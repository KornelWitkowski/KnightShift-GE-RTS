#define ANIMAL_EC

#include "Translates.ech"
#include "Items.ech"

animal TRL_SCRIPT_ANIMAL
{

////    Declarations    ////

state Nothing;
state Nothing2;
state StartMovingWithCheck;
state MovingWithCheck;
state AfterMoveAndDefend;

int  m_nStayGx;
int  m_nStayGy;
int  m_nStayLz;
int  m_nStayAlpha;

#define STOPCURRENTACTION
function int StopCurrentAction();

#define STORE_STAY_POS
function void StoreStayPos();

#define USE_MOVEANDDEFEND

#include "Common.ech"
#include "Trace.ech"
#include "Sleep.ech"
#include "HoldPos.ech"
#include "Move.ech"
#include "Recycle.ech"
#include "CustomAnim.ech"
#include "Attack.ech"
//po Move.ech aby dzialalo tylko w MoveAndDefend
#define STATE_AFTER_MOVE AfterMoveAndDefend
#include "MoveEx.ech"
#include "Events.ech"


////    Functions    ////

function int StopCurrentAction()
{
    if (IsAttacking())
    {
        CallStopAttack();
    }
    ResetCounterAfterMove();
    ResetAttackTarget();
    ResetEnterBuilding();
    m_bSelfAttackTarget = false;
    return true;
}//����������������������������������������������������������������������������������������������������|

function void StoreStayPos()
{
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    m_nStayLz = GetLocationZ();
    m_nStayAlpha = GetDirectionAlpha();
}//����������������������������������������������������������������������������������������������������|

function void RandomMove()
{
    int nMoveToX, nMoveToY;

    //losowy ruch w jakims kierunku
    nMoveToX = CLAMP(GetLocationX() - 15 + RAND(30), GetWorldLeft(), GetWorldRight());
    nMoveToY = CLAMP(GetLocationY() - 15 + RAND(30), GetWorldTop(), GetWorldBottom());
    MoveToPoint(nMoveToX, nMoveToY, GetLocationZ());
}//����������������������������������������������������������������������������������������������������|

function void RandomMoveFromStay()
{
    int nMoveToX, nMoveToY;

    //losowy ruch w promieniu 4
    nMoveToX = CLAMP(m_nStayGx - 3 + RAND(7), GetWorldLeft(), GetWorldRight());
    nMoveToY = CLAMP(m_nStayGy - 3 + RAND(7), GetWorldTop(), GetWorldBottom());
    MoveToPoint(nMoveToX, nMoveToY, m_nStayLz);
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Nothing
{
    int nDelay, nDist, nDistX, nDistY, nPosX, nPosY;
    unit uEnemy;

    if ((TALKMODE == 1) || IsInBuilding())
    {
        return Nothing;
    }
    if (!IsInHoldPosMode())
    {
        if (GetIFFNumber() == wildAnimalsIFFNum)
        {
            if (!RAND(20))
            {
                ResetCounterAfterMove();
                //losowy ruch w jakims kierunku
                RandomMove();
                return StartMovingAndDefend,5;
            }
            if (!m_nTargetTypes)
            {
                //zwierze "nieuzbrojone", 
                //od czasu do czasu uciekamy przed ludzmi i zwierzetami uzbrojonymi 
                if (!RAND(10))
                {
                    uEnemy = FindTarget(findTargetUnit | findTargetArmedAnimal, findEnemyUnit | findAllyUnit | findNeutralUnit | findOurUnit, findNearestUnit);
                    if (uEnemy != null)
                    {
                        ResetCounterAfterMove();
                        nDist = DistanceTo(uEnemy);
                        nPosX = GetLocationX();
                        nPosY = GetLocationY();
                        nDistX = nPosX - uEnemy.GetLocationX();
                        nDistY = nPosY - uEnemy.GetLocationY();
                        if (nDist > 0)
                        {
                            nDistX = 10*nDistX/nDist;
                            nDistY = 10*nDistY/nDist;
                        }
                        MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
                        return StartMovingWithCheck,5;
                    }
                }
            }
            else
            {
                //zwierze "uzbrojone"
                //od czasu do czasu atakujemy nieuzbrojone zwierzeta ("dzikie" - tego samego playera, innego playera sa atakowane automatycznie)
                if (!RAND(40))
                {
                    uEnemy = FindTarget(findTargetUnarmedAnimal, findOurUnit, findNearestUnit);
                    if ((uEnemy != null) && MoveToAttackTarget(uEnemy, true))
                    {
                        ResetCounterAfterMove();
                        SetAttackTarget(uEnemy, false, true, false, true, false);
                        return MovingToAttackTarget, 0;
                    }
                }
            }
        }
#ifdef AI_SCRIPT
        else
        {
            //od czasu do czasu chodzimy losowo w promieniu 3 kratek od stayGx,y
            if (!RAND(15))
            {
                StoreStayPos();
                RandomMoveFromStay();
                return Nothing2, 20;
            }
        }
#endif
    }
    if (TryFindNewAttackTarget(false, CheckHoldPosAfterMove()))
    {
        ResetCounterAfterMove();
        return MovingToAttackTarget, 0;
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
}//����������������������������������������������������������������������������������������������������|

//state Nothing2 zeby bylo wiadomo jaki jest punkt poczatkowy (stayGx,y,z) wokol ktorego chodzimy
//po wykonaniu ataku itp. wraca do state Nothing i zapamietujemy nowy punkt poczatkowy
state Nothing2
{
    int nDelay, nDist, nDistX, nDistY, nPosX, nPosY;
    unit uEnemy;

    if ((TALKMODE == 1) || IsInBuilding())
    {
        return Nothing2;
    }
    if (!IsMoving() && !IsInHoldPosMode())
    {
        //od czasu do czasu chodzimy losowo w promieniu 3 kratek od stayGx,y
        if (!RAND(15))
        {
            RandomMoveFromStay();
        }
    }
    if (TryFindNewAttackTarget(false, CheckHoldPosAfterMove()))
    {
        ResetCounterAfterMove();
        return MovingToAttackTarget, 0;
    }
    if (m_nAttackersCount > 0)
    {
        nDelay = 5;
    }
    else
    {
        nDelay = 20;
    }
    return Nothing2, nDelay;
}//����������������������������������������������������������������������������������������������������|

state AfterMoveAndDefend
{
    if (IsWaitingBeforeClosedGate())
    {
        RandomMove();
        return StartMovingAndDefend,5;
    }
    return Nothing;
}//����������������������������������������������������������������������������������������������������|

state StartMovingWithCheck
{
    if (IsMoving() || !CheckKeepStartMoving())
    {
        return MovingWithCheck,0;
    }
    else
    {
        return StartMovingWithCheck,5;
    }
}//����������������������������������������������������������������������������������������������������|

state MovingWithCheck
{
    int bWaiting;
    bWaiting = IsWaitingBeforeClosedGate();
    if (IsMoving() && !bWaiting)
    {
        TRACE("MovingWithCheck\n");
#ifdef ONMOVINGCALLBACK
        if (OnMovingCallback())
        {
            //state zmieniony w OnMovingCallback, wywolujemy tylko NextCommand
            NextCommand(1);//wykonana komenda moveTo
        }
        else
        {
            return MovingWithCheck;
        }
#else
        return MovingWithCheck;
#endif ONMOVINGCALLBACK
    }
    else
    {
        TRACE("MovingWithCheck -> Nothing\n");
        if (bWaiting)
        {
            RandomMove();
            return StartMovingWithCheck,5;
        }
        NextCommand(1);
        return Nothing, 0;
    }
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    int nDistX, nDistY, nDist, nRange, nPosX, nPosY;
    int nHP;
    int bResponseToAttack, bDamageable;
    unit uTarget, uNewTarget;
    int bByBlindAttack;
    int nHPPercent;

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
    nHP = GetHP()*100/GetMaxHP();
    if (IsRPGMode())
    {
        nHPPercent = RAND(100);
    }
    else
    {
        nHPPercent = 30;
    }
    if (!IsMoving() && ((nHP < nHPPercent) || !m_nTargetTypes) && !IsInHoldPosMode() && (TALKMODE == 0))
    {
        //uciekamy
        if (nHP < 20)
        {
            nRange = 15;
        }
        else
        {
            nRange = 6;
        }
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
        ResetAttackTarget();
        MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
        state StartMovingWithCheck;
        return true;
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
    if ((state == Nothing) || (state == StartMovingAndDefend) || (state == MovingAndDefend) || (state == AfterMoveAndDefend) ||
        bByBlindAttack)
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
                    nDistX = nPosX - uTarget.GetLocationX();
                    nDistY = nPosY - uTarget.GetLocationY();
                    nDist = DistanceTo(uTarget);
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
    ResetAttackTarget();
    return true;
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command Initialize()
{
    InitializeHoldPos();
    InitializeAttack();
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    ResetEnterBuilding();
    ResetAttackTarget();
    ResetCustomAnim();
    return true;
}//����������������������������������������������������������������������������������������������������|
}
