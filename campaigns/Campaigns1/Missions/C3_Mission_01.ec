#define MISSION_NAME "translate3_01"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_01_Dialog_
#include "Language\Common\timeMission3_01.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_01\\301_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start;
		state StartA;
		state WorkingA;
		state EndOfA;
		state LoadB;
		state StartB;
		state WorkingB;
		state EndOfB;
		state LoadC;
		state StartC;
		state WorkingC;
		state EndOfC;
		state LoadD;
		state StartD;
		state WorkingD;
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
			goalDefendVillage    = 1;
			goalFindVillage      = 2;
			goalHelpSorcerer     = 3;
			goalKillSkeletons    = 4;
			goalGiantsQuestStart = 5;
			goalGiantsQuest      = 6;
			goalKillDragon       = 7;
		// players ->		
			playerNeutral    =  0;
			playerPlayer     =  2;
			
			playerFriend     =  3;
			playerGiants     =  7;
			
			playerDragon     =  5;
			playerSkeletons  =  4;
			playerVillage    =  9;
			playerEnemy      =  8;
			playerAnimals    = 14;
			
			playerPriest     =  2;
		// markers ->	
			markerHeroStartFirst = 0;
			
			markerMag = 1;
			markerMagDst = 2;
			
			markerHeroEndA     =  6;
			markerCrewEndFromA =  7;
			markerCrewEndToA   =  8;
			markerHeroEndB     =  3;
			markerCrewEndFromB =  4;
			markerCrewEndToB   =  5;
			markerHeroEndC     =  9;
			markerCrewEndFromC = 10;
			markerCrewEndToC   = 11;
			
			markerWoodcutterStart = 109;
			
			markerWoodcutter = 12;
			
			markerGiant = 13;
			
			markerCowsDst = 15;
			
			markerDragon = 120;
		// dialogs ->
			dialogStart                  =  1;
			dialogVillage                =  2;
			dialogFreeSorcerer           =  3;
			dialogGoForArmour            =  4;
			dialogBackWithArmor          =  5;
			dialogAfterUndeadsKill       =  6;
			dialogAfterBackFromCowIsland =  7;
			dialogGiantAttack            =  8;
			dialogGiantKing              =  9;
			dialogFinishGiantQuest       = 10;
			dialogShieldQuest            = 11;
			dialogBackFromMaze           = 12;
			dialogMissionFail            = 13;
		// params ->		
			rangeTalk = 2;
			rangeNear = 3;
		// ids ->
			idCowAttack = 333;
			
			idMine   = 999;
			idMagDst = 998;
			
			maskGateOpenSwitch = 2048;
		}
	
	// players ->
		player m_pNeutral;
		player m_pPlayer;
		
		player m_pFriend;
		player m_pGiants;
		
		player m_pDragon;
		player m_pSkeletons;
		player m_pVillage;
		player m_pEnemy;
		player m_pAnimals;
	// units ->	
		unitex m_uHero;
		
		unitex m_uWoodcutterStart;
		unitex m_uWoodcutter;
		unitex m_uMag;
		unitex m_uGiant;
		unitex m_uBadGiant;
		
		unitex m_uWoodcutterTalkSmoke;
		unitex m_uMagTalkSmoke;
		unitex m_uGiantTalkSmoke;
		
		unitex m_auSafeCows[];
		
		unitex m_uDragon;
	// vars ->	
		int m_bCheckHero;
		int m_nGiantCows;
		int m_bUnsafeCows;
		
		int markerCrewEndFrom;
		int markerCrewEndTo;
		int markerHeroEnd;
		int markerCrewStart;
		int markerHeroStart;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Neutral   );
		INITIALIZE_PLAYER( Player    );
		
		INITIALIZE_PLAYER( Friend    );
		INITIALIZE_PLAYER( Giants    );
		
		INITIALIZE_PLAYER( Dragon    );
		INITIALIZE_PLAYER( Skeletons );
		INITIALIZE_PLAYER( Village   );
		INITIALIZE_PLAYER( Enemy     );
		INITIALIZE_PLAYER( Animals   );
		
		m_pNeutral.EnableAI(false);
		m_pFriend.EnableAI(false);
		m_pGiants.EnableAI(false);
		m_pDragon.EnableAI(false);
		m_pSkeletons.EnableAI(false);
		m_pEnemy.EnableAI(false);
		
		LoadAIScript(m_pVillage);
		m_pVillage.SetStartAttacksTime(20*30);
		m_pVillage.EnableAI(false);
		
		m_pVillage.SetMaxMoney(400);
		m_pVillage.SetMoney(400);
				
		m_pPlayer.SetMaxCountLimitForObject("COWSHED",4);
		m_pPlayer.SetMaxCountLimitForObject("COURT",1);
		
		m_pPlayer.SetMaxMoney(100);
		m_pPlayer.SetMoney(0);
		
		m_pFriend.SetSideColor(m_pPlayer.GetSideColor());
		
		INITIALIZE_PLAYER( Priest  );
		
		SetNeutrals(m_pPlayer, m_pFriend);
		SetNeutrals(m_pPlayer, m_pGiants);
		
		SetNeutrals(m_pNeutral, m_pPlayer);
		SetNeutrals(m_pNeutral, m_pFriend);
		SetNeutrals(m_pNeutral, m_pGiants);
		SetNeutrals(m_pNeutral, m_pSkeletons);
		SetNeutrals(m_pNeutral, m_pVillage);
		SetNeutrals(m_pNeutral, m_pEnemy);
		SetNeutrals(m_pNeutral, m_pAnimals);
		
		SetNeutrals(m_pFriend, m_pGiants);
		SetNeutrals(m_pFriend, m_pSkeletons);
		SetNeutrals(m_pFriend, m_pVillage);
		SetNeutrals(m_pFriend, m_pEnemy);
		SetNeutrals(m_pFriend, m_pAnimals);

		SetNeutrals(m_pGiants, m_pSkeletons);
		SetNeutrals(m_pGiants, m_pVillage);
		SetNeutrals(m_pGiants, m_pEnemy);
		SetNeutrals(m_pGiants, m_pAnimals);

		SetNeutrals(m_pSkeletons, m_pVillage);
		SetNeutrals(m_pSkeletons, m_pEnemy);
		SetNeutrals(m_pSkeletons, m_pAnimals);

		SetNeutrals(m_pVillage, m_pEnemy);
		SetNeutrals(m_pVillage, m_pAnimals);

		SetNeutrals(m_pEnemy, m_pAnimals);

		SetEnemies(m_pPlayer, m_pSkeletons);
		SetEnemies(m_pPlayer, m_pVillage);
		SetEnemies(m_pPlayer, m_pEnemy);
		SetEnemies(m_pPlayer, m_pAnimals);
		SetEnemies(m_pPlayer, m_pDragon);

		return true;
		}
	function int InitializeUnits()
		{
		markerHeroStart = markerHeroStartFirst;
		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
		
		INITIALIZE_HERO();
		m_bCheckHero = true;
		
		INITIALIZE_UNIT( Dragon          );
		INITIALIZE_UNIT( Mag             );
		INITIALIZE_UNIT( Woodcutter      );
		INITIALIZE_UNIT( WoodcutterStart );
		
		SetRealImmortal(m_uDragon, true);
		m_uDragon.CommandSetMovementMode(modeHoldPos);
		
		SetRealImmortal(m_uMag, true);
		SetRealImmortal(m_uWoodcutter, true);

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
		
		PlayerLookAtUnit(m_pPlayer, m_uPriest, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;
		
		state StartPlayDialog;
		
		return true;
		}
	function int RegisterGoals()
		{
		REGISTER_GOAL( MirkoMustSurvive );
		REGISTER_GOAL( DefendVillage    );
		REGISTER_GOAL( FindVillage      );
		REGISTER_GOAL( HelpSorcerer     );
		REGISTER_GOAL( KillSkeletons    );
		REGISTER_GOAL( GiantsQuestStart );
		REGISTER_GOAL( GiantsQuest      );
		REGISTER_GOAL( KillDragon       );
		
		EnableGoal(goalMirkoMustSurvive, true);
		
		return true;
		}
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogStart )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   WoodcutterStart
			#define DIALOG_NAME    Start
			#define DIALOG_LENGHT  7
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogVillage )
			{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Woodcutter
			#define DIALOG_NAME    Village
			#define DIALOG_LENGHT  7
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogFreeSorcerer )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FreeSorcerer
			#define DIALOG_LENGHT  5
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogGoForArmour )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    GoForArmour
			#define DIALOG_LENGHT  3
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogBackWithArmor )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BackWithArmor
			#define DIALOG_LENGHT  3
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogAfterUndeadsKill )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    AfterUndeadsKill
			#define DIALOG_LENGHT  5
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogAfterBackFromCowIsland )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    AfterBackFromCowIsland
			#define DIALOG_LENGHT  7
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
			}
		else if ( m_nDialogToPlay == dialogGiantAttack )
			{
			#define UNIT_NAME_FROM BadGiant
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    GiantAttack
			#define DIALOG_LENGHT  3
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogGiantKing )
			{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    GiantKing
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogFinishGiantQuest )
			{
			#define UNIT_NAME_FROM Giant
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FinishGiantQuest
			#define DIALOG_LENGHT  2
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogShieldQuest )
			{
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ShieldQuest
			#define DIALOG_LENGHT  2
			
			#include "..\..\TalkBis.ech"
			}
		else if ( m_nDialogToPlay == dialogBackFromMaze )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
			
			#define UNIT_NAME_FROM Mag
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BackFromMaze
			#define DIALOG_LENGHT  4
			
			#include "..\..\TalkBis.ech"
			
			return PlayDialog, 1;
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
		
		if ( m_nDialogToPlay == dialogStart )
			{
			EnableGoal(goalFindVillage, true);
			
			CommandMoveUnitToMarker(m_uWoodcutterStart, 110);
			CreateArtefactAtMarker("ARTIFACT_INVISIBLE", 110, idMine);
			}
		else if ( m_nDialogToPlay == dialogVillage )
			{
			SetGoalState(goalFindVillage, goalAchieved);
			EnableGoal(goalHelpSorcerer, true);
			EnableGoal(goalDefendVillage, true);
			
			m_pFriend.GiveAllBuildingsTo(m_pPlayer);
			m_pFriend.GiveAllUnitsTo(m_pPlayer);
			
			m_pPlayer.SetMoney(100);
			
			m_pVillage.EnableAI(true);

			SetRealImmortal(m_uWoodcutter, false);

			// AddWorldMapSignAtMarker(71, 1, -1);
			// AddWorldMapSignAtMarker(72, 1, -1);
			AddWorldMapSignAtMarker(markerMag, 0, -1);
			}
		else if ( m_nDialogToPlay == dialogFreeSorcerer )
			{
			SetGoalState(goalHelpSorcerer, goalAchieved);
			
			SetupTeleportBetweenMarkers(155, 156);
			
			m_uMag.BeginQuickRecord();
			m_uMag.CommandEnter(GetUnitAtMarker(155));
			CommandMoveUnitToMarker(m_uMag, markerMagDst);
			m_uMag.EndQuickRecord();

			CreateArtefactAtMarker("ARTIFACT_INVISIBLE", markerMagDst, idMagDst);
			
			// RemoveWorldMapSignAtMarker(71);
			// RemoveWorldMapSignAtMarker(72);
			RemoveWorldMapSignAtMarker(markerMag);

			SetConsoleText("translate3_01_Console_FollowTheMage");
			}
		else if ( m_nDialogToPlay == dialogGoForArmour )
			{
			PlayTrack("Music\\victory.tws");
			
			markerCrewEndFrom = markerCrewEndFromA;
			markerCrewEndTo = markerCrewEndToA;
			markerHeroEnd = markerHeroEndA;
			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
			
			markerHeroStart = 153;
			markerCrewStart = 154;
			
			RemoveWorldMapSignAtMarker(markerMagDst);

			SetConsoleText("translate3_01_Console_WalkThroughTheCaves");
			}
		else if ( m_nDialogToPlay == dialogBackWithArmor )
			{
			EnableGoal(goalKillSkeletons, true);
			
			ZoomInMap(0);
			
			ShowPanel(true, 10);
			
			AddWorldMapSignAtMarker(53, 1, -1);
			}
		else if ( m_nDialogToPlay == dialogAfterUndeadsKill )
			{
			PlayTrack("Music\\victory.tws");
			
			markerCrewEndFrom = markerCrewEndFromB;
			markerCrewEndTo = markerCrewEndToB;
			markerHeroEnd = markerHeroEndB;
			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
			
			markerHeroStart = 153;
			markerCrewStart = 154;
			}
		else if ( m_nDialogToPlay == dialogAfterBackFromCowIsland )
			{
			EnableGoal(goalGiantsQuestStart, true);

			ShowPanel(true, 10);
			
			AddWorldMapSignAtMarker(15, 0, -1);
			}
		else if ( m_nDialogToPlay == dialogGiantAttack )
			{
			}
		else if ( m_nDialogToPlay == dialogGiantKing )
			{
			SetGoalState(goalGiantsQuestStart, goalAchieved);
			EnableGoal(goalGiantsQuest, true);
			
			m_bCheckHero = false;
			m_uHero.ChangePlayer(m_pGiants);
			m_uHero.CommandSetMovementMode(modeHoldPos);
			SetRealImmortal(m_uHero, true);
			SetAlly(m_pPlayer, m_pGiants);
			m_bCheckHero = true;
			}
		else if ( m_nDialogToPlay == dialogFinishGiantQuest )
			{
			RemoveWorldMapSignAtMarker(15);
			}
		else if ( m_nDialogToPlay == dialogShieldQuest )
			{
			PlayTrack("Music\\victory.tws");
			
			markerCrewEndFrom = markerCrewEndFromC;
			markerCrewEndTo = markerCrewEndToC;
			markerHeroEnd = markerHeroEndC;
			CreateMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
			
			markerHeroStart = 153;
			markerCrewStart = 154;
			}
		else if ( m_nDialogToPlay == dialogBackFromMaze )
			{
			EnableGoal(goalKillDragon, true);
			
			ShowPanel(true, 10);
			
			AddWorldMapSignAtMarker(markerDragon, 1, -1);
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
		
		if ( m_nDialogToPlay == dialogGiantAttack )
			{
			m_nDialogToPlay = dialogGiantKing;
			
			return StartPlayDialog, 0;
			}
		
		SAFE_REMOVE_PRIEST();
		
		BEGIN_RESTORE_STATE_BLOCK()
			RESTORE_STATE(StartA)
			RESTORE_STATE(WorkingA)
			RESTORE_STATE(EndOfA)
			RESTORE_STATE(StartB)
			RESTORE_STATE(WorkingB)
			RESTORE_STATE(EndOfB)
			RESTORE_STATE(StartC)
			RESTORE_STATE(WorkingC)
			RESTORE_STATE(EndOfC)
			RESTORE_STATE(StartD)
			RESTORE_STATE(WorkingD)
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
		
		RegisterGoals();
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		// EnableAssistant(assistSelectBuildingPlaceHarvestFactory|assistSelectBuildingPlaceNearRoad|assistSelectBuildingPlaceTower|assistSelectBuildingPlaceGate|assistSelectBuildingPlaceBridgeGate|assistLazyHarvester|assistAttackedHoldPosition, true);
		
		CreateArtefactAtMarker("SWITCH_1_1", 100, maskGateOpenSwitch|99);
		
		ZoomInMap(1);
		
		SetTimer(2, 100);
		SetTimer(3, 30*30);
		
		OPEN_GATE( 111 );
		OPEN_GATE( 112 );
		OPEN_GATE( 113 );
		
		OnDifficultyLevelClearMarkers( difficultyEasy  , 128, 152, 0 );
		OnDifficultyLevelClearMarkers( difficultyMedium, 133, 140, 0 );
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		m_pPlayer.LookAt(GetLeft()+224,GetTop()+100,20,102,24,0);
		
		m_auSafeCows.Create(0);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		return Start0, 1;
		}
	state Start0
		{
		CommandMoveUnitToUnit(m_uWoodcutterStart, m_uHero);
		
		SetCutsceneText("translate3_01_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+225,GetTop()+96,16,43,35,0,220,0);
		
		return Start, 220;
		}
	state Start
		{
		SetLowConsoleText("");
		
		return StartA, 0;
		}
	state StartA
		{
		m_pPlayer.EnableResearchUpdate("SPEAR4"  , false); // 2
		m_pPlayer.EnableResearchUpdate("BOW4"    , false); // 2
		m_pPlayer.EnableResearchUpdate("SWORD2A" , false); // 2
		m_pPlayer.EnableResearchUpdate("AXE4"    , false); // 2
		m_pPlayer.EnableResearchUpdate("SHIELD2" , false); // 2
		m_pPlayer.EnableResearchUpdate("ARMOUR3" , false); // 2
		m_pPlayer.EnableResearchUpdate("HELMET2A", false); // 2

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

		START_TALK( Woodcutter );
		
		SET_DIALOG(Start, WorkingA);
		return StartPlayDialog, 0;
		}
	state WorkingA
		{
		if ( IsUnitNearUnit(m_uHero, m_uWoodcutter, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uWoodcutterTalkSmoke )
				{
				STOP_TALK( Woodcutter );
				
				START_TALK( Mag );
				
				SET_DIALOG(Village, WorkingA);
				return StartPlayDialog, 0;
				}
			}
		else if ( IsUnitNearUnit(m_uHero, m_uMag, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uMagTalkSmoke )
				{
				STOP_TALK( Mag );
				
				SET_DIALOG(FreeSorcerer, EndOfA);
				return StartPlayDialog, 0;
				}
			}
		
		return WorkingA;
		}
	state EndOfA
		{
		if ( IsUnitNearUnit(m_uHero, m_uMag, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uMagTalkSmoke )
				{
				STOP_TALK( Mag );
				
				SetConsoleText("");

				SET_DIALOG(GoForArmour, EndOfA);
				return StartPlayDialog, 0;
				}
			}
		
		if ( GetUnitAtMarker(markerMagDst) != m_uMag && !m_uMag.IsMoving() )
			{
			CommandMoveUnitToMarker(m_uMag, markerMagDst);
			}
		
		return EndOfA;
		}
	state LoadB
		{
		SetConsoleText("");

		EnableNextMission(22,true);

		return StartB, 0;
		}
	state StartB
		{
		platoon platTmp;

		SetTerrain(3);

		InitializePlayers();
		
		CallCamera();
		
		RESTORE_PLAYER_UNITS();
		
		INITIALIZE_HERO();
		m_bCheckHero = true;

		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		CreateExpUnits(m_pSkeletons, 53, 57, "MONSTER4"       , 5);
		CreateExpUnits(m_pSkeletons, 58, 62, "SKELETON_HUNTER", 5);
		CreateExpUnits(m_pSkeletons, 63, 70, "SKELETON4"      , 5);
		
		CreateArtefactAtMarker("ART_HELMET4A", 114, 0);
		CreateArtefactAtMarker("ART_BOW6", 115, 0);
		CreateArtefactAtMarker("ART_SHIELD4A", 116, 0);
		CreateArtefactAtMarker("ART_AXE5", 122, 0);
		
		platTmp = CreateExpUnitsAtMarker(m_pEnemy, 73, "MONSTER4" , 5, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 73, "WHITEBEAR", 5, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "MONSTER4" , 5, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "WHITEBEAR", 5, 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, markerWoodcutter);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterface(false, 0);
		ShowPanel(false, 0);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		PlayerLookAtUnit(m_pPlayer, m_uMag, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_pPlayer.EnableResearchUpdate("SPEAR4"  , true); // 2
		m_pPlayer.EnableResearchUpdate("BOW4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SWORD2A" , true); // 2
		m_pPlayer.EnableResearchUpdate("AXE4"    , true); // 2
		m_pPlayer.EnableResearchUpdate("SHIELD2" , true); // 2
		m_pPlayer.EnableResearchUpdate("ARMOUR3" , true); // 2
		m_pPlayer.EnableResearchUpdate("HELMET2A", true); // 2

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

		m_pPlayer.EnableResearchUpdate("SPEAR5"  , false); // 3
		m_pPlayer.EnableResearchUpdate("BOW5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SWORD3"  , false); // 3
		m_pPlayer.EnableResearchUpdate("AXE5"    , false); // 3
		m_pPlayer.EnableResearchUpdate("SHIELD2D", false); // 3
		m_pPlayer.EnableResearchUpdate("ARMOUR3A", false); // 3
		m_pPlayer.EnableResearchUpdate("HELMET3" , false); // 3

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

		SET_DIALOG(BackWithArmor, WorkingB);
		return StartPlayDialog, 30;
		}
	state WorkingB
		{
		if ( m_pSkeletons.GetNumberOfUnits() == 0 )
			{
			SetGoalState(goalKillSkeletons, goalAchieved);
			
			RemoveWorldMapSignAtMarker(53);
			START_TALK( Mag );
			
			SetConsoleText("translate3_01_Console_ReturnToMage");
			AddWorldMapSignAtMarker(markerMagDst, 0, -1);
			
			return EndOfB;
			}
		
		return WorkingB;
		}
	state EndOfB
		{
		if ( IsUnitNearUnit(m_uHero, m_uMag, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uMagTalkSmoke )
				{
				STOP_TALK( Mag );
				
				SetConsoleText("");
				RemoveWorldMapSignAtMarker(markerMagDst);
				
				SET_DIALOG(AfterUndeadsKill, EndOfB);
				return StartPlayDialog, 0;
				}
			}
		
		return EndOfB;
		}
	state LoadC
		{
		EnableNextMission(23,true);

		return StartC, 0;
		}
	state StartC
		{
		platoon platTmp;

		SetTerrain(3);

		InitializePlayers();
		
		CallCamera();
		
		RESTORE_PLAYER_UNITS();
		
		INITIALIZE_HERO();
		m_bCheckHero = true;

		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		ClearMarkers(15, 15, 10);
		
		CreateBuildingAtMarker(m_pGiants, 16, "COWSHED");
		CreateBuildingAtMarker(m_pGiants, 17, "COWSHED");
		CreateBuildingAtMarker(m_pGiants, 18, "COWSHED");
		CreateObjectAtMarker(19, "TG_01");
		CreateObjectAtMarker(21, "TG_01");
		CreateObjectAtMarker(25, "TG_01");
		CreateObjectAtMarker(24, "TG_02");
		CreateObjectAtMarker(26, "TG_02");
		CreateObjectAtMarker(20, "TG_06");
		CreateObjectAtMarker(22, "TG_06");
		CreateObjectAtMarker(23, "TG_06");
		CreateObjectAtMarker(27, "TG_04");
		CreateObjectAtMarker(28, "TG_04");
		CreateObjectAtMarker(29, "TG_05");
		CreateObjectAtMarker(30, "GADGET74");
		CreateObjectAtMarker(31, "GADGET73");
		CreateObjectAtMarker(32, "GADGET7");
		CreateObjectAtMarker(33, "GADGET7");
		CreateObjectAtMarker(34, "GADGET14");
		CreateObjectAtMarker(35, "GADGET14");
		CreateObjectAtMarker(36, "TREE11");
		CreateObjectAtMarker(37, "TREE11");
		CreateObjectAtMarker(38, "TREE11");
		CreateObjectAtMarker(39, "TREE11");
		CreateObjectAtMarker(40, "TREE11");
		CreateObjectAtMarker(41, "GADGET16");
		CreateObjectAtMarker(42, "GADGET16");
		CreateObjectAtMarker(43, "GADGET6");
		CreateObjectAtMarker(44, "GADGET6");
		CreateObjectAtMarker(45, "GADGET8");
		
		m_uGiant = CreateUnitAtMarker(m_pGiants, 13, "GIANTSPECIAL");
		SetRealImmortal(m_uGiant, true);
		
		START_TALK_GIANT( Giant );
		
		CreateUnits(m_pGiants, 46, 52, "GIANT");
		
		m_uBadGiant = GetUnitAtMarker(52);
		SetRealImmortal(m_uBadGiant, true);
		
		CreateArtefactsLine("ARTIFACT_INVISIBLE", 102, 103, idCowAttack);
		// CreateArtefactsLine("ARTIFACT_STARTMISSION", 102, 103, idCowAttack);
		
		m_nGiantCows = 0;
		
		CreateArtefactAtMarker("ART_SHIELD4B", 117, 0);
		CreateArtefactAtMarker("ART_SWORD4", 118, 0);
		CreateArtefactAtMarker("ART_AMULET_REGMAGIC2", 119, 0);
		CreateArtefactAtMarker("ART_AXE6", 121, 0);
		
		platTmp = CreateExpUnitsAtMarker(m_pEnemy, 73, "MONSTER4" , 6, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 73, "WEREWOLF3", 6, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "MONSTER4" , 6, 2);
		CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "WEREWOLF3", 6, 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, markerWoodcutter);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterface(false, 0);
		ShowPanel(false, 0);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		PlayerLookAtUnit(m_pPlayer, m_uMag, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		m_pPlayer.EnableResearchUpdate("SPEAR5"  , true); // 3
		m_pPlayer.EnableResearchUpdate("BOW5"    , true); // 3
		m_pPlayer.EnableResearchUpdate("SWORD3"  , true); // 3
		m_pPlayer.EnableResearchUpdate("AXE5"    , true); // 3
		m_pPlayer.EnableResearchUpdate("SHIELD2D", true); // 3
		m_pPlayer.EnableResearchUpdate("ARMOUR3A", true); // 3
		m_pPlayer.EnableResearchUpdate("HELMET3" , true); // 3

		m_pPlayer.EnableResearchUpdate("AUTOSPELL_PRIEST5"            , true); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_WITCH5"             , true); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_LIGHTING_PRIESTESS5", true); // 3
		m_pPlayer.EnableResearchUpdate("AUTOSPELL_FIREBALL5"          , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_SHIELD4"                , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_CAPTURE4"               , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_STORM4"                 , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_CONVERSION4"            , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_FIRERAIN4"              , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_SEEING4"                , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_TELEPORTATION4"         , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_GHOST4"                 , true); // 3
		m_pPlayer.EnableResearchUpdate("SPELL_WOLF4"                  , true); // 3

		SET_DIALOG(AfterBackFromCowIsland, WorkingC);
		return StartPlayDialog, 30;
		}
	state WorkingC
		{
		int x, y, z;
		unitex uTmp;
		
		if ( IsUnitNearUnit(m_uHero, m_uGiant, 6) && ! m_uHero.IsMoving() )
			{
			if ( m_uGiantTalkSmoke )
				{
				STOP_TALK( Giant );
				
				SET_DIALOG(GiantAttack, WorkingC);
				return StartPlayDialog, 0;
				}
			}
		
		z = GetPointZ(15);
		
		for ( x=GetPointX(15)-5; x<=GetPointX(15)+5; ++x )
			{
			for ( y=GetPointY(15)-5; y<=GetPointY(15)+5; ++y )
				{
				uTmp = GetUnit(x, y, z);
				
				if ( uTmp )
					{
					if ( uTmp.GetIFF() == m_pPlayer.GetIFF() && uTmp.IsHarvester() )
						{
						++m_nGiantCows;
						uTmp.ChangePlayer( m_pGiants );
						}
					}
				}
			}
		
		if ( m_nGiantCows >= 10 )
			{
			SetGoalState(goalGiantsQuest, goalAchieved);
			
			m_bCheckHero = false;
			m_uHero.ChangePlayer(m_pPlayer);
			m_uHero.CommandSetMovementMode(modeMove);
			SetRealImmortal(m_uHero, false);
			SetNeutrals(m_pPlayer, m_pGiants);
			m_bCheckHero = true;
			
			START_TALK_GIANT( Giant );
			
			return EndOfC;
			}
		
		return WorkingC;
		}
	state EndOfC
		{
		if ( IsUnitNearUnit(m_uHero, m_uGiant, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uGiantTalkSmoke )
				{
				STOP_TALK( Giant );
				
				START_TALK( Mag );
				
				SetConsoleText("translate3_01_Console_ReturnToMage");
				AddWorldMapSignAtMarker(markerMagDst, 0, -1);
				
				SET_DIALOG(FinishGiantQuest, EndOfC);
				return StartPlayDialog, 0;
				}
			}
		if ( IsUnitNearUnit(m_uHero, m_uMag, rangeTalk) && ! m_uHero.IsMoving() )
			{
			if ( m_uMagTalkSmoke )
				{
				STOP_TALK( Mag );
				
				SetConsoleText("");
				RemoveWorldMapSignAtMarker(markerMagDst);
				
				SET_DIALOG(ShieldQuest, EndOfC);
				return StartPlayDialog, 0;
				}
			}
		
		return EndOfC;
		}
	state LoadD
		{
		EnableNextMission(25,true);

		return StartD, 0;
		}
	state StartD
		{
		// platoon platTmp;
		
		SetTerrain(3);
		
		InitializePlayers();
		
		CallCamera();
		
		RESTORE_PLAYER_UNITS();
		
		EnableGoal(goalDefendVillage, false);
		
		m_pPlayer.GiveAllBuildingsTo(m_pFriend);
		m_pPlayer.GiveAllUnitsTo(m_pFriend);
		
		INITIALIZE_HERO();
		
		m_uHero.ChangePlayer(m_pPlayer);
		
		// CreateArtefactAtUnit("ART_ARMOUR5", m_uHero, 0);
		// CreateArtefactAtUnit("ART_SHIELD5", m_uHero, 0);
		// CreateArtefactAtUnit("ART_SWORD6" , m_uHero, 0);
		// CreateArtefactAtUnit("ART_HELMET5", m_uHero, 0);
		
		m_bCheckHero = true;
		
		PlayerLookAtUnit(m_pPlayer, m_uHero, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		// platTmp = CreateExpUnitsAtMarker(m_pEnemy, 73, "MONSTER4" , 8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 73, "WEREWOLF3", 8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 73, "WOLF",      8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 73, "BEAR",      8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "MONSTER4" , 8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "WEREWOLF3", 8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "WOLF",      8, 2);
		// CreateExpUnitsAtMarker(platTmp,  m_pEnemy, 74, "BEAR",      8, 2);
		
		CreateArtefacts("ART_HP", 123, 127, 0, false);
		
		// CommandMoveAndDefendPlatoonToMarker(platTmp, markerWoodcutter);
		
		m_uDragon.RemoveUnit();
		
		m_uDragon = CreateUnitAtMarker(m_pDragon, markerDragon, "DRAGON2", 128);
		
		m_uDragon.CommandSetMovementMode(modeHoldPos);
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterface(false, 0);
		ShowPanel(false, 0);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		PlayerLookAtUnit(m_pPlayer, m_uMag, constLookAtHeight, constLookAtAlpha, constLookAtView);
		
		SET_DIALOG(BackFromMaze, WorkingD);
		return StartPlayDialog, 30;
		}
	state WorkingD
		{
		if ( ! m_uDragon.IsLive() )
			{
			return MissionComplete, 150;
			}
		
		return WorkingD;
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
		int nMarker;
		platoon platTmp;
		
		if ( nArtefactNum == idMine && uUnitOnArtefact == m_uWoodcutterStart )
			{
			m_uWoodcutterStart.RemoveUnit();
			
			return true;
			}
		if ( nArtefactNum == idMagDst && uUnitOnArtefact == m_uMag )
			{
			START_TALK( Mag );
			
			AddWorldMapSignAtMarker(markerMagDst, 0, -1);
			
			return true;
			}
		
		if ( nArtefactNum == idCowAttack && uUnitOnArtefact.IsHarvester() )
			{
			m_bUnsafeCows = false;
			
			if ( IsUnitInArray(m_auSafeCows, uUnitOnArtefact) ) return false;
			
			if ( GetCameraDistanceToMarker(101) > GetCameraDistanceToMarker(104) )
				{
				nMarker = 101;
				}
			else
				{
				nMarker = 104;
				}
			if ( GetDifficultyLevel() == difficultyEasy )
				{
				platTmp = CreateExpUnitsAtMarker(m_pAnimals, nMarker, "WEREWOLF", 1, 1);
				}
			else
				{
				platTmp = CreateExpUnitsAtMarker(m_pAnimals, nMarker, "WEREWOLF", 2, 1);
				}
			platTmp.CommandAttack(uUnitOnArtefact);
			
			m_auSafeCows.Add(uUnitOnArtefact);
			
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
			
			RemoveMissionExit(markerHeroEnd, markerCrewEndFrom, markerCrewEndTo);
			
			     if ( state == EndOfA ) { state LoadB; }
			else if ( state == EndOfB ) { state LoadC; }
			else if ( state == EndOfC ) { state LoadD; }
			else                        __ASSERT_FALSE();
			}
		if ( nArtefactNum & maskGateOpenSwitch )
			{
			nMarker = nArtefactNum & ~maskGateOpenSwitch;
			
			// if ( nMarker == 99 && m_pVillage.GetNumberOfBuildings() > 0 )
			//	{
			//	return false;
			//	}
			
			OPEN_GATE( nMarker );
			CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
						
			return true;
			}
		
		return false;
		}
	event Timer2() // update max money
		{
		int iCountBuilding;
		
		iCountBuilding = m_pPlayer.GetNumberOfBuildings(buildingHarvestFactory);
		
		if(iCountBuilding<2) m_pPlayer.SetMaxMoney(100);
		if(iCountBuilding==2) m_pPlayer.SetMaxMoney(200);
		if(iCountBuilding==3) m_pPlayer.SetMaxMoney(300);
		if(iCountBuilding>=4) m_pPlayer.SetMaxMoney(400);

		if ( state != WorkingD )
			{
			m_uDragon.RegenerateHP();
			}
		}
	event Timer3() // unsafe all cows
		{
		if ( m_bUnsafeCows ) m_auSafeCows.RemoveAll();
		
		m_bUnsafeCows = true;
		}
	event UnitDestroyed(unitex uUnit)
		{
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
		if ( IsGoalEnabled(goalDefendVillage) )
			{
			if ( uBuilding.GetIFF() == m_pPlayer.GetIFF() )
				{
				if ( m_pPlayer.GetNumberOfBuildings() == 0 )
					{
					CreatePriestNearUnit(m_pPriest, uBuilding);
					
					SetGoalState(goalDefendVillage, goalFailed);
					MissionFailed();
					}
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
		
		SetConsoleText("");
		
			     if ( state == WorkingA || state == EndOfA ) { state LoadB;           }
			else if ( state == WorkingB || state == EndOfB ) { state LoadC;           }
			else if ( state == WorkingC || state == EndOfC ) { state LoadD;           }
			else                                             { state MissionComplete; }
		}
    event EscapeCutscene()
    {
		if ( state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+225,GetTop()+96,16,43,35,0);

			SetUnitAtMarker(m_uWoodcutterStart, markerHeroStart, 0, 1);

			SetStateDelay(0);
			state Start;
		}
	}

	event Timer7()
	{
		StartWind();
	}
}
