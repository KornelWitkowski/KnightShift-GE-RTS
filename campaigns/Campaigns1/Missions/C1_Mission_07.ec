#define MISSION_NAME "translate1_07"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_07_Dialog_
#include "Language\Common\timeMission1_07.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_07\\107_"

mission MISSION_NAME
{

	state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;
	state StartBis;
	state FindNecromancer;
	state FoundNecromancer;
	state NecromancerMove;
	state KillNecromancer;
	state KilledNecromancer;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalHeroSurvive      = 0;
		goalFindSword        = 1;
		goalDestroyCrystall1 = 2;
		goalDestroyCrystall2 = 3;
		goalDestroyCrystall3 = 4;
		goalKillScrag        = 5;

		markerHeroStart   = 0;
		markerCrewStart   = 1;
		markerPriestStart = 4;

		markerNecromancer = 3;

//		markerHeroEnd = 0;

//		markerCrewEndFrom = 1;
//		markerCrewEndTo = 2;

		markerGate1 = 15;
		markerGate2 = 16;
		markerGate3 = 17;

		markerGate1Switch = 18;
		markerGate2Switch = 19;
		markerGate3Switch = 20;

		maskGateOpenSwitch  =  2048;
		maskGateCloseSwitch =  4096;
		maskTeleport        =  8192;

		markerWitch = 22;

		markerHeroGateIn     = 23;
		markerHeroGateOut    = 24;
		markerHeroGateSwitch = 25;

		markerSkeletonFirst = 30;
		markerSkeletonLast = 69;

		idHeroGate = 421;
		idDamage   = 321;

		idSword    = 777;

		markerFireGem     = 73;
		markerWaterGem    = 74;
		markerBonesGem    = 75;

		markerSword       = 70;

		markerGemSkeletonFirst = 110;
		markerGemSkeletonLast  = 130;

		dialogFindNecromancer   = 0;
		dialogKillNecromancer   = 1;
		dialogMissionComplete   = 2;
		dialogSwordFound        = 3;
		dialogKrystalsDestroyed = 4;
		dialogMissionFail       = 9;

		rangeTalk = 1;
		rangeNear = 3;
	}

	player m_pPlayer;

	player m_pEnemy;
	player m_pAnimals;
	player m_pNeutral;

	player m_pEnemy1;
	player m_pEnemy2;

	player m_pNecromancer;

	unitex m_uHero;

	unitex m_uNecromancer;
	unitex m_uWitch;

	unitex m_uFireGem;
	unitex m_uWaterGem;
	unitex m_uBonesGem;

	int m_bCheckHero;

	int m_bWasNearSword;

	function int RegisterGoals()
	{
		RegisterGoal(goalHeroSurvive, "translate1_07_Goal_MirkoMustSurvive");

		REGISTER_GOAL( FindSword );
		REGISTER_GOAL( DestroyCrystall1 );
		REGISTER_GOAL( DestroyCrystall2 );
		REGISTER_GOAL( DestroyCrystall3 );
		REGISTER_GOAL( KillScrag );

		EnableGoal(goalHeroSurvive, true);

        return true;
	}

	function int ModifyDifficulty()
	{
//		OnDifficultyLevelClearMarkers( difficultyEasy  , XX, XX, 0 );
//		OnDifficultyLevelClearMarkers( difficultyMedium, XX, XX, 0 );

		if ( GetDifficultyLevel() == difficultyEasy )
		{
			CreateUnits(m_pEnemy, markerSkeletonFirst, markerSkeletonLast, "SKELETON1");
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			CreateUnits(m_pEnemy, markerSkeletonFirst, markerSkeletonLast, "SKELETON3");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			CreateUnits(m_pEnemy, markerSkeletonFirst, markerSkeletonLast, "SKELETON4");
		}

		return true;
	}

	function int InitializePlayers()
	{
		m_pPlayer	= GetPlayer( 2);

		m_pEnemy	= GetPlayer( 5);
		m_pAnimals	= GetPlayer(14);
		m_pNeutral	= GetPlayer( 0);

		m_pNecromancer = GetPlayer(1);

		m_pPriest	= GetPlayer( 2);

		m_pNeutral.EnableAI(false);
		m_pNecromancer.EnableAI(false);
		m_pEnemy.EnableAI(false);

		m_pEnemy1 = GetPlayer(6);
		m_pEnemy2 = GetPlayer(7);

		LoadAIScript(m_pEnemy1);
		LoadAIScript(m_pEnemy2);

		m_pEnemy1.SetMaxMoney(400);
		m_pEnemy2.SetMaxMoney(400);

		m_pEnemy1.SetMoney(400);
		m_pEnemy2.SetMoney(400);

		m_pPlayer.SetMoney(500);

		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pAnimals);
		SetNeutrals(m_pNeutral, m_pNecromancer);

		SetNeutrals(m_pNecromancer, m_pEnemy);

		SetNeutrals(m_pEnemy1, m_pEnemy);
		SetNeutrals(m_pEnemy1, m_pAnimals);
		SetNeutrals(m_pEnemy1, m_pNecromancer);

		SetNeutrals(m_pEnemy2, m_pEnemy);
		SetNeutrals(m_pEnemy2, m_pAnimals);
		SetNeutrals(m_pEnemy2, m_pNecromancer);

		SetNeutrals(m_pEnemy1, m_pEnemy2);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);

		m_pEnemy1.SetMaxCountLimitForObject("COWSHED",4);
		m_pEnemy1.SetMaxCountLimitForObject("HUT",2);
		m_pEnemy1.SetMaxCountLimitForObject("BARRACKS",GetDifficultyLevel()+1);

		m_pEnemy2.SetMaxCountLimitForObject("COWSHED",4);
		m_pEnemy2.SetMaxCountLimitForObject("HUT",2);
		m_pEnemy2.SetMaxCountLimitForObject("BARRACKS",GetDifficultyLevel()+1);

		m_pEnemy1.SetMaxCountLimitForObject("COURT",0);
		m_pEnemy1.SetMaxCountLimitForObject("TEMPLE",0);
		m_pEnemy1.SetMaxCountLimitForObject("SHRINE",0);
		m_pEnemy2.SetMaxCountLimitForObject("COURT",0);
		m_pEnemy2.SetMaxCountLimitForObject("TEMPLE",0);
		m_pEnemy2.SetMaxCountLimitForObject("SHRINE",0);

		m_pPlayer.SetMaxCountLimitForObject("COWSHED",4);
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

		m_pPlayer.EnableResearchUpdate("SPEAR4"  , true); // 2
		m_pPlayer.EnableResearchUpdate("BOW4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SWORD2A" , true); // 2
		m_pPlayer.EnableResearchUpdate("AXE4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SHIELD2" , true); // 2
		m_pPlayer.EnableResearchUpdate("ARMOUR3" , true); // 2
		m_pPlayer.EnableResearchUpdate("HELMET2A", true); // 2

		m_pPlayer.EnableResearchUpdate("SPEAR5"  , false); // 3
		m_pPlayer.EnableResearchUpdate("BOW5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SWORD3"  , false); // 3
		m_pPlayer.EnableResearchUpdate("AXE5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SHIELD2D", false); // 3
		m_pPlayer.EnableResearchUpdate("ARMOUR3A", false); // 3
		m_pPlayer.EnableResearchUpdate("HELMET3" , false); // 3

		return true;
	}

	function int InitializeUnits()
	{
		INITIALIZE_UNIT( Necromancer );
		INITIALIZE_UNIT( Witch );

		m_uNecromancer.SetUnitName("translate1_07_Name_Necromancer");

		m_uFireGem = CreateBuildingAtMarker(m_pNecromancer, markerFireGem, "KLEJNOT");
		m_uWaterGem = CreateBuildingAtMarker(m_pNecromancer, markerWaterGem, "KLEJNOT");
		m_uBonesGem = CreateBuildingAtMarker(m_pNecromancer, markerBonesGem, "KLEJNOT");

		m_uNecromancer.SetExperienceLevel(5);
		m_uNecromancer.CommandSetMovementMode(modeHoldPos);

		m_uWitch.CommandSetMovementMode(modeHoldPos);
		m_uWitch.CommandSetMakeMagicRemoveStormFireRainMode(1);

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

	int m_nWaterStep;
	int m_nFireStep;
	int m_nBonesStep;

	int m_nBonesLimit;

	int m_nResetStep;

    state Initialize
    {
		unitex uTmp;

		TurnOffTier5Items();

		InitializePlayers();
		initializeUnits();

		ModifyDifficulty();

		SetupOneWayTeleportBetweenMarkers(84, 85);
		SetupOneWayTeleportBetweenMarkers(86, 87);
		SetupOneWayTeleportBetweenMarkers(88, 89);
		SetupOneWayTeleportBetweenMarkers(90, 91);
		SetupOneWayTeleportBetweenMarkers(92, 93);

		RegisterGoals();

		OPEN_GATE(markerGate1);
		CLOSE_GATE(markerGate2);
		CLOSE_GATE(markerGate3);

		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate1Switch, markerGate1Switch, maskGateCloseSwitch|markerGate1, false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate2Switch, markerGate2Switch, maskGateCloseSwitch|markerGate2, false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate3Switch, markerGate3Switch, maskGateCloseSwitch|markerGate3, false);

		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate1Switch, markerGate1Switch, maskGateOpenSwitch|markerGate2, false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate2Switch, markerGate2Switch, maskGateOpenSwitch|markerGate3, false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerGate3Switch, markerGate3Switch, maskGateOpenSwitch|markerGate1, false);

		// CreateArtefactAtMarker("SWITCH_1_1"        , 134, maskGateOpenSwitch|135);
		// CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 134, maskGateOpenSwitch|136);

		CLOSE_GATE( markerHeroGateIn );
		CLOSE_GATE( markerHeroGateOut );

		CLOSE_GATE( 94 );

		CreateArtefacts("ART_SWORD5",         markerSword,  markerSword,  0      ,  false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerSword,  markerSword,  idSword,  false);

		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", markerHeroGateSwitch, idHeroGate);

		CreateArtefacts("SWITCH_5_1", 26, 28, idDamage, false);

		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 76, maskTeleport| 96);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 77, maskTeleport| 97);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 72, maskTeleport| 98);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 71, maskTeleport| 99);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 82, maskTeleport|101);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 83, maskTeleport|100);

		/*
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION", 78, 0);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION", 79, 0);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION", 80, 0);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION", 81, 0);
		*/

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);

		SetTimer(1, 100);
		SetTimer(2, 20);

		m_nWaterStep = (1+4)*60;
		m_nFireStep  = (1+8)*60;
		m_nBonesStep = (1+12)*60;

		m_nResetStep = 12*60;
		m_nBonesLimit = markerGemSkeletonFirst + 5;

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		ShowAreaAtMarker(m_pPlayer, markerHeroStart, 20);
		ShowAreaAtMarker(m_pPlayer, markerSword    , 10);

		m_pPlayer.LookAt(GetLeft()+155,GetTop()+147,18,73,36,0);

		SetTime(32);

		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);

		CacheObject(null, HERO_CREATE_EFFECT);
		CacheObject(null, CREW_CREATE_EFFECT);
		if ( GetDifficultyLevel() == difficultyEasy )
		{
			CacheObject(m_pPlayer, "HERO_EASY");
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			CacheObject(m_pPlayer, "HERO");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			CacheObject(m_pPlayer, "HERO_HARD");
		}
		CacheObject(m_pPlayer, PRIEST_UNIT);

		return Start0, 1;
	}
	//---------------------------------------------------------
	state Start0
	{
		SetCutsceneText("translate1_07_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+159,GetTop()+147,13,238,43,0,200,0);

		return Start1, 50;
	}

	state Start1
	{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		m_uPriest.CommandTurn(128);

		return Start2, 50;
	}

	state Start2
	{
		RESTORE_HERO();
		m_uHero.CommandTurn(0);

		m_bCheckHero = true;

		return Start3, 50;
	}

	state Start3
	{
		RESTORE_CREW();

		return Start, 50;
	}

	event Timer2()
	{
		platoon plat;

		if ( m_bPlayingDialog )
		{
			return;
		}

		if ( m_uFireGem.IsLive() || m_uWaterGem.IsLive() || m_uBonesGem.IsLive() )
		{
			m_uNecromancer.RegenerateHP();
			m_uNecromancer.RegenerateMagic();
		}

		if ( m_nWaterStep <= 0 && m_uWaterGem.IsLive() )
		{
			Storm(GetPointX(0), GetPointY(0), 30, 200, 200, 200, 7, 2, 1);

			m_nWaterStep = m_nResetStep;
		}

		if ( m_nFireStep <= 0 && m_uFireGem.IsLive() )
		{
			MeteorRain(GetPointX(0), GetPointY(0), 30, 200, 200, 200, 2, 5);

			m_nFireStep = m_nResetStep;
		}

		if ( m_nBonesStep <= 0 && m_uBonesGem.IsLive() )
		{
			if ( GetDifficultyLevel() == difficultyEasy )
			{
				plat = CreateUnits(m_pEnemy, markerGemSkeletonFirst, m_nBonesLimit, "SKELETON1");
			}
			else if ( GetDifficultyLevel() == difficultyMedium )
			{
				plat = CreateUnits(m_pEnemy, markerGemSkeletonFirst, m_nBonesLimit, "SKELETON1");
			}
			else if ( GetDifficultyLevel() == difficultyHard )
			{
				plat = CreateUnits(m_pEnemy, markerGemSkeletonFirst, m_nBonesLimit, "SKELETON2");
			}

			plat.CommandMoveAndDefend(GetPointX(0),GetPointY(0),GetPointZ(0));

			m_nBonesStep = m_nResetStep;
			++m_nBonesLimit;

			if ( m_nBonesLimit > markerGemSkeletonLast )
			{
				m_nBonesLimit = markerGemSkeletonLast;
			}
		}

		--m_nWaterStep;
		--m_nFireStep;
		--m_nBonesStep;
	}

	event Timer1()
	{
		int iCountBuilding;

		iCountBuilding = m_pPlayer.GetNumberOfBuildings(buildingHarvestFactory);

		if(iCountBuilding<2) m_pPlayer.SetMaxMoney(100);
		if(iCountBuilding==2) m_pPlayer.SetMaxMoney(200);
		if(iCountBuilding==3) m_pPlayer.SetMaxMoney(300);
		if(iCountBuilding==4) m_pPlayer.SetMaxMoney(400);

		/*
		if ( m_bCreateSorcerers )
		{
			if ( m_pEnemy1.GetNumberOfBuildings() == 0 && m_pEnemy2.GetNumberOfBuildings() == 0 )
			{
				m_bCreateSorcerers = false;

				CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "PRIEST", 4-GetDifficultyLevel());
			}
		}
		*/
	}

    state StartPlayDialog
    {
		if ( m_nDialogToPlay == dialogFindNecromancer )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK
			#define DO_FULL_SAVE

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    KillScrag
			#define DIALOG_LENGHT  5
						
			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogKillNecromancer )
		{
			SetAlly(m_pPlayer, m_pNecromancer);

			#define UNIT_NAME_FROM Necromancer
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    SeeScrag
			#define DIALOG_LENGHT  4
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMissionComplete )
		{
			#define UNIT_NAME_FROM Necromancer
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ScragKilled
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
		else if ( m_nDialogToPlay == dialogSwordFound )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    SwordFound
			#define DIALOG_LENGHT  6
						
			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogKrystalsDestroyed )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Necromancer
			#define DIALOG_NAME    KrystalsDestroyed
			#define DIALOG_LENGHT  1
						
			#include "..\..\TalkBis.ech"
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
    }

	state StartBis
	{
		EnableGoal(goalFindSword, true);

		PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
		RestoreTalkInterface(m_pPlayer, m_uHero);

		return WaitForEndPrepareInterfaceToTalk, 1;
	}

	state EndPlayDialog
	{
		if ( m_nDialogToPlay == dialogFindNecromancer )
		{
			SetLimitedStepRect(0, 0, 0, 0, 0);

			CreateObjectAtMarker(markerSword, "PENTAGRAM_BIG");

			m_pPlayer.LookAt(GetLeft()+69,GetTop()+131,20,156,35,1);
			m_pPlayer.DelayedLookAt(GetLeft()+69,GetTop()+131,10,240,46,1,150,1);

			return StartBis, 150;
		}

		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogKillNecromancer )
		{
			SetEnemies(m_pPlayer, m_pNecromancer);
			m_uNecromancer.CommandAttack(m_uHero);
		}
		else if ( m_nDialogToPlay == dialogMissionComplete )
		{
			EndMission(true);
			// m_uNecromancer.KillUnit();
		}
		else if ( m_nDialogToPlay == dialogSwordFound )
		{
			SetGoalState(goalFindSword, goalAchieved);

			EnableGoal(goalDestroyCrystall1, true);
			EnableGoal(goalDestroyCrystall2, true);
			EnableGoal(goalDestroyCrystall3, true);
		}
		else if ( m_nDialogToPlay == dialogKrystalsDestroyed )
		{
			EnableGoal(goalKillScrag, true);
			SetGoalState(goalDestroyCrystall1, goalAchieved);
			SetGoalState(goalDestroyCrystall2, goalAchieved);
			SetGoalState(goalDestroyCrystall3, goalAchieved);

			OPEN_GATE( markerHeroGateIn );
		}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
	}
	
    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogFindNecromancer )
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
			RESTORE_STATE(FindNecromancer)
			RESTORE_STATE(KillNecromancer)
			RESTORE_STATE(NecromancerMove)
			RESTORE_STATE(MissionComplete)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		SetLowConsoleText("");

