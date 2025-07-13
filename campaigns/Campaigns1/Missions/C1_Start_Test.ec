mission "translateC1_Start_Test"
{
#include "..\..\Common.ech"

	consts
	{
		markerHeroStart    = 1;
		markerMieszkoStart = 2;
	}

	player m_pPlayer;

	unitex m_uHero;
	unitex m_uMieszko;

	state Initialize;
	state Start;
	state MissionComplete;

	state Initialize
	{
		player pFake; pFake = GetPlayer(0); pFake.EnableAI(false);

		m_pPlayer = GetPlayer(2);

		TurnOffTier5Items();

		if ( GetDifficultyLevel() == difficultyEasy )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_EASY");
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, markerMieszkoStart, "MIESZKO_EASY");
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO");
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, markerMieszkoStart, "MIESZKO");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_HARD");
			m_uMieszko = CreateUnitAtMarker(m_pPlayer, markerMieszkoStart, "MIESZKO_HARD");
		}

		return Start;
	}

	function void CrewExit(int nMarker)
	{
		int x, y, z;

		z = GetPointZ(nMarker);

		for(x=GetPointX(nMarker); x<GetPointX(nMarker)+3; ++x)
		{
			for(y=GetPointY(nMarker); y<GetPointY(nMarker)+3; ++y)
			{
				CreateArtefact("ARTIFACT_STARTMISSION", x, y, z, 0);
			}
		}
	}

	function void CreateCarrier(int x, int y, string strUnitName)
	{
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Sorcerer_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Priest_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Knight_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Knight_carry2");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Knight_carry3");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Footman_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Hunter_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Diplomat_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Diplomat_carry2");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Diplomat_carry3");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Priestessa_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Shepherd_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Witch_carry");
		CreateSmokeObject(m_pPlayer.CreateUnit(++x, y, 0, 0, strUnitName), "RPG_Spearman_carry");
	}

	state Start
	{
		int i, m;
		int x,y,z;

		platoon plat;

		x = 19-1;
		y = 53-1;

		CreateCarrier(x, ++y, "RPG_FOOTMAN");
		CreateCarrier(x, ++y, "RPG_HUNTER");
		CreateCarrier(x, ++y, "RPG_SPEARMAN");
		CreateCarrier(x, ++y, "RPG_PRIESTESS");
		CreateCarrier(x, ++y, "RPG_SORCERER");
		CreateCarrier(x, ++y, "RPG_WOODCUTTER");

		plat = CreateExpUnitsAtMarker(m_pPlayer, 15, "WOLF", 3, 2);
		CreateExpUnitsAtMarker(plat,  m_pPlayer, 15, "BEAR", 4, 2);

		CommandMoveAndDefendPlatoonToMarker(plat, markerHeroStart);

		CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", 21, 0);

		for ( i=2; i<=7; ++i )
		{
			m = 22 + (i-2)*3;

			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m  , 0);
			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m+1, 0);
			
			CrewExit(m+2);
		}

		for ( i=1; i<=8; ++i )
		{
			m = 10 + i;

			CreateArtefactAtMarker("ARTIFACT_PENTAGRAM", m, i);
		}

		x = GetPointX(markerHeroStart)+5;
		y = GetPointY(markerHeroStart)-4;
		z = GetPointZ(markerHeroStart);

		CreateArtefact("SWITCH_1_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_1_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_2_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_2_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_3_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_3_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_4a_1", --x, y, z, 0);
		CreateArtefact("SWITCH_4a_2", x, y-1, z, 0);
		CreateArtefact("SWITCH_4b_1", --x, y, z, 0);
		CreateArtefact("SWITCH_4b_2", x, y-1, z, 0);
		CreateArtefact("SWITCH_4c_1", --x, y, z, 0);
		CreateArtefact("SWITCH_4c_2", x, y-1, z, 0);
		CreateArtefact("SWITCH_4d_1", --x, y, z, 0);
		CreateArtefact("SWITCH_4d_2", x, y-1, z, 0);
		CreateArtefact("SWITCH_5_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_5_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_WOLF_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_WOLF_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_BEAR_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_BEAR_2" , x, y-1, z, 0);
		CreateArtefact("SWITCH_GIANT_1" , --x, y, z, 0);
		CreateArtefact("SWITCH_GIANT_2" , x, y-1, z, 0);

		return MissionComplete;
	}

	function void SeveCrew(int nMarker)
	{
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnit(bufferMieszko, false, m_uMieszko, true);

		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetPointX(nMarker), GetPointY(nMarker), GetPointX(nMarker)+2, GetPointY(nMarker)+2, GetPointZ(nMarker), null, true);
	}

	state MissionComplete
	{
		int i, m;

		if ( IsUnitNearMarker(m_uHero, 21, 0) )
		{
			m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
			EndMission(1);
		}
		else
		{
			for ( i=2; i<=7; ++i )
			{
				m = 22 + (i-2)*3;

				if ( IsUnitNearMarker(m_uHero, m, 0) && IsUnitNearMarker(m_uMieszko, m+1, 0) )
				{
					SeveCrew(m+2);
					EndMission(i);

					break;
				}
			}
		}

		return MissionComplete;
	}

	event Artefact(int nArtefactNum, unitex uUnitOnArtefact, player pPlayerOnArtefact)
	{
		if ( nArtefactNum >= 1 && nArtefactNum <= 8 )
		{
			uUnitOnArtefact.SetExperienceLevel(nArtefactNum);
		}

		return false;
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
//			lockShowToolbar |
//			lockToolbarMap |
//			lockToolbarPanel |
			lockToolbarLevelName |
//			lockToolbarTunnels |
//			lockToolbarObjectives |
//			lockToolbarMenu |
//			lockDisplayToolbarLevelName |
			lockCreateBuildPanel |
//			lockCreatePanel |
//			lockCreateMap |
			0);
	}
    event Timer0()
    {
    }

}
