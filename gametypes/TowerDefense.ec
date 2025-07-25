#define TOWER_DEFENSE
#define TIER_5_GAME_TYPE

#define NEXT_WAVE_TRIGGER_MARKER 90
#define REMOVE_ARTEFACTS_TRIGGER_MARKER 91
#define PERUN_RAGE_TRIGGER_MARKER 92
#define EXTRA_BREAK_TIME_TRIGGER_MARKER 93
#define BREAK_TRIGGER_MARKER 94

#define BOSS_MARKER 50

#define FIRST_MARKER_TO_REACH_CENTER 60
#define FIRST_MARKER_TO_REACH_LEFT 70
#define FIRST_MARKER_TO_REACH_RIGHT 80
#define PATH_MASK 127
#define TOWER_DEFENSE_SPECIAL_MASK 127 << 8
#define BOMBER_MARKER 1 << 8
#define BOMBER_POISON_MARKER 2 << 8
#define MAIN_BOSS_QUEEN_MARKER 3 << 8
#define MAIN_BOSS_NECROMANCER_MARKER 4 << 8
#define MAIN_BOSS_DEMON_MARKER 5 << 8
#define SORCERESS_MARKER 6 << 8
#define MAGE_MARKER 7 << 8

#define SKELETON_WAVE 0
#define GIANT_WAVE 1
#define NORMAL_HUMAN_WAVE 2
#define ELITE_HUMAN_WAVE 3
#define MINOTAUR_WAVE 4
#define DEMON_WAVE 5
#define BEAST_WAVE 6
#define MAGE_WAVE 7
#define BANDIT_WAVE 8
#define DRAGON_WAVE 9

#define FIRST_SPAWN_MARKER 20
#define LAST_SPAWN_MARKER 39

#define FIRST_SPAWN_MARKER_CLOSE 40
#define LAST_SPAWN_MARKER_CLOSE 49

#define REWARDS_MARKER 3
#define CONTROL_BUTTONS_MARKER 4

#define MILK_MARKER 5

#define FIRST_REWARD_MARKER 6
#define LAST_REWARD_MARKER 10

#define REWARD_INFO_MARKER 11
#define CUTSCENE_PRIEST_MARKER 12


