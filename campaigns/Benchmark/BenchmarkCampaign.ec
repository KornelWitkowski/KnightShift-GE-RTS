campaign "translateCampaign1"
{
	consts
	{
		mission1 = 1;
		
		racePOL = 1;
	}

	state Initialize;
	state Nothing;
	
	state Initialize
	{
		CreateGamePlayer(2, racePOL, playerLocal);
				
		RegisterMission(mission1, "!Benchmark", "Benchmark\\Missions\\BenchmarkMission", "", 0, 0, 0, 0, 0, 0, mission1);
		
		SetWorldsToLoad(1);
		
		LoadMission(0, mission1);
		
		SetAvailableWorlds(1);
		SetActivePlayerAndWorld(2, 0);

        return Nothing;
	}
	
	state Nothing
	{
		return Nothing, 0;
	}

	event EndingMission(int iMission, int nResult)
	{
	}

	event EndMission(int iMission, int nResult)
	{
		EndGame(null); // victory
	}

	event EnableNextMission(int iMission, int iNextNr, int bEnable)
	{
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
