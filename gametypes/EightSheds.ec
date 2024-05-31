mission "translateGameTypeEightSheds"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\Teleports.ech"
    #include "Common\StartingUnits.ech"
    
    state Initialize
    {
        player rPlayer;
        int i;
        int j;

        // SZYBSZA TRAWKA
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);
        
        // TELEPORTY 
        CreateTeleportsAndSwitches();

        // SOJUSZE
        CreateTeamsFromComboButton(comboAlliedVictory);
        // SOJUSZE

        // Wyłączenie podpowiedzi
        EnableAssistant(0xffffff, false);

        // Czary dla gracza 14, czyli od czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Nieskończony milk pool dla gracza 14 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnablePlayer14Milk();

        for(i=0; i<8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                if(rPlayer.IsAI())
                {
                    /* boty na start dostają bonus mleka, ponieważ czasem startując z 2 drwalami i z 2 krowami, 
                       kupują na start drogę :> */
                    rPlayer.SetMaxMoney(800);
                    rPlayer.SetMoney(400);
                }
                else
                {
                    rPlayer.SetMoney(100);
                    CheckMilkPool(8);        
                }

                rPlayer.SetScriptData(0, 0);

                rPlayer.SetMaxCountLimitForObject("COWSHED", 8);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);

                RegisterGoal(0, "translateEightShedsGoal");
                EnableGoal(0, true);

                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    CreateStartingUnits(rPlayer, comboStartingUnits, true);
            }
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

        // Efekty pogodowe
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
        CheckMilkPool(8);

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