mission "translateTowerDefense"
{

    consts
    {
        BREAK_TIME_MINUTES = 5;
        WAVE_TIME_MINUTES = 5;
    }

    #include "Common\Consts.ech"
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\StartingUnits.ech"

    player rPlayer8, rPlayer9, rPlayer10, rPlayer11, rPlayer12, rPlayer13, rPlayer14;
    int bIsWin;
    int bIsBossWave, bIsFinalWave;
    int iBossWaveType;
    unitex uBoss;
    int iTotalWaveNumber;
    int bWaveActive;
    int iBreakTime, iBreakTimeStart;
    int iWaveTimeStart;
    int iNumberOfUnitsToSpawn, iNumberOfBombersToSpawn, iNumberOfBossUnitsToSpawn;
    int iCurrentWaveNumber;
    int iWaveType;

    int iDifficulty;

    #include "TowerDefense\SpecialPrize.ech"
    #include "TowerDefense\Helpers.ech"
    #include "TowerDefense\Research.ech"
    #include "TowerDefense\Rewards.ech"
    #include "TowerDefense\Starters.ech"
    #include "TowerDefense\Buildings.ech"
    #include "TowerDefense\Ai.ech"
    #include "TowerDefense\Waves.ech"
    #include "TowerDefense\Bossess.ech"

    int iBossHealth, iPreviousBossHealth;

    int iBossWaveTypes[];

    unitex uUnit;



    #include "TowerDefense\Control.ech"
    #include "TowerDefense\DisplayText.ech"
    #include "TowerDefense\Events.ech"


    enum comboDifficulty
    {    
        "translateTowerDefenseDifficultyLevel0",
        "translateTowerDefenseDifficultyLevel1",
        "translateTowerDefenseDifficultyLevel2",
        "translateTowerDefenseDifficultyLevel3",
        "translateTowerDefenseDifficultyLevel4",
            multi:
        "translateTowerDefenseDifficulty"
    }

    enum comboWaveNumber
    {
        "20",
        "30",
        "40",
        "50",
            multi:
        "translateTowerDefenseWaveNumber"
    }



    function void InitAiPlayers()
    {
        rPlayer8 = GetPlayer(8);
        rPlayer9 = GetPlayer(9);
        rPlayer10 = GetPlayer(10);
        rPlayer11 = GetPlayer(11);
        rPlayer12 = GetPlayer(12);
        rPlayer13 = GetPlayer(13);
        rPlayer14 = GetPlayer(14);

        SetAlly(rPlayer8, rPlayer9);
        SetAlly(rPlayer8, rPlayer10);
        SetAlly(rPlayer8, rPlayer11);
        SetAlly(rPlayer8, rPlayer12);

        SetAlly(rPlayer9, rPlayer10);
        SetAlly(rPlayer9, rPlayer11);
        SetAlly(rPlayer9, rPlayer12);

        SetAlly(rPlayer10, rPlayer11);
        SetAlly(rPlayer10, rPlayer12);

        SetAlly(rPlayer11, rPlayer12);

        
        SetEnemies(rPlayer8, rPlayer14);
        SetEnemies(rPlayer9, rPlayer14);
        SetEnemies(rPlayer10, rPlayer14);
        SetEnemies(rPlayer11, rPlayer14);
        SetEnemies(rPlayer12, rPlayer14);


        GiveResearch(rPlayer11, 0, 0, 1);
        GiveResearch(rPlayer12, 4, 4, 4);
    }

    function void InitHumanPlayers()
    {
        player rPlayer0, rPlayer1, rPlayer2;

        rPlayer0 = GetPlayer(0);
        rPlayer1 = GetPlayer(1);
        rPlayer2 = GetPlayer(2);

        SetAlly(rPlayer0, rPlayer1);
        SetAlly(rPlayer0, rPlayer2);

        SetAlly(rPlayer1, rPlayer2);
    }

    function void InitBossWaveTypes()
    {
        int i, j, iTemp, iTemp2;
        iBossWaveTypes.Create(5);
        
        // First fill array with sequential numbers
        for(i=0; i<5; i=i+1)
        {
            iBossWaveTypes[i] = i;
        }
        
        // Then shuffle using Fisher-Yates algorithm
        for(i=4; i>0; i=i-1)
        {
            j = RandXor(i+1);
            iTemp = iBossWaveTypes[i];
            iTemp2 = iBossWaveTypes[j];
            iBossWaveTypes[i] = iTemp2;
            iBossWaveTypes[j] = iTemp;
        }

    }

    function void InitCreateRewardInfo()
    {
        CreateObjectAtMarker(REWARD_INFO_MARKER, "TOWERDEFENSE_INFO5");
    }

    function void SetTotalWaveNumber()
    {
        iTotalWaveNumber = 10 * (comboWaveNumber + 2);
    }

    function void SetDifficulty()
    {
        iDifficulty = comboDifficulty;
    }

    function void SetGoal(player rPlayer)
    {
        SetStringBuffTranslate(2, "translateTowerDefenseGoal");
        SetStringBuff(3, GetStringBuff(2), iTotalWaveNumber);
        rPlayer.RegisterGoal(0, GetStringBuff(3));
        rPlayer.EnableGoal(0, true, true);
    }

    function void InitFinalBoss()
    {
        int i;
        unitex uSmoke;

        if(iTotalWaveNumber <= 10)
        {
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER, "RPG_EGYPT_NECRO");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+1, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+2, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+3, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+4, "QUEENCLONE");
        }
        else if(iTotalWaveNumber <= 20)
        {
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER, "RPG_EGYPT_NECRO2");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+1, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+2, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+3, "QUEENCLONE");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+4, "QUEENCLONE");
        }
        else if(iTotalWaveNumber <= 30) 
        {
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER, "RPG_EGYPT_NECRO2");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+1, "QUEENCLONE2");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+2, "QUEENCLONE2");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+3, "QUEENCLONE2");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+4, "QUEENCLONE2");
        }
        else if(iTotalWaveNumber <= 40)
        {
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER, "RPG_EGYPT_NECRO3");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+1, "QUEENCLONE3");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+2, "QUEENCLONE3");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+3, "QUEENCLONE3");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+4, "QUEENCLONE3");
        }
        else if(iTotalWaveNumber <= 50)
        {
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER, "RPG_EGYPT_NECRO3");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+1, "QUEENCLONE4");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+2, "QUEENCLONE4");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+3, "QUEENCLONE4");
            CreateUnitAtMarker(rPlayer8, BOSS_MARKER+4, "QUEENCLONE4");
        }


        for(i=0; i<5; i=i+1)
        {
            uUnit = GetUnitAtMarker(BOSS_MARKER+i);
            uUnit.CommandSetMovementMode(modeHoldPos);
            AddBigAntiMieszkoDamage(uUnit);
            SetUnitImmortal(BOSS_MARKER+i);
            SetUnitMaskedScriptData(uUnit, PATH_MASK, FIRST_MARKER_TO_REACH_CENTER);

            if(i != 0)
            {
                uSmoke = CreateObjectAtUnit(uUnit, "SMOKE_SHIELD_EFFECT1");
                uSmoke.SetSmokeObject(uUnit.GetUnitRef(), true, true, true, true);
                uSmoke = CreateObjectAtUnit(uUnit, "SMOKE_SHIELD_EFFECT2");
                uSmoke.SetSmokeObject(uUnit.GetUnitRef(), true, true, true, true);
            }
            else
            {
                uSmoke = CreateObjectAtUnit(uUnit, "SMOKE_GE_PORTAL_EFFECT_M1");
                uSmoke.SetSmokeObject(uUnit.GetUnitRef(), true, true, true, true);
            }
        }
    }

    state Initialize
    {
        player rPlayer;
        int i, j;
        unitex uUnit;

        int iXTranslateFront;
        int iYTranslateFront;
        int iXTranslateRight;
        int iYTranslateRight;

        int iAlpha;
        
        iExtraHut = 0;

        iCurrentWaveNumber = 1;

        bWaveActive = false;
        bIsFinalWave = false;


        // Ustawiamy czas rozpoczęcia przerwy do przodu, aby na starcie było więcej czasu na przygotowania
        iBreakTimeStart = GetMissionTime() + 7 * MINUTE;
        iBreakTimeStart = iBreakTimeStart - 40 * SECOND * (comboDifficulty - 2);

        InitXorShiftRNG(Rand(10000) + iBreakTimeStart + 10*comboWaveNumber + 100*comboStarter + 1000*comboDifficulty);
        iRewardSeed = RandXor(1000000);

        InitAiPlayers();
        InitHumanPlayers();
        SetDifficulty();
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);
        SetTotalWaveNumber();
        InitBossWaveTypes();  
        SetWaveType();
        
        InitRewards();
        InitCreateRewardInfo();

        CreatePortalArtifact();
        CreateNextWaveTrigger();
        CreateRemoveArtefactsTrigger();
        CreatePerunRageTrigger();
        CreateExtraBreakTimeTrigger();

        InitFinalBoss();

        InitializeMarkerFunctions();
        EnableAssistant(0xffffff, false);

        for(i=0; i<3; i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null) 
            {
                CheckMilkPool(8);
                rPlayer.SetMoney(100);
                rPlayer.SetScriptData(PLAYER_STAGE, STAGE_WITHOUT_BUILDINGS);
                ShowAreaAtMarker(rPlayer.GetIFF(), i, 20);
                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);
                SetGoal(rPlayer);
                

                iAlpha = GetPointAlpha(i);
                iXTranslateFront = GetXInFront(iAlpha);
                iYTranslateFront = GetYInFront(iAlpha);
                iXTranslateRight = GetXToRight(iAlpha);
                iYTranslateRight = GetYToRight(iAlpha);

                uUnit = rPlayer.CreateUnit(
                    GetPointX(i) + 7 * iXTranslateFront, 
                    GetPointY(i) + 7 * iYTranslateFront, 
                    GetPointZ(i), 
                    GetPointAlpha(i), 
                    "WOODCUTTER"
                );
                CreateObjectAtUnit(uUnit, "HIT_TELEPORT");
                uUnit = rPlayer.CreateUnit(
                    GetPointX(i) + 7 * iXTranslateFront + 1 * iXTranslateRight, 
                    GetPointY(i) + 7 * iYTranslateFront + 1 * iYTranslateRight, 
                    GetPointZ(i), 
                    GetPointAlpha(i), 
                    "WOODCUTTER"
                );
                CreateObjectAtUnit(uUnit, "HIT_TELEPORT");
                uUnit = rPlayer.CreateUnit(
                    GetPointX(i) + 6 * iXTranslateFront, 
                    GetPointY(i) + 6 * iYTranslateFront, 
                    GetPointZ(i), 
                    GetPointAlpha(i), 
                    "COW"
                );
                CreateObjectAtUnit(uUnit, "HIT_TELEPORT");
                uUnit = rPlayer.CreateUnit(
                    GetPointX(i) + 6 * iXTranslateFront + 1 * iXTranslateRight, 
                    GetPointY(i) + 6 * iYTranslateFront + 1 * iYTranslateRight, 
                    GetPointZ(i), 
                    GetPointAlpha(i), 
                    "COW"
                );
                CreateObjectAtUnit(uUnit, "HIT_TELEPORT");

            }
        }


        if(PointExists(REWARDS_MARKER))
            AddWorldMapSign(GetPointX(REWARDS_MARKER), GetPointY(REWARDS_MARKER), 0, 0, 1200);
        if(PointExists(CONTROL_BUTTONS_MARKER))
            AddWorldMapSign(GetPointX(CONTROL_BUTTONS_MARKER), GetPointY(CONTROL_BUTTONS_MARKER), 0, 2, 1200);

        CleanUpArtefacts(0);
        CleanUpArtefacts(0);
        CleanUpArtefacts(1);
        CleanUpArtefacts(1);

        CreateStarters();
        UpdatedPlayersAfterWave();

        SetTimer(0, 10);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 5*SECOND); // AI
        SetTimer(2, 5); // Logika
        SetTimer(3, 5); // Detonacja bomberów
        // Timery od efektów pogodowych
        SetTimer(4, 60*SECOND);
        SetTimer(7, GetWindTimerTicks());
        StartWind();

        InitializeStatistics();

        return Nothing;
    }


    event UseExtraSkirmishPlayers()
    {
        return true;
    }

    event SpecialLevelFlags()
    {
	    return 32;
    }

    event AIPlayerFlags()
    {
        return false;
    }

    event RemoveUnits()
    {
        return true;
    }

    event SetupInterface()
    {
        SetInterfaceOptions(
            lockToolbarSwitchMode |
            lockToolbarAlliance | 
            lockToolbarLevelName |
            lockToolbarMoney |
            lockToolbarHelpMode |
            lockDisplayToolbarMoney |
            0);
    }
        
    command Initialize()
    {
        comboStarter = 0;
        comboDifficulty = 0;
        return true;
    }
    
    command Uninitialize()
    {
        return true;
    }
        
    command Combo1(int nMode) button comboStarter 
    {
        comboStarter = nMode;
        return true;
    }

    command Combo2(int nMode) button comboDifficulty
    {
        comboDifficulty = nMode;
        return true;
    }
    
    command Combo3(int nMode) button comboWaveNumber
    {
        comboWaveNumber = nMode;
        return true;
    }
}

