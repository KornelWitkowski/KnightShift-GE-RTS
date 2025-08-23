#define MISSION_NAME "translate3_04"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_04_Dialog_
#include "Language\Common\timeMission3_04.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_04\\304_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start1;
	state Start;
	state CreateCrew;
	state FindMage;
	state TeleportHero;
	state TeleportHero2;
	state KillAllMonsters;
	state CompleteMission;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalMirkoMustSurvive = 0;
		goalGainSword		= 1;
		goalRemoveTheCurse	= 2;
		goalKillAllMonsters = 4;

		markerHeroStart = 0;
		markerHeroEnd   = 70;
		markerHeroGoTo  = 69;
		
		markerCrew1 = 1;
		markerCrew2	= 2;

		markerCow	= 3;
		markerCowFirst	= 4;
		markerCowLast	= 19;

		markerSword	= 61;

		markerMage	= 65;
		markerTeleportDest	= 67;
		markerMinotaur		= 68;

		constStartLookAtHeight = 15;

		rangeShowArea = 8;
		
		dialogStart = 1;
		dialogMage	= 2;
		dialogEND	= 3;
		dialogMissionFail = 4;

		idSword = 1024;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;
	
	unitex m_uHero;
	unitex m_uCow;
	unitex m_uMage;
	unitex m_uUnitOnSwitch;
	unitex m_uCrew1;
	unitex m_uCrew2;
	unitex m_auCows[];
	unitex m_auMinotaurs[];

	int m_bCheckHero;

	int m_nCameraX;
	int m_nCameraY;
	int m_nCameraZ;
	int m_nCameraZLayer;
	int m_nCameraView;

	int m_nShowGateCount;
	int m_nMarkerToShowArea; //ktora brame pokazac
	int m_bTeleportedHero;
	int m_bChangedCows;

	
