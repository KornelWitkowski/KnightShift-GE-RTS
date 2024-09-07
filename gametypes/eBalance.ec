mission "translateBalance"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
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
        
        InitializeMarkerFunctions();
        InititializeMissionScripts();

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
                // boty na start dostają bonus mleka, ponieważ czasem startując z 2 drwalami i z 2 krowami, kupują na start drogę :>
                rPlayer.SetMaxMoney(400);
                rPlayer.SetMoney(400);
            }
            else
            {
                CheckMilkPool(4);
                rPlayer.SetMoney(100);        
            }

            rPlayer.SetScriptData(0, 0);

            RegisterGoal(0, "translateBalanceGoal");
            EnableGoal(0, true);

            rPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST4"            , false); // 2
            rPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL4"          , false); // 2
            rPlayer.EnableResearchUpdate("SPELL_SHIELD3"                , false); // 2
            rPlayer.EnableResearchUpdate("SPELL_CAPTURE2"               , false); // 1
            rPlayer.EnableResearchUpdate("SPELL_STORM2"                 , false); // 1
            rPlayer.EnableResearchUpdate("SPELL_CONVERSION2"            , false); // 1
            rPlayer.EnableResearchUpdate("SPELL_FIRERAIN2"              , false); // 1
            rPlayer.EnableResearchUpdate("SPELL_SEEING3"                , false); // 2
            rPlayer.EnableResearchUpdate("SPELL_TELEPORTATION3"         , false); // 2
            rPlayer.EnableResearchUpdate("SPELL_GHOST3"                 , false); // 2
            rPlayer.EnableResearchUpdate("SPELL_WOLF2"                  , false); // 1

            // Budynki - GE
            
            rPlayer.SetMaxCountLimitForObject("TEMPLE", 2);
            rPlayer.SetMaxCountLimitForObject("SHRINE", 2);
            rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
            rPlayer.SetMaxCountLimitForObject("COURT", 1);
            
            // Postacie - GE
            
            rPlayer.SetMaxCountLimitForObject("SORCERER", 8);
            rPlayer.SetMaxCountLimitForObject("PRIESTESS", 4);
            rPlayer.SetMaxCountLimitForObject("PRIEST", 4);
            rPlayer.SetMaxCountLimitForObject("WITCH", 8);

            rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

            if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                CreateStartingUnits(rPlayer, comboStartingUnits, true);
        }

        // SOJUSZE
        CreateTeamsFromComboButton(comboAlliedVictory);
        AiChooseEnemy();
        // SOJUSZE

        SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 20*SECOND); // Artefakty
        SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

        // Efektywne czary dla najtrudniejszych botów
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
        MakeEquipmentFromTimeToTime(comboArtifacts, true);
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

