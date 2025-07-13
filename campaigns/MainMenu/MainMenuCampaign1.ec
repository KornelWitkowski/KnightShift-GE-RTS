campaign "B_Test_Campign"
{
	consts
	{
		mission1 = 1;
		
		racePOL = 1;

		bufferMap    =  0;
		bufferScript = 64;
	}

	state Initialize;
	state Nothing;

#define REGISTER_MISSION(Map, Script) \
	SetStringBuff(bufferMap+nMissionsCnt, Map); SetStringBuff(bufferScript+nMissionsCnt, "MainMenu\\Missions\\" Script); ++nMissionsCnt;
	
	state Initialize
	{
        int nMissionsCnt, nMission;
        int nCurrTerrain;
        int arrTerrains[];

        nMissionsCnt = 0;


		REGISTER_MISSION("!MainMenu05_1", "Mission_05");
		REGISTER_MISSION("!MainMenu01_2", "Mission_01");
		REGISTER_MISSION("!MainMenu07_5", "Mission_07");
		REGISTER_MISSION("!MainMenu04_3", "Mission_04");
		REGISTER_MISSION("!MainMenu08_1", "Mission_08");
		REGISTER_MISSION("!MainMenu09_3", "Mission_09");



        //wybieramy losowo ten level ktory ma taki sam teren jak biezaco zaladowany, a jesli nie ma takiego to dowolny
        nCurrTerrain = GetCurrentTerrainNum();
        arrTerrains.Create(0);
        for (nMission = 0; nMission < nMissionsCnt; ++nMission)
        {
            if (GetLevelTerrainNum(GetStringBuff(bufferMap+nMission)) == nCurrTerrain)
            {
                arrTerrains.Add(nMission);
            }
        }

        if (arrTerrains.GetSize())
        {
            nMission = arrTerrains[Rand(arrTerrains.GetSize())];
        }
        else
        {
            nMission = Rand(nMissionsCnt);
        }

		CreateGamePlayer(1, racePOL, playerLocal);
				
		RegisterMission(mission1, GetStringBuff(bufferMap+nMission), GetStringBuff(bufferScript+nMission), "", 0, 0, 0, 0, 0, 0);
		
		SetWorldsToLoad(1);
		
		LoadMission(0, mission1);
		
		SetAvailableWorlds(1);
		SetActivePlayerAndWorld(1, 0);

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
	}

	event EnableNextMission(int iMission, int iNextNr, int bEnable)
	{
	}
	
	command Initialize()
	{
		return true;
	}
}
