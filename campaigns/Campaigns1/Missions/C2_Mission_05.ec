#define MISSION_NAME "translate2_05"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_05_Dialog_
#include "Language\Common\timeMission2_05.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_05\\205_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start1;
		state Start1p5;
		state Start2;
		state Start3;
		state Start;
		
		state Working;
		
		state MissionFail;
		state BeforeMissionComplete;
		state MissionComplete;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
		#include "..\..\Priest.ech"
	
	consts
		{
		// goals ->
			goalMirkoMustSurvive     = 0;
			goalDestroyEnemyVillage1 = 1;
			goalDestroyEnemyVillage2 = 2;
			goalDestroyEnemyVillage3 = 3;
		// players ->		
			playerPlayer     =  2;
			
			playerEnemy1     =  1;
			playerEnemy2     =  3;
			playerEnemy3     =  4;
			
			playerPriest     =  2;
		// markers ->	
			markerHeroStart      = 0;
			markerCrewStart      = 1;
			markerPriestStart    = 2;
			markerHeroDst        = 3;
			markerCrewDst        = 4;
			
			markerHeroEnd      =  0;
			markerPrincessaEnd =  2;
			markerGiantEnd     =  3;
			
			markerCrewEndFrom = 1;
			markerCrewEndTo =   2;
		// dialogs ->
			dialogBegining    = 1;
			dialogEndMission  = 2;
			dialogMissionFail = 3;
		// params ->		
			rangeTalk     = 1;
			rangeNear     = 3;
			rangeShowArea = 20;
		// ids ->
			idTemple = 777;
		}
	
	// players ->
		player m_pPlayer;
		player m_pEnemy1;
		player m_pEnemy2;
		player m_pEnemy3;
	// units ->	
		unitex m_uHero;
		platoon m_pCrew;
	// vars ->	
		int m_bCheckHero;
		int m_bEnableControlTowers;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Player  );		
		
		INITIALIZE_PLAYER( Enemy1  );
		INITIALIZE_PLAYER( Enemy2  );
		INITIALIZE_PLAYER( Enemy3  );
		
		INITIALIZE_PLAYER( Priest  );
		
		LoadAIScript(m_pEnemy1);
		LoadAIScript(m_pEnemy2);
		LoadAIScript(m_pEnemy3);
		
		m_pEnemy1.SetMaxMoney(400);
		m_pEnemy2.SetMaxMoney(400);
		m_pEnemy3.SetMaxMoney(400);
		
		m_pEnemy1.SetMoney(400);
		m_pEnemy2.SetMoney(400);
		m_pEnemy3.SetMoney(400);
		
		m_pPlayer.SetMaxMoney(100);
		m_pPlayer.SetMoney(100);
		
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",4);
		m_pPlayer.SetMaxCountLimitForObject("COURT",1);
		
		m_pEnemy1.SetMaxCountLimitForObject("COWSHED",4);
		m_pEnemy1.SetMaxCountLimitForObject("COURT",1);
		
		m_pEnemy2.SetMaxCountLimitForObject("COWSHED",4);
		m_pEnemy2.SetMaxCountLimitForObject("COURT",1);
		
		m_pEnemy3.SetMaxCountLimitForObject("COWSHED",4);
		m_pEnemy3.SetMaxCountLimitForObject("COURT",1);
		
		if ( GetDifficultyLevel() == difficultyEasy )
			{
			m_pEnemy1.SetMaxCountLimitForObject("HUT"     ,4);
			m_pEnemy1.SetMaxCountLimitForObject("BARRACKS",2);
			m_pEnemy1.SetMaxCountLimitForObject("TEMPLE"  ,0);
			m_pEnemy1.SetMaxCountLimitForObject("SHRINE"  ,0);
			m_pEnemy2.SetMaxCountLimitForObject("HUT"     ,4);
			m_pEnemy2.SetMaxCountLimitForObject("BARRACKS",2);
			m_pEnemy2.SetMaxCountLimitForObject("TEMPLE"  ,0);
			m_pEnemy2.SetMaxCountLimitForObject("SHRINE"  ,0);
			m_pEnemy3.SetMaxCountLimitForObject("HUT"     ,4);
			m_pEnemy3.SetMaxCountLimitForObject("BARRACKS",2);
			m_pEnemy3.SetMaxCountLimitForObject("TEMPLE"  ,0);
			m_pEnemy3.SetMaxCountLimitForObject("SHRINE"  ,0);
			
			m_pEnemy1.EnableAIFeatures2(ai2ControlTowers, false);
			m_pEnemy2.EnableAIFeatures2(ai2ControlTowers, false);
			m_pEnemy3.EnableAIFeatures2(ai2ControlTowers, false);
			}
		else if ( GetDifficultyLevel() == difficultyMedium )
			{
			m_pEnemy1.SetMaxCountLimitForObject("TEMPLE",2);
			m_pEnemy1.SetMaxCountLimitForObject("SHRINE",0);
			m_pEnemy2.SetMaxCountLimitForObject("TEMPLE",2);
			m_pEnemy2.SetMaxCountLimitForObject("SHRINE",0);
			m_pEnemy3.SetMaxCountLimitForObject("TEMPLE",2);
			m_pEnemy3.SetMaxCountLimitForObject("SHRINE",0);
			
			m_pEnemy1.EnableAIFeatures2(ai2ControlTowers, false);
			m_pEnemy2.EnableAIFeatures2(ai2ControlTowers, false);
			m_pEnemy3.EnableAIFeatures2(ai2ControlTowers, false);
			}
		
		SetNeutrals(m_pEnemy1, m_pEnemy2);
		SetNeutrals(m_pEnemy1, m_pEnemy3);
		SetNeutrals(m_pEnemy2, m_pEnemy3);
		
		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pEnemy3);

		m_pPlayer.EnableResearchUpdate("SPEAR3"  , true); // 1
		m_pPlayer.EnableResearchUpdate("BOW3"    , true); // 1
		m_pPlayer.EnableResearchUpdate("SWORD2"  , true); // 1
		m_pPlayer.EnableResearchUpdate("AXE3"    , true); // 1
		m_pPlayer.EnableResearchUpdate("SHIELD1C", true); // 1
		m_pPlayer.EnableResearchUpdate("ARMOUR2A", true); // 1
		m_pPlayer.EnableResearchUpdate("HELMET2" , true); // 1

		m_pPlayer.EnableResearchUpdate("SPEAR4"  , false); // 2
		m_pPlayer.EnableResearchUpdate("BOW4"    , false); // 2
		m_pPlayer.EnableResearchUpdate("SWORD2A" , false); // 2
		m_pPlayer.EnableResearchUpdate("AXE4"    , false); // 2
		m_pPlayer.EnableResearchUpdate("SHIELD2" , false); // 2
		m_pPlayer.EnableResearchUpdate("ARMOUR3" , false); // 2
		m_pPlayer.EnableResearchUpdate("HELMET2A", false); // 2

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST3"            , false); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH3"             , false); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS3", false); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL3"          , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD2"                , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE2"               , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_STORM2"                 , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION2"            , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN2"              , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING2"                , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION2"         , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST2"                 , false); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF2"                  , false); // 1

		m_pPlayer.ResearchUpdate("SPELL_SHIELD");
		m_pPlayer.ResearchUpdate("SPELL_CAPTURE");
		m_pPlayer.ResearchUpdate("SPELL_CONVERSION");

		m_pEnemy1.ResearchUpdate("SPELL_SHIELD");
		m_pEnemy1.ResearchUpdate("SPELL_CAPTURE");
		m_pEnemy1.ResearchUpdate("SPELL_CONVERSION");

		m_pEnemy2.ResearchUpdate("SPELL_SHIELD");
		m_pEnemy2.ResearchUpdate("SPELL_CAPTURE");
		m_pEnemy2.ResearchUpdate("SPELL_CONVERSION");

		m_pEnemy3.ResearchUpdate("SPELL_SHIELD");
		m_pEnemy3.ResearchUpdate("SPELL_CAPTURE");
		m_pEnemy3.ResearchUpdate("SPELL_CONVERSION");

		return true;
		}
	function platoon GetPlayerCrew()
		{
		platoon platTmp;
		int x, y, z;
		
		platTmp = m_pPlayer.CreatePlatoon();
        platTmp.EnableFeatures(disposeIfNoUnits,true);
		
		x = GetPointX(markerCrewStart);
		y = GetPointY(markerCrewStart);
		z = GetPointZ(markerCrewStart);
		
		platTmp.AddUnitsToPlatoon(x-3, y-3, x+3, y+3, z);
		
		return platTmp;
		}
	function int InitializeUnits()
		{
		int nUnits;
		
		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		nUnits = RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart);
		
		m_pPlayer.ResetSavedUnits(bufferCrew); // na wszelki wypadek
		
		m_pCrew = GetPlayerCrew();
		
		if ( GetDifficultyLevel() == difficultyHard )
			{
				 if ( nUnits < 1 ) ClearMarkers(8, 9, 0);
			else if ( nUnits < 3 ) ClearMarkers(8, 8, 0);
			}
		else                       ClearMarkers(8, 9, 0);
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		// INITIALIZE_UNIT( Unit );
		
		// INITIALIZE_UNIT( Gate );
		// m_uGate.CommandBuildingSetGateMode(modeGateClosed);
		
		return true;
		}
	function int MissionFailed()
		{
		if ( state == MissionFail )
			{
			return false;
			}
		
		CREATE_PRIEST_NEAR_UNIT( Hero );
		
		PlayerLookAtUnit(m_pPlayer, m_uPriest, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;
		
		state StartPlayDialog;
		
		return true;
		}
	function int RegisterGoals()
		{
		REGISTER_GOAL( MirkoMustSurvive     );
		REGISTER_GOAL( DestroyEnemyVillage1 );
		REGISTER_GOAL( DestroyEnemyVillage2 );
		REGISTER_GOAL( DestroyEnemyVillage3 );
		
		EnableGoal(goalMirkoMustSurvive, true);
		
		return true;
		}
	
	event Timer2() // update max money
		{
		int iCountBuilding;
		
		iCountBuilding = m_pPlayer.GetNumberOfBuildings(buildingHarvestFactory);
		
		if(iCountBuilding<2) m_pPlayer.SetMaxMoney(100);
		if(iCountBuilding==2) m_pPlayer.SetMaxMoney(200);
		if(iCountBuilding==3) m_pPlayer.SetMaxMoney(300);
		if(iCountBuilding==4) m_pPlayer.SetMaxMoney(400);
		}
	event Timer5() // support team ;)
		{
		platoon platTmp;
		
		platTmp = CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "COW"     , 2);
		CreateUnitsAtMarker(platTmp,  m_pPlayer, markerCrewStart, "SHEPHERD", 1);
		
		CommandMovePlatoonToMarker(platTmp, markerCrewDst);
		
		SetTimer(5, 0);
		}
	
	state Initialize
		{
		TurnOffTier5Items();
		
		CallCamera();
		
		InitializePlayers();
		InitializeUnits();
		
		RegisterGoals();
		
		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		SetTimer(2, 100);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+93,GetTop()+92,18,16,59,0);
		
		ShowAreaAtMarker(m_pPlayer, 5, rangeShowArea);
		ShowAreaAtMarker(m_pPlayer, 6, rangeShowArea);
		ShowAreaAtMarker(m_pPlayer, 7, rangeShowArea);
		
		m_bEnableControlTowers = true;
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate2_05_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+112,GetTop()+57,18,16,59,0,150,0);
		
		return Start1, 30;
		}
	state Start1
		{
		CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
		CommandMoveUnitToMarker(m_uHero, markerHeroDst);
		
		return Start1p5, 30;
		}
	state Start1p5
		{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		
		return Start2, 90;
		}
	state Start2
		{
		SetLowConsoleText("");
		
		m_pPlayer.DelayedLookAt(GetLeft()+117,GetTop()+45,18,217,43,0,100,0);
		
		return Start3, 100;
		}
	state Start3
		{
		m_pPlayer.DelayedLookAt(GetLeft()+117,GetTop()+45,17,216,43,0,30,0);
		
		return Start, 30;
		}
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogBegining )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Begining
			#define DIALOG_LENGHT  8
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		if ( m_nDialogToPlay == dialogEndMission )
			{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
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
		
		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogBegining )
			{
			EnableGoal(goalDestroyEnemyVillage1, true);
			EnableGoal(goalDestroyEnemyVillage2, true);
			EnableGoal(goalDestroyEnemyVillage3, true);
			
			platTmp = CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "WOODCUTTER", 2);
			CreateUnitsAtMarker(platTmp, m_pPlayer, markerCrewStart, "DIPLOMAT", 1);
			CommandMovePlatoonToMarker(platTmp, markerCrewDst);
			
			SetTimer(5, 450);
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogBegining )
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
			lockToolbarLevelName |
			0);
			}
		
		SAFE_REMOVE_PRIEST();
		
		BEGIN_RESTORE_STATE_BLOCK()
		RESTORE_STATE(Working)
		RESTORE_STATE(MissionComplete)
		RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
		}
	state Start
		{
		SET_DIALOG(Begining, Working);
		
		return StartPlayDialog, 0;
		}
	state Working
		{
		if ( m_bEnableControlTowers && GetMissionTime() > 10*60*20 )
			{
			m_pEnemy1.EnableAIFeatures2(ai2ControlTowers, true);
			m_pEnemy2.EnableAIFeatures2(ai2ControlTowers, true);
			m_pEnemy3.EnableAIFeatures2(ai2ControlTowers, true);
			
			m_bEnableControlTowers = false;
			}
		
		if ( GetGoalState(goalDestroyEnemyVillage1) != goalAchieved && m_pEnemy1.GetNumberOfBuildings() == m_pEnemy1.GetNumberOfBuildings(buildingTower) )
			{
			SetGoalState(goalDestroyEnemyVillage1, goalAchieved);
			m_pEnemy1.EnableAI(false);
			}
		if ( GetGoalState(goalDestroyEnemyVillage2) != goalAchieved && m_pEnemy2.GetNumberOfBuildings() == m_pEnemy2.GetNumberOfBuildings(buildingTower) )
			{
			SetGoalState(goalDestroyEnemyVillage2, goalAchieved);
			m_pEnemy2.EnableAI(false);
			}
		if ( GetGoalState(goalDestroyEnemyVillage3) != goalAchieved && m_pEnemy3.GetNumberOfBuildings() == m_pEnemy3.GetNumberOfBuildings(buildingTower) )
			{
			SetGoalState(goalDestroyEnemyVillage3, goalAchieved);
			m_pEnemy3.EnableAI(false);
			}
		
		if ( GetGoalState(goalDestroyEnemyVillage1) == goalAchieved && GetGoalState(goalDestroyEnemyVillage2) == goalAchieved && GetGoalState(goalDestroyEnemyVillage3) == goalAchieved )
			{
			return BeforeMissionComplete, 300;
			}
		
		return Working;
		}
	state BeforeMissionComplete
		{
		CREATE_PRIEST_NEAR_UNIT( Hero );
		
		SET_DIALOG(EndMission, MissionComplete);
		
		return StartPlayDialog, 0;
		}
	state MissionComplete
		{
		m_bCheckHero = false;
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		EndMission(true);
		
		return MissionComplete;
		}
	state MissionFail
		{
		EndMission(false);
		}
	
	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
		{
		if ( pPlayerOnArtefact != m_pPlayer )
			{
			return false;
			}
		
		return false;
		}
	event UnitDestroyed(unitex uUnit)
		{
		unit uTmp;
		
		if ( m_bCheckHero )
			{
			if ( uUnit == m_uHero )
				{
				SetGoalState(goalMirkoMustSurvive, goalFailed);
				
				MissionFailed();
				}
			}
		}
	event BuildingDestroyed(unitex uBuilding)
		{
		if ( m_bEnableControlTowers && uBuilding.GetIFF() != m_pPlayer.GetIFF() )
			{
			m_pEnemy1.EnableAIFeatures2(ai2ControlTowers, true);
			m_pEnemy2.EnableAIFeatures2(ai2ControlTowers, true);
			m_pEnemy3.EnableAIFeatures2(ai2ControlTowers, true);
			
			m_bEnableControlTowers = false;
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
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		SetConsoleText("");
		
		EndMission(true);
		}
    event EscapeCutscene()
    {
		if ( state == Start1 || state == Start1p5 || state == Start2 || state == Start3 || state == Start )
		{
			if ( state == Start1 )
			{
				CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
			}

			if ( state == Start1 || state == Start1p5 )
			{
				CreatePriestAtMarket(m_pPriest, markerPriestStart);
			}

			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+117,GetTop()+45,17,216,43,0);

			SetUnitAtMarker(m_uHero, markerHeroDst);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
