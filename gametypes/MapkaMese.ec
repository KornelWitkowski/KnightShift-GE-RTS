mission "MapkaMese"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Missions.ech"
    #include "Common\MarkerFunctions.ech"
    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\StartingUnits.ech"

    int bMercDestroyed;

    player rPlayer2, rPlayer11, rPlayer12, rPlayer13, rPlayer14, rPlayer15;

    unitex uHero;
    int bPeasantTaken;
    unitex uPeasant1, uPeasant2, uPeasant3, uPeasantLeader;
    unitex uMerc1, uMerc2, uMerc3, uMerc4, uMerc5, uMerc6;
    unitex uPeasantLeaderSmoke;

    function void InitializeMecenaries()
    {
        bMercDestroyed = false;
        bPeasantTaken = false;
        uMerc1 = GetUnitAtMarker(11);
        uMerc2 = GetUnitAtMarker(12);
        uMerc3 = GetUnitAtMarker(13);
        uMerc4 = GetUnitAtMarker(14);
        uMerc5 = GetUnitAtMarker(15);
        uMerc6 = GetUnitAtMarker(16);

        uPeasant1 = GetUnitAtMarker(7);
        uPeasant2 = GetUnitAtMarker(8);
        uPeasant3 = GetUnitAtMarker(9);
        uPeasantLeader = GetUnitAtMarker(10);
        
        // SetRealImmortal(uPeasant1);
        // SetRealImmortal(uPeasant2);
        // SetRealImmortal(uPeasant3);
        // SetRealImmortal(uPeasantLeader);
    }

    function int CheckIfMercenariesKilled()
    {
        if(IsAlive(uMerc1)) return false;
        if(IsAlive(uMerc2)) return false;
        if(IsAlive(uMerc3)) return false;
        if(IsAlive(uMerc4)) return false;
        if(IsAlive(uMerc5)) return false;
        if(IsAlive(uMerc6)) return false;
        return true;
    }

    state Initialize
    {
        player rPlayer;
        int i;
        int j;

        

        rPlayer2  =  GetPlayer(2 - 1);
        rPlayer11 = GetPlayer(11 - 1);
        rPlayer12 = GetPlayer(12 - 1);
        rPlayer13 = GetPlayer(13 - 1);
        rPlayer14 = GetPlayer(14 - 1);
        rPlayer15 = GetPlayer(15 - 1);

        rPlayer2.SetNeutral(rPlayer12);
        rPlayer2.SetNeutral(rPlayer14);

        rPlayer2.SetEnemy(rPlayer11);
        rPlayer2.SetEnemy(rPlayer13);

        rPlayer14.SetNeutral(rPlayer2);
        rPlayer14.SetNeutral(rPlayer11);
        rPlayer14.SetNeutral(rPlayer12);
        rPlayer14.SetNeutral(rPlayer15);

        rPlayer14.SetEnemy(rPlayer13);

        rPlayer13.SetNeutral(rPlayer15);

        rPlayer13.SetEnemy(rPlayer2);
        rPlayer13.SetEnemy(rPlayer11);
        rPlayer13.SetEnemy(rPlayer12);
        rPlayer13.SetEnemy(rPlayer14);

        rPlayer11.SetNeutral(rPlayer14);
        rPlayer11.SetNeutral(rPlayer15);

        rPlayer11.SetEnemy(rPlayer2);
        rPlayer11.SetEnemy(rPlayer12);
        rPlayer11.SetEnemy(rPlayer13);

        rPlayer15.SetNeutral(rPlayer11);
        rPlayer15.SetNeutral(rPlayer13);
        rPlayer15.SetNeutral(rPlayer14);

        rPlayer15.SetEnemy(rPlayer2);
        rPlayer15.SetEnemy(rPlayer12);

        rPlayer12.SetNeutral(rPlayer2);
        rPlayer12.SetNeutral(rPlayer14);
        
        rPlayer12.SetEnemy(rPlayer11);
        rPlayer12.SetEnemy(rPlayer13);
        rPlayer12.SetEnemy(rPlayer15);


        uHero = GetUnitAtMarker(0);
        InitializeMecenaries();

    
        /* Ilość mleka z trawki i prędkość wzrostu. Pierwsza wartość im większa tym krowa dostaje więcej mleka z jednego gryza
           Druga wartość to bardziej 'rate' niż 'speed'. Im mniejsza tym szybciej trawa rośnie.
           Jak ustawimy 1 to trawa w ogóle nie znika. */
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

                // W ScriptData(0) zapisujemy informacje, czy gracz zbudował jakieś budynki. Wstępnie 0, czyli brak budynków.
                rPlayer.SetScriptData(0, 0);

                rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);

                // Cele misji
                RegisterGoal(0, "translateDestroyEnemyStrucuresGoal");
                EnableGoal(0, true);

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

        // Timery, czy wydarzenia, które są wywoływane co jakiś czas, aby sprawdzić stan gry i dokonywać pewnych zmian.
        SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
        SetTimer(1, 1*SECOND); // Artefakty
        SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

        // Efektywne czary dla najtrudniejszych botów
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
        if(!bMercDestroyed)
        {
            bMercDestroyed = CheckIfMercenariesKilled();
            // SetConsoleText("mercdestroyed <%0>", bMercDestroyed);
            if(bMercDestroyed)
            {
                uPeasantLeaderSmoke = CreateObjectAtUnit(uPeasantLeader, "PART_TALK");
                uPeasantLeaderSmoke.SetSmokeObject(uPeasantLeader.GetUnitRef(), true, true, true, true);
            }
        }
        else if (!bPeasantTaken)
        {
            // SetConsoleText("dystans: <%0>", uPeasantLeader.DistanceTo(uHero.GetLocationX(), uHero.GetLocationY()));
            if(uPeasantLeader.DistanceTo(uHero.GetLocationX(), uHero.GetLocationY()) <= 2)
            {
                uPeasantLeaderSmoke.RemoveUnit();
                uPeasantLeader.ChangePlayer(rPlayer2);
                uPeasant1.ChangePlayer(rPlayer2);
                uPeasant2.ChangePlayer(rPlayer2);
                uPeasant3.ChangePlayer(rPlayer2);
                bPeasantTaken = true;
            }
        }
    }


    command Uninitialize()
    {
        return true;
    }
        

}
