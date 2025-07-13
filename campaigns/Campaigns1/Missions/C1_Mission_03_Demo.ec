#define MISSION_NAME "translate1_03"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_03_Dialog_
#include "Language\Common\timeMission1_03.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_03\\103_"

mission MISSION_NAME
{
	
    state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start4;
	state Start;
	state FindInformation;
	state FindShepherd;
	state FindSorcerer;
	state FindTemple;
	state DestroyEnemy;
	state MissionFail;
	state MissionComplete;
	
#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"
	
	consts 
	{
		goalMirkoMustSurvive   = 0;
		goalMieszkoMustSurvive = 1;
		goalFindInformation    = 2;
		goalBandit1            = 3;
		goalMage               = 4;
		goalTemple             = 5;
		goalBandit2            = 6;
		goalTeleport           = 7;

		playerNeutral    =  0;
		playerPlayer     =  2;
		playerCows       =  4;
		playerWoodcutter =  5;
		playerEnemy      =  6;
		playerAnimals    = 14;

		playerEnemy1     =  1;
		playerEnemy2     =  3;

		playerPriest     =  2;

		markerHeroStart    =  0;
		markerCrewStart    =  1;
		markerMieszkoStart = 24;
		markerPriestStart  = 56;

		markerHeroEnd    = 48;
		markerMieszkoEnd = 49;

		markerCrewEndFrom = 20;
		markerCrewEndTo =   47;

		markerWoodcutter =  3;
		markerWitch      = 21;
		markerSorcerer   = 15;

		markerBadMan     = 34;

		markerSorcererGate = 16;

		markerShepherd1  = 13;
		markerShepherd2  = 14;

		markerShepherdDestination = 26;

		markerCowFirst   =  4;
		markerCowLast    = 11;

		markerCowMaster  = 12;

		markerCowGate    = 19;

		markerVictim = 57;
				
		markerShepherdMoveFirst = 59;
		markerShepherdMoveLast  = 65;

		dialogFindInformation   = 0;
		dialogFirstMeetSorcerer = 1;
		dialogKillCows          = 2;
		dialogKillWoodcutter    = 3;
		dialogGuides            = 4;
		dialogMeetSorcerer      = 5;
		dialogTemple            = 6;
		dialogNewFriends        = 7;
		dialogEndMission        = 8;
		dialogMissionFail       = 9;

		markerTemple = 31;
		
		rangeTalk = 2;//MD 19.12.2002
		rangeNear = 3;

		idTemple = 777;
	}

	player m_pPlayer;
	player m_pCows;
	player m_pWoodcutter;
	player m_pEnemy;
	player m_pAnimals;

	player m_pEnemy1;
	player m_pEnemy2;

	player m_pNeutral;

	unitex m_uHero;
	unitex m_uMieszko;
	
	unitex m_uWoodcutter;
	unitex m_uWitch;
	unitex m_uSorcerer;

	unitex m_uShepherd1;
	unitex m_uShepherd2;

	unitex m_uSorcererGate;
	unitex m_uCowGate;

	unitex m_uVictim;

	unitex m_uWoodcutterTalkSmoke;
	unitex m_uWitchTalkSmoke;
	unitex m_uShepherd1TalkSmoke;
	unitex m_uSorcererTalkSmoke;

	int m_bCheckHero;
	
	int m_bWoodcutterTalk;
	int m_bWitchTalk;
	int m_bSorcererTalk;

	unitex m_auCows[];

	unitex m_uBadMan;
	unitex m_uCowMaster;

	int m_nShepherdDest;

	function int InitializeCows()
	{
		int i;
		unitex uCow;

		m_auCows.Create(0);

		for ( i=markerCowFirst; i<=markerCowLast; ++i )
		{
			uCow = GetUnitAtMarker( i );

			m_auCows.Add( uCow );
		}

		return true;
	}

	function int InitializePlayers()
	{
		INITIALIZE_PLAYER( Player      );
		INITIALIZE_PLAYER( Cows        );
		INITIALIZE_PLAYER( Woodcutter  );
		INITIALIZE_PLAYER( Enemy       );
		INITIALIZE_PLAYER( Animals     );

		INITIALIZE_PLAYER( Enemy1      );
		INITIALIZE_PLAYER( Enemy2      );

		INITIALIZE_PLAYER( Neutral     );

		m_pNeutral.EnableAI(false);
		m_pCows.EnableAI(false);
		m_pWoodcutter.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);

		INITIALIZE_PLAYER( Priest  );

		SetNeutrals(m_pPlayer, m_pCows);
		SetNeutrals(m_pPlayer, m_pWoodcutter);

		SetNeutrals(m_pCows, m_pWoodcutter);

		SetNeutrals(m_pCows, m_pEnemy);
		SetNeutrals(m_pCows, m_pEnemy1);
		SetNeutrals(m_pCows, m_pEnemy2);
		SetNeutrals(m_pCows, m_pAnimals);

		SetNeutrals(m_pWoodcutter, m_pEnemy);
		SetNeutrals(m_pWoodcutter, m_pEnemy1);
		SetNeutrals(m_pWoodcutter, m_pEnemy2);
		SetNeutrals(m_pWoodcutter, m_pAnimals);

		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pWoodcutter);
		SetNeutrals(m_pNeutral, m_pCows);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pAnimals);
		SetNeutrals(m_pNeutral, m_pEnemy1);
		SetNeutrals(m_pNeutral, m_pEnemy2);

		SetNeutrals(m_pEnemy1, m_pPlayer);
		SetNeutrals(m_pEnemy1, m_pWoodcutter);
		SetNeutrals(m_pEnemy1, m_pCows);
		SetNeutrals(m_pEnemy1, m_pEnemy);
		SetNeutrals(m_pEnemy1, m_pAnimals);
		SetNeutrals(m_pEnemy1, m_pEnemy2);

		SetNeutrals(m_pEnemy2, m_pPlayer);
		SetNeutrals(m_pEnemy2, m_pWoodcutter);
		SetNeutrals(m_pEnemy2, m_pCows);
		SetNeutrals(m_pEnemy2, m_pEnemy);
		SetNeutrals(m_pEnemy2, m_pAnimals);

		SetNeutrals(m_pEnemy, m_pAnimals);

		SetEnemies(m_pPlayer, m_pEnemy);

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
		INITIALIZE_UNIT( Woodcutter );
		INITIALIZE_UNIT( Witch      );
		INITIALIZE_UNIT( Sorcerer   );

		INITIALIZE_UNIT( Shepherd1  );
		INITIALIZE_UNIT( Shepherd2  );

		INITIALIZE_UNIT( BadMan );
		INITIALIZE_UNIT( CowMaster );

		INITIALIZE_UNIT( Victim );

		INITIALIZE_UNIT( SorcererGate );
		m_uSorcererGate.CommandBuildingSetGateMode(modeGateClosed);

		INITIALIZE_UNIT( CowGate );
		m_uCowGate.CommandBuildingSetGateMode(modeGateClosed);
		SetRealImmortal(m_uCowGate.GetUnitOnTower(), true);
		SetRealImmortal(m_uCowGate, true);

		m_uWoodcutter.CommandSetMovementMode(modeHoldPos);

		m_uVictim.CommandSetMovementMode(modeHoldPos);

		m_uWoodcutter.SetExperienceLevel(5);

		m_pAnimals.SetUnitsExperienceLevel(GetDifficultyLevel()+2);

		m_pEnemy1.SetUnitsExperienceLevel(3);
		m_pEnemy2.SetUnitsExperienceLevel(3);

		SetRealImmortal(m_uWoodcutter, true);
		SetRealImmortal(m_uWitch, true);
		SetRealImmortal(m_uSorcerer, true);
		SetRealImmortal(m_uShepherd1, true);
		SetRealImmortal(m_uShepherd2, true);

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

	function int RegisterGoals()
	{
		REGISTER_GOAL( MirkoMustSurvive   );
		REGISTER_GOAL( MieszkoMustSurvive );
		REGISTER_GOAL( FindInformation    );
		REGISTER_GOAL( Bandit2            );
		REGISTER_GOAL( Bandit1            );
		REGISTER_GOAL( Mage               );
		REGISTER_GOAL( Temple             );
		REGISTER_GOAL( Teleport           );

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalMieszkoMustSurvive, true);

        return true;
	}

    state Initialize
    {
		unitex uTmp;

		TurnOffTier5Items();

		CallCamera();

		OnDifficultyLevelClearMarkers( difficultyEasy  , 27, 30, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 28, 28, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 30, 30, 0 );

		InitializePlayers();
		InitializeUnits();
		InitializeCows();

		SetAllBridgesImmortal(true);

		RegisterGoals();

		// PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);

		// OPEN_GATE( markerOpenedGate );

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		// EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);

		SetTimer(1, 200);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+89,GetTop()+134,28,190,40,0);
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
		SetCutsceneText("translate1_03_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+87,GetTop()+132,15,32,42,0,350,0);

		return Start1, 70;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(64);

		return Start2, 70;
	}

	state Start2
	{
		RESTORE_HERO();
		m_uHero.CommandTurn(192);

		return Start3, 70;
	}

	state Start3
	{
		RESTORE_MIESZKO();
		m_uMieszko.CommandTurn(192);

		m_bCheckHero = true;

		return Start4, 70;
	}

	state Start4
	{
		RESTORE_CREW();

		return Start, 70;
	}

	event Timer1()
	{
		int x, y, z;
		unitex uTmp;

		m_pEnemy2.SetMoney(0);

		z = GetPointZ(32);

		for ( x=GetPointX(32); x<=GetPointX(33); ++x )
		{
			for ( y=GetPointY(32); y<=GetPointY(33); ++y )
			{
				uTmp = GetUnit(x, y, z);

				if ( uTmp != null && uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
					Lighting(x, y, 10);
				}
			}
		}
	}

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindInformation )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindInformation
			#define DIALOG_LENGHT  2
						
			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogFirstMeetSorcerer )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Sorcerer
			#define DIALOG_NAME    FirstMeetSorcerer
			#define DIALOG_LENGHT  2
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogKillCows )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Woodcutter
			#define DIALOG_NAME    KillCows
			#define DIALOG_LENGHT  12
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogKillWoodcutter )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Witch
			#define DIALOG_NAME    KillWoodcutter
			#define DIALOG_LENGHT  16
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogGuides )
		{
			#define UNIT_NAME_FROM Shepherd1
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Guides
			#define DIALOG_LENGHT  4
			
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMeetSorcerer )
		{
			#define UNIT_NAME_FROM Sorcerer
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MeetSorcerer
			#define DIALOG_LENGHT  8
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogTemple )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Temple
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogNewFriends )
		{
			#define UNIT_NAME_FROM Woodcutter
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    NewFriends
			#define DIALOG_LENGHT  3
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogEndMission )
		{
			ADD_STANDARD_TALK(Priest, Hero, EndMission_01);
			ADD_STANDARD_TALK(Hero, Priest, EndMission_02);
			ADD_STANDARD_TALK(Priest, Hero, EndMission_03);

			PlayTalkDefinition();

			return TalkDialog;
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
		int i;

		if ( m_nDialogToPlay != dialogTemple ) RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogFindInformation )
		{
			EnableGoal(goalFindInformation, true);
		}
		else if ( m_nDialogToPlay == dialogGuides )
		{
			EnableGoal(goalMage, true);
		}
		else if ( m_nDialogToPlay == dialogKillCows )
		{
			EnableGoal(goalBandit2, true);
		}
		else if ( m_nDialogToPlay == dialogKillWoodcutter )
		{
			AddWorldMapSignAtMarker(markerBadMan, 1, -1);

			EnableGoal(goalBandit1, true);
		}
		else if ( m_nDialogToPlay == dialogMeetSorcerer )
		{
			AddWorldMapSignAtMarker(markerTemple, 0, -1);

			SetGoalState(goalMage, goalAchieved);
			SetGoalState(goalFindInformation, goalAchieved);
			EnableGoal(goalTemple, true);
		}
		else if ( m_nDialogToPlay == dialogTemple )
		{
			CREATE_PRIEST_NEAR_UNIT( Hero );

			m_uHero.CommandTurn(m_uHero.GetAngleToTarget(m_uPriest.GetUnitRef()));
			m_uPriest.CommandTurn(m_uPriest.GetAngleToTarget(m_uHero.GetUnitRef()));

			m_nDialogToPlay = dialogEndMission;
			return StartPlayDialog, 30;
		}
		else if ( m_nDialogToPlay == dialogEndMission )
		{
			if ( GetDifficultyLevel() >= difficultyEasy )
			{
				CreateUnits(m_pEnemy, 35, 38, "SKELETON3");
				for ( i=35; i<=38; ++i ) CreateObjectAtMarker(i, "HIT_TELEPORT");
			}
			else if ( GetDifficultyLevel() >= difficultyMedium )
			{
				CreateUnits(m_pEnemy, 39, 41, "SKELETON4");
				for ( i=39; i<=41; ++i ) CreateObjectAtMarker(i, "HIT_TELEPORT");
			}
			else if ( GetDifficultyLevel() >= difficultyHard )
			{
				CreateUnits(m_pEnemy, 42, 43, "SKELETON4");
				for ( i=42; i<=43; ++i ) CreateObjectAtMarker(i, "HIT_TELEPORT");
			}

			SetGoalState(goalTemple, goalAchieved);
			EnableGoal(goalTeleport, true);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}
	
    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogFindInformation )
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
			RESTORE_STATE(FindInformation)
			RESTORE_STATE(FindShepherd)
			RESTORE_STATE(FindSorcerer)
			RESTORE_STATE(FindTemple)
			RESTORE_STATE(DestroyEnemy)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		SetLowConsoleText("");

		START_TALK( Woodcutter );
		START_TALK( Witch      );

		m_bWoodcutterTalk = true;
		m_bWitchTalk      = true;
		m_bSorcererTalk   = true;
		
		SET_DIALOG(FindInformation, FindInformation);
		
		return StartPlayDialog, 0;
	}
	
	state FindInformation
	{
		if ( IsUnitNearUnit(m_uHero, m_uWoodcutter, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_bWoodcutterTalk )
			{
				if ( m_uCowMaster.IsLive() )
				{
					STOP_TALK( Woodcutter );

					m_bWoodcutterTalk = false;

					SET_DIALOG(KillCows, FindInformation);

					SetEnemies(m_pPlayer, m_pEnemy2);

					return StartPlayDialog, 0;
				}
				else
				{
					STOP_TALK( Woodcutter );

					m_bWoodcutterTalk = false;

					SetAlly(m_pPlayer, m_pWoodcutter);

					SET_DIALOG(NewFriends, FindTemple);

					m_uCowGate.CommandBuildingSetGateMode(modeGateOpened);

					return StartPlayDialog, 0;
				}
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uWitch, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_bWitchTalk )
			{
				STOP_TALK( Witch );

				m_bWitchTalk = false;

				SetEnemies(m_pPlayer, m_pEnemy1);

				SET_DIALOG(KillWoodcutter, FindInformation);

				return StartPlayDialog, 0;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uSorcererGate, rangeNear) && ! m_uHero.IsMoving() )
		{
			if ( m_bSorcererTalk )
			{
				m_bSorcererTalk = false;

				SET_DIALOG(FirstMeetSorcerer, FindInformation);

				return StartPlayDialog, 0;
			}
		}

		if ( ! m_uBadMan.IsLive() && GetGoalState(goalBandit1) != goalAchieved )
		{
			if ( m_bWitchTalk )
			{
				STOP_TALK( Witch );
				m_bWitchTalk = false;
			}

			if ( GetDifficultyLevel() >= difficultyEasy )
			{
				CreateUnits(m_pEnemy, 50, 55, "WHITEWOLF");
			}
			else if ( GetDifficultyLevel() >= difficultyMedium )
			{
				CreateUnits(m_pEnemy, 50, 55, "BLACKBEAR");
			}
			else if ( GetDifficultyLevel() >= difficultyHard )
			{
				CreateUnits(m_pEnemy, 50, 55, "BEAR");
			}

			RemoveWorldMapSignAtMarker(markerBadMan);

			SetGoalState(goalBandit1, goalAchieved);
			
			SetAlly(m_pPlayer, m_pCows);

			START_TALK( Shepherd1 );

			return FindShepherd;
		}

		if ( m_auCows.GetSize() > 0 )
		{
			m_uCowMaster.RegenerateHP();
		}

		if ( ! m_uCowMaster.IsLive() && GetGoalState(goalBandit2) != goalAchieved )
		{
			if ( ! m_bWoodcutterTalk )
			{
				START_TALK( Woodcutter );

				m_bWoodcutterTalk = true;
			}
			
			SetGoalState(goalBandit2, goalAchieved);
		}

		if ( m_uVictim != null && m_uVictim.IsLive() && IsPlayerUnitNearMarker(58, 6, m_pPlayer.GetIFF()))
		{
			CommandMoveUnitToMarker(m_uVictim, 58);
		}

		return FindInformation;
	}

	state FindShepherd
	{
		if ( IsUnitNearUnit(m_uHero, m_uShepherd1, rangeTalk) && ! m_uHero.IsMoving() )
		{
			STOP_TALK( Shepherd1 );

			SET_DIALOG(Guides, FindSorcerer);

			m_bSorcererTalk = false;
			m_nShepherdDest = markerShepherdMoveFirst;

			return StartPlayDialog, 0;
		}

		return FindShepherd;
	}

	state FindSorcerer
	{
		if ( m_uSorcererTalkSmoke )
		{
			if ( IsUnitNearUnit(m_uHero, m_uSorcerer, rangeTalk) /*&& ! m_uHero.IsMoving()*/ )
			{
				STOP_TALK( Sorcerer );
				
				SET_DIALOG(MeetSorcerer, FindInformation);
				
				return StartPlayDialog, 0;
			}
			if ( !m_uShepherd1.IsMoving() && !IsUnitNearMarker(m_uShepherd1, markerShepherdDestination, rangeNear) )
			{
				CommandMoveUnitToMarker(m_uShepherd1, markerShepherdDestination);
			}
			if ( !m_uShepherd2.IsMoving() && !IsUnitNearMarker(m_uShepherd2, markerShepherdDestination, rangeNear) )
			{
				CommandMoveUnitToMarker(m_uShepherd2, markerShepherdDestination);
			}
		}
		else
		{
			if ( ! IsUnitNearMarker(m_uShepherd1, m_nShepherdDest, rangeNear) )
			{
				CommandMoveUnitToMarker(m_uShepherd1, m_nShepherdDest);
				CommandMoveUnitToMarker(m_uShepherd2, m_nShepherdDest);
			}
			
			AddWorldMapSignAtUnit(m_uShepherd1, 0, 50);
			
			if ( IsUnitNearMarker(m_uShepherd1, m_nShepherdDest, rangeNear) && IsUnitNearMarker(m_uHero, m_nShepherdDest, rangeNear) )
			{
				if ( m_nShepherdDest < markerShepherdMoveLast )
				{
					++m_nShepherdDest;
				}
				else
				{
					START_TALK( Sorcerer );
					
					m_uSorcererGate.CommandBuildingSetGateMode(modeGateOpened);
					
					CommandMoveUnitToMarker(m_uShepherd1, markerShepherdDestination);
					CommandMoveUnitToMarker(m_uShepherd2, markerShepherdDestination);
				}
			}
		}
		
		return FindSorcerer, 50;
	}

	state FindTemple
	{
		if ( IsUnitNearMarker(m_uHero, markerTemple, rangeNear) )
		{
			RemoveWorldMapSignAtMarker(markerTemple);

			SET_DIALOG(Temple, DestroyEnemy);

			return StartPlayDialog, 1;
		}

		return FindTemple;
	}

	int m_bCheckEnemyVillage;

	state DestroyEnemy
	{
//		if ( m_bCheckEnemyVillage )
//		{
//			if ( m_pEnemyVillage.GetNumberOfBuildings() == 0 && m_pEnemyVillage.GetNumberOfUnits() == 0 )
//			{
				if ( GetDifficultyLevel() >= difficultyEasy )
				{
					CreateUnits(m_pEnemy, 44, 46, "WHITEWOLF");
				}
				else if ( GetDifficultyLevel() >= difficultyMedium )
				{
					CreateUnits(m_pEnemy, 44, 46, "BLACKBEAR");
				}
				else if ( GetDifficultyLevel() >= difficultyHard )
				{
					CreateUnits(m_pEnemy, 44, 46, "BEAR");
				}

				m_pEnemy.SetUnitsExperienceLevel(GetDifficultyLevel()+2);

				CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
				CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerMieszkoEnd, 0);

				AddWorldMapSignAtMarker(markerHeroEnd, 0, -1);

				return MissionComplete;
