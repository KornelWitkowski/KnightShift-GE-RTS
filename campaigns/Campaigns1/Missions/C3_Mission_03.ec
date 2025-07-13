#define MISSION_NAME "translate3_03"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_03_Dialog_
#include "Language\Common\timeMission3_03.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_03\\303_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start1;
	state Start;
	state StartDialog;
	state TalkWithMag;
	state PressSwitch;	
	state GainShield;
	state ShowGate;
	state ShowGates;
	state CompleteMission;
	state MissionComplete;
	state MissionFail;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalMirkoMustSurvive = 0;
		goalGainShield		= 1;

		markerMag			= 0;
		markerHeroStart		= 5;		
		markerCrewStart		= 6;
		markerMagSwitch		= 13;		
		markerShield		= 14;
		
		markerHeroDst		= 87;		
		markerCrewDst		= 88;

		markerSecure1		= 79;
		markerSecure2		= 80;

		markerCrewEnd		= 81;

		markerGiant1		= 24;
		markerGiant2		= 25;

		markerHoldPos1 = 85;
		markerHoldPos2 = 86;
		
		constStartLookAtHeight	= 15;

		constMaxLookAtHeight	= 23;
		constMaxLookAtView		= 32;

		rangeShowArea		= 6;
		rangeTalk			= 2;
	
		dialogStart				= 1;
		dialogMazeWithShield	= 2;
		dialogShield			= 3;
		dialogMissionFail		= 4;

		idShield		= 1024;
		idMagSwitch	= 1025;
	}

	player m_pPlayer;
	player m_pEnemy;
	player m_pNeutral;
		
	unitex m_uHero;
	unitex m_uMag;
	platoon m_pCrew;

	unitex m_uMagTalkSmoke;
	unitex m_uUnitOnSwitch;

	unitex m_uShieldSecure1;
	unitex m_uShieldSecure2;
	unitex m_uGigant1;
	unitex m_uGigant2;
	unitex m_uHoldPos1;
	unitex m_uHoldPos2;

	int m_bCheckHero;
	int m_bChangeGiants;
	int m_nMarkerToShowArea;

	int m_nShowGateCount;

	int m_nFireTrap2;
	int m_nFireTrap3;
		
		

