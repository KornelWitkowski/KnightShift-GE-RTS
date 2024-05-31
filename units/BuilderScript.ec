#define BUILDER_EC

#include "Translates.ech"
#include "Items.ech"

builder TRL_SCRIPT_BUILDER
{

////    Declarations    ////

state Initialize;
state Nothing;
state AfterWorking;
state AfterAttack;
state AfterKilledTarget;
state MovingToStayAfterWorking;
state MovingToStayAfterAttack;
state MovingToBuildObject;
state BuildObject;
state MovingToRepairedObject;
state Repairing;

unit m_uBuilderTarget;
int  m_nBuildObjectType;
int  m_bSelfTarget;
int  m_nMoveTryCounter;
int  m_nStayGx;
int  m_nStayGy;
int  m_nStayLz;
int  m_nStayAlpha;
int  m_bCheckAccessibleInNextFind;
int  m_nWaitingBeforeNotWithdrawalCounter;

#define STOPCURRENTACTION
function int StopCurrentAction();

//#define ONMOVINGCALLBACK 
function int OnMovingCallback();

#define STATE_AFTER_ATTACK AfterAttack

#define STATE_AFTER_KILLED_TARGET AfterKilledTarget

#define STATE_MOVING_AFTER_EQUIPMENT_ARTEFACT MovingToStayAfterAttack

#define STORE_STAY_POS
function void StoreStayPos();

function int FindStateNothingTarget();

#define USE_MOVEANDDEFEND

#include "Common.ech"
#include "Trace.ech"
#include "Sleep.ech"
#include "HoldPos.ech"
#include "Move.ech"
#include "Recycle.ech"
#include "Equipment.ech"
#include "CustomAnim.ech"
#include "Attack.ech"
#include "MoveEx.ech"
#include "Events.ech"
#include "EquipmentArtefact.ech"
#include "HealingPlace.ech"

////    Functions    ////

function void ResetCurrentTarget()
{
    m_uBuilderTarget = null;
    SetRepairObject(null);
}//����������������������������������������������������������������������������������������������������|

function void SetCurrentTarget(unit uTarget, int bSelfTarget)
{
    m_uBuilderTarget = uTarget;
    if ((uTarget != null) && CanBeBuild(uTarget))
    {
        m_nBuildObjectType = GetBuildType(uTarget);
    }
    else
    {
        m_nBuildObjectType = buildNone;
    }
    m_bSelfTarget = bSelfTarget;
    m_nMoveTryCounter = 0;
    m_nWaitingBeforeNotWithdrawalCounter = 0;
    SetRepairObject(m_uBuilderTarget);
}//����������������������������������������������������������������������������������������������������|

function int StopCurrentAction()
{
    if (IsAttacking())
    {
        CallStopAttack();
    }
    if (IsRepairing() || IsBuildWorking())
    {
        CallStopMoving();//dziala jak funkcja CallStopRepairing
    }
    ResetCounterAfterMove();
    ResetCurrentTarget();
    ResetAttackTarget();
    ResetEnterBuilding();
    m_bSelfAttackTarget = false;
    m_bSelfTarget = false;
    return true;
}//����������������������������������������������������������������������������������������������������|

//wywolywane w czasie wykonywania komendy MoveTo, zwracamy true jesli znalezlismy cel do ataku lub false jesli nie
function int OnMovingCallback()
{
    if (!IsInHoldPosMode() && (TALKMODE == 0) &&
        (DistanceTo(m_nMoveToGx, m_nMoveToGy) < 4) && (DistanceTo(m_nStartMoveGx, m_nStartMoveGy) > 6) &&
        (GetLocationZ() == m_nMoveToLz) && (GetWeaponType() == cannonTypeSword) && !HaveNextCommand() &&
        !IsArtefactInPoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz) && !IsHealingOrConversionPlaceInPoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz))
    {
        if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, false))
        {
            m_nStayGx = m_nMoveToGx;
            m_nStayGy = m_nMoveToGy;
            m_nStayLz = m_nMoveToLz;
            m_nStayAlpha = -1;
            state MovingToAttackTarget;
            return true;
        }
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function unit FindTargetToRepair()
{
    int i;
    int nLocGx, nLocGy, nLocLz;
    int iX, iY, iZ;
    int nTargetsCount;
    unit newTarget;
    
    // Nie szukamy palisady, żeby drwale skupili się na ważniejszych celach na początku
    BuildTargetsArray(findTargetBuilding, findOurUnit | findNeutralUnit);
    SortFoundTargetsArray();
    nTargetsCount = GetTargetsCount();
    if (nTargetsCount != 0)
    {
        StartEnumTargetsArray();
        for (i = 0; i < nTargetsCount; ++i)
        {
            newTarget = GetNextTarget();
            if (CanBeRepaired(newTarget))
            {
                nLocGx = GetOperateOnTargetLocationX(newTarget);
                nLocGy = GetOperateOnTargetLocationY(newTarget);
                nLocLz = GetOperateOnTargetLocationZ(newTarget);
        iX = GetLocationX();
        iY = GetLocationY();
        iZ = GetLocationZ();

        if (!IsAccessible(newTarget))
        {
            continue;
        }
                if (IsGoodPointForOperateOnTarget(newTarget, nLocGx, nLocGy, nLocLz))
        {
                    EndEnumTargetsArray();
                            return newTarget;
        }
            }
        }
        EndEnumTargetsArray();
    }
    return null;
}


