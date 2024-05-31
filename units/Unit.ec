#define UNIT_EC

#include "Translates.ech"
#include "Items.ech"

tank TRL_SCRIPT_UNIT
{

////    Declarations    ////

state Initialize;
state Nothing;
state AfterAttack;
state AfterKilledTarget;
state MovingToStay;

int  m_nStayGx;
int  m_nStayGy;
int  m_nStayLz;
int  m_nStayAlpha;
int  m_nCheckMagicCounter;

#define STOPCURRENTACTION
function int StopCurrentAction();

//#define ONMOVINGCALLBACK 
function int OnMovingCallback();

#define ONCOMMANDMOVECALLBACK
function int OnCommandMoveCallback(int nGx, int nGy, int nLz);

#define ONCOMMANDENTERCALLBACK
function int OnCommandEnterCallback(unit uEntrance, int bReplaceWithCurrUnit);

#define STATE_AFTER_ATTACK AfterAttack

#define STATE_AFTER_KILLED_TARGET AfterKilledTarget

#define STATE_MOVING_AFTER_EQUIPMENT_ARTEFACT MovingToStay

#define STORE_STAY_POS
function void StoreStayPos();

function int FindStateNothingTarget();

#define USE_MOVEANDDEFEND

#include "Common.ech"
#include "Trace.ech"
#include "Sleep.ech"
#include "Camouflage.ech"
#include "HoldPos.ech"
#include "Move.ech"
#include "Recycle.ech"
#include "Equipment.ech"
#include "CustomAnim.ech"
#ifdef RPG_UNIT_EC
#include "RPG.ech"
#endif RPG_UNIT_EC
#include "Magic.ech"
#include "Attack.ech"
#include "MoveEx.ech"
#include "Events.ech"
#include "EquipmentArtefact.ech"
#include "HealingPlace.ech"

////    Functions    ////

function int StopCurrentAction()
{
    if (IsAttacking())
    {
        CallStopAttack();
    }
    ResetCounterAfterMove();
    //nie ma sensu stopowanie magii bo i tak sie wykona
    ResetAttackTarget();
    ResetMagicTarget();
    ResetEnterBuilding();
#ifdef RPG_UNIT_EC
    ResetRPG();
#endif RPG_UNIT_EC
    m_bSelfAttackTarget = false;
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
            TRACE5("OnMovingCallback -> stay == (", m_nStayGx, ", ", m_nStayGy, ")");
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

function int OnCommandMoveCallback(int nGx, int nGy, int nLz)
{
    return OnCommandMoveMagicCallback(nGx, nGy, nLz);
}//����������������������������������������������������������������������������������������������������|

function int OnCommandEnterCallback(unit uEntrance, int bReplaceWithCurrUnit)
{
    return OnCommandEnterMagicCallback(uEntrance, bReplaceWithCurrUnit);
}//����������������������������������������������������������������������������������������������������|

function void StoreStayPos()
{
    m_nStayGx = GetLocationX();
    m_nStayGy = GetLocationY();
    m_nStayLz = GetLocationZ();
    m_nStayAlpha = GetDirectionAlpha();
}//����������������������������������������������������������������������������������������������������|

function int FindStateNothingTarget()
{
    int nGx, nGy, nLz;
    int nFindHealthPlaceRet;

    if (m_nCheckMagicCounter > 0)
    {
        --m_nCheckMagicCounter;
        if (m_nCheckMagicCounter == 0)
        {
            m_nCheckMagicCounter = 3;
            if (!IsInCamouflageMode() && (TryMakeCapturingMagic(false) || TryMakeConversionMagic(false) || TryMakeWolfMagic(false) || TryMakeStormMagic(false) || TryMakeFireRainMagic(false) || TryMakeRemoveStormFireRainMagic(false) || TryMakeFreezeMagic(false)))
            {
                ResetCounterAfterMove();
                TRACE1("Nothing->MovingToMagicTarget");
                SetStateDelay(0);
                state MovingToMagicTarget;
                return true;
            }
        }
    }
    if (TryFindEquipmentArtefactStep())
    {
        ResetCounterAfterMove();
        SetStateDelay(40);
        state MovingToEquipmentArtefact;
        return true;
    }
    //nie szukamy celu w trybie Camouflage bo nie mozemy zaatakowac
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
    return false;
}//����������������������������������������������������������������������������������������������������|

////    States    ////

state Initialize
{
    //inicjacja StayGx,y na wszelki wypadek
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
        TRACE1("AfterAttack -> found new target");
        return MovingToAttackTarget, 0;
    }
    else
    {
        TRACE5("AfterAttack -> stay == (", m_nStayGx, ", ", m_nStayGy, ")");
        if (m_nStayAlpha == -1)
        {
            CallMoveToPoint(m_nStayGx, m_nStayGy, m_nStayLz);
        }
        else
        {
            CallMoveToPointAlpha(m_nStayGx, m_nStayGy, m_nStayLz, m_nStayAlpha);
        }
        return MovingToStay;
    }
}//����������������������������������������������������������������������������������������������������|

state AfterKilledTarget
{
    return StartMovingAndDefend, 5;
}//����������������������������������������������������������������������������������������������������|


state MovingToStay
{
    if (IsMoving() && !IsWaitingBeforeClosedGate())
    {
        if (!IsInCamouflageMode() && TryFindNewAttackTarget(false, false, true, false, true))
        {
            return MovingToAttackTarget, 0;
        }
        return MovingToStay;
    }
    else
    {
        m_bSelfAttackTarget = false;
        NextCommand(1);//potrzebne jesli AutoAttack byl wywolany z MovingAndDefend
        return Nothing, 0;
    }
}//����������������������������������������������������������������������������������������������������|

////    Events    ////

event OnHit(unit uByUnit)
{
    int nHP, nMaxHP;
    int nDistX, nDistY, nDist, nRange, nPosX, nPosY;
    int nWeaponType, nByUnitWeaponType;
    unit uGate;
    int nCurrState;
    int bResponseToAttack, bDamageable;
    unit uTarget, uNewTarget;
    int bByBlindAttack;
    
    if (ExitSleepModeOnHit())
    {
        return true;
    }

    if (IsMakingMagic())
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
    if (IsInCamouflageMode() && (uByUnit != null))
    {
        if (!IsInHoldPosMode() && (TALKMODE == 0))
        {
            //uciekamy
            nRange = 5;
            nPosX = GetLocationX();
            nPosY = GetLocationY();
            nDistX = nPosX - uByUnit.GetLocationX();
            nDistY = nPosY - uByUnit.GetLocationY();
            nDist = DistanceTo(uByUnit);
            if (nDist > 0)
            {
                nDistX = nRange*nDistX/nDist;
                nDistY = nRange*nDistY/nDist;
            }
            MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
            state StartMoving;
        }
        return true;
    }
    if ((TALKMODE == 0) && TryMakeImmortalShieldMagic(false))
    {
        ResetAttackTarget();
        state MovingToMagicTarget;
        return true;
    }

    // Ucieczka dla kapłanów AI
#ifdef AI_SCRIPT
    if ((uByUnit != null))
    {
        nByUnitWeaponType = uByUnit.GetWeaponType();

        if (nByUnitWeaponType == cannonTypeSword)
        {
                nRange = 6;
                    
                nPosX = GetLocationX();
                nPosY = GetLocationY();

                nDistX = nPosX - uByUnit.GetLocationX();
                nDistY = nPosY - uByUnit.GetLocationY();
                nDist = DistanceTo(uByUnit);

                if (nDist > 0)
                {
                    nDistX = (nRange*nDistX)/nDist;
                    nDistY = (nRange*nDistY)/nDist;
                }

                if(CanMakeMagic(magicTeleportation, nPosX + nDistX, nPosY + nDistY, GetLocationZ()))
                {
                   CallMakeMagic(magicTeleportation, 
                                 nPosX + nDistX-1+RAND(3), nPosY + nDistY-1+RAND(3), GetLocationZ());
                   return true;
                }   
        }
    }
#endif AI_SCRIPT
    

    //jesli jestesmy w trakcie walki i ten ktorego bijemy nas nie bije to stopujemy walke
    //i w event OnEndAttackTarget powinnismy wybrac do bicia unita uByUnit
    if ((state == AttackingTarget) && (uByUnit != null))
    {
        nWeaponType = GetWeaponType();
        nByUnitWeaponType = uByUnit.GetWeaponType();
        /*
        if ((uByUnit != m_uAttackTarget) &&
            (nWeaponType == cannonTypeSword) && (nByUnitWeaponType == cannonTypeSword) && m_bSelfAttackTarget)
        {
            if (m_uAttackTarget.SetEventOnGetTarget() != GetUnitRef())
            {
                TRACE2(GetUnitRef(), "OnHit->CallForceEventOnEndAttackTarget");
                CallForceEventOnEndAttackTarget();
            }
        }
        */
        //Wlocznik nie ucieka; uciekaja tylko unity AI
    // Jednostki z piorunami te� nie uciekaj�. (nWeaponType != 6)
#ifdef AI_SCRIPT
        /*else */if ((nWeaponType != cannonTypeSword) && (nWeaponType != 6) && !HaveShooterSwordHit() && (nByUnitWeaponType == cannonTypeSword) && !IsInHoldPosMode())
        {

            if ((GetArmour(0) < 100) && (GetHP() < GetMaxHP()/2))
            {
                //uciekamy
                nRange = 5;
                    
                nPosX = GetLocationX();
                nPosY = GetLocationY();
                if (uByUnit != null)
                {
                    nDistX = nPosX - uByUnit.GetLocationX();
                    nDistY = nPosY - uByUnit.GetLocationY();
                    nDist = DistanceTo(uByUnit);
                }
                else
                {
                    nDistX = 0;
                    nDistY = -1;
                    nDist = 1;
                }
                if (nDist > 0)
                {
                    nDistX = (nRange*nDistX)/nDist;
                    nDistY = (nRange*nDistY)/nDist;
                }
                    
                MoveToPoint(nPosX + nDistX, nPosY + nDistY, GetLocationZ());
                state StartMoving;
            }
        }
#endif AI_SCRIPT
    }
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

//event OnHit gdy jestesmy na wiezy
event OnHitInTower(unit uByUnit)
{
    if (TryMakeImmortalShieldMagic(true))
    {
        return true;
    }
    return true;
}//����������������������������������������������������������������������������������������������������|

//wywolywane dla unita na wiezy
//uCurrTarget - obiekt ktory aktualnie atakujemy (lub null)
//bCurrSelfTarget - czy uCurrTarget to znaleziony przez nas cel (TRUE), lub podany z komendy (FALSE)
event OnFindTowerUnitTarget(int bCurrSelfTarget, unit uCurrTarget)
{
    if (uCurrTarget == null)
    {
        if (m_nCheckMagicCounter > 0)
        {
            --m_nCheckMagicCounter;
            if (m_nCheckMagicCounter == 0)
            {
                m_nCheckMagicCounter = 3;
                if (TryMakeCapturingMagic(true) || TryMakeConversionMagic(true) || TryMakeWolfMagic(true) || TryMakeStormMagic(true) || TryMakeFireRainMagic(true) || TryMakeRemoveStormFireRainMagic(true) || TryMakeFreezeMagic(true))
                {
                    return true;
                }
            }
        }
        if ((GetWeaponType() != cannonTypeSword) && TryFindNewAttackTarget(true, false))
        {
            return true;
        }
    }
    else
    {
        //jesli sami atakujemy budynek to szukamy innego celu - nie budynku
        if (bCurrSelfTarget && ((uCurrTarget.IsBuilding() && !uCurrTarget.HaveUnitOnTower()) || uCurrTarget.IsPassive()))
        {
            if ((GetWeaponType() != cannonTypeSword) && FindNewNotBuildingTarget(true))
            {
                return true;
            }
        }
    }
    return false;
}//����������������������������������������������������������������������������������������������������|

//event potrzebny aby skasowac linki od razu po zabiciu (command Uninitialize jest wywolywane dopiero
//po zapadnieciu sie pod ziemie)
event OnKilled()
{
    ResetMagicTarget();
    ResetAttackTarget();
    ResetCustomAnim();
#ifdef RPG_UNIT_EC
    ResetRPG();
#endif RPG_UNIT_EC
    return true;
}//����������������������������������������������������������������������������������������������������|

////    Commands    ////

command Initialize()
{
    InitializeHoldPos();
    InitializeMagic();
    InitializeAttack();
    if (!m_nAvailableMagics)
    {
        m_nCheckMagicCounter = -1;
    }
    else
    {
        m_nCheckMagicCounter = 3;
    }
    //inicjacja StayGx,y na wszelki wypadek
    StoreStayPos();
    InitializeArtefactsCounter();
#ifndef RPG_UNIT_EC
    teleportationMode=1;
    immortalMode = 1;
    capturingMode = 1;
    removeStormFireRainMode = 1;
#endif RPG_UNIT_EC
    return true;
}//����������������������������������������������������������������������������������������������������|

command Uninitialize()
{
    ResetEnterBuilding();
    ResetMagicTarget();
    ResetAttackTarget();
    ResetCustomAnim();
#ifdef RPG_UNIT_EC
    ResetRPG();
#endif RPG_UNIT_EC
    return true;
}//����������������������������������������������������������������������������������������������������|
}

