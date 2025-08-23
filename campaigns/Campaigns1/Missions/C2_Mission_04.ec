#define MISSION_NAME "translate2_04"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_04_Dialog_
#include "Language\Common\timeMission2_04.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_04\\204_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start1;
		state Start;
		
		state Working;
		
		state MissionFail;
		state BeforeMissionComplete;
		state BeforeMissionComplete1;
		state BeforeMissionComplete2;
		state BeforeMissionComplete3;
		state MissionComplete;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
		#include "..\..\Priest.ech"
	
	consts
		{
		// goals ->
			goalMirkoMustSurvive     = 0;
			goalGiantMustSurvive     = 1;
			goalPrincessaMustSurvive = 2;
			goalDefendVillage        = 3;
		// players ->		
			playerNeutral    =  0;
			playerPlayer     =  2;
			
			playerEnemy1     =  3;
			playerEnemy2     =  4;
			playerEnemy3     =  1;
			playerEnemyX     =  5;
			
			playerPriest     =  2;
		// markers ->	
			markerHeroStart      =  0;
			markerCrewStart      =  3;
			markerPrincessaStart =  1;
			markerGiantStart     =  2;
			markerHeroDst        = 15;
			markerCrewDst        = 18;
			markerPrincessaDst   = 16;
			markerGiantDst       = 17;
			
			markerHeroEnd      = 0;
			markerPrincessaEnd = 1;
			markerGiantEnd     = 2;
			
			markerCrewEndFrom = 3;
			markerCrewEndTo =   4;
			
			markerDarkPriest = 9;
			
			markerMag = 5;
		// dialogs ->
			dialogWoundedGiant  = 1;
			dialogEndFirstPart  = 2;
			dialogEndSecondPart = 3;
			dialogEndMission    = 4;
			dialogMissionFail   = 5;
		// params ->		
			rangeTalk = 1;
			rangeNear = 3;
		// ids ->
			idTemple = 777;
		}
	
	// players ->
		player m_pPlayer;
		player m_pNeutral;
		
		player m_pEnemy1;
		player m_pEnemy2;
		player m_pEnemy3;
		player m_pEnemyX;
	// units ->	
		unitex m_uHero;
		platoon m_pCrew;
		unitex m_uPrincessa;
		unitex m_uGiant;
		
		unitex m_uDarkPriest;
		
		unitex m_uMag;
	// vars ->	
		int m_bCheckHero;
		
		int m_nTimeToEnd;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Player      );
		
		INITIALIZE_PLAYER( Enemy1      );
		INITIALIZE_PLAYER( Enemy2      );
		INITIALIZE_PLAYER( Enemy3      );
		INITIALIZE_PLAYER( EnemyX      );
		
		INITIALIZE_PLAYER( Neutral     );
		
		m_pNeutral.EnableAI(false);
		m_pEnemyX.EnableAI(false);
		
		LoadAIScript(m_pEnemy1);
		LoadAIScript(m_pEnemy2);
		LoadAIScript(m_pEnemy3);

		m_pEnemy1.SetStartAttacksTime(20*60*1);
		m_pEnemy2.SetStartAttacksTime(20*60*3);
		m_pEnemy3.SetStartAttacksTime(20*60*5);
		
		m_pEnemy1.SetThinkSpeed(aiThinkSpeedMakeSmallAttack, 20*60*3);
		m_pEnemy1.SetThinkSpeed(aiThinkSpeedMakeBigAttack, 20*60*7);

		m_pEnemy2.SetThinkSpeed(aiThinkSpeedMakeSmallAttack, 20*60*3);
		m_pEnemy2.SetThinkSpeed(aiThinkSpeedMakeBigAttack, 20*60*7);

		m_pEnemy3.SetThinkSpeed(aiThinkSpeedMakeSmallAttack, 20*60*3);
		m_pEnemy3.SetThinkSpeed(aiThinkSpeedMakeBigAttack, 20*60*7);

		m_pEnemy1.SetMaxMoney(400);
		m_pEnemy2.SetMaxMoney(400);
		m_pEnemy3.SetMaxMoney(400);
		
		m_pEnemy1.SetMoney(400);
		m_pEnemy2.SetMoney(400);
		m_pEnemy3.SetMoney(400);
		
		m_pNeutral.EnableAI(false);
		
		m_pEnemy1.SetMaxCountLimitForObject("COURT",0);
		m_pEnemy2.SetMaxCountLimitForObject("COURT",0);
		m_pEnemy3.SetMaxCountLimitForObject("COURT",0);
		
		if ( GetDifficultyLevel() == difficultyEasy )
			{
			m_pEnemy1.SetMaxCountLimitForObject("COW",7);
			m_pEnemy2.SetMaxCountLimitForObject("COW",7);
			m_pEnemy3.SetMaxCountLimitForObject("COW",7);
			
			ClearMarkers(11, 14, 0);
			}
		else if ( GetDifficultyLevel() == difficultyMedium )
			{
			m_pEnemy1.SetMaxCountLimitForObject("COW",9);
			m_pEnemy2.SetMaxCountLimitForObject("COW",9);
			m_pEnemy3.SetMaxCountLimitForObject("COW",9);
			
			ClearMarkers(13, 13, 0);
			}
		
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",4);
		m_pPlayer.SetMaxCountLimitForObject("COURT",1);
		
		m_pPlayer.SetMaxMoney(100);
		m_pPlayer.SetMoney(100);
		
		INITIALIZE_PLAYER( Priest  );
		
		SetNeutrals(m_pEnemyX, m_pEnemy1);
		SetNeutrals(m_pEnemyX, m_pEnemy2);
		SetNeutrals(m_pEnemyX, m_pEnemy3);
		
		SetNeutrals(m_pEnemy1, m_pEnemy2);
		SetNeutrals(m_pEnemy1, m_pEnemy3);
		
		SetNeutrals(m_pEnemy2, m_pEnemy3);

		SetEnemies(m_pPlayer, m_pEnemyX);
		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pEnemy3);
		
		SetAlly(m_pPlayer, m_pNeutral);
		
		m_pPlayer.EnableResearchUpdate("SPEAR4"  , true); // 2
		m_pPlayer.EnableResearchUpdate("BOW4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SWORD2A" , true); // 2
		m_pPlayer.EnableResearchUpdate("AXE4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SHIELD2" , true); // 2
		m_pPlayer.EnableResearchUpdate("ARMOUR3" , true); // 2
		m_pPlayer.EnableResearchUpdate("HELMET2A", true); // 2

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST3"            , true); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH3"             , true); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS3", true); // 1
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL3"          , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD2"                , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE2"               , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_STORM2"                 , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION2"            , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN2"              , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING2"                , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION2"         , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST2"                 , true); // 1
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF2"                  , true); // 1

		m_pPlayer.EnableResearchUpdate("SPEAR5"  , false); // 3
		m_pPlayer.EnableResearchUpdate("BOW5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SWORD3"  , false); // 3
		m_pPlayer.EnableResearchUpdate("AXE5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SHIELD2D", false); // 3
		m_pPlayer.EnableResearchUpdate("ARMOUR3A", false); // 3
		m_pPlayer.EnableResearchUpdate("HELMET3" , false); // 3

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST4"            , false); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH4"             , false); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS4", false); // 2
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL4"          , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD3"                , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE3"               , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_STORM3"                 , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION3"            , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN3"              , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING3"                , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION3"         , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST3"                 , false); // 2
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF3"                  , false); // 2

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
		m_uPrincessa = RestorePlayerUnitAtMarker(m_pPlayer, bufferPrincessa, markerPrincessaStart);
		m_uGiant     = RestorePlayerUnitAtMarker(m_pPlayer, bufferGiant, markerGiantStart);
		m_uHero      = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart);
		
		m_pPlayer.ResetSavedUnits(bufferCrew); // na wszelki wypadek
		
		ASSERT( m_uPrincessa != null);
		ASSERT( m_uGiant != null);

		m_pCrew = GetPlayerCrew();
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		INITIALIZE_UNIT( DarkPriest );
		INITIALIZE_UNIT( Mag        );
		
		SetRealImmortal(m_uDarkPriest, true);
		
		m_uGiant.CommandSetMovementMode(modeHoldPos);
		m_uMag.CommandSetMovementMode(modeHoldPos);
		
		SetRealImmortal(m_uMag, true);

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
		REGISTER_GOAL( DefendVillage        );
		
		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalGiantMustSurvive, true);
		EnableGoal(goalPrincessaMustSurvive, true);
		
		return true;
		}
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogWoundedGiant )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mag
			#define DIALOG_NAME    WoundedGiant
			#define DIALOG_LENGHT  10
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogEndFirstPart )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Giant
			#define DIALOG_NAME    EndFirstPart
			#define DIALOG_LENGHT  3
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogEndSecondPart )
			{
			#define DO_FULL_SAVE
			
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Mag
			#define DIALOG_NAME    EndSecondPart
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogEndMission )
			{
			ADD_STANDARD_TALK(Hero, Hero, EndMission_01);
			
			PlayTalkDefinition();
			
			PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
			
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
		if ( m_nDialogToPlay == dialogEndSecondPart )
			{
			ShowAreaAtMarker(m_pPlayer, markerDarkPriest, 256);
			SetAlly(m_pPlayer, m_pEnemyX);
			SetAlly(m_pPlayer, m_pEnemy1);
			SetAlly(m_pPlayer, m_pEnemy2);
			SetAlly(m_pPlayer, m_pEnemy3);
			
			m_uMag.CommandMakeCustomAnimation(2, true, false, 5, 0, 0);
			CreateObjectAtMarker(6, "SUMMONING_PRINCE");
			
			return BeforeMissionComplete, 80;
			}
		else if ( m_nDialogToPlay == dialogEndFirstPart )
			{
			RestoreTalkInterface(m_pPlayer, m_uGiant);
			}
		else
			{
			RestoreTalkInterface(m_pPlayer, m_uHero);
			}
		
		if ( m_nDialogToPlay == dialogWoundedGiant )
			{
			EnableGoal(goalDefendVillage, true);
			
			m_bCheckHero = false;
			m_uGiant.ChangePlayer(m_pNeutral);
			SetRealImmortal(m_uGiant, true);
			m_bCheckHero = true;
			
			m_uGiant.BeginQuickRecord();
			CommandMoveUnitToMarker(m_uGiant, 6, 0, -2);
			m_uGiant.CommandTurn(128);
			m_uGiant.EndQuickRecord();
			
			m_uMag.BeginQuickRecord();
			CommandMoveUnitToMarker(m_uMag, 6);
			m_uMag.CommandTurn(0);
			m_uMag.CommandMakeCustomAnimation(2, true, false, 15*60, 0, 0);
			m_uMag.EndQuickRecord();
			}
		else if ( m_nDialogToPlay == dialogEndFirstPart )
			{
			m_bCheckHero = false;
			m_uGiant.ChangePlayer(m_pPlayer);
			SetRealImmortal(m_uGiant, false);
			CommandMoveUnitToUnit(m_uGiant, m_uHero);
			m_bCheckHero = true;
			
			m_uMag.CommandMakeCustomAnimation(2, true, false, 15*60, 0, 0);
			}
		else if ( m_nDialogToPlay == dialogEndMission )
			{
			SetNeutrals(m_pPlayer, m_pEnemyX);
			SetNeutrals(m_pPlayer, m_pEnemy1);
			SetNeutrals(m_pPlayer, m_pEnemy2);
			SetNeutrals(m_pPlayer, m_pEnemy3);
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogWoundedGiant )
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
		RESTORE_STATE(BeforeMissionComplete)
		RESTORE_STATE(MissionComplete)
		RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
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

		EnableAssistant(0xffffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		SetTimer(2, 100);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+36,GetTop()+158,35,56,35,0);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate2_04_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+45,GetTop()+149,13,240,40,0,200,0);
		
		return Start1, 30;
		}
	state Start1
		{
		CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
		CommandMoveUnitToMarker(m_uHero, markerHeroDst);
		CommandMoveUnitToMarker(m_uPrincessa, markerPrincessaDst);
		CommandMoveUnitToMarker(m_uGiant, markerGiantDst);
		
		return Start, 170;
		}
	state Start
		{
		SetLowConsoleText("");
		
		SET_DIALOG(WoundedGiant, Working);

		m_nTimeToEnd = 30*60;
		
		return StartPlayDialog, 0;
		}
	state Working
		{
		SetConsoleText("translate2_04_Console_DefendVillage", m_nTimeToEnd/60 + 1);
		
		--m_nTimeToEnd;
		
		if ( m_nTimeToEnd == 15*60 )
			{
			SET_DIALOG(EndFirstPart, Working);
			
			return StartPlayDialog, 0;
			}
		else if ( m_nTimeToEnd == 0 )
			{
			SET_DIALOG(EndSecondPart, BeforeMissionComplete);
			
			SetConsoleText("");
			
			return StartPlayDialog, 10;
			}
		
		return Working;
		}
	state BeforeMissionComplete
		{
		SetLimitedStepRect(0, 0, 0, 0, 0);
		
		PlayerLookAtUnit(m_pPlayer, m_uDarkPriest, -1, -1, -1);
		
		return BeforeMissionComplete1, 30;
		}
	state BeforeMissionComplete1
		{		
		SetRealImmortal(m_uDarkPriest, false);
		
		Lighting(m_uDarkPriest.GetLocationX(), m_uDarkPriest.GetLocationY(), 10);
		m_uDarkPriest.KillUnit();
		KillArea(m_pEnemy1.GetIFF()|m_pEnemy2.GetIFF()|m_pEnemy3.GetIFF()|m_pEnemyX.GetIFF(),m_uDarkPriest.GetLocationX(), m_uDarkPriest.GetLocationY(),m_uDarkPriest.GetLocationZ(),8);
		
		DamageArea(m_pEnemy1.GetIFF()|m_pEnemy2.GetIFF()|m_pEnemy3.GetIFF()|m_pEnemyX.GetIFF(), 121, 64, 0, 10, 0,0,80);
		
		MeteorRain(121, 64, 30, 150, 250, 150, 10, 10);

		return BeforeMissionComplete2, 150;
		}
	state BeforeMissionComplete2
		{
		m_pPlayer.LookAt(GetLeft()+126,GetTop()+63,20,194,42,0);
		m_pPlayer.DelayedLookAt(GetLeft()+121,GetTop()+63,36,62,40,0,250,1);
		
		return BeforeMissionComplete3, 180;
		}
	state BeforeMissionComplete3
		{
		KillArea(m_pEnemy1.GetIFF()|m_pEnemy2.GetIFF()|m_pEnemy3.GetIFF()|m_pEnemyX.GetIFF(),m_uHero.GetLocationX(), m_uHero.GetLocationY(),m_uHero.GetLocationZ(),16);

		SET_DIALOG(EndMission, MissionComplete);
		
		return StartPlayDialog, 70;
		}
	state MissionComplete
		{
		m_bCheckHero = false;
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnit(bufferGiant, false, m_uGiant, true);
		m_pPlayer.SaveUnit(bufferPrincessa, false, m_uPrincessa, true);
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
		int nRand;
		
		unitex uNewUnit;
		
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
		
		if ( m_nTimeToEnd > 0 && uUnit.GetIFF() == m_pEnemyX.GetIFF() )
			{
			nRand = Rand(8);
			
			     if ( nRand == 0 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "SKELETON4" );
			else if ( nRand == 1 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "MONSTER4"  );
			else if ( nRand == 2 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "GIANT"     );
			else if ( nRand == 3 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "DARKPRIEST");
			else if ( nRand == 4 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "AMAZONE"   );
			else if ( nRand == 5 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "WEREWOLF3" );
			else if ( nRand == 6 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "IGOR3"     );
			else if ( nRand == 7 ) uNewUnit = CreateUnitNearUnit(m_pEnemyX, uUnit, "DARKPRIEST");
			
			uNewUnit.SetExperienceLevel( 3 );
			
			CreateObjectAtUnit(uNewUnit, "HIT_TELEPORT");
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
		
		m_uGiant.ChangePlayer(m_pPlayer);
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnit(bufferGiant, false, m_uGiant, true);
		m_pPlayer.SaveUnit(bufferPrincessa, false, m_uPrincessa, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		SetConsoleText("");
		
		EndMission(true);
		}
    event EscapeCutscene()
    {
		if ( state == Start1 || state == Start )
		{
			if ( state == Start1 )
			{
				CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
			}

			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+45,GetTop()+149,13,240,40,0);

			SetUnitAtMarker(m_uHero, markerHeroDst);
			SetUnitAtMarker(m_uPrincessa, markerPrincessaDst);
			SetUnitAtMarker(m_uGiant, markerGiantDst);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
