#define CAPTURER_EC

#include "Translates.ech"
#include "Items.ech"

repairer TRL_SCRIPT_CAPTURER
{

////    Declarations    ////

state Initialize;
state Nothing;
state AfterConversion;
state MovingToStay;
state MovingToConvertTarget;
state Converting;
state StartMovingToCaptureBuilding;
state MovingToCaptureBuilding;
state StartMovingToWatchRepair;
state MovingToWatchRepair;
state WatchingRepair;
state StartMovingToWatchBuild;
state MovingToWatchBuild;
state WatchingBuild;

int  m_nFindType;
unit m_uCurrTarget;
int  m_nStartTargetGx, m_nStartTargetGy;
int  m_bSelfTarget;
int  m_nStayGx, m_nStayGy, m_nStayLz, m_nStayAlpha;

#define STOPCURRENTACTION
function int StopCurrentAction();

function int FindStateNothingTarget();

#include "Common.ech"
#include "Trace.ech"
#include "Sleep.ech"
#include "HoldPos.ech"
#include "Move.ech"
#include "Recycle.ech"
#include "CustomAnim.ech"
#include "MoveEx.ech"
#include "Events.ech"
#include "HealingPlace.ech"

////    Functions    ////

function void ResetCurrentTarget()
{
    m_uCurrTarget = null;
    SetRepairObject(null);
    m_nStartTargetGx = 0;
    m_nStartTargetGy = 0;
}//����������������������������������������������������������������������������������������������������|

function void SetCurrentTarget(unit uTarget, int bSelfTarget)
{
    m_uCurrTarget = uTarget;
    m_bSelfTarget = bSelfTarget;
    SetRepairObject(m_uCurrTarget);
    if (uTarget != null)
    {
        m_nStartTargetGx = uTarget.GetLocationX();
        m_nStartTargetGy = uTarget.GetLocationY();
    }
    else
    {
        m_nStartTargetGx = 0;
        m_nStartTargetGy = 0;
    }
}//����������������������������������������������������������������������������������������������������|

//znalezienie krowy do przejecia
//znajdujemy tylko te ktore stoja po to aby pastuszek nie chodzil bez sensu za krowa ktora idzie gdzies daleko na 
//pastwisko, lub wraca do bazy wroga
function unit FindTargetToConvert(int nFindType)
{
    int nIndex, nTargetsCount;
    unit uTarget;
    int nLocGx, nLocGy, nLocLz;
    
    BuildTargetsArray(nFindType, findEnemyUnit);
    SortFoundTargetsArray();
    nTargetsCount = GetTargetsCount();
    if (nTargetsCount != 0)
    {
        StartEnumTargetsArray();
        for (nIndex = 0; nIndex < nTargetsCount; ++nIndex)
        {
            uTarget = GetNextTarget();
            if (CanBeConverted(uTarget) && !uTarget.IsMoving() &&
                (DistanceTo(uTarget.GetLocationX(), uTarget.GetLocationY()) < 8))
            {
                nLocGx = GetOperateOnTargetLocationX(uTarget);
                nLocGy = GetOperateOnTargetLocationY(uTarget);
                nLocLz = GetOperateOnTargetLocationZ(uTarget);
                if (IsGoodPointForOperateOnTarget(uTarget, nLocGx, nLocGy, nLocLz))
                {
                    EndEnumTargetsArray();
                    return uTarget;
                }
            }
        }
        EndEnumTargetsArray();
    }
    return null;
}//����������������������������������������������������������������������������������������������������|

//znajdujemy budynek do przejecia
function unit FindTargetToCapture()
{
    int nIndex, nTargetsCount;
    unit uTarget;
    
    BuildTargetsArray(findTargetBuilding, findEnemyUnit);
    SortFoundTargetsArray();
    nTargetsCount = GetTargetsCount();
    if (nTargetsCount != 0)
    {
        StartEnumTargetsArray();
        for (nIndex = 0; nIndex < nTargetsCount; ++nIndex)
        {
            uTarget = GetNextTarget();
            if (CanBeCaptured(uTarget))
            {
                EndEnumTargetsArray();
                return uTarget;
            }
        }
        EndEnumTargetsArray();
    }
    return null;
}//����������������������������������������������������������������������������������������������������|

function int MoveToTarget(unit uTarget)
{
    m_nMoveToGx = GetOperateOnTargetLocationX(uTarget);
    m_nMoveToGy = GetOperateOnTargetLocationY(uTarget);
    m_nMoveToLz = GetOperateOnTargetLocationZ(uTarget);
    if (IsGoodPointForOperateOnTarget(uTarget, m_nMoveToGx, m_nMoveToGy, m_nMoveToLz))
    {
        CallMoveToPoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function void StopConverting()
{
    CallStopMoving();
    ResetCurrentTarget();
    NextCommand(1);
}//����������������������������������������������������������������������������������������������������|

function int StopCurrentAction()
{
    if (IsConverting())
    {
        CallStopMoving();//dziala jak funkcja CallStopConverting
    }
    ResetCounterAfterMove();
    ResetCurrentTarget();
    m_bSelfTarget = false;
    return true;
}//����������������������������������������������������������������������������������������������������|

function int TryFindNewConvertTarget()
{
    unit uTarget;

    if (IsInHoldPosMode())
    {
        return false;
    }
    if (!m_nFindType)
    {
        return false;
    }
    uTarget = FindTargetToConvert(m_nFindType);
    if ((uTarget != null) && MoveToTarget(uTarget))
    {
        SetCurrentTarget(uTarget, true);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function int TryFindNewCaptureTarget()
{
    unit uTarget;

    if (IsInHoldPosMode())
    {
        return false;
    }
    if (!CanCaptureBuildings())
    {
        return false;
    }
    uTarget = FindTargetToCapture();
    if (uTarget != null)
    {
         CallMoveInsideObject(uTarget);
        SetCurrentTarget(uTarget, true);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function int FindStateNothingTarget()
{
    if (TryFindNewConvertTarget())
    {
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        state MovingToConvertTarget;
        return true;
    }
    if (TryFindNewCaptureTarget())
    {
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        SetStateDelay(5);
        state StartMovingToCaptureBuilding;
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Initialize
{
    //inicjacja StayGx,y na wszelki wypadek aby w przypadku jakiegos bledu nie poszedl do 0, 0 w AfterConverting
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    return Nothing;
}//����������������������������������������������������������������������������������������������������|

state Nothing
{
    unit uEnemy;
    int nDist, nPosX, nPosY, nDistX, nDistY;

    if ((TALKMODE == 1) || IsInBuilding())
    {
        return Nothing;
    }
    if (!FindStateNothingTarget())
    {
        if (!IsInHoldPosMode() && !CheckHoldPosAfterMove() && TryMoveToHealingPlace(true))
        {
            return StartMovingToHealingPlace;
        }
        if (!IsInHoldPosMode() && CanConvertAnimals())
        {//child
            uEnemy = FindTarget(findTargetUnit | findTargetFlyingUnit | findTargetArmedAnimal, findEnemyUnit, findNearestUnit);
            if ((uEnemy != null) && uEnemy.HaveWeapon() && (DistanceTo(uEnemy) <= 4))
            {
                //uciekamy od wroga
                ResetCounterAfterMove();
                nDist = DistanceTo(uEnemy);
                nPosX = GetLocationX();
                nPosY = GetLocationY();
                nDistX = nPosX - uEnemy.GetLocationX();
                nDistY = nPosY - uEnemy.GetLocationY();
                if (nDist > 0)
                {
                    nDistX = 5*nDistX/nDist;
                    nDistY = 5*nDistY/nDist;
                }
                MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
                return StartMoving,5;
            }
        }
        return Nothing;
    }
    //else state ustawiony w FindStateNothingTarget
}//����������������������������������������������������������������������������������������������������|

state AfterConversion
{
    if (!m_bSelfTarget)
    {
        return Nothing, 0;
    }
    if (TryFindNewConvertTarget())
    {
        return MovingToConvertTarget;
    }
    if (TryFindNewCaptureTarget())
    {
        return StartMovingToCaptureBuilding,5;
    }
    CallMoveToPoint(m_nStayGx, m_nStayGy, GetLocationZ());
    return MovingToStay;
}//����������������������������������������������������������������������������������������������������|

state MovingToStay
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (TryFindNewConvertTarget())
        {
            return MovingToConvertTarget;
        }
        if (TryFindNewCaptureTarget())
        {
            return StartMovingToCaptureBuilding,5;
        }
        return MovingToStay;
    }
    else
    {
        m_bSelfTarget = false;
        return Nothing, 0;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToConvertTarget
{
    TRACE("MovingToConvertTarget\n");
    if (IsWaitingBeforeClosedGate())
    {
        TRACE("IsWaitingBeforeClosedGate\n");
        StopConverting();
        return AfterConversion, 0;
    }
    else if (IsMoving())
    {
        //sprawdzanie czy cel jeszcze mozna przejac i czy sie ruszyl (wtedy trzeba zmienic kierunek jazdy)
        //sprawdzanie m_nStartTargetGx,y - zabezpieczenie zeby nie poszedl za krowa do obozu wroga
        if (CanBeConverted(m_uCurrTarget) && 
            (Distance(m_uCurrTarget.GetLocationX(), m_uCurrTarget.GetLocationY(), m_nStartTargetGx, m_nStartTargetGy) < 8) &&
            ((IsGoodPointForOperateOnTarget(m_uCurrTarget, m_nMoveToGx, m_nMoveToGy, m_nMoveToLz) && IsFreePoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz)) ||
             MoveToTarget(m_uCurrTarget)))
        {
            return MovingToConvertTarget, 5;
        }
        else
        {
            TRACE("IsMoving - unable to find operation point for target or target converted/dead\n");
            StopConverting();
            return AfterConversion, 0;
        }
    }
    else
    {
        //sprawdzic czy w punkcie w ktorym jestesmy mozemy zaczac naprawe
        if (IsInGoodPointForOperateOnTarget(m_uCurrTarget))
        {
            if (CanBeConverted(m_uCurrTarget))
            {
                CallConvert(m_uCurrTarget);
                return Converting;
            }
            else
            {
                TRACE(" - target converted/dead\n");
                StopConverting();
                return AfterConversion, 0;
            }
        }
        else
        {
            if (MoveToTarget(m_uCurrTarget))
            {
                return MovingToConvertTarget;
            }
            else
            {//unable to find operation point for target
                TRACE("IsNotMoving - unable to find operation point for target\n");
                StopConverting();
                return AfterConversion, 0;
            }
        }
    }
}//����������������������������������������������������������������������������������������������������|

state Converting
{
    if (IsConverting())
    {
        return Converting, 5;
    }
    else
    {
        //z jakiegos powodu jeszcze go nie skonvertowali�my - odjechal ?
        if (CanBeConverted(m_uCurrTarget) && MoveToTarget(m_uCurrTarget))
        {
            return MovingToConvertTarget;
        }
        else
        {
            StopConverting();
            if (IsFlyable())
            {
                //podniesc sie - po StopConverting
                CallMoveToPoint(GetLocationX(), GetLocationY(), GetLocationZ());
            }
            return AfterConversion, 0;
        }
    }
}//����������������������������������������������������������������������������������������������������|

state StartMovingToCaptureBuilding
{
    if (IsMoving() || !CheckKeepStartMoving())
    {
        return MovingToCaptureBuilding,0;
    }
    else
    {
        return StartMovingToCaptureBuilding,5;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToCaptureBuilding
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (m_uCurrTarget.IsVisibleFake())
        {
            if (!m_uCurrTarget.IsLive())
            {
                m_uCurrTarget = m_uCurrTarget.GetVisibleFakeObject();
                SetRepairObject(m_uCurrTarget);
                if (m_uCurrTarget == null)
                {
                    StopConverting();
                    return AfterConversion, 0;
                }
            }
        }
        if (!CanBeCaptured(m_uCurrTarget) && !m_uCurrTarget.IsVisibleFake())
        {
            StopConverting();
            return AfterConversion, 0;
        }
        return MovingToCaptureBuilding;
    }
    else
    {
        //skoro sie zatrzymalismy i jeszcze istniejemy to znaczy, ze nie mozna tam wejsc
        StopConverting();
        return AfterConversion, 0;
    }
}//����������������������������������������������������������������������������������������������������|

state StartMovingToWatchRepair
{
    if (IsMoving() || !CheckKeepStartMoving())
    {
        TRACE1("StartMovingToWatchRepair->MovingToWatchRepair");
        return MovingToWatchRepair,0;
    }
    else
    {
        return StartMovingToWatchRepair,5;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToWatchRepair
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if ((m_uCurrTarget == null) || !m_uCurrTarget.IsLive() || !m_uCurrTarget.IsDamaged())
        {
            TRACE1("MovingToWatchRepair->Nothing");
            m_uCurrTarget = null;
            NextCommand(1);
            return Nothing;
        }
        else if (DistanceTo(m_nMoveToGx, m_nMoveToGy) <= 2)
        {
            TRACE1("MovingToWatchRepair->WatchingRepair");
            CallStopMoving();
            return WatchingRepair;
        }
        return MovingToWatchRepair;
    }
    else
    {
        return WatchingRepair;
    }
}//����������������������������������������������������������������������������������������������������|

state WatchingRepair
{
    if ((m_uCurrTarget == null) || !m_uCurrTarget.IsLive() || !m_uCurrTarget.IsDamaged())
    {
        TRACE1("WatchingRepair->Nothing");
        m_uCurrTarget = null;
        NextCommand(1);
        return Nothing;
    }
    return WatchingRepair, 5;
}//����������������������������������������������������������������������������������������������������|

state StartMovingToWatchBuild
{
    if (IsMoving() || !CheckKeepStartMoving())
    {
        TRACE1("StartMovingToWatchBuild->MovingToWatchBuild");
        return MovingToWatchBuild,0;
    }
    else
    {
        return StartMovingToWatchBuild,5;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToWatchBuild
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if ((m_uCurrTarget == null) || !m_uCurrTarget.IsLive() || !m_uCurrTarget.IsDamaged())
        {
            TRACE1("MovingToWatchBuild->Nothing");
            m_uCurrTarget = null;
            NextCommand(1);
            return Nothing;
        }
        else if (DistanceTo(m_nMoveToGx, m_nMoveToGy) <= 2)
        {
            TRACE1("MovingToWatchBuild->WatchingBuild");
            CallStopMoving();
            return WatchingBuild;
        }
        return MovingToWatchBuild;
    }
    else
    {
        return WatchingBuild;
    }
}//����������������������������������������������������������������������������������������������������|

state WatchingBuild
{
    if ((m_uCurrTarget == null) || !m_uCurrTarget.IsLive() || !m_uCurrTarget.IsDamaged())
    {
        TRACE1("WatchingBuild->Nothing");
        m_uCurrTarget = null;
        NextCommand(1);
        return Nothing;
    }
    return WatchingBuild, 5;
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    int nDistX, nDistY, nDist, nRange, nPosX, nPosY;
    int nHP, nMaxHP;
    unit uBuilding;

    if (ExitSleepModeOnHit())
    {
        return true;
    }
#ifdef AI_SCRIPT
    if ((uByUnit == null) && (state == Nothing) && !IsInHoldPosMode() && (TALKMODE == 0))
    {
        //uciekamy spod deszczu meteorytow
        nRange = 10;
        nPosX = GetLocationX();
        nPosY = GetLocationY();
        nDistX = 0 - nRange/2 + RAND(nRange);
        nDistY = 0 - nRange/2 + RAND(nRange);
        MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
        state StartMoving;
    }
#endif AI_SCRIPT
    nHP = GetHP();
    nMaxHP = GetMaxHP();
    //03-07-30 pastuszek ucieka zawsze
    if (!IsMoving() && /*(nHP < 2*nMaxHP/3) &&*/ !IsInHoldPosMode() && (TALKMODE == 0))
    {
        if (nHP <= nMaxHP/3)
        {
            uBuilding = FindBuilding(buildingHarvestFactory);
        }
        if ((nHP > nMaxHP/3) || (uBuilding == null))
        {
            //uciekamy troche dalej
            nRange = 5;
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            if ((uByUnit != null) && IsVisible(uByUnit))
            {
                nDist = DistanceTo(uByUnit);
                nDistX = nPosX - uByUnit.GetLocationX();
                nDistY = nPosY - uByUnit.GetLocationY();
                if (nDist > 0)
                {
                    nDistX = nRange*nDistX/nDist;
                    nDistY = nRange*nDistY/nDist;
                }
            }
            else
            {
                nDistX = 0 - nRange/2 + RAND(nRange);
                nDistY = 0 - nRange/2 + RAND(nRange);
            }
            MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
            state StartMoving;
        }
        else
        {
            //uciekamy do wioski
            MoveToPoint(uBuilding.GetLocationX(), uBuilding.GetLocationY(), uBuilding.GetLocationZ());
            state StartMoving;
        }
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

event OnKilled()
{
    ResetCurrentTarget();
    return true;
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command Initialize()
{
    InitializeHoldPos();
    m_nFindType = 0;
    if (CanConvertUnits())
    {
        m_nFindType = m_nFindType | findTargetUnit;
    }
    if (CanConvertBuildings())
    {
        m_nFindType = m_nFindType | findTargetBuilding;
    }
    if (CanConvertAnimals())
    {
        m_nFindType = m_nFindType | findTargetArmedAnimal | findTargetUnarmedAnimal;
    }
    //inicjacja StayGx,y na wszelki wypadek aby w przypadku jakiegos bledu nie poszedl do 0, 0 w AfterConverting
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    //wykasowac referencje
    ResetEnterBuilding();
    ResetCurrentTarget();
    ResetCustomAnim();
    return true;
}//����������������������������������������������������������������������������������������������������|

//bez nazwy - wywolywany przez kursor
command Convert(unit uTarget) hidden button TRL_CONVERT
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if (CanBeConverted(uTarget) && MoveToTarget(uTarget))
    {
        CHECK_STOP_CURR_ACTION();
        SetCurrentTarget(uTarget, false);
        state MovingToConvertTarget;
    }
    else
    {
        NextCommand(0);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

command CaptureBuilding(unit uTarget) hidden button TRL_CAPTUREBUILDING
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if (CanBeCaptured(uTarget) || uTarget.IsVisibleFake())
    {
        CHECK_STOP_CURR_ACTION();
        CallMoveInsideObject(uTarget);
        SetCurrentTarget(uTarget, false);
        state StartMovingToCaptureBuilding;
    }
    else
    {
        NextCommand(0);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

command Repair(unit uTarget) hidden button TRL_REPAIR
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if ((uTarget != null) && uTarget.IsLive() && uTarget.IsDamaged() && 
        HaveLookRoundEquipment(lookRoundTypeBuildSpeedIncrease) && MoveToTarget(uTarget))
    {
        CHECK_STOP_CURR_ACTION();
        m_uCurrTarget = uTarget;
        TRACE1("command Repair->StartMovingToWatchRepair");
        state StartMovingToWatchRepair;
    }
    else
    {
        NextCommand(0);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

command BuildObject(unit uObjectToBuild) hidden button TRL_BUILDOBJECT
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if ((uObjectToBuild != null) && uObjectToBuild.IsLive() && uObjectToBuild.IsDamaged() && 
        HaveLookRoundEquipment(lookRoundTypeBuildSpeedIncrease) && MoveToTarget(uObjectToBuild))
    {
        CHECK_STOP_CURR_ACTION();
        m_uCurrTarget = uObjectToBuild;
        TRACE1("command BuildObject->StartMovingToWatchBuild");
        state StartMovingToWatchBuild;
    }
    else
    {
        NextCommand(0);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|
}
