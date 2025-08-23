#define MISSION_NAME "translate3_05"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_05_Dialog_
#include "Language\Common\timeMission3_05.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_05\\305_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start1;
		state Start;
		state Working;
		state ShowSleeping;
		state Sleeping;
		state MissionFail;
		state MissionComplete;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
		#include "..\..\Priest.ech"
	
	consts
		{
		// goals ->
			goalMirkoMustSurvive = 0;
			goalGainHelmet       = 1;
			goalSolveThePuzzle   = 2;
			goalGoBack           = 3;
			goalGoToPort         = 4;
		// players ->		
			playerNeutral =  0;
			playerPlayer  =  2;
			
			playerEnemy   =  4;
			playerEnemy2  =  3;
			playerAnimals = 14;
			
			playerPriest     =  2;
		// markers ->	
			markerHeroStart =  0;
			markerCrewStart =  1;
			markerHeroDst   = 24;
			markerCrewDst   = 23;
			
			markerHeroEnd   = 25;
			
			markerMag       = 24;
			markerHelmet    = 19;
			markerCowDst    = 13;
			markerBearDst   =  9;
			markerWolfDst   =  5;
		// dialogs ->
			dialogCastleWithHelmet = 1;
			dialogHelmet           = 2;
			dialogBackWithHelmet   = 3;
			dialogMissionFail      = 4;
		// params ->		
			rangeTalk = 1;
			rangeNear = 3;
			
			maskGateOpenSwitch  =  2048;
			maskTeleport        =  4096;
		// ids ->
			idCowDst  = 501;
			idWolfDst = 502;
			idBearDst = 503;
			idHelmet  = 777;
		}
	
	// players ->
		player m_pNeutral;
		player m_pPlayer;
		
		player m_pEnemy;
		player m_pEnemy2;
	// units ->	
		unitex m_uHero;
		platoon m_pCrew;
		
		unitex m_uMag;
		unitex m_uMagTalkSmoke;
		
		unitex m_auCows[];
		unitex m_auWolfs[];
		unitex m_auBears[];
		
		unitex m_auSleepers[];
	// vars ->	
		int m_bCheckHero;
		int m_nPuzzleStep;
		int m_bCheckPlayerUnits;

	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Neutral   );
		INITIALIZE_PLAYER( Player    );
		
		INITIALIZE_PLAYER( Enemy     );
		INITIALIZE_PLAYER( Enemy2    );
		
		m_pNeutral.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		
		INITIALIZE_PLAYER( Priest  );
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pEnemy2);
		
		SetNeutrals(m_pEnemy, m_pEnemy2);
		
		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemy2);

		m_pEnemy.SetUnitsExperienceLevel(5+GetDifficultyLevel());
		m_pEnemy2.SetUnitsExperienceLevel(3+GetDifficultyLevel());
		
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
		
		INITIALIZE_UNIT( Mag );
		SetRealImmortal(m_uMag, true);
		
		m_auCows.Create(0);
		m_auWolfs.Create(0);
		m_auBears.Create(0);
		
		m_auSleepers.Create(0);
		
		for ( i=40; i<=67; ++i ) m_auSleepers.Add( GetUnitAtMarker(i) );
		
		return true;
		}
	function int MissionFailed()
		{
		if ( state == MissionFail )
			{
			return false;
			}
		
		PlayTrack("Music\\defeat.tws");
		
		CREATE_PRIEST_NEAR_UNIT( Hero );
		
		PlayerLookAtUnit(m_pPlayer, m_uPriest, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;
		
		state StartPlayDialog;
		
		return true;
		}
	function int RegisterGoals()
		{
		REGISTER_GOAL( MirkoMustSurvive );
		REGISTER_GOAL( GainHelmet       );
		REGISTER_GOAL( SolveThePuzzle   );
		REGISTER_GOAL( GoBack           );
		REGISTER_GOAL( GoToPort         );
		
		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalGainHelmet, true);
		
		return true;
		}
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogCastleWithHelmet )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mag
			#define DIALOG_NAME    CastleWithHelmet
			#define DIALOG_LENGHT  16
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogHelmet )
			{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Helmet
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogBackWithHelmet )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BackWithHelmet
			#define DIALOG_LENGHT  3
			
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
		int i;
		unitex uTmp;
		
		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogCastleWithHelmet )
			{
			EnableGoal(goalSolveThePuzzle, true);
			
			AddWorldMapSignAtMarker(10, 0, 2*60*20);
			AddWorldMapSignAtMarker(30, 0, 2*60*20);
			AddWorldMapSignAtMarker( 6, 0, 2*60*20);
			}
		else if ( m_nDialogToPlay == dialogHelmet )
			{
			SetGoalState(goalGainHelmet, goalAchieved);
			EnableGoal(goalGoBack, true);
			
			OPEN_GATE( 16 );
			
			SetEnemies(m_pPlayer, m_pEnemy);
			
			for ( i=0; i<m_auSleepers.GetSize(); ++i )
				{
				uTmp = m_auSleepers[i];
				if ( uTmp.IsLive() )
					{
					uTmp.CommandSleepMode(false);
					uTmp.RegenerateHP();
					}
				else
					{
					m_auSleepers.RemoveAt(i);
					--i;
					}
				}
			
			START_TALK( Mag );

			AddWorldMapSignAtMarker(markerMag, 0, -1);
			
			SetConsoleText("translate3_05_Console_ReturnToMage");
			}
		else if ( m_nDialogToPlay == dialogBackWithHelmet )
			{
			SetGoalState(goalGoBack, goalAchieved);
			EnableGoal(goalGoToPort, true);
			
			PlayTrack("Music\\victory.tws");

			RemoveWorldMapSignAtMarker(markerMag);
			AddWorldMapSignAtMarker(markerHeroEnd, 0, -1);
			
			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerHeroEnd, idHeroEnd);
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogCastleWithHelmet )
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
	state Initialize
		{
		TurnOffTier5Items();
		
		CallCamera();
		
		InitializePlayers();
		InitializeUnits();
		
		SetAllBridgesImmortal(true);
		
		RegisterGoals();
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		
		SetTimer(2, 100);
		
		CLOSE_GATE(  4 );
		CLOSE_GATE(  8 );
		CLOSE_GATE( 12 );
		CLOSE_GATE(  3 );
		CLOSE_GATE( 15 );
		CLOSE_GATE( 16 );
		
		OPEN_GATE( 14 );
		
		CLOSE_GATE( 18 );
		CLOSE_GATE( 82 );
		CLOSE_GATE( 16 );
		
		CreateArtefactAtMarker("ART_HELMET5"       , markerHelmet, 0);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", markerHelmet, idHelmet);
		
		CreateArtefactAtMarker("SWITCH_1_1", 28, maskGateOpenSwitch| 4);
		CreateArtefactAtMarker("SWITCH_1_1", 29, maskGateOpenSwitch| 8);
		CreateArtefactAtMarker("SWITCH_1_1", 11, maskGateOpenSwitch|12);
		CreateArtefactAtMarker("SWITCH_1_1",  7, maskGateOpenSwitch| 3);
		
		CreateArtefactAtMarker("SWITCH_1_1", 80, maskGateOpenSwitch|18);
		CreateArtefactAtMarker("SWITCH_1_1", 81, maskGateOpenSwitch|82);
		CreateArtefactAtMarker("SWITCH_1_1", 83, maskGateOpenSwitch|16);
		
		CreateArtefactAtMarker("SWITCH_2_1", 13, idCowDst);
		CreateArtefactAtMarker("SWITCH_2_1",  5, idWolfDst);
		CreateArtefactAtMarker("SWITCH_2_1",  9, idBearDst);
		
		m_nPuzzleStep = 0;
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+104,GetTop()+103,21,176,59,0);
		ShowAreaAtMarker(m_pPlayer, markerHeroStart, 40);
		
		SetAlly(m_pPlayer, m_pNeutral);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate3_05_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+105,GetTop()+100,23,14,34,0,300,1);
		
		return Start1, 100;
		}
	state Start1
		{
		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		if ( RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart) < 3 )
			{
			CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "FOOTMAN", 3 - m_pPlayer.GetSavedUnitsCount(bufferCrew));
			}
		
		m_pCrew = GetPlayerCrew();
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		CommandMoveUnitToUnit(m_uHero, m_uMag, -3, 0);
		CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
		
		return Start, 200;
		}
	state Start
		{
		SetLowConsoleText("");
		
		SET_DIALOG(CastleWithHelmet, Working);
		
		SetNeutrals(m_pPlayer, m_pNeutral);
		
		return StartPlayDialog, 0;
		}
	state Working
		{
		int i;
		unitex uTmp;
		
		if ( m_bCheckPlayerUnits )
			{
			if ( m_pPlayer.GetNumberOfUnits() < 4 - m_nPuzzleStep )
				{
				SetGoalState(goalSolveThePuzzle, goalFailed);
				MissionFailed();
				
				return StartPlayDialog, 0;
				}
			m_bCheckPlayerUnits = false;
			}
		
		if ( m_nPuzzleStep >= 3 )
			{
			ASSERT( m_nPuzzleStep == 3 );
			
			SetGoalState(goalSolveThePuzzle, goalAchieved);
			
			EnableInterface(false);
			EnableCameraMovement(false);
			ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
			
			m_pPlayer.SpyPlayer(m_pEnemy, true, 200);
			
			PlayerLookAtMarker(m_pPlayer, markerHelmet, -1, 0x20, -1);
			m_pPlayer.DelayedLookAt(-1, -1, -1, 0xa0, -1, GetPointZ(markerHelmet), 200, true);
			
			CreateObjectAtMarker(markerHelmet, "SPELL_SLEEP");
			
			CreateObjectAtMarker( 5, "FIRETRAP1");
			CreateObjectAtMarker( 9, "FIRETRAP1");
			CreateObjectAtMarker(13, "FIRETRAP1");
			
			SetNeutrals(m_pPlayer, m_pEnemy);
			
			for ( i=0; i<m_auSleepers.GetSize(); ++i )
				{
				uTmp = m_auSleepers[i];
				if ( uTmp.IsLive() )
					{
					uTmp.DamageUnit(50);
					uTmp.CommandSleepMode(true);
					}
				else
					{
					m_auSleepers.RemoveAt(i);
					--i;
					}
				}
		
			return ShowSleeping, 200;
			}
		
		return Working;
		}
	state ShowSleeping
		{
		EnableInterface(true);
		EnableCameraMovement(true);
		ShowInterfaceBlackBorders(false, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		ShowAreaAtMarker(m_pPlayer, 36, 16);
		PlayerLookAtMarker(m_pPlayer, 36, -1, -1, -1);
		
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 34, maskTeleport|39);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 35, maskTeleport|39);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 36, maskTeleport|39);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 37, maskTeleport|39);
		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 38, maskTeleport|39);
		
		return Sleeping;
		}
	state Sleeping
		{
		int i;
		unitex uTmp;
		
		for ( i=0; i<m_auSleepers.GetSize(); ++i)
			{
			uTmp = m_auSleepers[i];
			if ( uTmp.GetHP()*2 >= uTmp.GetMaxHP() ) uTmp.DamageUnit(10);
			}
		
		return Sleeping;
		}
	state MissionComplete
		{
		if ( IsUnitNearUnit(m_uHero, m_uMag, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uMagTalkSmoke )
				{
				STOP_TALK( Mag );
				
				SetConsoleText("");
				
				SET_DIALOG(BackWithHelmet, MissionComplete);
				
				return StartPlayDialog, 0;
				}
			}
		return MissionComplete;
		}
	state MissionFail
		{
		EndMission(false);
		}
	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
		{
		int nMarker;
		int x, y, z;
		
		// TRACE2("event Artefact:", nArtefactNum);
		
		if ( pPlayerOnArtefact != m_pPlayer )
			{
			return false;
			}
		
		if ( nArtefactNum & maskGateOpenSwitch )
			{
			nMarker = nArtefactNum & ~maskGateOpenSwitch;
			OPEN_GATE( nMarker );
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			if ( nMarker == 18 || nMarker == 82 || nMarker == 16 )
				{
				m_pPlayer.SpyPlayer(m_pEnemy, true, 40);
				PlayerLookAtMarker(m_pPlayer, nMarker, -1, -1, -1);
				}
			
			return true;
			}
		
		if ( nArtefactNum == idCowDst && IsUnitInArray(m_auCows, uUnitOnArtefact) )
			{
			RemoveUnitFromArray(m_auCows, uUnitOnArtefact);
			
			uUnitOnArtefact.ChangePlayer(m_pNeutral);
			CLOSE_GATE(12);
			++m_nPuzzleStep;
			
			CreateArtefactAtUnit("SWITCH_2_2", uUnitOnArtefact, 0);
			
			return true;
			}
		if ( nArtefactNum == idWolfDst && IsUnitInArray(m_auWolfs, uUnitOnArtefact) )
			{
			RemoveUnitFromArray(m_auWolfs, uUnitOnArtefact);
			
			uUnitOnArtefact.ChangePlayer(m_pNeutral);
			CLOSE_GATE(4);
			++m_nPuzzleStep;
			
			CreateArtefactAtUnit("SWITCH_2_2", uUnitOnArtefact, 0);
			
			return true;
			}
		if ( nArtefactNum == idBearDst && IsUnitInArray(m_auBears, uUnitOnArtefact) )
			{
			RemoveUnitFromArray(m_auBears, uUnitOnArtefact);
			
			uUnitOnArtefact.ChangePlayer(m_pNeutral);
			CLOSE_GATE(8);
			++m_nPuzzleStep;
			
			CreateArtefactAtUnit("SWITCH_2_2", uUnitOnArtefact, 0);
			
			return true;
			}
		
		if ( nArtefactNum == idHelmet && uUnitOnArtefact == m_uHero )
			{
			SET_DIALOG(Helmet, MissionComplete);
			
			CreateObjectAtMarker(markerHelmet, "SPELL_WAKEUP");
			
			state StartPlayDialog;
			
			return true;
			}
		
		if ( nArtefactNum & maskTeleport )
			{
			nMarker = nArtefactNum & ~maskTeleport;
			
			x = GetPointX(nMarker);
			y = GetPointY(nMarker);
			z = GetPointZ(nMarker);
			
			// if ( uUnitOnArtefact == m_uHero ) m_bCheckHero = false;
			
			// m_pPlayer.SaveUnit(bufferHero, false, uUnitOnArtefact, true);
			// ClearMarkers(nMarker, nMarker, 0);
			// for ( x = GetPointX(nMarker)-2; x <= GetPointX(nMarker)+2; ++x )
			//	{
			//	for ( y = GetPointY(nMarker)-2; y <= GetPointY(nMarker)+2; ++y )
			//		{
			//		if ( GetUnit(x, y, z) == null )
			//			{
			//			m_pPlayer.RestoreUnitsAt(bufferHero, x, y, z, true);
			//			
			//			if ( uUnitOnArtefact == m_uHero )
			//				{
			//				m_uHero = GetUnit(x, y, z);
			//				m_bCheckHero = true;
			//				}
			
			uUnitOnArtefact.SetImmediatePosition(x, y, z, uUnitOnArtefact.GetAlphaAngle(), true);
			CreateObjectAtUnit(uUnitOnArtefact, "HIT_TELEPORT");
						
			PlayerLookAtMarker(m_pPlayer, nMarker, -1, -1, -1);
			return false;
			
			//			}
			//		}
			//	}
			}
		
		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
			{
			m_bCheckHero = false;
			m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
			
			m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
			m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
			
			EndMission(true);
			}
		
		return false;
		}
	event UnitDestroyed(unitex uUnit)
		{
		int i;
		unitex uTmp;
		
		// TRACE2("UnitDestroyed:", uUnit);
		
		if ( m_bCheckHero )
			{
			if ( uUnit == m_uHero )
				{
				SetGoalState(goalMirkoMustSurvive, goalFailed);
				MissionFailed();
				}
			}
		
		if ( uUnit.GetIFF() == m_pPlayer.GetIFF() )
			{
			RemoveUnitFromArray(m_auCows, uUnit);
			RemoveUnitFromArray(m_auWolfs, uUnit);
			RemoveUnitFromArray(m_auBears, uUnit);
			
			m_bCheckPlayerUnits = true;
			}
		
		if ( uUnit.GetIFF() == m_pEnemy.GetIFF() && state == Sleeping )
			{
			SetEnemies(m_pPlayer, m_pEnemy);
			
			for ( i=0; i<m_auSleepers.GetSize(); ++i )
				{
				uTmp = m_auSleepers[i];
				if ( uTmp.IsLive() )
					{
					uTmp.CommandSleepMode(false);
					uTmp.RegenerateHP();
					}
				else
					{
					m_auSleepers.RemoveAt(i);
					--i;
					}
				}
			
			state MissionComplete;
			}
		}
	event UnitCreated(unitex uUnit)
		{
		// TRACE2("UnitCreated:", uUnit);
		
		if ( uUnit.GetIFF() == m_pPlayer.GetIFF() )
			{
			if ( IsUnitNearMarker(uUnit, 10, 0) ) m_auCows.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 30, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 31, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 32, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 33, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 78, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit, 79, 0) ) m_auWolfs.Add(uUnit);
			if ( IsUnitNearMarker(uUnit,  6, 0) ) m_auBears.Add(uUnit);
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
		if ( state == Start || state == Start1 )
		{
			SetLowConsoleText("");
			
			if ( state == Start1 )
			{
				m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
				if ( RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart) < 3 )
				{
					CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "FOOTMAN", 3 - m_pPlayer.GetSavedUnitsCount(bufferCrew));
				}
				
				m_pCrew = GetPlayerCrew();
				
				INITIALIZE_HERO();
				m_bCheckHero = true;
				
				CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
			}
			
			m_pPlayer.LookAt(GetLeft()+105,GetTop()+100,23,14,34,0);
			
			SetUnitAtMarker(m_uHero, markerMag, -3, 0);
			
			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
