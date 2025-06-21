mission "translateZeroupgrades"
{
    #include "Common\Consts.ech"
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\StartingUnits.ech"
    #include "Common\Events.ech"
    
    state Initialize
    {
        player rPlayer;
        int i;
        int j;
    
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);

        // Wyłączenie podpowiedzi
        EnableAssistant(0xffffff, false);

        // Czary dla gracza 14, czyli od czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Nieskończony milk pool dla gracza 14 i 15 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnableExtraSkirmishPlayersMilkPool();

        for(i=0; i < 8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer==null)
                continue;

            if(rPlayer.IsAI())
            {
                rPlayer.SetMaxMoney(400);
                rPlayer.SetMoney(400);
            }
            else
            {
                rPlayer.SetMoney(100);    
                CheckMilkPool(4);    
            }

            rPlayer.SetScriptData(PLAYER_STAGE, STAGE_WITHOUT_BUILDINGS);

            RegisterGoal(0, "translateZeroUpgradesGoal");
            EnableGoal(0, true, true);

            // Ulepszenia - GE
            
            rPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST"            , false);
            rPlayer.EnableResearchUpdate("AUTOSPELL_WITCH"             , false);
            rPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS", false);
            rPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL"          , false);
            rPlayer.ResearchUpdate("SPELL_SHIELD"               );
            rPlayer.ResearchUpdate("SPELL_CAPTURE"               );
            rPlayer.ResearchUpdate("SPELL_STORM"                 );
            rPlayer.ResearchUpdate("SPELL_CONVERSION"            );
            rPlayer.ResearchUpdate("SPELL_FIRERAIN"              );
            rPlayer.ResearchUpdate("SPELL_SEEING"                );
            rPlayer.ResearchUpdate("SPELL_TELEPORTATION"         );
            rPlayer.ResearchUpdate("SPELL_GHOST"                 );
            rPlayer.ResearchUpdate("SPELL_WOLF"                  );
            
            rPlayer.EnableResearchUpdate("SPEAR1"  , false);
            rPlayer.EnableResearchUpdate("BOW1"    , false);
            rPlayer.EnableResearchUpdate("SWORD1" , false);
            rPlayer.EnableResearchUpdate("AXE1"    , false);
            rPlayer.EnableResearchUpdate("SHIELD1" , false);
            rPlayer.EnableResearchUpdate("ARMOUR1" , false);
            rPlayer.EnableResearchUpdate("HELMET1", false);

            // Budynki - GE
            
            rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
            rPlayer.SetMaxCountLimitForObject("COURT", 1);
            

            rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(), 6, 32, 20, 0);
            if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                CreateStartingUnits(rPlayer, comboStartingUnits, false);
        }

        // SOJUSZE
        CreateTeamsFromComboButton(comboAlliedVictory);
        AiChooseEnemy();
        // SOJUSZE
        // TELEPORTY
        InititializeMissionScripts();
        InitializeMarkerFunctions();
        // TELEPORTY

        SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 20*SECOND); // Artefakty
        SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.
        
        // Efektywne czary dla najtrudniejszych botów i eventy markerów i misji
        SetTimer(3, SECOND);

        SetTimer(4, 60*SECOND);
        SetTimer(7, GetWindTimerTicks());
        StartWind();

        InitializeStatistics();

        return Nothing;
    }
    
    event RemoveUnits()
    {
        if(comboStartingUnits) return true;
        return false;

    }
    
    event SetupInterface()
    {
        SetInterfaceOptions(
            lockResearchUpdates|
            lockToolbarSwitchMode |
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

        if ( state != Nothing ) return;

        // Sprawdzamy ile obór mają gracze i ile maksymalnie mleka mogą mieć
        CheckMilkPool(4);

        // Sprawdzamy, czy gracz został pokonany. Zmienna określa czy jakikolwiek gracz został wyeliminowany z mapy.
        bOneHasBeenDestroyed = CheckIfPlayerWasDestroyed(true);

        // Sprawdzamy, czy na mapie został jeden team/gracz
        bActiveEnemies = CheckIfActiveEnemiesExist(comboAlliedVictory);

        if(bActiveEnemies) return;
        if(!bOneHasBeenDestroyed) return;
        
        SetStateDelay(150);
        state Victory;
    }
    
    event Timer1()
    {
        MakeEquipmentFromTimeToTime(comboArtifacts, false);
    }

    event Timer2()
    {
        AiChooseEnemy();
    }

    // Ta flaga wybiera mapy, na których dany tryb może być grany. 0x01 = 1 oznacza ustawienie `Wojny Wiosek` w edytorze.
    // 2, to bitwa, a 4 to RPG. Inne ustawienia wymagają ustawienia flagi bezpośrednio w pliku mapy.
    event SpecialLevelFlags()
    {
        return 1;
    }

    command Initialize()
    {
        comboAlliedVictory=1;
        comboArtifacts=3;
        comboStartingUnits=0;
        return true;
    }
    
    command Uninitialize()
    {
        return true;
    }
        
    command Combo1(int nMode) button comboStartingUnits 
    {
        comboStartingUnits = nMode;
        return true;
    }
    command Combo2(int nMode) button comboAlliedVictory
    {
        comboAlliedVictory = nMode;
        return true;
    }
    
    command Combo3(int nMode) button comboArtifacts
    {
        comboArtifacts = nMode;
        return true;
    }
}

