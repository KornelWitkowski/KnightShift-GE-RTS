#define MISSION_NAME "translate2_03"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_03_Dialog_
#include "Language\Common\timeMission2_03.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_03\\203_"

mission MISSION_NAME
	{
	state Initialize;
	state Start0;
	state Start1;
	state Start2;
	state Start3;
	state Start;
	
	state ShowGate;
	state Working;
	state MissionEnd;
	
	state MissionFail;
	state MissionComplete;
	
	#include "..\..\Common.ech"
	#include "..\..\Talk.ech"
	#include "..\..\Priest.ech"
	
	consts
		{
		goalMirkoMustSurvive     = 0;
		goalGiantMustSurvive     = 1;
		goalPrincessaMustSurvive = 2;
		goalFindPrincessa        = 3;
		goalKillGuardian         = 4;
		goalFreePrincessa        = 5;
		
		playerNeutral    =  0;
		playerPlayer     =  2;
		playerEnemy1     =  3;
		playerEnemy2     =  5;
		playerEnemy3     = 14;
		
		playerScrag      =  4;
		
		playerPriest     =  2;
		
		markerHeroStart    =  0;
		markerCrewStart    =  1;
		
		markerHeroEnd    = 89;
		
		markerCrewEndFrom = 90;
		markerCrewEndTo =   91;
		
		markerPrincessa = 97;
		markerGiant     = 81;
		
		markerEgg = 84;
		
		markerPriestStart = 29;
		
		markerWitch   = 153;
		markerHeroDst = 200;
		
		markerGuard1 = 192;
		markerGuard2 = 193;
		
		dialogInformation      = 20;
		dialogStart            =  1;
		dialogGiant            =  5;
		dialogDragonEgg        =  6;
		dialogPrincessaInTower =  7;
		dialogWitchTrap        =  8;
		dialogPrincessaIsFree  =  9;
		dialogMissionFail      = 10;
		
		rangeTalk   =  1;
		rangeNear   =  3;
		rangeSee    = 10;
		rangeCreate =  6;
		
		maskGateOpenSwitch  =  2048;
		maskGateCloseSwitch =  4096;
		maskRandomSwitch    =  8192;
		
		idGiantSwitch = 444;
		idFireSwitch  = 445;
		
		idKill = 447;
		idEgg  = 448;
		}
	
	player m_pPlayer;
	
	player m_pNeutral;
	player m_pEnemy1;
	player m_pEnemy2;
	player m_pEnemy3;
	
	player m_pScrag;
	
	unitex m_uHero;
	
	unitex m_uPrincessa;
	unitex m_uGiant;
	
	unitex m_uPrincessaTalkSmoke;
	unitex m_uGiantTalkSmoke;
	
	unitex m_uWitch;
	
	unitex m_uGuard1;
	unitex m_uGuard2;
	
	int m_bCheckHero;
	
	int m_bGoToEgg;
	
	int m_abInformation[];
	
	int m_nStep;
	
	int m_bUpdateFire;
	int m_bUpdateGates;
	
	int m_anFootman[];
	int m_anHunter[];
	int m_anGiant[];
	
	int m_bGateOn;
	int m_nRandomSwitchOpen;
	
	int m_bRemoveWorldMapSignAtMarker100;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Player      );
		
		INITIALIZE_PLAYER( Neutral     );
		INITIALIZE_PLAYER( Enemy1     );
		INITIALIZE_PLAYER( Enemy2     );
		INITIALIZE_PLAYER( Enemy3     );
		
		INITIALIZE_PLAYER( Scrag );
		
		m_pEnemy1.SetUnitsExperienceLevel(GetDifficultyLevel());
		m_pEnemy2.SetUnitsExperienceLevel(GetDifficultyLevel());
		m_pEnemy3.SetUnitsExperienceLevel(GetDifficultyLevel());
		m_pScrag.SetUnitsExperienceLevel(GetDifficultyLevel());
		
		m_pNeutral.EnableAI(false);
		
		m_pEnemy1.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		// m_pEnemy3.EnableAI(false); // Animals !!! pl. 14
		m_pScrag.EnableAI(false);
		
		INITIALIZE_PLAYER( Priest  );
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		
		SetNeutrals(m_pNeutral, m_pEnemy1);
		SetNeutrals(m_pNeutral, m_pEnemy2);
		SetNeutrals(m_pNeutral, m_pEnemy3);
		SetNeutrals(m_pNeutral, m_pScrag );
		
		SetNeutrals(m_pEnemy1, m_pEnemy2);
		SetNeutrals(m_pEnemy1, m_pEnemy3);
		
		SetNeutrals(m_pEnemy2, m_pEnemy3);

		SetEnemies(m_pPlayer, m_pEnemy1);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pEnemy3);
		
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
		unitex uTmp;
		platoon platCrew;
		
		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		
		m_pPlayer.SortSavedUnitsBuffer(bufferCrew, sortUnitsByExperience);
		
		i =     RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "BANDIT"  , 2  );
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "FOOTMAN" , 5-i);
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "SPEARMAN", 4  );
		i = i + RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "HUNTER"  , 9-i);
		
		if ( i < 2) CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "FOOTMAN", 2-i);
		
		platCrew = GetPlayerCrew();
		
		platCrew.CommandTurn(128);
		
		m_pPlayer.ResetSavedUnits(bufferCrew); // na wszelki wypadek
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		m_uHero.CommandTurn(128);
		
		INITIALIZE_UNIT( Princessa );
		INITIALIZE_UNIT( Giant );
		
		INITIALIZE_UNIT( Guard1 );
		INITIALIZE_UNIT( Guard2 );
		
		m_uPrincessa.SetIsSingleUnit(true);
		m_uGiant.SetIsSingleUnit(true);

		m_uPrincessa.CommandSetMovementMode(modeHoldPos);
		
		SetRealImmortal(m_uPrincessa, true);
		SetRealImmortal(m_uGiant, true);

		for ( i=161; i<=173; ++i )
			{
			uTmp = GetUnitAtMarker(i);
			uTmp.SetExperienceLevel(8);
			}
		
		for ( i=174; i<=191; ++i )
			{
			uTmp = GetUnitAtMarker(i);
			uTmp.SetExperienceLevel(4);
			}
		
		return true;
		}
	
	function int MissionFailed()
		{
		if ( state == MissionFail )
			{
			return false;
			}
		
		m_bGateOn = false; // !!! WAZNE !!!
		
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
		REGISTER_GOAL( FindPrincessa        );
		REGISTER_GOAL( KillGuardian         );
		REGISTER_GOAL( FreePrincessa        );
		
		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalPrincessaMustSurvive, true);
		
		return true;
		}
	
	state Initialize
		{
		unitex uTmp;
		int i;
		
		TurnOffTier5Items();
		
		CallCamera();
		
		InitializePlayers();
		InitializeUnits();
		
		RegisterGoals();
		
		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		EnableAssistant(0xffffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		CLOSE_GATE( 72 );
		
		// CLOSE_GATE( 86 );
		// CLOSE_GATE( 87 );
		
		CLOSE_GATE( 100 ); m_bRemoveWorldMapSignAtMarker100 = false;
		CLOSE_GATE( 98 );
		CLOSE_GATE( 99 );
		CLOSE_GATE( 92 );
		
		CreateArtefactAtMarker("SWITCH_1_1", 73, maskRandomSwitch|77);
		CreateArtefactAtMarker("SWITCH_1_1", 74, maskRandomSwitch|78);
		CreateArtefactAtMarker("SWITCH_1_1", 75, maskRandomSwitch|79);
		CreateArtefactAtMarker("SWITCH_1_1", 76, maskRandomSwitch|80);
		
		m_nRandomSwitchOpen = 77 + Rand(4);
		
		CreateArtefactAtMarker("SWITCH_1_1", 101, maskGateOpenSwitch|100);
		CreateArtefactAtMarker("SWITCH_1_1", 102, maskGateOpenSwitch|99);
		CreateArtefactAtMarker("SWITCH_1_1", 103, maskGateOpenSwitch|98);
		
		CreateArtefactAtMarker("SWITCH_1_1", 129, maskGateOpenSwitch|92);
		
		CreateArtefactAtMarker("SWITCH_1_1", 88, idGiantSwitch);
		
		CreateArtefactAtMarker("SWITCH_1_1", 25, idFireSwitch);
		
		CreateArtefactAtMarker("SWITCH_1_1", 30, 0);
		CreateArtefactAtMarker("SWITCH_1_1", 35, 0);
		CreateArtefactAtMarker("SWITCH_1_1", 159, 0);
		CreateArtefactAtMarker("SWITCH_1_1", 160, 0);
		
		// CreateArtefactAtMarker("SWITCH_2_1", 30, maskGateOpenSwitch|100); // tescik
		
		CreateArtefactAtMarker("SWITCH_1_1", 42, 0);
		CreateArtefactAtMarker("SWITCH_1_1", 57, 0);
		
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 154, idKill);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 155, idKill);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 156, idKill);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 157, idKill);
		
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", markerEgg, idEgg);
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		
		m_abInformation.Create(4);
		m_abInformation[0] = true;
		m_abInformation[1] = true;
		m_abInformation[2] = true;
		m_abInformation[3] = true;
		
		OnDifficultyLevelClearMarkers( difficultyEasy  , 108, 115, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 108, 110, 0 );
		
		SetTimer(0, 20*4);
		SetTimer(1, 20*6);
		SetTimer(2, 20*2);
		
		m_anFootman.Create(0);
		m_anHunter.Create(0);
		m_anGiant.Create(0);
		
		for ( i=130; i<=138; ++i) m_anFootman.Add(i);
		for ( i=139; i<=145; ++i) m_anHunter.Add(i);
		for ( i=146; i<=151; ++i) m_anGiant.Add(i);
		
		m_bGateOn = true;
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+111,GetTop()+110,20,117,37,0);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		CacheObject(m_pPriest, PRIEST_UNIT);
		CacheObject(null, PRIEST_CREATE_EFFECT);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate2_03_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+106,GetTop()+114,18,52,39,0,230,0);
		
		return Start1, 230;
		}
	state Start1
		{
		SetLowConsoleText("");
		
		m_pPlayer.DelayedLookAt(GetLeft()+106,GetTop()+114,14,38,41,0,80,0);
		
		return Start2, 60;
		}
	state Start2
		{
		CREATE_PRIEST_AT_MARKER( PriestStart );
		
		return Start3, 20;
		}
	state Start3
		{
		m_pPlayer.DelayedLookAt(GetLeft()+106,GetTop()+114,14,37,41,0,10,0);
		
		return Start, 0;
		}
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogInformation+0 )
			{
			#define NO_TURN_UNITS

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FirstInformation
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogInformation+1 )
			{
			#define NO_TURN_UNITS

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    SecondInformation
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogInformation+2 )
			{
			#define NO_TURN_UNITS

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ThirdInformation
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogInformation+3 )
			{
			#define NO_TURN_UNITS

			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FourthInformation
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogStart )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Start
			#define DIALOG_LENGHT  9
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogGiant )
			{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Giant
			#define DIALOG_LENGHT  4
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogDragonEgg )
			{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Giant
			#define DIALOG_NAME    DragonEgg
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogPrincessaInTower )
			{
			#define UNIT_NAME_FROM Princessa
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    PrincessaInTower
			#define DIALOG_LENGHT  4
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogWitchTrap )
			{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Witch
			#define DIALOG_NAME    WitchTrap
			#define DIALOG_LENGHT  2
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogPrincessaIsFree )
			{
			ADD_STANDARD_TALK(Princessa, Hero, PrincessaIsFree_01);
			
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
		if ( m_nDialogToPlay != dialogWitchTrap ) RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogStart )
			{
			EnableGoal(goalFindPrincessa, true);
			}
		else if ( m_nDialogToPlay == dialogGiant )
			{
			EnableGoal(goalGiantMustSurvive, true);
			EnableGoal(goalKillGuardian, true);
			
			m_bCheckHero = false;
			m_uGiant.ChangePlayer(m_pPlayer);
			SetRealImmortal(m_uGiant, false);
			m_bCheckHero = true;
			}
		else if ( m_nDialogToPlay == dialogDragonEgg )
			{
			m_bCheckHero = false;
			m_uGiant.ChangePlayer(m_pNeutral);
			SetRealImmortal(m_uGiant, true);
			CommandMoveUnitToMarker(m_uGiant, markerEgg);
			m_bCheckHero = true;
			}
		else if ( m_nDialogToPlay == dialogPrincessaInTower )
			{
			SetGoalState(goalFindPrincessa, goalAchieved);
			EnableGoal(goalFreePrincessa, true);
			
			m_bCheckHero = false;
			m_uHero.ChangePlayer(m_pNeutral);
			SetRealImmortal(m_uHero, true);
			CommandMoveUnitToMarker(m_uHero, 200);
			m_bCheckHero = true;
			
			SetAlly(m_pPlayer, m_pNeutral);
			}
		else if ( m_nDialogToPlay == dialogWitchTrap )
			{
			m_uWitch.RemoveUnit();
			
			CommandMoveUnitToUnit(m_uPrincessa, m_uHero);
			
			m_nDialogToPlay = dialogPrincessaIsFree;
			return StartPlayDialog, 30;
			}
		else if ( m_nDialogToPlay == dialogPrincessaIsFree )
			{
			SetGoalState(goalFreePrincessa, goalAchieved);
			
			m_bCheckHero = false;
			m_uHero.ChangePlayer(m_pPlayer);
			m_uPrincessa.ChangePlayer(m_pPlayer);
			SetRealImmortal(m_uHero, false);
			SetRealImmortal(m_uPrincessa, false);
			m_bCheckHero = true;
			}
			
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogStart )
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
		RESTORE_STATE(MissionEnd)
		RESTORE_STATE(MissionComplete)
		RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
		}
	
	int m_nLightingStep;
	int m_nGatesStep;
	
	int m_nFireStep1;
	int m_nFireStep2;
	
	event Timer0() // 4
		{
		int x, y, z;
		int i;
		
		if ( m_bPlayingDialog )
			{
			return;
			}
		
		if ( GetUnitAtMarker(35) != null || GetUnitAtMarker(160) != null )
			{
			z = GetPointZ(33);
			
			for ( x=GetPointX(33); x<=GetPointX(34); ++x )
				{
				for ( y=GetPointY(33); y<=GetPointY(34); ++y )
					{
					CreateObject(x, y, z, 0, "FIRETRAP1");
					}
				}
			}
		
		if ( GetUnitAtMarker(57) != null )
			{
			for ( i=58; i<=67; ++i ) CreateObjectAtMarker(i  , "FIRETRAP1");
			}
		
		if ( GetUnitAtMarker(42) != null )
			{
			CLOSE_GATE( 44 );
			for ( i=45; i<=56; ++i ) CreateObjectAtMarker(i  , "FIRETRAP1");
			for ( i=194; i<=196; ++i ) CreateObjectAtMarker(i  , "FIRETRAP1");
			}
		else
			{
			OPEN_GATE( 44 );
			}
		
		m_nFireStep1 = ( m_nFireStep1 + 1 ) % 4;
		m_nFireStep2 = ( m_nFireStep2 + 1 ) % 2;
		
		CreateObjectAtMarker(68 + m_nFireStep1  , "FIRETRAP1");
		
		     if ( m_nFireStep2 == 0 ) for ( i=116; i<=120; ++i ) CreateObjectAtMarker(i, "FIRETRAP1");
		else if ( m_nFireStep2 == 1 ) for ( i=121; i<=128; ++i ) CreateObjectAtMarker(i, "FIRETRAP1");
		
		if ( m_bGateOn )
			{
			CreateObjectAtMarker(154 , "FIRETRAP1");
			CreateObjectAtMarker(155 , "FIRETRAP1");
			CreateObjectAtMarker(156 , "FIRETRAP1");
			CreateObjectAtMarker(157 , "FIRETRAP1");
			}
		
		}
	
	event Timer1() // 6 
		{
		int x, y, z;
		unitex uTmp;
		
		if ( m_bPlayingDialog )
			{
			return;
			}
		
		z = GetPointZ(27);
		
		for ( x=GetPointX(27); x<=GetPointX(28); ++x )
			{
			for ( y=GetPointY(27); y<=GetPointY(28); ++y )
				{
				uTmp = GetUnit(x, y, z);
				
				if ( uTmp != null && uTmp.GetIFF() == m_pEnemy1.GetIFF() )
					{
					Lighting(x, y, 10);
					uTmp.KillUnit();
					}
				}
			}
		
		CreateObjectAtMarker(36  , "FIRETRAP1");
		CreateObjectAtMarker(37  , "FIRETRAP1");
		CreateObjectAtMarker(38  , "FIRETRAP1");
		}
	
	event Timer2() // 2
		{
		int i;
		int nMarker;
		unitex uTmp;
		
		if ( m_bPlayingDialog )
			{
			return;
			}
		
		for ( i=0; i<m_anFootman.GetSize(); ++i )
			{
			nMarker = m_anFootman[i];
			
			if ( IsPlayerUnitNearMarker(nMarker, rangeCreate, m_pPlayer.GetIFF()) )
				{
				ClearMarkers(nMarker,nMarker,0);
				uTmp = CreateExpUnitAtMarker(m_pEnemy1, nMarker, "FOOTMAN", 8);
				CreateObjectAtUnit(uTmp, "HIT_TELEPORT");
				
				m_anFootman.RemoveAt(i);
				}
			}
		
		for ( i=0; i<m_anHunter.GetSize(); ++i )
			{
			nMarker = m_anHunter[i];
			
			if ( IsPlayerUnitNearMarker(nMarker, rangeCreate, m_pPlayer.GetIFF()) )
				{
				ClearMarkers(nMarker,nMarker,0);
				uTmp = CreateExpUnitAtMarker(m_pEnemy1, nMarker, "HUNTER", 8);
				CreateObjectAtUnit(uTmp, "HIT_TELEPORT");
				
				m_anHunter.RemoveAt(i);
				}
			}
		
		for ( i=0; i<m_anGiant.GetSize(); ++i )
			{
			nMarker = m_anGiant[i];
			
			if ( IsPlayerUnitNearMarker(nMarker, rangeCreate, m_pPlayer.GetIFF()) )
				{
				ClearMarkers(nMarker,nMarker,0);
				uTmp = CreateExpUnitAtMarker(m_pEnemy1, nMarker, "GIANT", 8);
				CreateObjectAtUnit(uTmp, "HIT_TELEPORT");
				
				m_anGiant.RemoveAt(i);
				}
			}
		}
	
	state Start
		{
		START_TALK_GIANT( Giant );
		
		m_nLightingStep = 0;
		m_nGatesStep    = 0;
		
		m_bUpdateGates = true;
		m_bUpdateFire  = true;
		
		SET_DIALOG(Start, Working);

		return StartPlayDialog, 0;
		}
	
	#define SET_GATE( marker, state ) \
	uTmp = GetUnitAtMarker(marker); \
	uTmp.CommandBuildingSetGateMode(state);
	
	function void SetGates(int g8, int g7, int g6, int g5, int g4, int g3, int g2, int g1)
		{
		unitex uTmp;
		
		if ( !m_bUpdateGates ) return;
		
		SET_GATE( 3, g1);
		SET_GATE( 4, g2);
		SET_GATE( 5, g3);
		SET_GATE( 6, g4);
		SET_GATE( 7, g5);
		SET_GATE( 8, g6);
		SET_GATE( 9, g7);
		SET_GATE(10, g8);
		}
	
	function void SetFire(int nGate)
		{
		int nMarker;
		
		if ( !m_bUpdateFire ) return;
		
		nMarker = 11 + (nGate-1)*2;
		
		CreateObjectAtMarker(nMarker  , "FIRETRAP1");
		CreateObjectAtMarker(nMarker+1, "FIRETRAP1");
		}
	
	function void SetFire(int g1, int g2)
		{
		SetFire(g1);
		SetFire(g2);
		}
	
	function void SetFire(int g1, int g2, int g3)
		{
		SetFire(g1);
		SetFire(g2);
		SetFire(g3);
		}
	
	function void UpdateGates()
		{
		m_nGatesStep = ( m_nGatesStep + 1 ) % 8;
		
		if ( m_nGatesStep == 0 )      { SetGates(1, 2, 1, 1, 2, 1, 2, 1); SetFire(2, 4, 7); }
		else if ( m_nGatesStep == 1 ) { SetGates(2, 1, 2, 2, 1, 2, 1, 1); SetFire(3, 5   ); }
		else if ( m_nGatesStep == 2 ) { SetGates(1, 2, 2, 1, 2, 1, 1, 2); SetFire(1, 4, 6); }
		else if ( m_nGatesStep == 3 ) { SetGates(1, 1, 2, 1, 1, 2, 2, 2); SetFire(2, 5, 7); }
		else if ( m_nGatesStep == 4 ) { SetGates(2, 2, 1, 1, 2, 2, 1, 1); SetFire(1, 3, 7); }
		else if ( m_nGatesStep == 5 ) { SetGates(2, 1, 2, 2, 1, 1, 2, 2); SetFire(2, 4, 6); }
		else if ( m_nGatesStep == 6 ) { SetGates(1, 2, 1, 2, 1, 2, 1, 2); SetFire(1, 3, 7); }
		else if ( m_nGatesStep == 7 ) { SetGates(1, 1, 2, 2, 2, 1, 2, 2); SetFire(3, 4   ); }
		}
	
	state Working
		{
		int i;
		int x, y, z;
		int x1, y1, x2, y2;
		unitex uTmp;
		
		++m_nStep;
		
		// m_nLightingStep = ( m_nLightingStep + 1) % 15;
		
		// LightingAtMarker(m_nLightingStep*3 + 27);
		// LightingAtMarker(m_nLightingStep*3 + 28);
		// LightingAtMarker(m_nLightingStep*3 + 29);
		
		x1 = GetPointX(27);
		y1 = GetPointY(27);
		x2 = GetPointX(28);
		y2 = GetPointY(28);
		z  = GetPointZ(27);
		
		for (i=0; i<1; ++i) // ;)
			{
			x = x1 + Rand(x2-x1+1);
			y = y1 + Rand(y2-y1+1);
			
			Lighting(x, y, z);
			}
		
		if ( (m_nStep%5) == 0 ) UpdateGates();
		
		if ( GetUnitAtMarker(30) != null || GetUnitAtMarker(159) != null )
			{
			OPEN_GATE( 31 );
			OPEN_GATE( 32 );
			}
		else
			{
			CLOSE_GATE( 31 );
			CLOSE_GATE( 32 );
			}
		
		for ( i=0; i<4; ++i )
			{
			if ( m_abInformation[i] && IsUnitNearMarker(m_uHero, 93+i, rangeNear) )
				{
				m_nDialogToPlay = dialogInformation + i;
				m_nStateAfterDialog = Working;
				
				m_abInformation[i] = false;

				uTmp = GetUnitAtMarker( 93+i );

				m_uHero.CommandTurn(m_uHero.GetAngleToTarget(uTmp.GetUnitRef()));
				
				return StartPlayDialog, 0;
				}
			}
		
		if ( m_bRemoveWorldMapSignAtMarker100 )
			{
			if ( IsPlayerUnitNearMarker(100, 5, m_pPlayer.GetIFF()) )
				{
				RemoveWorldMapSignAtMarker(100);
				m_bRemoveWorldMapSignAtMarker100 = false;
				}
			}
		
		if ( IsUnitNearUnit(m_uHero, m_uGiant, 5) )
			{
			if ( m_uGiantTalkSmoke )
				{
				STOP_TALK( Giant );
				
				SET_DIALOG(Giant, Working);
				
				m_bGoToEgg = true;
				
				return StartPlayDialog, 0;
				}
			}
		if ( IsUnitNearUnit(m_uHero, m_uPrincessa, 5) && ! m_uHero.IsMoving() )
			{
			if ( m_uPrincessaTalkSmoke )
				{
				STOP_TALK( Princessa );
				
				SET_DIALOG(PrincessaInTower, MissionComplete);
				
				// CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
				
				return StartPlayDialog, 0;
				}
			}
		if ( IsUnitNearMarker(m_uGiant, 82, 3) )
			{
			if ( m_bGoToEgg )
				{
				SET_DIALOG(DragonEgg, Working);
				
				m_bGoToEgg = false;
				
				EnableInterface(false);
				EnableCameraMovement(false);
				
				PlayerLookAtMarker(m_pPlayer, markerEgg, -1, -1, -1);
				ShowAreaAtMarker(m_pPlayer, markerEgg, 10);
				
				return StartPlayDialog, 30;
				}
			}
		
		return Working;
		}
	
	int m_nShowGateCount;
	int m_nShowGateMarker;
	unitex m_uShowGateUnit;
	
	state ShowGate
		{
		ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
		
		--m_nShowGateCount;
		
		if ( m_nShowGateCount == 0 )
			{
			EnableInterface(true);
			EnableCameraMovement(true);
				
			PlayerLookAtUnit(m_pPlayer, m_uShowGateUnit, -1, -1, -1);
			
			return Working;
			}
		
		return ShowGate, 5;
		}
	
	state MissionEnd
		{
		m_bCheckHero = false;

		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnit(bufferGiant, false, m_uGiant, true);
		m_pPlayer.SaveUnit(bufferPrincessa, false, m_uPrincessa, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		EndMission(true);
		}
	
	state MissionComplete
		{
		return MissionComplete;
		}
	
	state MissionFail
		{
		EndMission( false );
		}
	
	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
		{
		unitex uTmp;
		int nMarker, i;
		
		if ( nArtefactNum == idEgg )
			{
			if ( uUnitOnArtefact == m_uGiant )
				{
				m_bCheckHero = false;
				m_uGiant.ChangePlayer(m_pPlayer);
				SetRealImmortal(m_uGiant, false);
				m_bCheckHero = true;				
				}
			
			return true;
			}
		
		if ( pPlayerOnArtefact != m_pPlayer )
			{
			return false;
			}
		
		if ( nArtefactNum == idKill && m_bGateOn )
			{
			uUnitOnArtefact.KillUnit();
			
			return false;
			}
		
		if ( nArtefactNum == idGiantSwitch )
			{
			if ( uUnitOnArtefact == m_uGiant && state == MissionComplete && !m_uGuard1.IsLive() && !m_uGuard2.IsLive() )
				{
				// OPEN_GATE( 86 );
				// OPEN_GATE( 87 );
				
				m_uWitch = CreateUnitAtMarker(m_pNeutral, markerWitch, "OLDWITCH");
				CreateObjectAtUnit(m_uGiant, "EXP_TRAP1");
				
				SET_DIALOG(WitchTrap, MissionEnd);
				
				CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
				
				m_bGateOn = false;
				
				state StartPlayDialog;
				
				return true;
				}
			}
		
		if ( nArtefactNum == idFireSwitch )
			{
			SetupOneWayTeleportBetweenMarkers(203, 204);
			
			m_bUpdateFire = false;
			
			// CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			// EnableInterface(false);
			// EnableCameraMovement(false);
			
			// m_nShowGateMarker = 4;
			
			for ( i=11; i<=24; ++i ) CreateObjectAtMarker(i, "FIRE4");
			
			// PlayerLookAtMarker(m_pPlayer, m_nShowGateMarker, -1, -1, -1);
			// ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
			//
			// m_nShowGateCount = 8;
			//
			// state ShowGate;
			//
			// return true
			// }
			//
			// if ( nArtefactNum == idGatesSwitch )
			// {
			
			m_bUpdateGates = false;
			
			for ( nMarker=3; nMarker<=10; ++nMarker )
				{
				OPEN_GATE( nMarker );
				}
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			EnableInterface(false);
			EnableCameraMovement(false);
			
			m_nShowGateMarker = 3;
			m_uShowGateUnit = uUnitOnArtefact;
			
			PlayerLookAtMarker(m_pPlayer, m_nShowGateMarker, -1, -1, -1);
			ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
			
			m_nShowGateCount = 8;
			
			state ShowGate;
			
			return true;
			}
		
		if ( nArtefactNum & maskGateOpenSwitch )
			{
			nMarker = nArtefactNum & ~maskGateOpenSwitch;
			
			uTmp = GetUnitAtMarker( nMarker );
			
			uTmp.CommandBuildingSetGateMode(modeGateOpened);
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			if ( nMarker == 100 )
				{
				SetupOneWayTeleportBetweenMarkers(201, 202);

				EnableInterface(false);
				EnableCameraMovement(false);
				
				m_nShowGateMarker = 100;
				m_uShowGateUnit = uUnitOnArtefact;
				
				PlayerLookAtMarker(m_pPlayer, m_nShowGateMarker, -1, -1, -1);
				ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
				
				AddWorldMapSignAtMarker(100, 0, -1);
				m_bRemoveWorldMapSignAtMarker100 = true;
				
				m_nShowGateCount = 8;
				
				state ShowGate;
				}
			
			return true;
			}
		else if ( nArtefactNum & maskGateCloseSwitch )
			{
			nMarker = nArtefactNum & ~maskGateCloseSwitch;
			
			uTmp = GetUnitAtMarker( nMarker );
			
			uTmp.CommandBuildingSetGateMode(modeGateClosed);
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			return true;
			}
		else if ( nArtefactNum & maskRandomSwitch )
			{
			nMarker = nArtefactNum & ~maskRandomSwitch;
			
			if ( nMarker == m_nRandomSwitchOpen )
				{
				OPEN_GATE( 72 );
				
				CreateUnitsAtMarker(m_pEnemy1, nMarker, "SKELETON2", 2);
				CreateObjectAtMarker(nMarker, "HIT_TELEPORT3x3");
				
				m_nShowGateMarker = 72;
				m_uShowGateUnit = uUnitOnArtefact;
				
				PlayerLookAtMarker(m_pPlayer, m_nShowGateMarker, -1, -1, -1);
				ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
				
				m_nShowGateCount = 8;
				
				state ShowGate;
				}
			else
				{
				CreateUnitsAtMarker(m_pEnemy1, nMarker, "SKELETON2", 8);
				CreateObjectAtMarker(nMarker, "HIT_TELEPORT3x3");
				}
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
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
			else if ( uUnit == m_uPrincessa )
				{
				SetGoalState(goalPrincessaMustSurvive, goalFailed);
				
				MissionFailed();
				}
			else if ( uUnit == m_uGiant )
				{
				SetGoalState(goalGiantMustSurvive, goalFailed);
				
				MissionFailed();
				}
			}
		
		if ( uUnit == m_uGuard1 || uUnit == m_uGuard2 )
			{
			if ( !m_uGuard1.IsLive() && !m_uGuard2.IsLive() && GetGoalState(goalKillGuardian) != goalAchieved )
				{
				START_TALK( Princessa );
				
				SetGoalState(goalKillGuardian, goalAchieved);
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
		m_bCheckHero = false;
		
		m_uGiant.ChangePlayer(m_pPlayer);
		m_uPrincessa.ChangePlayer(m_pPlayer);
		
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
		if ( state == Start1 || state == Start2 || state == Start3 || state == Start )
		{
			if ( state == Start1 || state == Start2 )
			{
				CreatePriestAtMarket(m_pPriest, markerPriestStart);
			}

			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+106,GetTop()+114,14,37,41,0);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
	
