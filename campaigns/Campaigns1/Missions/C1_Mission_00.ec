#define MISSION_NAME "translate1_00"

#define TIME_MISSION_DIALOG_PREFIX TIME_translate1_00_Dialog_
#include "Language\Common\timeMission1_00.ech"

#define WAVE_MISSION_DIALOG_PREFIX "Dialogs\\Mission1_00\\100_"

mission MISSION_NAME
{
	state Initialize;
	state Start0;
	state Start;
	state Start1;
	state Start2;
	state Start2b;
	state Start3;
	state Start4;
	state MoveHero;
	state MovedHero;
	state FindWeapon;
	state FoundWeapon;
	state FindPriest;
	state FoundPriest;
	state KillWolf;
	state KilledWolf;
	state HealHero;
	state HeroSleeping;
	state HealedHero;
	state FindArtefacts;
	state FoundArtefacts;
	state FindCrew;
	state FoundCrew;
	state WaitForMissionComplete;
	state MissionComplete;
	state MissionFail;

	state MoveShepherdToGateShitch;

#include "..\..\Common.ech"
#include "..\..\Talk.ech"
#include "..\..\Priest.ech"

	consts
	{
		goalHeroSurvive   =  0;
//		goalMoveHero      =  1;
//		goalFindWeapon    =  2;
//		goalKillWolf      =  3;
//		goalHealHero      =  4;
		goalFindCrew      =  5;
		goalFindEquipment =  6;

		goalFindArmour    =  7;
		goalFindHelmet    =  8;
		goalFindShield    =  9;
		goalFindSword     = 10;

		goalChilds        = 11;
		goalBears         = 12;
		goalCows          = 13;

		playerPlayer     =  2;
		playerNeutral    =  0;
		playerVillage    =  3;
		playerChilds     =  4;
//		playerAnimals    = 14;
		playerAnimalsBis =  1;
		playerFriend     =  5;

		playerPriest     =  5;

		markerHeroStart =  0;
		markerCrewStart = 52;

		markerPriest    = 1;
		markerPriestBis = 5;
		markerArmourOwner = 7;
		markerHelmetOwner = 8;

//		markerStartGate  = 3;
//		markerWolfGate   = 2;
//		markerCastleGate = 5;
		markerCrewGate   = 6;

		markerCrewGateKeeper = 89;

		markerWolf1 = 44;
		markerWolf2 = 45;

		rangeHeroMove = 0;
		rangeNear     = 4;
		rangeTalk     = 3;

		rangeShowArea = 10;

		rangeAutoArtifactsCreate = 14;

		idWeapon = 1024;
		idArmour = 1025;
		idHelmet = 1026;
		idShield = 1027;
		idSword  = 1028;

		constAutoBonus = 777;

		maskGateOpenSwitch  =  2048;
		maskGateCloseSwitch =  4096;
//		maskTeleport        =  8192;
		maskDetonator       = 16384;

		markerWeapon =  4;
		markerArmour = 50;
		markerHelmet = 51;
		markerShield = 21;
		markerSword  = 38;

		markerChildsInformator =  7;
		markerBearsInformator  =  8;
		markerShieldInformator =  9;
		markerHealInformator   = 10;

		markerShepherd = 43;
		markerObora    = 63;

		markerChildFirst = 11;
		markerChildLast  = 13;

		markerChildsDestination = 105;

		markerBearFirst = 15;
		markerBearLast  = 16;

		markerBearsDestination = 17;

		markerCowFirst = 60;
		markerCowLast  = 62;

		markerCowsDestination = 63;

		rangeChildFollowHero = 8;

		markerSwordGate       = 66;
		markerSwordGateSwitch = 65;

//		bufferTeleport = 5;

		markerWalkerFirst    = 70;
		markerWalkerLast     = 80;

		markerVillageLimiterFrom = 81;
		markerVillageLimiterTo   = 82;

		markerAutoArtifactFirst = 83;
		markerAutoArtifactLast  = 88;

		dialogMoveHero        =  1;
		dialogFindWeapon      =  2;
		dialogKillWolf        =  3;
		dialogHealHero        =  4;
		dialogFindCrew        =  5;
		dialogChildsInfo      =  6;
		dialogChildsDone      =  7;
		dialogBearsInfo       =  8;
		dialogBearsDone       =  9;
		dialogCowsInfo        = 10;
		dialogCowsDone        = 11;
		dialogCowsGateOpened  = 12;
		dialogHealInfo        = 13;
		dialogShieldInfo      = 14;
		dialogTunnelsInfo     = 15;
		dialogGateInfo        = 16;
		dialogMissionComplete = 17;
		dialogMissionFail     = 18;
		dialogChildFound1     = 19;
		dialogChildFound2     = 20;
		dialogChildFound3     = 21;
	}

	player m_pPlayer;

	player m_pNeutral;
	player m_pVillage;
	player m_pChilds;
//	player m_pAnimals;
	player m_pAnimalsBis;
	player m_pFriend;

	unitex m_uHero;

	unitex m_uArmourOwner;
	unitex m_uHelmetOwner;

//	unitex m_uStartGate;
//	unitex m_uWolfGate;
//	unitex m_uCastleGate;
	unitex m_uCrewGate;

	unitex m_uCrewGateKeeper;

	unitex m_uWolf1;
	unitex m_uWolf2;

	unitex m_uChildsInformator;
	unitex m_uBearsInformator;
	unitex m_uShieldInformator;
	unitex m_uHealInformator;

	unitex m_uChildsInformatorTalkSmoke;
	unitex m_uBearsInformatorTalkSmoke;
	unitex m_uShieldInformatorTalkSmoke;
	unitex m_uHealInformatorTalkSmoke;
	unitex m_uCrewGateKeeperTalkSmoke;

	unitex m_uObora;
	unitex m_uShepherd;

	unitex m_uShepherdTalkSmoke;

	unitex m_uSwordGate;

	unitex m_uChildTalk;

	int m_bCheckHero;

	int m_bUpdateWalkers;
	int m_bCheckInformators;

	int m_anArtefactsIDsToFind[];

	platoon m_pCrew;

	int m_bClearConsoleOnUnitDestroyed;

	unitex m_uPriestTalkSmoke;

	function int RegisterGoals()
	{
		REGISTER_GOAL( HeroSurvive   );
//		REGISTER_GOAL( MoveHero      );
//		REGISTER_GOAL( FindWeapon    );
//		REGISTER_GOAL( KillWolf      );
//		REGISTER_GOAL( HealHero      );
		REGISTER_GOAL( FindCrew      );
		REGISTER_GOAL( FindEquipment );

		REGISTER_GOAL( FindArmour  );
		REGISTER_GOAL( FindHelmet  );
		REGISTER_GOAL( FindShield  );
		REGISTER_GOAL( FindSword   );

		REGISTER_GOAL( Childs );
		REGISTER_GOAL( Bears  );
		REGISTER_GOAL( Cows   );

		EnableGoal(goalHeroSurvive, true);

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
		INITIALIZE_PLAYER( Player     );

		INITIALIZE_PLAYER( Neutral    );
		INITIALIZE_PLAYER( Village    );
		INITIALIZE_PLAYER( Childs     );
//		INITIALIZE_PLAYER( Animals    );
		INITIALIZE_PLAYER( AnimalsBis );
		INITIALIZE_PLAYER( Friend     );

		INITIALIZE_PLAYER( Priest     );

		m_pNeutral.EnableAI(false);
		m_pVillage.EnableAI(false);
		m_pChilds.EnableAI(false);
		m_pAnimalsBis.EnableAI(false);
		m_pFriend.EnableAI(false);

		m_pVillage.SetSideColor(m_pFriend.GetSideColor());
		m_pChilds.SetSideColor(m_pVillage.GetSideColor());
		m_pPriest.SetSideColor(m_pPlayer.GetSideColor());
		m_pNeutral.SetSideColor(m_pPlayer.GetSideColor());

		SetNeutrals(m_pNeutral, m_pPlayer    );
		SetNeutrals(m_pNeutral, m_pVillage   );
		SetNeutrals(m_pNeutral, m_pChilds    );
//		SetNeutrals(m_pNeutral, m_pAnimals   );
		SetNeutrals(m_pNeutral, m_pAnimalsBis);
		SetNeutrals(m_pNeutral, m_pFriend    );

		SetNeutrals(m_pPlayer, m_pVillage);
		SetNeutrals(m_pPlayer, m_pChilds );

//		m_pAnimals.SetEnemy(m_pPlayer);
		m_pAnimalsBis.SetEnemy(m_pPlayer);

		SetNeutrals(m_pChilds, m_pAnimalsBis);
		SetNeutrals(m_pChilds, m_pVillage   );

		m_pFriend.EnableAIFeatures(aiRejectAlliance, false);
		m_pPlayer.SetAlly(m_pFriend);

		SetNeutrals(m_pFriend, m_pAnimalsBis);

//		SetNeutrals(m_pAnimals, m_pAnimalsBis);

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
		
		m_pPlayer.EnableCommand(commandDropEquipment, false);

		return true;
	}

	function int InitializeUnits()
	{
//		INITIALIZE_HERO();

		m_uPriest = m_pPriest.CreateUnit(GetPointX(markerPriest), GetPointY(markerPriest), GetPointZ(markerPriest), 0xc0, PRIEST_UNIT);

		m_bRemovePriest = false;

		INITIALIZE_UNIT( ArmourOwner );
		INITIALIZE_UNIT( HelmetOwner );

//		INITIALIZE_UNIT( StartGate  );
//		INITIALIZE_UNIT( WolfGate   );
//		INITIALIZE_UNIT( CastleGate );
		INITIALIZE_UNIT( CrewGate );

		INITIALIZE_UNIT( CrewGateKeeper );

//		INITIALIZE_UNIT( Wolf1 );
//		INITIALIZE_UNIT( Wolf2 );

		INITIALIZE_UNIT( ChildsInformator );
		INITIALIZE_UNIT( BearsInformator  );
		INITIALIZE_UNIT( ShieldInformator );
		INITIALIZE_UNIT( HealInformator   );

		m_uChildsInformator.CommandSetMovementMode(modeHoldPos);
		m_uBearsInformator.CommandSetMovementMode(modeHoldPos);
		m_uShieldInformator.CommandSetMovementMode(modeHoldPos);
		m_uHealInformator.CommandSetMovementMode(modeHoldPos);

		INITIALIZE_UNIT( Shepherd );
		INITIALIZE_UNIT( Obora );

		m_uShepherd.SetUnitName("translate1_00_Name_Pietrek");
		m_uHealInformator.SetUnitName("translate1_00_Name_Witch");

		m_uShepherd.CommandSetMovementMode(modeHoldPos);

		INITIALIZE_UNIT( SwordGate );

		START_TALK( ChildsInformator );
		// START_TALK( BearsInformator  );
		START_TALK( HealInformator   );

		SetRealImmortal(m_uChildsInformator, true);
		SetRealImmortal(m_uBearsInformator, true);
		SetRealImmortal(m_uShieldInformator, true);
		SetRealImmortal(m_uHealInformator, true);
		SetRealImmortal(m_uShepherd, true);
		SetRealImmortal(m_uCrewGateKeeper, true);

		m_bCheckInformators = true;

		m_pCrew = CreateUnitsAtMarker(m_pNeutral, markerCrewStart, "HEROHUNTER", 1);
		m_pCrew = CreateUnitsAtMarker(m_pNeutral, markerCrewStart, "HEROHUNTER2", 1);
		m_pCrew = CreateUnitsAtMarker(m_pNeutral, markerCrewStart, "HEROHUNTER3", 1);
		m_pCrew = CreateUnitsAtMarker(m_pNeutral, markerCrewStart, "HEROHUNTER4", 1);
		CreateUnitsAtMarker(m_pCrew, m_pNeutral, markerCrewStart, "MIESZKO", 1);

		return true;
	}

	function int InitializeArtefacts()
	{
		CreateArtefacts("ART_SWORD1",         markerWeapon, markerWeapon, 0       , false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerWeapon, markerWeapon, idWeapon, false);

		CreateArtefacts("ART_SHIELD2H",       markerShield, markerShield, 0       , false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerShield, markerShield, idShield, false);

		CreateArtefacts("ART_SWORD2",         markerSword,  markerSword,  0      ,  false);
		CreateArtefacts("ARTIFACT_INVISIBLE", markerSword,  markerSword,  idSword,  false);

		m_anArtefactsIDsToFind.Create(0);

		m_anArtefactsIDsToFind.Add(idArmour);
		m_anArtefactsIDsToFind.Add(idHelmet);
		m_anArtefactsIDsToFind.Add(idShield);
		m_anArtefactsIDsToFind.Add(idSword);

		return true;
	}

	function int InitializeGateSwitches()
	{
		unitex uTmp;

		CreateArtefacts("SWITCH_1_1", 23, 23, maskGateOpenSwitch|22, false);
		CreateArtefacts("SWITCH_1_1", 25, 25, maskGateOpenSwitch|24, false);
		//CreateArtefacts("ARTIFACT_INVISIBLE", 26, 26, maskGateOpenSwitch|27, false);

		CLOSE_GATE( 103 );

		CLOSE_GATE( 22 );
		CLOSE_GATE( 24 );
		//CLOSE_GATE( 27 );

		CreateArtefacts("SWITCH_1_1", 31, 31, maskGateOpenSwitch|35, false);
		CreateArtefacts("SWITCH_1_1", 32, 32, maskGateOpenSwitch|36, false);
		CreateArtefacts("SWITCH_1_1", 33, 33, maskGateOpenSwitch|34, false);

		CLOSE_GATE( 34 );
		CLOSE_GATE( 35 );
		CLOSE_GATE( 36 );

		CreateArtefacts("ARTIFACT_INVISIBLE", markerSword, markerSword, maskGateCloseSwitch|37, false);

		OPEN_GATE( 37 );

		CreateArtefacts("ARTIFACT_INVISIBLE", 18, 18, maskDetonator|19, false);

		CreateArtefacts("SWITCH_1_1", markerSwordGateSwitch, markerSwordGateSwitch, 0, false);

		return true;
	}

	function int InitializeTeleports()
	{
		SetupOneWayTeleportBetweenMarkers(90, 91);
		SetupOneWayTeleportBetweenMarkers(40, 42);
		SetupOneWayTeleportBetweenMarkers(42, 90);
		SetupOneWayTeleportBetweenMarkers(26, 91);

		return true;
	}

	int m_nChildsStep;
	int m_nBearsStep;
	int m_nShieldStep;
	int m_nCowsStep;
	int m_nHealStep;
	int m_nGateStep;

	unitex m_auChilds[];
	int    m_bChildsTalk;

	unitex m_auBears[];
	unitex m_auCows[];
	unitex m_auWalkers[];

	int m_bAutoSword;
	int m_bAutoShield;
	int m_bAutoHelmet;

	int m_nAutoArtifact;

	function int CheckArtefactsToFind(int nArtefactNum)
	{
		int i;

		int bResult;

		bResult = false;

		if ( m_anArtefactsIDsToFind.GetSize() == 0 )
		{
			return false;
		}

//		TraceD(m_anArtefactsIDsToFind.GetSize());
//		TraceD("->");

		for ( i=0; i<m_anArtefactsIDsToFind.GetSize(); ++i )
		{
			if ( nArtefactNum == m_anArtefactsIDsToFind[i] )
			{
				m_anArtefactsIDsToFind.RemoveAt(i);

				bResult = true;

				break;
			}
		}

		if ( nArtefactNum == idShield )
		{
			SetGoalState(goalFindShield, goalAchieved);

			if ( m_nShieldStep == 0 && m_nCowsStep > 3 )
			{
				STOP_TALK( ShieldInformator );
			}

			if ( m_nShieldStep == 1 )
			{
				RemoveWorldMapSignAtMarker(markerShield);
			}

			CLOSE_GATE( 99 );

			m_nShieldStep = 2;
			m_bAutoShield = false;
		}
		else if ( nArtefactNum == idSword )
		{
			SetGoalState(goalFindSword, goalAchieved);

			SetupOneWayTeleportBetweenMarkers(39, 41);

			CLOSE_GATE( 101 );
			OPEN_GATE( 102 );

			if ( m_nShieldStep == 0 )
			{
				START_TALK( ShieldInformator );
			}

			SetConsoleText("");
			
			++m_nCowsStep;

			m_bAutoSword = false;
		}
		else if ( nArtefactNum == idArmour )
		{
			SetGoalState(goalFindArmour, goalAchieved);

			START_TALK( BearsInformator  );

			SetConsoleText("translate1_00_Console_BeeKeeper");

			++m_nChildsStep;
		}
		else if ( nArtefactNum == idHelmet )
		{
			SetGoalState(goalFindHelmet, goalAchieved);

			START_TALK( Shepherd );

			SetConsoleText("translate1_00_Console_Cowherd");
			
			++m_nBearsStep;

			m_bAutoHelmet = false;
		}

//		TraceD(m_anArtefactsIDsToFind.GetSize());
//		TraceD("\n");

		if ( m_anArtefactsIDsToFind.GetSize() == 0 )
		{
			state FoundArtefacts;
		}

		return bResult;
	}

	function int InitializeChilds()
	{
		int i;

		m_auChilds.Create(0);

		for ( i=markerChildFirst; i<=markerChildLast; ++i )
		{
			m_auChilds.Add( CreateUnitAtMarker(m_pChilds, i, "SHEPHERD") );
		}

		m_bChildsTalk = true;

		return true;
	}

	function int InitializeBears()
	{
		int i;

		m_auBears.Create(0);

		for ( i=markerBearFirst; i<=markerBearLast; ++i )
		{
			if ( GetDifficultyLevel() == difficultyEasy )
			{
				m_auBears.Add( CreateUnitAtMarker(m_pAnimalsBis, i, "BLACKBEAR") );
			}
			else
			{
				m_auBears.Add( CreateUnitAtMarker(m_pAnimalsBis, i, "BEAR") );
			}
		}

		return true;
	}

	function int InitializeCows()
	{
		int i;
		unitex uCow;

		m_auCows.Create(0);

//		for ( i=markerCowFirst; i<=markerCowLast; ++i )
//		{
			uCow = CreateUnitAtMarker(m_pChilds, 60, "SPECIALCOW", 128);

			m_auCows.Add( uCow );

			uCow.CommandSetTalkMode(true, true, false);
			uCow.CommandStop();
			SetRealImmortal(uCow, true);
//		}
			uCow = CreateUnitAtMarker(m_pChilds, 61, "SPECIALCOW", 128+32);

			m_auCows.Add( uCow );

			uCow.CommandSetTalkMode(true, true, false);
			uCow.CommandStop();
			SetRealImmortal(uCow, true);

			uCow = CreateUnitAtMarker(m_pChilds, 62, "SPECIALCOW", 256-32);

			m_auCows.Add( uCow );

			uCow.CommandSetTalkMode(true, true, false);
			uCow.CommandStop();
			SetRealImmortal(uCow, true);

		return true;
	}

	function int InitializeWalkers()
	{
		int i;

		m_auWalkers.Create(0);

		for ( i=markerWalkerFirst; i<=markerWalkerLast; ++i )
		{
			m_auWalkers.Add( GetUnitAtMarker(i) );
		}

		m_bUpdateWalkers = true;

		return true;
	}

	function int UpdateChilds()
	{
		int i;
		unitex uTmp;

		for ( i=0; i<m_auChilds.GetSize(); ++i )
		{
			uTmp = m_auChilds[i];

			if ( IsUnitNearUnit(m_uChildsInformator, uTmp, rangeChildFollowHero) )
			{
				uTmp.ChangePlayer(m_pVillage);

				CommandMoveUnitToMarker(uTmp, markerChildsDestination);

				m_auChilds.RemoveAt(i);
			}
			else if ( IsUnitNearUnit(m_uHero, uTmp, rangeChildFollowHero) )
			{
				if ( m_bChildsTalk )
				{
					if ( IsUnitNearUnit(m_uHero, uTmp, 6) )
					{
						m_uChildTalk = uTmp;

						//if ( m_auChildsTalk[i] == 1 )
						//{
							m_nDialogToPlay = dialogChildFound1;

							RemoveWorldMapSignAtMarker(markerChildFirst);
						//}
						//else if ( m_auChildsTalk[i] == 2 )
						//{
						//	m_nDialogToPlay = dialogChildFound2;
						//}
						//else if ( m_auChildsTalk[i] == 3 )
						//{
						//	m_nDialogToPlay = dialogChildFound3;
						//}

						m_nStateAfterDialog = FindArtefacts;

						m_bChildsTalk = false;

						state StartPlayDialog;

						return true;
					}
				}
				else if ( ! IsUnitNearUnit(m_uHero, uTmp, 1) )
				{
					CommandMoveUnitToUnit(uTmp, m_uHero);
				}
			}
		}

		if ( m_auChilds.GetSize() == 0 )
		{
			START_TALK( ChildsInformator );

			++m_nChildsStep;
		}

		return true;
	}

	function int UpdateBears()
	{
		int i;
		unitex uTmp;

		for ( i=0; i<m_auBears.GetSize(); ++i )
		{
			uTmp = m_auBears[i];

			if ( 2 * uTmp.GetHP() < uTmp.GetMaxHP() )
			{
				CommandMoveUnitToMarker(uTmp, markerBearsDestination);

				m_auBears.RemoveAt(i);
			}
		}

		if ( m_auBears.GetSize() == 0 )
		{
			SetGoalState(goalBears, goalAchieved);

			RemoveWorldMapSignAtMarker(markerBearFirst);

			START_TALK( BearsInformator );

			SetConsoleText("translate1_00_Console_BearsDone");

			++m_nBearsStep;
		}

		return true;
	}

	state MoveShepherdToGateShitch
	{
		CommandMoveUnitToMarker(m_uShepherd, markerSwordGateSwitch);

		return FindArtefacts;
	}

	function int UpdateCows()
	{
		int i;
		unitex uTmp;

		for ( i=0; i<m_auCows.GetSize(); ++i )
		{
			uTmp = m_auCows[i];

			if ( IsUnitNearUnit(m_uObora, m_uShepherd, 10) )
			{
				uTmp.ChangePlayer(m_pVillage);

				uTmp.CommandSetTalkMode(false, true, false);

				uTmp.CommandEnter(m_uObora);

				m_auCows.RemoveAt(i);
			}
			else if ( ! IsUnitNearUnit(m_uShepherd, uTmp, 1) )
			{
				CommandMoveUnitToUnit(uTmp, m_uShepherd, 0, -2);
			}
		}

		if ( IsUnitNearUnit(m_uHero, m_uShepherd, 10) && !IsUnitNearUnit(m_uHero, m_uShepherd, 1) )
		{
			if ( m_pAnimalsBis.GetNumberOfUnits(m_uHero.GetLocationX(), m_uHero.GetLocationY(), m_uHero.GetLocationZ(), rangeNear) == 0 )
			{
				CommandMoveUnitToUnit(m_uShepherd, m_uHero, -3, 0);
			}
		}

		if ( m_auCows.GetSize() == 0 )
		{
			RemoveWorldMapSignAtMarker(markerObora);

//			ADD_BRIEFING( CowsDone );

//			CommandMoveUnitToMarker(m_uShepherd, markerSwordGateSwitch);

			++m_nCowsStep;

			START_TALK( Shepherd );
		}

		return true;
	}

	function int UpdateWalkers()
	{
		int i;
		unitex uTmp;

		int x, y, z;

		ASSERT(m_auWalkers.GetSize() > 0);

		i = RAND(m_auWalkers.GetSize());

		// for ( i=0; i<m_auWalkers.GetSize(); ++i )
		// {
			uTmp = m_auWalkers[i];

			x = uTmp.GetLocationX();
			y = uTmp.GetLocationY();
			z = uTmp.GetLocationZ();

			x = x + (Rand(13)-6);
			y = y + (Rand(13)-6);

			if ( x < GetPointX(markerVillageLimiterFrom) ) x = GetPointX(markerVillageLimiterFrom);
			if ( y < GetPointY(markerVillageLimiterFrom) ) y = GetPointY(markerVillageLimiterFrom);
			if ( x > GetPointX(markerVillageLimiterTo) ) x = GetPointX(markerVillageLimiterTo);
			if ( y > GetPointY(markerVillageLimiterTo) ) y = GetPointY(markerVillageLimiterTo);

			uTmp.CommandMove(x, y, z);
		// }

		return true;
	}

	function int CheckInformators()
	{
		if ( IsUnitNearUnit(m_uHero, m_uChildsInformator, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nChildsStep == 0 )
			{
//				ADD_BRIEFING( ChildsInfo );

				STOP_TALK( ChildsInformator );

				InitializeChilds();

				++m_nChildsStep;

				m_nDialogToPlay = dialogChildsInfo;
				m_nStateAfterDialog = FindArtefacts;

				RemoveWorldMapSignAtMarker(markerChildsInformator);

				state StartPlayDialog;
			}
			else if ( m_nChildsStep == 2 )
			{
//				ADD_BRIEFING( ChildsDone );

				STOP_TALK( ChildsInformator );

//				if ( m_uChilsInformator.FindFreePointInTargetNeighbourhood(m_uChilsInformator) )
//				{
//					CreateArtefact("ART_ARMOUR2",           GetFoundFreePointInTargetNeighbourhoodX(), GetFoundFreePointInTargetNeighbourhoodY(), GetFoundFreePointInTargetNeighbourhoodZ(), idArmour);
//					CreateArtefact("ARTIFACT_STARTMISSION", GetFoundFreePointInTargetNeighbourhoodX(), GetFoundFreePointInTargetNeighbourhoodY(), GetFoundFreePointInTargetNeighbourhoodZ(), idArmour);
//				}

				++m_nChildsStep;

				m_nDialogToPlay = dialogChildsDone;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uBearsInformator, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nBearsStep == 0 && m_nChildsStep > 3 )
			{
//				ADD_BRIEFING( BearsInfo );

				STOP_TALK( BearsInformator );

				InitializeBears();

				++m_nBearsStep;

				m_nDialogToPlay = dialogBearsInfo;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
			else if ( m_nBearsStep == 2 )
			{
//				ADD_BRIEFING( BearsDone );

				STOP_TALK( BearsInformator );

//				if ( m_uBearsInformator.FindFreePointInTargetNeighbourhood(m_uBearsInformator) )
//				{
//					CreateArtefact("ART_HELME2",            GetFoundFreePointInTargetNeighbourhoodX(), GetFoundFreePointInTargetNeighbourhoodY(), GetFoundFreePointInTargetNeighbourhoodZ(), idHelmet);
//					CreateArtefact("ARTIFACT_STARTMISSION", GetFoundFreePointInTargetNeighbourhoodX(), GetFoundFreePointInTargetNeighbourhoodY(), GetFoundFreePointInTargetNeighbourhoodZ(), idHelmet);
//				}

				++m_nBearsStep;

				m_nDialogToPlay = dialogBearsDone;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uShieldInformator, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nShieldStep == 0 && m_nCowsStep > 3 )
			{
//				ADD_BRIEFING( ShieldInfo );

				STOP_TALK( ShieldInformator );

				++m_nShieldStep;

				m_nDialogToPlay = dialogShieldInfo;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uHealInformator, rangeTalk+1) && ! m_uHero.IsMoving() )
		{
			if ( m_nHealStep == 0 )
			{
//				ADD_BRIEFING( HealInfo );

				STOP_TALK( HealInformator );

				++m_nHealStep;

				m_nDialogToPlay = dialogHealInfo;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
		}
		else if ( IsUnitNearUnit(m_uHero, m_uShepherd, rangeTalk) && ! m_uHero.IsMoving() )
		{
			if ( m_nCowsStep == 0 && m_nBearsStep > 3 )
			{
				AddWorldMapSignAtMarker(markerObora, 0, -1);

				SetAlly(m_pPlayer, m_pChilds);

//				ADD_BRIEFING( CowsInfo );

				STOP_TALK( Shepherd );

				SetConsoleText("translate1_00_Console_Cows");

				OPEN_GATE( 14 );

				++m_nCowsStep;

				m_nDialogToPlay = dialogCowsInfo;
				m_nStateAfterDialog = FindArtefacts;

				state StartPlayDialog;
			}
			else if ( m_nCowsStep == 2 )
			{
				STOP_TALK( Shepherd );

				++m_nCowsStep;

				m_nDialogToPlay = dialogCowsDone;
				m_nStateAfterDialog = MoveShepherdToGateShitch;

				state StartPlayDialog;
			}
		}

		return true;
	}

	
	int m_nGate;

	/* BUGFIX 1844
	function int UpdateGates()
	{
		unitex uTmp;

		uTmp = GetUnitAtMarker(28 + m_nGate);
		uTmp.CommandBuildingSetGateMode(modeGateClosed);

		m_nGate = (m_nGate+1) % 3;

		uTmp = GetUnitAtMarker(28 + m_nGate);
		uTmp.CommandBuildingSetGateMode(modeGateOpened);

		/////

		return true;
	}
	/**/

	int m_nHeroGx, m_nHeroGy;

	function int UpdateCamera()
	{
		int nHeroNewGx, nHeroNewGy;

		nHeroNewGx = m_uHero.GetLocationX();
		nHeroNewGy = m_uHero.GetLocationY();

		if ( Distance(m_nHeroGx, m_nHeroGy, nHeroNewGx, nHeroNewGy) > 10 && !m_pPlayer.IsCameraFollowingObject(m_uHero) )
		{
			PlayerLookAtUnit(m_pPlayer, m_uHero, -1, -1, -1);
		}

		m_nHeroGx = nHeroNewGx;
		m_nHeroGy = nHeroNewGy;

		if ( state != MoveHero )
		{
			m_pPlayer.SelectUnit(m_uHero, false);
		}

		return true;
	}

	int m_anMarkersAutoArtifact[];

	function int InitializeAutoArtifacts()
	{
		int i;

		m_anMarkersAutoArtifact.Create(0);

		for ( i=markerAutoArtifactFirst; i<=markerAutoArtifactLast; ++i )
		{
			m_anMarkersAutoArtifact.Add( i );
		}

		return true;
	}

#define AUTO_ARTIFACTS_CREATE_BLOCK(ArtifactStep, ArtifactType, ArtifactName) \
	if ( m_nAutoArtifact == ArtifactStep ) \
	{ \
		if ( m_bAuto ## ArtifactType ) \
		{ \
			CreateArtefactAtMarker(ArtifactName, m_anMarkersAutoArtifact[i], 0); \
		} \
		else \
		{ \
			++m_nAutoArtifact; \
		} \
	}
	
	function int UpdateAutoArtifacts()
	{
		int i;

		for ( i=0; i<m_anMarkersAutoArtifact.GetSize(); ++i )
		{
			if ( IsUnitNearMarker(m_uHero, m_anMarkersAutoArtifact[i], rangeAutoArtifactsCreate) )
			{
				++m_nAutoArtifact;

				AUTO_ARTIFACTS_CREATE_BLOCK(1, Sword , "ART_SWORD1A" )
				AUTO_ARTIFACTS_CREATE_BLOCK(2, Shield, "ART_SHIELD1B")
				AUTO_ARTIFACTS_CREATE_BLOCK(3, Helmet, "ART_HELMET1A")
				AUTO_ARTIFACTS_CREATE_BLOCK(4, Sword , "ART_AXE2"    )
				AUTO_ARTIFACTS_CREATE_BLOCK(5, Shield, "ART_SHIELD2" )
				AUTO_ARTIFACTS_CREATE_BLOCK(6, Shield, "ART_SHIELD2B")

				m_anMarkersAutoArtifact.RemoveAt(i);
			}
		}

		return true;
	}

	int m_bShowedTunnelsInfo;

	event Timer0()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		if ( m_nChildsStep == 1 )
		{
			UpdateChilds();
		}

		if ( m_nBearsStep == 1 )
		{
			UpdateBears();
		}

		if ( m_nCowsStep == 1 )
		{
			UpdateCows();
		}

		if ( !m_bShowedTunnelsInfo && m_uHero.GetLocationZ() == 1 )
		{
			SetConsoleText("translate1_00_Console_TunnelsInfo");

			if ( GetCameraZLayer() == m_uHero.GetLocationZ() )
			{
			
			    SetConsoleText("");
				
			    if(m_nShieldStep == 2)
				{
				SetConsoleText("translate1_00_Console_EndMission");
                }

                
				m_bShowedTunnelsInfo = true;
			}
		}

		if ( m_bShowedTunnelsInfo )
		{
			if ( GetCameraZLayer() == 1 && m_uHero.GetLocationZ() == 0 )
			{
				//SetConsoleText("translate1_00_Console_TunnelsInfoUp");
				
			}
			else if ( GetCameraZLayer() == 0 && m_uHero.GetLocationZ() == 1 )
			{
				//SetConsoleText("translate1_00_Console_TunnelsInfoDown");
				
			}
			else
			{
			    //SetConsoleText("");
				
				if(m_nShieldStep == 2)
				{
				SetConsoleText("translate1_00_Console_EndMission");
                }
			}
		}
	}

	event Timer1()
	{
		int i;
		unitex uTmp;

		if ( m_bPlayingDialog )
		{
			return;
		}

		m_pVillage.SetMoney(0);

		m_uChildsInformator.RegenerateHP();
		m_uBearsInformator.RegenerateHP();
		m_uShieldInformator.RegenerateHP();
		m_uHealInformator.RegenerateHP();

		m_uShepherd.RegenerateHP();

		for ( i=0; i<m_auCows.GetSize(); ++i )
		{
			uTmp = m_auCows[i];

			uTmp.RegenerateHP();
		}
	}

	event Timer2()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}
	}

	event Timer3()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		if ( m_bUpdateWalkers )
		{
			UpdateWalkers();
		}

		UpdateCamera();

		UpdateAutoArtifacts();

		if ( GetUnitAtMarker(markerSwordGateSwitch) != null || m_nCowsStep > 2 )
		{
			m_uSwordGate.CommandBuildingSetGateMode(modeGateOpened);

			if ( m_nCowsStep > 2 && GetUnitAtMarker(markerSwordGateSwitch) != m_uShepherd && !m_uShepherd.IsMoving() ) // BUGFIX 1697
			{
				CommandMoveUnitToMarker(m_uShepherd, markerSwordGateSwitch);
			}
		}
		else
		{
			m_uSwordGate.CommandBuildingSetGateMode(modeGateClosed);
		}

		if ( m_bCheckInformators )
		{
			CheckInformators();
		}
	}

	/* BUGFIX 1844
	event Timer4()
	{
		if ( m_bPlayingDialog )
		{
			return;
		}

		UpdateGates();
	}
	*/

	function int MissionFailed()
	{
		if ( state == MissionFail )
		{
			return false;
		}

//		ADD_BRIEFING( MissionFail );

		PlayTrack("Music\\RPGdefeat.tws");

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

	state Initialize
	{
		TurnOffTier5Items();
		
		ModifyDifficulty();

		InitializePlayers();
		InitializeUnits();
		InitializeArtefacts();
		InitializeGateSwitches();
		InitializeTeleports();
		InitializeCows();
		InitializeWalkers();
		InitializeAutoArtifacts();

		SetAllBridgesImmortal(true);

		CLOSE_GATE(  14 );
		CLOSE_GATE(  99 );
		CLOSE_GATE( 100 );
		CLOSE_GATE( 101 );
		CLOSE_GATE( 104 );

		OPEN_GATE( 102 );

		RegisterGoals();

//		m_uStartGate.CommandBuildingSetGateMode(modeGateClosed);
//		m_uWolfGate.CommandBuildingSetGateMode(modeGateClosed);
//		m_uCastleGate.CommandBuildingSetGateMode(modeGateClosed);

		m_nChildsStep = 0;
		m_nBearsStep  = 0;
		m_nShieldStep = 0;
		m_nCowsStep   = 0;
		m_nHealStep   = 0;
		m_nGateStep   = 0;

		m_nGate       = 0;

		m_bAutoSword  = true;
		m_bAutoShield = true;
		m_bAutoHelmet = true;

		m_nAutoArtifact = 0;

		m_bClearConsoleOnUnitDestroyed = false;

		m_bPlayingDialog = false;

		SetGameRect(GetPointX(2), GetPointY(2),
			        GetPointX(3), GetPointY(3));

		ShowAreaAtMarker(m_pPlayer, markerHeroStart, rangeShowArea);
		ShowAreaAtMarker(m_pPlayer, 106, 20);
		ShowAreaAtMarker(m_pPlayer, 107, 20);
		ShowAreaAtMarker(m_pPlayer, 108, 20);
		ShowAreaAtMarker(m_pPlayer, 109, 20);

		EnableAssistant(0xffffff, false);
		EnableAssistant(assistAttackedHoldPosition, true);

		EnableInterface(false);
		EnableCameraMovement(false);

		m_pPlayer.LookAt(GetLeft()+190, GetTop()+27, 12, 61, 59, 0);

		ShowInterfaceBlackBorders(true, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_SIZE, INTERFACE_BORDERS_COLOR, INTERFACE_BORDERS_COLOR, 0, 0);

		SetTime(40);

		SetTimer(7, GetWindTimerTicks());
		StartWind();

		SaveGameRestart(null);

		PlayTrack("Music\\RPGday01.tws");

        CacheWave("Special\\SND_SUMMONING_PRINCE_HIT.wav");
		CacheObject(null, "SUMMONING_PRIEST");
		CacheObject(null, "SUMMONING_PRINCE");
        CacheObject(null, "PENTAGRAM_BIG");
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

		return Start0, 1;
	}

	state Start0
	{
		SetCutsceneText("translate1_00_Cutscene_Start");

		m_pPlayer.DelayedLookAt(GetLeft()+191, GetTop()+29, 12, 58, 59, 0, 150, false);

		return Start, 150;
	}


/*
	state Start
	{
		EnableGoal(goalMoveHero, true);

		ADD_BRIEFING( MoveHero );

		return MoveHero;
	}
*/

	state StartPlayDialog
	{
		if ( m_nDialogToPlay == dialogMoveHero )
		{
			#define NO_PREPARE_INTERFACE_TO_TALK

			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MoveHero
			#define DIALOG_LENGHT  9

			#include "..\..\TalkBis.ech"

			m_nGameCameraZ = constLookAtHeight;
			m_nGameCameraAlpha = constLookAtAlpha;
			m_nGameCameraView = constLookAtView;

			return PlayDialog, 1;
		}
		else if ( m_nDialogToPlay == dialogFindWeapon )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindWeapon
			#define DIALOG_LENGHT  3

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogKillWolf )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    KillWolf
			#define DIALOG_LENGHT  1

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogHealHero )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    HealHero
			#define DIALOG_LENGHT  6

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogFindCrew )
		{
			#define UNIT_NAME_FROM Priest
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    FindCrew
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogChildsInfo )
		{
			#define UNIT_NAME_FROM ChildsInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ChildsInfo
			#define DIALOG_LENGHT  7

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogChildsDone )
		{
			#define UNIT_NAME_FROM ChildsInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ChildsDone
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogBearsInfo )
		{
			#define UNIT_NAME_FROM BearsInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BearsInfo
			#define DIALOG_LENGHT  5

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogBearsDone )
		{
			#define UNIT_NAME_FROM BearsInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    BearsDone
			#define DIALOG_LENGHT  3

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogCowsInfo )
		{
			#define UNIT_NAME_FROM Shepherd
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    CowsInfo
			#define DIALOG_LENGHT  6

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogCowsDone )
		{
			#define UNIT_NAME_FROM Shepherd
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    CowsDone
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogCowsGateOpened )
		{
			#define UNIT_NAME_FROM Shepherd
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    CowsGateOpened
			#define DIALOG_LENGHT  1

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogHealInfo )
		{
			#define UNIT_NAME_FROM HealInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    HealInfo
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogShieldInfo )
		{
			#define UNIT_NAME_FROM ShieldInformator
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    ShieldInfo
			#define DIALOG_LENGHT  4

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogTunnelsInfo )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    TunnelsInfo
			#define DIALOG_LENGHT  1

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogGateInfo )
		{
			#define UNIT_NAME_FROM CrewGateKeeper
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    GateInfo
			#define DIALOG_LENGHT  9

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogMissionComplete )
		{
			#define UNIT_NAME_FROM CrewGateKeeper
			#define UNIT_NAME_TO   Hero
			#define DIALOG_NAME    MissionComplete
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
		else if ( m_nDialogToPlay == dialogChildFound1 )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   ChildTalk
			#define DIALOG_NAME    ChildFound1
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogChildFound2 )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   ChildTalk
			#define DIALOG_NAME    ChildFound2
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"
		}
		else if ( m_nDialogToPlay == dialogChildFound3 )
		{
			#define UNIT_NAME_FROM Hero
			#define UNIT_NAME_TO   ChildTalk
			#define DIALOG_NAME    ChildFound3
			#define DIALOG_LENGHT  2

			#include "..\..\TalkBis.ech"
		}
		
		return WaitForEndPrepareInterfaceToTalk, 1;
    }

	state EndPlayDialog
	{
		RestoreTalkInterface(m_pPlayer, m_uHero);

		if ( m_nDialogToPlay == dialogMoveHero )
		{
//			EnableGoal(goalMoveHero, true);

			ZoomInMap(2);

			SetConsoleText("translate1_00_Console_Move");
		}
		if ( m_nDialogToPlay == dialogFindWeapon )
		{
//			SetGoalState(goalMoveHero, goalAchieved);
//			EnableGoal(goalFindWeapon, true);

			SetConsoleText("translate1_00_Console_FindWeapon");
		}
		else if ( m_nDialogToPlay == dialogKillWolf )
		{
//			SetGoalState(goalFindWeapon, goalAchieved);
//			EnableGoal(goalKillWolf, true);

			m_uWolf1 = CreateUnitAtMarker(m_pAnimalsBis, markerWolf1, "MAGICWOLF2", 192);
			m_uWolf2 = CreateUnitAtMarker(m_pAnimalsBis, markerWolf2, "MAGICWOLF2", 192);

//			m_uWolf1.CommandSetMovementMode(modeHoldPos);
//			m_uWolf2.CommandSetMovementMode(modeHoldPos);

			CreateObjectAtUnit(m_uWolf1, "HIT_TELEPORT");
			CreateObjectAtUnit(m_uWolf2, "HIT_TELEPORT");

			m_uWolf1.SetExperienceLevel(1);
			m_uWolf2.SetExperienceLevel(1);

			SetConsoleText("translate1_00_Console_Enemy");

			CommandMoveUnitToMarker(m_uPriest, 98);
		}
		else if ( m_nDialogToPlay == dialogHealHero )
		{
//			SetGoalState(goalKillWolf, goalAchieved);
//			EnableGoal(goalHealHero, true);

			SetConsoleText("translate1_00_Console_Sleep");
		}
		else if ( m_nDialogToPlay == dialogFindCrew )
		{
//			SetGoalState(goalHealHero, goalAchieved);
			EnableGoal(goalFindCrew, true);

//			EnableGoal(goalMoveHero, false);
//			EnableGoal(goalFindWeapon, false);
//			EnableGoal(goalKillWolf, false);
//			EnableGoal(goalHealHero, false);

			SetConsoleText("translate1_00_Console_FindCrew");

			m_bClearConsoleOnUnitDestroyed = false; // nie ma byc wylaczane
		}
		else if ( m_nDialogToPlay == dialogChildsDone )
		{
			SetGoalState(goalChilds, goalAchieved);

			CreateArtefacts("ART_ARMOUR2B",       markerArmour, markerArmour, 0       , false);
			CreateArtefacts("ARTIFACT_INVISIBLE", markerArmour, markerArmour, idArmour, false);

			CLOSE_GATE( 100 );
		}
		else if ( m_nDialogToPlay == dialogBearsDone )
		{
			CreateArtefacts("ART_HELMET2B",       markerHelmet, markerHelmet, 0       , false);
			CreateArtefacts("ARTIFACT_INVISIBLE", markerHelmet, markerHelmet, idHelmet, false);
		}
		else if ( m_nDialogToPlay == dialogChildsInfo )
		{
			EnableGoal(goalChilds, true);

			AddWorldMapSignAtMarker(markerChildFirst, 0, -1);

			OPEN_GATE( 100 );
			CLOSE_GATE( 102 );

			SetConsoleText("translate1_00_Console_FindChild");
		}
		else if ( m_nDialogToPlay == dialogBearsInfo )
		{
			EnableGoal(goalChilds, false);
			EnableGoal(goalFindCrew, false);

			EnableGoal(goalBears, true);

			AddWorldMapSignAtMarker(markerBearFirst, 1, -1);

			SetConsoleText("translate1_00_Console_Bears");

			OPEN_GATE( 101 );
		}
		else if ( m_nDialogToPlay == dialogShieldInfo )
		{
			EnableGoal(goalCows, false);

			EnableGoal(goalFindShield, true);

			AddWorldMapSignAtMarker(markerShield, 0, -1);

			SetConsoleText("translate1_00_Console_Shield");
			
			OPEN_GATE( 99 );
			CLOSE_GATE( 102 );
		}
		else if ( m_nDialogToPlay == dialogCowsInfo )
		{
			EnableGoal(goalBears, false);

			EnableGoal(goalCows, true);
		}
		else if ( m_nDialogToPlay == dialogCowsDone )
		{
			SetGoalState(goalCows, goalAchieved);

			SetConsoleText("translate1_00_Console_Sword");
		}
		else if ( m_nDialogToPlay == dialogGateInfo )
		{
			EnableGoal(goalFindArmour, true);
			EnableGoal(goalFindHelmet, true);
			EnableGoal(goalFindShield, true);
			EnableGoal(goalFindSword,  true);

			SetGoalState(goalFindCrew, goalAchieved);
			EnableGoal(goalFindEquipment, true);

			SetConsoleText("translate1_00_Console_FindVillage");

			AddWorldMapSignAtMarker(markerChildsInformator, 0, -1);
		}
		else if ( m_nDialogToPlay == dialogChildFound1 )
		{
			SetConsoleText("translate1_00_Console_BackChild");
		}

		return WaitForEndPrepareInterfaceToTalk, 1;
	}

    state RestoreGameState
	{
		END_TALK_DEFINITION();
		
		if ( m_nDialogToPlay == dialogMoveHero )
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
				lockDisplayToolbarLevelName |
				lockCreateBuildPanel |
	//			lockCreatePanel |
	//			lockCreateMap |
				0);
		}
		SAFE_REMOVE_PRIEST();

		if ( m_nDialogToPlay == dialogMoveHero )
		{
			SetTimer(0, 60);
			SetTimer(1, 100);
			SetTimer(2, 200);
			SetTimer(3, 10);
			// SetTimer(4, 150); BUGFIX 1844
		}

		BEGIN_RESTORE_STATE_BLOCK()
			RESTORE_STATE(MoveHero)
			RESTORE_STATE(FindWeapon)
			RESTORE_STATE(KillWolf)
			RESTORE_STATE(HealHero)
			RESTORE_STATE(FindArtefacts)
			RESTORE_STATE(WaitForMissionComplete)
			RESTORE_STATE(MissionFail)
			RESTORE_STATE(MoveShepherdToGateShitch)
		END_RESTORE_STATE_BLOCK()
	}

	state Start
	{
		int x, y;

		m_pPlayer.SetNeutral(m_pAnimalsBis);

		m_uPriest.CommandMakeCustomAnimation(2, true, false, 6, 0, 0);

		x = 128+( GetCameraX()*256 + m_uPriest.GetLocationX()*256 ) / 2;
		y = GetCameraY()*256 - 128;

		SetLowConsoleText("");

		PlayerLookAtMarker(m_pPlayer, markerHeroStart, constLookAtHeight, constLookAtAlpha, constLookAtView);
		m_pPlayer.DelayedLookAt(x, y, DEFAULT_LOOKAT_Z+1, 0, DEFAULT_LOOKAT_VIEW, 0, 245, false);

		return Start1, 40;
	}

	unitex m_uObj1;
	unitex m_uObj2;

	state Start1
	{
		m_uObj1 = CreateObjectAtUnit(m_uPriest, "SUMMONING_PRIEST");

		return Start2, 20;
	}

	state Start2
	{
		m_uObj2 = CreateObjectAtMarker(markerHeroStart, "SUMMONING_PRINCE");

		return Start2b, 60;
	}

	state Start2b
	{
		PlayWave("Special\\SND_SUMMONING_PRINCE_HIT.wav");

		return Start3, 20;
	}

	state Start3
	{
		if ( GetDifficultyLevel() == difficultyEasy )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_EASY", 0x40);
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO", 0x40);
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_HARD", 0x40);
		}

		m_uHero.SetIsHeroUnit(true);
        m_uHero.SetIsSingleUnit(true);

		m_bCheckHero = true;

		return Start4, 16;
	}

	state Start4
	{
		Rain(190, 27, 128, 200, 6000, 200, 5);

		CreateObjectAtMarker(markerHeroStart, "PENTAGRAM_BIG");

		m_nDialogToPlay = dialogMoveHero;
		m_nStateAfterDialog = MoveHero;

		return StartPlayDialog, 84;
	}

	state MoveHero
	{
		if ( ! IsUnitNearMarker(m_uHero, markerHeroStart, rangeHeroMove) /*&& ! m_uHero.IsMoving()*/ )
		{
			return MovedHero, 60;
		}
		else
		{
			return MoveHero;
		}
	}

	state MovedHero
	{
//		ADD_BRIEFING( FindWeapon );

		SetConsoleText("");

//		m_uStartGate.CommandBuildingSetGateMode(modeGateOpened);

//		PlayerLookAtUnit(m_pPlayer, m_uStartGate, constLookAtHeight, constLookAtAlpha, constLookAtView);

		SetGameRect(GetPointX(96), GetPointY(96),
			        GetPointX( 3), GetPointY( 3));

		m_nDialogToPlay = dialogFindWeapon;
		m_nStateAfterDialog = FindWeapon;

		return StartPlayDialog, 0;
//		return FindWeapon;
	}

	state FindWeapon
	{
		return FindWeapon;
	}

	state FoundWeapon
	{
		// SetConsoleText("translate1_00_Console_FindPriest");

		SetGameRect(GetPointX(96), GetPointY(96),
			        GetPointX(97), GetPointY(97));

		m_bRemovePriest = true;

		SAFE_REMOVE_PRIEST();

		m_uPriest = CreateUnitAtMarker(m_pPriest, markerPriestBis, PRIEST_UNIT);
		CreateObjectAtUnit(m_uPriest, "HIT_TELEPORT");

		m_bRemovePriest = false;

//		START_TALK( Priest );

		return FoundPriest;
	}

	state FindPriest
	{
		if ( IsUnitNearUnit(m_uHero, m_uPriest, rangeTalk) /*&& ! m_uHero.IsMoving()*/ )
		{
			return FoundPriest, 0;
		}
		else
		{
			return FindPriest;
		}
	}

	state FoundPriest
	{
//		ADD_BRIEFING( KillWolf );

//		STOP_TALK( Priest );

//		m_uWolfGate.CommandBuildingSetGateMode(modeGateOpened);
//		m_uStartGate.CommandBuildingSetGateMode(modeGateClosed);

//		PlayerLookAtUnit(m_pPlayer, m_uWolfGate, constLookAtHeight, constLookAtAlpha, constLookAtView);

		m_nDialogToPlay = dialogKillWolf;
		m_nStateAfterDialog = KillWolf;

		m_uHero.CommandSetMovementMode(modeHoldPos);

		return StartPlayDialog, 0;
//		return KillWolf;
	}

	state KillWolf2
	{
		if ( !m_uWolf1.IsLive() && !m_uWolf2.IsLive() && ! m_uHero.IsMoving() )
		{
			return KilledWolf, 0;
		}
		else
		{
			return KillWolf2;
		}
	}

	state KillWolf
	{
//		m_uWolfGate.CommandBuildingSetGateMode(modeGateOpened);

		m_pPlayer.SetEnemy(m_pAnimalsBis);

		return KillWolf2;
	}

	state KilledWolf
	{
		SetConsoleText("");

//		m_pPlayer.IgnoreNotifyAttackUnit("BROWNWOLF", true);
//		m_pPlayer.IgnoreNotifyAttackUnit("WOLF", true);
//		m_pPlayer.IgnoreNotifyAttackUnit("WHITEWOLF", true);

//		ADD_BRIEFING( HealHero );

		m_uHero.CommandSetMovementMode(modeMove);

		if ( m_uHero.GetHP()*10 > m_uHero.GetMaxHP()*8 )
		{
			m_uHero.DamageUnit(15);
		}

		m_nDialogToPlay = dialogHealHero;
		m_nStateAfterDialog = HealHero;

		return StartPlayDialog, 0;
//		return HealHero;
	}

	state HealHero
	{
		if ( m_uHero.IsInSleepMode() )
		{
			m_uHero.AddHPRegenerationSpeed(25, true);

			return HeroSleeping;
		}
		else
		{
			m_uHero.DamageUnit(1);

			return HealHero, 40;
		}
	}

	state HeroSleeping
	{
		if ( m_uHero.GetHP() == m_uHero.GetMaxHP() && ! m_uHero.IsMoving() && ! m_uHero.IsInSleepMode() )
		{
			m_uHero.AddHPRegenerationSpeed(25, false);

			return HealedHero, 0;
		}
		else
		{
			return HeroSleeping;
		}
	}

	state HealedHero
	{
		SetGameRect(0,0,0,0);

		SetConsoleText("");

		//		ADD_BRIEFING( FindCrew );

//		ShowArea(m_pPlayer.GetIFF(), m_uCastleGate.GetLocationX(), m_uCastleGate.GetLocationY(), m_uCastleGate.GetLocationZ(), rangeShowArea, showAreaPassives|showAreaBuildings);

//		m_uCastleGate.CommandBuildingSetGateMode(modeGateOpened);
//		m_uStartGate.CommandBuildingSetGateMode(modeGateOpened);

//		PlayerLookAtUnit(m_pPlayer, m_uCastleGate, constLookAtHeight, constLookAtAlpha, constLookAtView);

		m_bRemovePriest = true;

		m_nDialogToPlay = dialogFindCrew;
		m_nStateAfterDialog = FindArtefacts;

		return StartPlayDialog, 0;
//		return FindArtefacts;
	}

	state FindArtefacts
	{
		if ( IsUnitNearUnit(m_uHero, m_uCrewGate, rangeNear) /*&& ! m_uHero.IsMoving()*/ )
		{
			if ( m_nGateStep == 0 )
			{
				SetupOneWayTeleportBetweenMarkers(91, 40);
				OPEN_GATE( 102 );

//				ADD_BRIEFING( GateInfo );

				++m_nGateStep;

				m_nDialogToPlay = dialogGateInfo;
				m_nStateAfterDialog = FindArtefacts;

				return StartPlayDialog;
			}
		}
		else if ( m_nGateStep == 0 && IsUnitNearMarker(m_uHero, 90, 6) )
		{
			SetConsoleText("translate1_00_Console_Teleport");
		}

		return FindArtefacts;
	}

	state FoundArtefacts
	{
		START_TALK( CrewGateKeeper );

		SetConsoleText("translate1_00_Console_EndMission");

		CreateUnits(m_pAnimalsBis, 92, 93, "WHITEWOLF");
		CreateUnits(m_pAnimalsBis, 94, 94, "BROWNWOLF");
		CreateUnits(m_pAnimalsBis, 95, 95, "BLACKBEAR");

		return FindCrew;
	}

	state FindCrew
	{
		if ( IsUnitNearUnit(m_uHero, m_uCrewGate, rangeNear) /*&& ! m_uHero.IsMoving()*/ )
		{
			STOP_TALK( CrewGateKeeper );

			return FoundCrew, 0;
		}

		return FindCrew;
	}

	state FoundCrew
	{
		m_uCrewGate.CommandBuildingSetGateMode(modeGateOpened);

		CommandMovePlatoonToUnit(m_pCrew, m_uHero);

//		ADD_BRIEFING( MissionComplete );

		SetConsoleText("");
			
		m_nDialogToPlay = dialogMissionComplete;
		m_nStateAfterDialog = WaitForMissionComplete;

		PlayTrack("Music\\RPGvictory.tws");

		return StartPlayDialog, 0;
//		return WaitForMissionComplete;
	}

	state WaitForMissionComplete
	{
		EnableInterface(false);

		return MissionComplete, 200;
	}

	state MissionComplete
	{
		m_bCheckHero = false;
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);

		EnableInterface(true);

		m_pPlayer.EnableCommand(commandDropEquipment, true);

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
		
		int nFromGx, nFromGy, nToGx, nToGy;
		int nRange, nRange2;

		if ( uUnitOnArtefact == m_uHero )
		{
			if ( nArtefactNum == idWeapon )
			{
				state FoundWeapon;

				return true;
			}
			else if ( CheckArtefactsToFind(nArtefactNum) )
			{
				return true;
			}
			else if ( nArtefactNum & maskGateOpenSwitch )
			{
				nMarker = nArtefactNum & ~maskGateOpenSwitch;

				uTmp = GetUnitAtMarker( nMarker );

				if ( nMarker == 24 )
				{
					if ( m_nShieldStep < 2 )
					{
						return false;
					}

					uTmp.ChangePlayer(m_pFriend);
				}

				uTmp.CommandBuildingSetGateMode(modeGateOpened);

				CreateArtefactAtUnit("SWITCH_1_2", uUnitOnArtefact, 0);

				return true;
			}
			else if ( nArtefactNum & maskGateCloseSwitch )
			{
				nMarker = nArtefactNum & ~maskGateCloseSwitch;

				uTmp = GetUnitAtMarker( nMarker );

				uTmp.CommandBuildingSetGateMode(modeGateClosed);

				if ( nMarker != 37 )
				{
					CreateArtefactAtUnit("SWITCH_1_1", uUnitOnArtefact, 0);
				}

				return true;
			}
			else if ( nArtefactNum & maskDetonator )
			{
				nMarker = ~maskDetonator & nArtefactNum;

				nFromGx = GetPointX(nMarker);
				nFromGy = GetPointY(nMarker);

				nToGx = GetPointX(nMarker+1);
				nToGy = GetPointY(nMarker+1);

				nRange = (nToGx-nFromGx)/2;
				nRange2 = (nToGy-nFromGy)/2;

				if ( nRange2 > nRange ) nRange = nRange2;

				KillArea(65535, (nFromGx+nToGx)/2, (nFromGy+nToGy)/2, 0, nRange);

				return true;
			}

			return false;
		}

		return false;
	}

	event UnitDestroyed(unitex uUnit)
	{
		unit uTmp;

		if ( m_bClearConsoleOnUnitDestroyed )
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetConsoleText("");

				m_bClearConsoleOnUnitDestroyed = false;
			}
		}

		if ( uUnit.GetIFF() == m_pVillage.GetIFF() || uUnit.GetIFF() == m_pChilds.GetIFF() ) 
		{
			uTmp = uUnit.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetEnemies(m_pPlayer, m_pVillage);

				m_bUpdateWalkers = false;
				m_bCheckInformators = false;

				m_uChildsInformator.CommandAttack(m_uHero);
				m_uBearsInformator.CommandAttack(m_uHero);
				m_uShieldInformator.CommandAttack(m_uHero);
				m_uHealInformator.CommandAttack(m_uHero);
				m_uShepherd.CommandAttack(m_uHero);

				STOP_TALK( ChildsInformator );
				STOP_TALK( BearsInformator );
				STOP_TALK( ShieldInformator );
				STOP_TALK( HealInformator );
				STOP_TALK( Shepherd );
			}
		}

		if ( m_bCheckHero && uUnit == m_uHero )
		{
			SetGoalState(goalHeroSurvive, goalFailed);

			MissionFailed();
//			state MissionFail;
		}
