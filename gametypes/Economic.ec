mission "translateEconomic"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Events.ech"
    #include "Common\Teleports.ech"

	// ECONOMIC
    enum comboMilkToWin
    {
        "5000",
        "10000",
	    "20000",
	    "50000",
	    "100 000",
        "200 000",
        "500 000",
			multi:
        "translateMilkToWin"
    }

    enum comboMilkPerGrass
    {
        "translateMilkPerGrassNormal",
        "translateMilkPerGrassHigh",
	    "translateMilkPerGrassEnormous",
		    multi:
        "translateMilkPerGrass"
    }

    enum comboGrassGrowSpeed
    {
        "translateGrassGrowSpeedLow",
        "translateGrassGrowSpeedNormal",
        "translateGrassGrowSpeedHigh",
			multi:
        "translateGrassGrowSpeed"
    }
    // ECONOMIC

	function void ShowEndingScreen(player rPlayerWinner)
	{
        int i;
        int iNumberOfUnits;
        unitex uCow;
        player rPlayer;

        SetBufferSideColorName(6, rPlayerWinner.GetSideColor());
        SetStringBuff(4, "Koniec gry! Wygrywa %s!", GetStringBuff(6));
		SetCutsceneText(GetStringBuff(4));
		ShowInterfaceBlackBorders(true, 15, 15, 0xFF000000, 0xFF000000, 0, 0);

        iNumberOfUnits = rPlayerWinner.GetNumberOfUnits();

        for(i=0; i<iNumberOfUnits; i=i+1)
        {
            uCow = rPlayerWinner.GetUnit(i);
            if(uCow.IsHarvester())
            {
                break;
            }
        }

        for(i=0; i<8; i=i+1)
        {
            rPlayer = GetPlayer(i);
            rPlayer.ShowInterface(false);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                if(uCow != null)
                {
                    rPlayer.LookAt(uCow.GetLocationX(), uCow.GetLocationY(), 3,
                                   uCow.GetAlphaAngle()-128, 20, 0);
                    rPlayer.DelayedLookAt(uCow.GetLocationX()+1, uCow.GetLocationY()+2, 12,
                                uCow.GetAlphaAngle()-128, 58, 0, 150, false);
                    rPlayer.SpyPlayer(rPlayerWinner.GetIFFNumber(), true, 10000);
                    ShowArea(rPlayer.GetIFFNumber(), uCow.GetLocationX(), uCow.GetLocationY(), 0, 300,
                             showAreaPassives|showAreaBuildings|showAreaUnits);
                }
                else
                {
                    rPlayer.LookAt(rPlayerWinner.GetStartingPointX(), rPlayerWinner.GetStartingPointY(),
                                6, 32, 20, 0);
                    rPlayer.DelayedLookAt(rPlayerWinner.GetStartingPointX(), rPlayerWinner.GetStartingPointY(),
                                6, 32, 20, 0, 100, 1);
                    rPlayer.SpyPlayer(rPlayerWinner.GetIFFNumber(), true, 10000);
                    ShowArea(rPlayer.GetIFFNumber(), rPlayerWinner.GetStartingPointX(), rPlayerWinner.GetStartingPointY(), 0, 300,
                             showAreaPassives|showAreaBuildings|showAreaUnits);
                }  
            }
        }

		
	}

    function int CreateDefaultUnitEconomic(player rPlayer, int nX, int nY, int nZ)
    {
	    rPlayer.CreateUnit(nX, nY, nZ, 0, "WOODCUTTER");
        rPlayer.CreateUnit(nX+1, nY, nZ, 0, "WOODCUTTER");
	    rPlayer.CreateUnit(nX+2, nY, nZ, 0, "WOODCUTTER");
	    rPlayer.CreateUnit(nX+3, nY, nZ, 0, "DIPLOMAT");

	    rPlayer.CreateUnit(nX, nY+1, nZ, 0, "COW");
        rPlayer.CreateUnit(nX+1, nY+1, nZ, 0, "COW");
	    rPlayer.CreateUnit(nX+2, nY+1, nZ, 0, "COW");
	    rPlayer.CreateUnit(nX+3, nY+1, nZ, 0, "SHEPHERD");
		
	    return true;
    }

    state Initialize;
    int iMilkToWin;
    
    state Initialize
    {
        player rPlayer;
        int i;
    
		// Wyłączenie podpowiedzi
		EnableAssistant(0xffffff, false);

		// TELEPORTY
		CreateTeleportsAndSwitches();
		// TELEPORTY

        // Czary dla gracza 14, czyli od czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Nieskończony milk pool dla gracza 14 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnablePlayer14Milk();

        if(comboGrassGrowSpeed==0) SetResourceGrowSpeed(800);
        if(comboGrassGrowSpeed==1) SetResourceGrowSpeed(400);
        if(comboGrassGrowSpeed==2) SetResourceGrowSpeed(200);

        for(i=0; i<8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
		        rPlayer.SetScriptData(0, 0);

                // ECONOMIC
                // ilość mleka potrzebna do wygranej

                if(comboMilkToWin==0) rPlayer.SetMaxMoney(1500); 
                if(comboMilkToWin==1) rPlayer.SetMaxMoney(10000); 
                if(comboMilkToWin==2) rPlayer.SetMaxMoney(20000); 
                if(comboMilkToWin==3) rPlayer.SetMaxMoney(50000); 
                if(comboMilkToWin==4) rPlayer.SetMaxMoney(100000);
                if(comboMilkToWin==5) rPlayer.SetMaxMoney(200000); 
                if(comboMilkToWin==6) rPlayer.SetMaxMoney(500000);  
                iMilkToWin = rPlayer.GetMaxMoney();

                rPlayer.SetScriptData(0, 0);
                rPlayer.SetMoney(1000);

				SetStringBuffTranslate(2, "translateEconomicGoal");
				SetStringBuff(3, GetStringBuff(2), iMilkToWin);
                RegisterGoal(0, GetStringBuff(3));
				EnableGoal(0, true);

		        // dowolna ilość obór i dworów
		        rPlayer.SetMaxCountLimitForObject("COWSHED", -1);
                rPlayer.SetMaxCountLimitForObject("COURT", -1);
		        // ECONOMIC		
		
                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    CreateDefaultUnitEconomic(rPlayer, rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 0);
	        }
        }

		SetTimer(0, 1);

        // Efektywne czary dla najtrudniejszych botów
        SetTimer(3, SECOND);

		SetTimer(4, 60*SECOND);
        SetTimer(7, GetWindTimerTicks());
		StartWind();

        InitializeStatistics();

        return Nothing;
    }

    state EconomicVictory
    {
		return Nothing;
    }

    event RemoveUnits()
    {
        return true;
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
        int i;
        int j;
        int iMoney;
        int iCountBuilding;
        int bOneHasBeenDestroyed;   
        int bActiveEnemies;

        player rPlayer;
        player rPlayer2;

		if ( state != Nothing ) return;

        // Sprawdzamy, czy gracz został pokonany. Zmienna określa czy jakikolwiek gracz został wyeliminowany z mapy.
        bOneHasBeenDestroyed = CheckIfPlayerWasDestroyed(true);

        // ECONOMIC  
        // Celem gry jest uzyskanie odpowiedniej ilości mleka. 
	    // Wyniki poszczególnych wyświetlamy graczy na górze ekranu

	    // Przygotowujemy buffer do wyświetlenia wyników

	    SetStringBuff(0, "");

        for(i=0; i<maxNormalPlayersCnt; i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                iMoney = rPlayer.GetMoney();
                // Łączymy wyniki wszystkich graczy w jeden string

                SetBufferSideColorName(5, rPlayer.GetSideColor());

                SetStringBuff(1, " %s: %d ", GetStringBuff(5), iMoney);
                SetStringBuff(0, " %s %s ", GetStringBuff(0), GetStringBuff(1));

                if(iMoney >= iMilkToWin)		
                {
                    ShowEndingScreen(rPlayer);

             		SetStateDelay(250);
                    
                    for(j=0; j<maxNormalPlayersCnt; j=j+1)
                    {
                            if(i==j) continue;
                            rPlayer2 = GetPlayer(j);
                            rPlayer2.SetScriptData(1, 1);
                    }

                    state Victory;
                }
            }

        }

	//Wyświetlamy wyniki. Żeby połączyć string 'translate...' trzeba użyć specjalną funkcję.
	
		// Na początku misji wyświetlamy na górze dodatkowo cel gry
		if (GetMissionTime() < 10*60*SECOND)
		{
            SetStringBuff(2, "translateEconomicGoalConsole");
            SetStringBuffTranslate(3, GetStringBuff(2));
			SetStringBuff(4, "%s%s%s", GetStringBuff(3), "\n", GetStringBuff(0));
			SetConsoleText(GetStringBuff(4), iMilkToWin);	
		}
		// Potem wyświetlamy tylko informacje o wynikach
		else
		{
			SetConsoleText(GetStringBuff(0));
		}


        // ECONOMIC
        
        // Sprawdzamy, czy na mapie został jeden team/gracz
        bActiveEnemies = CheckIfActiveEnemiesExist(false);

        if(bActiveEnemies) return;
        if(!bOneHasBeenDestroyed) return;
        
		SetStateDelay(250);
		state Victory;
    }

    command Initialize()
    {   
        // Wartości przypisywane tutaj odpowiadają, która wartość z comboButton bedzie pokazana po wyborze trybu.
        // np. comboMilkToWin = 1 odpowiada wartości 10000, dla comboMilkToWin = 2 byłoby 20000, a dla comboMilkToWin = 0 - 5000
	    comboMilkToWin = 1;
        comboMilkPerGrass = 1;
        comboGrassGrowSpeed = 1;
        return true;
        // ECONOMIC
    }
    
    command Uninitialize()
    {
        return true;
    }
    // ECONOMIC    
    command Combo1(int nMode) button comboMilkToWin 
    {
        comboMilkToWin = nMode;
		return true;
    }
    
    command Combo2(int nMode) button comboMilkPerGrass 
    {
        comboMilkPerGrass = nMode;
        return true;
    }

    command Combo3(int nMode) button comboGrassGrowSpeed
    {
        comboGrassGrowSpeed = nMode;
        return true;
    }
    // ECONOMIC
}
