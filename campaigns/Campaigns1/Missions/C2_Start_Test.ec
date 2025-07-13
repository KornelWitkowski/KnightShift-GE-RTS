mission "translateC1_Start_Test"
{
#include "..\..\Common.ech"

	consts
	{
		markerHeroStart    = 1;

		markerGiant = 0;
		markerPri   = 2;
	}

	player m_pPlayer;

	unitex m_uHero;

	unitex m_uGiant;
	unitex m_uPri;

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

		INITIALIZE_UNIT( Giant );
		INITIALIZE_UNIT( Pri   );

		return Start;
	}

	function void CrewExit(int nMarker)
	{
		int x, y, z;

		z = GetPointZ(nMarker);

		for(x=GetPointX(nMarker); x<GetPointX(nMarker)+4; ++x)
		{
			for(y=GetPointY(nMarker); y<GetPointY(nMarker)+4; ++y)
			{
				CreateArtefact("ARTIFACT_STARTMISSION", x, y, z, 0);
			}
		}
	}

	state Start
	{
		int i, m;

		for ( i=1; i<=6; ++i )
		{
			m = 20 + (i-1)*4;

			CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m  , 0);

			if ( i == 4 || i == 6 )
			{
				CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m+2, 0);
				CreateArtefactAtMarker("ARTIFACT_STARTMISSION_MIRKO", m+3, 0);
			}
			
			CrewExit(m+1);
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
		m_pPlayer.SaveUnit(bufferGiant, false, m_uGiant, true);
		m_pPlayer.SaveUnit(bufferPrincessa, false, m_uPri, true);

		m_pPlayer.SaveUnitsFromArea(bufferCrew, false, GetPointX(nMarker), GetPointY(nMarker), GetPointX(nMarker)+3, GetPointY(nMarker)+3, GetPointZ(nMarker), null, true);
	}

	state MissionComplete
	{
		int i, m;

		for ( i=1; i<=6; ++i )
		{
			m = 20 + (i-1)*4;

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
