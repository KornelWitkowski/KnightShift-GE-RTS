#define MISSION_NAME "translate1_01"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_01_Dialog_
#include "Language\Common\timeMission1_01.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_01\\101_"

mission MISSION_NAME
{
    state Initialize;
    state Start0;
    state Start;
//	state MoveUnit;
	state OpenGate;
	state OpeningGate;
	state GoToPriest;
	state GoToVillage;

	state BuildUpVillage;
	state Attack;
	state Fight;
	state Victory;
	state Defeat;

	state PrepareToMission;
	state SleepState;
	state ReturnFromMission;

	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts 
	{
        markerMirko = 0;
		markerPriest = 1;
		markerMapBorderMiddle = 2;
		markerVillage = 3;
		markerMapTopLeft = 4;
		markerMapBottomRight = 5;

		firstWolfMarker = 6;
		wolfMarkersNo = 6;
		markerWolfAttackPoint = 12;

		markerEnemyAttackPoint1 = 13;
		markerEnemyAttackPoint2 = 14;
		markerEnemyAttackPoint3 = 15;

		markerMissionStartMirko   = 16;
		markerMissionStartOthers  = 17;
		markerMissionStartOthersX = 51;
		markerMissionStartMieszko = 50;

		markerHeroEnd = 16;
		markerMieszkoEnd = 50;

		markerRemoveOnEasyFirst = 18;
		noOfUnitsToRemoveOnEasy = 11;

		markerRemoveOnMediumFirst = 29;
		noOfUnitsToRemoveOnMedium = 9;

		markerGate = 38;
		markerSwitch = 39;
		markerMapBorder1 = 40;
		markerMapBorder2 = 41;

		noOfWolfWavesOnEasy = 4;
		noOfWolfWavesOnMedium = 4;
		noOfWolfWavesOnHard = 4;

		noOfWolfsInWaveOnEasy = 4;
		noOfWolfsInWaveOnMedium = 4;
		noOfWolfsInWaveOnHard = 4;

		noOfEnemyWavesOnEasy = 3;
		noOfEnemyWavesOnMedium = 4;
		noOfEnemyWavesOnHard = 4;

		noOfEnemyUnitsInWaveOnEasy = 3;
		noOfEnemyUnitsInWaveOnMedium = 4;
		noOfEnemyUnitsInWaveOnHard = 3;

		goal_MirkoMustSurvive = 0;
		goal_MieszkoMustSurvive = 1;
		goal_FindPriest = 2;
		goal_FindVillage = 3;
		goal_BuildUpVillage = 4;
		goal_ProtectVillageFromWolfs = 5; 
		goal_ProtectVillageFromEnemies = 6; 
		goal_ProtectVillageFromMages = 7;
		
		questDefendFromWolf = 0;
		questDefendFromEnemies = 1;
		questDestroyEnemyVillage = 2;
		questDefendFromMages = 3;
		questDestroyMagesVillage = 4;
		questbuildNextVillage = 5;

		dialogFindPriest                = 1;
		dialogFindVillage               = 2;
		dialogBuildUpVillage            = 3;
		dialogProtectVillageFromWolfs   = 4;
		dialogProtectVillageFromEnemies = 5;
		dialogPrepareForMission2        = 6;
		dialogProtectVillageFromMages   = 7;
		dialogPrepareForMission3        = 8;
		dialogMissionFail               = 9;

		markerWoodcutter = 3;

		markerPriestGate = 44;

		playerPriest = 2;
    }

	player m_pNeutral;
	player m_pPlayer;
	player m_pEnemy;
	// player m_pEnemy2;
	player m_pEnemy3;
	player m_pVillage;

	unitex m_uMirko;
	unitex m_uGate;

	unitex m_uHero;

	unitex m_uMieszko;

	unitex m_uWoodcutter;

	unitex m_uPriestTalkSmoke;

	int m_nAttackWave;
	int m_nAttackStep;
	int m_bCheckNumberOfUnits;
	int m_bCheckMirko;
	int m_nCurrentQuest;
	int m_bShowQuestBriefing;
	
	unitex m_uPriestGate;

	platoon m_platEnemy;

    state Initialize
    {
		int i;
        platoon platoon1;
		
		TurnOffTier5Items();
		
		RegisterGoal(goal_MirkoMustSurvive,"translate1_01_Goal_MirkoMustSurvive");
		RegisterGoal(goal_MieszkoMustSurvive,"translate1_01_Goal_MieszkoMustSurvive");
		RegisterGoal(goal_FindPriest,"translate1_01_Goal_FindPriest");
		RegisterGoal(goal_FindVillage,"translate1_01_Goal_FindVillage");
		RegisterGoal(goal_BuildUpVillage,"translate1_01_Goal_BuildUpVillage");
		RegisterGoal(goal_ProtectVillageFromWolfs,"translate1_01_Goal_ProtectVillageFromWolfs");
		RegisterGoal(goal_ProtectVillageFromEnemies,"translate1_01_Goal_ProtectVillageFromEnemies");
		RegisterGoal(goal_ProtectVillageFromMages,"translate1_01_Goal_ProtectVillageFromMages");

		EnableGoal(goal_MirkoMustSurvive,true);
		EnableGoal(goal_MieszkoMustSurvive,true);
		
		m_pNeutral = GetPlayer(0);
		m_pEnemy = GetPlayer(1);
		m_pPlayer = GetPlayer(2);
		m_pVillage = GetPlayer(3);
		// m_pEnemy2 = GetPlayer(14);
		m_pEnemy3 = GetPlayer(4);

		m_pNeutral.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pVillage.EnableAI(false);
		m_pEnemy3.EnableAI(false);

		m_pNeutral.SetNeutral(m_pPlayer);
		m_pPlayer.SetNeutral(m_pNeutral);

		// m_pNeutral.SetNeutral(m_pEnemy2);
		// m_pEnemy2.SetNeutral(m_pNeutral);

		m_pNeutral.SetNeutral(m_pEnemy3);
		m_pEnemy3.SetNeutral(m_pNeutral);

		m_pEnemy.SetNeutral(m_pNeutral);
		m_pEnemy.SetNeutral(m_pVillage);
		m_pEnemy3.SetNeutral(m_pVillage);

		m_pVillage.SetNeutral(m_pPlayer);
		m_pPlayer.SetNeutral(m_pVillage);

		// SetNeutrals(m_pEnemy2, m_pEnemy3);
		// SetNeutrals(m_pEnemy2, m_pVillage);

		// SetNeutrals(m_pEnemy, m_pEnemy2);
		SetNeutrals(m_pEnemy, m_pEnemy3);
		SetNeutrals(m_pEnemy, m_pNeutral);
		SetNeutrals(m_pEnemy, m_pVillage);

		INITIALIZE_PLAYER( Priest );

		if ( GetDifficultyLevel() == difficultyEasy )
		{
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, 42, "MIESZKO_EASY", 64);
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, 42, "MIESZKO", 64);
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, 42, "MIESZKO_HARD", 64);
		}

		m_uMieszko.SetIsSingleUnit(true);

		m_uMieszko.SetExperienceLevel(2);

		m_uMirko = m_pPlayer.RestoreUnitAt( 0, GetPointX(markerMirko),  GetPointY(markerMirko),  0, true);
		ASSERT( m_uMirko != null );
		m_bCheckMirko=true;