function unit FindWallToRepair()
{
    int i;
    int nLocGx, nLocGy, nLocLz;
    int iX, iY, iZ;
    int nTargetsCount;
    unit newTarget;
    
    BuildTargetsArray(findTargetWall, findOurUnit | findNeutralUnit);
    SortFoundTargetsArray();
    nTargetsCount = GetTargetsCount();
    if (nTargetsCount != 0)
    {
        StartEnumTargetsArray();
        for (i = 0; i < nTargetsCount; ++i)
        {
            newTarget = GetNextTarget();
            if (CanBeRepaired(newTarget))
            {
                nLocGx = GetOperateOnTargetLocationX(newTarget);
                nLocGy = GetOperateOnTargetLocationY(newTarget);
                nLocLz = GetOperateOnTargetLocationZ(newTarget);
                iX = GetLocationX();
                iY = GetLocationY();
                iZ = GetLocationZ();

                if (!IsAccessible(newTarget))
                {
                    continue;
                }
                if (IsGoodPointForOperateOnTarget(newTarget, nLocGx, nLocGy, nLocLz))
                {
                    EndEnumTargetsArray();
                    return newTarget;
                }
            }
        }
        EndEnumTargetsArray();
    }
    return null;
}

function unit FindTargetToBuild(int bCheckAccessibleMode)
{
    return FindNextObjectToBuild(buildBuildingMask | buildWallMask | buildBridgeMask, bCheckAccessibleMode);
}//����������������������������������������������������������������������������������������������������|

function unit FindNextTargetToBuild(unit uLastBuildTarget, int nLastBuildType)
{
    int  nMask;
    unit uTarget;

    if ((nLastBuildType == buildWall) || (nLastBuildType == buildBridge))
    {
        if (nLastBuildType == buildWall)
        {
            nMask = buildWallMask;
        }
        else if (nLastBuildType == buildBridge)
        {
            nMask = buildBridgeMask;
        }
        if (uLastBuildTarget)
        {
            uTarget = FindNextObjectToBuild(uLastBuildTarget.GetLocationX(), uLastBuildTarget.GetLocationY(), uLastBuildTarget.GetLocationZ(), nMask, 4, false);
        }
        else
        {
            uTarget = FindNextObjectToBuild(nMask, 4, false);
        }
        return uTarget;
    }
    return null;
}//����������������������������������������������������������������������������������������������������|

