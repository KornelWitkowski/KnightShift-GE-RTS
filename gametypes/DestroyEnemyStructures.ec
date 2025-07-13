mission "translateGameTypeDestroyStructures"
{
    #include "Common\Consts.ech"
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\Alliance.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\StartingUnits.ech"

    state Initialize
    {
        player rPlayer;
        int i;
        int j;
    
        /* Ilość mleka z trawki i prędkość wzrostu. Pierwsza wartość im większa tym krowa dostaje więcej mleka z jednego gryza
           Druga wartość to bardziej 'rate' niż 'speed'. Im mniejsza tym szybciej trawa rośnie.
           Jak ustawimy 1 to trawa w ogóle nie znika. */
        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);
        
        TurnOffTier5Items();
        // Wyłączenie podpowiedzi
        EnableAssistant(0xffffff, false);

        // Czary dla gracza 14, czyli czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Bardzo duży milk pool dla gracza 14 i 15 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnableExtraSkirmishPlayersMilkPool();

        for(i=0; i<8; i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null) 
            {
                if(rPlayer.IsAI())
                {
                    /* boty na start dostają bonus mleka, ponieważ czasem startując z 2 drwalami i z 2 krowami,
                     kupują na start drogę :> */
                    rPlayer.SetMaxMoney(400);
                    rPlayer.SetMoney(400);
                }
                else
                {
                    CheckMilkPool(4);    // Sprawdzamy liczbę obór gracza i ustawiamy ilość mleka
                    rPlayer.SetMoney(100);
                }

                rPlayer.SetScriptData(PLAYER_STAGE, STAGE_WITHOUT_BUILDINGS);

                rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);

                // Cele misji
                RegisterGoal(0, "translateDestroyEnemyStrucuresGoal");
                EnableGoal(0, true, true);

                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

                // Postacie początkowe na mapie
                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    CreateStartingUnits(rPlayer, comboStartingUnits, true);
            }
        }

        // SOJUSZE
        CreateTeamsFromComboButton(comboAlliedVictory);
        AiChooseEnemy();
        // SOJUSZE
        InititializeMissionScripts();
        InitializeMarkerFunctions();


        // Timery, czy wydarzenia, które są wywoływane co jakiś czas, aby sprawdzić stan gry i dokonywać pewnych zmian.
        SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 20*SECOND); // Artefakty
        SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

        // Efektywne czary dla najtrudniejszych botów i eventy markerów i misji
        SetTimer(3, SECOND);

        // Timery od efektów pogodowych
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

        // Jeśli state to Victory lub Defeat to nie ma potrzeby sprawdzać
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
        /* Losowe tworzenie artefaktów na mapie. Prawodpobieństwo, czy zostanie
         stworzony artefakt, zależy od liczby graczy, rozmiaru mapy. */
        MakeEquipmentFromTimeToTime(comboArtifacts, true);
    }

    event Timer2()
    {
        /* Funkcja wybiera głównego przeciwnika dla graczy AI. Główny przeciwnik jest wybierany
         na początku gry i po pokonaniu wroga, ale także może być zmieniony w czasie gry.
         Sprawia to, że gracze AI są mniej przewidywalni */
        AiChooseEnemy();
    }

    // Ta flaga wybiera mapy, na których dany tryb może być grany. 0x01 = 1 oznacza ustawienie `Wojny Wiosek` w edytorze.
    // 2, to bitwa, a 4 to RPG. Inne ustawienia wymagają ustawienia flagi bezpośrednio w pliku mapy.
    event SpecialLevelFlags()
    {
        return 0x01;
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
