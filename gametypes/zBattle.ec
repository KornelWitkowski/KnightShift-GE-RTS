mission "translateGameTypeBattle"
{
    #include "Common\States.ech"
    #include "Common\Common.ech"

    #include "Common\Artefacts.ech"
    #include "Common\Alliance.ech"
    #include "Common\Teleports.ech"

	int m_nAIPlayers;

	enum comboStartingMilk
	{
		"2000",
		"5000",
		"10000",
		"20000",
		"50000",
			multi:
        "translateGameMenuStartingMilk"
	}
    
    state Initialize
    {
        player rPlayer;
        int i;
		int j;
        
		// Wyłączenie podpowiedzi
		EnableAssistant(0xffffff, false);

		// TELEPORTY
		CreateTeleportsAndSwitches();
		// TELEPORTY

		m_nAIPlayers = 0;

        for(i=0; i<8; i=i+1)
        {
            rPlayer=GetPlayer(i);
            if(rPlayer!=null) 
            {
                if (rPlayer.IsAI())
				{
					rPlayer.PlayerCommand1(true);
					rPlayer.EnableAIFeatures2(ai2ControlOffense | ai2ControlOffenseMagic, false);
					++m_nAIPlayers;
				}

				// Cele misji
                RegisterGoal(0, "translateDestroyEnemyStrucuresGoal");
				EnableGoal(0, true);
  
				// Skrócenie czasu produkcji jednostek
                rPlayer.SetUnitsBuildTimePercent(20);
                rPlayer.SetCalcMinMoneyInUnitsCounts(true);
				rPlayer.SetScriptData(0, 0);              
				                
				if(GetPointX(i))
				{
					rPlayer.LookAt(GetPointX(i)+1, GetPointY(i)-1, 6, 32, 20, 0);
					rPlayer.CreateBuilding(GetPointX(i), GetPointY(i), 0, 0, "SKIRMISH_COURT");
				}
				else
				{
					rPlayer.CreateBuilding(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 0, 0, "SKIRMISH_COURT");
					rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);
				}

				if(comboStartingMilk==0){rPlayer.SetMaxMoney(2000); rPlayer.SetMoney(2000);}
				if(comboStartingMilk==1){rPlayer.SetMaxMoney(5000); rPlayer.SetMoney(5000);}
				if(comboStartingMilk==2){rPlayer.SetMaxMoney(10000); rPlayer.SetMoney(10000);}
				if(comboStartingMilk==3){rPlayer.SetMaxMoney(20000); rPlayer.SetMoney(20000);}
				if(comboStartingMilk==4){rPlayer.SetMaxMoney(50000); rPlayer.SetMoney(50000);}
	
				rPlayer.SetMaxUnitsCountInBuilding("SKIRMISH_COURT", 200);

				rPlayer.SetUnitProductionBuilding("WOODCUTTER", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("HUNTER", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("FOOTMAN", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("SPEARMAN", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("KNIGHT", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("SORCERER", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("WITCH", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("PRIEST", "SKIRMISH_COURT");
				rPlayer.SetUnitProductionBuilding("PRIESTESS", "SKIRMISH_COURT");

				rPlayer.SetMaxCountLimitForObject("COWSHED", 0);
				rPlayer.SetMaxCountLimitForObject("HUT", 0);
				rPlayer.SetMaxCountLimitForObject("BARRACKS", 0);
				rPlayer.SetMaxCountLimitForObject("COURT", 0);
				rPlayer.SetMaxCountLimitForObject("TEMPLE", 0);
				rPlayer.SetMaxCountLimitForObject("SHRINE", 0);

				rPlayer.SetMaxCountLimitForObject("TOWER2", 0);
				rPlayer.SetMaxCountLimitForObject("DRAWBRIDGE2", 0);
				rPlayer.SetMaxCountLimitForObject("GATE2", 0);
				//rPlayer.SetMaxCountLimitForObject("WALL2_O_USER", 0);
				rPlayer.EnableCommand(commandPlayerBuildRoad, false);
				rPlayer.EnableCommand(commandPlayerBuildRoad2x2, false);

				rPlayer.SetMaxCountLimitForObject("COW"     , 0);
				rPlayer.SetMaxCountLimitForObject("SHEPHERD", 0);
				rPlayer.SetMaxCountLimitForObject("DIPLOMAT", 0);

				rPlayer.ResearchUpdate("SPELL_SHIELD");
				rPlayer.ResearchUpdate("SPELL_SHIELD2");
				rPlayer.ResearchUpdate("SPELL_SHIELD3");
				rPlayer.ResearchUpdate("SPELL_SHIELD4");
				
				rPlayer.ResearchUpdate("SPELL_CAPTURE");
				rPlayer.ResearchUpdate("SPELL_CAPTURE2");
				rPlayer.ResearchUpdate("SPELL_CAPTURE3");
				rPlayer.ResearchUpdate("SPELL_CAPTURE4");
				
				rPlayer.ResearchUpdate("SPELL_STORM");
				rPlayer.ResearchUpdate("SPELL_STORM2");
				rPlayer.ResearchUpdate("SPELL_STORM3");
				rPlayer.ResearchUpdate("SPELL_STORM4");
				
				rPlayer.ResearchUpdate("SPELL_CONVERSION");
				rPlayer.ResearchUpdate("SPELL_CONVERSION2");
				rPlayer.ResearchUpdate("SPELL_CONVERSION3");
				rPlayer.ResearchUpdate("SPELL_CONVERSION4");
				
				rPlayer.ResearchUpdate("SPELL_FIRERAIN");
				rPlayer.ResearchUpdate("SPELL_FIRERAIN2");
				rPlayer.ResearchUpdate("SPELL_FIRERAIN3");
				rPlayer.ResearchUpdate("SPELL_FIRERAIN4");
				
				rPlayer.ResearchUpdate("SPELL_SEEING");
				rPlayer.ResearchUpdate("SPELL_SEEING2");
				rPlayer.ResearchUpdate("SPELL_SEEING3");
				rPlayer.ResearchUpdate("SPELL_SEEING4");
				
				rPlayer.ResearchUpdate("SPELL_TELEPORTATION");
				rPlayer.ResearchUpdate("SPELL_TELEPORTATION2");
				rPlayer.ResearchUpdate("SPELL_TELEPORTATION3");
				rPlayer.ResearchUpdate("SPELL_TELEPORTATION4");
				
				rPlayer.ResearchUpdate("SPELL_GHOST");
				rPlayer.ResearchUpdate("SPELL_GHOST2");
				rPlayer.ResearchUpdate("SPELL_GHOST3");
				rPlayer.ResearchUpdate("SPELL_GHOST4");
				
				rPlayer.ResearchUpdate("SPELL_WOLF");
				rPlayer.ResearchUpdate("SPELL_WOLF2");
				rPlayer.ResearchUpdate("SPELL_WOLF3");
				rPlayer.ResearchUpdate("SPELL_WOLF4");
	        }
        }

		// SOJUSZE
		CreateTeamsFromComboButton(comboAlliedVictory);
		AiChooseEnemy();
		// SOJUSZE

		SetTimer(0, 5*SECOND);  // Sprawdzenie stanu graczy, obór itd.
		SetTimer(1, 20*SECOND); // Artefakty
		SetTimer(2, 4*MINUTE);  // Wybór przeciwników przez AI. Przeciwnicy są też wybierani po pokonaniu gracza.

		SetTimer(4, MINUTE);
		SetTimer(5, 2*MINUTE);

        SetTimer(7, GetWindTimerTicks());
		StartWind();

		KillArea(1<<14, GetRight()/2, GetBottom()/2, 0, 128);

        InitializeStatistics();

        return Nothing;
    }

    event RemoveResources()
    {
	    return false;
    }
    
    event RemoveUnits()
    {
        return true;
    }
    
    event SpecialLevelFlags()
    {
        return 2;
    }
    
    event AIPlayerFlags()
    {
        return 0x0F;
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
    
    event Timer4()
    {
		MakeWeather();
	}

	event Timer7()
	{
		StartWind();
	}

	event UnitDestroyed(unitex uUnit)
	{
		// event dodaje mleko za każdą pokonaną jednostkę
		player pPlayer;
		unit uAttacker;

		uAttacker = uUnit.GetAttacker();

		if ( uAttacker == null ) return;
		if ( uUnit.GetIFFNumber() == uAttacker.GetIFFNumber() ) return;

		// Wyłączamy farmienie na wilkach
		if(uUnit.GetIFFNumber() == 14) return;

		pPlayer = GetPlayer(uAttacker.GetIFFNumber());

		pPlayer.AddMoney(150);
	}

	command Initialize()
    {
		comboStartingMilk = 3;
		comboAlliedVictory = 1;
        comboArtifacts = 3;
        return true;
    }
    
    command Uninitialize()
    {
        return true;
    }
        
	command Combo1(int nMode) button comboStartingMilk
    {
        comboStartingMilk = nMode;
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
