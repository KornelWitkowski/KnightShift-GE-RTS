#define MISSION_NAME "translate1_04"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_04_Dialog_
#include "Language\Common\timeMission1_04.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_04\\104_"

mission MISSION_NAME
{
    state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;

	state FindVillage;
	state Working;
	state FindTemple;

	state MissionFail;
	state MissionComplete;
	
#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"
	
	consts 
	{
		goalMirkoMustSurvive   = 0;
		goalMieszkoMustSurvive = 1;
		goalDestroyPentagram   = 2;
		goalDestroySkeletons   = 3;

		playerVillage    =  1;
		playerPlayer     =  2;
		playerEnemy      =  3;
		playerTemple     =  5;
		playerAnimals    = 14;

		playerPriest     =  2;

		markerPriestStart = 55;

		markerHeroStart    =  0;
		markerCrewStart    =  1;
		markerMieszkoStart = 53;

		markerHeroEnd    = 42;
		markerMieszkoEnd = 54;

		markerCrewEndFrom = 43;
		markerCrewEndTo   = 44;

		markerTemple = 5;

		markerPentagram = 30;

		markerDamager = 7;
		rangeDamager = 14;

		markerVillagePriest = 51;

		markerVillagePriestDst = 56;

		markerSwitch =  4;
		markerGate1  =  3;
		markerGate2  = 17;

		dialogDestroySkeletons  = 1;
		dialogDestroySkeletons2 = 2;
		dialogOnIsland          = 3;
		dialogVillage           = 4;
		dialogMissionFail       = 9;

		rangeTalk = 1;
		rangeNear = 3;

		idPentagram = 321;

		markerEnemyCreation1 = 18;
		markerEnemyCreation2 = 19;

		markerVillage = 20;
	}

	player m_pPlayer;

	player m_pVillage;
	player m_pEnemy;
	player m_pTemple;
	player m_pAnimals;

	unitex m_uHero;
	unitex m_uMieszko;

	unitex m_uVillagePriest;
	unitex m_uVillagePriestTalkSmoke;
	
	int m_bCheckHero;

	int m_bCheckVillage;

	int m_bCreateEnemies;

	platoon m_platEnemy;

	function int InitializePlayers()
	{
		INITIALIZE_PLAYER( Player      );
		INITIALIZE_PLAYER( Village     );
		INITIALIZE_PLAYER( Enemy       );
		INITIALIZE_PLAYER( Temple      );
		INITIALIZE_PLAYER( Animals     );

		m_pVillage.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pTemple.EnableAI(false);

		m_pVillage.SetSideColor(m_pPlayer.GetSideColor());
		
		INITIALIZE_PLAYER( Priest  );

		SetNeutrals(m_pTemple, m_pPlayer);
		SetNeutrals(m_pTemple, m_pVillage);
		SetNeutrals(m_pTemple, m_pEnemy);
		SetNeutrals(m_pTemple, m_pAnimals);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pVillage, m_pEnemy);

		SetNeutrals(m_pVillage, m_pAnimals);

		SetNeutrals(m_pPlayer, m_pVillage);

		SetNeutrals(m_pEnemy, m_pAnimals);

		if ( GetDifficultyLevel() > 0 )
		{
			m_pEnemy.SetUnitsExperienceLevel(1);
		}

		m_pPlayer.SetMaxCountLimitForObject("COWSHED",3);
		m_pPlayer.SetMaxCountLimitForObject("HUT",-1);
		m_pPlayer.SetMaxCountLimitForObject("BARRACKS",-1);
		m_pPlayer.SetMaxCountLimitForObject("COURT",0);
		m_pPlayer.SetMaxCountLimitForObject("TEMPLE",0);
		m_pPlayer.SetMaxCountLimitForObject("SHRINE",0);

		m_pPlayer.SetMaxCountLimitForObject("PRIESTESS",0);
		m_pPlayer.SetMaxCountLimitForObject("KNIGHT",0);
		m_pPlayer.SetMaxCountLimitForObject("SORCERER",0);
		m_pPlayer.SetMaxCountLimitForObject("DIPLOMAT",-1);
		m_pPlayer.SetMaxCountLimitForObject("PRIEST",0);
		m_pPlayer.SetMaxCountLimitForObject("WITCH",0);

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

		m_pVillage.ResearchUpdate("SPELL_TELEPORTATION4"); // zeby VillagePriest sie teleportowal do wioski

		return true;
	}

	function int InitializeUnits()
	{
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
		REGISTER_GOAL( DestroySkeletons   );
		REGISTER_GOAL( DestroyPentagram   );

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalMieszkoMustSurvive, true);

        return true;
	}

    state Initialize
    {
		TurnOffTier5Items();
	
		CallCamera();

		InitializePlayers();
		InitializeUnits();

		SetAllBridgesImmortal(true);

		RegisterGoals();

		// PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);

		CreateArtefactAtMarker("SWITCH_5_1", markerPentagram, idPentagram);
		CreateArtefactAtMarker("SWITCH_1_1", markerSwitch, 0);

		SetTimer(1,  20);
		SetTimer(2, 100);

		m_bCheckVillage = true;

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		m_pPlayer.LookAt(GetLeft()+31,GetTop()+53,22,218,31,0);
		ShowAreaAtMarker(m_pPlayer, markerPriestStart, 20);

		SetTime(0);

		SetTimer(7, GetWindTimerTicks());
		StartWind();

		m_platEnemy = m_pEnemy.CreatePlatoon();
		m_platEnemy.EnableFeatures(disposeIfNoUnits, false);

		SaveGameRestart(null);

		CacheObject(null, "PENTAGRAM_BIG");
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
		SetCutsceneText("translate1_04_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+31,GetTop()+53,12,12,37,0,120,1);

		CreateObjectAtMarker(markerPriestStart, "PENTAGRAM_BIG");

		return Start1, 30;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(96);

		return Start2, 30;
	}

	state Start2
	{
		RESTORE_HERO();
		RESTORE_MIESZKO();
		m_uHero.CommandTurn(224);
		m_uMieszko.CommandTurn(64);

		m_bCheckHero = true;

		return Start3, 30;
	}

	state Start3
	{
		RESTORE_CREW();

		return Start, 30;
	}

	event Timer1()
	{
		unitex uTmp;
		unitex uUnit;

		if ( m_bPlayingDialog )
		{
			return;
		}

		uUnit = GetUnitAtMarker(markerSwitch);

		if ( uUnit != null )
		{
			CLOSE_GATE(markerGate1);
			OPEN_GATE(markerGate2);

			uUnit.DamageUnit(5);
		}
		else
		{
			OPEN_GATE(markerGate1);
			CLOSE_GATE(markerGate2);

			DamageArea(m_pPlayer.GetIFF(), GetPointX(markerDamager), GetPointY(markerDamager), GetPointZ(markerDamager), rangeDamager, 5);
		}

	}
	event Timer2()
	{
		int iCountBuilding;

		iCountBuilding = m_pPlayer.GetNumberOfBuildings(buildingHarvestFactory);

		if(iCountBuilding<2) m_pPlayer.SetMaxMoney(100);
		if(iCountBuilding==2) m_pPlayer.SetMaxMoney(200);
		if(iCountBuilding==3) m_pPlayer.SetMaxMoney(300);
		if(iCountBuilding==4) m_pPlayer.SetMaxMoney(400);
	}

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogDestroySkeletons )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    DestroySkeletons
			#define DIALOG_LENGHT  4
						
			#include "..\..\TalkBis.ech"

			/*
			AddTalkLookAt(GetLeft()+36,GetTop()+53,23,197,47,0);
			AddTalkDelayedLookAt(GetLeft()+36,GetTop()+53,23,197,47,0,20,1);
			AddTalkLookAt(GetLeft()+30,GetTop()+52,23,43,20,0);
			AddTalkDelayedLookAt(GetLeft()+30,GetTop()+53,14,19,24,0,150,0);

			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_06);
			ADD_STANDARD_TALK(Priest, VillagePriest, DestroySkeletons_07);
			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_08);
			ADD_STANDARD_TALK(Priest, VillagePriest, DestroySkeletons_09);
			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_10);
			ADD_STANDARD_TALK(Priest, Hero, DestroySkeletons_11);
			ADD_STANDARD_TALK(VillagePriest, Hero, DestroySkeletons_12);
			ADD_STANDARD_TALK(Priest, Hero, DestroySkeletons_13);
			*/

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogDestroySkeletons2 )
		{
			ADD_STANDARD_TALK(Priest, VillagePriest, DestroySkeletons_05);
			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_06);
			ADD_STANDARD_TALK(Priest, VillagePriest, DestroySkeletons_07);
			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_08);
			ADD_STANDARD_TALK(Priest, VillagePriest, DestroySkeletons_09);
			ADD_STANDARD_TALK(VillagePriest, Priest, DestroySkeletons_10);
			ADD_STANDARD_TALK(Priest, Hero, DestroySkeletons_11);
			ADD_STANDARD_TALK(VillagePriest, Hero, DestroySkeletons_12);
			ADD_STANDARD_TALK(Priest, Hero, DestroySkeletons_13);

			PlayTalkDefinition();

			return TalkDialog;
		}
		else if ( m_nDialogToPlay == dialogOnIsland )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    OnIsland
			#define DIALOG_LENGHT  3
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogVillage )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   VillagePriest
			#define DIALOG_NAME    Village
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
		if ( m_nDialogToPlay != dialogDestroySkeletons ) RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogDestroySkeletons )
		{
			CommandMoveUnitToMarker(m_uVillagePriest, markerVillagePriestDst);
			m_uPriest.CommandTurn(m_uPriest.GetAngleToTarget(m_uVillagePriest.GetUnitRef()));

			m_nDialogToPlay = dialogDestroySkeletons2;
			return StartPlayDialog, 100;
		}
		else if ( m_nDialogToPlay == dialogDestroySkeletons2 )
		{
			EnableGoal(goalDestroySkeletons, true);
		
			m_uVillagePriest.RegenerateMagic();
			CommandMoveUnitToMarker(m_uVillagePriest, markerVillage);
		}
		else if ( m_nDialogToPlay == dialogVillage )
		{
			EnableGoal(goalDestroyPentagram, true);

			m_bCheckVillage = false;

			CreateObject(m_uVillagePriest.GetLocationX(), m_uVillagePriest.GetLocationY(), m_uVillagePriest.GetLocationZ(), 0, PRIEST_REMOVE_EFFECT);
			m_uVillagePriest.RemoveUnit();

			m_pVillage.GiveAllUnitsTo(m_pPlayer);
			m_pVillage.GiveAllBuildingsTo(m_pPlayer);
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}
	
    state RestoreGameState
	{
		END_TALK_DEFINITION();

		if ( m_nDialogToPlay == dialogDestroySkeletons2 )
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

			START_TALK( VillagePriest );
		}
		
		SAFE_REMOVE_PRIEST();
		
		BEGIN_RESTORE_STATE_BLOCK()
			RESTORE_STATE(FindVillage)
			RESTORE_STATE(Working)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		SetLowConsoleText("");

		m_uVillagePriest = CreateUnitAtMarker(m_pVillage, markerVillagePriest, "SORCERER");
		m_uVillagePriest.SetUnitName("translate1_04_Name_Priest");
		SetRealImmortal(m_uVillagePriest, true);

		SET_DIALOG(DestroySkeletons, FindVillage);

		return StartPlayDialog, 0;
	}

	int m_bCheckEnemy;
	int m_nCounter;
	
	state FindVillage
	{
		if ( IsUnitNearMarker(m_uHero, markerVillage, 5) && ! m_uHero.IsMoving() )
		{
			STOP_TALK( VillagePriest );

			SET_DIALOG(Village, Working);

			m_bCreateEnemies = true;
			m_nCounter = 120;

			return StartPlayDialog, 0;
		}

		return FindVillage;
	}

	state Working
	{
		int nExp, nSkeletons;

		if ( m_bCreateEnemies )
		{
			--m_nCounter;

			if ( m_nCounter == 0 )
			{
				m_nCounter = 120;

				nExp = GetDifficultyLevel();
				nSkeletons = 3 + GetDifficultyLevel()*2;

				if ( GetDifficultyLevel() == difficultyEasy )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation1, "SKELETON1", nExp, nSkeletons);
				}
				else if ( GetDifficultyLevel() == difficultyMedium )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation1, "SKELETON2", nExp, nSkeletons);
				}
				else if ( GetDifficultyLevel() == difficultyHard )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation1, "SKELETON3", nExp, nSkeletons);
				}

				if ( GetDifficultyLevel() == difficultyEasy )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation2, "SKELETON1", nExp, nSkeletons);
				}
				else if ( GetDifficultyLevel() == difficultyMedium )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation2, "SKELETON2", nExp, nSkeletons);
				}
				else if ( GetDifficultyLevel() == difficultyHard )
				{
					CreateExpUnitsAtMarker(m_platEnemy, m_pEnemy, markerEnemyCreation2, "SKELETON3", nExp, nSkeletons);
				}

				m_platEnemy.CommandMoveAndDefend(GetPointX(41), GetPointY(41), 0);
			}

			return Working;
		}

		// ! m_bCreateEnemies

		if ( m_bCheckEnemy ) 
		{
			if ( m_pEnemy.GetNumberOfUnits() == 0 )
			{
				SetGoalState(goalDestroySkeletons, goalAchieved);
				
				return FindTemple;
			}

			m_bCheckEnemy = false;
		}

		if( ! IsPlayerUnitNearMarker(41, 20, m_pEnemy.GetIFF()) )
		{
			m_platEnemy.CommandMoveAndDefend(GetPointX(41), GetPointY(41), 0);
		}

		return Working;
	}

	state FindTemple
	{
		int x, y, z;

		CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerMieszkoEnd, 0);

		x = (GetPointX(markerCrewEndFrom)+GetPointX(markerCrewEndTo))/2;
		y = (GetPointY(markerCrewEndFrom)+GetPointY(markerCrewEndTo))/2;
		z =  GetPointZ(markerCrewEndFrom);

		m_pPlayer.CreateUnit(x, y, z, 0, "PRIESTESS");
		m_pPlayer.CreateUnit(x, y, z, 0, "PRIESTESS");
		m_pPlayer.CreateUnit(x, y, z, 0, "PRIESTESS");

		CREATE_PRIEST_NEAR_UNIT( Hero );

		PlayTrack("Music\\RPGvictory.tws");

		SET_DIALOG(OnIsland, MissionComplete);

		return StartPlayDialog, 0;
	}

	state MissionComplete
	{
		if  (
			IsUnitNearMarker(m_uHero, markerHeroEnd, 0) && IsUnitNearMarker(m_uMieszko, markerMieszkoEnd, 0)
		 || IsUnitNearMarker(m_uMieszko, markerHeroEnd, 0) && IsUnitNearMarker(m_uHero, markerMieszkoEnd, 0)
			)
		{
			m_bCheckHero = false;

			m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);
			SAVE_PLAYER_UNITS();

			EndMission(true);
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

		if ( nArtefactNum == idPentagram )
		{
			DamageArea(m_pEnemy.GetIFF(), GetPointX(markerPentagram), GetPointY(markerPentagram), 0, 30, 50);
			DamageArea(m_pEnemy.GetIFF(), GetPointX(markerPentagram), GetPointY(markerPentagram), 1, 30, 50);

			SetEnemies(m_pPlayer, m_pEnemy);
			SetEnemies(m_pVillage, m_pEnemy);

			SetGoalState(goalDestroyPentagram, goalAchieved);

			m_bCreateEnemies = false;

			CreateArtefactAtMarker("SWITCH_5_2", markerPentagram, 0);
			CreateObjectAtMarker(markerPentagram, "SWITCH_5_EXP");

			return true;
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
			else if ( uUnit == m_uMieszko )
			{
				SetGoalState(goalMieszkoMustSurvive, goalFailed);

				MissionFailed();
			}
		}

		if ( m_bCheckVillage )
		{
			if ( uUnit.GetIFF() == m_pVillage.GetIFF() ) 
			{
				MissionFailed();
			}
		}

		if ( uUnit.GetIFF() == m_pEnemy.GetIFF() )
		{
			m_bCheckEnemy = true;
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

			m_pPlayer.LookAt(GetLeft()+31,GetTop()+53,12,12,37,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 96);
				m_bRemovePriest = true;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uHero.CommandTurn(224);
				m_uMieszko = RestorePlayerUnitAtMarker(m_pPlayer, bufferMieszko, markerMieszkoStart);
				INITIALIZE_MIESZKO();
				m_uMieszko.CommandTurn(64);

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
