mission "translateKingOfTheHill"
{
	consts
	{
		MARKER_FIRST_TOWER = 50;
		MAX_TOWER_NUMBER = 20;
	}

    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Events.ech"
    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\Teleports.ech"
    #include "Common\StartingUnits.ech"

	int iNumberOfTowers;
	int iTowerXAverage, iTowerYAverage;

    function void RegisterTowers()
	// Zliczamy także liczbę wież oraz średnie położenie - druga wartość
	// jest wykorzystywana przez boty do wysyłania jednostek i ustawienia znacznik na mapie
    {
		int j, iX, iY;
		iNumberOfTowers = 0;
		iTowerXAverage = 0;
		iTowerYAverage = 0;

		for(j = 0; j < MAX_TOWER_NUMBER; j = j+1)
		// Maksymalnie może być 20 wież. Markery na wieżach muszą mieć numery 50-69 (w edytorze 51-70).
       	{		
			if(PointExist(MARKER_FIRST_TOWER + j))
			// Jeśli marker nie istnieje, to funkcje GetPoint dają wartości ostatniego markera.
			{
				iX = GetPointX(MARKER_FIRST_TOWER + j);
				iY = GetPointY(MARKER_FIRST_TOWER + j);
				iTowerXAverage = iTowerXAverage + iX;
				iTowerYAverage = iTowerYAverage + iY;
				iNumberOfTowers = iNumberOfTowers + 1;
			}
			else
			// Zakładamy, że markery są ustawione po kolei i na ma żadnej dziury
			// Dobre markery w edytorze: 51, 52, 53
			// Złe: 51, 52, 54;
			{
				break;
			}
		}
		if(iNumberOfTowers>0)
		{
			iTowerXAverage = iTowerXAverage/iNumberOfTowers;
			iTowerYAverage = iTowerYAverage/iNumberOfTowers;
		}

    }

	function int CalculatePlayerPoints(player rPlayer)
	// Funkcja zlicza ile wież zostało zajęty przez gracza
	{
		int j, iX, iY;
		unitex uTower;
		int iScore;

		iScore = 0;

		for(j=0; j<iNumberOfTowers; j=j+1)
       	{		
			if(PointExist(MARKER_FIRST_TOWER + j))
			{
				iX = GetPointX(MARKER_FIRST_TOWER + j);
				iY = GetPointY(MARKER_FIRST_TOWER + j);
				uTower = GetUnit(iX, iY);

				if(uTower.GetUnitOnTower()==null)
					continue;

				if(uTower.GetIFF()==rPlayer.GetIFF()) iScore = iScore + 1; 
			}
		}
		return iScore;
	}

	function int CanUnitBeSentOnTower(unitex uUnit)
    // funkcja do trybu King of the Hill. Funkcja sprawdza, czy jednostka może zostać wysłana na wieże
    {
		if(uUnit.GetWeaponType()!=3 || uUnit.IsFlyable() || uUnit.IsInTower() || uUnit.GetMaxMagic() == 200)
		// uUnit.GetWeaponType = 3 odpowiada strzelcom: łucznik, włócznik, mag, wiedźma, kapłan. Czarodziejka to uUnit.GetWeaponType = 6.
		// GetMaxMagic()==200 odpowiada magowi.
		{
			return false;
		}
		return true;
    }

	function int AreUnitsEnemies(unitex uUnit1, unitex uUnit2)
	{
		player rPlayer1, rPlayer2;

		if(uUnit1.GetSideColor() == uUnit2.GetSideColor())
		{
			return false;
		}
		 
		rPlayer1 = GetPlayer(uUnit1.GetSideColor());
		rPlayer2 = GetPlayer(uUnit2.GetSideColor());

		return rPlayer1.IsEnemy(rPlayer2);
	}

	function void AttackClosestTower(unitex uUnit)
	{
		int i, iX, iY;
		int iShortestDistance, iDistance;
		unitex uTower, uClosestTower;

		iShortestDistance = 10000;

		for(i=0; i<iNumberOfTowers; i=i+1)
		{
			iX = GetPointX(MARKER_FIRST_TOWER + i);
			iY = GetPointY(MARKER_FIRST_TOWER + i);
			uTower = GetUnit(iX, iY);
			if(AreUnitsEnemies(uUnit, uTower))
			{
				iDistance = uUnit.DistanceTo(iX, iY);
				if(iDistance < iShortestDistance)
				{
					uClosestTower = uTower;
					iShortestDistance = iDistance;
				}
			}
		}

		if(iShortestDistance<10000)
		{
			uUnit.CommandAttack(uClosestTower);
		}

	}

	function void ShowEndingScreen(player rPlayer)
	{
		int i;
		player rPlayer2;

		SetCutsceneText("Koniec gry");
		ShowInterfaceBlackBorders(true, 15, 15, 0xFF000000, 0xFF000000, 0, 0);
		rPlayer.ShowInterface(false);
		rPlayer.LookAt(GetPointX(MARKER_FIRST_TOWER), GetPointY(MARKER_FIRST_TOWER), 3, 32, 20, 0);
		rPlayer.DelayedLookAt(GetPointX(MARKER_FIRST_TOWER)+3,
							GetPointY(MARKER_FIRST_TOWER)+3, 8, 32+128, 20, 0, 300, true);
		

		for(i=0; i<8; i=i+1)
		{
			rPlayer2 = GetPlayer(i);
			if(rPlayer!=null)
			{
				rPlayer.SpyPlayer(rPlayer2.GetIFFNumber(), true, 10000);
			}
		}

		ShowArea(rPlayer.GetIFFNumber(), GetPointX(MARKER_FIRST_TOWER), GetPointY(MARKER_FIRST_TOWER), 0, 100);
	}
    
    state Initialize
    {
        player rPlayer;
		player rPlayerTowers;
        int i;
		int j;

        // KING OF THE HILL

        // Szybszy wzrost trawy i większa ilość mleka z jednego pola dla szybszej rozgrywki

        SetMoneyPerResource100x(60);
        SetResourceGrowSpeed(300);

		// Wyliczenie pozycji wież
		RegisterTowers();

		// Migacz na mapie w miejscu gdzie znajdują się wieże
		AddWorldMapSign(iTowerXAverage, iTowerYAverage, 0, 2, 10*MINUTE);

		// Gracz niezależny, który kontroluje wieże na początku gry
		rPlayerTowers = GetPlayer(14);

        // KING OF THE HILL

		// Wyłączenie podpowiedzi
		EnableAssistant(0xffffff, false);

		// TELEPORTY
		CreateTeleportsAndSwitches();
		// TELEPORTY

		// SOJUSZE
		CreateTeamsFromComboButton(comboAlliedVictory);
		// SOJUSZE
		
        // Czary dla gracza 14, czyli od czarnego od potworków na mapie
        EnablePlayer14Spells();
        // Nieskończony milk pool dla gracza 14 dzięki czemu krowy tego gracza będą się pasły w nieskończoność
        EnablePlayer14Milk();

        for(i=0;i<8;i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
				if(rPlayer.IsAI())
				{
					// boty na start dostają bonus mleka
					rPlayer.SetMaxMoney(400);
					rPlayer.SetMoney(400);

					if(iNumberOfTowers > 0)
					// Jeśli na mapie są wieże to ustawiamy gracza 15 jako głównego przeciwnika AI
					// Dodatkowo dajemy ekstra teleport botom, aby mogły przejmować zamknięte bramy
					{
						rPlayer.ResearchUpdate("SPELL_TELEPORTATION");
						rPlayer.ResearchUpdate("SPELL_TELEPORTATION2");
						rPlayer.SetMainEnemyIFFNum(rPlayerTowers.GetIFFNumber());
					}

				}
				else
				{
					CheckMilkPool(4);	
					rPlayer.SetMoney(100);	
				}

				rPlayer.SetScriptData(0, 0);

				rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);
				
				// KING OF THE HILL
				// Wpisujemy cele misji dla graczy

				SetStringBuffTranslate(2, "translateKOTHGoal");
				SetStringBuff(3, GetStringBuff(2), iNumberOfTowers);
				rPlayer.RegisterGoal(0, GetStringBuff(3));
				rPlayer.EnableGoal(0, true);
				
				// KING OF THE HILL
				
                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);

                if (!rPlayer.GetNumberOfUnits() && !rPlayer.GetNumberOfBuildings())
                    CreateStartingUnits(rPlayer, comboStartingUnits, true);
	        }
        }

		// SOJUSZE
		CreateTeamsFromComboButton(comboAlliedVictory);
		// SOJUSZE

		SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
		SetTimer(1, 20*SECOND); // Artefakty
		SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

        // Efektywne czary dla najtrudniejszych botów
        SetTimer(3, SECOND);

		if(iNumberOfTowers > 0)
		{
			SetTimer(5, 10*SECOND);
		}
		else
		{
        	SetConsoleText("translateKOTHGameTypeDescription");
			AiChooseEnemy();
		}
		
		SetTimer(4, MINUTE);
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
        int i;
        int j;
        int iOccupiedTowers;
        int iCountBuilding;

        int bActiveEnemies;
        int bOneHasBeenDestroyed;   

        player rPlayer;
        player rPlayer2;

		if ( state != Nothing ) return;

        // Sprawdzamy ile obór mają gracze i ile maksymalnie mleka mogą mieć
        CheckMilkPool(4);

        // Sprawdzamy, czy gracz został pokonany. Zmienna określa czy jakikolwiek gracz został wyeliminowany z mapy.
        bOneHasBeenDestroyed = CheckIfPlayerWasDestroyed(false);
        
		// KING OF THE HILL  
		// Celem mapy King of the Hill jest zdobycie 16 wież na środku mapy. W tej pętli sprawdzamy, czy któryś z graczy zajął wszystkie wieże
		// Oraz wyświetlamy wyniki poszczególnych graczy na górze ekranu
		// Jeśli gracze są w sojuszu, to ich wynik jest równy sumie zdobytych wież

		
		if(iNumberOfTowers!=0)
		// Warunkiem do gry jest obecność wież z markerami
		{
			// Przygotowujemy buffer do wyświetlenia wyników
			SetStringBuff(0, "");

			for(i=0; i<maxNormalPlayersCnt; i=i+1)
			{
				rPlayer = GetPlayer(i);
				iOccupiedTowers = 0;

				if(rPlayer!=null && rPlayer.IsAlive()) 
				{
					iOccupiedTowers = CalculatePlayerPoints(rPlayer);

					for(j=0; j<maxNormalPlayersCnt; j=j+1)
					{
						rPlayer2 = GetPlayer(j);
						if(i!=j && rPlayer2!=null && rPlayer2.IsAlive() && ((rPlayer.IsAlly(rPlayer2) && comboAlliedVictory)))
						// Zliczamy zajęte wieże przez sojuszników 
						{
							iOccupiedTowers =  iOccupiedTowers + CalculatePlayerPoints(rPlayer2);
						}
					}

					// Łączymy wyniki wszystkich graczy w jeden string

					SetBufferSideColorName(5, rPlayer.GetSideColor());

					SetStringBuff(1, " %s: %d ", GetStringBuff(5), iOccupiedTowers);
					SetStringBuff(0, " %s %s ", GetStringBuff(0), GetStringBuff(1));
				}

				// Jeśli któryś gracz bądź drużyna zdobyła wszystkie wieże, to kończymy grę
					if(iOccupiedTowers >= iNumberOfTowers)		
					{
						SetStateDelay(500);
						for(j=0; j<maxNormalPlayersCnt; j=j+1)
						{
							if(i==j) continue;

							rPlayer2 = GetPlayer(j);
							rPlayer2.DelayedLookAt(GetPointX(MARKER_FIRST_TOWER), GetPointY(MARKER_FIRST_TOWER), 11, 109, 62, 0, 100, true);
							SetStateDelay(500);
							if(rPlayer2!=null && rPlayer2.IsAlive() && (rPlayer.IsAlly(rPlayer2) && comboAlliedVictory)) 
							{
								rPlayer2.SetGoalState(0, goalAchieved, true);
							}
							else
							{
								rPlayer2.SetScriptData(1, 1);
								rPlayer2.SetGoalState(0, goalFailed, true);
							}
							ShowEndingScreen(rPlayer2);
						}

						ShowEndingScreen(rPlayer);
						SetStateDelay(300);

						state Victory;
					}
			}

			//Wyświetlamy wyniki. Żeby połączyć string 'translate...' trzeba użyć specjalną funkcję.
			// Na początku misji wyświetlamy na górze dodatkowo cel gry
			if (GetMissionTime() < 10*MINUTE)
			{
				SetStringBuffTranslate(2, "translateKOTHConsoleGoal");
				SetStringBuff(3, GetStringBuff(2), iNumberOfTowers);
				SetStringBuff(4, "%s%s%s", GetStringBuff(3), "\n", GetStringBuff(0));
				SetConsoleText(GetStringBuff(4));	
			}
			// Potem wyświetlamy tylko informacje o wynikach
			else
			{
				SetConsoleText(GetStringBuff(0));
			}
		}
        // KING OF THE HILL

        // Sprawdzamy, czy na mapie został jeden team/gracz
        bActiveEnemies = CheckIfActiveEnemiesExist(comboAlliedVictory);

        if(bActiveEnemies) return;
        if(!bOneHasBeenDestroyed) return;
        
		SetStateDelay(150);
		state Victory;
    }
    
	event Timer1()
    {
		/*
		 Tworzenie artefaktów na mapie z pewnym prawdopobieństwem. Można zwiększyć liczbę
		 tworzonych artefaktów zmniejszając czas między wywołaniami zegara
		*/
		MakeEquipmentFromTimeToTime(comboArtifacts, true);
	}

	event Timer2()
	{
		// Jeśli nie ma na mapie wież, to gramy zwykłą wojne wiosek
		if(iNumberOfTowers == 0)
		{
			AiChooseEnemy();
		}	
	}

	event Timer5()
	{
		// Kod służy do wysyłania jednostek AI na wieże w trybie KOTH. 
		int i, j, k;
		int iNumberOfUnits;
		int iTowerCounter;

		int iUnitIndex, iTowerIndex;
		int iUnitRandIndex, iTowerRandIndex;
		// iUnitIndex, iTowerIndex i UnitRandIndex, iTowerRandIndex są używane, żeby wprowadzić pewną losowość w wysyłaniu jednostek na wieże
		// Nie chcemy aby zawsze był wysyłany unit z indexem 1 na wieże z indeksem 1.
		// Rozwiązanie na losowość jest dość prymitywne - wynika to z bardzo niewygodnej implementacji tablic w KnightC - ale działa OK.
		
		unitex uUnit;
		unitex uTower;
		player rPlayer;
		
		for(i=0; i < 8; i=i+1)
        	{
            	rPlayer = GetPlayer(i);
            	if(rPlayer!=null &&  rPlayer.IsAlive() && rPlayer.IsAI())
				{
					
					if(GetMissionTime() < rPlayer.GetStartAttacksTime())
					// We wczesnym etapie gry nie atakujemy.
					{
						continue;
					}

					if(RAND(1000) < 20)
					// Średnio raz na 50 wywołań zegara atakujemy. Zegar się włącza co 10 sekund, więc średnio co 500 sekund, czyl 6 minut i 20 sekund.
					{
						rPlayer.RussianAttack(iTowerXAverage-8+RAND(16), iTowerYAverage-8+RAND(16), 0);
					} 
					
					iTowerCounter = 0;
					
					
					iNumberOfUnits = rPlayer.GetNumberOfUnits();

					iUnitRandIndex = RAND(iNumberOfUnits);
					iTowerRandIndex = RAND(iNumberOfTowers);

					for(j=0; j<iNumberOfUnits; j=j+1)
					{
						iUnitIndex = (iUnitRandIndex + j) % iNumberOfUnits;
						uUnit = rPlayer.GetUnit(iUnitIndex);

						if(CanUnitBeSentOnTower(uUnit) && RAND(100) < 50)
						// RAND(100) < 50 powoduje, że nie wszyscy strzelcy zostaną wysłani na pałe jeśli wieża jest pusta
						{
							if(uUnit.GetMaxMagic()==100)
							// Jeśli jest ustawiona brama, to powinna być. Na markerze 50 
							// Jeśli jednostka to kapłan (ma 100 many), to wysyłamy tę jednostkę na bramę, aby ją otworzyła.
							{
								uTower = GetUnit(GetPointX(MARKER_FIRST_TOWER), GetPointY(MARKER_FIRST_TOWER));
								if(uTower.GetUnitOnTower()==null)
								{
									uUnit.CommandEnter(uTower);
									continue;
								}
							}

							iTowerIndex = (iTowerRandIndex + iTowerCounter) % iNumberOfTowers;
							iTowerCounter = iTowerCounter + 1;
							if(iTowerCounter >= iNumberOfTowers) iTowerCounter = 0;
							uTower = GetUnit(GetPointX(MARKER_FIRST_TOWER + iTowerIndex), GetPointY(MARKER_FIRST_TOWER + iTowerIndex));

							// Puste wieże są przekazywane graczowi o numerze 13. 
							// Jeśli jest pusta to wysyłamy jednostki
							if(uTower.GetUnitOnTower()==null)
							{
								uUnit.CommandEnter(uTower);	
							}
							else if (AreUnitsEnemies(uUnit, uTower) && RAND(100) < 50) 
							// Z pewnym prawdopobieństwem atakujemy najbliższą wieże jeśli jest na niej wróg
							{
								AttackClosestTower(uUnit);	
							}
							else
							{
								//  Jeśli wieża nie jest zajęta to próbujemy jeszcze raz jednostkę wysyłać, ale na kolejną wieżę
								iTowerIndex = (iTowerRandIndex + iTowerCounter) % iNumberOfTowers;
								iTowerCounter = iTowerCounter + 1;
								if(iTowerCounter >= iNumberOfTowers) iTowerCounter = 0;
								uTower = GetUnit(GetPointX(MARKER_FIRST_TOWER + iTowerIndex), GetPointY(MARKER_FIRST_TOWER + iTowerIndex));
								if(uTower.GetUnitOnTower()==null)
								{
									uUnit.CommandEnter(uTower);	
								} 
							}
							

						}
					}
			}
		}
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