/*
		else if ( uUnit == m_uPriest )
		{
			SetGoalState(goalHeroSurvive, goalFailed);

			MissionFailed();
//			state MissionFail;
		}
*/
	}

	event BuildingDestroyed(unitex uBuilding)
	{
		unit uTmp;

		if ( uBuilding.GetIFF() == m_pVillage.GetIFF() ) 
		{
			uTmp = uBuilding.GetAttacker();

			if ( uTmp.GetIFF() == m_pPlayer.GetIFF() )
			{
				SetEnemies(m_pPlayer, m_pVillage);

				m_bUpdateWalkers = false;
				m_bCheckInformators = false;

				m_uChildsInformator.CommandAttack(m_uHero);
				m_uBearsInformator.CommandAttack(m_uHero);
				m_uShieldInformator.CommandAttack(m_uHero);
				m_uHealInformator.CommandAttack(m_uHero);
				m_uShepherd.CommandAttack(m_uHero);

				STOP_TALK( ChildsInformator );
				STOP_TALK( BearsInformator );
				STOP_TALK( ShieldInformator );
				STOP_TALK( HealInformator );
				STOP_TALK( Shepherd );
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
		state MissionComplete;
	}

    event EscapeCutscene()
    {
		int x, y;

		x = 128+( GetPointX(markerHeroStart)*256 + m_uPriest.GetLocationX()*256 ) / 2;
		y = GetPointY(markerHeroStart)*256 - 128;

		if ( state == Start || state == Start1 || state == Start2 || state == Start2b || state == Start3 || state == Start4 )
		{
			SetLowConsoleText("");

			m_pPlayer.LookAt(x, y, DEFAULT_LOOKAT_Z+1, 0, DEFAULT_LOOKAT_VIEW, 0);

			if ( state != Start4 )
			{
				if ( GetDifficultyLevel() == difficultyEasy )
				{
					m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_EASY", 0x40);
				}
				else if ( GetDifficultyLevel() == difficultyMedium )
				{
					m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO", 0x40);
				}
				else if ( GetDifficultyLevel() == difficultyHard )
				{
					m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_HARD", 0x40);
				}

				m_uHero.SetIsHeroUnit(true);
				m_uHero.SetIsSingleUnit(true);

				m_bCheckHero = true;
			}

			if ( m_uObj1 != null && m_uObj1.IsLive() ) m_uObj1.RemoveUnit();
			if ( m_uObj2 != null && m_uObj2.IsLive() ) m_uObj2.RemoveUnit();

			Rain(190, 27, 128, 200, 6000, 200, 5);

			CreateObjectAtMarker(markerHeroStart, "PENTAGRAM_BIG");

			m_nDialogToPlay = dialogMoveHero;
			m_nStateAfterDialog = MoveHero;

			SetStateDelay(0);
			state StartPlayDialog;
		}
		else if ( state == StartPlayDialog && m_nDialogToPlay == dialogMoveHero )
		{
			m_pPlayer.LookAt(x, y, DEFAULT_LOOKAT_Z+1, 0, DEFAULT_LOOKAT_VIEW, 0);

			SetStateDelay(0);
			state StartPlayDialog;
		}
    }

	event Timer7()
	{
		StartWind();
	}
}
