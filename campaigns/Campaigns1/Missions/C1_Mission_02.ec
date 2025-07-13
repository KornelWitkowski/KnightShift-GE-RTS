#define MISSION_NAME "translate1_02"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_02_Dialog_
#include "Language\Common\timeMission1_02.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_02\\102_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;
	state FindWomen;
	state FoundWomen;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalMirkoMustSurvive   = 0;
		goalMieszkoMustSurvive = 1;
		goalOldWoman           = 2;
		goalHut                = 3;
		goalTemple             = 4;
		goalTeleport           = 5;

		playerPlayer     =  2;
		playerNeutral    =  0;
		playerVillage    =  1;
		playerHouse      =  3;
		playerAnimals    = 14;
		playerEnemy      =  4;

		playerPriest     =  2;

		markerHeroStart    =  0;
		markerCrewStart    =  1;
		markerMieszkoStart = 40;
		markerPriestStart  = 46;

		markerHeroEnd    = 37;
		markerMieszkoEnd = 41;

		markerCrewEndFrom = 38;
		markerCrewEndTo = 39;

		markerWoodcutter   =  2;
		markerHouse        =  3;
		markerBridge       = 11;

		markerTempleKeeper = 33;
		markerTemplePriest = 34;
		markerTempleHelper = 35;

		markerTempleGate   = 12;

		markerDestination  =  7;

		markerEndGate      =  6;

		dialogFindWoman              = 1;
		dialogTempleKeeper           = 2;
		dialogOldPriest              = 3;
		dialogWoodcutterRequest      = 4;
		dialogWoodcutterConversation = 5;
		dialogDrawbridge             = 6;
		dialogEndMission             = 7;
		dialogMissionFail            = 9;
		
		rangeTalk = 2;//MD 19.12.2002

		maskGateOpenSwitch  =  2048;
	}

	player m_pPlayer;
	player m_pNeutral;
	player m_pVillage;
	player m_pHouse;
	player m_pAnimals;
	player m_pEnemy;

	unitex m_uHero;
	unitex m_uMieszko;

	unitex m_uWoodcutter;
	unitex m_uHouse;

	unitex m_uWoodcutterTalkSmoke;

	unitex m_uBridge;

	unitex m_uTempleKeeper;
	unitex m_uTemplePriest;
	unitex m_uTempleHelper;

	unitex m_uTempleKeeperTalkSmoke;
	unitex m_uTemplePriestTalkSmoke;

	unitex m_uTempleGate;

	unitex m_uEndGate;

	unitex m_uScrag;

	int m_bCheckHero;

	int m_nWoodcutterStep;
	int m_nTempleKeeperStep;
	int m_nTemplePriestStep;

	platoon m_pSkeletons;
	int m_nSkeletons;

	function int RegisterGoals()
	{
		REGISTER_GOAL( MirkoMustSurvive   );
		REGISTER_GOAL( MieszkoMustSurvive );
		REGISTER_GOAL( OldWoman           );
		REGISTER_GOAL( Hut                );
		REGISTER_GOAL( Temple             );
		REGISTER_GOAL( Teleport           );

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalMieszkoMustSurvive, true);

        return true;
	}

	function int ModifyDifficulty()
	{
		if ( GetDifficultyLevel() == difficultyEasy )
		{
			CreateUnitAtMarker(m_pEnemy, 42, "BEAR");
			CreateUnitAtMarker(m_pEnemy, 43, "BEAR");
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			CreateUnitAtMarker(m_pEnemy, 44, "BEAR");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			CreateUnitAtMarker(m_pEnemy, 45, "BEAR");
		}

		return true;
	}

	function int InitializePlayers()
	{
		INITIALIZE_PLAYER( Player  );

		INITIALIZE_PLAYER( Neutral );
		INITIALIZE_PLAYER( Village );
		INITIALIZE_PLAYER( House   );
		INITIALIZE_PLAYER( Animals );
		INITIALIZE_PLAYER( Enemy   );

		INITIALIZE_PLAYER( Priest  );

		m_pNeutral.EnableAI(false);
		m_pVillage.EnableAI(false);
		m_pHouse.EnableAI(false);
		m_pEnemy.EnableAI(false);

		SetNeutrals(m_pNeutral, m_pPlayer  );
		SetNeutrals(m_pNeutral, m_pVillage );
		SetNeutrals(m_pNeutral, m_pHouse   );
		SetNeutrals(m_pNeutral, m_pAnimals );
		SetNeutrals(m_pNeutral, m_pEnemy   );

		SetNeutrals(m_pPlayer, m_pVillage);
		SetNeutrals(m_pPlayer, m_pHouse  );

		SetEnemies(m_pPlayer, m_pEnemy);

		SetNeutrals(m_pVillage, m_pHouse  );
		SetNeutrals(m_pVillage, m_pEnemy  );

		SetNeutrals(m_pHouse, m_pEnemy  );

		SetEnemies(m_pPlayer, m_pAnimals);

		m_pPlayer.SetMaxCountLimitForObject("COW",0);
		m_pPlayer.SetMaxCountLimitForObject("SHEPHERD",0);
		m_pPlayer.SetMaxCountLimitForObject("WOODCUTTER",0);
		m_pPlayer.SetMaxCountLimitForObject("FOOTMAN",0);
		m_pPlayer.SetMaxCountLimitForObject("HUNTER",0);
		m_pPlayer.SetMaxCountLimitForObject("SPEARMAN",0);
		
		
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
		INITIALIZE_UNIT( Woodcutter   );
		INITIALIZE_UNIT( House        );
		INITIALIZE_UNIT( TempleKeeper );
		INITIALIZE_UNIT( TemplePriest );
		INITIALIZE_UNIT( TempleHelper );

		INITIALIZE_UNIT( TempleGate );
		m_uTempleGate.CommandBuildingSetGateMode(modeGateClosed);

		INITIALIZE_UNIT( Bridge );
		m_uBridge.CommandBuildingSetGateMode(modeGateClosed);

		INITIALIZE_UNIT( EndGate );
		m_uEndGate.CommandBuildingSetGateMode(modeGateClosed);

		m_uWoodcutter.CommandSetMovementMode(modeHoldPos);
		m_uTempleKeeper.CommandSetMovementMode(modeHoldPos);
		m_uTemplePriest.CommandSetMovementMode(modeHoldPos);
		m_uTempleHelper.CommandSetMovementMode(modeHoldPos);

		m_uTemplePriest.SetUnitName("translate1_02_Name_Priest");

		m_uWoodcutter.AddHPRegenerationSpeed(64, false); // zeby mogl spac do woli ;)
		m_uWoodcutter.DamageUnit(10);

		SetRealImmortal(m_uWoodcutter, true);
		SetRealImmortal(m_uHouse, true);
		SetRealImmortal(m_uTempleKeeper, true);
		SetRealImmortal(m_uTemplePriest, true);
		SetRealImmortal(m_uTempleHelper, true);

		return true;
	}