//		int nMarker;

//		nMarker = 3*Rand(3) + 7;
//		ClearMarkers(nMarker, nMarker, 0);

		AddWorldMapSignAtMarker(markerSword, 0, -1);

//		AddBriefing(null, "translateC1_Mission_07_Briefing_FindNecromancer");

		m_nDialogToPlay = dialogFindNecromancer;
		m_nStateAfterDialog = FindNecromancer;

		return StartPlayDialog;
//		return FindNecromancer;
	}

	state FindNecromancer
	{
		if (
			IsUnitNearUnit(m_uHero, m_uFireGem , rangeNear) ||
			IsUnitNearUnit(m_uHero, m_uWaterGem, rangeNear) ||
			IsUnitNearUnit(m_uHero, m_uBonesGem, rangeNear)
			)
		{
			if ( GetGoalState(goalFindSword) == goalAchieved ) return FoundNecromancer;
		}

		if ( !m_bWasNearSword && IsUnitNearMarker(m_uHero, markerSword, 10) )
		{
			CreateObjectAtMarker(markerSword, "PENTAGRAM_BIG");

			m_bWasNearSword = true;
		}

		return FindNecromancer;
	}

	state FoundNecromancer
	{
//		RemoveWorldMapSignAtMarker(markerNecromancer);

//		PlayerLookAtUnit(m_pPlayer, m_uNecromancer, -1, -1, -1);

		ShowAreaAtMarker(m_pPlayer, markerNecromancer, 5);

		m_nDialogToPlay = dialogKillNecromancer;
		m_nStateAfterDialog = NecromancerMove;

		return StartPlayDialog;
	}

	state NecromancerMove
	{
		return KillNecromancer;
	}

	state KillNecromancer
	{
		if ( m_uNecromancer.GetHP() * 2 < m_uNecromancer.GetMaxHP() )
		{
			SetAlly(m_pPlayer, m_pNecromancer);

			return KilledNecromancer;
		}

		return KillNecromancer;
	}

	state KilledNecromancer
	{
		PlayTrack("Music\\RPGvictory.tws");

		m_nDialogToPlay = dialogMissionComplete;
		m_nStateAfterDialog = MissionComplete;

		return StartPlayDialog;
	}

	state MissionComplete
	{
		EndMission(true);

		return MissionComplete;
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
		int i;

		if ( pPlayerOnArtefact != m_pPlayer || uUnitOnArtefact == m_uPriest )
		{
			return false;
		}


		if ( uUnitOnArtefact == m_uHero )
		{
			if ( nArtefactNum == idSword )
			{
				CreateObjectAtMarker(markerSword, "SUMMONING_PRINCE");

				RemoveWorldMapSignAtMarker(markerSword);

				// AddWorldMapSignAtMarker(131, 0, -1);
				AddWorldMapSignAtMarker(132, 0, -1);
				AddWorldMapSignAtMarker(133, 0, -1);

				AddWorldMapSignAtMarker(markerBonesGem, 1, -1);
				AddWorldMapSignAtMarker(markerWaterGem, 1, -1);
				AddWorldMapSignAtMarker(markerFireGem, 1, -1);

				AddWorldMapSignAtMarker(82, 2, -1);
				AddWorldMapSignAtMarker(76, 2, -1);
				AddWorldMapSignAtMarker(71, 2, -1);

				OPEN_GATE( 94 );
				OPEN_GATE( 95 );

				CREATE_PRIEST_NEAR_UNIT( Hero );

				SET_DIALOG(SwordFound, FindNecromancer);

				state StartPlayDialog;

				return true;
			}

			if ( nArtefactNum & maskTeleport )
			{
				nMarker = nArtefactNum & ~maskTeleport;

				/*
				if ( nMarker == 76 || nMarker == 77 )
				{
					for (i=78; i<81; ++i)
					{
						uTmp = GetUnitAtMarker(i);

						if ( uTmp == null && uTmp.GetIFF() == m_pPlayer.GetIFF() )
						{
							return false;
						}
					}
				}
				*/

				m_bCheckHero = false;

				/*
				m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
				ClearMarkers(nMarker, nMarker, 0);
				RestorePlayerUnitsAtMarker(m_pPlayer, bufferHero, nMarker);
				m_uHero = GetUnitAtMarker( nMarker );
				*/

				m_uHero.SetImmediatePosition(GetPointX(nMarker), GetPointY(nMarker), GetPointZ(nMarker), m_uHero.GetAlphaAngle(), true);

				PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
				CreateObjectAtUnit(m_uHero, HERO_CREATE_EFFECT);

				m_bCheckHero = true;

				m_uNecromancer.CommandAttack(m_uHero);

				return false;
			}
		}

		if ( nArtefactNum & maskGateOpenSwitch )
		{
			OPEN_GATE( nArtefactNum & ~maskGateOpenSwitch );

			// if ( (nArtefactNum & ~maskGateOpenSwitch) == 135 )
			// {
			// 	CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			//
			//	return true;
			// }
		}
		else if ( nArtefactNum & maskGateCloseSwitch )
		{
			CLOSE_GATE( nArtefactNum & ~maskGateCloseSwitch );
		}

		if ( nArtefactNum == idHeroGate && uUnitOnArtefact == m_uHero )
		{
			CLOSE_GATE( markerHeroGateIn );
			OPEN_GATE( markerHeroGateOut );
		}

		if ( nArtefactNum == idDamage )
		{
			uUnitOnArtefact.DamageUnit(100);
		}

		return false;
	}

	event UnitDestroyed(unitex uUnit)
	{
		if ( m_bCheckHero && uUnit == m_uHero )
		{
			SetGoalState(goalHeroSurvive, goalFailed);

			MissionFailed();
		}
	}

	event BuildingDestroyed(unitex uUnit)
	{
		if ( uUnit == m_uWaterGem )
		{
				RemoveWorldMapSignAtMarker(132);
				RemoveWorldMapSignAtMarker(markerWaterGem);
				RemoveWorldMapSignAtMarker(76);
		}
		else if ( uUnit == m_uFireGem )
		{
				RemoveWorldMapSignAtMarker(133);
				RemoveWorldMapSignAtMarker(markerFireGem);
				RemoveWorldMapSignAtMarker(71);
		}
		else if ( uUnit == m_uBonesGem )
		{
				// RemoveWorldMapSignAtMarker(131);
				RemoveWorldMapSignAtMarker(markerBonesGem);
				RemoveWorldMapSignAtMarker(82);
		}

		if ( uUnit == m_uWaterGem || uUnit == m_uFireGem || uUnit == m_uBonesGem )
		{
			if ( !m_uFireGem.IsLive() && !m_uWaterGem.IsLive() && !m_uBonesGem.IsLive() )
			{
				SET_DIALOG(KrystalsDestroyed, KillNecromancer);

				state StartPlayDialog;

				return; // zeby nie bylo uaktualnienie goli ! Wszystkie ustawiane po dialogu...
			}
		}

		if ( uUnit == m_uWaterGem )
		{
			SetGoalState(goalDestroyCrystall2, goalAchieved);
		}
		else if ( uUnit == m_uFireGem )
		{
			SetGoalState(goalDestroyCrystall1, goalAchieved);
		}
		else if ( uUnit == m_uBonesGem )
		{
			SetGoalState(goalDestroyCrystall3, goalAchieved);
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
		if ( state == Start1 || state == Start2 || state == Start3 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+159,GetTop()+147,13,238,43,0);

			if ( state == Start1 )
			{
				m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestStart, PRIEST_UNIT, 128);
				m_bRemovePriest = true;
			}
			if ( state == Start1 || state == Start2 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				INITIALIZE_HERO();
				m_uHero.CommandTurn(0);

				m_bCheckHero = true;
			}
			if ( state == Start1 || state == Start2 || state == Start3 )
			{
				RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart);
			}

			if ( m_uPriestObj != null && m_uPriestObj.IsLive() ) m_uPriestObj.RemoveUnit();
			if ( m_uHeroObj != null && m_uHeroObj.IsLive() ) m_uHeroObj.RemoveUnit();
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
