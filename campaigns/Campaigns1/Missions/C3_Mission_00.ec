#define MISSION_NAME "translate3_00"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate3_00_Dialog_
#include "Language\Common\timeMission3_00.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission3_00\\300_"

mission MISSION_NAME
	{
	// states ->
		state Initialize;
		state Start0;
		state Start0p5;
		state Start0p75;
		state Start1;
		state Start2;
		state Start;
		state MissionComplete;
	// includes ->
		#include "..\..\Common.ech"
		#include "..\..\Talk.ech"
	
	consts
		{
		// players ->		
			playerNeutral   =  0;
			playerPlayer    =  2;			
		// markers ->	
			markerHeroStart = 3;
			markerMag       = 0;
		// dialogs ->
			dialogIntro     = 1;
		}
	
	// players ->
		player m_pNeutral;
		player m_pPlayer;
	// units ->	
		unitex m_uHero;		
		unitex m_uMag;
	
	function int InitializePlayers()
		{
		INITIALIZE_PLAYER( Neutral   );
		INITIALIZE_PLAYER( Player    );
		
		m_pNeutral.EnableAI(false);
		
		SetAlly(m_pPlayer, m_pNeutral);
		
		return true;
		}
	function int InitializeUnits()
		{
		if ( GetDifficultyLevel() == difficultyEasy )
			{
			m_uHero = m_pPlayer.CreateUnit(GetPointX(markerHeroStart), GetPointY(markerHeroStart), GetPointZ(markerHeroStart), 0, "HERO_EASY","HELMET2B","ARMOUR2B","SHIELD2H","SWORD2A", null, null, null, null);
			}
		else if ( GetDifficultyLevel() == difficultyMedium )
			{
			m_uHero = m_pPlayer.CreateUnit(GetPointX(markerHeroStart), GetPointY(markerHeroStart), GetPointZ(markerHeroStart), 0, "HERO","HELMET2B","ARMOUR2B","SHIELD2H","SWORD2A", null, null, null, null);
			}
		else if ( GetDifficultyLevel() == difficultyHard )
			{
			m_uHero = m_pPlayer.CreateUnit(GetPointX(markerHeroStart), GetPointY(markerHeroStart), GetPointZ(markerHeroStart), 0, "HERO_HARD","HELMET2B","ARMOUR2B","SHIELD2H","SWORD2A", null, null, null, null);
			}
		
		m_uHero.SetIsHeroUnit(true);
        m_uHero.SetIsSingleUnit(true);

		m_uHero.SetExperienceLevel(6);
		
		INITIALIZE_UNIT( Mag );
		
		return true;
		}
	
	state StartPlayDialog
		{
		if ( m_nDialogToPlay == dialogIntro )
			{
			#define NO_PREPARE_INTERFACE_TO_TALK
			
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Mag
			#define DIALOG_NAME    Intro
			#define DIALOG_LENGHT  6
			
			#include "..\..\TalkBis.ech"
			
			m_nGameCameraZ = 23;
			m_nGameCameraAlpha = -1;
			m_nGameCameraView = 32;
			
			return PlayDialog, 1;
			}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
		}
	state EndPlayDialog
		{				
		// RestoreTalkInterface(m_pPlayer, m_uHero);
		CommandMoveUnitToMarker(m_uHero, markerHeroStart);
		
		return MissionComplete, 2*30;
		}
	state RestoreGameState
		{
		END_TALK_DEFINITION();
		
		BEGIN_RESTORE_STATE_BLOCK()
		RESTORE_STATE(MissionComplete)
		END_RESTORE_STATE_BLOCK()
		}
	state Initialize
		{
		int i;
		unitex uTmp;
		
		TurnOffTier5Items();
		
		CallCamera();
		
		InitializePlayers();
		InitializeUnits();
		
		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

		EnableAssistant(0xffffff, false);
		
		ExecuteConsoleCommand("Terrain.MinDrawDistance 47.0");
		ExecuteConsoleCommand("Graph.DrawDistance 47.0");
		ExecuteConsoleCommand("Terrain.MaxDrawDistance 47.0");
		
		EnableInterface(false);
		EnableCameraMovement(false);
		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);
		
		ShowAreaAtMarker(m_pPlayer, markerHeroStart, 128);
		
		m_pPlayer.LookAt(GetLeft()+20,GetTop()+74,23,230,62,0);
		
		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);
		
		PlayTrack("Music\\night05.tws");
		
		return Start0, 1;
		}
	state Start0
		{
		int i;
		
		SetCutsceneText("translate3_00_Cutscene_Start");
		m_pPlayer.DelayedLookAt(GetLeft()+41,GetTop()+80,22,15,57,0,350,1);
		
		for ( i= 4; i<= 9; ++i ) CreateObjectAtMarker(i, "FIRE2");
		for ( i=10; i<=16; ++i ) CreateObjectAtMarker(i, "FIRE3");
		
		return Start0p5, 235;
		}
	state Start0p5
		{
		m_uHero.BeginQuickRecord();
		CommandMoveUnitToMarker(m_uHero, 2);
		CommandMoveUnitToMarker(m_uHero, 1);
		m_uHero.EndQuickRecord();
		
		return Start0p75, 115-60;
		}
	state Start0p75
		{
		int i;
		
		return Start1, 60;
		}
	state Start1
		{
		SetLowConsoleText("");
		
		m_pPlayer.LookAt(GetLeft()+48,GetTop()+51,17,130,41,0);
		m_pPlayer.DelayedLookAt(GetLeft()+48,GetTop()+51,17,130,41,0,70,1);
		
		return Start2, 70;
		}
	state Start2
		{
		m_pPlayer.LookAt(GetLeft()+49,GetTop()+50,17,26,32,0);
		m_pPlayer.DelayedLookAt(GetLeft()+49,GetTop()+50,17,26,32,0,30,1);
		
		return Start, 30;
		}
	state Start
		{
		SET_DIALOG(Intro, MissionComplete);
		
		return StartPlayDialog, 0;
		}
	state MissionComplete
		{
			m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
			
			ExecuteConsoleCommand("Terrain.MinDrawDistance 25.0");
			ExecuteConsoleCommand("Terrain.MaxDrawDistance 60.0");
			
			EndMission(true);
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

    event EscapeCutscene()
		{
		SetStateDelay(0);
		state MissionComplete;
		}

	event Timer7()
	{
		StartWind();
	}
}
