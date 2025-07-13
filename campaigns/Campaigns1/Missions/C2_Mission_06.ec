#define MISSION_NAME "translate2_06"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_06_Dialog_
#include "Language\Common\timeMission2_06.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_06\\206_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start;
		state StartDialog;
		
		state Working;
		
		state MissionFail;
		state MissionComplete;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
		#include "..\..\Priest.ech"
	
	consts
		{
		goalMirkoMustSurvive     = 0;
		goalGiantMustSurvive     = 1;
		goalPrincessaMustSurvive = 2;
		goalDestroyEnemy         = 3;
		
		playerNeutral    =  0;
		playerPlayer     =  2;
		
		playerEnemy1     =  3;
		playerEnemy2     =  4;
		playerEnemy3     =  5;
		playerEnemy4     =  6;
		playerEnemy5     =  7;
		playerRuins      = 10;
		playerAnimals    = 14;
		
		playerPriest     =  2;
		
		markerHeroStart      =  0;
		markerCrewStart      =  1;
		markerPrincessaStart = 10;
		markerGiantStart     = 11;
		markerHeroDst        = 34;
		markerCrewDst        = 35;
		
		dialogBackToHome      = 1;
		dialogEndOfCampainTwo = 2;
		dialogMissionFail     = 9;
		
		rangeTalk = 1;
		rangeNear = 3;
		
		markerMan1    =  3;
		markerMan2    =  4;
		markerMan1Dst = 32;
		markerMan2Dst = 33;
		
		markerGate = 5;
		
		idTemple = 777;
		}
	
	// players ->
		player m_pPlayer;
		
		player m_pNeutral;
		player m_pRuins;
		
		player m_pEnemy1;
		player m_pEnemy2;
		player m_pEnemy3;
		player m_pEnemy4;
		player m_pEnemy5;
		player m_pAnimals;
	// units  ->
		unitex m_uHero;
		unitex m_uPrincessa;
		unitex m_uGiant;
		platoon m_pCrew;
		
		unitex m_uMan1;
		unitex m_uMan2;
		
		unitex m_uGate;	
	// vars ->
		int m_bCheckHero;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Player      );
		
		INITIALIZE_PLAYER( Neutral     );
		
		INITIALIZE_PLAYER( Enemy1  );
		INITIALIZE_PLAYER( Enemy2  );
		INITIALIZE_PLAYER( Enemy3  );
		INITIALIZE_PLAYER( Enemy4  );
		INITIALIZE_PLAYER( Enemy5  );
		INITIALIZE_PLAYER( Ruins   );
		INITIALIZE_PLAYER( Animals );
		
		m_pNeutral.EnableAI(false);
		m_pRuins.EnableAI(false);
		m_pEnemy5.EnableAI(false);
		
		INITIALIZE_PLAYER( Priest  );
		
		LoadAIScript(m_pEnemy1);
		LoadAIScript(m_pEnemy2);
		LoadAIScript(m_pEnemy3);
		LoadAIScript(m_pEnemy4);
		
		m_pEnemy1.SetMaxMoney(600);
		m_pEnemy1.SetMoney(600);		
		m_pEnemy2.SetMaxMoney(600);
		m_pEnemy2.SetMoney(600);
		m_pEnemy3.SetMaxMoney(600);
		m_pEnemy3.SetMoney(600);
		m_pEnemy4.SetMaxMoney(600);
		m_pEnemy4.SetMoney(600);
		
		m_pPlayer.SetMaxMoney(100);
		m_pPlayer.SetMoney(100);
		
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",4);
		m_pPlayer.SetMaxCountLimitForObject("COURT",1);
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pEnemy1);
		SetNeutrals(m_pNeutral, m_pEnemy2);
		SetNeutrals(m_pNeutral, m_pEnemy3);
		SetNeutrals(m_pNeutral, m_pEnemy4);
		SetNeutrals(m_pNeutral, m_pEnemy5);
		SetNeutrals(m_pNeutral, m_pAnimals);
		
		SetNeutrals(m_pEnemy1, m_pEnemy2);
		SetNeutrals(m_pEnemy1, m_pEnemy3);
		SetNeutrals(m_pEnemy1, m_pEnemy4);
		SetNeutrals(m_pEnemy1, m_pEnemy5);
		SetNeutrals(m_pEnemy1, m_pAnimals);

		SetNeutrals(m_pEnemy2, m_pEnemy3);
		SetNeutrals(m_pEnemy2, m_pEnemy4);
		SetNeutrals(m_pEnemy2, m_pEnemy5);
		SetNeutrals(m_pEnemy2, m_pAnimals);

		SetNeutrals(m_pEnemy3, m_pEnemy4);
		SetNeutrals(m_pEnemy3, m_pEnemy5);
		SetNeutrals(m_pEnemy3, m_pAnimals);

		SetNeutrals(m_pEnemy4, m_pEnemy5);
		SetNeutrals(m_pEnemy4, m_pAnimals);

		SetNeutrals(m_pEnemy5, m_pAnimals);

		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pEnemy3);
		SetEnemies(m_pPlayer, m_pEnemy4);
		SetEnemies(m_pPlayer, m_pEnemy5);
		SetEnemies(m_pPlayer, m_pAnimals);

		m_pPlayer.EnableResearchUpdate("SPEAR5"  , true); // 3
		m_pPlayer.EnableResearchUpdate("BOW5"    , true); // 3
		m_pPlayer.EnableResearchUpdate("SWORD3"  , true); // 3
		m_pPlayer.EnableResearchUpdate("AXE5"    , true); // 3
		m_pPlayer.EnableResearchUpdate("SHIELD2D", true); // 3
		m_pPlayer.EnableResearchUpdate("ARMOUR3A", true); // 3
		m_pPlayer.EnableResearchUpdate("HELMET3" , true); // 3

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST4"            , true); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH4"             , true); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS4", true); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL4"          , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD3"                , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE3"               , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_STORM3"                 , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION3"            , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN3"              , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING3"                , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION3"         , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST3"                 , true); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF3"                  , true); // 2

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST5"            , false); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH5"             , false); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS5", false); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL5"          , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD4"                , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE4"               , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_STORM4"                 , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION4"            , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN4"              , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING4"                , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION4"         , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST4"                 , false); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF4"                  , false); // 3

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
		
		platTmp.AddUnitsToPlatoon(x-1, y-1, x+1, y+1, z);
		
		return platTmp;
		}
	function int InitializeUnits()
		{
		int i;
		
		m_uPrincessa = RestorePlayerUnitAtMarker(m_pPlayer, bufferPrincessa, markerPrincessaStart);
		m_uGiant     = RestorePlayerUnitAtMarker(m_pPlayer, bufferGiant, markerGiantStart);
		m_uHero      = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		
		m_pPlayer.SortSavedUnitsBuffer(bufferCrew, sortUnitsByExperience);
		
		i =     RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "KNIGHT"  , 1  );
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "BANDIT"  , 2  );
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "FOOTMAN" , 5-i);
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "SPEARMAN", 4  );
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "HUNTER"  , 9-i);
		
		m_pPlayer.ResetSavedUnits(bufferCrew); // na wszelki wypadek
		
		ASSERT( m_uPrincessa != null);
		ASSERT( m_uGiant != null);
		
		m_pCrew = GetPlayerCrew();
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		INITIALIZE_UNIT( Man1 );
		INITIALIZE_UNIT( Man2 );
		
		INITIALIZE_UNIT( Gate );
		m_uGate.CommandBuildingSetGateMode(modeGateOpened);
		
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
		REGISTER_GOAL( GiantMustSurvive     );
		REGISTER_GOAL( PrincessaMustSurvive );
		REGISTER_GOAL( DestroyEnemy         );
		
		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalGiantMustSurvive, true);
		EnableGoal(goalPrincessaMustSurvive, true);
		
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

		EnableAssistant(0xffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		OnDifficultyLevelClearMarkers( difficultyEasy  , 12, 23, 0 );
		OnDifficultyLevelClearMarkers( difficultyEasy  , 29, 29, 0 );
		
		OnDifficultyLevelClearMarkers( difficultyMedium, 17, 17, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 19, 19, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 22, 23, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 13, 13, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 25, 26, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 28, 29, 0 );
		
		EnableAssistant(0xffffff, false);
		
		EnableInterface(false);
		
		SetTimer(2, 100);
		
		SetupTeleportBetweenMarkers(30, 31);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+198,GetTop()+35,16,198,52,0);
		ShowAreaAtMarker(m_pPlayer, markerHeroDst, 20);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate2_06_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+198,GetTop()+35,18,0,39,0,200,1);
		
		return Start, 50;
		}
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogBackToHome )
			{
			SetLowConsoleText("");
			
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Man1
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BackToHome
			#define DIALOG_LENGHT  2
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogEndOfCampainTwo )
			{
			KillArea(m_pEnemy1.GetIFF()|m_pEnemy2.GetIFF()|m_pEnemy3.GetIFF()|m_pEnemy4.GetIFF()|m_pEnemy5.GetIFF()|m_pAnimals.GetIFF(), GetPointX(6), GetPointY(6), GetPointZ(6), 15);
			
			m_uHero.SetImmediatePosition(GetPointX(6), GetPointY(6), GetPointZ(6), 0x40, true);
			m_uPrincessa.SetImmediatePosition(GetPointX(7), GetPointY(7), GetPointZ(7), 0x40, true);
			m_uGiant.SetImmediatePosition(GetPointX(8), GetPointY(8), GetPointZ(8), 0xc0, true);
			
			PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Giant
			#define DIALOG_NAME    EndOfCampainTwo
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
		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogBackToHome )
			{
			EnableGoal(goalDestroyEnemy, true);
			
			m_uGate.CommandBuildingSetGateMode(modeGateClosed);
			
			// m_uMan1.ChangePlayer(m_pPlayer);
			// m_uMan2.ChangePlayer(m_pPlayer);
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogBackToHome )
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
		CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
		CommandMoveUnitToMarker(m_uHero, markerHeroDst);
		CommandMoveUnitToMarker(m_uPrincessa, markerCrewDst);
		CommandMoveUnitToMarker(m_uGiant, markerCrewDst);
		CommandMoveUnitToMarker(m_uMan1, markerMan1Dst);
		CommandMoveUnitToMarker(m_uMan2, markerMan2Dst);
		
		return StartDialog, 200;
		}
	state StartDialog
		{
		SET_DIALOG(BackToHome, Working);
		
		return StartPlayDialog, 0;
		}
	state Working
		{
		if  (
			m_pEnemy1.GetNumberOfBuildings() == 0 &&
			m_pEnemy2.GetNumberOfBuildings() == 0 &&
			m_pEnemy3.GetNumberOfBuildings() == 0 &&
			m_pEnemy4.GetNumberOfBuildings() == 0
			)
			{
			SET_DIALOG(EndOfCampainTwo, MissionComplete);
			
			return StartPlayDialog, 0;
			}
		
		return Working;
		}
	state MissionComplete
		{
		EndMission(true);
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
			else if ( uUnit == m_uGiant )
				{
				SetGoalState(goalGiantMustSurvive, goalFailed);
				
				MissionFailed();
				}
			else if ( uUnit == m_uPrincessa )
				{
				SetGoalState(goalPrincessaMustSurvive, goalFailed);
				
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
		EndMission(true);
		}
    event EscapeCutscene()
    {
		if ( state == Start || state == StartDialog )
		{
			if ( state == Start )
			{
				CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
			}

			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+198,GetTop()+35,18,0,39,0);

			SetUnitAtMarker(m_uHero, markerHeroDst);
			SetUnitAtMarker(m_uPrincessa, markerCrewDst);
			SetUnitAtMarker(m_uGiant, markerCrewDst);
			SetUnitAtMarker(m_uMan1, markerMan1Dst);
			SetUnitAtMarker(m_uMan2, markerMan2Dst);

			SetStateDelay(0);
			state StartDialog;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
