mission "translateTowerDefense"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\StartingUnits.ech"

    #include "TowerDefense\Starters.ech"
    #include "TowerDefense\Buildings.ech"
    #include "TowerDefense\Research.ech"
    #include "TowerDefense\Rewards.ech"
    #include "TowerDefense\Waves.ech"
    #include "TowerDefense\Ai.ech"

    int bTemp;

    enum comboDifficulty
    {    
        "translateDifficultyNovice",
        "translateDifficultyMedium",
        "translateDifficultyVeteran",
            multi:
        "translateTowerDefenseStarter"
    }

    int bWaveActive;
    int iBreakTime, iBreakTimeStart;
    int iWaveTimeStart;
    int iNumberOfUnitsToSpawn;
    int iWaveNumber;
    int iWaveType;

    unitex uUnit;
    player rPlayer8, rPlayer9, rPlayer10, rPlayer11, rPlayer14;

    function void InitAiPlayers()
    {
        rPlayer8 = GetPlayer(8);
        rPlayer9 = GetPlayer(9);
        rPlayer10 = GetPlayer(10);
        rPlayer11 = GetPlayer(11);
        rPlayer14 = GetPlayer(14);

        SetAlly(rPlayer8, rPlayer9);
        SetAlly(rPlayer8, rPlayer10);
        SetAlly(rPlayer8, rPlayer11);
        SetAlly(rPlayer8, rPlayer14);

        SetAlly(rPlayer9, rPlayer10);
        SetAlly(rPlayer9, rPlayer11);
        SetAlly(rPlayer9, rPlayer14);

        SetAlly(rPlayer10, rPlayer11);
        SetAlly(rPlayer10, rPlayer14);

        SetAlly(rPlayer11, rPlayer14);


        rPlayer8.ResearchUpdate("SPELL_WOLF");
        rPlayer8.ResearchUpdate("SPELL_SEEING");
        rPlayer8.ResearchUpdate("SPELL_GHOST");
        rPlayer8.ResearchUpdate("SPELL_TELEPORTATION");

        rPlayer8.ResearchUpdate("SPELL_SHIELD");
        rPlayer8.ResearchUpdate("SPELL_CAPTURE");
        rPlayer8.ResearchUpdate("SPELL_STORM");
        rPlayer8.ResearchUpdate("SPELL_CONVERSION");
        rPlayer8.ResearchUpdate("SPELL_FIRERAIN");

        rPlayer9.ResearchUpdate("SPELL_WOLF4");
        rPlayer9.ResearchUpdate("SPELL_SEEING4");
        rPlayer9.ResearchUpdate("SPELL_GHOST4");
        rPlayer9.ResearchUpdate("SPELL_TELEPORTATION4");

        rPlayer9.ResearchUpdate("SPELL_SHIELD4");
        rPlayer9.ResearchUpdate("SPELL_CAPTURE4");
        rPlayer9.ResearchUpdate("SPELL_STORM4");
        rPlayer9.ResearchUpdate("SPELL_CONVERSION4");
        rPlayer9.ResearchUpdate("SPELL_FIRERAIN4");

        rPlayer9.ResearchUpdate("AUTOSPELL_PRIEST5");
        rPlayer9.ResearchUpdate("AUTOSPELL_FIREBALL5");
        rPlayer9.ResearchUpdate("AUTOSPELL_WITCH5");
        rPlayer10.ResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS5");

        rPlayer9.ResearchUpdate("HELMET3");
        rPlayer9.ResearchUpdate("SWORD3");
        rPlayer9.ResearchUpdate("SPEAR5");
        rPlayer9.ResearchUpdate("AXE5");
        rPlayer9.ResearchUpdate("BOW5");
        rPlayer9.ResearchUpdate("ARMOUR3A");
        rPlayer9.ResearchUpdate("SHIELD2D");

        // uSmoke = CreateObjectAtUnit(uUnit, "ARTIFACT_SHIELD_EFFECT3");
        // uSmoke.SetSmokeObject(uUnit.GetUnitRef(), true, true, true, true);

        uUnit = GetUnitAtMarker(50);
        uUnit.CommandSetMovementMode(modeHoldPos);
        SetUnitImmortal(50);
    }

    state Initialize
    {
        player rPlayer;
        int i, j;
        
        iExtraHut = 0;

        iWaveNumber = 1;
        bWaveActive = false;

        // Ustawiamy czas rozpoczęcia przerwy do przodu, aby na starcie było więcej czasu na przygotowania
        iBreakTimeStart = GetMissionTime() -  2 * MINUTE - 30 * SECOND;

        InitAiPlayers();
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);
        
        InitializeMarkerFunctions();
        EnableAssistant(0xffffff, false);

        for(i=0; i<8; i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null) 
            {
                CheckMilkPool(8);    // Sprawdzamy liczbę obór gracza i ustawiamy ilość mleka
                rPlayer.SetMoney(100);

                // W ScriptData(0) zapisujemy informacje, czy gracz zbudował jakieś budynki. Wstępnie 0, czyli brak budynków.
                rPlayer.SetScriptData(0, 0);

                // Cele misji
                RegisterGoal(0, "translateDestroyEnemyStrucuresGoal");
                EnableGoal(0, true);

                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

                // Postacie początkowe na mapie
                CreateStarters(rPlayer, 4 + i * 4);
                UpdateResearchAfterWave(rPlayer, 1);
                UpdateBuildingsAfterWave(rPlayer, 1);
            }
        }

        // Timery, czy wydarzenia, które są wywoływane co jakiś czas, aby sprawdzić stan gry i dokonywać pewnych zmian.
        SetTimer(0, SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 5*SECOND); // Artefakty
        SetTimer(2, 10);

        // Efektywne czary dla najtrudniejszych botów
        SetTimer(3, SECOND);

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
	    // return 8;
       return 0x01;
    }

    event AIPlayerFlags()
    {
        return false;
    }

    event RemoveUnits()
    {
        return false;
    }

    event Timer4()
    {
        MakeWeather();
    }

    event Timer7()
    {
        StartWind();
    }

    event Artefact(int iArtefactNum, unitex uUnitOnArtefact, player rPlayerOnArtefact)
    {
        return MarkerFunctionsEventArtefact(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
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
        
    event Timer0()
    {
        int bActiveEnemies;
        int bOneHasBeenDestroyed;

        // Jeśli state to Victory lub Defeat to nie ma potrzeby sprawdzać
        if ( state != Nothing ) return;

        // Sprawdzamy ile obór mają gracze i ile maksymalnie mleka mogą mieć
        CheckMilkPool(8);

        // Sprawdzamy, czy gracz został pokonany.
        CheckIfPlayerWasDestroyed(true);
    }
    
    event Timer1()
    {
        int i;
        player rPlayer;
        
        for(i=8; i<12; i=i+1)
        {
            rPlayer = GetPlayer(i);
            AttackPlayer(rPlayer);
        }
    }

    event Timer2()
    {

        player rPlayer, rPlayerEnemy1, rPlayerEnemy2;
        int bSpawned;
        int iCurrentTime;
        iCurrentTime = GetMissionTime();

        rPlayer = GetPlayer(0);
        rPlayerEnemy1 = GetPlayer(9);
        rPlayerEnemy2 = GetPlayer(11);

        if(bWaveActive && iNumberOfUnitsToSpawn > 0)
        {
            bSpawned = SpawnUnit(iWaveType, iWaveNumber);
            SetConsoleText("Do spawnowania: <%0> Udany: <%1>, Wave type: <%2>", iNumberOfUnitsToSpawn, bSpawned, iWaveType);
            if(bSpawned)
            {
                iNumberOfUnitsToSpawn = iNumberOfUnitsToSpawn - 1;
            }
        }
        else if(bWaveActive)
        {
            if ((iCurrentTime - iWaveTimeStart) > ( 4 *MINUTE) || (rPlayerEnemy1.GetNumberOfUnits() == 0 && rPlayerEnemy2.GetNumberOfUnits() == 0 && iNumberOfUnitsToSpawn == 0))
            {
                bWaveActive = false ;
                iBreakTimeStart = GetMissionTime();
                GiveRewards(iWaveNumber);
                UpdateResearchAfterWave(rPlayer, iWaveNumber);
                UpdateBuildingsAfterWave(rPlayer, iWaveNumber);
            }
            else
            {
                SetConsoleText("Pozostalo do pokonania <%0> przeciwnikow",  rPlayerEnemy1.GetNumberOfUnits() + rPlayerEnemy2.GetNumberOfUnits());
            }
        }
        else
        {
            if ((iCurrentTime - iBreakTimeStart) > ( 3 *MINUTE))
            {
                iWaveType = RAND(6);
                iNumberOfUnitsToSpawn = GetUnitNumber(iWaveType, iWaveNumber);
                iWaveNumber = iWaveNumber + 1;
                bWaveActive = true;
                // SetConsoleText("");
                iWaveTimeStart =  GetMissionTime();
            }
            else
            {
                SetConsoleText("Do fali <%0> pozostalo <%1>", iWaveNumber, (iBreakTimeStart + (3* MINUTE) - iCurrentTime) / (SECOND) + 30);
            }
        }
    }

    event Timer3()
    {
        int i;
        player rPlayer;

        for(i=8; i<12; ++i)
        {
            rPlayer = GetPlayer(i);

            if(rPlayer == null)
                continue;

            if(rPlayer.IsAI())
            {
                UseMagic(rPlayer);
            }
        }
    }

    event Timer5()
    {
        
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
    
    // command Combo3(int nMode) button comboArtifacts
    // {
    //     comboArtifacts = nMode;
    //     return true;
    // }
}