//------ FUNCTIONS -----------------------------------------------------------

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

	function int RegisterGoals()
	{
		RegisterGoal(goalMirkoMustSurvive , "translate3_03_Goal_MirkoMustSurvive");
		RegisterGoal(goalGainShield, "translate3_03_Goal_GainShield");

		EnableGoal(goalMirkoMustSurvive, true);
		EnableGoal(goalGainShield, true);

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
		m_pPlayer	= GetPlayer( 2);
		m_pPriest	= GetPlayer( 2);
		
		m_pNeutral	= GetPlayer( 0);
		m_pEnemy	= GetPlayer( 9);
		
		m_pNeutral.EnableAI(false);
		m_pEnemy.EnableAI(false);

		m_pEnemy.SetUnitsExperienceLevel(4+GetDifficultyLevel());
		
		SetNeutrals(m_pPlayer, m_pNeutral);
		SetNeutrals(m_pEnemy, m_pNeutral);		
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
		RESTORE_PLAYER_UNITS();
	
		m_uHero = GetUnitAtMarker( markerHeroStart );
		m_uHero.CommandSetTalkMode(true, false, false);

		m_pCrew = CreatePlatoon();

		m_uMag = CreateUnitAtMarker( m_pNeutral, markerMag, "SORCERER" );
		m_uMag.CommandTurn(128);

		SetRealImmortal(m_uMag, true);

		m_uShieldSecure1 = GetUnitAtMarker(markerSecure1);
		m_uShieldSecure2 = GetUnitAtMarker(markerSecure2);

		INITIALIZE_UNIT( HoldPos1 );
		INITIALIZE_UNIT( HoldPos2 );
		m_uHoldPos1.CommandSetMovementMode(modeHoldPos);
		m_uHoldPos2.CommandSetMovementMode(modeHoldPos);

		m_bCheckHero = true;

		return true;
	}


	function int InitializeArtefacts()
	{
		CreateArtefacts("ART_SHIELD5",         markerShield, markerShield, 0       , false);	
		CreateArtefacts("ARTIFACT_INVISIBLE", markerShield, markerShield, idShield, false);

		CreateArtefacts("SWITCH_1_1", 42, 42, 41, false);
		CreateArtefacts("SWITCH_3_1", 66, 66, 65, false);
		CreateArtefacts("SWITCH_2_1", 68, 68, 67, false);

		CreateArtefacts("SWITCH_2_1", 82, 82, 81, false);
		CreateArtefacts("SWITCH_3_1", 84, 84, 83, false);



		return true;
	}

	function int InitializeVariables()
	{
		
		m_nFireTrap2 = 4;
		m_nFireTrap3 = 4;
		m_bChangeGiants = false;

		return true;
	}


	function int CloseGates()
	{
		CLOSE_GATE ( 1 );
		CLOSE_GATE ( 2 );
		CLOSE_GATE ( 3 );
		CLOSE_GATE ( 4 );
		CLOSE_GATE ( 41 );
		CLOSE_GATE ( 65 );
		CLOSE_GATE ( 67 );
		CLOSE_GATE ( 81 );
		CLOSE_GATE ( 83 );


		return true;
	}

	function int SecureUnitsHoldPos()
	{
		if( m_uShieldSecure1.IsLive() && !IsUnitNearMarker(m_uShieldSecure1, markerSecure1, 16) )
		{
			m_uShieldSecure1.CommandMove(GetPointX(markerSecure1), GetPointY(markerSecure1), GetPointZ(markerSecure1));
		}
		if( m_uShieldSecure2.IsLive() && !IsUnitNearMarker(m_uShieldSecure2, markerSecure2, 16) )
		{
			m_uShieldSecure2.CommandMove(GetPointX(markerSecure2), GetPointY(markerSecure2), GetPointZ(markerSecure2));
		}
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
		CloseGates();
		
		//ModifyDifficulty();

		RegisterGoals();

		// PlayerLookAtUnit(m_pPlayer, m_uHero, constStartLookAtHeight, constLookAtAlpha, constLookAtView);

		SetTimer(0, 40);
		SetTimer(1, 50);
		SetTimer(7, 1); // snieg na starcie

		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		SetGameRect(0,0,0,0);
		EnableAssistant(0xffffff, false);
		SaveGameRestart(null);

		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		//+1: lookat 48,100,24,30,25,0
		m_pPlayer.LookAt(GetLeft()+65,GetTop()+106,20,279,45,0);

		ShowAreaAtMarker(m_pPlayer, markerHeroStart, 20);

		SetTime(0);
	
		SaveGameRestart(null);


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
		
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero 
			#define DIALOG_NAME    Start
			#define DIALOG_LENGHT  1
			#define NO_TURN_UNITS  
					
			#include "..\..\TalkBis.ech"

			return PlayDialog, 1;
		}	
		else if ( m_nDialogToPlay ==  dialogMazeWithShield )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mag 
			#define DIALOG_NAME    MazeWithShield
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogShield )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    Shield
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

		if ( m_nDialogToPlay == dialogStart )
		{
			START_TALK( Mag );
			AddWorldMapSignAtMarker(markerMag, 0, -1);
			m_uHero.CommandSetTalkMode(false, false, false);
			m_uHoldPos1.CommandSetMovementMode(modeMove);
			m_uHoldPos2.CommandSetMovementMode(modeMove);
		}
		else if( m_nDialogToPlay == dialogMazeWithShield )
		{
			CreateArtefactAtMarker("SWITCH_3_1", markerMagSwitch, idMagSwitch);
		}
		else if( m_nDialogToPlay == dialogShield )
		{
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
			RESTORE_STATE(TalkWithMag)
			RESTORE_STATE(PressSwitch)
			RESTORE_STATE(CompleteMission)
			RESTORE_STATE(MissionFail)
		END_RESTORE_STATE_BLOCK()
	}

	state Start0
	{
		//+1: delayedlookat 65,106,20,259,45,200,0
		SetCutsceneText("translate3_03_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+65,GetTop()+106,20,259,45,0,60,0);

		return Start1, 50;
	}
	state Start1
	{
		CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
		CommandMoveUnitToMarker(m_uHero, markerHeroDst);

		return Start, 10;
	}
	
	state Start
	{		
		SetLowConsoleText("");

		//+1: delayedlookat 64,106,15,229,50,100,0
		m_pPlayer.DelayedLookAt(GetLeft()+64,GetTop()+106,15,229,50,0,100,0);

		return StartDialog, 100;
//		return Start, 20;
	}

	state StartDialog
	{
		m_nDialogToPlay = dialogStart;
		m_nStateAfterDialog = TalkWithMag;
	
		return StartPlayDialog, 0;
	}

	state TalkWithMag
	{
		if( IsUnitNearMarker( m_uHero, markerMag, rangeTalk ) && !m_uHero.IsMoving())
		{
			RemoveWorldMapSignAtMarker(markerMag);
			STOP_TALK( Mag );
			m_nDialogToPlay = dialogMazeWithShield;
			m_nStateAfterDialog = PressSwitch;

			m_uHero.CommandTurn(m_uHero.GetAngleToTarget(m_uMag.GetUnitRef()));
		

			return StartPlayDialog, 20;			
		}
		return TalkWithMag, 20;	
	}

		
	state PressSwitch
	{
		return PressSwitch ,20;
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
			return GainShield;			
		}		
		return ShowGate, 5;
	}

	state ShowGates
	{
		--m_nShowGateCount;		

		if( m_nMarkerToShowArea <= 4)
			ShowAreaAtMarker(m_pPlayer, m_nMarkerToShowArea, rangeShowArea);
				
		if( m_nShowGateCount == 1 )
		{
			++m_nMarkerToShowArea;
		
			if( m_nMarkerToShowArea <= 4)		
				PlayerLookAtMarker(m_pPlayer, m_nMarkerToShowArea, -1, -1, -1);
		}
	

		if ( m_nShowGateCount == 0 )
		{	
			m_nShowGateCount = 10;			
			
			if( m_nMarkerToShowArea > 4 )
			{
				EnableInterface(true);
				EnableCameraMovement(true);	
				PlayerLookAtUnit( m_pPlayer, m_uUnitOnSwitch, -1, -1, -1);
				return GainShield;			
			}
			else
			{
				OPEN_GATE( m_nMarkerToShowArea );
			}
		}
				
		return ShowGates, 5;		
	}

	state GainShield
	{		
		if ( IsPlayerUnitNearMarker(  markerGiant1, 3, m_pPlayer.GetIFF()) && !m_bChangeGiants )
		{
			m_bChangeGiants = true;

			ClearMarkers(markerGiant1, markerGiant1, 0);
			ClearMarkers(markerGiant2, markerGiant2, 0);

			CreateUnitAtMarker(m_pEnemy, markerGiant1, "GIANT");
			CreateObjectAtMarker(markerGiant1, "HIT_TELEPORT");

			CreateUnitAtMarker(m_pEnemy, markerGiant2, "GIANT");
			CreateObjectAtMarker(markerGiant2, "HIT_TELEPORT");			
		}
		return GainShield, 20;
	}
	
	state CompleteMission
	{				
		m_bCheckHero = false;
		SetGoalState(goalMirkoMustSurvive, goalAchieved);
		
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetLeft(), GetTop(), GetRight(), GetBottom(), 0, null, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, true , GetLeft(), GetTop(), GetRight(), GetBottom(), 1, null, true);
		
		EndMission(true);
		return MissionComplete, 20;
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
		if ( nArtefactNum == idShield && uUnitOnArtefact == m_uHero && GetGoalState(goalGainShield) != goalAchieved )
		{
			
			SetGoalState(goalGainShield, goalAchieved);
			m_nDialogToPlay = dialogShield;
			m_nStateAfterDialog = CompleteMission;

			state StartPlayDialog;
			return true;		
		}

		if( nArtefactNum == idMagSwitch && uUnitOnArtefact.GetIFF() == m_pPlayer.GetIFF() )
		{
			RemoveArtefactAtMarker(markerMagSwitch);
			CreateArtefactAtMArker("SWITCH_3_2", markerMagSwitch, 0);

			OPEN_GATE ( 1 );

			PlayerLookAtMarker(m_pPlayer, 1, constLookAtHeight, constLookAtAlpha, constLookAtView);

			m_uUnitOnSwitch = uUnitOnArtefact;
			m_nShowGateCount = 10;
			m_nMarkerToShowArea = 1;
			
			ShowAreaAtMarker(m_pPlayer, 1, rangeShowArea);
			ShowAreaAtMarker(m_pPlayer, 2, rangeShowArea);
			ShowAreaAtMarker(m_pPlayer, 3, rangeShowArea);
			ShowAreaAtMarker(m_pPlayer, 4, rangeShowArea);
	
			state ShowGates;

		}

		
		if ( (nArtefactNum == 41 ||
			  nArtefactNum == 65 ||
			  nArtefactNum == 67 ||
			  nArtefactNum == 81 ||
			  nArtefactNum == 83 )
			  && uUnitOnArtefact.GetIFF() == m_pPlayer.GetIFF() )
		{			
			RemoveArtefactAtUnit(uUnitOnArtefact);	

			if( nArtefactNum == 41 )
			{
				CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);
			}
			else if ( nArtefactNum == 65 || nArtefactNum == 83)
			{
				CreateArtefactAtUnit("SWITCH_3_2", uUnitOnArtefact, 0);
			}
			else if ( nArtefactNum == 67 || nArtefactNum == 81)
			{
				CreateArtefactAtUnit("SWITCH_2_2", uUnitOnArtefact, 0);
			}

			EnableInterface(false);
			EnableCameraMovement(false);


			ShowAreaAtMarker(m_pPlayer, nArtefactNum, rangeShowArea);
			
			OPEN_GATE( nArtefactNum );				
					
			PlayerLookAtMarker(m_pPlayer, nArtefactNum, constLookAtHeight, constLookAtAlpha, constLookAtView);

			m_nShowGateCount = 15;
			m_nMarkerToShowArea = nArtefactNum;
			m_uUnitOnSwitch = uUnitOnArtefact;
			
			ShowAreaAtMarker(m_pPlayer, m_nMarkerToShowArea, rangeShowArea);
	
			state ShowGate;										
		}			
		

		/*
		if ( nArtefactNum == idHeroEnd && uUnitOnArtefact == m_uHero )
		{
			m_bCheckHero = false;
			SetGoalState(goalMirkoMustSurvive, goalAchieved);
			SAVE_PLAYER_UNITS();
			EndMission(true);
			state MissionComplete;
		}*/

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
	}

	event Timer0()
	{	
		int i;
		--m_nFireTrap3;
					
		if( m_uShieldSecure1.IsLive() || m_uShieldSecure2.IsLive() )
		{
			CreateObjectAtMarker( 77, "FIRETRAP1");
			CreateObjectAtMarker( 78, "FIRETRAP1");
		}
		
		if(m_nFireTrap3 == 2)
		{	
			SecureUnitsHoldPos();
					
			CreateObjectAtMarker(15, "FIRETRAP1");
			CreateObjectAtMarker(16, "FIRETRAP1");
			CreateObjectAtMarker(17, "FIRETRAP1");

			CreateObjectAtMarker(21, "FIRETRAP1");
			CreateObjectAtMarker(22, "FIRETRAP1");
			CreateObjectAtMarker(23, "FIRETRAP1");
		}
		else if(m_nFireTrap3 == 0)
		{	
			
			SecureUnitsHoldPos();
						
			CreateObjectAtMarker(18, "FIRETRAP1");
			CreateObjectAtMarker(19, "FIRETRAP1");
			CreateObjectAtMarker(20, "FIRETRAP1");

			for ( i=26; i<=40; ++i)
			{
				CreateObjectAtMarker(i, "FIRETRAP1");		
			}
						
			m_nFireTrap3 = 4;
		}

	}

	function int IsInArray( int nVal, int nArr[])
	{
		int i;
			
		for( i=0; i < nArr.GetSize(); ++i )
		{
			if ( nVal == nArr[i] )
			{
				return true;
			}
		}
		return false;
	}

	event Timer1()
	{			
		int i;
		int r;
		int fire[];		
		fire.Create(0);

		--m_nFireTrap2;
				
		if(m_nFireTrap2 == 2)
		{			
			CreateObjectAtMarker(7, "FIRETRAP1");
			CreateObjectAtMarker(8, "FIRETRAP1");
			CreateObjectAtMarker(9, "FIRETRAP1");

			for ( i=69; i<=76; ++i)
			{
				CreateObjectAtMarker(i, "FIRETRAP1");		
			}

			for ( i = 0; i < 7 ; ++i )
			{							
				do
				{
					r = 43 + Rand(22);					
				}while( IsInArray(r, fire));
			
				fire.Add(r);					
				CreateObjectAtMarker(r, "FIRETRAP1");	
			}
			fire.RemoveAll();			
		}
		else if(m_nFireTrap2 == 0)
		{	
			CreateObjectAtMarker(10, "FIRETRAP1");
			CreateObjectAtMarker(11, "FIRETRAP1");
			CreateObjectAtMarker(12, "FIRETRAP1");

			for ( i=69; i<=76; ++i)
			{
				CreateObjectAtMarker(i, "FIRETRAP1");		
			}

			for ( i = 0; i < 7 ; ++i )
			{							
				do
				{
					r = 43 + Rand(22);			
				}while( IsInArray(r, fire) );
				fire.Add(r);		
				CreateObjectAtMarker(r, "FIRETRAP1");	
			}
			fire.RemoveAll();			

			m_nFireTrap2 = 4;
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
		if ( state == Start1 || state == Start || state == StartDialog )
		{
			if ( state == Start1 )
			{
				CommandMovePlatoonToMarker(m_pCrew, markerCrewDst);
			}

			SetLowConsoleText("");

			m_pPlayer.LookAt(GetLeft()+64,GetTop()+106,15,229,50,0);

			SetUnitAtMarker(m_uHero, markerHeroDst);

			SetStateDelay(0);
			state StartDialog;
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