#define INITIALIZE_CLOSED_GATE( markerSwitch, markerGate ) \
	CreateArtefactAtMarker("SWITCH_1_1", markerSwitch, maskGateOpenSwitch|markerGate); \
	CLOSE_GATE( markerGate );

	function int InitializeGates()
	{
		unitex uTmp;

		INITIALIZE_CLOSED_GATE(24, 25);
		// INITIALIZE_CLOSED_GATE(26, 27);
		// INITIALIZE_CLOSED_GATE(28, 29);
		// INITIALIZE_CLOSED_GATE(30, 31);
		// INITIALIZE_CLOSED_GATE(32, 36);

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
		TurnOffTier5Items();
		
		CallCamera();

		InitializePlayers();
		InitializeUnits();
		InitializeGates();

		ModifyDifficulty();

		SetAllBridgesImmortal(true);

		// SetupTeleportBetweenMarkers(35, 36);

		RegisterGoals();

		m_nWoodcutterStep   = 0;
		m_nTempleKeeperStep = 0;
		m_nTemplePriestStep = 0;

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		// EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);

		SetTimer(1, 100);
		SetTimer(2, 500);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+38,GetTop()+109,22,230,47,0);
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
		SetCutsceneText("translate1_02_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+41,GetTop()+105,22,230,47,0,200,0);

		return Start1, 50;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(83);

		return Start2, 50;
	}

	state Start2
	{
		RESTORE_HERO();
		RESTORE_MIESZKO();
		m_uHero.CommandTurn(211);

		m_bCheckHero = true;

		return Start3, 50;
	}

	unitex m_uObj1;

	state Start3
	{
		RESTORE_CREW();

		if ( m_pPlayer.GetSavedUnitsCount(bufferCrew) < 1 )
		{
			CreateUnitAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER");
			m_uObj1 = CreateObjectAtMarker(markerCrewStart, HERO_CREATE_EFFECT);
		}

		return Start, 50;
	}

	event Timer1()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		m_pVillage.SetMoney(0);
	}

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindWoman )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindWoman
			#define DIALOG_LENGHT  8

			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogTempleKeeper )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   TempleKeeper
			#define DIALOG_NAME    TempleKeeper
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"

			ADD_STANDARD_TALK(TempleHelper, Hero, TempleKeeper_05);
			ADD_STANDARD_TALK(TempleKeeper, TempleHelper, TempleKeeper_06);
		}
		else if ( m_nDialogToPlay == dialogOldPriest )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   TemplePriest
			#define DIALOG_NAME    OldPriest
			#define DIALOG_LENGHT  7

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogWoodcutterRequest )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Woodcutter
			#define DIALOG_NAME    WoodcutterRequest
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogWoodcutterConversation )
		{
			#define UNIT_NAME_FROM Woodcutter
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    WoodcutterConversation
			#define DIALOG_LENGHT  9

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogDrawbridge )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Drawbridge
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogEndMission )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Scrag
			#define DIALOG_NAME    EndMission
			#define DIALOG_LENGHT  5

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
		platoon platTmp;

		int nSkeletons;

		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogFindWoman )
		{
			EnableGoal(goalOldWoman, true);
		}
		else if ( m_nDialogToPlay == dialogWoodcutterRequest )
		{
			m_pVillage.SetAlly(m_pHouse);
			m_uWoodcutter.CommandRepair(m_uHouse);

			SetConsoleText("translate1_02_Console_ConvertToWoodcutter");

			EnableGoal(goalHut, true);
		}
		else if ( m_nDialogToPlay == dialogWoodcutterConversation )
		{
			m_uBridge.CommandBuildingSetGateMode(modeGateOpened);
			CommandMoveUnitToUnit(m_uWoodcutter, m_uBridge);

			SetGoalState(goalHut, goalAchieved);
		}
		else if ( m_nDialogToPlay == dialogEndMission )
		{
			SetGoalState(goalOldWoman, goalAchieved);
			EnableGoal(goalTeleport, true);

			nSkeletons = GetDifficultyLevel() + 1;

			if ( GetDifficultyLevel() == difficultyEasy )
			{
				m_pSkeletons = CreateUnitsAtMarker(m_pEnemy              , 4, "SKELETON1", nSkeletons);
                               CreateUnitsAtMarker(m_pSkeletons, m_pEnemy, 5, "SKELETON1", nSkeletons);
 			}
			else if ( GetDifficultyLevel() == difficultyMedium )
			{
				m_pSkeletons = CreateUnitsAtMarker(m_pEnemy              , 4, "SKELETON2", nSkeletons);
                               CreateUnitsAtMarker(m_pSkeletons, m_pEnemy, 5, "SKELETON2", nSkeletons);
			}
			else if ( GetDifficultyLevel() == difficultyHard )
			{
				m_pSkeletons = CreateUnitsAtMarker(m_pEnemy              , 4, "SKELETON3", nSkeletons);
                               CreateUnitsAtMarker(m_pSkeletons, m_pEnemy, 5, "SKELETON3", nSkeletons);
			}

			m_pSkeletons.EnableFeatures(disposeIfNoUnits, false);

			CommandMoveAndDefendPlatoonToUnit(m_pSkeletons, m_uHero);

			m_nSkeletons = nSkeletons*2;

			m_uScrag.RemoveUnit();
		}
		else if ( m_nDialogToPlay == dialogTempleKeeper )
		{
			EnableGoal(goalTemple, true);

			SetConsoleText("translate1_02_Console_ConvertToWolf");

			CommandMoveUnitToUnit(m_uTempleHelper, m_uBridge);
		}
		else if ( m_nDialogToPlay == dialogOldPriest )
		{
			SetGoalState(goalTemple, goalAchieved);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}

    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogFindWoman )
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
				lockCreateBuildPanel |
	//			lockCreatePanel |
	//			lockCreateMap |
				0);
		}

		SAFE_REMOVE_PRIEST();
		
		BEGIN_RESTORE_STATE_BLOCK()
			RESTORE_STATE(FindWomen)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		SetLowConsoleText("");

		START_TALK( Woodcutter   );
		START_TALK( TempleKeeper );
		START_TALK( TemplePriest );
		
		SET_DIALOG(FindWoman, FindWomen);
		
		return StartPlayDialog, 0;
	}
	
	state FindWomen
	{
		int x, y, z;
		unitex uTmp;
		platoon platSupport;

		if ( m_nWoodcutterStep == 1 )
		{
			if ( m_uHouse.GetHP()*2 >= m_uHouse.GetMaxHP() )
			{
				SetNeutrals(m_pVillage, m_pHouse);
				// m_uWoodcutter.DamageUnit(50);
				m_uWoodcutter.CommandSleepMode(true);

				++m_nWoodcutterStep;
			}

			if ( m_pPlayer.GetNumberOfUnits() <= 2 ) // tylko Hero i Mieszko
			{
				CreateObjectAtMarker(markerCrewStart, CREW_CREATE_EFFECT);
				platSupport = CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER", 3);
				CommandMovePlatoonToUnit(platSupport, m_uHero);
			}
		}
		else if ( m_nWoodcutterStep == 2 )
		{
			if ( m_uWoodcutter.GetHP()*2 >= m_uWoodcutter.GetMaxHP() )
			{
				// m_uWoodcutter.DamageUnit(10);
			}

			if ( m_uHouse.GetHP() == m_uHouse.GetMaxHP() )
			{
				m_uWoodcutter.CommandSleepMode(false);
				// m_uWoodcutter.RegenerateHP();
				m_uWoodcutter.CommandTurn(128);
				START_TALK( Woodcutter );

				SetConsoleText("");

				++m_nWoodcutterStep;
			}

			if ( m_pPlayer.GetNumberOfUnits() <= 2 ) // tylko Hero i Mieszko
			{
				CreateObjectAtMarker(markerCrewStart, CREW_CREATE_EFFECT);
				platSupport = CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER", 3);
				CommandMovePlatoonToUnit(platSupport, m_uHero);
			}
		}

		if ( m_nTempleKeeperStep == 1 )
		{
			z = m_uTempleKeeper.GetLocationZ();

			for ( x = m_uTempleKeeper.GetLocationX()-1; x <= m_uTempleKeeper.GetLocationX()+1; ++x )
			{
				for ( y = m_uTempleKeeper.GetLocationY()-1; y <= m_uTempleKeeper.GetLocationY()+1; ++y )
				{
					uTmp = GetUnit(x, y, z);

					if ( uTmp != null )
					{
						if ( uTmp.GetIFF() == m_pPlayer.GetIFF() && uTmp.IsAnimal() )
						{
							SetConsoleText("");

							m_uTempleGate.CommandBuildingSetGateMode(modeGateOpened);

							CommandMoveUnitToUnit(m_uTempleKeeper, m_uBridge);

							++m_nTempleKeeperStep;
						}
					}
				}
			}

			if ( m_pPlayer.GetNumberOfUnits() <= 2 ) // tylko Hero i Mieszko
			{
				CreateObjectAtMarker(markerCrewStart, CREW_CREATE_EFFECT);
				platSupport = CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER", 3);
				CommandMovePlatoonToUnit(platSupport, m_uHero);
			}
		}

		if ( IsUnitNearUnit(m_uHero, m_uWoodcutter, rangeTalk) && ! m_uHero.IsMoving() && ! m_uWoodcutter.IsMoving() && ! m_uWoodcutter.IsInSleepMode() )
		{
			if ( m_nWoodcutterStep == 0 )
			{
				STOP_TALK( Woodcutter );

				SET_DIALOG(WoodcutterRequest, FindWomen);

				m_pHouse.EnableAIFeatures(aiRejectAlliance, false);
				m_pPlayer.SetAlly(m_pHouse);

				++m_nWoodcutterStep;

				return StartPlayDialog, 0;
			}
			else if ( m_nWoodcutterStep == 3 )
			{
				STOP_TALK( Woodcutter );

				SET_DIALOG(WoodcutterConversation, FindWomen);

				++m_nWoodcutterStep;

				return StartPlayDialog, 0;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uTempleKeeper, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nTempleKeeperStep == 0 )
			{
				STOP_TALK( TempleKeeper );

				SET_DIALOG(TempleKeeper, FindWomen);

				++m_nTempleKeeperStep;

				return StartPlayDialog, 0;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uTemplePriest, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nTemplePriestStep == 0 )
			{
				STOP_TALK( TemplePriest );

				SET_DIALOG(OldPriest, FindWomen);

				++m_nTemplePriestStep;

				return StartPlayDialog, 0;
			}
		}

		if ( IsUnitNearMarker(m_uHero, markerDestination, 5) )
		{
			CREATE_PRIEST_NEAR_UNIT( Hero );

			m_uScrag = CreateUnitAtMarker(m_pNeutral, markerDestination, "KOSCIEJ");
			m_uScrag.SetUnitName("translate1_02_Name_Necromancer");

			SET_DIALOG(EndMission, MissionComplete);

			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerMieszkoEnd, 0);

			m_uEndGate.CommandBuildingSetGateMode(modeGateOpened);
			
			return StartPlayDialog, 0;
		}

		return FindWomen;
	}

	state FoundWomen
	{
		return MissionComplete;
	}

	state MissionComplete
	{
		if  (
			IsUnitNearMarker(m_uHero, markerHeroEnd, 0) && IsUnitNearMarker(m_uMieszko, markerMieszkoEnd, 0)
		 || IsUnitNearMarker(m_uMieszko, markerHeroEnd, 0) && IsUnitNearMarker(m_uHero, markerMieszkoEnd, 0)
			)
		{
			PlayTrack("Music\\RPGvictory.tws");

			m_bCheckHero = false;

			m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
			SAVE_PLAYER_UNITS();

			m_pSkeletons.Dispose();

			EndMission(true);
		}
	}

	state MissionFail
	{
		EndMission(false);

		return MissionFail;
	}

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
	{
		unitex uTmp;
		int nMarker;
		
		int nFromGx, nFromGy, nToGx, nToGy;
		int nRange, nRange2;

		if ( nArtefactNum & maskGateOpenSwitch )
		{
			nMarker = nArtefactNum & ~maskGateOpenSwitch;
			
			uTmp = GetUnitAtMarker( nMarker );
						
			uTmp.CommandBuildingSetGateMode(modeGateOpened);
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			return true;
		}

		return false;
	}

	event BuildingDestroyed(unitex uBuilding)
	{
		if ( uBuilding == m_uHouse )
		{
			SetGoalState(goalHut, goalFailed);

			MissionFailed();
		}
		else if ( uBuilding == m_uBridge )
		{
			MissionFailed();
		}
	}

	event UnitDestroyed(unitex uUnit)
	{
		unit uTmp;
		unitex uEnemy;

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

		if ( uUnit.GetIFF() == m_pVillage.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				MissionFailed();
			}
		}

		if ( state == MissionComplete && !IsUnitNearMarker(m_uHero, markerHeroEnd, 20) )
		{
			if ( uUnit.GetIFF() == m_pEnemy.GetIFF() )
			{
				if ( m_nSkeletons < 25 )
				{
					if ( GetDifficultyLevel() == difficultyEasy )
					{
						uEnemy = CreateUnitAtMarker(m_pEnemy, 4, "SKELETON1");
					}
					else if ( GetDifficultyLevel() == difficultyMedium )
					{
						uEnemy = CreateUnitAtMarker(m_pEnemy, 4, "SKELETON2");
					}
					else if ( GetDifficultyLevel() == difficultyHard )
					{
						uEnemy = CreateUnitAtMarker(m_pEnemy, 4, "SKELETON3");
					}
				}
				else
				{
					uEnemy = CreateUnitAtMarker(m_pEnemy, 4, "SKELETON4");
				}

				++m_nSkeletons;

				uEnemy.CommandMoveAndDefend(m_uHero.GetLocationX(), m_uHero.GetLocationY(), m_uHero.GetLocationZ());

				m_pSkeletons.AddUnitToPlatoon(uEnemy.GetUnitRef());
			}
		}
	}

	event Timer2()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		if ( state == MissionComplete && !IsUnitNearMarker(m_uHero, markerHeroEnd, 20) )
		{
			CommandMoveAndDefendPlatoonToUnit(m_pSkeletons, m_uHero);
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

			m_pPlayer.LookAt(GetLeft()+41,GetTop()+105,22,230,47,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 83);
				m_bRemovePriest = true;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uHero.CommandTurn(211);
				m_uMieszko = RestorePlayerUnitAtMarker(m_pPlayer, bufferMieszko, markerMieszkoStart);
				INITIALIZE_MIESZKO();

				m_bCheckHero = true;
			}
			if ( state == Start1 || state == Start2 || state == Start3 )
			{
				RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart);
				if ( m_pPlayer.GetSavedUnitsCount(bufferCrew) < 1 )
				{
					CreateUnitAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER");
				}
			}

			if ( m_uPriestObj != null && m_uPriestObj.IsLive() ) m_uPriestObj.RemoveUnit();
			if ( m_uHeroObj != null && m_uHeroObj.IsLive() ) m_uHeroObj.RemoveUnit();
			if ( m_uMieszkoObj != null && m_uMieszkoObj.IsLive() ) m_uMieszkoObj.RemoveUnit();
			if ( m_uCrewObj != null && m_uCrewObj.IsLive() ) m_uCrewObj.RemoveUnit();
			if ( m_uObj1 != null && m_uObj1.IsLive() ) m_uObj1.RemoveUnit();

			SetStateDelay(0);
			state Start;
		}
	}
	event Timer7()
	{
		StartWind();
	}
}