//------ FUNCTIONS -----------------------------------------------------------

	function int RegisterGoals()
	{
		RegisterGoal(goalMirkoMustSurvive, "translate3_04_Goal_MirkoMustSurvive");
		RegisterGoal(goalGainSword, "translate3_04_Goal_GainSword");
		RegisterGoal(goalRemoveTheCurse, "translate3_04_Goal_RemoveTheCurse");
		RegisterGoal(goalKillAllMonsters, "translate3_04_Goal_KillAllMonsters");

		EnableGoal(goalMirkoMustSurvive, true);

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
		m_pPlayer	= GetPlayer(2);
		m_pPriest	= GetPlayer(2);

		m_pNeutral	= GetPlayer(0);
		m_pEnemy	= GetPlayer(1);
	
		m_pNeutral.EnableAI(false);
		m_pEnemy.EnableAI(false);
		
		SetNeutrals(m_pPlayer, m_pNeutral);
		SetNeutrals(m_pNeutral, m_pEnemy);
		
		SetEnemies(m_pPlayer, m_pEnemy);

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



	function int InitializeUnits()
	{
//		CreateUnitAtMarker(m_pPlayer,markerHeroStart, "HERO");

		m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerHeroStart);
	
		// m_uHero = GetUnitAtMarker( markerHeroStart );

		m_uCow = GetUnitAtMarker( markerCow );
		m_uCow.CommandSetTalkMode(true, false, false);

		
		m_bCheckHero = true;
		m_bChangedCows = false;
	
		return true;
	}

	function int InitializeCows()
	{
		int i;
		unitex uTemp;

		m_auCows.Create(0);
		
		for ( i = markerCowFirst; i <= markerCowLast; ++i)
		{
			uTemp = GetUnitAtMarker(i);
			if(uTemp != null)
			{
				m_auCows.Add( uTemp );
			}
		} 
		return true;
	}


	function int InitializeArtefacts()
	{
		
		CreateArtefacts("ART_SWORD6", markerSword, markerSword, 0, false);	
		CreateArtefacts("ARTIFACT_INVISIBLE", markerSword, markerSword, idSword, false);

		CreateArtefacts("SWITCH_1_1", 21, 21, 28, false);
		CreateArtefacts("SWITCH_2_1", 22, 22, 31, false);
		CreateArtefacts("SWITCH_3_1", 23, 23, 20, false);
		
		CreateArtefacts("SWITCH_1_1", 25, 25, 29, false);
		CreateArtefacts("SWITCH_2_1", 26, 26, 32, false);
		CreateArtefacts("SWITCH_3_1", 27, 27, 24, false);
		
		CreateArtefacts("SWITCH_1_1", 34, 34, 30, false);
		CreateArtefacts("SWITCH_2_1", 35, 35, 38, false);
		CreateArtefacts("SWITCH_3_1", 36, 36, 39, false);		
		CreateArtefacts("SWITCH_1_1", 37, 37, 33, false);
		
		CreateArtefacts("SWITCH_1_1", 40, 40, 42, false);
		CreateArtefacts("SWITCH_1_1", 41, 41, 43, false);

		CreateArtefacts("SWITCH_3_1", 44, 44, 48, false);
		CreateArtefacts("SWITCH_3_1", 46, 46, 49, false);

		CreateArtefacts("SWITCH_1_1", 50, 50, 45, false);
		CreateArtefacts("SWITCH_2_1", 52, 52, 51, false);

		CreateArtefacts("SWITCH_3_1", 62, 62, 47, false);
	
		return true;
	}

	function int CloseGates()
	{

		CLOSE_GATE(24);
		CLOSE_GATE(20);
		CLOSE_GATE(28);
		CLOSE_GATE(29);
		CLOSE_GATE(32);
		CLOSE_GATE(31);
		CLOSE_GATE(30);
		CLOSE_GATE(33);
		CLOSE_GATE(38);
		CLOSE_GATE(39);
		CLOSE_GATE(43);
		CLOSE_GATE(42);	
		CLOSE_GATE(49);
		CLOSE_GATE(48);
		CLOSE_GATE(45);
		CLOSE_GATE(51);
		CLOSE_GATE(47);
		CLOSE_GATE(66);

		return true;
	}

	function int IsGateNumber ( int nArtefactNumber )
	{
		if(	nArtefactNumber == 24
		||	nArtefactNumber == 20
		||	nArtefactNumber == 28
		||	nArtefactNumber == 29
		||	nArtefactNumber == 32
		||	nArtefactNumber == 31
		||	nArtefactNumber == 30
		||	nArtefactNumber == 33
		||	nArtefactNumber == 38
		||	nArtefactNumber == 39
		||	nArtefactNumber == 42
		||	nArtefactNumber == 43
		||	nArtefactNumber == 49
		||	nArtefactNumber == 48
		||	nArtefactNumber == 45
		||	nArtefactNumber == 51
		||	nArtefactNumber == 47 )
		{
			return true;
		}
		return false;
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

		m_nDialogToPlay = dialogMissionFail;
		m_nStateAfterDialog = MissionFail;

		state StartPlayDialog;

		return true;
	}

	function int SetupMinotaursExperience(int nExp)
	{	
		int i;
		unitex uTemp;

		for( i=0; i<m_auMinotaurs.GetSize(); ++i)
		{	
			uTemp = m_auMinotaurs[i];
			if(uTemp != null)
			{
				uTemp.SetExperienceLevel(nExp);			
			}
		}
		return true;
	}


	function int ChangeCowsIntoMonsters()
	{
		int i,x,y,z;
		unitex uTemp;

		m_auMinotaurs.Create(0);

		m_bChangedCows = true;
		m_pNeutral.SetSideColor(m_pEnemy.GetSideColor());
		SetEnemies(m_pPlayer, m_pNeutral);
	
		m_uCow.RemoveUnit();
		m_uCow = CreateUnitAtMarker(m_pNeutral, markerCow,"MINOTAUR");
		m_auMinotaurs.Add(m_uCow);

		for ( i = 0; i < m_auCows.GetSize(); ++i)
		{
			uTemp = m_auCows[i];
			uTemp.RemoveUnit();
			uTemp = CreateUnitAtMarker(m_pNeutral, markerCowFirst+i, "MINOTAUR");
			m_auMinotaurs.Add(uTemp);				
		}
		m_auCows.RemoveAll();

		if( GetDifficultyLevel() == difficultyEasy)
		{
			SetupMinotaursExperience(0);
		}
		else if( GetDifficultyLevel() == difficultyMedium)
		{
			SetupMinotaursExperience(1);
		}
		if( GetDifficultyLevel() == difficultyHard)
		{
			SetupMinotaursExperience(2);
		}
				
		return true;
	}


	function int MoveCows()
	{
		int i,x,y,z,r;
		unitex uTemp;
		
		r = Rand(17);

		if ( r > m_auCows.GetSize()-1 )
		{
			x = m_uCow.GetLocationX();
			y = m_uCow.GetLocationY();
			z = m_uCow.GetLocationZ();
			x = x + (Rand(13)-6);
			y = y + (Rand(13)-6);

			if ( (Distance ( x, y, 54, 93) >= 3) && (Distance ( x, y, 74, 92) >= 3) )
				m_uCow.CommandMove(x, y, z);
		}
		else if ( r == 1 || r == 2 )
		{
			return true;
		}
		else
		{
			uTemp = m_auCows[r];
			x = uTemp.GetLocationX();
			y = uTemp.GetLocationY();
			z = uTemp.GetLocationZ();

			x = x + (Rand(13)-6);
			y = y + (Rand(13)-6);

			if ( (Distance ( x, y, 54, 93) >= 3) && (Distance ( x, y, 74, 92) >= 3) )
				uTemp.CommandMove(x, y, z);
		}
		
		return true;
	}

	function int RemoveCrew()
	{
		if( m_uCrew1.IsLive() )
		{
			m_uCrew1.RemoveUnit();
		}
		if( m_uCrew2.IsLive() )
		{
			m_uCrew2.RemoveUnit();
		}		
		return true;
	}


