#define AI_SCRIPT
#define AI_PLATOON_EC

platoon "AIPlatoon"
{

////    Declarations    ////

state Initialize;
state Nothing;
state StartTurning;
state Turning;
state StartMoving;
state Moving;
state StartWaitForEndAttacking;
state Attacking;
state StartMovingAndDefend;
state MovingAndDefend;
state StartMovingAndBackIfEnemy;
state MovingAndBackIfEnemy;
state EscortingMagicUnit;
state StartMovingAndDefendInGroup;
state MovingAndDefendInGroup;
state StartEscapeFromStormFireRain;
state EscapeFromStormFireRain;

int m_nMoveMode;
int m_nMoveToGx;
int m_nMoveToGy;
int m_nMoveToLz;

int m_bDefendUnitsInPlatoon;
int m_bEscapeOnStorm;

int m_nStormAreaGx;
int m_nStormAreaGy;
int m_nStormAreaLz;
int m_nEscapeFromStormPrevState;

int m_nWaitForEndAttackingTicks;

unit m_uEscortedUnit;
int  m_nEscortCounter;

consts {
    eMoving      = 0x0001;
    eAttacking   = 0x0002;
    eAfterAttack = 0x0004;
    eAfterEscorted = 0x0010;
    eEscortedFirst = 0x0020;
    eEscortedMove  = 0x0040;
    eEscortedStop  = 0x0080;
}

//#define USE_TRACE

#include "..\Common.ech"
#include "..\Trace.ech"

////    Functions    ////

function void PlatoonAttack(unit uTarget)
{
    int nIndex, nCnt;
    punit uMember;

    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        uMember.CommandAttack(uTarget);
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|
function void PlatoonTurn(int nAlphaAngle)
{
    int nIndex, nCnt;
    punit uMember;

    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        uMember.CommandTurn(nAlphaAngle);
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonStop()
{
    int nIndex, nCnt;
    punit uMember;

    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        uMember.CommandStop();
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonMove(int nGx, int nGy, int nLz)
{
    m_nMoveToGx = nGx;
    m_nMoveToGy = nGy;
    m_nMoveToLz = nLz;
    CommandMovePlatoon(commandMove, nGx, nGy, nLz, m_nMoveMode, 0, null);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonMove(int nGx, int nGy, int nLz, int nUnitsMask)
{
    m_nMoveToGx = nGx;
    m_nMoveToGy = nGy;
    m_nMoveToLz = nLz;
    CommandMovePlatoon(commandMove, nGx, nGy, nLz, m_nMoveMode, nUnitsMask, null);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonMoveAndDefend(int nGx, int nGy, int nLz)
{
    m_nMoveToGx = nGx;
    m_nMoveToGy = nGy;
    m_nMoveToLz = nLz;
    CommandMovePlatoon(commandMoveAndDefend, nGx, nGy, nLz, m_nMoveMode, 0, null);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonMoveAndDefend(int nGx, int nGy, int nLz, unit uExeptUnit)
{
    m_nMoveToGx = nGx;
    m_nMoveToGy = nGy;
    m_nMoveToLz = nLz;
    CommandMovePlatoon(commandMoveAndDefend, nGx, nGy, nLz, m_nMoveMode, 0, uExeptUnit);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonMoveToFormation()
{
    punit uLeader;

    if (GetUnitsCount() > 0)
    {
        uLeader = GetUnit(0);
        ASSERT(uLeader != null);
        m_nMoveToGx = uLeader.GetLocationX();
        m_nMoveToGy = uLeader.GetLocationY();
        m_nMoveToLz = uLeader.GetLocationZ();
        CommandMovePlatoon(commandMove, m_nMoveToGx, m_nMoveToGy, m_nMoveToLz, movePlatoonFormation, 0, null);
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonSetMovementMode(int nMode)
{
    int nIndex, nCnt;
    punit uMember;

    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        uMember.CommandSetMovementMode(nMode);
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void PlatoonSetSmartAttackMode(int nMode)
{
    int nIndex, nCnt;
    punit uMember;

    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        uMember.CommandSetSmartAttackMode(nMode);
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void SetAllMoveFlag()
{
    AddUnitDataForAll(eMoving);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void SetAllAttackFlag()
{
    AddUnitDataForAll(eAttacking);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void SetAllMoveAndDefendFlag()
{
    AddUnitDataForAll(eMoving);
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function int IsExecutingMovingCommand()
{
    int nIndex, nCnt;
    int bIsAnyMoving;
    int nData;
    punit uMember;

    bIsAnyMoving = false;
    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        nData = GetUnitData(nIndex);
        if (nData & eMoving)
        {
            uMember = GetUnit(nIndex);
            if (uMember.IsMoving())
            {
                bIsAnyMoving = true;
            }
            else
            {
                SetUnitData(nIndex, nData & ~eMoving);
            }
        }
    }
    return bIsAnyMoving;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function int IsExecutingAttackCommand()
{
    int nIndex, nCnt;
    int bHaveAnyTarget;
    int nData;
    punit uMember;

    bHaveAnyTarget = false;
    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        nData = GetUnitData(nIndex);
        if (nData & eAttacking)
        {
            uMember = GetUnit(nIndex);
            if (uMember.SetEventOnGetTarget() != null)
            {
                bHaveAnyTarget = true;
            }
            else
            {
                SetUnitData(nIndex, nData & ~eAttacking);
            }
        }
    }
    return bHaveAnyTarget;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function int IsExecutingMoveAndDefendCommand()
{
    int nIndex, nCnt;
    int bIsAnyMovingOrDefending;
    int nData;
    punit uMember;

    bIsAnyMovingOrDefending = false;
    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        nData = GetUnitData(nIndex);
        if (nData & eMoving)
        {
            uMember = GetUnit(nIndex);
            if (uMember.IsMoving())
            {
                bIsAnyMovingOrDefending = true;
            }
            else
            {
                SetUnitData(nIndex, nData & ~eMoving);
            }
        }
        else if (nData & eAttacking)
        {
            uMember = GetUnit(nIndex);
            if (uMember.SetEventOnGetTarget() != null)
            {
                bIsAnyMovingOrDefending = true;
            }
            else
            {
                //eAfterAttack - czekamy az ruszy dalej po zakonczeniu ataku
                SetUnitData(nIndex, (nData & ~eAttacking) | eAfterAttack);
            }
        }
        else if (nData & eAfterAttack)
        {
            SetUnitData(nIndex, nData & ~eAfterAttack);
            bIsAnyMovingOrDefending = true;
        }
        else
        {
            uMember = GetUnit(nIndex);
            if (uMember.IsMoving())
            {
                bIsAnyMovingOrDefending = true;
                SetUnitData(nIndex, nData | eMoving);
            }
            else if (uMember.SetEventOnGetTarget() != null)
            {
                bIsAnyMovingOrDefending = true;
                SetUnitData(nIndex, nData | eAttacking);
            }
        }
    }
    return bIsAnyMovingOrDefending;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function int IsExecutingMoveAndBackIfEnemyCommand()
{
    int nIndex, nCnt;
    int bIsAnyMoving;
    int nData;
    punit uMember;

    bIsAnyMoving = false;
    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uMember = GetUnit(nIndex);
        if (uMember.SetEventOnGetTarget() != null)
        {
            //jakis z nich znalazl cel wiec konczymy wykonanie tej komendy
            return false;
        }
        nData = GetUnitData(nIndex);
        if (nData & eMoving)
        {
            uMember = GetUnit(nIndex);
            if (uMember.IsMoving())
            {
                bIsAnyMoving = true;
            }
            else
            {
                SetUnitData(nIndex, nData & ~eMoving);
            }
        }
    }
    return bIsAnyMoving;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//wywolywane po dodaniu nowego unita (z produkcji)
function void OnAddNewUnitToPlatoon(punit uUnit)
{
    punit uLeader;
    int nMoveToGx, nMoveToGy, nMoveToLz;
    int nMinCnt;

    ASSERT(state != Initialize);
    if ((state == StartMoving) || (state == Moving))
    {
        uUnit.CommandMove(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        SetUnitData(uUnit, eMoving);
    }
    else if ((state == StartMovingAndDefend) || (state == MovingAndDefend) || (state == StartMovingAndBackIfEnemy) || (state == MovingAndBackIfEnemy))
    {
        uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        SetUnitData(uUnit, eMoving);
    }
    else if ((state == StartMovingAndDefendInGroup) || (state == MovingAndDefendInGroup))
    {
        if ((m_uEscortedUnit != null) && uUnit.IsFasterThenUnit(m_uEscortedUnit))
        {
            uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
        }
        else
        {
            uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        }
        SetUnitData(uUnit, eAfterEscorted);
    }
    else if (state == EscortingMagicUnit)
    {
        if (m_uEscortedUnit != null)
        {
            uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
        }
        SetUnitData(uUnit, eAfterEscorted);
    }
    else if ((state == StartWaitForEndAttacking) || (state == Attacking) || (state == Nothing))
    {
        if (state == Nothing)
        {
            nMinCnt = 0;
        }
        else
        {
            //attacking
            nMinCnt = 4;
        }
        if (GetUnitsCount() > nMinCnt)
        {
            uLeader = GetUnit(0);
            if (uLeader.IsMoving())
            {
                nMoveToGx = uLeader.GetMoveTargetX();
                nMoveToGy = uLeader.GetMoveTargetY();
                nMoveToLz = uLeader.GetMoveTargetZ();
                uUnit.CommandMoveAndDefend(nMoveToGx, nMoveToGy, nMoveToLz);
            }
            else
            {
                nMoveToGx = uLeader.GetLocationX();
                nMoveToGy = uLeader.GetLocationY();
                nMoveToLz = uLeader.GetLocationZ();
            }
            if ((uUnit.DistanceTo(nMoveToGx, nMoveToGy) > 5) || (uUnit.GetLocationZ() != nMoveToLz))
            {
                uUnit.CommandMoveAndDefend(nMoveToGx, nMoveToGy, nMoveToLz);
            }
        }
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//funkcja ktora sprawdza czy jakis unit jest atakowany i jesli tak i jest unit w plutonie ktory
//nic nie robi to wysyla go aby bronil tamtego unita (wysyla go w jego kierunku)
//funkcja wprowadzona po to aby nie bylo tak, ze bija jakiegos naszego unita a inne stoja od niego za daleko
//i nic nie widza wiec stoja bezczynnie
function void DefendUnitsInPlatoon()
{
    punit arrAttackedUnits[];
    punit arrFreeUnits[];
    punit uUnit;
    unit uAttacker;
    int nIndex, nIndex2, nCnt, nCnt2, nStep, nSteps;
    int nPosGx, nPosGy, nPosLz;
    int nFreePerAttacked, nExtraFree;

    arrAttackedUnits.Create(0);
    arrFreeUnits.Create(0);
    nCnt = GetUnitsCount();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uUnit = GetUnit(nIndex);
        uAttacker = uUnit.GetLatestAttacker();
        if (uAttacker != null)
        {
            arrAttackedUnits.Add(uUnit);
        }
        else
        {
            if (!uUnit.IsExecutingAnyCommand() && (uUnit.SetEventOnGetTarget() == null))
            {
                arrFreeUnits.Add(uUnit);
            }
        }
    }
    if ((arrAttackedUnits.GetSize() == 0) || (arrFreeUnits.GetSize() == 0))
    {
        return;
    }
    //do kolejnych unitow z arrAttackedUnits wysylamy unity z arrFreeUnits
    //nie sprawdzamy odleglosci (wysylania do bedacych najblizej) bo zajelo by to za duzo czasu
    //ale sprawdzamy czy broniony nie jest za daleko po to aby nie bylo sytuacji ze pluton idzie do ataku
    //jest wybijany ale sa produkowane nowe jednostki do plutonu i one ida bronic tych starych i tak
    //po kolei sa wybijane
    nFreePerAttacked = arrFreeUnits.GetSize()/arrAttackedUnits.GetSize();
    if (nFreePerAttacked == 0)
    {
        nFreePerAttacked = 1;
    }
    nExtraFree = arrFreeUnits.GetSize()%arrAttackedUnits.GetSize();
    nCnt = arrAttackedUnits.GetSize();
    nIndex2 = 0;
    nCnt2 = arrFreeUnits.GetSize();
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uUnit = arrAttackedUnits[nIndex];
        nPosGx = uUnit.GetLocationX();
        nPosGy = uUnit.GetLocationY();
        nPosLz = uUnit.GetLocationZ();
        if (nIndex < nExtraFree)
        {
            nSteps = nFreePerAttacked + 1;
        }
        else
        {
            nSteps = nFreePerAttacked;
        }
        for (nStep = 0; (nIndex2 < nCnt2) && (nStep < nSteps); ++nStep)
        {
            uUnit = arrFreeUnits[nIndex2];
            if (uUnit.DistanceTo(nPosGx, nPosGy) < 16)
            {
                uUnit.CommandMoveAndDefend(nPosGx, nPosGy, nPosLz);
            }
            ++nIndex2;
        }
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//sprawdza czy w miejscu w ktorym znajduje sie pluton (lider) jest burza/fireRain i jesli tak
//i znajdujemy sie odpowiednio daleko od bazy to zwracamy true (jesli znajdujemy sie blisko bazy to musimy jej bronic)
function int CheckIsInStormFireRainArea()
{
    punit uLeader;

    uLeader = GetUnit(0);
    if (uLeader == null)
    {
        return false;
    }
    if (uLeader.IsStormOrFireRainInPoint(uLeader.GetLocationX(), uLeader.GetLocationY(), uLeader.GetLocationZ(), true, false))
    {
        if (uLeader.DistanceTo(GetPlayerStartingPointX(), GetPlayerStartingPointY()) > 20)
        {
            return true;
        }
    }
    return false;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

function void StartEscapeFromStormFireRainArea(int bMovingToMoveTarget)
{
    punit uLeader;

    uLeader = GetUnit(0);
    ASSERT(uLeader);
    m_nStormAreaGx = uLeader.GetLocationX();
    m_nStormAreaGy = uLeader.GetLocationY();
    m_nStormAreaLz = uLeader.GetLocationZ();
    m_nEscapeFromStormPrevState = state;
    if (!bMovingToMoveTarget)
    {
        m_nMoveToGx = m_nStormAreaGx;
        m_nMoveToGy = m_nStormAreaGy;
        m_nMoveToLz = m_nStormAreaLz;
    }
    //else m_nMoveTo zostaje takie jakie jest
    //uciekamy w kierunku punktu startowego
    CommandMovePlatoon(commandMove, GetPlayerStartingPointX(), GetPlayerStartingPointY(), 0, m_nMoveMode, 0, null);
    SetAllMoveFlag();
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

////    States    ////

state Initialize
{
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Nothing
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    return Nothing;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartTurning
{
    return Turning;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Turning
{
    if (IsExecutingMovingCommand())
    {
        return Turning;
    }
    else
    {
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartMoving
{
    return Moving;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Moving
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (IsExecutingMovingCommand())
    {
        return Moving;
    }
    else
    {
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartMovingAndDefend
{
    return MovingAndDefend;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state MovingAndDefend
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (m_bEscapeOnStorm && CheckIsInStormFireRainArea())
    {
        //jestesmy w strefie burzy/fireRain - uciekamy
        StartEscapeFromStormFireRainArea(true);
        return StartEscapeFromStormFireRain;
    }
    if (IsExecutingMoveAndDefendCommand())
    {
        return MovingAndDefend;
    }
    else
    {
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartMovingAndBackIfEnemy
{
    return MovingAndBackIfEnemy;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//idzie i gdy tylko jeden z unitow znajdzie cel to wraca
state MovingAndBackIfEnemy
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (m_bEscapeOnStorm && CheckIsInStormFireRainArea())
    {
        //jestesmy w strefie burzy/fireRain - uciekamy
        StartEscapeFromStormFireRainArea(true);
        return StartEscapeFromStormFireRain;
    }
    if (IsExecutingMoveAndBackIfEnemyCommand())
    {
        return MovingAndBackIfEnemy;
    }
    else
    {
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartWaitForEndAttacking
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (m_bEscapeOnStorm && CheckIsInStormFireRainArea())
    {
        //jestesmy w strefie burzy/fireRain - uciekamy
        StartEscapeFromStormFireRainArea(false);
        return StartEscapeFromStormFireRain;
    }
    //zmniejszenie licznika "na zapas"
    if (m_nWaitForEndAttackingTicks >= 0)
    {
        m_nWaitForEndAttackingTicks = m_nWaitForEndAttackingTicks - 100;
        if (m_nWaitForEndAttackingTicks <= 0)
        {
            m_nWaitForEndAttackingTicks = 0;
        }
    }
    return Attacking, 100;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state Attacking
{
    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (m_bEscapeOnStorm && CheckIsInStormFireRainArea())
    {
        //jestesmy w strefie burzy/fireRain - uciekamy
        StartEscapeFromStormFireRainArea(false);
        return StartEscapeFromStormFireRain;
    }
    if (m_nWaitForEndAttackingTicks >= 0)
    {
        m_nWaitForEndAttackingTicks = m_nWaitForEndAttackingTicks - 20;
        if (m_nWaitForEndAttackingTicks <= 0)
        {
            NextCommand(1);
            return Nothing;
        }
    }
    if (IsExecutingAttackCommand())
    {
        return Attacking;
    }
    else
    {
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state EscortingMagicUnit
{
    punit uUnit;
    unitex uTmp;
    int nDist;
    int nIndex, nCnt, nNotAttackingCnt, nAttackingCnt;
    int nBeforeEscCnt;
    int nCommand;
    int nUnitData;

    if ((m_uEscortedUnit == null) || !m_uEscortedUnit.IsLive() || !m_uEscortedUnit.IsExecutingAnyCommand())
    {
        m_uEscortedUnit = null;
        NextCommand(1);
        return Nothing;
    }
    nCnt = GetUnitsCount();
    if ((nCnt == 0) || ((nCnt == 1) && (GetUnit(0) == m_uEscortedUnit)))
    {
        //pluton zostal wybity
        //jesli "magic" jeszcze wykonuje ta komende to robimy mu NextCommand zeby uciekal
        nCommand = m_uEscortedUnit.GetExecutedCommand();
        if ((nCommand >= commandMakeMagicFirst) && (nCommand <= commandMakeMagicLast))
        {
            uTmp = GetUnitExRef(m_uEscortedUnit);
            uTmp.NextCommand(1);
        }
        m_uEscortedUnit = null;
        NextCommand(1);
        return Nothing;
    }
    if (m_nEscortCounter == 0)
    {
        nCommand = m_uEscortedUnit.GetExecutedCommand();
        if ((nCommand < commandMakeMagicFirst) || (nCommand > commandMakeMagicLast))
        {
            m_nEscortCounter = 1;
        }
    }
    else
    {
        if (!m_uEscortedUnit.IsMoving())
        {
            ++m_nEscortCounter;
            if (m_nEscortCounter >= 5)
            {
                m_uEscortedUnit = null;
                NextCommand(1);
                return Nothing;
            }
        }
    }
    //nie robimy PlatoonMoveAndDefend tylko dla kazdego unita sprawdzamy osobno odleglosc
    //po to zeby wlasciwie obsluzyc walke (moveAndDefend)
    //w pierwszej petli liczymy ile unitow w plutonie walczy
    nAttackingCnt = 0;
    nNotAttackingCnt = 0;
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uUnit = GetUnit(nIndex);
        if (uUnit != m_uEscortedUnit) 
        {
            if (uUnit.SetEventOnGetTarget() != null)
            {
                ++nAttackingCnt;
            }
            else
            {
                ++nNotAttackingCnt;
            }
        }
    }
    if ((nAttackingCnt + nNotAttackingCnt) == 0)
    {
        m_uEscortedUnit = null;
        NextCommand(1);
        return Nothing;
    }
    //teraz wydajemy rozkazy Move unitom - jesli jakis walczy to pozwalamy mu walczyc, chyba ze zbyt malo eskortuje
    nBeforeEscCnt = 0;
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uUnit = GetUnit(nIndex);
        if (uUnit != m_uEscortedUnit)
        {
            if (uUnit.SetEventOnGetTarget() == null)
            {
                nDist = uUnit.DistanceTo(m_uEscortedUnit);
                if (uUnit.IsFasterThenUnit(m_uEscortedUnit) && (nBeforeEscCnt <= nCnt/2))
                {
                    ++nBeforeEscCnt;
                    TRACE("Faster");
                    nUnitData = GetUnitData(nIndex);
                    if (nUnitData & eAfterEscorted)
                    {
                        if (nDist < 3)
                        {
                            TRACE2("~eAfterEscorted ", uUnit);
                            SetUnitData(nIndex, nUnitData & ~eAfterEscorted);
                            uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetMoveTargetX(), m_uEscortedUnit.GetMoveTargetY(), m_uEscortedUnit.GetMoveTargetZ());
                        }
                        else
                        {
                            TRACE2("eAfterEscorted ", uUnit);
                            if (nIndex <= nCnt/2)
                            {
                                uUnit.CommandMove(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                            }
                            else
                            {
                                uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                            }
                        }
                    }
                    else
                    {
                        if (!m_uEscortedUnit.IsMoving())
                        {
                            TRACE2("!IsMoving ", uUnit);
                            uUnit.CommandStop();
                        }
                        else if (nDist < 4)
                        {
                            TRACE2("(nDist < 4) ", uUnit);
                            uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetMoveTargetX(), m_uEscortedUnit.GetMoveTargetY(), m_uEscortedUnit.GetMoveTargetZ());
                        }
                        else if (nDist > 15)
                        {
                            TRACE2("(nDist > 15) ", uUnit);
                            //cos sie pogubil
                            uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                        }
                        else if (nDist > 5)
                        {
                            TRACE2("(nDist > 5) ", uUnit);
                            uUnit.CommandStop();
                        }
                        else
                        {
                            //4-5 - idzie
                            TRACE2("nDist 4-5 ", uUnit);
                        }
                    }
                }
                else if (nDist > 1)
                {
                    if ((uUnit.GetExecutedCommand() == commandMove) && (nIndex <= nCnt/2))
                    {
                        uUnit.CommandMove(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                    else
                    {
                        uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                }
            }
            else
            {
                SetUnitData(nIndex, GetUnitData(nIndex) | eAfterEscorted);
                --nAttackingCnt;
                //co najmniej 3 musza eskortowac unit
                if (((nNotAttackingCnt + nAttackingCnt) < 3) && 
                    (uUnit.DistanceTo(m_uEscortedUnit) > 6))
                {
                    //dajemy mu CommandMove zeby za chwile znowu nie zaatakowal swojego celu (ale nie wszystkim zeby jakies walczyly)
                    if (nIndex <= nCnt/2)
                    {
                        uUnit.CommandMove(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                    else
                    {
                        uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                }
            }
        }
    }
    return EscortingMagicUnit;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartMovingAndDefendInGroup
{
    return MovingAndDefendInGroup;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//porusza sie zwarta grupa w kierunku punktu docelowego. 
//w tym celu "eskortuje" unit m_uEscortedUnit ktory nalezy do tego plutonu i ma najmniejsza predkosc
//czesciowo skopiowane z EscortingMagicUnit
state MovingAndDefendInGroup
{
    punit uUnit;
    int nIndex, nCnt;
    int nDist;
    int bIsAnyMovingOrAttacking;
    int nUnitData;

    if (m_bDefendUnitsInPlatoon)
    {
        DefendUnitsInPlatoon();
    }
    if (m_bEscapeOnStorm && CheckIsInStormFireRainArea())
    {
        //jestesmy w strefie burzy/fireRain - uciekamy
        StartEscapeFromStormFireRainArea(true);
        AddUnitDataForAll(eAfterEscorted);
        return StartEscapeFromStormFireRain;
    }

    bIsAnyMovingOrAttacking = false;
    nCnt = GetUnitsCount();
    if ((m_uEscortedUnit == null) || !m_uEscortedUnit.IsLive())
    {
        if (nCnt >= 2)
        {
            m_uEscortedUnit = GetUnit(nCnt - 1);
            AddUnitDataForAll(eAfterEscorted);
        }
        else if (nCnt == 1)
        {
            m_uEscortedUnit = null;
            uUnit = GetUnit(0);
            uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
            SetAllMoveAndDefendFlag();
            return MovingAndDefend;
        }
        else
        {
            m_uEscortedUnit = null;
            NextCommand(0);
            return Nothing;
        }
    }
    for (nIndex = 0; nIndex < nCnt; ++nIndex)
    {
        uUnit = GetUnit(nIndex);
        if (uUnit.IsMoving())
        {
            bIsAnyMovingOrAttacking = true;
        }
        if ((uUnit != m_uEscortedUnit) && uUnit.IsFasterThenUnit(m_uEscortedUnit))
        {
            nUnitData = GetUnitData(nIndex);
            if (uUnit.SetEventOnGetTarget() == null)
            {
                nDist = uUnit.DistanceTo(m_uEscortedUnit);
                if (nUnitData & eAfterEscorted)
                {
                    if (nDist < 3)
                    {
                        TRACE2("~eAfterEscorted ", uUnit);
                        SetUnitData(nIndex, (nUnitData & ~eAfterEscorted) | eEscortedFirst);
                        uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
                    }
                    else
                    {
                        TRACE2("eAfterEscorted ", uUnit);
                        uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                }
                else
                {
                    if (nDist < 4)
                    {
                        TRACE2("(nDist < 4) ", uUnit);
                        SetUnitData(nIndex, nUnitData | eEscortedMove);
                        uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
                    }
                    else if (nDist > 10)
                    {
                        TRACE2("(nDist > 10) ", uUnit);
                        //cos sie pogubil
                        SetUnitData(nIndex, (nUnitData & ~(eEscortedFirst | eEscortedMove)) | eAfterEscorted);
                        uUnit.CommandMoveAndDefend(m_uEscortedUnit.GetLocationX(), m_uEscortedUnit.GetLocationY(), m_uEscortedUnit.GetLocationZ());
                    }
                    else if (nDist > 5)
                    {
                        if (nUnitData & eEscortedFirst)
                        {
                            TRACE2("(nDist > 5)-a ", uUnit);
                            SetUnitData(nIndex, (nUnitData & ~eEscortedFirst) | eEscortedMove);
                            uUnit.CommandMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
                        }
                        else if (nUnitData & eEscortedMove)
                        {
                            TRACE2("(nDist > 5)-b ", uUnit);
                            SetUnitData(nIndex, (nUnitData & ~eEscortedMove) | eEscortedStop);
                            uUnit.CommandStop();
                        }
                        else
                        {
                            TRACE2("(nDist > 5)-c ", uUnit);
                            ASSERT(nUnitData & eEscortedStop);
                        }
                    }
                    else
                    {
                        //4-5 - idzie
                        TRACE2("nDist 4-5 ", uUnit);
                    }
                }
            }
            else
            {
                SetUnitData(nIndex, nUnitData | eAfterEscorted);
                bIsAnyMovingOrAttacking = true;
            }
        }
    }

    if (bIsAnyMovingOrAttacking)
    {
        return MovingAndDefendInGroup;
    }
    else
    {
        TRACE("!bIsAnyMovingOrAttacking -> NextCommand");
        m_uEscortedUnit = null;
        NextCommand(1);
        return Nothing;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state StartEscapeFromStormFireRain
{
    return EscapeFromStormFireRain;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

state EscapeFromStormFireRain
{
    punit uLeader;

    //sprawdzamy czy w punkcie z ktorego uciekamy jest jeszcze burza
    //jesli nie to wracamy do wykonywania komendy
    uLeader = GetUnit(0);
    if (uLeader == null)
    {
        NextCommand(1);
        return Nothing;
    }
    if (!uLeader.IsStormOrFireRainInPoint(m_nStormAreaGx, m_nStormAreaGy, m_nStormAreaLz, true, false) || !IsExecutingMovingCommand())
    {
        PlatoonMoveAndDefend(m_nMoveToGx, m_nMoveToGy, m_nMoveToLz);
        if (m_nEscapeFromStormPrevState == MovingAndDefend)
        {
            return MovingAndDefend;
        }
        else if (m_nEscapeFromStormPrevState == MovingAndBackIfEnemy)
        {
            return MovingAndBackIfEnemy;
        }
        else if (m_nEscapeFromStormPrevState == StartWaitForEndAttacking)
        {
            return StartWaitForEndAttacking;
        }
        else if (m_nEscapeFromStormPrevState == Attacking)
        {
            return Attacking;
        }
        else if (m_nEscapeFromStormPrevState == MovingAndDefendInGroup)
        {
            return MovingAndDefendInGroup;
        }
        else
        {
            __ASSERT_FALSE();
            NextCommand(1);
            return Nothing;
        }
    }
    else
    {
        return EscapeFromStormFireRain;
    }
}//————————————————————————————————————————————————————————————————————————————————————————————————————|


////    Commands    ////

command Initialize()
{
    m_nMoveMode = moveSquareFormation;
    m_bDefendUnitsInPlatoon = false;
    m_bEscapeOnStorm = false;
#ifdef USE_TRACE
    traceMode = 1;
#endif USE_TRACE
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Uninitialize()
{
    int nCnt;
    int nCommand;
    unitex uTmp;

    //jesli bylismy w trakcie eskortowania unita i wszystkie unity zostaly wybite (zanim zostalo to zauwazone w state Escorting)
    //to powtarzamy tutaj to co jest w EscortingMagicUnit
    if (state == EscortingMagicUnit)
    {
        nCnt = GetUnitsCount();
        if ((nCnt == 0) || ((nCnt == 1) && (GetUnit(0) == m_uEscortedUnit)))
        {
            //pluton zostal wybity
            //jesli "magic" jeszcze wykonuje ta komende to robimy mu NextCommand zeby uciekal
            nCommand = m_uEscortedUnit.GetExecutedCommand();
            if ((nCommand >= commandMakeMagicFirst) && (nCommand <= commandMakeMagicLast))
            {
                uTmp = GetUnitExRef(m_uEscortedUnit);
                uTmp.NextCommand(1);
            }
        }
    }

    //wykasowac referencje
    m_uEscortedUnit = null;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command AddUnitToPlatoon(punit uUnit)
{
    AddUnitToPlatoon(uUnit.GetUnitRef());
    if (state != Initialize)
    {
        OnAddNewUnitToPlatoon(uUnit);
    }
    //tutaj nie wolamy NextCommand po to zeby pluton wykonywal ta kolejke komend ktora ma nagrana
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command RemoveUnitFromPlatoon(punit uUnit)
{
    RemoveUnitFromPlatoon(uUnit.GetUnitRef());
    //tutaj nie wolamy NextCommand po to zeby pluton wykonywal ta kolejke komend ktora ma nagrana
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command DisposePlatoon()
{
    Dispose();
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Stop()
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonStop();
    NextCommand(1);
    state Nothing;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Move(int nGx, int nGy, int nLz)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonMove(nGx, nGy, nLz);
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Turn(int nAlphaAngle) hidden
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
	PlatoonTurn(nAlphaAngle);
	SetAllMoveFlag();
	state StartTurning;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command Attack(unit uTarget)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonAttack(uTarget);
    SetAllAttackFlag();
    m_nWaitForEndAttackingTicks = -1;
    state Attacking;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetMovementMode(int nMode)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonSetMovementMode(nMode);
    NextCommand(1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

command SetSmartAttackMode(int nMode)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonSetSmartAttackMode(nMode);
    NextCommand(1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//move and defend
command MoveAndDefend(int nGx, int nGy, int nLz)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonMoveAndDefend(nGx, nGy, nLz);
    SetAllMoveAndDefendFlag();
    state StartMovingAndDefend;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//move and defend - keep units close
command MoveAndDefendInGroup(int nGx, int nGy, int nLz)
{
    int nCnt, nIndex;
    punit uUnit;
    unitex uExTmp;
    unit uUnitFirst, uUnitLast;

    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    SortUnitsBySpeed(true);
    //jesli maja taka sama predkosc to normalnie moveAndDefend
    nCnt = GetUnitsCount();
    if (nCnt >= 2)
    {
        uUnitFirst = GetUnit(0);
        uUnitLast = GetUnit(nCnt - 1);
        if (uUnitFirst.IsFasterThenUnit(uUnitLast))
        {
            m_uEscortedUnit = uUnitLast;
            m_nMoveToGx = nGx;
            m_nMoveToGy = nGy;
            m_nMoveToLz = nLz;
            //m_uEscortedUnit oraz tym unitom ktore nie sa od niego szybsze wydajemy rozkaz jazdy do punktu docelowego
            uExTmp = GetUnitExRef(m_uEscortedUnit);
            uExTmp.CommandMoveAndDefend(nGx, nGy, nLz);
            for (nIndex = 0; nIndex < nCnt; ++nIndex)
            {
                uUnit = GetUnit(nIndex);
                if ((uUnit != m_uEscortedUnit) && !uUnit.IsFasterThenUnit(m_uEscortedUnit))
                {
                    uUnit.CommandMoveAndDefend(nGx, nGy, nLz);
                }
            }
            AddUnitDataForAll(eAfterEscorted);
            state StartMovingAndDefendInGroup;
            return true;
        }
        //else przechodzimy dalej
    }
    PlatoonMoveAndDefend(nGx, nGy, nLz);
    SetAllMoveAndDefendFlag();
    state StartMovingAndDefend;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//set line formation
command UserNoParam0()
{
    int nIndex, nCnt;

    nCnt = GetUnitsCount();
    if (nCnt == 0)
    {
        NextCommand(0);
        return true;
    }
    for(nIndex = 1; nIndex < nCnt; ++nIndex)
    {
        if(nIndex%2)
        {
            SetPosition(nIndex, nIndex/2+1, 0);
        }
        else
        {
            SetPosition(nIndex, -nIndex/2, 0);
        }
    }
    PlatoonMoveToFormation();
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//set square formation
command UserNoParam1()
{
    int nIndex, nCnt;
    int nSize;

    nCnt = GetUnitsCount();
    if (nCnt == 0)
    {
        NextCommand(0);
        return true;
    }
    nSize = sqrt(nCnt);
    if (nSize*nSize < nCnt)
    {
        ++nSize;
    }
    for(nIndex = 1; nIndex < nCnt; ++nIndex)
    {
        SetPosition(nIndex, nIndex%nSize, nIndex/nSize);
    }
    PlatoonMoveToFormation();
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//turn right
command UserNoParam2()
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    TurnFormation(64);
    PlatoonMoveToFormation();
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//turn left
command UserNoParam3()
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    TurnFormation(-64);
    PlatoonMoveToFormation();
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//wait for end units attacking
command UserNoParam5()
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    SetAllAttackFlag();
    m_nWaitForEndAttackingTicks = -1;
    state StartWaitForEndAttacking;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//set move mode
command UserOneParam0(int nMoveMode)
{
    //nie ma sprawdzania UnitsCount
    m_nMoveMode = nMoveMode;
    NextCommand(1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//set "defend units in platoon" mode
command UserOneParam1(int nMode)
{
    //nie ma sprawdzania UnitsCount
    m_bDefendUnitsInPlatoon = nMode;
    NextCommand(1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//set "escape (NextCommand) if in storm area" mode
command UserOneParam2(int nMode)
{
    //nie ma sprawdzania UnitsCount
    m_bEscapeOnStorm = nMode;
    NextCommand(1);
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//wait for end units attacking nTime-seconds
command UserOneParam5(int nTime)
{
    //nie ma sprawdzania UnitsCount
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    SetAllAttackFlag();
    m_nWaitForEndAttackingTicks = nTime*20;
    state StartWaitForEndAttacking;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//move without builders
command UserPoint0(int nGx, int nGy, int nLz)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonMove(nGx, nGy, nLz, notMoveBuilders);
    SetAllMoveFlag();
    state StartMoving;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//move and end command if found some enemy
command UserPoint1(int nGx, int nGy, int nLz)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    PlatoonMoveAndDefend(nGx, nGy, nLz);
    SetAllMoveFlag();
    state StartMovingAndBackIfEnemy;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|

//escort unit until he's executing magic command
command UserObject0(unit uEscortUnit)
{
    if (GetUnitsCount() == 0)
    {
        NextCommand(0);
        return true;
    }
    m_uEscortedUnit = uEscortUnit;
    m_nEscortCounter = 0;
    SortUnitsBySpeed(true);
    AddUnitDataForAll(eAfterEscorted);
    m_uEscortedUnit.SetCustomEvent(0, 1, 0, 0, 0, null);
    state EscortingMagicUnit;
    return true;
}//————————————————————————————————————————————————————————————————————————————————————————————————————|
}
