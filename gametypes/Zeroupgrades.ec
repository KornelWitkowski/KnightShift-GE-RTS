mission "translateZeroupgrades"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\MarkerFunctions.ech"
    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\StartingUnits.ech"
    
    state Initialize
    {
        player rPlayer;
        int i;
        int j;
    
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);
        
        CreateTeleportsAndSwitches();

        // Wyłączenie podpowiedzi
        EnableAssistant(0xffffff, false);

        // Czary dla gracza 14, czyli od czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Nieskończony milk pool dla gracza 14 i 15 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnableExtraSkirmishPlayersMilkPool();

        for(i=0; i < 8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
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

                rPlayer.SetScriptData(0, 0);

                RegisterGoal(0, "translateZeroUpgradesGoal");
                EnableGoal(0, true);

                // Ulepszenia - GE
                
                rPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST"            , false); // 0
                rPlayer.EnableResearchUpdate("AUTOSPELL_WITCH"             , false); // 0
                rPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS", false); // 0
                rPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL"          , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_SHIELD"                , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_CAPTURE"               , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_STORM"                 , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_CONVERSION"            , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_FIRERAIN"              , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_SEEING"                , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_TELEPORTATION"         , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_GHOST"                 , false); // 0
                rPlayer.EnableResearchUpdate("SPELL_WOLF"                  , false); // 0
                
                rPlayer.EnableResearchUpdate("SPEAR1"  , false); // 0
                rPlayer.EnableResearchUpdate("BOW1"    , false); // 0
                rPlayer.EnableResearchUpdate("SWORD1" , false); // 0
                rPlayer.EnableResearchUpdate("AXE1"    , false); // 0
                rPlayer.EnableResearchUpdate("SHIELD1" , false); // 0
                rPlayer.EnableResearchUpdate("ARMOUR1" , false); // 0
                rPlayer.EnableResearchUpdate("HELMET1", false); // 0

                // Budynki - GE
                
                rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);
                

                rPlayer.LookAt(rPlayer.GetStartingPointX(),rPlayer.GetStartingPointY(), 6, 32, 20, 0);
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    CreateStartingUnits(rPlayer, comboStartingUnits, false);
            }
        }

        // SOJUSZE
        CreateTeamsFromComboButton(comboAlliedVictory);
        AiChooseEnemy();
        // SOJUSZE

        SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 20*SECOND); // Artefakty
        SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

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