//--------- STATES -----------------------------------------------------------------------------

    state Initialize
    {
		TurnOffTier5Items();

		SetupTeleportBetweenMarkers(201, 202);
		SetupTeleportBetweenMarkers(203, 204);
 		SetupOneWayTeleportBetweenMarkers(205, 206);
 		SetupOneWayTeleportBetweenMarkers(207, 208);
 		SetupOneWayTeleportBetweenMarkers(209, 210);
		SetupTeleportBetweenMarkers(211, 212);

		CallCamera();

//		ModifyDifficulty();

		InitializePlayers();
		InitializeUnits();
		InitializeCows();
		InitializeArtefacts();
		CloseGates();
		RegisterGoals();

		ShowAreaAtMarker(m_pPlayer, markerHeroStart, 65000);			
			
		PlayerLookAtMarker(m_pPlayer, markerHeroGoTo, constStartLookAtHeight, constLookAtAlpha, constLookAtView);		
		
		SetTimer(7, 500);

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		SetGameRect(0,0,0,0);
		EnableAssistant(0xffffff, false);
		SaveGameRestart(null);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		//+1: lookat 56,23,17,96,49,0
		m_pPlayer.LookAt(GetLeft()+64,GetTop()+22,17,126,49,0);	

		return Start0, 1;
	}


	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogStart )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;
				
			#define UNIT_NAME_FROM Cow
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Start
			#define DIALOG_LENGHT  13

			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay ==  dialogMage )
		{
			#define UNIT_NAME_FROM Mage
			#define UNIT_NAME_TO   Hero 
			#define DIALOG_NAME    Mage
			#define DIALOG_LENGHT  10

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogEND )
		{
			#define UNIT_NAME_FROM Mage
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    END
			#define DIALOG_LENGHT  2

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
		unitex uTemp;

		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogStart )
		{
			SetTimer(0, 20);
			m_uCow.CommandSetTalkMode(false, false, false);
			AddWorldMapSignAtMarker(markerMage, 0, -1);
		}
		else if ( m_nDialogToPlay == dialogEND )
		{
			CreateObjectAtUnit(m_uMage, "CAST_TELEPORT");
			m_uMage.RemoveUnit();
			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", markerHeroEnd, idHeroEnd);
			AddWorldMapSignAtMarker(markerHeroEnd, 0, -1);
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
			RESTORE_STATE(CreateCrew)
			RESTORE_STATE(KillAllMonsters)
			RESTORE_STATE(MissionFail)
			RESTORE_STATE(TeleportHero)
			RESTORE_STATE(TeleportHero2)
			RESTORE_STATE(CompleteMission)
		END_RESTORE_STATE_BLOCK()
	}


	state ShowGate
	{
		ShowAreaAtMarker(m_pPlayer, m_nMarkerToShowArea, rangeShowArea);
		--m_nShowGateCount;		

		if ( m_nShowGateCount == 0 )
		{
			EnableInterface(true);
			EnableCameraMovement(true);	
			
			PlayerLookAtUnit( m_pPlayer, m_uUnitOnSwitch, -1, -1, -1);
			return FindMage;			
		}		
		return ShowGate, 5;
	}

	state Start0
	{
		SetCutsceneText("translate3_04_Cutscene_Start");
		//+1: delayedlookat 64,34,15,41,32,250,0
		m_pPlayer.DelayedLookAt(GetLeft()+66,GetTop()+35,15,41,32,0,150,0);
		return Start1, 30;
	}
	
	state Start1
	{
		m_uHero.CommandMove(GetPointX(markerHeroGoTo), GetPointY(markerHeroGoTo), 0); 			

		return Start, 120;
	}

	state Start
	{	
		SetLowConsoleText("");

		m_nDialogToPlay = dialogStart;
		m_nStateAfterDialog = CreateCrew;

		return StartPlayDialog, 0;
	}

	state CreateCrew
	{

		m_uCrew1 = CreateUnitAtMarker( m_pPlayer, markerCrew1, "MINOTAUR");
		m_uCrew2 = CreateUnitAtMarker( m_pPlayer, markerCrew2, "MINOTAUR");

		CreateObjectAtUnit(m_uCrew1, "HIT_TELEPORT");
		CreateObjectAtUnit(m_uCrew2, "HIT_TELEPORT");


		EnableGoal(goalGainSword, true);
		EnableGoal(goalRemoveTheCurse, true);

		EnableInterface(true);
		EnableCameraMovement(true);

		return FindMage, 20;
	}

	state FindMage
	{		
		if( IsUnitNearMarker( m_uHero, 66, 2)  && !IsPlayerUnitNearMarker( 66, 10, m_pEnemy.GetIFF()))
		{	
			OPEN_GATE( 66 );
		}
		else
		{
			CLOSE_GATE( 66 );
		}

		if( IsUnitNearMarker( m_uHero, markerMage, 2) )
		{				
			SetGoalState(goalRemoveTheCurse, goalAchieved);

			RemoveWorldMapSignAtMarker(markerMage);

			m_uMage = CreateUnitAtMarker( m_pPlayer, markerMage, "PRIEST");
			CreateObjectAtUnit( m_uMage, "HIT_TELEPORT" );
			
			m_nStateAfterDialog = TeleportHero;
			m_nDialogToPlay = dialogMage;
				
			CloseGates();
			ChangeCowsIntoMonsters();	
			
			ClearMarkers(markerMinotaur, markerMinotaur, 0);						
			CreateObjectAtMarker(markerMinotaur, "STATUE_MINOTAUR");

			EnableGoal(goalKillAllMonsters, true);
								
			return StartPlayDialog, 40;
		}
		
		return FindMage, 20;
	}

	state TeleportHero
	{
		m_bCheckHero = false;
		CreateObjectAtUnit(m_uHero, "CAST_TELEPORT");		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		
		m_bTeleportedHero = false;
	
		return TeleportHero2, 50;
	}

	state TeleportHero2
	{
		int i;
		unitex uTemp;

		ShowAreaAtMarker(m_pPlayer, markerTeleportDest, rangeShowArea);
		PlayerLookAtMarker(m_pPlayer, markerTeleportDest, -1, -1, -1);		

		if( m_bTeleportedHero == true )
		{	
			m_uMage.RemoveUnit();	 
			RemoveCrew();
			m_uHero = RestorePlayerUnitAtMarker(m_pPlayer, bufferHero, markerTeleportDest);
			ASSERT( m_uHero != null );
			CreateObjectAtUnit(m_uHero, "HIT_TELEPORT");		
			m_bCheckHero = true;

			for( i=0; i<m_auMinotaurs.GetSize(); ++i)
			{
				uTemp = m_auMinotaurs[i];
				uTemp.CommandAttack(m_uHero);
			}

			return KillAllMonsters, 20;
		}
		else
		{
			m_bTeleportedHero = true;
		}

		return TeleportHero2, 20;
	}
	
	state KillAllMonsters
	{
		if ( m_pNeutral.GetNumberOfUnits() == 0 && GetGoalState(goalKillAllMonsters) != goalAchieved)
		{
			SetGoalState(goalKillAllMonsters, goalAchieved);
		}
		if ( GetGoalState(goalKillAllMonsters) == goalAchieved && GetGoalState(goalGainSword) == goalAchieved )
		{
			m_uMage = CreateUnitNearUnit(m_pPlayer, m_uHero, "PRIEST");
			CreateObjectAtUnit(m_uMage, "HIT_TELEPORT");

			m_nDialogToPlay = dialogEND;
			m_nStateAfterDialog = CompleteMission;
			return StartPlayDialog, 50;
		}
		return KillAllMonsters, 20;
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


//------- EVENTS -----------------------------------------------------------------------

	event Timer0()
	{
		if(!m_bChangedCows)
		{
			MoveCows();		
		}
	}

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
	{

		if ( nArtefactNum == idSword && uUnitOnArtefact == m_uHero )
		{
			if ( GetGoalState(goalRemoveTheCurse) != goalAchieved )
			{	
				m_bCheckHero = false;

				CreateObjectAtUnit(m_uHero, "HIT_CONVERT");
				m_uHero.RemoveUnit();

				m_uHero = null;
				m_uHero = CreateUnitAtMarker(m_pPlayer, markerSword, "COW");
				m_uHero.CommandSetMovementMode(modeHoldPos);			
												
				MissionFailed();

				return true;
			}
			else
			{
				SetGoalState(goalGainSword, goalAchieved);
				state KillAllMonsters;

				return true;
			}
		}
		
		if ( uUnitOnArtefact.GetIFF() == m_pPlayer.GetIFF() )
		{	
			if ( IsGateNumber ( nArtefactNum ) )
			{
				m_nCameraX		= GetCameraX();
				m_nCameraY		= GetCameraY();
				m_nCameraZ		= GetCameraZ();
				m_nCameraZLayer	= GetCameraZLayer();
				m_nCameraView	= GetCameraViewAngle();
					
				OPEN_GATE( nArtefactNum );				
				RemoveArtefactAtUnit(uUnitOnArtefact);	

				if( nArtefactNum == 28
				||	nArtefactNum == 29
				||	nArtefactNum == 30
				||	nArtefactNum == 33
				||	nArtefactNum == 42
				||	nArtefactNum == 43
				||	nArtefactNum == 35 )
				{
					CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
				}
				else if ( nArtefactNum == 31
				||  nArtefactNum == 32
				||  nArtefactNum == 38
				||  nArtefactNum == 51 )
				{
					CreateArtefactAtUnit("SWITCH_2_2", uUnitOnArtefact, 0);
				}
				else if ( nArtefactNum == 20
				||  nArtefactNum == 24
				||  nArtefactNum == 39
				||  nArtefactNum == 48
				||  nArtefactNum == 49
				||  nArtefactNum == 49 )
				{
					CreateArtefactAtUnit("SWITCH_3_2", uUnitOnArtefact, 0);
				}

				EnableInterface(false);
				EnableCameraMovement(false);

				ShowAreaAtMarker(m_pPlayer, nArtefactNum, rangeShowArea);
				PlayerAutoDirDelayedLookAt( m_pPlayer, GetPointX(nArtefactNum), GetPointY(nArtefactNum), m_nCameraZ, -1, m_nCameraView,  m_nCameraZLayer, 40);

				m_nShowGateCount = 15;
				m_nMarkerToShowArea = nArtefactNum;
				m_uUnitOnSwitch = uUnitOnArtefact;
				
				state ShowGate;										
			}			
		} 

		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
		{
			m_bCheckHero = false;
			SetGoalState(goalMirkoMustSurvive, goalAchieved);
			m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
			EndMission(true);
			state MissionComplete;
		}

		return false;
	}

	event UnitDestroyed(unitex uUnit)
	{
		unit uTmp;

		if ( uUnit.GetIFF() == m_pNeutral.GetIFF() && !m_bChangedCows ) 
		{
			uTmp = uUnit.GetAttacker();
			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() ) MissionFailed();
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
		if ( state == Start1 || state == Start )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+66,GetTop()+35,15,41,32,0);

			SetUnitAtMarker(m_uHero, markerHeroGoTo);

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