function int MoveToTarget(unit uTarget, int bResetWaitingWithCnt, int bMaxDist2CurrMoveTo)
{
    int bMoveTo;
    int nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz;

    bMoveTo = false;
    if (bResetWaitingWithCnt)
    {
        m_nWaitingBeforeNotWithdrawalCounter = 0;
    }
    if (CanBeBuild(uTarget))
    {
        if (bMaxDist2CurrMoveTo)
        {
            nCurrMoveToGx = m_nMoveToGx;
            nCurrMoveToGy = m_nMoveToGy;
            nCurrMoveToLz = m_nMoveToLz;
            m_nMoveToGx = GetBuildLocationX(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
            m_nMoveToGy = GetBuildLocationY(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
            m_nMoveToLz = GetBuildLocationZ(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
        }
        else
        {
            m_nMoveToGx = GetBuildLocationX(uTarget);
            m_nMoveToGy = GetBuildLocationY(uTarget);
            m_nMoveToLz = GetBuildLocationZ(uTarget);
        }
        bMoveTo = IsGoodPlaceForBuildObject(uTarget, m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        if (bMoveTo)
        {
            SetRepairPos(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        }
    }
    else if (CanBeRepaired(uTarget))
    {
        if (bMaxDist2CurrMoveTo)
        {
            nCurrMoveToGx = m_nMoveToGx;
            nCurrMoveToGy = m_nMoveToGy;
            nCurrMoveToLz = m_nMoveToLz;
            m_nMoveToGx = GetOperateOnTargetLocationX(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
            m_nMoveToGy = GetOperateOnTargetLocationY(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
            m_nMoveToLz = GetOperateOnTargetLocationZ(uTarget, nCurrMoveToGx, nCurrMoveToGy, nCurrMoveToLz);
        }
        else
        {
            m_nMoveToGx = GetOperateOnTargetLocationX(uTarget);
            m_nMoveToGy = GetOperateOnTargetLocationY(uTarget);
            m_nMoveToLz = GetOperateOnTargetLocationZ(uTarget);
        }
        bMoveTo = IsGoodPointForOperateOnTarget(uTarget, m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        if (bMoveTo)
        {
            SetRepairPos(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        }
    }
    if (bMoveTo)
    {
        CallMoveToPointForce(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function int MoveToTarget(unit uTarget)
{
    return MoveToTarget(uTarget, false, false);
}//����������������������������������������������������������������������������������������������������|

function void StopWorking()
{
    CallStopMoving();
    ResetCurrentTarget();
    NextCommand(1);
}//����������������������������������������������������������������������������������������������������|

function int TryFindNewTarget(int bCheckAccessibleMode)
{
    unit uTarget;
    int bCheckAccessibleInNextFind;

    TRACE2("CBuilder::TryFindNewTarget, m_bCheck=", m_bCheckAccessibleInNextFind);
    if (IsInHoldPosMode())
    {
        return false;
    }

    if(RAND(2)==1)
    {
        uTarget = FindTargetToRepair();

        if (uTarget == null)
        {
            bCheckAccessibleInNextFind = m_bCheckAccessibleInNextFind;
            uTarget = FindTargetToBuild(bCheckAccessibleMode | m_bCheckAccessibleInNextFind);
            m_bCheckAccessibleInNextFind = false;
        }

        if (uTarget == null)
            uTarget = FindWallToRepair();
    }
    else
    {

        bCheckAccessibleInNextFind = m_bCheckAccessibleInNextFind;
        uTarget = FindTargetToBuild(bCheckAccessibleMode | m_bCheckAccessibleInNextFind);
        m_bCheckAccessibleInNextFind = false;
        
        if (uTarget == null)
        {
            uTarget = FindTargetToRepair();
        }

        if (uTarget == null)
            uTarget = FindWallToRepair();
    }

    if (uTarget != null)
    {
        TRACE1("CBuilder::TryFindNewTarget 3");
        if (MoveToTarget(uTarget))
        {
            TRACE1("CBuilder::TryFindNewTarget 4");
            SetCurrentTarget(uTarget, true);
            return true;
        }
        else
        {
            if (!bCheckAccessibleInNextFind)
            {
                m_bCheckAccessibleInNextFind = true;
            }
        }
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function int TryFindNextBuildTarget()
{
    unit uTarget;

    if (IsInHoldPosMode() && (m_nBuildObjectType != buildWall) && (m_nBuildObjectType != buildBridge))
    {
        return false;
    }
    uTarget = FindNextTargetToBuild(m_uBuilderTarget, m_nBuildObjectType);
    if ((uTarget != null) && MoveToTarget(uTarget))
    {
        SetCurrentTarget(uTarget, m_bSelfTarget);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function void StoreStayPos()
{
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    m_nStayLz = GetLocationZ();
    m_nStayAlpha = GetDirectionAlpha();
}//����������������������������������������������������������������������������������������������������|

function int CheckContinueMoveToBuilderTarget()
{
    if (!m_bSelfTarget && (m_uBuilderTarget != null) && (DistanceTo(m_uBuilderTarget) >= GetSightRange()))
    {
        m_nMoveToGx = m_uBuilderTarget.GetLocationX();
        m_nMoveToGy = m_uBuilderTarget.GetLocationY();
        m_nMoveToLz = m_uBuilderTarget.GetLocationZ();
        CallMoveToPoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        //StopWorking:
        ResetCurrentTarget();
        NextCommand(1);
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

function int FindStateNothingTarget()
{
    if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, CheckHoldPosAfterMove()))
    {
        ResetCounterAfterMove();
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        m_nStayAlpha = GetDirectionAlpha();
        state MovingToAttackTarget;
        return true;
    }
    if (!IsInCamouflageMode() && TryFindNewTarget(false))
    {
        ResetCounterAfterMove();
        m_nStayGx = GetLocationX();
        m_nStayGy = GetLocationY();
        m_nStayLz = GetLocationZ();
        m_nStayAlpha = GetDirectionAlpha();
        SetStateDelay(0);
        if (m_nBuildObjectType != buildNone)
        {
            state MovingToBuildObject;
        }
        else
        {
            state MovingToRepairedObject;
        }
        return true;
    }
    if (TryFindEquipmentArtefactStep())
    {
        ResetCounterAfterMove();
        SetStateDelay(40);
        state MovingToEquipmentArtefact;
        return true;
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Initialize
{
    //inicjacja StayGx,y na wszelki wypadek aby w przypadku jakiegos bledu nie poszedl do 0, 0 w AfterConverting
    StoreStayPos();
    return Nothing, 5;
}//����������������������������������������������������������������������������������������������������|

state Nothing
{
    int nDelay;

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
        if (m_nAttackersCount > 0)
        {
            nDelay = 5;
        }
        else
        {
            nDelay = 20;
        }
        return Nothing, nDelay;
    }
    else if (state == MovingToAttackTarget)
    {
        return MovingToAttackTarget, 0;
    }
    //else state ustawiony w FindStateNothingTarget
}//����������������������������������������������������������������������������������������������������|

state AfterAttack
{
    if (!m_bSelfAttackTarget)
    {
        return Nothing, 0;
    }
    if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, false, true, false, false))
    {
        return MovingToAttackTarget, 0;
    }
    else
    {
        if (m_nStayAlpha == -1)
        {
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
        }
        else
        {
            CallMoveToPointAlpha(m_nStayGx, m_nStayGy, m_nStayLz, m_nStayAlpha);
        }
        return MovingToStayAfterAttack;
    }
}//����������������������������������������������������������������������������������������������������|

state AfterKilledTarget
{
    return StartMovingAndDefend, 5;
}//����������������������������������������������������������������������������������������������������|

state AfterWorking
{
    if (!m_bSelfTarget && !m_bSelfAttackTarget)
    {
        return Nothing, 0;
    }
    if (!IsInCamouflageMode() && TryFindNewTarget(false))
    {
        m_bSelfAttackTarget = false;
        if (m_nBuildObjectType != buildNone)
        {
            return MovingToBuildObject;
        }
        else
        {
            return MovingToRepairedObject;
        }
    }
    else
    {
        if (m_nStayAlpha == -1)
        {
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
        }
        else
        {
            CallMoveToPointAlpha(m_nStayGx, m_nStayGy, m_nStayLz, m_nStayAlpha);
        }
        return MovingToStayAfterWorking;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToStayAfterAttack
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, false, true, false, true))
        {
            m_bSelfTarget = false;
            return MovingToAttackTarget, 0;
        }
        //nie robimy TryFindNewTarget bo to moze byc wywolane z MovingAndDefend
        return MovingToStayAfterAttack;
    }
    else
    {
        NextCommand(1);//potrzebne jesli AutoAttack byl wywolany z MovingAndDefend
        m_bSelfAttackTarget = false;
        m_bSelfTarget = false;
        return Nothing, 0;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToStayAfterWorking
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, false))
        {
            m_bSelfTarget = false;
            return MovingToAttackTarget, 0;
        }
        if (!IsInCamouflageMode() && TryFindNewTarget(false))
        {
            m_bSelfAttackTarget = false;
            if (m_nBuildObjectType != buildNone)
            {
                return MovingToBuildObject;
            }
            else
            {
                return MovingToRepairedObject;
            }
        }
        return MovingToStayAfterWorking;
    }
    else
    {
        NextCommand(1);//potrzebne jesli AutoAttack byl wywolany z MovingAndDefend
        m_bSelfAttackTarget = false;
        m_bSelfTarget = false;
        return Nothing, 0;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToBuildObject
{
    int bCanBeBuild;

    bCanBeBuild = CanBeBuild(m_uBuilderTarget);
    if (IsWaitingBeforeClosedGate())
    {
        bCanBeBuild = false;
    }
    else if (IsMoving() && bCanBeBuild)
    {
        if (((GetLocationX() != m_nMoveToGx) || (GetLocationY() != m_nMoveToGy) || (GetLocationZ() != m_nMoveToLz)) && 
            !IsFreePoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz))
        {
            TRACE("Builder->MovingToBuildObject 1\n");
            MoveToTarget(m_uBuilderTarget, true, false);
        }
        else if (IsWaitingBeforeNotWithdrawalUnit())
        {
            //moze sie zdazyc sytuacja ze droge do naszego punktu zaslania nam inny builder ktory juz buduje
            //w takiej sytuacji najpierw sprawdzamy czy juz stoimy w miejscu w ktorym mozna budowac,
            //jesli nie to szukamy miejsca jeszcze raz, a jesli i to nie pomaga to szukamy takiego ktore lezy 
            //najdalej od dotychczasowego (moze wtedy pojdzie inna droga)
            if (IsInGoodPlaceForBuildObject(m_uBuilderTarget))
            {
                SetRepairPos(GetLocationX(), GetLocationY(), GetLocationZ());
                CallStopMoving();
            }
            else
            {
                if (m_nWaitingBeforeNotWithdrawalCounter == 0)
                {
                    MoveToTarget(m_uBuilderTarget, true, false);
                    ++m_nWaitingBeforeNotWithdrawalCounter;
                }
                else
                {
                    if (m_nWaitingBeforeNotWithdrawalCounter > 4)
                    {
                        MoveToTarget(m_uBuilderTarget, true, true);
                        ++m_nWaitingBeforeNotWithdrawalCounter;
                    }
                    else
                    {
                        ++m_nWaitingBeforeNotWithdrawalCounter;
                    }
                }
            }
        }
        return MovingToBuildObject, 5;
    }
    else
    {
        if (IsInGoodPlaceForBuildObject(m_uBuilderTarget) && bCanBeBuild)
        {
            TRACE("Builder->MovingToBuildObject 2\n");
            CallBuildObject(m_uBuilderTarget);
            return BuildObject;
        }
        else if ((m_nBuildObjectType != buildWall) && bCanBeBuild && MoveToTarget(m_uBuilderTarget, true, false))
        {
            TRACE("Builder->MovingToBuildObject 3\n");
            ++m_nMoveTryCounter;
            if ((m_nMoveTryCounter > 15)
                ON_USER_SCRIPT(&& m_bSelfTarget)
                )
            {
                TRACE("Builder->MovingToBuildObject 4\n");
                if (ON_USER_SCRIPT(m_bSelfTarget &&)
                    !IsInCamouflageMode() && TryFindNewTarget(true))
                {
                    TRACE("Builder->MovingToBuildObject 5\n");
                    m_bSelfAttackTarget = false;
                    if (m_nBuildObjectType != buildNone)
                    {
                        return MovingToBuildObject;
                    }
                    else
                    {
                        return MovingToRepairedObject;
                    }
                }
                else
                {
                    TRACE("Builder->MovingToBuildObject 6\n");
                    //jesli jestesmy daleko od celu to do niego dalej idziemy
                    if (CheckContinueMoveToBuilderTarget())
                    {
                        TRACE("Builder->MovingToBuildObject 7\n");
                        return AfterKilledTarget, 0;
                    }
                    StopWorking();
                    return AfterWorking, 0;
                }
            }
            return MovingToBuildObject;
        }
        else
        {
            TRACE("Builder->MovingToBuildObject 8\n");
            if (TryFindNextBuildTarget())
            {
                return MovingToBuildObject;
            }
            else
            {
                //jesli jestesmy daleko od celu to do niego dalej idziemy
                if (CheckContinueMoveToBuilderTarget())
                {
                    TRACE("Builder->MovingToBuildObject 9\n");
                    return AfterKilledTarget, 0;
                }
                StopWorking();
                return AfterWorking, 0;
            }
        }
    }
}//����������������������������������������������������������������������������������������������������|

state BuildObject
{
    if (IsBuildWorking())
    {
        return BuildObject, 5;
    }
    else
    {
        if (CanBeBuild(m_uBuilderTarget) && IsInGoodPlaceForBuildObject(m_uBuilderTarget))
        {
            TRACE("BuildObject->BuildObject\n");
            CallBuildObject(m_uBuilderTarget);
            return BuildObject;
        }
        else if (TryFindNextBuildTarget())
        {
            return MovingToBuildObject;
        }
        else
        {
            StopWorking();
            return AfterWorking, 0;
        }
    }
}//����������������������������������������������������������������������������������������������������|

state MovingToRepairedObject
{
    int bCanBeRepaired;

    bCanBeRepaired = CanBeRepaired(m_uBuilderTarget);

    if (IsWaitingBeforeClosedGate() && (GetWaitingBeforeClosedGate() != m_uBuilderTarget))
    {
        bCanBeRepaired = false;
    }
    if (IsMoving() && bCanBeRepaired)
    {
        TRACE("Builder->MovingToRepairedObject 1\n");
        if (((GetLocationX() != m_nMoveToGx) || (GetLocationY() != m_nMoveToGy) || (GetLocationZ() != m_nMoveToLz)) && 
            !IsFreePoint(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz))
        {
            MoveToTarget(m_uBuilderTarget, true, false);
        }
        else if (IsWaitingBeforeNotWithdrawalUnit())
        {
            //moze sie zdazyc sytuacja ze droge do naszego punktu zaslania nam inny builder ktory juz buduje
            //w takiej sytuacji najpierw sprawdzamy czy juz stoimy w miejscu w ktorym mozna budowac,
            //jesli nie to szukamy miejsca jeszcze raz, a jesli i to nie pomaga to szukamy takiego ktore lezy 
            //najdalej od dotychczasowego (moze wtedy pojdzie inna droga)
            if (IsInGoodPointForOperateOnTarget(m_uBuilderTarget))
            {
                SetRepairPos(GetLocationX(), GetLocationY(), GetLocationZ());
                CallStopMoving();
            }
            else
            {
                if (m_nWaitingBeforeNotWithdrawalCounter == 0)
                {
                    MoveToTarget(m_uBuilderTarget, true, false);
                    ++m_nWaitingBeforeNotWithdrawalCounter;
                }
                else
                {
                    if (m_nWaitingBeforeNotWithdrawalCounter > 4)
                    {
                        MoveToTarget(m_uBuilderTarget, true, true);
                    }
                    else
                    {
                        ++m_nWaitingBeforeNotWithdrawalCounter;
                    }
                }
            }
        }
        return MovingToRepairedObject, 5;
    }
    else
    {
        TRACE("Builder->MovingToRepairedObject 2\n");
        if (IsInGoodPointForOperateOnTarget(m_uBuilderTarget) && bCanBeRepaired)
        {
            CallRepair(m_uBuilderTarget);
            return Repairing;
        }
        else if (bCanBeRepaired && MoveToTarget(m_uBuilderTarget, true, false))
        {
            ++m_nMoveTryCounter;
            if ((m_nMoveTryCounter > 15) ON_USER_SCRIPT(&& m_bSelfTarget))
            {
                if (ON_USER_SCRIPT(m_bSelfTarget &&)
                    !IsInCamouflageMode() && TryFindNewTarget(true))
                {
                    m_bSelfAttackTarget = false;
                    if (m_nBuildObjectType != buildNone)
                    {
                        return MovingToBuildObject;
                    }
                    else
                    {
                        return MovingToRepairedObject;
                    }
                }
                else
                {
                    //jesli jestesmy daleko od celu to do niego dalej idziemy
                    if (CheckContinueMoveToBuilderTarget())
                    {
                        TRACE("Builder->MovingToRepairedObject 3\n");
                        return AfterKilledTarget, 0;
                    }
                    StopWorking();
                    return AfterWorking, 0;
                }
            }
            return MovingToRepairedObject;
        }
        else
        {
            TRACE("XXX 2\n");
            //jesli jestesmy daleko od celu to do niego dalej idziemy
            if (CheckContinueMoveToBuilderTarget())
            {
                TRACE("Builder->MovingToRepairedObject 4\n");
                return AfterKilledTarget, 0;
            }
            StopWorking();
            return AfterWorking, 0;
        }
    }
}//����������������������������������������������������������������������������������������������������|

state Repairing
{
    if (IsRepairing())
    {
        return Repairing, 5;
    }
    else
    {
        if (CanBeRepaired(m_uBuilderTarget) && IsInGoodPointForOperateOnTarget(m_uBuilderTarget))
        {
            TRACE("Repairing->Repairing\n");
            CallRepair(m_uBuilderTarget);
            return Repairing;
        }
        else if (IsFlyable())
        {
            //podniesc sie
            CallMoveToPoint(GetLocationX(), GetLocationY(), GetLocationZ());
        }
        StopWorking();
        return AfterWorking, 0;
    }
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    int nDistX, nDistY, nDist, nRange, nPosX, nPosY;
    int bResponseToAttack, bDamageable;
    unit uGate;
    int nCurrState;
    unit uTarget, uNewTarget;
    int bByBlindAttack;

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
    if ((uByUnit != null) && IsVisible(uByUnit) && !IsAlliance(uByUnit) && (GetHPDamageOnObject(uByUnit) > 0) &&
        ((state == Repairing) || (state == BuildObject) || (state == MovingToRepairedObject) || (state == MovingToBuildObject)) &&
        (m_bSelfTarget || (!IsInHoldPosMode() && (TALKMODE == 0))))
    {
        if (MoveToAttackTarget(uByUnit, true))
        {
            if ((GetWeaponType() == cannonTypeSword) && (uByUnit.GetWeaponType() == cannonTypeSword) &&
                (uByUnit.SetEventOnGetTarget() == GetUnitRef()))
            {
                bResponseToAttack = true;
            }
            if (!m_bSelfTarget)
            {
                NextCommand(1);
            }
            m_bSelfTarget = false;
            SetAttackTarget(uByUnit, false, true, bResponseToAttack, true, false);
            SetStateDelay(0);
            state MovingToAttackTarget;
        }
    }
    /*
    else if ((uByUnit != m_uAttackTarget) && (state == AttackingTarget) &&
        (GetWeaponType() == cannonTypeSword) && (uByUnit.GetWeaponType() == cannonTypeSword) && m_bSelfAttackTarget)
    {
        if (m_uAttackTarget.SetEventOnGetTarget() != GetUnitRef())
        {
            TRACE2(GetUnitRef(), "OnHit->CallForceEventOnEndAttackTarget");
            CallForceEventOnEndAttackTarget();
        }
    }
    */
    else if ((state == MovingToAttackTarget) || (state == WaitingForAttackedTarget))
    {
        uGate = GetWaitingBeforeClosedGate();
        if (uGate != null)
        {
            if ((IsEnemy(uGate) || IsLastEnemyTowerOrGate(uGate)) && GetHPDamageOnObject(uGate) && (uGate != m_uAttackTarget))
            {
                if (MoveToAttackTarget(uGate, m_bSelfAttackTarget))
                {
                    nCurrState = state;
                    if (m_bAttackingCommandTarget)
                    {
                        //musimy wywolac NextCommand bo inaczej dla tego obiektu pokazywalo by dwa cele
                        //jeden z komendy i drugi z SetTargetObject
                        NextCommand(1);
                    }
                    if (state == nCurrState)
                    {
                        SetAttackTarget(uGate, false, m_bSelfAttackTarget, false, false, true);
                        SetStateDelay(0);
                        state MovingToAttackTarget;
                        return true;
                    }
                    //else state zmieniony w NextCommand
                }
            }
        }
        //jesli czekamy na cel i obrywamy to zaczynamy isc (zeby ew. mogl zmienic cel)
        if (m_bSelfAttackTarget && !IsMoving() && (state == WaitingForAttackedTarget))
        {
            SetStateDelay(0);
            state MovingToAttackTarget;
        }
        uTarget = uByUnit;
        if (uTarget.IsInTower())
        {
            uNewTarget = uTarget.GetTowerWithUnit();
            if (uNewTarget != null)
            {
                uTarget = uNewTarget;
            }
        }
        if (IsAlliance(uTarget) && uTarget.IsInBlindAttack())
        {
            bByBlindAttack = true;
        }
    }
    if ((state == Nothing) || bByBlindAttack)
    {
        //nie strzelamy bo nie ma celu ktory jest blisko, ale skoro on nas bije to my ruszamy do walki
        if (!IsInCamouflageMode() && !IsInTower())
        {
            if (TryFindNewAttackTarget(false, CheckHoldPosAfterMove(), false, true, false))
            {
                ResetCounterAfterMove();
                StoreStayPos();
                SetStateDelay(0);
                state MovingToAttackTarget;
            }
            else
            {
                //nie znalazl celu wiec atakujemy tego ktory nas atakuje
                uTarget = uByUnit;
                if (uTarget.IsInTower())
                {
                    uNewTarget = uTarget.GetTowerWithUnit();
                    if (uNewTarget != null)
                    {
                        uTarget = uNewTarget;
                    }
                }
                if (IsAlliance(uTarget) && !uTarget.IsInBlindAttack())
                {
                    return true;
                }
                if (GetHPDamageOnObject(uTarget) > 0)
                {
                    bDamageable = true;
                }
                else
                {
                    bDamageable = false;
                }
                if (bDamageable && !CheckHoldPosAfterMove() && MoveToAttackTarget(uTarget, true))
                {
                    TRACE2(GetUnitRef(), "OnHit->Attack uByUnit");
                    if ((GetWeaponType() == cannonTypeSword) && (uTarget.GetWeaponType() == cannonTypeSword) &&
                        (uTarget.SetEventOnGetTarget() == GetUnitRef()))
                    {
                        TRACE2(GetUnitRef(), "    ->bResponseToAttack == true");
                        bResponseToAttack = true;
                    }
                    SetAttackTarget(uTarget, false, true, bResponseToAttack, true, false);
#ifdef AI_SCRIPT
                    if (IsRPGMode())
                    {
                        m_nAllowInvisibleCounter = 20;
                    }
#endif
                    ResetCounterAfterMove();
                    StoreStayPos();
                    SetStateDelay(0);
                    state MovingToAttackTarget;
                }
                else if (!bDamageable && !IsInHoldPosMode() && (TALKMODE == 0))
                {
                    //uciekamy w przeciwnym kierunku
                    TRACE2(GetUnitRef(), "OnHit->Escape");
                    nRange = 5;
                    nPosX = GetLocationX();
                    nPosY = GetLocationY();
                    if (uTarget != null)
                    {
                        nDistX = nPosX - uTarget.GetLocationX();
                        nDistY = nPosY - uTarget.GetLocationY();
                        nDist = DistanceTo(uTarget);
                    }
                    else
                    {
                        nDistX = 0;
                        nDistY = -1;
                        nDist = 1;
                    }
                    if (nDist > 0)
                    {
                        nDistX = nRange*nDistX/nDist;
                        nDistY = nRange*nDistY/nDist;
                    }
                    MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
                    state StartMoving;
                }
            }
        }
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

event OnKilled()
{
    ResetCurrentTarget();
    ResetAttackTarget();
    return true;
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command Initialize()
{
    InitializeHoldPos();
    InitializeAttack();
    InitializeArtefactsCounter();
    //inicjacja StayGx,y na wszelki wypadek aby w przypadku jakiegos bledu nie poszedl do 0, 0 w AfterConverting
    StoreStayPos();
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    ResetEnterBuilding();
    ResetCurrentTarget();
    ResetAttackTarget();
    ResetCustomAnim();
    return true;
}//����������������������������������������������������������������������������������������������������|

//bez nazwy - wywolywane po wybraniu miejsca
command BuildObject(unit uObjectToBuild) hidden button TRL_BUILDOBJECT
{
    EXIT_COMMAND_IN_SLEEP_MODE();
    if (CanBeBuild(uObjectToBuild) && MoveToTarget(uObjectToBuild))
    {
        CHECK_STOP_CURR_ACTION();
        SetCurrentTarget(uObjectToBuild, false);
        state MovingToBuildObject;
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
    if (CanBeRepaired(uTarget) && MoveToTarget(uTarget))
    {
        CHECK_STOP_CURR_ACTION();
        SetCurrentTarget(uTarget, false);
        state MovingToRepairedObject;
    }
    else
    {
        NextCommand(0);
    }
    return true;
}//����������������������������������������������������������������������������������������������������|
}
