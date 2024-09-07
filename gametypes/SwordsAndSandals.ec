mission "translateSwordsandsandals"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\StartingUnits.ech"

    function void RemoveMagicUnits()
    {
        player rPlayer;
        int i;
        int j;
        int iNumberOfUnits;
        unitex uUnit;

        rPlayer = GetPlayer(i);
        uUnit = rPlayer.GetScriptUnit(0);

        for(i=0; i<8; i=i+1)
        {
            rPlayer=GetPlayer(i);

            if(rPlayer==null)
                continue; 

            iNumberOfUnits = rPlayer.GetNumberOfUnits();
            for(j=0; j<iNumberOfUnits; j=j+1)
            {
                // iterujemy od ostatniego unita, żeby nie zmieniać kolejności indeksów unitów
                // w przeciwnym wypadku jeślibyśmy usuneli jednostkę o indeksie 0, to jednostka z indeksem 1 dostała by nowy indeks 0.
                uUnit = rPlayer.GetUnit(iNumberOfUnits-j-1);
                if(uUnit.GetMaxMagic() > 0)
                    uUnit.RemoveUnit();
            }
        }
    }

    state Initialize
    {
        player rPlayer;
        int i;
        int j;
        int iNumberOfUnits;
        unitex uUnit;
    
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
        
        for(i=0; i<8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer==null)
                continue; 

            if(rPlayer.IsAI())
            {
                // boty na start dostają bonus mleka, ponieważ czasem startując z 2 drwalami i z 2 krowami, kupują na start drogę zamiast obory :>
                rPlayer.SetMaxMoney(400);
                rPlayer.SetMoney(400);
            }
            else
            {
                CheckMilkPool(4);    
                rPlayer.SetMoney(100);    
            }

            RegisterGoal(0, "translateSwordsAndSandalsGoal");
            EnableGoal(0, true);

            rPlayer.SetScriptData(0, 0);

            // Budynki - GE
            
            rPlayer.SetMaxCountLimitForObject("TEMPLE", 0);
            rPlayer.SetMaxCountLimitForObject("SHRINE", 0);
            rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
            rPlayer.SetMaxCountLimitForObject("COURT", 2);
            
            // Postacie - GE
            
            rPlayer.SetMaxCountLimitForObject("SORCERER", 0);
            rPlayer.SetMaxCountLimitForObject("PRIESTESS", 0);
            rPlayer.SetMaxCountLimitForObject("PRIEST", 0);
            rPlayer.SetMaxCountLimitForObject("WITCH", 0);

            rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);
            if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                CreateStartingUnits(rPlayer, comboStartingUnits, false);

        }

        RemoveMagicUnits();

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
        comboAlliedVictory = 1;
        comboArtifacts = 3;
        comboStartingUnits = 0;
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
