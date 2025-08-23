mission "translateC3_Start_Test"
{
#include "..\..\Common.ech"

	consts
	{
		markerHeroStart    = 1;
	}

	player m_pPlayer;
	unitex m_uHero;

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
		}
		else if ( GetDifficultyLevel() == difficultyMedium )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO");
		}
		else if ( GetDifficultyLevel() == difficultyHard )
		{
			m_uHero = CreateUnitAtMarker(m_pPlayer, markerHeroStart, "HERO_HARD");
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

	state Start
	{
		int i, m;

		for ( i=1; i<=5; ++i )
		{
			m = 20 + (i-1)*10;

			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m , 0);

			if( i == 2 || i == 3 || i == 5)
			{			
				CrewExit(m+1);
			}
		}

		for ( i=1; i<=8; ++i )
		{
			m = 10 + i;
			CreateArtefactAtMarker("ARTIFACT_PENTAGRAM", m, i);
		}


		return MissionComplete;
	}

	function void SeveCrew(int nMarker)
	{
		m_pPlayer.SaveUnit(bufferHero, false, m_uHero, true);
		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetPointX(nMarker), GetPointY(nMarker), GetPointX(nMarker)+3, GetPointY(nMarker)+3, GetPointZ(nMarker), null, true);
	}

	state MissionComplete
	{
		int i, m;

		for ( i=1; i<=5; ++i )
		{
			m = 20 + (i-1)*10;

			if ( IsUnitNearMarker(m_uHero, m, 0) )
			{
				SeveCrew(m+1);
				EndMission(i);

				break;
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
