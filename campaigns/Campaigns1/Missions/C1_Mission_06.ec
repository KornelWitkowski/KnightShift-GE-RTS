#define MISSION_NAME "translate1_06"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_06_Dialog_
#include "Language\Common\timeMission1_06.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_06\\106_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;
	state FindSorcerer;
	state FoundSorcerer;
	state KillGuards;
	state KilledGuards;
	state FindSword;
	state FindGate;
	state FindGem;
	state FindMieszko;
	state KillMieszko;
	state FindScrag;
	state MissionComplete;
	state MissionFail;
	state MissionEnd;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalMirkoMustSurvive = 0;
		goalMieszkoMustSurvive = 1;
		goalFindSorcerer = 2;
		goalKillGuards = 3;
		goalFindGem = 4;

		markerHeroStart    = 0;
		markerCrewStart    = 1;
		markerMieszkoStart = 48;
		markerPriestStart  = 5;

		markerHeroEnd = 0;

		markerCrewEndFromV = 1;
		markerCrewEndToV = 9;

		markerCrewEndFrom = 47;
		markerCrewEndTo =   49;

		markerGuard1 = 20;
		markerGuard2 = 21;
		markerGuard3 = 22;
		markerGuard4 = 23;
		markerGuard5 = 24;
		markerGuard6 = 25;

		markerGuardedGate = 4;
		markerSwordGate = 2;

		markerGiant = 3;

		markerGiantDestination = 7;

		markerMapLimiter = 11;

		markerSorcerer = 12;

		idGateSwitch = 777;

		markerScrag = 39;

		dialogFindSorcerer    = 0;
		dialogFindGiant       = 1;
		dialogGiant           = 2;
		dialogFootmanEscape   = 3;
		dialogMieszkoFrenzy   = 4;
		dialogMieszkoTreason  = 5;
		dialogMieszkoDeatht   = 6;
		dialogLastGem         = 7;
		dialogMissionEnd      = 8;

		dialogMissionFail     = 9;
	}

	player m_pPlayer;

	// player m_pAnimals;
	player m_pGates;

	player m_pNeutral;

	player m_pEnemy2;

	unitex m_uHero;

	unitex m_uMieszko;

	unitex m_uGiant;

	unitex m_uGuard1;
	unitex m_uGuard2;
	unitex m_uGuard3;
	unitex m_uGuard4;
	unitex m_uGuard5;
	unitex m_uGuard6;

	unitex m_uGuardedGate;
	unitex m_uSwordGate;

	unitex m_uSorcerer;

	unitex m_uSorcererTalkSmoke;

	unitex m_uScrag;

	int m_bCheckHero;
		
	function int RegisterGoals()
	{
		RegisterGoal(goalMirkoMustSurvive, "translate1_06_Goal_MirkoMustSurvive");
		RegisterGoal(goalMieszkoMustSurvive, "translate1_06_Goal_MieszkoMustSurvive");
		RegisterGoal(goalFindSorcerer,	"translate1_06_Goal_FindSorcerer");
		RegisterGoal(goalKillGuards,	"translate1_06_Goal_FindGiant");
		RegisterGoal(goalFindGem,		"translate1_06_Goal_FindGem");

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalMieszkoMustSurvive, true);

        return true;
	}

	function int ModifyDifficulty()
	{
		// OnDifficultyLevelClearMarkers( difficultyEasy  , 14, 19, 0 );
		// OnDifficultyLevelClearMarkers( difficultyMedium, 16, 18, 0 );

		return true;
	}

	function int InitializePlayers()
	{
		m_pPlayer	= GetPlayer( 2);

		// m_pAnimals	= GetPlayer(14);
		m_pGates	= GetPlayer( 0);

		m_pEnemy2   = GetPlayer( 3);

		m_pNeutral  = GetPlayer( 0);

		m_pPriest	= GetPlayer( 2);

		m_pNeutral.EnableAI(false);
		m_pEnemy2.EnableAI(false);

		// m_pAnimals.SetUnitsExperienceLevel(GetDifficultyLevel()+3);
		m_pEnemy2.SetUnitsExperienceLevel(GetDifficultyLevel()+3);

		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pEnemy2);
		// SetNeutrals(m_pNeutral, m_pAnimals);

		SetEnemies(m_pPlayer, m_pEnemy2);

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
		INITIALIZE_UNIT( Scrag );

		m_uScrag.SetUnitName("translate1_06_Name_Necromancer");

		m_uGiant = GetUnit( GetPointX(markerGiant), GetPointY(markerGiant), GetPointZ(markerGiant) );

		m_uGuard1 = GetUnit( GetPointX(markerGuard1), GetPointY(markerGuard1), GetPointZ(markerGuard1) );
		m_uGuard2 = GetUnit( GetPointX(markerGuard2), GetPointY(markerGuard2), GetPointZ(markerGuard2) );
		m_uGuard3 = GetUnit( GetPointX(markerGuard3), GetPointY(markerGuard3), GetPointZ(markerGuard3) );
		m_uGuard4 = GetUnit( GetPointX(markerGuard4), GetPointY(markerGuard4), GetPointZ(markerGuard4) );
		m_uGuard5 = GetUnit( GetPointX(markerGuard5), GetPointY(markerGuard5), GetPointZ(markerGuard5) );
		m_uGuard6 = GetUnit( GetPointX(markerGuard6), GetPointY(markerGuard6), GetPointZ(markerGuard6) );

		m_uGuard1.CommandSetMovementMode(modeHoldPos);
		m_uGuard2.CommandSetMovementMode(modeHoldPos);
		m_uGuard3.CommandSetMovementMode(modeHoldPos);
		m_uGuard4.CommandSetMovementMode(modeHoldPos);
		m_uGuard5.CommandSetMovementMode(modeHoldPos);
		m_uGuard6.CommandSetMovementMode(modeHoldPos);

		m_uGuardedGate = GetUnit( GetPointX(markerGuardedGate), GetPointY(markerGuardedGate), GetPointZ(markerGuardedGate) );
		m_uSwordGate = GetUnit( GetPointX(markerSwordGate), GetPointY(markerSwordGate), GetPointZ(markerSwordGate) );

		m_uGuardedGate.CommandBuildingSetGateMode( modeGateClosed );
		m_uSwordGate.CommandBuildingSetGateMode( modeGateAuto );

		m_uSorcerer = GetUnitAtMarker( markerSorcerer );
		m_uSorcerer.SetUnitName("translate1_06_Name_Sorcerer");

		SetRealImmortal(m_uScrag, true);
		SetRealImmortal(m_uGiant, true);
		SetRealImmortal(m_uSorcerer, true);

		CLOSE_GATE( 11 );
		CLOSE_GATE( 26 );

		return true;
	}

	function int MissionFailed()
	{
		if ( state == MissionFail )
		{
			return false;
		}

		PlayTrack("Music\\RPGdefeat.tws");

		CREATE_PRIEST_NEAR_UNIT( Hero );

		PlayerLookAtUnit(m_pPlayer, m_uPriest, constLookAtHeight, constLookAtAlpha, constLookAtView);

		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;

		state StartPlayDialog;

		return true;
	}

    state Initialize
    {
		unitex uTmp;

		TurnOffTier5Items();

		ModifyDifficulty();

		InitializePlayers();
		initializeUnits();

		RegisterGoals();

		OPEN_GATE( 35 );
		OPEN_GATE( 36 );
		OPEN_GATE( 38 );

		CLOSE_GATE( 28 );
		CLOSE_GATE( 30 );

		CLOSE_GATE( 37 ); // zeby nie mozna sobie polezc do koscieja przed spotkaniem z Mieszkiem

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+92,GetTop()+100,19,248,48,0);
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
		SetCutsceneText("translate1_06_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+90,GetTop()+98,13,25,37,0,170,1);

		return Start1, 40;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(45);

		return Start2, 40;
	}

	state Start2
	{
		RESTORE_HERO();
		RESTORE_MIESZKO();
		m_uHero.CommandTurn(173);

		m_bCheckHero = true;

		return Start3, 40;
	}

	state Start3
	{
		RESTORE_CREW();

		return Start, 40;
	}

	unitex m_uFootman;

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindSorcerer )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindSorcerer
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogFindGiant )
		{
			#define UNIT_NAME_FROM Sorcerer
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Sorcerer
			#define DIALOG_LENGHT  9
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogGiant )
		{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Giant
			#define DIALOG_LENGHT  2
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogFootmanEscape )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FootmanEscape
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMieszkoFrenzy )
		{
			#define UNIT_NAME_FROM Mieszko
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MieszkoFrenzy
			#define DIALOG_LENGHT  3
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMieszkoTreason )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mieszko
			#define DIALOG_NAME    MieszkoTreason
			#define DIALOG_LENGHT  4
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMieszkoDeatht )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mieszko
			#define DIALOG_NAME    MieszkoDeatht
			#define DIALOG_LENGHT  6
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogLastGem )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Scrag
			#define DIALOG_NAME    LastGem
			#define DIALOG_LENGHT  3
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMissionEnd )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MissionEnd
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
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
		unitex uTmp;
		platoon plat;

		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogFindSorcerer )
		{
			EnableGoal(goalFindSorcerer, true);
		}
		else if ( m_nDialogToPlay == dialogMieszkoFrenzy )
		{
			EnableGoal(goalMieszkoMustSurvive, false);
			
			m_uMieszko.ChangePlayer( m_pNeutral );
			m_uMieszko.SetExperienceLevel( m_uMieszko.GetExperienceLevel() - 1 );

			OPEN_GATE( 30 );

			SetAlly(m_pPlayer, m_pNeutral);

			m_uMieszko.CommandSetMovementMode(modeHoldPos);

			RemoveWorldMapSignAtMarker(6);
			
			CommandMoveUnitToMarker(m_uMieszko, 33);
		}
		else if ( m_nDialogToPlay == dialogGiant )
		{
			EnableGoal(goalFindGem, true);
			
			AddWorldMapSignAtMarker(28, 0, -1);
			
			CommandMoveUnitToMarker(m_uGiant, markerGiantDestination);
		}
		else if ( m_nDialogToPlay == dialogMieszkoTreason )
		{
			m_uMieszko.ChangePlayer( m_pEnemy2 );

			m_uMieszko.CommandSetMovementMode(modeMove);

			SetNeutrals(m_pNeutral, m_pPlayer);
		}
		else if ( m_nDialogToPlay == dialogMieszkoDeatht )
		{
			m_uMieszko.KillUnit();
		}
		else if ( m_nDialogToPlay == dialogLastGem )
		{
			CreateObjectAtUnit(m_uScrag, UNIT_CREATE_EFFECT);

			m_uScrag.RemoveUnit();

			ClearMarkers(40, 40, 0);

			CreateObjectAtMarker(39, "GADGET55");

			/*
			if ( GetDifficultyLevel() >= difficultyEasy )
			{
				ClearMarkers(41, 42, 0);

				plat = CreateExpUnitsAtMarker(m_pEnemy2, 41, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
				plat = CreateExpUnitsAtMarker(m_pEnemy2, 42, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
			}

			if ( GetDifficultyLevel() >= difficultyMedium )
			{
				ClearMarkers(43, 44, 0);

				plat = CreateExpUnitsAtMarker(m_pEnemy2, 43, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
				plat = CreateExpUnitsAtMarker(m_pEnemy2, 44, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
			}

			if ( GetDifficultyLevel() >= difficultyHard )
			{
				ClearMarkers(45, 46, 0);

				plat = CreateExpUnitsAtMarker(m_pEnemy2, 45, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
				plat = CreateExpUnitsAtMarker(m_pEnemy2, 46, "BEAR", 3, 1);
				plat.CommandAttack(m_uHero);
			}
			*/
		}
		else if ( m_nDialogToPlay == dialogFindGiant )
		{
			SetGoalState(goalFindSorcerer, goalAchieved);
			EnableGoal(goalKillGuards, true);

			AddWorldMapSignAtMarker(markerGiant, 0, -1);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}
	
    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogFindSorcerer )
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
			RESTORE_STATE(FindSorcerer)
			RESTORE_STATE(KillGuards)
			RESTORE_STATE(FindSword)
			RESTORE_STATE(FindGem)
			RESTORE_STATE(FindMieszko)
			RESTORE_STATE(KillMieszko)
			RESTORE_STATE(FindScrag)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
			RESTORE_STATE(MissionEnd)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		SetLowConsoleText("");

		m_nDialogToPlay = dialogFindSorcerer;
		m_nStateAfterDialog = FindSorcerer;

		CreateArtefactAtMarker("SWITCH_1_1", 31, 0);
		CreateArtefactAtMarker("SWITCH_1_1", 32, 0);

		START_TALK( Sorcerer );

		return StartPlayDialog;
	}

	state FindSorcerer
	{
		if ( IsUnitNearUnit(m_uHero, m_uSorcerer, 2) )
		{
			return FoundSorcerer;
		}

		return FindSorcerer;
	}

	state FoundSorcerer
	{
//		AddBriefing(null, "translateC1_Mission_05_Briefing_KillGuards");

		OPEN_GATE( 26 );

		STOP_TALK( Sorcerer );

		m_nDialogToPlay = dialogFindGiant;
		m_nStateAfterDialog = KillGuards;

		return StartPlayDialog, 1;
//		return KillGuards;
	}

	state KillGuards
	{
		if ( ((! m_uGuard1.IsLive()) || m_uGuard1.GetIFF() == m_pPlayer.GetIFF()) &&
		     ((! m_uGuard2.IsLive()) || m_uGuard2.GetIFF() == m_pPlayer.GetIFF()) &&
			 ((! m_uGuard3.IsLive()) || m_uGuard3.GetIFF() == m_pPlayer.GetIFF()) &&
			 ((! m_uGuard4.IsLive()) || m_uGuard4.GetIFF() == m_pPlayer.GetIFF()) &&
			 ((! m_uGuard5.IsLive()) || m_uGuard5.GetIFF() == m_pPlayer.GetIFF()) &&
			 ((! m_uGuard6.IsLive()) || m_uGuard6.GetIFF() == m_pPlayer.GetIFF())
		   )
		{
			SetGoalState(goalKillGuards, goalAchieved);
			m_uGuardedGate.CommandBuildingSetGateMode(modeGateOpened);

			RemoveWorldMapSignAtMarker(markerGiant);

			return KilledGuards;
		}

		return KillGuards;
	}

	state KilledGuards
	{
		if ( IsUnitNearUnit(m_uHero, m_uGiant, 6) )
		{
			OPEN_GATE( 11 );

			SET_DIALOG(Giant, FindSword);

			return StartPlayDialog, 0;
		}
		else
		{
			CommandMoveUnitToUnit(m_uGiant, m_uHero);

			return KilledGuards, 100;
		}
	}

	state FindSword
	{
		if ( IsUnitNearMarker(m_uHero, 28, 6) )
		{
			m_uSwordGate.CommandBuildingSetGateMode(modeGateOpened);

			CommandMoveUnitToMarker(m_uGiant, markerGiantDestination);

			return FindGate, 0;
		}

		if ( IsUnitNearMarker(m_uGiant, markerGiantDestination, 7) )
		{
			m_uSwordGate.CommandBuildingSetGateMode(modeGateOpened);
		}

		if ( ! IsUnitNearMarker(m_uGiant, markerGiantDestination, 2) )
		{
			CommandMoveUnitToMarker(m_uGiant, markerGiantDestination);

			return FindSword, 100;
		}
		else
		{
			return FindGate;
		}

		return FindSword;
	}

	state FindGate
	{
		unitex uTmp;
		unitex auTmp[];

		int i, nCount;

		if ( IsUnitNearMarker(m_uHero, 28, 6) )
		{
			CREATE_PRIEST_NEAR_UNIT( Hero );

			SET_DIALOG(FootmanEscape, FindGem);

			OPEN_GATE( 28 );

			auTmp.Create(0);

			nCount = m_pPlayer. GetNumberOfUnits(); 
			for (i = 0; i<nCount; ++i) auTmp.Add( m_pPlayer.GetUnit(i) );
			for (i = 0; i<nCount; ++i)
			{
				uTmp = auTmp[i];

				if ( uTmp != m_uHero && uTmp != m_uMieszko )
				{
					uTmp.ChangePlayer(m_pNeutral);
					CommandMoveUnitToMarker(uTmp, 29);
				}
			}

			RemoveWorldMapSignAtMarker(28);
			AddWorldMapSignAtMarker(6, 0, -1);

			return StartPlayDialog, 0;
		}
	}

	state FindGem
	{
		// int x, y, z;
		unitex uTmp;

		// TRACE5("State: FindSword",IsUnitNearMarker(m_uHero, 31, 0),IsUnitNearMarker(m_uMieszko, 32, 0),IsUnitNearMarker(m_uMieszko, 31, 0), IsUnitNearMarker(m_uHero, 32, 0) );

		if  (
			(IsUnitNearMarker(m_uHero, 31, 0) && IsUnitNearMarker(m_uMieszko, 32, 0))
		 || (IsUnitNearMarker(m_uMieszko, 31, 0) && IsUnitNearMarker(m_uHero, 32, 0))
			)
		{
			SET_DIALOG(MieszkoFrenzy, FindMieszko);

			return StartPlayDialog, 0;
		}

		/*
		z = GetPointZ(28);

		for ( x=GetPointX(28)-6; x<=GetPointX(28)+6; ++x )
		{
			for ( y=GetPointY(28)-6; y<=GetPointY(28)+6; ++y )
			{
				uTmp = GetUnit(x, y, z);

				if ( uTmp != null && uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
					if ( uTmp != m_uHero && uTmp != m_uMieszko )
					{
						uTmp.ChangePlayer(m_pNeutral);

						CommandMoveUnitToMarker(uTmp, 29);
					}
				}
			}
		}
		*/
	}

	state FindMieszko
	{
		unitex uTmp;

		if ( IsUnitNearMarker(m_uHero, 33, 4) && IsUnitNearMarker(m_uMieszko, 33, 2) )
		{
			SET_DIALOG(MieszkoTreason, KillMieszko);

			CLOSE_GATE( 35 );
			CLOSE_GATE( 36 );
			CLOSE_GATE( 37 );
			CLOSE_GATE( 38 );

			m_uMieszko.RegenerateHP();
			m_uHero.RegenerateHP();

			return StartPlayDialog, 0;
		}

		if ( ! IsUnitNearMarker(m_uMieszko, 33, 2) )
		{
			CommandMoveUnitToMarker(m_uMieszko, 33);

			return FindMieszko, 100;
		}

		return FindMieszko;
	}

	state KillMieszko
	{
		unitex uTmp;

		if ( m_uMieszko.GetHP() * 2 < m_uMieszko.GetMaxHP() )
		{
			SET_DIALOG(MieszkoDeatht, FindScrag);

			OPEN_GATE( 35 );
			OPEN_GATE( 36 );
			OPEN_GATE( 37 );
			OPEN_GATE( 38 );

			return StartPlayDialog, 0;
		}

		return KillMieszko;
	}

	state FindScrag
	{
		if ( IsUnitNearMarker(m_uHero, 39, 5) )
		{
			SET_DIALOG(LastGem, MissionComplete);

			CreateMissionExit(markerHeroEnd, markerCrewEndFromV, markerCrewEndToV);

			return StartPlayDialog, 0;
		}

		return FindScrag;
	}

	state MissionComplete
	{
		CREATE_PRIEST_NEAR_UNIT( Hero );

		PlayTrack("Music\\RPGvictory.tws");

		SET_DIALOG(MissionEnd, MissionEnd);

		return StartPlayDialog, 0;
//		return MissionComplete;
	}

	state MissionEnd
	{
		m_pNeutral.GiveAllUnitsTo(m_pPlayer);

		m_bCheckHero = false;
		SAVE_PLAYER_UNITS();

		EndMission(true);
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
			m_pNeutral.GiveAllUnitsTo(m_pPlayer);

			m_bCheckHero = false;
			SAVE_PLAYER_UNITS();

			EndMission(true);
		}

		return false;
	}

