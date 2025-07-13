#define MISSION_NAME "translate1_05"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_05_Dialog_
#include "Language\Common\timeMission1_05.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_05\\105_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;
	state FindPriests;
	state FoundPriests;
	state EscortPriests;
	state EscortedPriests;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"
#include "..\..\Gates.ech"

	consts
	{
		goalMirkoMustSurvive = 0;
		goalMieszkoMustSurvive = 1;
		goalFindPriests = 2;
		goalEscortPriests = 3;

		markerHeroStart = 0;
		markerCrewStart = 35;

		markerMieszkoStart = 49;
		markerPriestStart  = 50;

		markerHeroEnd = 0;

		markerCrewEndFrom = 35;
		markerCrewEndTo = 36;

		markerMieszkoEnd = 51;

		markerGateSwitchFirst = 2;
		markerGateSwitchLast = 5;

		markerGateFirst = 6;
		markerGateLast = 9;

//		markerPriestsActivator = 10;

		markerPriest1 = 12;
		markerPriest2 = 13;
		markerPriest3 = 14;
		markerPriest4 = 15;

		markerPriestEnd = 1;

		idGateSwitch = 777;

		rangePriestFollowHero = 10;

		dialogFindPriest     = 0;
		dialogPriestsFound   = 1;
		dialogTheEnd         = 2;
		dialogMissionFail    = 3;
	}

	player m_pPlayer;
	player m_pPlayerBis;

	player m_pEnemy;
	player m_pAnimals;
	player m_pPriests;
	player m_pGates;

	player m_pEnemy2;

	player m_pNeutral;

	unitex m_uHero;

	unitex m_uMieszko;

	unitex m_uPriest1;
	unitex m_uPriest2;
	unitex m_uPriest3;
	unitex m_uPriest4;

