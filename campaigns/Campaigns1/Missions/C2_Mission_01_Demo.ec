#define MISSION_NAME "translate2_01"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_01_Dialog_
#include "Language\Common\timeMission2_01.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_01\\201_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start;
		state StartCut;
		state FindChild;
		state FoundChild;
		state FindVillage;
		state DestroyEnemyFirst;
		state DestroyEnemy;
		state DestroyedEnemy;
		state MissionComplete;
		state MissionFail;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
		#include "..\..\Priest.ech"
	
	consts
		{
		dialogNeighbourHelp = 1;
		dialogDefense       = 2;
		dialogKidnapping    = 3;
		dialogMissionFail   = 4;
		
		playerPriest = 2;
		
		goalMirkoMustSurvive  = 0;
		// goalFatherMustSurvive = 1;
		goalNeighbourHelp     = 1;
		goalDefendVillage     = 2;
		
		markerHeroStart = 0;
		
		markerHeroEnd = 49;
		
		markerCrewEndFrom = 47;
		markerCrewEndTo = 48;
		
		markerGate = 42;
		
		//		markerAreaToShow = 9;
		//		rangeAreaToShow = 10;
		
		markerChild = 1;
		
		//		markerTrigerChildFrom = 0;
		//		markerTrigerChildTo   = 1;
		
		//		idTrigerChild = 9990;
		
		markerVillage = 4;
		
		markerKnight = 58;
		
		// markerMapLimiter = 40;
		
		rangeTalk = 1;
		
		idMine = 12345;
		}
	
	// players ->
		player m_pPlayer;
		
		player m_pEnemy;
		player m_pAnimals;
		player m_pFriend;
		player m_pNeutral;
		player m_pEnemy2;
	// units ->		
		unitex m_uHero;
		unitex m_uGate;
		unitex m_uKnight;
		
		unitex m_uChild;
	// vars ->
		int m_nAttack;
		platoon m_aplatMain[];
		
		int m_nCounter;
		
		int m_bCheckHero;
		
		unitex m_uKnightTalkSmoke;
		
		//	int m_bActivatedTrigerChild;
	
	/*
	function int UpdateChild()
		{
		if ( m_uChild.IsLive() )
			{
			if ( m_uHero.GetLocationZ() == 0 )
				{
				CommandMoveUnitToUnit(m_uChild, m_uHero);
				}
			}
		
		return true;
		}
	*/
	
	function int RegisterGoals()
		{
		REGISTER_GOAL( MirkoMustSurvive  );
		// REGISTER_GOAL( FatherMustSurvive );
		REGISTER_GOAL( NeighbourHelp     );
		REGISTER_GOAL( DefendVillage     );
		
		EnableGoal(goalMirkoMustSurvive, true);
		// EnableGoal(goalFatherMustSurvive, true);
		
		return true;
		}
	function int ModifyDifficulty()
		{
		//		OnDifficultyLevelClearMarkers( difficultyEasy  , XX, XX, 0 );
		//		OnDifficultyLevelClearMarkers( difficultyMedium, XX, XX, 0 );
		
		return true;
		}
	function int InitializePlayers()
		{
		m_pPlayer   = GetPlayer( 2);
		
		m_pEnemy    = GetPlayer( 3);
		m_pEnemy2   = GetPlayer( 4);
		m_pFriend   = GetPlayer(10);
		m_pAnimals	= GetPlayer(14);
		m_pNeutral  = GetPlayer( 0);
		
		INITIALIZE_PLAYER( Priest );
		
		m_pEnemy.EnableAI(false);
		m_pFriend.EnableAI(false);
		m_pAnimals.EnableAI(false);
		m_pEnemy2.EnableAI(false);
		m_pNeutral.EnableAI(false);
		
		SetAlly(m_pPlayer, m_pFriend);
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		
		SetNeutrals(m_pEnemy , m_pFriend);
		SetEnemies(m_pEnemy2, m_pFriend);
		
		SetNeutrals(m_pEnemy, m_pEnemy2);
		
		SetNeutrals(m_pEnemy, m_pAnimals);
		SetNeutrals(m_pEnemy2, m_pAnimals);
		
		SetNeutrals(m_pFriend, m_pNeutral);
		SetNeutrals(m_pFriend, m_pAnimals);
		
		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pEnemy2);
		SetEnemies(m_pPlayer, m_pAnimals);

		m_pEnemy2.SetSideColor(m_pEnemy.GetSideColor());
		
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",2);
		m_pPlayer.SetMaxCountLimitForObject("HUT",2);
		m_pPlayer.SetMaxCountLimitForObject("BARRACKS",3);
		m_pPlayer.SetMaxCountLimitForObject("COURT",0);
		m_pPlayer.SetMaxCountLimitForObject("TEMPLE",0);
		m_pPlayer.SetMaxCountLimitForObject("SHRINE",0);
		
		m_pPlayer.SetMaxCountLimitForObject("PRIEST",0);
		m_pPlayer.SetMaxCountLimitForObject("WITCH",0);
		m_pPlayer.SetMaxCountLimitForObject("PRIESTESS",0);
		m_pPlayer.SetMaxCountLimitForObject("KNIGHT",0);
		m_pPlayer.SetMaxCountLimitForObject("SORCERER",0);
		
		m_pPlayer.EnableResearchUpdate("SPEAR3"  , false); // 1
		m_pPlayer.EnableResearchUpdate("BOW3"    , false); // 1
		m_pPlayer.EnableResearchUpdate("SWORD2"  , false); // 1
		m_pPlayer.EnableResearchUpdate("AXE3"    , false); // 1
		m_pPlayer.EnableResearchUpdate("SHIELD1C", false); // 1
		m_pPlayer.EnableResearchUpdate("ARMOUR2A", false); // 1
		m_pPlayer.EnableResearchUpdate("HELMET2" , false); // 1

		m_pPlayer.ResearchUpdate("SPELL_SHIELD");
		m_pPlayer.ResearchUpdate("SPELL_CAPTURE");

		return true;
		}
	function int InitializeUnits()
		{
		int i, nCount;
		unitex uTmp;
		
		if ( GetDifficultyLevel() == difficultyEasy )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_EASY", 0x80);
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO", 0x80);
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_HARD", 0x80);
		}
		
		m_uHero.SetIsHeroUnit(true);
        m_uHero.SetIsSingleUnit(true);

		m_uHero.SetExperienceLevel( 2 );
		
		m_bCheckHero = true;
		
		INITIALIZE_UNIT( Child  );
		
		m_uKnight = CreateUnitAtMarker(m_pFriend, markerKnight, "FATHER", 0x80);

		SetRealImmortal(m_uKnight, true);
		
		INITIALIZE_UNIT( Gate );
		m_uGate.CommandBuildingSetGateMode( modeGateClosed );
		
		CLOSE_GATE( 50 );
		
		for (i=60; i<=71; ++i)
			{
			uTmp = GetUnitAtMarker( i );
			uTmp.CommandSetMovementMode(modeHoldPos);
			}
		
		uTmp = GetUnitAtMarker( 51 );
		SetRealImmortal(uTmp.GetUnitOnTower(), true);
		
		nCount = m_pFriend. GetNumberOfUnits(); 
		for ( i = 0; i < nCount; ++i )
			{
			uTmp = m_pFriend.GetUnit(i);
			uTmp.EnableCapture(false);
			}
		
		return true;
		}
	//	function int InitializeTrigers()
		//	{
		//		CreateArtefactsLine("ARTIFACT_INVISIBLE", markerTrigerChildFrom, markerTrigerChildTo, idTrigerChild);
		//
		//		m_bActivatedTrigerChild = false;
		//
		//		return true;
		//	}
	function int MissionCompleted()
		{
		unitex uUnit;
		
		if ( state == MissionComplete || state == MissionFail )
		{
			if (state == MissionComplete)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		// CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
		
		SetAlly(m_pPlayer, m_pFriend);
		
		ShowAreaAtMarker(m_pPlayer, markerGate, 10);
		PlayerLookAtUnit(m_pPlayer, m_uGate, -1, -1, -1);
		
		uUnit = CreateUnitAtMarker(m_pFriend, 43, "PRINCESS");
		CommandMoveUnitToMarker(uUnit, 46);
		
		uUnit = CreateUnitAtMarker(m_pFriend, 44, "BANDIT");
		CommandMoveUnitToMarker(uUnit, 46);
		uUnit = CreateUnitAtMarker(m_pFriend, 45, "BANDIT");
		CommandMoveUnitToMarker(uUnit, 46);
		
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 46, idMine);
		
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
	
	event Timer0() // update child
		{
		if ( m_bPlayingDialog )
			{
			return;
			}
		
		/*
		if ( state == FindChild )
			{
			UpdateChild();
			}
		*/
		}
	event Timer1() // attacks
		{
		int i;
		platoon plat;
		
		// TRACE2("Timer Attack:", m_nAttack);
		
		if ( m_nAttack < 3 )
			{
			for (i=0; i<m_aplatMain.GetSize(); ++i)
				{
				plat = m_aplatMain[i];
				plat.CommandMoveAndDefend( GetPointX(53+m_nAttack), GetPointY(53+m_nAttack), 0 );
				
				// TRACE2("-> Platoon MoveAndDefend:", i);
				}
			if ( m_nAttack < 2) PlayerLookAtMarker(m_pPlayer, 53+m_nAttack, -1, -1, -1);
			
			++m_nAttack;
			}
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
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogNeighbourHelp )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			#define UNIT_NAME_FROM Child
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    NeighbourHelp
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			
			m_nGameCameraZ = 23;
			m_nGameCameraAlpha = -1;
			m_nGameCameraView = 32;
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogDefense )
			{
			#define UNIT_NAME_FROM Knight
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Defense
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogKidnapping )
			{
			#define UNIT_NAME_FROM Knight
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Kidnapping
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
		int x, y, z, a;

		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogNeighbourHelp )
			{
			x = m_uChild.GetLocationX();
			y = m_uChild.GetLocationY();
			z = m_uChild.GetLocationZ();
			a = m_uChild.GetAlphaAngle();

			m_uChild.RemoveUnit();
			m_uChild = m_pNeutral.CreateUnit(x, y, z, a, "SHEPHERD");

			CommandMoveUnitToMarker(m_uChild, 10);
			CommandMoveUnitToMarker(m_uHero , 75);
			
			EnableGoal(goalNeighbourHelp, true);
			}
		if ( m_nDialogToPlay == dialogDefense )
			{
			CommandMoveUnitToMarker(m_uKnight, markerKnight);
			
			EnableGoal(goalDefendVillage, true);
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		SAFE_REMOVE_PRIEST();
		
		if ( m_nDialogToPlay == dialogNeighbourHelp )
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
		if ( m_nDialogToPlay == dialogDefense )
			{
			SetTimer(1, 4*60*20);
			}
		
		BEGIN_RESTORE_STATE_BLOCK()
		RESTORE_STATE(DestroyEnemy)
		RESTORE_STATE(DestroyedEnemy)
		RESTORE_STATE(FindVillage)
		RESTORE_STATE(MissionComplete)
		RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
		}
	state Initialize
		{
		TurnOffTier5Items();
		
		ModifyDifficulty();
		
		InitializePlayers();
		InitializeUnits();
		//		InitializeTrigers();
		
		RegisterGoals();
		
		SetTimer(0, 20);
		SetTimer(1, 0);
		SetTimer(2, 100);
		
		// SetGameRect(GetLeft(), GetTop(), GetRight(), GetPointY(markerMapLimiter));
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		
		ExecuteConsoleCommand("Terrain.MinDrawDistance 25.0");
		ExecuteConsoleCommand("Graph.DrawDistance 25.0");
		ExecuteConsoleCommand("Terrain.MaxDrawDistance 25.0");
		
		EnableInterface(false);
		EnableCameraMovement(false);
		
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+60, GetTop()+74, 11, 94, 62, 0);
		
		ShowAreaAtMarker(m_pPlayer, markerChild, 12);
		ShowAreaAtMarker(m_pPlayer, 11, 12);
		
		SetTime(55);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		PlayTrack("Music\\war05.tws");
		
		return Start, 1;
		}
	state Start
		{
		SetAlly(m_pPlayer, m_pNeutral);
		
		SetCutsceneText("translate2_01_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+60, GetTop()+74, 11, 109, 62, 0, 100, true);
		
		CommandMoveUnitToMarker(m_uChild, 2);
		
		return StartCut, 100;
		}
	state StartCut
		{
		SetLowConsoleText("");

		m_pPlayer.LookAt(GetLeft()+60, GetTop()+75, 11, 148, 46, 0);
		m_pPlayer.DelayedLookAt(GetLeft()+48, GetTop()+49, 14, 32, 40, 0, 280, false);
		
		return FindChild, 180;
		}
	state FindChild
		{
		CommandMoveUnitToMarker(m_uHero, 3);
		
		return FoundChild, 100;
		}
	state FoundChild
		{
		SetNeutrals(m_pPlayer, m_pNeutral);
		
		SET_DIALOG( NeighbourHelp, FindVillage );
		
		AddWorldMapSignAtMarker(markerVillage, 0, -1);
		
		m_nCounter = 1;
		m_nAttack  = 0;
		
		ExecuteConsoleCommand("Terrain.MinDrawDistance 25.0");
		ExecuteConsoleCommand("Terrain.MaxDrawDistance 60.0");
		
		return StartPlayDialog, 0;
		}
	state FindVillage
		{
		int i;
		unitex uTmp;
		
		if ( IsPlayerUnitNearMarker(5, 8, m_pPlayer.GetIFF()) )
			{
			// OPEN_GATE( 51 );
			// OPEN_GATE( 56 );
			
			SetEnemies(m_pFriend, m_pEnemy);
			SetEnemies(m_pFriend, m_pEnemy2);
			
			RemoveWorldMapSignAtMarker(markerVillage);

			return DestroyEnemyFirst;
			}
		
		if ( (m_nCounter % (4*60)) == 0 )
			{
			if ( m_nAttack < 4 )
				{
				for ( i=60+3*m_nAttack; i<63+3*m_nAttack; ++i )
					{
					uTmp = GetUnitAtMarker(i);
					
					uTmp.CommandSetMovementMode(modeMove);
					CommandMoveAndDefendUnitToMarker(uTmp, 51);
					}
				++m_nAttack;
				}
			++m_nCounter;
			}
		return FindVillage;
		}	
	state DestroyEnemyFirst
		{
		int nExp;
		
		if ( m_pEnemy.GetNumberOfUnits() == 0 )
			{
			if ( !m_uKnightTalkSmoke )
				{
				CommandMoveUnitToMarker( m_uKnight, 59 );
				
				SetGoalState(goalNeighbourHelp, goalAchieved);
				
				START_TALK( Knight );
				}
			}
		if ( IsUnitNearUnit(m_uHero, m_uKnight, rangeTalk) && ! m_uHero.IsMoving() && ! m_uKnight.IsMoving() )
			{
			if ( m_uKnightTalkSmoke )
				{
				STOP_TALK( Knight );
				
				m_nAttack = 0;
				m_aplatMain.Create(0);
				
				nExp = GetDifficultyLevel();
				
				m_pPlayer.SetMaxCountLimitForObject("HUT",4);
				m_pPlayer.SetMaxCountLimitForObject("BARRACKS",4);
				
				// m_pPlayer.SetMaxCountLimitForObject("PRIEST",-1);
				// m_pPlayer.SetMaxCountLimitForObject("WITCH",-1);
				// m_pPlayer.SetMaxCountLimitForObject("PRIESTESS",-1);
				// m_pPlayer.SetMaxCountLimitForObject("KNIGHT",-1);
				// m_pPlayer.SetMaxCountLimitForObject("SORCERER",-1);
				
				m_aplatMain.Add(CreateExpUnitsAtMarker(m_pEnemy, 52, "FOOTMAN" , nExp, 10));
				m_aplatMain.Add(CreateExpUnitsAtMarker(m_pEnemy, 52, "HUNTER"  , nExp, 20));
				m_aplatMain.Add(CreateExpUnitsAtMarker(m_pEnemy, 52, "BANDIT"  , nExp, 20));
				m_aplatMain.Add(CreateExpUnitsAtMarker(m_pEnemy, 52, "SPEARMAN", nExp, 20));
				
				CreateUnits(m_pFriend, 53, 54, "HUNTER");
				CreateUnits(m_pFriend, 72, 74, "HUNTER");
				
				SET_DIALOG( Defense, DestroyEnemy );
				
				return StartPlayDialog, 0;
				}
			}
		}
	state DestroyEnemy
		{
		if ( m_pEnemy.GetNumberOfUnits() == 0 )
			{
			if ( !m_uKnightTalkSmoke )
				{
				CommandMoveUnitToMarker( m_uKnight, 59 );
				
				SetGoalState(goalDefendVillage, goalAchieved);
				
				START_TALK( Knight );
				}
			}
		if ( IsUnitNearUnit(m_uHero, m_uKnight, rangeTalk) && ! m_uHero.IsMoving() && ! m_uKnight.IsMoving() )
			{
			if ( m_uKnightTalkSmoke )
				{
				STOP_TALK( Knight );
				
				m_uGate.CommandBuildingSetGateMode( modeGateOpened );
				
				OPEN_GATE( 50 );
				
				SET_DIALOG( Kidnapping, DestroyedEnemy );
				
				return StartPlayDialog, 0;
				}
			}
		return DestroyEnemy;
		}
	state DestroyedEnemy
		{
		if ( MissionCompleted() )
			{
			return MissionComplete, 100;
			}
		else
			{
			return MissionFail;
			}
		}

	// *** *** *** *** *** *** *** ***
	state MissionCompleteBis
	{
		SetLowConsoleText("");

		m_bCheckHero = false;
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		EnableInterface(true);
		EnableCameraMovement(true);

		ShowInterfaceBlackBorders(false, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		EndMission(true);
	}

	state MissionCompleteDemo
	{
		SetCutsceneText("translateDemoEndsHere");

		return MissionCompleteBis, 170;
	}
	// *** *** *** *** *** *** *** ***

	state MissionComplete
		{
		PlayTrack("Music\\RPGvictory.tws");

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterface(false, INITIALIZE_CAMERA_DELAY);
		ShowPanel(false, INITIALIZE_CAMERA_DELAY);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 30);

		return MissionCompleteDemo, 30;
		}
	state MissionFail
		{
		EndMission(false);
		
		return MissionFail;
		}
	
	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
		{
		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
			{
			m_bCheckHero = false;
			SAVE_PLAYER_UNITS();
			
			EndMission(true);
			}
		//		else if ( nArtefactNum == idTrigerChild )
		//		{
		//			m_bActivatedTrigerChild = true;
		//
		//			return true;
		//		}
		else if ( nArtefactNum == idMine )
			{
			ClearArea(uUnitOnArtefact.GetIFF(), uUnitOnArtefact.GetLocationX(), uUnitOnArtefact.GetLocationY(), uUnitOnArtefact.GetLocationZ(), 2);
			
			return true;
			}
		
		return false;
		}
	event UnitDestroyed(unitex uUnit)
		{
		unit uTmp;
		
		if ( m_bCheckHero && uUnit == m_uHero )
			{
			SetGoalState(goalMirkoMustSurvive, goalFailed);
			
			MissionFailed();
			}
		
		if ( uUnit == m_uKnight )
			{
			// SetGoalState(goalFatherMustSurvive, goalFailed);
			
			MissionFailed();
			}
		
		if ( uUnit.GetIFF() == m_pFriend.GetIFF() )
			{
			uTmp = uUnit.GetAttacker();
			
			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
				MissionFailed();
				}
			}
		}
	event BuildingDestroyed(unitex uBuilding)
		{
		unit uTmp;
		
		if ( uBuilding.GetIFF() == m_pFriend.GetIFF() && uBuilding.GetBuildingType() != buildingWall )
			{
			uTmp = uBuilding.GetAttacker();
			
			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
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
		m_bCheckHero = false;
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		SetConsoleText("");
		
		EndMission(true);
		}
    event EscapeCutscene()
    {
		if ( state == StartCut || state == FindChild || state == FoundChild )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+48, GetTop()+49, 14, 32, 40, 0);

			SetUnitAtMarker(m_uChild, 2);
			SetUnitAtMarker(m_uHero , 3);

			SetStateDelay(0);
			state FoundChild;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
	