//		m_uPriest = GetUnit(GetPointX(markerPriest),GetPointY(markerPriest),0);
		m_uPriest = CreateUnitAtMarker(m_pNeutral, markerPriest, "DOBROMIR");
		m_uGate = GetUnit(GetPointX(markerGate),GetPointY(markerGate),0);
		m_uGate.CommandBuildingSetGateMode(2);
        CallCamera();

		START_TALK( Priest );

		m_uPriestGate = GetUnit(GetPointX(markerPriestGate),GetPointY(markerPriestGate),0);
		m_uPriestGate.CommandBuildingSetGateMode(modeGateClosed);

		m_uHero = m_uMirko;
		m_uHero.CommandTurn(237);
		m_uMieszko.CommandTurn(109);
		
		m_uWoodcutter = GetUnit(GetPointX(markerWoodcutter),GetPointY(markerWoodcutter),0);

		m_pPlayer.SetMoney(0);
		m_pPlayer.SetMaxCountLimitForObject("SHEPHERD",0);
		m_pPlayer.SetMaxCountLimitForObject("PRIEST",0);
		m_pPlayer.SetMaxCountLimitForObject("WITCH",0);
//		m_pPlayer.SetMaxCountLimitForObject("CROSSBOWMAN",0);
		m_pPlayer.SetMaxCountLimitForObject("BARRACKS",0);
		m_pPlayer.SetMaxCountLimitForObject("COURT",0);
		m_pPlayer.SetMaxCountLimitForObject("TEMPLE",0);
		m_pPlayer.SetMaxCountLimitForObject("SHRINE",0);
		m_pPlayer.SetMaxCountLimitForObject("GATE2",0);
		m_pPlayer.SetMaxCountLimitForObject("DRAWBRIDGE2",0);
		m_pPlayer.SetMaxCountLimitForObject("TOWER2",0);

		m_pPlayer.SetMaxCountLimitForObject("PRIESTESS",0);
		m_pPlayer.SetMaxCountLimitForObject("KNIGHT",0);
		m_pPlayer.SetMaxCountLimitForObject("SORCERER",0);
		m_pPlayer.SetMaxCountLimitForObject("DIPLOMAT",0);
		m_pPlayer.SetMaxCountLimitForObject("FOOTMAN",0);
		m_pPlayer.SetMaxCountLimitForObject("SPEARMAN",0);

		m_pPlayer.EnableResearchUpdate("SPEAR3"  , false); // 1
		m_pPlayer.EnableResearchUpdate("BOW3"    , false); // 1
		m_pPlayer.EnableResearchUpdate("SWORD2"  , false); // 1
		m_pPlayer.EnableResearchUpdate("AXE3"    , false); // 1
		m_pPlayer.EnableResearchUpdate("SHIELD1C", false); // 1
		m_pPlayer.EnableResearchUpdate("ARMOUR2A", false); // 1
		m_pPlayer.EnableResearchUpdate("HELMET2" , false); // 1

		if(GetDifficultyLevel()==0)
		{
			for(i=markerRemoveOnEasyFirst; i<markerRemoveOnEasyFirst+noOfUnitsToRemoveOnEasy;i=i+1)
			{
				ClearArea(65535,GetPointX(i),GetPointY(i),0,0);
			}
			for(i=markerRemoveOnMediumFirst; i<markerRemoveOnMediumFirst+noOfUnitsToRemoveOnMedium;i=i+1)
			{
				ClearArea(65535,GetPointX(i),GetPointY(i),0,0);
			}
		}
		if(GetDifficultyLevel()==1)
		{
			for(i=markerRemoveOnMediumFirst; i<markerRemoveOnMediumFirst+noOfUnitsToRemoveOnMedium;i=i+1)
			{
				ClearArea(65535,GetPointX(i),GetPointY(i),0,0);
			}
		}
		
		SetTimer(1, 100);

		//SetGameRect(GetPointX(markerMapBorder1),GetPointY(markerMapBorder1),
		//	        GetPointX(markerMapBorder2),GetPointX(markerMapBorder2));

		//SetConsoleText(0,"translate1_01_Goal_MoveUnit");
        //platoon1 = m_pPlayer.CreatePlatoon(null, 26, 24, 29, 28, 0);
        //platoon1.CommandMove(50, 50, 0);
        //m_pEnemy.LoadScript("Single\\single");
        //m_pEnemy.PlayerCommand1(0);
        //m_pEnemy.PlayerCommand2(1);
        //m_pEnemy.PlayerCommand5(5);

		m_bRemovePriest = false;
        
		EnableAssistant(0xffffff, false);
		EnableAssistant(assistCreateGroup|assistCenterOnGroup, true);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+28,GetTop()+27,21,182,30,0);

		SetTimer(7, GetWindTimerTicks());
		StartWind();

		m_platEnemy = m_pEnemy.CreatePlatoon();
		m_platEnemy.EnableFeatures(disposeIfNoUnits, false);

		SaveGameRestart(null);

		return Start0, 1;
	}
	//---------------------------------------------------------
	state Start0
	{
		SetCutsceneText("translate1_01_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+28,GetTop()+27,13,39,37,0,170,1);

		m_nDialogToPlay = dialogFindPriest;
		m_nStateAfterDialog = Start;

		return StartPlayDialog, 170;
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

		SetStateDelay(0);
		state StartPlayDialog;

		return true;
	}

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindPriest )
		{
			SetLowConsoleText("");

			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mieszko
			#define DIALOG_NAME    FindPriest
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogFindVillage )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindVillage
			#define DIALOG_LENGHT  7

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogBuildUpVillage )
		{
			#define UNIT_NAME_FROM Woodcutter
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BuildUpVillage
			#define DIALOG_LENGHT  3

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromWolfs )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ProtectVillageFromWolfs
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromEnemies )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ProtectVillageFromEnemies
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogPrepareForMission2 )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    PrepareForMission2
			#define DIALOG_LENGHT  7

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromMages )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ProtectVillageFromMages
			#define DIALOG_LENGHT  3

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogPrepareForMission3 )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Priest
			#define DIALOG_NAME    PrepareForMission3
			#define DIALOG_LENGHT  7

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
		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogFindPriest )
		{
			EnableGoal(goal_FindPriest,true);
		}
		else if ( m_nDialogToPlay == dialogFindVillage )
		{
			SetGoalState(goal_FindPriest,goalAchieved);
			EnableGoal(goal_FindVillage,true);
		}
		else if ( m_nDialogToPlay == dialogBuildUpVillage )
		{
			EnableGoal(goal_BuildUpVillage,true);
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromWolfs )
		{
			SetGoalState(goal_BuildUpVillage,goalAchieved);
			EnableGoal(goal_ProtectVillageFromWolfs,true);
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromEnemies )
		{
			EnableGoal(goal_ProtectVillageFromEnemies,true);
		}
		else if ( m_nDialogToPlay == dialogProtectVillageFromMages )
		{
			EnableGoal(goal_ProtectVillageFromMages,true);
		}
		else if ( m_nDialogToPlay == dialogPrepareForMission2 )
		{
		EnableAssistant(0xffffff, false);
		SetConsoleText("translate1_01_Console_Teleports");
		}
		else if ( m_nDialogToPlay == dialogPrepareForMission3 )
		{
		EnableAssistant(0xffffff, false);
		SetConsoleText("translate1_01_Console_Teleports");
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

		if ( m_bRemovePriest ) RemovePriest();

		if ( m_nStateAfterDialog == Start )
		{
			return Start;
		}
		else if ( m_nStateAfterDialog == GoToVillage )
		{
			SetConsoleText("translate1_01_Goal_FindVillage");

			return GoToVillage;
		}
		else if ( m_nStateAfterDialog == BuildUpVillage )
		{
			return BuildUpVillage;
		}
		else if ( m_nStateAfterDialog == Attack )
		{
			return Attack;
		}
		else if ( m_nStateAfterDialog == PrepareToMission )
		{
			return PrepareToMission;
		}
		else if ( m_nStateAfterDialog == MissionFail )
		{
			return MissionFail;
		}
		else
		{
			TRACE1("Can't restore game state.");
		}
	}
	
	int m_nMisTime;

    state Start
	{
		SetConsoleText("translate1_01_Console_Selection");

		CreateArtefact("SWITCH_2_1", GetPointX(markerSwitch), GetPointY(markerSwitch), 0, 0);

		m_nMisTime = GetMissionTime();

		return OpenGate;
	}

	//---------------------------------------------------------
	state OpenGate
	{
		if ( GetMissionTime() > m_nMisTime + 60*20 )
		{
			SetConsoleText("translate1_01_Goal_OpenGate");
		}
		//if(m_uMirko.DistanceTo(GetPointX(markerSwitch),GetPointY(markerSwitch))==0)
		if(IsUnitNearPoint(GetPointX(markerSwitch),GetPointY(markerSwitch),0,0,4))
		{
			m_uGate.ChangePlayer(m_pPlayer);
			m_uGate.CommandBuildingSetGateMode(1);

			// ShowArea(4,GetPointX(markerGate)+1,GetPointY(markerGate), 0, 1,showAreaPassives|showAreaBuildings|showAreaUnits);

			m_nGameCameraZ = GetCameraZ();
			m_nGameCameraAlpha = GetCameraAlphaAngle();
			m_nGameCameraView = GetCameraViewAngle();

			m_pPlayer.LookAt(GetPointX(markerGate)+2,GetPointY(markerGate), 6, 0, 45, 0);
			EnableInterface(false);
			EnableCameraMovement(false);
			return OpeningGate,80;
		}
		return OpenGate;
	}

	//---------------------------------------------------------
	state OpeningGate
	{
		m_uGate.ChangePlayer(m_pNeutral);

		EnableInterface(true);
		EnableCameraMovement(true);
		RemoveArtefact(GetPointX(markerSwitch), GetPointY(markerSwitch), 0);
		//SetGameRect(GetPointX(markerMapTopLeft),GetPointY(markerMapTopLeft),
		//	    GetPointX(markerMapBorderMiddle),GetPointX(markerMapBottomRight));

//		AddBriefing(null,"translateC1_Mission_01_Briefing_FindPriest");

		PlayerLookAtUnit(m_pPlayer, m_uHero, m_nGameCameraZ, m_nGameCameraAlpha, m_nGameCameraView);

		SetConsoleText("translate1_01_Console_Hunters");

		m_nMisTime = GetMissionTime();

		return GoToPriest;
	
	}
	//---------------------------------------------------------
	state GoToPriest
	{
		if ( GetMissionTime() > m_nMisTime + 2*60*20 )
		{
			SetConsoleText("translate1_01_Goal_FindPriest");
		}
		else if ( GetMissionTime() > m_nMisTime + 60*20 )
		{
		SetConsoleText("translate1_01_Console_Shift");
		}

		if (!m_uPriest.IsLive())
		{
			MissionFailed();

			return StartPlayDialog;
		}
		if(m_uMirko.DistanceTo(GetPointX(markerPriest),GetPointY(markerPriest))<5)
		{
//			AddBriefing(null,"translateC1_Mission_01_Briefing_FindVillage");
			AddWorldMapSign(GetPointX(markerVillage), GetPointY(markerVillage), 0, 0, 65000);
			//SetGameRect(0,0,0,0);

			m_uPriestGate.CommandBuildingSetGateMode(modeGateOpened);

			m_nDialogToPlay = dialogFindVillage;
			m_nStateAfterDialog = GoToVillage;

			m_bRemovePriest = true;

			STOP_TALK( Priest );

			return StartPlayDialog;
//			return GoToVillage,20;
		}
		return GoToPriest,20;
	}
	//---------------------------------------------------------
	state GoToVillage
	{
		if(m_uMirko.DistanceTo(GetPointX(markerVillage),GetPointY(markerVillage))<6)
		{
			SetGoalState(goal_FindVillage,goalAchieved);
			m_pVillage.GiveAllBuildingsTo(m_pPlayer);
			m_pVillage.GiveAllUnitsTo(m_pPlayer);
			RemoveWorldMapSign(GetPointX(markerVillage), GetPointY(markerVillage), 0);
			m_bShowQuestBriefing = true;
			m_nCurrentQuest = questDefendFromWolf;

			EnableAssistant(0xffffff, true);
			EnableAssistant(assistBuildIncreaseHarvestSpeedUnit|assistBuildIncreaseBuildSpeedUnit, false);

			return BuildUpVillage,20;
		}
		return GoToVillage,20;
	}
	
	
	
	
	
	//---------------------------------------------------------
	state BuildUpVillage//*************************************
	{
		if(m_nCurrentQuest == questDefendFromWolf)
		{
//			TraceD("Number of buildings: ");
//			TraceD(m_pPlayer.GetNumberOfBuildings());
//			TraceD("               \n");

//			TraceD("Number of buildings Wall: ");
//			TraceD(m_pPlayer.GetNumberOfBuildings(buildingWall));
//			TraceD("               \n");

			if(m_bShowQuestBriefing)
			{
				m_bShowQuestBriefing = false;
				m_pPlayer.SetMoney(200);
				m_pPlayer.SetMaxDistance(25);
//				AddBriefing(null,"translateC1_Mission_01_Briefing_BuildUpVillage");
				SetConsoleText("translate1_01_Goal_BuildUpVillage");
				m_pPlayer.SetMaxCountLimitForObject("COWSHED",3); // bylo 3
				m_pPlayer.SetMaxCountLimitForObject("HUT",2);

				m_nDialogToPlay = dialogBuildUpVillage;
				m_nStateAfterDialog = BuildUpVillage;

				return StartPlayDialog;
			}
			if(m_pPlayer.GetNumberOfBuildings()>=5)
			{
//				AddBriefing(null,"translateC1_Mission_01_Briefing_ProtectVillageFromWolfs");
				SetConsoleText("translate1_01_Goal_ProtectVillageFromWolfs");
				m_pPlayer.SetMaxDistance(256);
				m_nAttackWave = 0;
				m_pPlayer.SetMaxCountLimitForObject("TOWER2",-1);

				m_nDialogToPlay = dialogProtectVillageFromWolfs;
				m_nStateAfterDialog = Attack;

				CREATE_PRIEST_NEAR_UNIT(Hero);

				return StartPlayDialog;
//				return Attack,200;
			}
		}
		if(m_nCurrentQuest == questDefendFromEnemies)
		{
			if(m_bShowQuestBriefing)
			{
				m_bShowQuestBriefing = false;
//				AddBriefing(null,"translateC1_Mission_01_Briefing_ProtectVillageFromEnemies");
				m_pPlayer.SetMaxCountLimitForObject("BARRACKS",2);
				m_pPlayer.SetMaxCountLimitForObject("GATE2",-1);
				m_pPlayer.SetMaxCountLimitForObject("DRAWBRIDGE2",-1);
				m_pPlayer.SetMaxCountLimitForObject("FOOTMAN",-1);
				m_pPlayer.SetMaxCountLimitForObject("SPEARMAN",-1);

				m_nDialogToPlay = dialogProtectVillageFromEnemies;
				m_nStateAfterDialog = BuildUpVillage;

				CREATE_PRIEST_NEAR_UNIT(Hero);

				return StartPlayDialog;
			}
			m_nAttackWave = m_nAttackWave - 1;
			SetConsoleText("translate1_01_Console_TimeToAttack",m_nAttackWave);
			if(m_nAttackWave < 1)
			{
				m_nAttackWave = 0;
				SetConsoleText("translate1_01_Goal_ProtectVillageFromEnemies");
				return Attack;	
			}
		}
		if(m_nCurrentQuest == questDefendFromMages)
		{
			if(m_bShowQuestBriefing)
			{
				m_bShowQuestBriefing = false;
				m_nAttackWave =240;
				SetConsoleText("");
//				AddBriefing(null,"translateC1_Mission_01_Briefing_ProtectVillageFromMages");
				m_pPlayer.SetMaxCountLimitForObject("COWSHED",3); // bylo 4
				m_pPlayer.SetMaxCountLimitForObject("HUT",4);
				m_pPlayer.SetMaxCountLimitForObject("BARRACKS",3);

				m_nDialogToPlay = dialogProtectVillageFromMages;
				m_nStateAfterDialog = BuildUpVillage;

				CREATE_PRIEST_NEAR_UNIT(Hero);

				return StartPlayDialog;
			}
	
			m_nAttackWave = m_nAttackWave - 1;
			SetConsoleText("translate1_01_Console_TimeToAttack",m_nAttackWave);
			if(m_nAttackWave < 1)
			{
				m_nAttackWave = 0;
				SetConsoleText("translate1_01_Goal_ProtectVillageFromMages");
				return Attack;	
			}
		}
		

		return BuildUpVillage;
	}
	//---------------------------------------------------------
	state WaitForAttack
	{
		--m_nAttackStep;

		if ( m_nAttackStep <= 0 )
		{
			return Attack;
		}
		else
		{
			return WaitForAttack;
		}
	}
	state Attack//*********************************************
	{
		int i;
		int nCreateMarker;
		int nMaxWaves;
		int nWaveUnits;

		if(m_nCurrentQuest == questDefendFromWolf)
		{
			if(GetDifficultyLevel()==0)
			{
				nMaxWaves = noOfWolfWavesOnEasy;
				nWaveUnits = noOfWolfsInWaveOnEasy;
			}
			if(GetDifficultyLevel()==1)
			{
				nMaxWaves = noOfWolfWavesOnMedium;
				nWaveUnits = noOfWolfsInWaveOnMedium;
			}
			if(GetDifficultyLevel()==2)
			{
				nMaxWaves = noOfWolfWavesOnHard;
				nWaveUnits = noOfWolfsInWaveOnHard;
			}

			nCreateMarker =	firstWolfMarker + (m_nAttackWave%wolfMarkersNo);
			
			if(nCreateMarker >= firstWolfMarker + wolfMarkersNo)
				nCreateMarker =	firstWolfMarker;
			
			if(GetDifficultyLevel()==0)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WOLF", nWaveUnits); 
			}
			if(GetDifficultyLevel()==1)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "BROWNWOLF", nWaveUnits); 
			}
			if(GetDifficultyLevel()==2)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WHITEWOLF", nWaveUnits); 
			}

			m_platEnemy.CommandMoveAndDefend(GetPointX(markerWolfAttackPoint),GetPointY(markerWolfAttackPoint),0);

			m_nAttackWave = m_nAttackWave + 1;

			if(m_nAttackWave>=nMaxWaves)
			{
				m_bCheckNumberOfUnits = false;
				return Fight;
			}
		}

		if(m_nCurrentQuest == questDefendFromEnemies)
		{
			if(GetDifficultyLevel()==0)
			{
				nMaxWaves = noOfEnemyWavesOnEasy;
				nWaveUnits = noOfEnemyUnitsInWaveOnEasy;
			}
			if(GetDifficultyLevel()==1)
			{
				nMaxWaves = noOfEnemyWavesOnMedium;
				nWaveUnits = noOfEnemyUnitsInWaveOnMedium;
			}
			if(GetDifficultyLevel()==2)
			{
				nMaxWaves = noOfEnemyWavesOnHard;
				nWaveUnits = noOfEnemyUnitsInWaveOnHard;
			}
//			TraceD("Enemy attack                      \n");
			nCreateMarker =	markerEnemyAttackPoint1 + (m_nAttackWave%3);

			if(GetDifficultyLevel() < 2)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WOODCUTTER", nWaveUnits); 
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "HUNTER"    , nWaveUnits); 
			}
			if(GetDifficultyLevel() == 2)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WOODCUTTER", nWaveUnits); 
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "FOOTMAN"   , nWaveUnits); 
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "SPEARMAN"  , nWaveUnits); 
			}

			m_platEnemy.CommandMoveAndDefend(GetPointX(markerWolfAttackPoint),GetPointY(markerWolfAttackPoint),0);

			m_nAttackWave = m_nAttackWave + 1;
			if(m_nAttackWave >= nMaxWaves)
			{
//				TraceD("Go to Fight                      \n");
				m_bCheckNumberOfUnits = false;
				return Fight;
			}
		}
		if(m_nCurrentQuest == questDefendFromMages)
		{
			if(GetDifficultyLevel()==0)
			{
				nMaxWaves = noOfEnemyWavesOnEasy;
				nWaveUnits = noOfEnemyUnitsInWaveOnEasy;
			}
			if(GetDifficultyLevel()==1)
			{
				nMaxWaves = noOfEnemyWavesOnMedium;
				nWaveUnits = noOfEnemyUnitsInWaveOnMedium;
			}
			if(GetDifficultyLevel()==2)
			{
				nMaxWaves = noOfEnemyWavesOnHard;
				nWaveUnits = noOfEnemyUnitsInWaveOnHard;
			}
//			TraceD("Mage attack                      \n");
			nCreateMarker =	markerEnemyAttackPoint1 + (m_nAttackWave%3);

			CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "PRIEST", 1); 

			if(GetDifficultyLevel() < 2)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WITCH", nWaveUnits); 
			}
			if(GetDifficultyLevel() == 2)
			{
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "WITCH"  , nWaveUnits); 
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "FOOTMAN", nWaveUnits); 
				CreateUnitsAtMarker(m_platEnemy, m_pEnemy, nCreateMarker, "PRIEST" , nWaveUnits); 
			}

			m_platEnemy.CommandMoveAndDefend(GetPointX(markerWolfAttackPoint),GetPointY(markerWolfAttackPoint),0);

			m_nAttackWave = m_nAttackWave + 1;
			if(m_nAttackWave>=nMaxWaves)
			{
//				TraceD("Go to Fight                      \n");
				m_bCheckNumberOfUnits = false;
				return Fight;
			}
		}
		
		m_nAttackStep = 40;
		return WaitForAttack;
		// return Attack,800;
	}

	//---------------------------------------------------------
	state Fight//**********************************************
	{
		// ClearArea (m_pEnemy.GetIFF(), GetPointX(markerEnemyAttackPoint1), GetPointY(markerEnemyAttackPoint1), GetPointZ(markerEnemyAttackPoint1), 16);
		// ClearArea (m_pEnemy.GetIFF(), GetPointX(markerEnemyAttackPoint2), GetPointY(markerEnemyAttackPoint2), GetPointZ(markerEnemyAttackPoint2), 16);
		// ClearArea (m_pEnemy.GetIFF(), GetPointX(markerEnemyAttackPoint3), GetPointY(markerEnemyAttackPoint3), GetPointZ(markerEnemyAttackPoint3), 16);

		if(m_nCurrentQuest == questDefendFromWolf)
		{
			if(m_bCheckNumberOfUnits)
			{
				// m_bCheckNumberOfUnits = false; // bo z plutonu nie od razu znikaja

				if( m_platEnemy.GetUnitsCount() == 0 )
				{
					SetConsoleText("");
					SetGoalState(goal_ProtectVillageFromWolfs,goalAchieved);
					return Victory,100;
				}
			}
		}

		if(m_nCurrentQuest == questDefendFromEnemies)
		{
			if(m_bCheckNumberOfUnits)
			{
				// m_bCheckNumberOfUnits = false; // bo z plutonu nie od razu znikaja

				if( m_platEnemy.GetUnitsCount() == 0 )
				{
					SetConsoleText("");
					SetGoalState(goal_ProtectVillageFromEnemies,goalAchieved);
					return Victory,100;
				}
			}
		}
		if(m_nCurrentQuest == questDefendFromMages)
		{
			if(m_bCheckNumberOfUnits)
			{
				// m_bCheckNumberOfUnits = false; // bo z plutonu nie od razu znikaja

				if( m_platEnemy.GetUnitsCount() == 0 )
				{
					SetConsoleText("");
					SetGoalState(goal_ProtectVillageFromMages,goalAchieved);
					return Victory,100;
				}
			}
		}

		if( ! IsPlayerUnitNearMarker(markerWolfAttackPoint, 14, m_pEnemy.GetIFF()) )
		{
			m_platEnemy.CommandMoveAndDefend(GetPointX(markerWolfAttackPoint),GetPointY(markerWolfAttackPoint),0);

			return Fight, 15*30;
		}

		return Fight;

	}
	//---------------------------------------------------------
	state Victory//********************************************
	{
		int i;
		int j;

		if(m_nCurrentQuest == questDefendFromWolf)
		{
			SetConsoleText("");
			SetGoalState(goal_ProtectVillageFromWolfs,goalAchieved);
			m_nCurrentQuest = questDefendFromEnemies;
			m_bShowQuestBriefing = true;
			m_nAttackWave = 240;
			return BuildUpVillage;
		}
		if(m_nCurrentQuest == questDefendFromEnemies)
		{
			SetConsoleText("");
			SetGoalState(goal_ProtectVillageFromEnemies,goalAchieved);
			m_nCurrentQuest = questDestroyEnemyVillage;
			m_bShowQuestBriefing = true;
			return PrepareToMission;
		}
		if(m_nCurrentQuest == questDefendFromMages)
		{
			SetConsoleText("");
			SetGoalState(goal_ProtectVillageFromMages,goalAchieved);
			m_nCurrentQuest = questDestroyMagesVillage;
			m_bShowQuestBriefing = true;
			return PrepareToMission;
		}	
	}
	//---------------------------------------------------------
	state Defeat//*********************************************
	{
		SetGoalState(goal_MirkoMustSurvive,goalFailed);

		MissionFailed();

		return StartPlayDialog;

	}
	//---------------------------------------------------------
	state PrepareToMission//***********************************
	{
		int i;
		int j;
		if(m_bShowQuestBriefing)
		{
			AddWorldMapSign(GetPointX(markerMissionStartMirko), GetPointY(markerMissionStartMirko), 0, 0, 65000);
			CreateArtefact("ARTIFACT_STARTMISSION_MIRKO", GetPointX(markerMissionStartMirko), GetPointY(markerMissionStartMirko), 0, 0);
			for(i=0;i<3;i=i+1)
			for(j=0;j<3;j=j+1)
			{
				CreateArtefact("ARTIFACT_STARTMISSION", i+GetPointX(markerMissionStartOthers), j+GetPointY(markerMissionStartOthers), 0, 1+i+j*3);
			}

			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerMissionStartMieszko, 0);
		}
		if(m_nCurrentQuest == questDestroyEnemyVillage)
		{
			if(m_bShowQuestBriefing)
			{
				m_bShowQuestBriefing = false;
//				AddBriefing(null,"translateC1_Mission_01_Briefing_PrepareForMission2");

				PlayTrack("Music\\RPGvictory.tws");

				m_nDialogToPlay = dialogPrepareForMission2;
				m_nStateAfterDialog = PrepareToMission;

				CREATE_PRIEST_NEAR_UNIT(Hero);

				return StartPlayDialog;
			}
			if  (
				IsUnitNearMarker(m_uHero, markerHeroEnd, 0) && IsUnitNearMarker(m_uMieszko, markerMieszkoEnd, 0)
			 || IsUnitNearMarker(m_uMieszko, markerHeroEnd, 0) && IsUnitNearMarker(m_uHero, markerMieszkoEnd, 0)
				)
			{
				m_bCheckMirko = false;
				m_pPlayer.SaveUnit(0,false,m_uMirko,true);
				m_pPlayer.SaveUnit(bufferMieszko,false,m_uMieszko,true);
				m_pPlayer.SaveUnitsFromArea( 1, false, GetPointX(markerMissionStartOthers), GetPointY(markerMissionStartOthers), GetPointX(markerMissionStartOthers)+2, GetPointY(markerMissionStartOthers)+2, 0, null, true);

				CreateArtefactAtMarker("ART_BOW2", 49, 0);

				SetConsoleText("");

				EnableNextMission(2,true);
				return ReturnFromMission,1;
			}
		}
		if(m_nCurrentQuest == questDestroyMagesVillage)
		{
			if(m_bShowQuestBriefing)
			{
				m_bShowQuestBriefing = false;
//				AddBriefing(null,"translateC1_Mission_01_Briefing_PrepareForMission3");

				PlayTrack("Music\\RPGvictory.tws");

				m_nDialogToPlay = dialogPrepareForMission3;
				m_nStateAfterDialog = PrepareToMission;

				CREATE_PRIEST_NEAR_UNIT(Hero);

				return StartPlayDialog;
			}
			if  (
				IsUnitNearMarker(m_uHero, markerHeroEnd, 0) && IsUnitNearMarker(m_uMieszko, markerMieszkoEnd, 0)
			 || IsUnitNearMarker(m_uMieszko, markerHeroEnd, 0) && IsUnitNearMarker(m_uHero, markerMieszkoEnd, 0)
				)
			{
				m_bCheckMirko = false;
				m_pPlayer.SaveUnit(0,false,m_uMirko,true);
				m_pPlayer.SaveUnit(bufferMieszko,false,m_uMieszko,true);
				m_pPlayer.SaveUnitsFromArea( 1, false, GetPointX(markerMissionStartOthers), GetPointY(markerMissionStartOthers), GetPointX(markerMissionStartOthers)+2, GetPointY(markerMissionStartOthers)+2, 0, null, true);
//				EnableNextMission(3,true);

				SetConsoleText("");

				m_platEnemy.Dispose();

				EndMission(true);
				return ReturnFromMission,1;
			}
		}
		
		return PrepareToMission;
			
	}
	//---------------------------------------------------------
	state SleepState//*****************************************
	{
		return SleepState;
	}
	//---------------------------------------------------------
	state ReturnFromMission//**********************************
	{
		int i;
		int j;

		EnableAssistant(0xffffff, true);
		EnableAssistant(assistBuildIncreaseHarvestSpeedUnit|assistBuildIncreaseBuildSpeedUnit, false);

		m_pPlayer.RestoreUnitsAt( 1, GetPointX(markerMissionStartOthers), GetPointY(markerMissionStartOthers), 0, true);
		m_uMirko = m_pPlayer.RestoreUnitAt( 0, GetPointX(markerMissionStartMirko),  GetPointY(markerMissionStartMirko),  0, true);
		ASSERT( m_uMirko != null );
		m_uMieszko = m_pPlayer.RestoreUnitAt( bufferMieszko, GetPointX(markerMissionStartMieszko),  GetPointY(markerMissionStartMieszko),  0, true);
		ASSERT( m_uMieszko != null );
		m_bCheckMirko = true;

		m_uHero = m_uMirko;
		
		m_pNeutral.SetNeutral(m_pPlayer);
		m_pPlayer.SetNeutral(m_pNeutral);

		// m_pNeutral.SetNeutral(m_pEnemy2);
		// m_pEnemy2.SetNeutral(m_pNeutral);

		m_pNeutral.SetNeutral(m_pEnemy3);
		m_pEnemy3.SetNeutral(m_pNeutral);

		m_pEnemy.SetNeutral(m_pNeutral);
		m_pEnemy.SetNeutral(m_pVillage);
		m_pEnemy3.SetNeutral(m_pVillage);

		m_pVillage.SetNeutral(m_pPlayer);
		m_pPlayer.SetNeutral(m_pVillage);

		// SetNeutrals(m_pEnemy2, m_pEnemy3);
		// SetNeutrals(m_pEnemy2, m_pVillage);

		// SetNeutrals(m_pEnemy, m_pEnemy2);
		SetNeutrals(m_pEnemy, m_pEnemy3);
		SetNeutrals(m_pEnemy, m_pNeutral);
		SetNeutrals(m_pEnemy, m_pVillage);

		RemoveArtefactAtMarker(markerMissionStartMieszko);
		RemoveArtefact(GetPointX(markerMissionStartMirko), GetPointY(markerMissionStartMirko), 0);
		RemoveWorldMapSign(GetPointX(markerMissionStartMirko), GetPointY(markerMissionStartMirko), 0);
		for(i=0;i<3;i=i+1)
		for(j=0;j<3;j=j+1)
		{
			RemoveArtefact(i+GetPointX(markerMissionStartOthers), j+GetPointY(markerMissionStartOthers), 0);
		}
		if(m_nCurrentQuest == questDestroyEnemyVillage)
		{
			m_nCurrentQuest = questDefendFromMages;
			m_bShowQuestBriefing = true;
			return BuildUpVillage;
		}
		if(m_nCurrentQuest == questDestroyMagesVillage)
		{
			m_pPlayer.SetMaxCountLimitForObject("TEMPLE",3);
			//m_nCurrentQuest = questDefendFromBears;!!!XXXMD to dodac
			m_bShowQuestBriefing = true;
			return BuildUpVillage;
		}
	}

	state MissionFail
	{
		EndMission(false);

		return MissionFail;
	}
	//---------------------------------------------------------
	event Timer1()
	{
		int iCountBuilding;

		iCountBuilding = m_pPlayer.GetNumberOfBuildings(buildingHarvestFactory);

		if(iCountBuilding<2) m_pPlayer.SetMaxMoney(100);
		if(iCountBuilding==2) m_pPlayer.SetMaxMoney(200);
		if(iCountBuilding==3) m_pPlayer.SetMaxMoney(300);
		if(iCountBuilding==4) m_pPlayer.SetMaxMoney(400);
	}

	//---------------------------------------------------------
	event UnitDestroyed(unitex uUnit)
	{
//		TraceD("UnitDestroyed\n");
		if ( uUnit.GetIFF() == m_pEnemy.GetIFF() ) m_bCheckNumberOfUnits = true;

		if ( m_bCheckMirko )
		{
			if ( uUnit == m_uHero )
			{
				SetGoalState(goal_MirkoMustSurvive, goalFailed);

				MissionFailed();
			}
			else if ( uUnit == m_uMieszko )
			{
				MissionFailed();
			}
		}
	}

	//---------------------------------------------------------
	event CustomEvent0(int k1,int k2,int k3,int k4) //XXXMD
    {
        if(k1==1) 
		{
			CallCamera();
			state ReturnFromMission;
		}
    }

	//---------------------------------------------------------
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
		m_bCheckMirko = false;

		m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);

		SetConsoleText("");

		if ( m_nCurrentQuest == questDefendFromMages || m_nCurrentQuest == questDestroyMagesVillage )
		{
			EndMission(true);
		}
		else
		{
			CreateArtefactAtMarker("ART_BOW2", 49, 0);

			EnableNextMission(2, true);

			m_nCurrentQuest = questDestroyEnemyVillage;
			state ReturnFromMission;
		}
	}

    event EscapeCutscene()
    {
		if ( state == StartPlayDialog && m_nStateAfterDialog == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+28,GetTop()+27,13,39,37,0);

			SetStateDelay(0);
			state StartPlayDialog;
		}
	}
	event Timer7()
	{
		StartWind();
	}
}
