campaign "translateCampaign1"
{
	consts
	{
		mission0 = 0;
		mission1 = 1;
		mission2 = 2;
		mission3 = 3;
		mission4 = 4;
		mission5 = 5;
		mission6 = 6;
		mission7 = 7;
		
		racePOL = 1;
	}

	int m_nLastMission;

	int m_nEndedMissionWorld;
	
	state Initialize;
	state LoadFirstMission;
	state Nothing;
	state ShowOutro;
	state EndCampaign;
	
	state Initialize
	{
		CreateGamePlayer(2, racePOL, playerLocal);
				
		RegisterMission(mission0, "!C1_Mission_00", "Campaigns1\\Missions\\C1_Mission_00", "", 0, 0, 0, 0, 0, 0, mission1);
		RegisterMission(mission1, "!C1_Mission_01", "Campaigns1\\Missions\\C1_Mission_01", "", 0, 0, 0, 0, 0, 0, mission3);
		RegisterMission(mission2, "!C1_Mission_02", "Campaigns1\\Missions\\C1_Mission_02", "", 0, 0, 0, 0, 0, 0); // return to mission1
		RegisterMission(mission3, "!C1_Mission_03", "Campaigns1\\Missions\\C1_Mission_03", "", 0, 0, 0, 0, 0, 0, mission4);
		RegisterMission(mission4, "!C1_Mission_04", "Campaigns1\\Missions\\C1_Mission_04", "", 0, 0, 0, 0, 0, 0, mission5);
		RegisterMission(mission5, "!C1_Mission_05", "Campaigns1\\Missions\\C1_Mission_05", "", 0, 0, 0, 0, 0, 0, mission6);
		RegisterMission(mission6, "!C1_Mission_06", "Campaigns1\\Missions\\C1_Mission_06", "", 0, 0, 0, 0, 0, 0, mission7);
		RegisterMission(mission7, "!C1_Mission_07", "Campaigns1\\Missions\\C1_Mission_07", "", 0, 0, 0, 0, 0, 0); // last mission

		ShowMissionVideoDialog("POL_INTRO1", null, true);
        // SetLoadBitmap("Interface\\Bkg0003.tex");

		m_nLastMission = mission7;

		return LoadFirstMission, 1;
	}

    state LoadFirstMission
    {
		SetWorldsToLoad(1);

		LoadMission(0, mission0);

		SetAvailableWorlds(1);
		SetActivePlayerAndWorld(2, 0);

        return Nothing,0;
    }
	
	state Nothing
	{
		return Nothing, 0;
	}

    state ShowOutro
    {
        ShowMissionVideoDialog("POL_OUTRO1", null, true);
        return EndCampaign, 0;
    }

    state EndCampaign
    {
		EnableCampaign("Campaigns1\\Campaign2Disabled");

        EndGame("");
        return Nothing;
    }

	event EndingMission(int iMission, int nResult)
	{
        int nNextMission, nWorld;

		m_nEndedMissionWorld = GetWorldWithMission(iMission);

        //SetAvailableWorlds przed skasowaniem swiata
		if( nResult == true )
		{
			if ( iMission == m_nLastMission )
			{
			}
			else
			{
				nNextMission = GetNextMission(iMission, 0);

				if ( nNextMission == -1 )
				{
					nWorld = m_nEndedMissionWorld - 1;

					SetAvailableWorlds( 1<<nWorld );
				}
			}
		}
	}

	event EndMission(int iMission, int nResult)
	{
		int nNextMission, nWorld;

		if( nResult == true )
		{
			if ( iMission == m_nLastMission )
			{
				state ShowOutro; // victory
			}
			else
			{
				nNextMission = GetNextMission(iMission, 0);

				if ( nNextMission == -1 )
				{
					nWorld = m_nEndedMissionWorld - 1;

					SetAvailableWorlds( 1<<nWorld );
					CallCamera( nWorld ); // return to parent mission
				}
				else
				{
					nWorld = m_nEndedMissionWorld;

					LoadMission( nWorld, nNextMission ); // load next mission

					SetAvailableWorlds( 1<<nWorld );
					CallCamera( nWorld );
				}
			}
		}
		else
		{
			DefeatScreen(); // defeat
		}
	}

	event EnableNextMission(int iMission, int iNextNr, int bEnable)
	{
		int nWorld;

		if ( bEnable == true )
		{
			nWorld = GetWorldWithMission(iMission) + 1;

			LoadMission(nWorld, iNextNr); // load child mission

			SetAvailableWorlds(1<<nWorld);

			CallCamera(nWorld);
		}
	}
	
	enum difficultyLevel
	{
		"translateSelectCampaignDifficultyEasy",
		"translateSelectCampaignDifficultyMedium",
		"translateSelectCampaignDifficultyHard",
	multi:
		""
	}
	
	command Initialize()
	{
		difficultyLevel = 0;
		return true;
	}
	
	command DifficultyLevel(int nLevel) button difficultyLevel
	{
		return true;
	}
}
