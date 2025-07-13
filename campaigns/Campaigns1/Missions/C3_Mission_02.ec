#define MISSION_NAME "translate3_02"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_02_Dialog_
#include "Language\Common\timeMission3_02.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_02\\302_"

mission MISSION_NAME
{
	state Initialize;
	state Start00;
	state Start0;
	state Start;
	state MovePriest;
	state CloseGate;
	state GainArmour;
	state CompleteMission;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalMirkoMustSurvive = 0;
		goalGainArmour		= 1;

		markerHeroStart		= 0;
		markerCrewStart		= 1;
		markerPriest		= 3;
		markerArmour		= 4;
		
		markerMovePriest	= 5;
		markerGate			= 6;
		markerWoodcutter	= 7;

		markerHeroEnd		= 8;
		markerCrewEndFrom	= 9;
		markerCrewEndTo		= 10;

		markerEnemyPlatoon1	= 11;
		markerEnemyPlatoon2	= 12;

		markerKnightFirst	= 13;
		markerKnightLast	= 15;
		
		constStartLookAtHeight	= 15;

		constMaxLookAtHeight	= 23;
		constMaxLookAtView		= 32;

		rangeShowArea		= 6;
		rangeToPriest		= 4;
		rangeToWoodcutter	= 3;

		dialogTempleWithArmour	= 1;
		dialogVillage			= 2;
		dialogTheArmour			= 3;
		dialogMissionFail		= 4;

		idArmour = 1024;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pVillage;
	player m_pFriend;
	
	unitex m_uHero;
	unitex m_uWoodcutter;
	unitex m_uPriest1;
	unitex m_uWoodcutterTalkSmoke;

	platoon m_pEnemyPlatoon;
	platoon m_pPlayerPlatoon;

	int m_bCheckHero;
	int m_bCaptureVillage;

	int m_nNumberOfBarracks;
	int m_bTemple;
	int m_bCourt;

	int m_bEnemyPlatoon1;
	int m_bEnemyPlatoon2;
	int m_bEnemyPlatoon3;
	int m_bEnemyPlatoon4;


//------ FUNCTIONS -----------------------------------------------------------

	function int RegisterGoals()
	{
		RegisterGoal(goalMirkoMustSurvive , "translate3_02_Goal_MirkoMustSurvive");
		RegisterGoal(goalGainArmour, "translate3_02_Goal_GainArmour");

		EnableGoal(goalMirkoMustSurvive, true);
        return true;
	}

	function int ModifyDifficulty()
	{
		int i;
		unitex uTemp;

		int nDifficultyLevel;
		nDifficultyLevel = GetDifficultyLevel();

		for ( i=markerKnightFirst; i<=markerKnightLast; ++i)
		{
			uTemp = GetUnitAtMarker(i);
			uTemp.SetExperienceLevel(nDifficultyLevel);
		}
		
//		OnDifficultyLevelClearMarkers( difficultyEasy  , XX, XX, 0 );
//		OnDifficultyLevelClearMarkers( difficultyMedium, XX, XX, 0 );

		return true;
	}

	function int InitializePlayers()
	{
		m_pPlayer	= GetPlayer( 2);
		m_pPriest	= GetPlayer( 2);

		m_pVillage	= GetPlayer( 0);
		m_pEnemy	= GetPlayer( 1);
		m_pFriend	= GetPlayer( 5);
		
		m_pVillage.EnableAI(false);
		m_pFriend.EnableAI(false);
		m_pEnemy.EnableAI(true);

		LoadAIScript(m_pEnemy);
		m_pEnemy.EnableAIFeatures2(ai2ControlOffense,false);

		m_pVillage.SetSideColor(m_pPlayer.GetSideColor());
		
		SetNeutrals(m_pPlayer, m_pVillage);
		SetNeutrals(m_pVillage, m_pFriend);
		SetNeutrals(m_pPlayer, m_pFriend);
		SetNeutrals(m_pEnemy, m_pFriend);

		SetEnemies(m_pPlayer, m_pEnemy);

		SetAlly(m_pPlayer, m_pFriend);

		m_pPlayer.SetMaxMoney(400);
		m_pPlayer.SetMaxCountLimitForObject("COWSHED", 4);
		m_pPlayer.SetMaxCountLimitForObject("COURT", 1);
		m_pPlayer.SetMaxCountLimitForObject("TEMPLE",1);
		m_pPlayer.SetMaxCountLimitForObject("HUT",3);
		m_pPlayer.SetMaxCountLimitForObject("BARRACKS",3);
		m_pPlayer.SetMaxCountLimitForObject("SHRINE",2);
			
		m_pFriend.ResearchUpdate("SPELL_TELEPORTATION4"); // zeby m_uPriest1 sie teleportowal do swiatyni

		return true;
	}

	function platoon CreatePlatoon()
	{
		int i, j;

		platoon plTemp;
		unitex uTemp;

		plTemp = m_pPlayer.CreatePlatoon();
        plTemp.EnableFeatures(disposeIfNoUnits,true);
	
		for( i=-1; i<2; ++i)
		{
			for( j=-1; j<2; ++j)
			{
				uTemp = GetUnit( GetPointX(markerCrewStart)+i, GetPointY(markerCrewStart)+j, GetPointZ(markerCrewStart));
				if(uTemp != null)
				{
					plTemp.AddUnitToPlatoon(uTemp.GetUnitRef());						
				}
			}
		}
		return plTemp;
	}
	
	
	function int InitializeUnits()
	{
//		CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO");
				
		RESTORE_PLAYER_UNITS();

		m_uHero = GetUnitAtMarker( markerHeroStart );
		m_pPlayerPlatoon = CreatePlatoon();

		m_uPriest1 = GetUnitAtMarker( markerPriest );
		m_uWoodcutter = GetUnitAtMarker( markerWoodcutter );

		START_TALK( Woodcutter );
					
		m_bCheckHero = true;
		m_bCaptureVillage = false;

		return true;
	}


	function int InitializeArtefacts()
	{
		CreateArtefacts("ART_ARMOUR5",        markerArmour, markerArmour, 0       , false);	
		CreateArtefacts("ARTIFACT_INVISIBLE", markerArmour, markerArmour, idArmour, false);
		return true;
	}

	function int InitializeVariables()
	{
		m_nNumberOfBarracks = 0;
		m_bTemple = false;
		m_bCourt = false;

		m_bEnemyPlatoon1 = false;
		m_bEnemyPlatoon2 = false;
		m_bEnemyPlatoon3 = false;
		m_bEnemyPlatoon4 = false;

		return true;
	}

	function int MissionFailed()
	{	
		if ( state == MissionFail )
		{
			return false;
		}

		PlayTrack("Music\\defeat.tws");

		if ( m_uPriest == null )
		{
			CREATE_PRIEST_NEAR_UNIT( Hero );
		}

		PlayerLookAtUnit(m_pPlayer, m_uPriest, constStartLookAtHeight, constLookAtAlpha, constLookAtView);

		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;

		state StartPlayDialog;

		return true;
	}


//--------- STATES -----------------------------------------------------------------------------

    state Initialize
    {
		TurnOffTier5Items();
	
		CallCamera();

		InitializePlayers();
		InitializeUnits();
		InitializeArtefacts();
		InitializeVariables();
		ModifyDifficulty();

		RegisterGoals();

		
		ShowAreaAtMarker(m_pPlayer, markerHeroStart, rangeShowArea);
		ShowAreaAtMarker(m_pPlayer, markerPriest, 20);
		PlayerLookAtUnit(m_pPlayer, m_uHero, constStartLookAtHeight, constLookAtAlpha, constLookAtView);

		SetGameRect(0,0,0,0);

		CLOSE_GATE( markerGate );

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);

		SetTimer(7, 500);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		 //lookat 62,100,28,120,43,0
		m_pPlayer.LookAt(GetLeft()+62,GetTop()+100,28,120,43,0);
	

		SaveGameRestart(null);

		return Start00, 1;
	}


	state StartPlayDialog
	{
		
		if ( m_nDialogToPlay == dialogTempleWithArmour )
		{

			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Priest1
			#define DIALOG_NAME    TempleWithArmour
			#define DIALOG_LENGHT  9

			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay ==  dialogVillage )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Woodcutter 
			#define DIALOG_NAME    Village
			#define DIALOG_LENGHT  8

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogTheArmour )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    TheArmour
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
		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogTempleWithArmour )
		{
			EnableGoal(goalGainArmour, true);
			AddWorldMapSignAtMarker(markerArmour, 0, -1);
		}
		else if( m_nDialogToPlay == dialogVillage )
		{
			m_pVillage.GiveAllUnitsTo(m_pPlayer);
			m_pVillage.GiveAllBuildingsTo(m_pPlayer);
			m_pPlayer.SetMoney(200);

			//EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		}
		else if( m_nDialogToPlay == dialogTheArmour )
		{
			OPEN_GATE(markerGate);
			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}

	state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogTempleWithArmour )
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
			RESTORE_STATE(MovePriest)
			RESTORE_STATE(MissionFail)
			RESTORE_STATE(CompleteMission)
			RESTORE_STATE(GainArmour)
		END_RESTORE_STATE_BLOCK()
	}

	state Start00
	{
		SetCutsceneText("translate3_02_Cutscene_Start");
		//+1: delayedlookat 58,103,12,25,34,250,0
		m_pPlayer.DelayedLookAt(GetLeft()+58,GetTop()+103,12,25,34,0,250,0);
	
		return Start0, 250-80;

	}

	state Start0
	{
		m_uHero.CommandMove(GetPointX(markerPriest)+2, GetPointY(markerPriest), GetPointZ(markerPriest));

		return Start, 80;
	}	


	state Start
	{
		SetLowConsoleText("");

		m_nDialogToPlay = dialogTempleWithArmour;
		m_nStateAfterDialog = MovePriest;
		m_pPlayerPlatoon.CommandMove(GetPointX(markerHeroStart)+4, GetPointY(markerHeroStart)-1, 0);
		m_uHero.CommandTurn(m_uHero.GetAngleToTarget(m_uPriest1.GetUnitRef()));
		
		return StartPlayDialog, 0;
	}

	state MovePriest
	{
		int x, y, z;
		x = GetPointX(markerMovePriest);
		y = GetPointY(markerMovePriest)+3;

		ShowAreaAtMarker(m_pPlayer, markerMovePriest, rangeShowArea);

		PlayerAutoDirDelayedLookAt(m_pPlayer, x,  y, constMaxLookAtHeight, 100, constMaxLookAtView, 0, 10);
		m_uPriest1.CommandMove(GetPointX(markerMovePriest), GetPointY(markerMovePriest), GetPointZ(markerMovePriest));

		return CloseGate, 100;
	}

	state CloseGate
	{
		SetNeutrals(m_pPlayer, m_pFriend);
		PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
		
		CLOSE_GATE( markerGate );
		EnableInterface(true);
		EnableCameraMovement(true);
		return GainArmour, 20;
	}

	state GainArmour
	{
		if( !m_bCaptureVillage && IsUnitNearMarker(m_uHero, markerWoodcutter, rangeToWoodcutter) )
		{
			m_bCaptureVillage = true;

			STOP_TALK( Woodcutter );

			m_nDialogToPlay = dialogVillage;
			m_nStateAfterDialog = GainArmour;

			return StartPlayDialog, 1;
		}
		return GainArmour, 20;
	}

	state GainedArmour
	{	
		//if ( m_pFriend.GetNumberOfUnits() == 0 )
		//{	
			m_nDialogToPlay = dialogTheArmour;
			m_nStateAfterDialog = CompleteMission;
			return StartPlayDialog, 1;
		//}
		//return GainedArmour, 20;
	}

	state CompleteMission
	{		
		return CompleteMission, 20;
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

		if ( nArtefactNum == idArmour && uUnitOnArtefact == m_uHero )
		{
			SetGoalState(goalGainArmour, goalAchieved);
			RemoveWorldMapSignAtMarker( markerArmour );
			SetEnemies(m_pPlayer, m_pFriend);
			state GainedArmour;	
			return true;		
		}


		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
		{
			m_bCheckHero = false;
			SetGoalState(goalMirkoMustSurvive, goalAchieved);
			SAVE_PLAYER_UNITS();
			EndMission(true);
			state MissionComplete;
		}

		return false;
	}

	event BuildingCreated(unitex uBuilding)
	{
		int nBarrackNum;
		int nCourtNum;
		int nTempleNum;

		int nDifficultyLevel;
	
		if( m_pPlayer != null)
		{
			nBarrackNum = m_pPlayer.GetNumberOfBuildings("BARRACKS");
			nCourtNum = m_pPlayer.GetNumberOfBuildings("COURT");
			nTempleNum = m_pPlayer.GetNumberOfBuildings("TEMPLE");

			nDifficultyLevel = GetDifficultyLevel();
			
			if(nBarrackNum == 1 && !m_bEnemyPlatoon1)
			{
				m_bEnemyPlatoon1 = true;
				m_pEnemyPlatoon = CreateExpUnitsAtMarker(m_pEnemy, markerEnemyPlatoon1, "WOODCUTTER" , nDifficultyLevel, 3);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon1, "HUNTER", nDifficultyLevel, 2);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon1, "FOOTMAN", nDifficultyLevel, 1);											
				m_pEnemyPlatoon.CommandMove(GetPointX(markerWoodcutter),GetPointY(markerWoodcutter),0);
			}
			if(nBarrackNum == 3 && !m_bEnemyPlatoon2)
			{
				m_bEnemyPlatoon2 = true;				
				m_pEnemyPlatoon = CreateExpUnitsAtMarker(m_pEnemy, markerEnemyPlatoon1, "FOOTMAN" , nDifficultyLevel, 5);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon1, "HUNTER", nDifficultyLevel, 5);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon1, "WITCH", nDifficultyLevel, 3);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon1, "PRIESTESS", nDifficultyLevel, 3);
				m_pEnemyPlatoon.CommandMove(GetPointX(markerWoodcutter),GetPointY(markerWoodcutter),0);
			}
			if(nCourtNum == 1 && !m_bEnemyPlatoon3)
			{
				m_bEnemyPlatoon3 = true;
				m_pEnemyPlatoon = CreateExpUnitsAtMarker(m_pEnemy, markerEnemyPlatoon2, "KNIGHT" , nDifficultyLevel, 1);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon2, "PRIESTESS", nDifficultyLevel, 2);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon2, "HUNTER", nDifficultyLevel, 4);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon2, "PRIEST", nDifficultyLevel, 1);
				m_pEnemyPlatoon.CommandMove(GetPointX(markerWoodcutter),GetPointY(markerWoodcutter),0);
			}
			if(nTempleNum == 1 && !m_bEnemyPlatoon4)
			{	
				m_bEnemyPlatoon4 = true;
				m_pEnemyPlatoon = CreateExpUnitsAtMarker(m_pEnemy, markerEnemyPlatoon2, "FOOTMAN" , nDifficultyLevel, 3);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon2, "HUNTER", nDifficultyLevel, 4);
				CreateExpUnitsAtMarker(m_pEnemyPlatoon, m_pEnemy, markerEnemyPlatoon2, "SORCERER", nDifficultyLevel, 3);				
				m_pEnemyPlatoon.CommandMove(GetPointX(markerWoodcutter),GetPointY(markerWoodcutter),0);
			}
		}
	}


	event UnitDestroyed(unitex uUnit)
	{
		unit uTmp;

		if ( uUnit.GetIFF() == m_pVillage.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				m_pVillage.SetEnemy(m_pPlayer);
			}
		}
	
		if ( uUnit.GetIFF() == m_pFriend.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetEnemies(m_pFriend, m_pPlayer);
			}
		}


		if ( m_bCheckHero && uUnit == m_uHero )
		{
			SetGoalState(goalMirkoMustSurvive, goalFailed);
			MissionFailed();
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
		if ( state == Start0 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+58,GetTop()+103,12,25,34,0);

			SetUnitAtMarker(m_uHero, markerPriest, 2, 0);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		int nTime;
		nTime = 300+Rand(600);

		Snow(m_uHero.GetLocationX(), m_uHero.GetLocationY(), 50, 100, 100+nTime, 100, 5+Rand(6));

		Wind(100, 100+nTime, 100, 3, 0);
		SetTimer(7, nTime+Rand(900));
	}
}
