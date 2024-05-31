#define HARVESTER_EC

#include "Translates.ech"
#include "Items.ech"

harvester TRL_SCRIPT_HARVESTER
{

////    Declarations    ////

state InitInBuilding;
state Nothing;
state WaitingForHarvestPointOrDestination;
state AIAfterMove;
state AIAfterMove2;
state WaitForMovingToHarvestPoint;
state MovingToHarvestPoint;
state MovingToDestinationBuilding;
state Harvesting;
state PuttingResource;

int m_nHarvestX;
int m_nHarvestY;
int m_nHarvestZ;
int m_bValidHarvest;
int m_nDestinationX;
int m_nDestinationY;
int m_nDestinationZ;
int m_bValidDestination;
int m_nHarvestMode;
int m_nFirstTime; //added by MD 28.08.2001 zeby krowa zaczynala automatycznie harwesowac po wyprodukowaniu

#define STOPCURRENTACTION
function int StopCurrentAction();

#ifdef AI_SCRIPT
#define STATE_AFTER_MOVE AIAfterMove
#endif AI_SCRIPT

#define CUSTOM_EVENT_ONCHECKDOINGNOTHING

#include "Common.ech"
#include "Trace.ech"
#include "Sleep.ech"
#include "Move.ech"
#include "Recycle.ech"
#include "CustomAnim.ech"
#include "MoveEx.ech"
#include "Events.ech"

////    Functions    ////

function int StopCurrentAction()
{
    if (IsHarvesting() || IsPuttingResource())
    {
        CallStopMoving();//dziala jak funkcja CallStopHarvesting
    }
    ResetCounterAfterMove();
    return true;
}//����������������������������������������������������������������������������������������������������|

function void SetHarvestPoint(int nX, int nY, int nZ)
{
    m_nHarvestX = nX;
    m_nHarvestY = nY;
    m_nHarvestZ = nZ;
    m_bValidHarvest = true;
    SetCurrentHarvestPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
}//����������������������������������������������������������������������������������������������������|

function void ResetHarvestPoint()
{
    m_bValidHarvest = false;
    InvalidateCurrentHarvestPoint();
}//����������������������������������������������������������������������������������������������������|

function int SetHarvestPointInCurrPos()
{
    //sprawdza czy tam gdzie stoi jest resource i jesli tak to go ustawia
    int nPosX, nPosY, nPosZ;

    nPosX = GetLocationX();
    nPosY = GetLocationY();
    nPosZ = GetLocationZ();
    if (m_bValidDestination && (nPosX == m_nDestinationX) && (nPosY == m_nDestinationY) && (nPosZ == m_nDestinationZ))
    {
        return false;
    }
    if (IsResourceInPoint(nPosX, nPosY, nPosZ) &&
        (!m_nHarvestMode || (GetResourcesPercentInPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ) >= 30)))
    {
        SetHarvestPoint(nPosX, nPosY, nPosZ);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function void MoveToHarvestPoint()
{
    CallMoveToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
}//����������������������������������������������������������������������������������������������������|

function void MoveToDestinationBuilding(int bMoveForce)
{
    m_nDestinationX = GetHarvesterBuildingPutLocationX();
    m_nDestinationY = GetHarvesterBuildingPutLocationY();
    m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
    m_bValidDestination = true;
    if (bMoveForce)
    {
        CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
    }
    else
    {
        CallMoveToPoint(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
    }
}//����������������������������������������������������������������������������������������������������|

function int GetFindResourceFlags()
{
    return findModeCloseToDestination;//findModeStraight
}//����������������������������������������������������������������������������������������������������|

function int FindNewHarvestPoint()
{
    //znajduje nowy punkt z zasobami i do niego jedzie
    if (FindResource(GetFindResourceFlags()))
    {
        if ((Distance(m_nHarvestX, m_nHarvestY, GetFoundResourceX(), GetFoundResourceY()) > 12) &&
            m_bValidDestination && (Distance(m_nDestinationX, m_nDestinationY, GetFoundResourceX(), GetFoundResourceY()) > 10))
        {
            return false;
        }
        SetHarvestPoint(GetFoundResourceX(), GetFoundResourceY(), GetFoundResourceZ());
        return true;
    }
    //m_bValidHarvest zostaje takie jakie bylo
    return false;
}//����������������������������������������������������������������������������������������������������|

function int FindNewHarvestPointFromCurrHarvestPoint()
{
    ASSERT(m_bValidHarvest);
    //znajduje nowy punkt z zasobami w poblizu starego i do niego jedzie
    if (FindResource(GetFindResourceFlags(), m_nHarvestX, m_nHarvestY, m_nHarvestY))
    {
        if (m_bValidDestination && (Distance(m_nDestinationX, m_nDestinationY, GetFoundResourceX(), GetFoundResourceY()) > 15))
        {
            return false;
        }
        SetHarvestPoint(GetFoundResourceX(), GetFoundResourceY(), GetFoundResourceZ());
        return true;
    }
    //m_bValidHarvest zostaje takie jakie bylo
    return false;
}//����������������������������������������������������������������������������������������������������|

function int MoveFindToDestinationBuilding(int bMoveForce)
{
    unit uBuilding;

    if (m_bValidDestination && (GetHarvesterBuilding() != null))
    {
        if (bMoveForce)
        {
            CallMoveToPointForce(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
        }
        else
        {
            CallMoveToPoint(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
        }
        return true;
    }
    else
    {
        //znalezc inny budynek
        uBuilding = FindHarvesterBuilding();
        if (uBuilding != null)
        {
            SetHarvesterBuilding(uBuilding);
            MoveToDestinationBuilding(bMoveForce);
            return true;
        }
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state InitInBuilding
{
    if (IsFreePoint(GetLocationX(), GetLocationY(), GetLocationZ()))
    {
        return Nothing;
    }
    //czeka w budynku na otwarcie drzwi
    return InitInBuilding;
}//����������������������������������������������������������������������������������������������������|

state Nothing
{
    if ((TALKMODE == 1) || IsInBuilding())
    {
        return Nothing;
    }
    //added by MD 28.08.2001 zeby krowa zaczynala automatycznie harwesowac po wyprodukowaniu
    if (m_nFirstTime > 0)
    {
        --m_nFirstTime;
        if ((m_nFirstTime == 0) && !m_bValidHarvest)
        {
            m_nHarvestX = GetLocationX();
            m_nHarvestY = GetLocationY();
            m_nHarvestZ = 0;
            if (FindNewHarvestPoint())
            {
                MoveToHarvestPoint();
                return MovingToHarvestPoint;
            }
        }
    }
    TRACE1("Nothing0");
    return Nothing;
}//����������������������������������������������������������������������������������������������������|

state WaitingForHarvestPointOrDestination
{
    if (!HaveFullResources())
    {
        if (FindNewHarvestPoint())
        {
            MoveToHarvestPoint();
            return MovingToHarvestPoint;
        }
    }
    if (HaveSomeResources())
    {
        if (MoveFindToDestinationBuilding(false))
        {
            return MovingToDestinationBuilding;
        }
    }
    return WaitingForHarvestPointOrDestination, 60;
}//����������������������������������������������������������������������������������������������������|

//krowa AI dostaje komende Move wtedy gdy ma sie usunac z miejsca w ktorym 
//ma zostac zbudowany budynek, dlatego tutaj jest obsluga powrotu do pracy
state AIAfterMove
{
    return AIAfterMove2, 100;
}//����������������������������������������������������������������������������������������������������|

state AIAfterMove2
{
    if (HaveFullResources())
    {
        if (MoveFindToDestinationBuilding(false))
        {
            return MovingToDestinationBuilding;
        }
        else
        {
            TRACE1("WaitingForHarvestPointOrDestination");
            return WaitingForHarvestPointOrDestination;
        }
    }
    else
    {
        if (m_bValidHarvest || FindNewHarvestPoint())
        {
            MoveToHarvestPoint();
            return MovingToHarvestPoint;
        }
        else
        {
            ResetHarvestPoint();
            TRACE1("WaitingForHarvestPointOrDestination");
            return WaitingForHarvestPointOrDestination;
        }
    }
}//����������������������������������������������������������������������������������������������������|

state WaitForMovingToHarvestPoint
{
    if (IsHarvesting())
    {
        return WaitForMovingToHarvestPoint, 5;
    }
    else
    {
        //tak dla pewnosci wywolujemy jeszcze raz Call...
        CallMoveToPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ);
        return MovingToHarvestPoint, 40;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToHarvestPoint
{
    int nPosX;
    int nPosY;
    int nPosZ;
    
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (m_nHarvestMode)
        {
            nPosX = GetStopLocationX();
            nPosY = GetStopLocationY();
            nPosZ = GetStopLocationZ();
            if (m_bValidDestination && (Distance(nPosX, nPosY, m_nDestinationX, m_nDestinationY) >= 3) &&
                (GetResourcesPercentInPoint(nPosX, nPosY, nPosZ) == 100))
            {
                CallStopMoving();
                SetHarvestPoint(nPosX, nPosY, nPosZ);
            }
        }
        return MovingToHarvestPoint, 5;
    }
    else
    {
        nPosX = GetLocationX();
        nPosY = GetLocationY();
        nPosZ = GetLocationZ();
        if (m_bValidHarvest && (nPosX == m_nHarvestX) && (nPosY == m_nHarvestY) && (nPosZ == m_nHarvestZ))
        {
            //sprawdzic czy jest tu jeszcze zasob
            if (IsResourceInPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ) &&
                (!m_nHarvestMode || (GetResourcesPercentInPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ) >= 30)))
            {
                CallHarvest();
                return Harvesting;
            }
            else
            {
                //znalezc jakis zasob
                if (FindNewHarvestPoint())
                {
                    if ((nPosX == m_nHarvestX) && (nPosY == m_nHarvestY) && (nPosZ == m_nHarvestZ))
                    {
                        CallHarvest();
                        return Harvesting;
                    }
                    else
                    {
                        MoveToHarvestPoint();
                        return MovingToHarvestPoint;
                    }
                }
                else
                {
                    ResetHarvestPoint();
                    TRACE1("WaitingForHarvestPointOrDestination");
                    return WaitingForHarvestPointOrDestination;
                }
            }
        }
        else
        {
            //sprawdzic czy nie ma zasobu tu gdzie stoimy (o ile jest rozny od slotu budynku)
            if (SetHarvestPointInCurrPos())
            {
                //ok harvestujemy tu gdzie jestesmy
                CallHarvest();
                return Harvesting;
            }
            else
            {
                //znalezc jakis zasob
                if (FindNewHarvestPoint())
                {
                    MoveToHarvestPoint();
                    return MovingToHarvestPoint;
                }
                else
                {
                    ResetHarvestPoint();
                    TRACE1("WaitingForHarvestPointOrDestination");
                    return WaitingForHarvestPointOrDestination;
                }
            }
        }
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToDestinationBuilding
{
    int nPosX;
    int nPosY;
    int nPosZ;

    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        return MovingToDestinationBuilding, 5;
    }
    else
    {
        nPosX = GetLocationX();
        nPosY = GetLocationY();
        nPosZ = GetLocationZ();
        if (m_bValidDestination && (nPosX == m_nDestinationX) && (nPosY == m_nDestinationY) && (nPosZ == m_nDestinationZ))
        {
            CallPutResource();
            return PuttingResource;
        }
        else
        {
            if (m_bValidDestination)
            {
                //kazac mu tam znowu jechac (moze jakis licznik (+ zmiana budynku) zeby nie wywolywal tego w kolko)
                CallMoveToPoint(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
                return MovingToDestinationBuilding, 40;
            }
            else
            {
                TRACE1("WaitingForHarvestPointOrDestination");
                return WaitingForHarvestPointOrDestination;
            }
        }
    }
}//����������������������������������������������������������������������������������������������������|

state Harvesting
{
    int nResGx, nResGy, nResLz;
    if (IsHarvesting())
    {
        //jeszcze nie skonczyl
        if (m_nHarvestMode && (GetResourcesPercentInPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ) < 20))
        {
            //probujemy znalezc lepszy zasob
            if (FindResource(GetFindResourceFlags()))
            {
                nResGx = GetFoundResourceX();
                nResGy = GetFoundResourceY();
                nResLz = GetFoundResourceZ();
                if ((Distance(m_nHarvestX, m_nHarvestY, nResGx, nResGy) <= 5) &&
                    (GetResourcesPercentInPoint(nResGx, nResGy, nResLz) > 60))
                {
                    //jedziemy tam
                    SetHarvestPoint(nResGx, nResGy, nResLz);
                    MoveToHarvestPoint();
                    return WaitForMovingToHarvestPoint;
                }
            }
        }
        return Harvesting;
    }
    else
    {
        //skonczyl - jedziemy do budynku
        if (HaveFullResources())
        {
            if (MoveFindToDestinationBuilding(false))
            {
                return MovingToDestinationBuilding;
            }
            else
            {
                TRACE1("WaitingForHarvestPointOrDestination");
                return WaitingForHarvestPointOrDestination;
            }
        }
        else
        {
            //nie zdolalismy zapelnic calego pojazdu - znalezc nastepna kratke
            if (FindNewHarvestPoint())
            {
                MoveToHarvestPoint();
                return MovingToHarvestPoint;
            }
            else
            {
                ResetHarvestPoint();
                //nie ma juz zasobow - pojechac z tym co mamy (o ile mamy) do budynku
                if (HaveSomeResources())
                {
                    if (MoveFindToDestinationBuilding(false))
                    {
                        return MovingToDestinationBuilding;
                    }
                    else
                    {
                        TRACE1("WaitingForHarvestPointOrDestination");
                        return WaitingForHarvestPointOrDestination;
                    }
                }
                else
                {
                    TRACE1("WaitingForHarvestPointOrDestination");
                    return WaitingForHarvestPointOrDestination;
                }
            }
        }
    }
}//����������������������������������������������������������������������������������������������������|

state PuttingResource
{
    if (IsPuttingResource())
    {
        return PuttingResource;
    }
    else
    {
        if (HaveSomeResources())
        {
            //z jakiegos powodu zostaly resource'y
            if (MoveFindToDestinationBuilding(false))
            {
                return MovingToDestinationBuilding;
            }
            //else przechodzimy dalej
        }
        //nie sprawdzamy IsResourceInPoint zeby nie weszla do znajdowania nowego punktu
        //bo moze znalezc ten na ktorym stoimy i zablokowac slot budynku
        //pojechac tam
        if (m_nHarvestMode && m_bValidHarvest)
        {
            if (GetResourcesPercentInPoint(m_nHarvestX, m_nHarvestY, m_nHarvestZ) < 40)
            {
                FindNewHarvestPointFromCurrHarvestPoint();
            }
        }
        if (m_bValidHarvest || FindNewHarvestPoint())
        {
            MoveToHarvestPoint();
            return MovingToHarvestPoint;
        }
        else
        {
            ResetHarvestPoint();
            TRACE1("WaitingForHarvestPointOrDestination");
            return WaitingForHarvestPointOrDestination;
        }
    }
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    unit uTarget, uBuilding;

    if (ExitSleepModeOnHit())
    {
        return true;
    }
    if (!IsMoving() || (state == MovingToHarvestPoint))
    {
        if (MoveFindToDestinationBuilding(
#ifdef AI_HARVESTER_EC
            true
#else
            false
#endif
            ))
        {
            state StartMoving;
        }
        else
        {
            //retreat
            if (uByUnit)
            {
                uTarget = uByUnit;
            }
            else
            {
                uTarget = FindClosestEnemy();
            }
            if (uTarget)
            {
                MoveToPoint(2*GetLocationX() - uTarget.GetLocationX(), 2*GetLocationY() - uTarget.GetLocationY(), GetLocationZ());
                state StartMoving;
            }
        }
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

event OnKilled()
{
    m_bValidHarvest = false;//potrzebne przy przejezdzaniu do innego swiata
    m_bValidDestination = false;
    InvalidateCurrentHarvestPoint();
    SetHarvesterBuilding(null);
    return true;
}//����������������������������������������������������������������������������������������������������|

event OnCheckDoingNothing()
{
    if ((state == Nothing) && (m_nFirstTime == 0))
    {
        TRACE1("OnCheckDoingNothing->true");
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command Initialize()
{
    m_bValidHarvest = false;
    m_bValidDestination = false;
    m_nFirstTime = 4; //added by MD 28.08.2001 zeby krowa zaczynala automatycznie harwesowac po wyprodukowaniu
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    //wykasowac referencje
    m_bValidHarvest = false;//potrzebne przy przejezdzaniu do innego swiata
    m_bValidDestination = false;
    ResetEnterBuilding();
    InvalidateCurrentHarvestPoint();
    SetHarvesterBuilding(null);
    ResetCustomAnim();
    return true;
}//����������������������������������������������������������������������������������������������������|

//bez nazwy - wywolywane po kliknieciu kursorem
command SetHarvestPoint(int nX, int nY, int nZ) hidden button TRL_HARVEST
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    SetHarvestPoint(nX, nY, nZ);
    if (!IsResourceInPoint(nX, nY, nZ))
    {
        //nie ma tam resource'ow ale tam jedziemy
        ResetHarvestPoint();
    }
    if (!HaveFullResources())
    {
        MoveToHarvestPoint();
        if (IsHarvesting())
        {
            state WaitForMovingToHarvestPoint;
        }
        else
        {
            state MovingToHarvestPoint;
        }
    }
    else
    {
        if (MoveFindToDestinationBuilding(false))
        {
            state MovingToDestinationBuilding;
        }
    }
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|

//bez nazwy - wywolywane po kliknieciu kursorem
command SetHarvestDestination(unit uObject) hidden button TRL_SETREFINERY
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    SetHarvesterBuilding(uObject);
    m_nDestinationX = GetHarvesterBuildingPutLocationX();
    m_nDestinationY = GetHarvesterBuildingPutLocationY();
    m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
    m_bValidDestination = true;
    if (HaveSomeResources())
    {
        CallMoveToPoint(m_nDestinationX, m_nDestinationY, m_nDestinationZ);
        state MovingToDestinationBuilding;
    }
    else
    {
        if ((state != Harvesting) && m_bValidHarvest)
        {
            MoveToHarvestPoint();
            if (IsHarvesting())
            {
                state WaitForMovingToHarvestPoint;
            }
            else
            {
                state MovingToHarvestPoint;
            }
        }
    }
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|

command InitHarvestDestination(unit uObject) hidden button TRL_SETREFINERY
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    SetHarvesterBuilding(uObject);
    m_nDestinationX = GetHarvesterBuildingPutLocationX();
    m_nDestinationY = GetHarvesterBuildingPutLocationY();
    m_nDestinationZ = GetHarvesterBuildingPutLocationZ();
    m_bValidDestination = true;
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|

command MoveToDestination() button TRL_MOVETODEST description TRL_MOVETODEST item ITEM_MOVETODEST priority PRIOR_MOVETODEST hotkey
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if ((state == MovingToDestinationBuilding) || (state == PuttingResource))
    {
        NextCommand(1);
        return true;
    }
    if (HaveSomeResources() && MoveFindToDestinationBuilding(false))
    {
        state MovingToDestinationBuilding;
    }
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|

command MoveToHarvestPoint() button TRL_MOVETOHARVESTPOINT description TRL_MOVETOHARVESTPOINT item ITEM_MOVETOHARVESTPOINT priority PRIOR_MOVETOHARVESTPOINT hotkey
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if (state == Harvesting)
    {
        NextCommand(1);
        return true;
    }
    if (HaveFullResources())
    {
        if ((state == MovingToDestinationBuilding) || (state == PuttingResource))
        {
            NextCommand(1);
            return true;
        }
        if (MoveFindToDestinationBuilding(false))
        {
            state MovingToDestinationBuilding;
        }
    }
    if (m_bValidHarvest || FindNewHarvestPoint())
    {
        MoveToHarvestPoint();
        state MovingToHarvestPoint;
    }
    else
    {
        ResetHarvestPoint();
    }
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|

//m_nHarvestMode: 0-normal, 1-smart(AI)
command SetHarvestMode(int nMode) hidden
{
    ASSERT(nMode != -1);
    m_nHarvestMode = nMode;
    NextCommand(1);
    return true;
}//����������������������������������������������������������������������������������������������������|
}