//			}
//
//			m_bCheckEnemyVillage = false;
//		}

//		return DestroyEnemy;
	}

	state MissionCompleteBis
	{
		SetLowConsoleText("");

		m_bCheckHero = false;

		m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
		SAVE_PLAYER_UNITS();

		EnableInterface(true);
		EnableCameraMovement(true);

		ShowInterfaceBlackBorders(false, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		EndMission(true);
	}

	state MissionCompleteDemo
	{
		SetCutsceneText("translateDemoEndsHere");

		return MissionCompleteBis, 170;
	}

	state MissionComplete
	{
		if  (
			IsUnitNearMarker(m_uHero, markerHeroEnd, 0) && IsUnitNearMarker(m_uMieszko, markerMieszkoEnd, 0)
		 || IsUnitNearMarker(m_uMieszko, markerHeroEnd, 0) && IsUnitNearMarker(m_uHero, markerMieszkoEnd, 0)
			)
		{
			PlayTrack("Music\\RPGvictory.tws");

			EnableInterface(false);
			EnableCameraMovement(false);
			ShowInterface(false, INITIALIZE_CAMERA_DELAY);
			ShowPanel(false, INITIALIZE_CAMERA_DELAY);
			ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 30);

			return MissionCompleteDemo, 30;
		}

		return MissionComplete;
	}

	state MissionFail
	{
		EndMission(false);

		return MissionFail;
	}

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
	{
		if ( pPlayerOnArtefact != m_pPlayer )
		{
			return false;
		}
/*
		if ( state == FindTemple && nArtefactNum == idTemple && uUnitOnArtefact == m_uHero )
		{
			SetGoalState(goalFindInformation, goalAchieved);

			EnableGoal(goalDestroyEnemy, true);

			SET_DIALOG(Temple, DestroyEnemy);

			state StartPlayDialog;
		}
*/
		return false;
	}

	event UnitDestroyed(unitex uUnit)
	{
		int i;
		unit uTmp;

		if ( state == Initialize ) return;

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

		if ( uUnit.GetIFF() == m_pCows.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				if ( m_bWitchTalk )
				{
					STOP_TALK( Witch );

					m_bWitchTalk = false;
				}

				SetEnemies(m_pPlayer, m_pCows);
			}
		}
		else if ( uUnit.GetIFF() == m_pEnemy2.GetIFF() )
		{
			for ( i=0; i<m_auCows.GetSize(); ++i )
			{
				if ( uUnit == m_auCows[i] )
				{
					m_auCows.RemoveAt(i);

					break;
				}
			}
		}
		else if ( uUnit.GetIFF() == m_pWoodcutter.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				if ( m_bWitchTalk )
				{
					STOP_TALK( Woodcutter );

					m_bWoodcutterTalk = false;
				}

				SetEnemies(m_pPlayer, m_pWoodcutter);
			}
		}
		else if ( uUnit.GetIFF() == m_pEnemy1.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetEnemies(m_pPlayer, m_pEnemy1);
			}
		}
		else if ( uUnit.GetIFF() == m_pEnemy2.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetEnemies(m_pPlayer, m_pEnemy2);
			}
		}
	}

	event BuildingDestroyed(unitex uUnit)
	{
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

		m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);

		SetConsoleText("");

		EndMission(true);
	}
    event EscapeCutscene()
    {
		if ( state == Start1 || state == Start2 || state == Start3 || state == Start4 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+87,GetTop()+132,15,32,42,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 64);
				m_bRemovePriest = true;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uHero.CommandTurn(192);
			}
			if ( state == Start1 || state == Start2 || state == Start3 )
			{
				m_uMieszko = RestorePlayerUnitAtMarker(m_pPlayer, bufferMieszko, markerMieszkoStart);
				INITIALIZE_MIESZKO();
				m_uMieszko.CommandTurn(192);

				m_bCheckHero = true;
			}
			if ( state == Start1 || state == Start2 || state == Start3 || state == Start4 )
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