//	unitex m_uMasterPriest;

	int m_bCheckHero;

	unitex m_auPriests[];

	function int UpdatePriests()
	{
		int i;
		unitex uTmp;

		for ( i=0; i<m_auPriests.GetSize(); ++i )
		{
			uTmp = m_auPriests[i];

//			if ( IsUnitNearUnit(m_uHero, uTmp, rangePriestFollowHero) )
//			{
			if ( uTmp.IsLive() )
			{
				CommandMoveUnitToUnit(uTmp, m_uHero);
			}
//			}
		}

		return true;
	}

	function int RegisterGoals()
	{
		RegisterGoal(goalMirkoMustSurvive,	"translate1_05_Goal_MirkoMustSurvive");
		RegisterGoal(goalMieszkoMustSurvive,	"translate1_05_Goal_MieszkoMustSurvive");
		RegisterGoal(goalFindPriests,	"translate1_05_Goal_FindPriests");
		RegisterGoal(goalEscortPriests,	"translate1_05_Goal_EscortPriests");

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalMieszkoMustSurvive, true);

		return true;
	}

	function int ModifyDifficulty()
	{
		OnDifficultyLevelClearMarkers( difficultyEasy  , 16, 34, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 28, 34, 0 );

		return true;
	}

	function int InitializePlayers()
	{
		m_pPlayer	= GetPlayer( 2);

		m_pEnemy	= GetPlayer( 4);
		m_pAnimals	= GetPlayer(14);
		m_pPriests	= GetPlayer( 0);
		m_pGates	= GetPlayer( 1);

		m_pEnemy2   = GetPlayer( 5);

		m_pNeutral  = GetPlayer( 0);

		m_pPriest	 = GetPlayer( 3);
		m_pPlayerBis = GetPlayer( 3);

		m_pPriests.EnableAI(false);
		m_pGates.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pPlayerBis.EnableAI(false);

		m_pPriests.SetEnemy(m_pAnimals);

		SetNeutrals(m_pGates, m_pPlayer);
		SetNeutrals(m_pGates, m_pPriests);
		SetNeutrals(m_pGates, m_pAnimals);
		SetNeutrals(m_pGates, m_pEnemy);
		SetNeutrals(m_pGates, m_pEnemy2);

		SetAlly(m_pPlayer, m_pPlayerBis);
		SetNeutrals(m_pPlayerBis, m_pPriests);
		SetNeutrals(m_pPlayerBis, m_pAnimals);
		SetNeutrals(m_pPlayerBis, m_pEnemy);
		SetNeutrals(m_pPlayerBis, m_pEnemy2);

		m_pPlayerBis.SetSideColor(m_pPlayer.GetSideColor());

		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pAnimals);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pEnemy2);

		SetNeutrals(m_pPriests, m_pEnemy);

		SetNeutrals(m_pAnimals, m_pEnemy);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pAnimals);

		SetAlly(m_pPlayer, m_pPriests);

		m_pPlayer.SetMaxCountLimitForObject("COW",0);
		m_pPlayer.SetMaxCountLimitForObject("WOODCUTTER",0);
		m_pPlayer.SetMaxCountLimitForObject("FOOTMAN",0);
		m_pPlayer.SetMaxCountLimitForObject("HUNTER",0);
		m_pPlayer.SetMaxCountLimitForObject("SPEARMAN",0);
		m_pPlayer.SetMaxCountLimitForObject("SHEPHERD",0);
		m_pPlayer.SetMaxCountLimitForObject("PRIEST",0);
		m_pPlayer.SetMaxCountLimitForObject("WITCH",0);

		m_pPlayer.SetMaxCountLimitForObject("PRIESTESS",0);
		m_pPlayer.SetMaxCountLimitForObject("KNIGHT",0);
		m_pPlayer.SetMaxCountLimitForObject("SORCERER",0);
		m_pPlayer.SetMaxCountLimitForObject("DIPLOMAT",0);

		m_pPlayer.SetMaxCountLimitForObject("BARRACKS",0);
		m_pPlayer.SetMaxCountLimitForObject("COURT",0);
		m_pPlayer.SetMaxCountLimitForObject("TEMPLE",0);
		m_pPlayer.SetMaxCountLimitForObject("SHRINE",0);
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",0);
		m_pPlayer.SetMaxCountLimitForObject("HUT",0);

		m_pPlayer.SetMaxCountLimitForObject("TOWER2",0);
		m_pPlayer.SetMaxCountLimitForObject("DRAWBRIDGE2",0);
		m_pPlayer.SetMaxCountLimitForObject("GATE2",0);
		m_pPlayer.SetMaxCountLimitForObject("WALL2_O_USER",0);
		m_pPlayer.EnableCommand(commandPlayerBuildRoad, false);
		m_pPlayer.EnableCommand(commandPlayerBuildRoad2x2, false);
		m_pPlayer.EnableCommand(commandPlayerBuildSingleBridge, false);
		
		return true;
	}

	function int InitializeUnits()
	{
		m_uPriest1 = CreateUnitAtMarker(m_pPriests, markerPriest1, "PRIEST2");
		m_uPriest2 = CreateUnitAtMarker(m_pPriests, markerPriest2, "PRIEST2");
		m_uPriest3 = CreateUnitAtMarker(m_pPriests, markerPriest3, "PRIEST2");
		m_uPriest4 = CreateUnitAtMarker(m_pPriests, markerPriest4, "PRIEST2");

		m_uPriest1.CommandSetMakeMagicTeleportationMode(false);
		m_uPriest2.CommandSetMakeMagicTeleportationMode(false);
		m_uPriest3.CommandSetMakeMagicTeleportationMode(false);
		m_uPriest4.CommandSetMakeMagicTeleportationMode(false);

		m_uPriest1.EnableConversionByMagic(false);
		m_uPriest2.EnableConversionByMagic(false);
		m_uPriest3.EnableConversionByMagic(false);
		m_uPriest4.EnableConversionByMagic(false);

		// m_uMasterPriest = GetUnit( GetPointX(markerMasterPriest), GetPointY(markerMasterPriest), GetPointZ(markerMasterPriest) );

		// m_uPriest = m_uMasterPriest;

		// SetRealImmortal(m_uPriest, true);

		return true;
	}

	function int InitializeGatesSwitches()
	{
		return CreateArtefacts("SWITCH_4A_1", markerGateSwitchFirst, markerGateSwitchLast, idGateSwitch, false);
	}

	function int GateSwitchPressed()
	{
		int nGate;
		int nCounter;

		nCounter = m_nGates * 100;

		do
		{
			nGate = Rand(m_nGates);
		}
		while ( ! OpenGate(nGate) && --nCounter );

		if ( nCounter )
		{
			return true;
		}
		else
		{
			return false;
		}
        return false;
	}

	function int CountPriests()
	{
		int nPriests;

		nPriests = 0;

		if ( m_uPriest1 != null && m_uPriest1.IsLive() ) ++nPriests;
		if ( m_uPriest2 != null && m_uPriest2.IsLive() ) ++nPriests;
		if ( m_uPriest3 != null && m_uPriest3.IsLive() ) ++nPriests;
		if ( m_uPriest4 != null && m_uPriest4.IsLive() ) ++nPriests;

		return nPriests;
	}

	function int CountPriestsNearUnit( unitex uUnit, int nRange )
	{
		int nPriests;
		int nGx, nGy, nLz;

		nPriests = 0;

		nGx = uUnit.GetLocationX();
		nGy = uUnit.GetLocationY();
		nLz = uUnit.GetLocationZ();

		if ( m_uPriest1 != null && m_uPriest1.IsLive() && Distance(m_uPriest1.GetLocationX(), m_uPriest1.GetLocationY(), nGx, nGy) <= nRange && m_uPriest1.GetLocationZ() == nLz ) ++nPriests;
		if ( m_uPriest2 != null && m_uPriest2.IsLive() && Distance(m_uPriest2.GetLocationX(), m_uPriest2.GetLocationY(), nGx, nGy) <= nRange && m_uPriest2.GetLocationZ() == nLz ) ++nPriests;
		if ( m_uPriest3 != null && m_uPriest3.IsLive() && Distance(m_uPriest3.GetLocationX(), m_uPriest3.GetLocationY(), nGx, nGy) <= nRange && m_uPriest3.GetLocationZ() == nLz ) ++nPriests;
		if ( m_uPriest4 != null && m_uPriest4.IsLive() && Distance(m_uPriest4.GetLocationX(), m_uPriest4.GetLocationY(), nGx, nGy) <= nRange && m_uPriest4.GetLocationZ() == nLz ) ++nPriests;

		return nPriests;
	}

	function int MissionFailed()
	{
		if ( state == MissionFail )
		{
			return false;
		}

		PlayTrack("Music\\RPGdefeat.tws");

		if ( m_uPriest == null )
		{
			CREATE_PRIEST_NEAR_UNIT( Hero );
		}
		else if ( !IsUnitNearUnit(m_uPriest, m_uHero, 7) )
		{
			RemovePriest();
			CREATE_PRIEST_NEAR_UNIT( Hero );
		}

		PlayerLookAtUnit(m_pPlayer, m_uPriest, constLookAtHeight, constLookAtAlpha, constLookAtView);

		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;

		state StartPlayDialog;

		return true;
	}

    state Initialize
    {
		TurnOffTier5Items();
	
		ModifyDifficulty();

		InitializePlayers();
		InitializeUnits();
		InitializeGates(markerGateFirst, markerGateLast-markerGateFirst+1, false);
		InitializeGatesSwitches();

		RegisterGoals();

		SetupOneWayTeleportBetweenMarkers(46, 41);

		SetTimer(1, 20);
		// SetTimer(2, 20);
		SetTimer(3, 100);
		SetTimer(4, 60*20);

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);

		CreateArtefacts("SWITCH_4A_1", 37, 40, 0, false);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+32,GetTop()+100,22,46,44,0);
		ShowAreaAtMarker(m_pPlayer, markerPriestStart, 20);

		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);

		CacheObject(null, HERO_CREATE_EFFECT);
		CacheObject(null, CREW_CREATE_EFFECT);
		if ( GetDifficultyLevel() == difficultyEasy )
		{
			CacheObject(m_pPlayer, "HERO_EASY");
			CacheObject(m_pPlayer, "MIESZKO_EASY");
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			CacheObject(m_pPlayer, "HERO");
			CacheObject(m_pPlayer, "MIESZKO");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			CacheObject(m_pPlayer, "HERO_HARD");
			CacheObject(m_pPlayer, "MIESZKO_HARD");
		}
		CacheObject(m_pPlayer, PRIEST_UNIT);

		return Start0, 1;
	}
	//---------------------------------------------------------
	state Start0
	{
		SetCutsceneText("translate1_05_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+32,GetTop()+100,13,222,43,0,200,0);

		return Start1, 50;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(192);
		m_bRemovePriest = false;

		return Start2, 50;
	}

	state Start2
	{
		RESTORE_HERO();
		RESTORE_MIESZKO();
		m_uMieszko.CommandTurn(64);

		m_uMieszko.ChangePlayer(m_pPlayerBis);
		m_uMieszko.CommandSetMovementMode(modeHoldPos);

		m_bCheckHero = true;

		return Start3, 50;
	}

	state Start3
	{
		RESTORE_CREW();

		return Start, 50;
	}

	event Timer4()
	{
		Rain(m_uHero.GetLocationX(), m_uHero.GetLocationY(), 50, 200, 60*20-2*200, 200, 10);
	}

	event Timer1()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		if ( GetUnitAtMarker(37) != null )
		{
			SetupOneWayTeleportBetweenMarkers(41, 45);
		}
		else if ( GetUnitAtMarker(38) != null )
		{
			SetupTeleportBetweenMarkers(41, 44);
		}
		else if ( GetUnitAtMarker(39) != null )
		{
			SetupTeleportBetweenMarkers(41, 42);
		}
		else if ( GetUnitAtMarker(40) != null )
		{
			SetupTeleportBetweenMarkers(41, 43);
		}
		else
		{
			ResetTeleportAtMarker(41);
			ResetTeleportAtMarker(42);
			ResetTeleportAtMarker(43);
			ResetTeleportAtMarker(44);
		}
	}

	/*
	event Timer2()
	{
		int i;
		unitex auTmp[];
		unitex uTmp;

		int x, y, z;

		if ( m_bPlayingDialog )
		{
			return;
		}

		auTmp.Create(0);

		for (i=37; i<=40; ++i)
		{
			uTmp = GetUnitAtMarker(i);

			if ( uTmp != null )
			{
				if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
					auTmp.Add(uTmp);
				}
			}
		}

		if ( auTmp.GetSize() == 2 )
		{
			for (i=0; i<auTmp.GetSize(); ++i)
			{
				uTmp = auTmp[i];

				x = uTmp.GetLocationX();
				y = uTmp.GetLocationY();
				z = uTmp.GetLocationZ();

				uTmp.RemoveUnit();

				m_pPlayer.CreateUnit(x, y, z, 0, "SKELETON1");
			}
		}
		else if ( auTmp.GetSize() == 3 )
		{
			for (i=0; i<auTmp.GetSize(); ++i)
			{
				uTmp = auTmp[i];

				x = uTmp.GetLocationX();
				y = uTmp.GetLocationY();
				z = uTmp.GetLocationZ();

				uTmp.RemoveUnit();

				m_pPlayer.CreateUnit(x, y, z, 0, "SKELETON2");
			}
		}
		else if ( auTmp.GetSize() == 4 )
		{
			for (i=0; i<auTmp.GetSize(); ++i)
			{
				uTmp = auTmp[i];

				x = uTmp.GetLocationX();
				y = uTmp.GetLocationY();
				z = uTmp.GetLocationZ();

				uTmp.RemoveUnit();

				m_pPlayer.CreateUnit(x, y, z, 0, "SKELETON3");
			}
		}
	}
	/**/

	event Timer3()
	{
		int x, y, z;
		unitex uTmp;

		if ( m_bPlayingDialog )
		{
			return;
		}

		z = GetPointZ(47);

		for ( x=GetPointX(47)-6; x<=GetPointX(47)+6; ++x )
		{
			for ( y=GetPointY(47)-6; y<=GetPointY(47)+6; ++y )
			{
				uTmp = GetUnit(x, y, z);

				if ( uTmp )
				{
					if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
					{
						uTmp.RegenerateHP();
					}
				}
			}
		}
	}

	unitex m_uTalkPriest;

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindPriest )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Mieszko
			#define DIALOG_NAME    FindPriest
			#define DIALOG_LENGHT  2
						
			#include "..\..\TalkBis.ech"

			ADD_STANDARD_TALK(Hero, Mieszko, FindPriest_03);

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogPriestsFound )
		{
			#define UNIT_NAME_FROM Priest1
			#define UNIT_NAME_TO   Priest1
			#define DIALOG_NAME    PriestsFound
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogTheEnd )
		{
			#define UNIT_NAME_FROM Mieszko
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    TheEnd
			#define DIALOG_LENGHT  2
						
			#include "..\..\TalkBis.ech"

			ADD_STANDARD_TALK(TalkPriest, Priest, TheEnd_03);
			ADD_STANDARD_TALK(Priest, TalkPriest, TheEnd_04);
			ADD_STANDARD_TALK(TalkPriest, Priest, TheEnd_05);
			ADD_STANDARD_TALK(Priest, TalkPriest, TheEnd_06);
			ADD_STANDARD_TALK(TalkPriest, Priest, TheEnd_07);
			ADD_STANDARD_TALK(Priest, TalkPriest, TheEnd_08);
		}
		else if ( m_nDialogToPlay == dialogMissionFail )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MissionFail
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}

	state EndPlayDialog
	{
		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogFindPriest )
		{
			EnableGoal(goalFindPriests, true);

			CreateObjectAtUnit(m_uPriest, "CAST_TELEPORT");
			SetUnitAtMarker(m_uPriest, markerPriestEnd);
			CreateObjectAtUnit(m_uPriest, "HIT_TELEPORT");

			CommandMoveUnitToMarker(m_uMieszko, markerMieszkoEnd);
		}
		else if ( m_nDialogToPlay == dialogPriestsFound )
		{
			SetGoalState(goalFindPriests, goalAchieved);
			EnableGoal(goalEscortPriests, true);
		}
		else if ( m_nDialogToPlay == dialogTheEnd )
		{
			SetGoalState(goalEscortPriests, goalAchieved);

			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}
	
    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogFindPriest )
		{
			SetInterfaceOptions(
				lockAllianceDialog |
				lockGiveMoneyDialog |
				lockGiveUnitsDialog |
				lockToolbarSwitchMode |
				lockToolbarAlliance |
				lockToolbarGiveMoney |
				lockToolbarMoney |
				lockDisplayToolbarMoney |
	//			lockShowToolbar |
	//			lockToolbarMap |
	//			lockToolbarPanel |
				lockToolbarLevelName |
	//			lockToolbarTunnels |
	//			lockToolbarObjectives |
	//			lockToolbarMenu |
	//			lockDisplayToolbarLevelName |
	//			lockCreateBuildPanel |
	//			lockCreatePanel |
	//			lockCreateMap |
				0);
		}
		SAFE_REMOVE_PRIEST();
		
		BEGIN_RESTORE_STATE_BLOCK()
			RESTORE_STATE(FindPriests)
			RESTORE_STATE(EscortPriests)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
