#define MISSION_NAME "translate2_02"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate2_02_Dialog_
#include "Language\Common\timeMission2_02.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission2_02\\202_"

mission MISSION_NAME
	{
	state Initialize;
	state Start0;
	// state Start1;
	// state Start2;
	state Start;
	state FindWoodcutter;
	
	state Working;
	
	state MissionFail;
	state MissionComplete;

	state ShowGate;

	#include "..\..\Common.ech"
	#include "..\..\Talk.ech"
	#include "..\..\Priest.ech"
	
	consts
		{
		goalMirkoMustSurvive = 0;
		goalFindKidnappers   = 1;
		goalFindSepherd      = 2;
		goalFindUnicorn      = 3;
		goalFindMushrooms    = 4;
		goalFollowUnicorn    = 5;
		
		playerNeutral    =  0;
		playerPlayer     =  2;
		playerEnemy      =  3;
		playerBadBoys    =  4;
		playerFriend     =  5;
		playerAnimals    = 14;
		
		playerPriest     =  2;
		
		markerHeroStart    =  0;
		markerCrewStart    =  47;
		
		markerHeroEnd    =	2;
		
		markerCrewEndFrom = 3;
		markerCrewEndTo =   4;
		
		markerBear       =  5;
		markerWoodcutter = 16;
		markerShepherd   =  7;
		
		markerBearSwitch =  8;
		markerBearGate   = 10;
		
		markerWitch      =  9;
		markerWitchGate  = 11;
		
		markerForWitchFirst = 12;
		markerForWitchLast  = 14;
		
		markerFootman    = 15;

		markerBoss1  = 50;
		markerBoss2A = 57;
		markerBoss2B = 58;
		markerBoss3  = 62;
		
		dialogStart             = 1;
		dialogLastKnight        = 2;
		dialogBadBoys           = 3;
		dialogOldWich           = 4;
		dialogFreeShepherd      = 5;
		dialogUnicorn           = 6;
		dialogMissionFail       = 9;
				
		rangeTalk = 1;
		rangeNear = 3;
		
		maskGateOpenSwitch  =  2048;
		maskGateCloseSwitch =  4096;
		maskCreateMonster   =  8192;
		
		markerBearMoveFirst = 32;
		markerBearMoveLast = 41;
		
		markerBearGateFirst = 26;
		markerBearGateLast = 29;
		
		idForWitch = 421;
		idFireTrap = 777;
		}
	
	player m_pPlayer;
	
	player m_pNeutral;
	player m_pEnemy;
	player m_pBadBoys;
	player m_pFriend;
	player m_pAnimals;
	
	unitex m_uHero;
	
	unitex m_uWoodcutter;
	unitex m_uShepherd;
	unitex m_uWitch;
	unitex m_uWitchGate;
	unitex m_uFootman;
	
	unitex m_uBear;
	
	unitex m_uWoodcutterTalkSmoke;
	unitex m_uWitchTalkSmoke;
	unitex m_uFootmanTalkSmoke;
	unitex m_uBearTalkSmoke;
	unitex m_uHeroCarrySmoke;

	unitex m_uBoss1;
	unitex m_uBoss2A;
	unitex m_uBoss2B;
	unitex m_uBoss3;
	
	platoon m_platCrew;
	
	int m_nForWitch;
	
	int m_bCheckHero;
	int m_nBearDest;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Player      );
		
		INITIALIZE_PLAYER( Neutral     );
		INITIALIZE_PLAYER( Enemy       );
		INITIALIZE_PLAYER( BadBoys     );
		INITIALIZE_PLAYER( Friend      );
		INITIALIZE_PLAYER( Animals     );
		
		INITIALIZE_PLAYER( Priest      );
		
		m_pNeutral.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pBadBoys.EnableAI(false);
		m_pFriend.EnableAI(false);
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pBadBoys, m_pPlayer);
		
		SetNeutrals(m_pNeutral, m_pBadBoys);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pAnimals);
		SetNeutrals(m_pNeutral, m_pFriend);
		
		SetNeutrals(m_pFriend, m_pBadBoys);
		SetNeutrals(m_pFriend, m_pEnemy);
		SetNeutrals(m_pFriend, m_pAnimals);
		SetNeutrals(m_pFriend, m_pPlayer);

		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pAnimals);
		
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
		
		m_pPlayer.ResearchUpdate("SPELL_SHIELD");
		m_pPlayer.ResearchUpdate("SPELL_CAPTURE");
		m_pPlayer.ResearchUpdate("SPELL_CONVERSION");

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
		
		platTmp.AddUnitsToPlatoon(x-2, y-2, x+2, y+2, z);
		
		return platTmp;
		}
	
	function platoon CreateCrew(int n1, int n2, int n3, int n4)
		{
		int m1, m2, m3, m4;
		
		m_pPlayer.SortSavedUnitsBuffer(bufferCrew, sortUnitsByExperience);
		
		m1 = RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "SPEARMAN", n1);
		CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "SPEARMAN", n1-m1);
		m2 = RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "FOOTMAN", n2);
		CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "FOOTMAN", n2-m2);
		m3 = RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "PRIESTESS", n3);
		CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "PRIESTESS", n3-m3);
		m4 = RestorePlayerUnitsAtMarker(m_pPlayer, bufferCrew, markerCrewStart, "PRIEST", n4);
		CreateUnitsAtMarker(m_pPlayer, markerCrewStart, "PRIEST", n4-m4);
		
		m_pPlayer.ResetSavedUnits(bufferCrew); // na wszelki wypadek
		
		return GetPlayerCrew();
		}
	
	function int InitializeUnits()
		{
		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		     if ( GetDifficultyLevel() == difficultyEasy   ) m_platCrew = CreateCrew(4, 3, 3, 3);
		else if ( GetDifficultyLevel() == difficultyMedium ) m_platCrew = CreateCrew(3, 2, 2, 2);
		else if ( GetDifficultyLevel() == difficultyHard   ) m_platCrew = CreateCrew(2, 1, 1, 1);
		
		INITIALIZE_UNIT( Shepherd );
		INITIALIZE_UNIT( Witch );
		INITIALIZE_UNIT( Footman );
		INITIALIZE_UNIT( Woodcutter );

		m_uWoodcutter.SetUnitName("translate2_02_Name_Knight");
		
		INITIALIZE_UNIT( Bear );

		m_uBear.SetIsSingleUnit(true);
		
		INITIALIZE_UNIT( WitchGate );
		m_uWitchGate.CommandBuildingSetGateMode(modeGateClosed);
		
		INITIALIZE_UNIT( Boss1  );
		INITIALIZE_UNIT( Boss2A );
		INITIALIZE_UNIT( Boss2B );
		INITIALIZE_UNIT( Boss3  );

		m_uBoss2A.SetExperienceLevel(7);
		m_uBoss2B.SetExperienceLevel(7);
		m_uBoss3.SetExperienceLevel(7);
		m_uBoss1.SetExperienceLevel(7);

		m_uBoss1.CommandSetMovementMode(modeHoldPos);
		m_uBoss2A.CommandSetMovementMode(modeHoldPos);
		m_uBoss2B.CommandSetMovementMode(modeHoldPos);
		m_uBoss3.CommandSetMovementMode(modeHoldPos);

		SetRealImmortal(m_uShepherd, true);
		SetRealImmortal(m_uWitch, true);
		SetRealImmortal(m_uWoodcutter, true);
		SetRealImmortal(m_uBear, true);

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
		REGISTER_GOAL( MirkoMustSurvive );
		REGISTER_GOAL( FindKidnappers   );
		REGISTER_GOAL( FindSepherd      );
		REGISTER_GOAL( FindUnicorn      );
		REGISTER_GOAL( FindMushrooms    );
		REGISTER_GOAL( FollowUnicorn    );
		
		EnableGoal(goalMirkoMustSurvive, true);
		
		return true;
		}
	
	int m_nHeroGx, m_nHeroGy;
	
	function int UpdateCamera()
		{
		int nHeroNewGx, nHeroNewGy;
		
		nHeroNewGx = m_uHero.GetLocationX();
		nHeroNewGy = m_uHero.GetLocationY();
		
		if ( Distance(m_nHeroGx, m_nHeroGy, nHeroNewGx, nHeroNewGy) > 10 )
			{
			PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
			}
		
		m_nHeroGx = nHeroNewGx;
		m_nHeroGy = nHeroNewGy;
		
		return true;
		}
	
	state Initialize
		{
		unitex uTmp;
		
		TurnOffTier5Items();
		
		CallCamera();
		
		InitializePlayers();
		InitializeUnits();
		
		SetAllBridgesImmortal(true);
		
		RegisterGoals();
		
		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		EnableAssistant(0xffff, false);
		EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		CreateArtefactAtMarker("SWITCH_1_1", markerBearSwitch, maskGateOpenSwitch|markerBearGate);
		CreateArtefactAtMarker("SWITCH_1_1", 23, maskGateOpenSwitch|22);
		
		CreateArtefactAtMarker("SWITCH_1_1", 18, maskGateOpenSwitch|17);
		CreateArtefactAtMarker("SWITCH_1_1", 19, maskCreateMonster|21);
		CreateArtefactAtMarker("SWITCH_1_1", 20, maskCreateMonster|21);

		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 53, maskGateCloseSwitch|51);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 59, maskGateCloseSwitch|56);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 61, maskGateCloseSwitch|60);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 64, maskGateCloseSwitch|63);
		CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 55, maskGateCloseSwitch|54);

		CreateArtefacts("ARTIFACT_INVISIBLE", 65, 76, idFireTrap, false);
		
		CLOSE_GATE( markerBearGate );
		CLOSE_GATE( 22 );
		CLOSE_GATE( 17 );
		
		CLOSE_GATE( 24 );
		CLOSE_GATE( 25 );

		CLOSE_GATE( 52 );

		OPEN_GATE( 51 );
		OPEN_GATE( 54 );
		CLOSE_GATE( 56 );
		OPEN_GATE( 60 );
		CLOSE_GATE( 63 );
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		
		// SetupTeleportBetweenMarkers(43, 44);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+30,GetTop()+26,20,200,45,0);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		SetCutsceneText("translate2_02_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+34,GetTop()+30,19,32,45,0,300,1);
		
		CommandMoveUnitToMarker(m_uHero, 1);
		CommandMovePlatoonToMarker(m_platCrew, 48);
		
		return Start, 300;
		}
	/*
	state Start1
		{
		m_pPlayer.LookAt(GetLeft()+33,GetTop()+29,21,21,207,0);
		m_pPlayer.DelayedLookAt(GetLeft()+33,GetTop()+29,21,21,207,0,200,1);
		
		return Start2, 200;
		}
	state Start2
		{
		m_pPlayer.LookAt(GetLeft()+34,GetTop()+30,21,21,29,0);
		m_pPlayer.DelayedLookAt(GetLeft()+34,GetTop()+30,18,25,31,0,200,1);
		
		return Start, 200;
		}
	*/
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogStart )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Start
			#define DIALOG_LENGHT  1
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogLastKnight )
			{
			#define UNIT_NAME_FROM Woodcutter
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    LastKnight
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogBadBoys )
			{
			#define UNIT_NAME_FROM Footman
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BadBoys
			#define DIALOG_LENGHT  4
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogOldWich )
			{
			#define UNIT_NAME_FROM Witch
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    OldWich
			#define DIALOG_LENGHT  7
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogFreeShepherd )
			{
			#define UNIT_NAME_FROM Shepherd
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FreeShepherd
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogUnicorn )
			{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Bear
			#define DIALOG_NAME    Unicorn
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
		unitex uTmp;
		
		RestoreTalkInterface(m_pPlayer, m_uHero);
		
		if ( m_nDialogToPlay == dialogStart )
			{
			EnableGoal(goalFindKidnappers, true);
			}
		else if ( m_nDialogToPlay == dialogFreeShepherd )
			{
			SetGoalState(goalFindSepherd, goalAchieved);
			
			OPEN_GATE( 24 );
			
			AddWorldMapSignAtMarker(30, 0, -1);
			AddWorldMapSignAtMarker(25, 0, -1);
			
			m_uHeroCarrySmoke.RemoveUnit();
			
			CommandMoveUnitToMarker(m_uShepherd, 25);
			}
		else if ( m_nDialogToPlay == dialogBadBoys )
			{
			SetEnemies(m_pPlayer, m_pBadBoys);
			}
		else if ( m_nDialogToPlay == dialogLastKnight )
			{
			EnableGoal(goalFindSepherd, true);
			EnableGoal(goalFindUnicorn, true);
			
			m_uWoodcutter.ChangePlayer( m_pPlayer );
			SetRealImmortal(m_uWoodcutter, false);
			}
		else if ( m_nDialogToPlay == dialogOldWich )
			{
			EnableGoal(goalFindMushrooms, true);

			CreateObjectAtUnit(m_uHero, "CAST_TELEPORT");
			
			m_uHero.SetImmediatePosition(GetPointX(45), GetPointY(45), GetPointZ(45), m_uHero.GetAlphaAngle(), true);
			
			CreateObjectAtUnit(m_uHero, "HIT_TELEPORT");
			
			// PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
			}
		else if ( m_nDialogToPlay == dialogUnicorn )
			{
			SetGoalState(goalFindUnicorn, goalAchieved);
			EnableGoal(goalFollowUnicorn, true);
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
		RESTORE_STATE(FindWoodcutter)
		RESTORE_STATE(Working)
		RESTORE_STATE(MissionComplete)
		RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
		}
	
	state Start
		{
		SetLowConsoleText("");
		
		SET_DIALOG(Start, FindWoodcutter);
		
		return StartPlayDialog, 0;
		}
	
	state FindWoodcutter
		{
		START_TALK( Woodcutter );
		
		AddWorldMapSignAtMarker(markerWoodcutter, 0, -1);
		
		m_nForWitch = 3;
		
		return Working;
		}
	
	state Working
		{
		unitex uTmp;
		
		UpdateCamera();
		
		if ( IsUnitNearUnit(m_uHero, m_uWoodcutter, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uWoodcutterTalkSmoke )
				{
				STOP_TALK( Woodcutter );
				
				START_TALK( Footman );
				START_TALK( Witch );
				
				RemoveWorldMapSignAtMarker(markerWoodcutter);
				
				AddWorldMapSignAtMarker(markerWitch, 0, -1);
				
				SET_DIALOG(LastKnight, Working);
				
				return StartPlayDialog, 0;
				}
			}
		else if ( IsUnitNearUnit(m_uHero, m_uWitch, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uWitchTalkSmoke )
				{
				STOP_TALK( Witch );
				
				if ( m_nForWitch == 0 )
					{
					// przeniesione do eventa
					}
				else
					{
					SET_DIALOG(OldWich, Working);
					
					RemoveWorldMapSignAtMarker(markerWitch);
					
					CreateArtefactAtMarker("MUSHROOM_1", markerForWitchFirst+0, idForWitch);
					CreateArtefactAtMarker("MUSHROOM_2", markerForWitchFirst+1, idForWitch);
					CreateArtefactAtMarker("MUSHROOM_3", markerForWitchFirst+2, idForWitch);
					
					return StartPlayDialog, 0;
					}
				}
			}
		else if ( IsUnitNearUnit(m_uHero, m_uFootman, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uFootmanTalkSmoke )
				{
				STOP_TALK( Footman );
				
				m_uFootman.CommandSetMovementMode(modeMove);
				
				SET_DIALOG(BadBoys, Working);
				
				return StartPlayDialog, 0;
				}
			}
		else if ( IsUnitNearUnit(m_uHero, m_uBear, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uBearTalkSmoke )
				{
				STOP_TALK( Bear );
				
				m_nBearDest = markerBearMoveFirst;
				
				RemoveWorldMapSignAtMarker(30);
				
				SET_DIALOG(Unicorn, MissionComplete);
				
				// CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
				
				SetRealImmortal(m_uBear, false);

				return StartPlayDialog, 0;
				}
			}
		
		if ( m_uShepherd.GetIFF() != m_pPlayer.GetIFF() )
			{
			if ( IsUnitNearMarker(m_uShepherd, 25, rangeNear) && IsPlayerUnitNearMarker(25, rangeNear, m_pPlayer.GetIFF()) )
				{
				OPEN_GATE( 25 );
				
				RemoveWorldMapSignAtMarker(25);
				
				m_uShepherd.ChangePlayer(m_pPlayer);
				SetRealImmortal(m_uShepherd, false);
				}
			
			m_uShepherd.RegenerateHP();
			}
		
		return Working;
		}
	
	state MissionComplete
		{
		int i;
		
		if ( ! IsUnitNearMarker(m_uBear, m_nBearDest, rangeNear) )
			{
			CommandMoveUnitToMarker(m_uBear, m_nBearDest);
			}
		
		AddWorldMapSignAtUnit(m_uBear, 0, 50);
		
		if ( IsUnitNearMarker(m_uBear, m_nBearDest, 9) && IsUnitNearMarker(m_uHero, m_nBearDest, 9) )
			{
			if ( m_nBearDest < markerBearMoveLast )
				{
				++m_nBearDest;
				}
			else
				{
				if ( GetGoalState(goalFollowUnicorn) != goalAchieved )
					{
					SetGoalState(goalFollowUnicorn, goalAchieved);
					
					m_uBear.ChangePlayer(m_pPlayer);
					
					m_bCheckHero = false;
					
					m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
					m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
					m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
					
					EndMission(true);
					}
				}
			}
		
		for ( i=markerBearGateFirst; i<=markerBearGateLast; ++i )
			{
			if ( IsUnitNearMarker(m_uBear, i, rangeNear) )
				{
				OPEN_GATE( i );
				}
			}
		return MissionComplete, 50;
		}
	
	state MissionFail
		{
		EndMission( false );
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

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
		{
		unitex uTmp;
		int nMarker;

		if ( nArtefactNum == idFireTrap )
			{
			CreateObjectAtUnit(uUnitOnArtefact, "FIRETRAP1");
			return false;
			}
		
		if ( pPlayerOnArtefact != m_pPlayer )
			{
			return false;
			}
		
		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
			{
			m_bCheckHero = false;
			
			SAVE_PLAYER_UNITS();
			
			EndMission(true);
			}
		
		if ( nArtefactNum == idForWitch )
			{
			--m_nForWitch;
			
			if ( !m_uBoss2A.IsLive() && !m_uBoss2B.IsLive() && m_nForWitch < 3 ) OPEN_GATE( 56 );
			if ( !m_uBoss3.IsLive()                         && m_nForWitch < 2 ) OPEN_GATE( 63 );
			
			if ( m_nForWitch == 2 )
				{
				m_uHeroCarrySmoke = CreateSmokeObject(m_uHero, "RPG_Diplomat_carry");
				}
			if ( m_nForWitch == 1 )
				{
				m_uHeroCarrySmoke.RemoveUnit();
				m_uHeroCarrySmoke = CreateSmokeObject(m_uHero, "RPG_Diplomat_carry2");
				}
			if ( m_nForWitch == 0 )
				{
				m_uHeroCarrySmoke.RemoveUnit();
				m_uHeroCarrySmoke = CreateSmokeObject(m_uHero, "RPG_Diplomat_carry3");
				
				CreateObjectAtUnit(m_uHero, "CAST_TELEPORT");
				
				m_uHero.SetImmediatePosition(GetPointX(46), GetPointY(46), GetPointZ(46), m_uHero.GetAlphaAngle(), true);
				
				CreateObjectAtUnit(m_uHero, "HIT_TELEPORT");
				
				PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
				
				SetGoalState(goalFindMushrooms, goalAchieved);
				
				m_uWitchGate.CommandBuildingSetGateMode(modeGateOpened);
				
				SetAlly(m_pPlayer, m_pFriend);
				
				CommandMoveUnitToUnit(m_uShepherd, m_uHero);
				
				SET_DIALOG(FreeShepherd, Working);
				
				state StartPlayDialog;
				}
			
			return true;
			}
		
		if ( nArtefactNum & maskGateOpenSwitch )
			{
			nMarker = nArtefactNum & ~maskGateOpenSwitch;
			
			if ( nMarker == markerBearGate )
				{
				if ( m_pBadBoys.GetNumberOfUnits() == 0 )
					{
					m_uBear.ChangePlayer( m_pFriend );
					
					START_TALK( Bear );
					}
				else
					{
					return false;
					}
				}
			
			uTmp = GetUnitAtMarker( nMarker );
			
			uTmp.CommandBuildingSetGateMode(modeGateOpened);
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			if ( nMarker == 17 )
				{
				EnableInterface(false);
				EnableCameraMovement(false);
				
				m_nShowGateMarker = 17;
				m_uShowGateUnit = uUnitOnArtefact;
				
				PlayerLookAtMarker(m_pPlayer, m_nShowGateMarker, -1, -1, -1);
				ShowAreaAtMarker(m_pPlayer, m_nShowGateMarker, 10);
				
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

			if ( nMarker == 51 )
				{
					m_uBoss1.CommandSetMovementMode(modeMove);
					m_uBoss1.CommandAttack(m_uHero);
				}
			else if ( nMarker == 54 )
				{
					m_uBoss2A.CommandSetMovementMode(modeMove);
					m_uBoss2A.CommandAttack(m_uHero);
					m_uBoss2B.CommandSetMovementMode(modeMove);
					m_uBoss2B.CommandAttack(m_uHero);
				}
			else if ( nMarker == 60 )
				{
					m_uBoss3.CommandSetMovementMode(modeMove);
					m_uBoss3.CommandAttack(m_uHero);
				}
			
			return true;
			}
		
		if ( nArtefactNum & maskCreateMonster )
			{
			nMarker = nArtefactNum & ~maskCreateMonster;
			
			CreateUnitAtMarker(m_pEnemy, nMarker, "MONSTER2");
			
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			
			return true;
			}
		
		return false;
		}
	
	event UnitDestroyed(unitex uUnit)
		{
		unit uTmp;

		if ( uUnit == m_uBoss1 ) OPEN_GATE( 52 );
		if ( uUnit == m_uBoss2A && !m_uBoss2B.IsLive() && m_nForWitch < 3 ) OPEN_GATE( 56 );
		if ( uUnit == m_uBoss2B && !m_uBoss2A.IsLive() && m_nForWitch < 3 ) OPEN_GATE( 56 );
		if ( uUnit == m_uBoss3                         && m_nForWitch < 2 ) OPEN_GATE( 63 );
		
		if ( m_bCheckHero )
			{
			if ( uUnit == m_uHero )
				{
				SetGoalState(goalMirkoMustSurvive, goalFailed);
				
				MissionFailed();
				}
			}
		
		if ( uUnit.GetIFF() == m_pBadBoys.GetIFF() )
			{
			uTmp = uUnit.GetAttacker();
			
			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
				{
				if ( m_uFootmanTalkSmoke )
					{
					STOP_TALK( Footman );
					
					m_uFootman.CommandSetMovementMode(modeMove);
					}
				
				SetEnemies(m_pPlayer, m_pBadBoys);
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
		if ( state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+34,GetTop()+30,19,32,45,0);

			SetUnitAtMarker(m_uHero , 1);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
	