#define CondAttack( Guard ) \
	if ( Guard != null && Guard.IsLive() && Guard != uUnit && Guard.GetIFF() != m_pPlayer.GetIFF() ) \
		Guard.CommandAttack(m_uHero);

	event UnitDestroyed(unitex uUnit)
	{
		if ( m_bCheckHero )
		{
			if ( uUnit == m_uHero )
			{
				SetGoalState(goalMirkoMustSurvive, goalFailed);

				MissionFailed();
			}
			else if ( IsGoalEnabled(goalMieszkoMustSurvive) && uUnit == m_uMieszko )
			{
				SetGoalState(goalMieszkoMustSurvive, goalFailed);

				MissionFailed();
			}
		}

		if ( uUnit == m_uGiant )
		{
			MissionFailed();
		}

		if ( uUnit == m_uGuard1 || uUnit == m_uGuard2 || uUnit == m_uGuard3 || uUnit == m_uGuard4 || uUnit == m_uGuard5 || uUnit == m_uGuard6 )
		{
			CondAttack( m_uGuard1 );
			CondAttack( m_uGuard2 );
			CondAttack( m_uGuard3 );
			CondAttack( m_uGuard4 );
			CondAttack( m_uGuard5 );
			CondAttack( m_uGuard6 );
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

		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);

		SetConsoleText("");

		EndMission(true);
	}
    event EscapeCutscene()
    {
		if ( state == Start1 || state == Start2 || state == Start3 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+90,GetTop()+98,13,25,37,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 45);
				m_bRemovePriest = true;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uHero.CommandTurn(173);
				m_uMieszko = RestorePlayerUnitAtMarker(m_pPlayer, bufferMieszko, markerMieszkoStart);
				INITIALIZE_MIESZKO();

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