//		AddBriefing(null, "translateC1_Mission_04_Briefing_FindPriests");

		SetLowConsoleText("");

		m_nDialogToPlay = dialogFindPriest;
		m_nStateAfterDialog = FindPriests;

		SetNeutrals(m_pPlayer, m_pPriests);

		return StartPlayDialog;
//		return FindPriests;
	}

	state FindPriests
	{
		if ( CountPriests() < 4 )
		{
			SetGoalState(goalFindPriests, goalFailed);

			MissionFailed();

			return StartPlayDialog;
		}

		if ( m_bGateOpened1 && m_bGateOpened3 )
		{
			return FoundPriests, 0;
		}

		return FindPriests, 5;
	}

	state FoundPriests
	{
//		AddBriefing(null, "translateC1_Mission_04_Briefing_EscortPriests");

//		m_uPriest1.CommandEscort(m_uHero); // DONE: tak ma dzialac :)
//		m_uPriest2.CommandEscort(m_uHero);
//		m_uPriest3.CommandEscort(m_uHero);
//		m_uPriest4.CommandEscort(m_uHero);

		m_auPriests.Create(0);

		m_auPriests.Add( m_uPriest1 );
		m_auPriests.Add( m_uPriest2 );
		m_auPriests.Add( m_uPriest3 );
		m_auPriests.Add( m_uPriest4 );

		m_nDialogToPlay = dialogPriestsFound;
		m_nStateAfterDialog = EscortPriests;

		return StartPlayDialog, 0;
//		return EscortPriests;
	}

	state EscortPriests
	{
		UpdatePriests();

//		TraceD( CountPriests() );
//		TraceD( " - " );
//		TraceD( CountPriestsNearUnit(m_uMasterPriest, 6) );
//		TraceD( "\n" );

		if ( CountPriests() < 4 )
		{
			SetGoalState(goalEscortPriests, goalFailed);

			MissionFailed();

			return StartPlayDialog;
		}

		if ( CountPriests() == CountPriestsNearUnit(m_uPriest, 5) )
		{
			return EscortedPriests, 0;
		}
		
		return EscortPriests;
	}

	state EscortedPriests
	{
//		AddBriefing(null, "translateC1_Mission_04_Briefing_MissionComplete");

//		CREATE_PRIEST_NEAR_UNIT( Hero );

		if ( m_uPriest1.IsLive() )
		{
			m_uTalkPriest = m_uPriest1;
		}
		else if ( m_uPriest2.IsLive() )
		{
			m_uTalkPriest = m_uPriest2;
		}
		else if ( m_uPriest3.IsLive() )
		{
			m_uTalkPriest = m_uPriest3;
		}
		else if ( m_uPriest4.IsLive() )
		{
			m_uTalkPriest = m_uPriest4;
		}

		PlayTrack("Music\\RPGvictory.tws");

		m_nDialogToPlay = dialogTheEnd;
		m_nStateAfterDialog = MissionComplete;

		return StartPlayDialog, 0;
//		return MissionComplete;
	}

	state MissionComplete
	{
		return MissionComplete;
	}

	state MissionFail
	{
		EndMission(false);

		return MissionFail;
	}

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
	{
		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
		{
			m_bCheckHero = false;

			m_uMieszko.ChangePlayer( m_pPlayer );
			m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);

			SAVE_PLAYER_UNITS();

			EndMission(true);
		}

		if ( pPlayerOnArtefact != m_pPlayer )
		{
			return false;
		}

		if ( nArtefactNum == idGateSwitch )
		{
			CreateArtefactAtUnit("SWITCH_4A_2", uUnitOnArtefact, 0);

			return GateSwitchPressed();
		}

		return false;
	}

	event UnitDestroyed(unitex uUnit)
	{
		if ( m_bCheckHero )
		{
			if ( uUnit == m_uHero )
			{
				SetGoalState(goalMirkoMustSurvive, goalFailed);

				MissionFailed();
			}
			else if ( uUnit == m_uMieszko )
			{
				SetGoalState(goalMieszkoMustSurvive, goalFailed);

				MissionFailed();
			}
		}
	}

	event SetupInterface()
	{
		SetInterfaceOptions(
			lockAllianceDialog |
			lockGiveMoneyDialog |
			lockGiveUnitsDialog |
			lockToolbarSwitchMode |
			lockToolbarAlliance |
			lockToolbarGiveMoney |
			lockToolbarMoney |
			lockDisplayToolbarMoney |
			lockShowToolbar |
//			lockToolbarMap |
//			lockToolbarPanel |
			lockToolbarLevelName |
//			lockToolbarTunnels |
//			lockToolbarObjectives |
//			lockToolbarMenu |
			lockDisplayToolbarLevelName |
			lockCreateBuildPanel |
			lockCreatePanel |
//			lockCreateMap |
			0);
	}

	event DebugEndMission()
	{
		m_bCheckHero = false;

		m_uMieszko.ChangePlayer( m_pPlayer );

		m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);

		SetConsoleText("");

		EndMission(true);
	}
    event EscapeCutscene()
    {
		if ( state == Start1 || state == Start2 || state == Start3 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+32,GetTop()+100,13,222,43,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 192);
				m_bRemovePriest = false;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uMieszko = RestorePlayerUnitAtMarker(m_pPlayer, bufferMieszko, markerMieszkoStart);
				INITIALIZE_MIESZKO();
				m_uMieszko.CommandTurn(64);
				m_uMieszko.ChangePlayer(m_pPlayerBis);
				m_uMieszko.CommandSetMovementMode(modeHoldPos);

				m_bCheckHero = true;
			}
			if ( state == Start1 || state == Start2 || state == Start3 )
			{
				RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart);
			}

			if ( m_uPriestObj != null && m_uPriestObj.IsLive() ) m_uPriestObj.RemoveUnit();
			if ( m_uHeroObj != null && m_uHeroObj.IsLive() ) m_uHeroObj.RemoveUnit();
			if ( m_uMieszkoObj != null && m_uMieszkoObj.IsLive() ) m_uMieszkoObj.RemoveUnit();
			if ( m_uCrewObj != null && m_uCrewObj.IsLive() ) m_uCrewObj.RemoveUnit();

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
