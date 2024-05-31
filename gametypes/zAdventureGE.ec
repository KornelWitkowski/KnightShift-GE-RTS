mission "translateZGarniec"
{

/* 
 Deklaracja zmiennych dla unitów. Tworzymy jakąś postać, np. Mieszko, w dalszej częsci skryptu
 i zapisanie do niej odwołania pozwala przechwycić, w evencie, że dana postać zginęła lub zebrała artefakt.
 Zmienne są potrzebne do celów misji.
*/

unitex uHero1, uHero2;

#include "Common\States.ech"
#include "..\AIPlayers\Rand.ech"
#include "..\Campaigns\Common.ech"

/*
    Importowanie funkcji dla poszczególnych misji. Trzeba uważać, bo jak zdefinujemy zmienną lub funkcje w jednym pliku,
    to będzie ona dostępna wszędzie. Najlepiej dodawać opis na koniec funkcji typu  `NazwaFunkcjiAdventureGEXY`, gdzie XY
    to numer misji.
*/

#include "Adventure\Common.ech"

#include "Adventure\AdventureGE_1.ech"
#include "Adventure\AdventureGE_2.ech"
#include "Adventure\AdventureGE_3.ech"
#include "Adventure\AdventureGE_4.ech"
#include "Adventure\AdventureGE_5.ech"
#include "Adventure\AdventureGE_6.ech"
#include "Adventure\AdventureGE_7.ech"
#include "Adventure\AdventureGE_8.ech"
#include "Adventure\AdventureGE_9.ech"


function void CreateAutoGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("SWITCH_1_1", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 1024 | markerGate);
    }
}

function void CreateOpenGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("SWITCH_1_1", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 2048 | markerGate);
    }
}

function void CreateCloseGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("SWITCH_1_1", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 4096 | markerGate);
    }
}

function void CreateInvisibleAutoGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("ARTIFACT_INVISIBLE", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 1024 | markerGate);
    }
}

function void CreateInvisibleOpenGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("ARTIFACT_INVISIBLE", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 2048 | markerGate);
    }
}

function void CreateInvisibleCloseGateSwitch(int markerArtefact, int markerGate)
{
    if (PointExist(markerArtefact) && PointExist(markerGate))
    {
        CreateArtefact("ARTIFACT_INVISIBLE", GetPointX(markerArtefact), GetPointY(markerArtefact), GetPointZ(markerArtefact), 4096 | markerGate);
    }
}

event Artefact(int marker, unitex u, player p)
{
    unitex u2;

    /* 
    Obsługa eventu Artefact dla różnych misji. Jeśli zgadza się nazwa misji, to wywołujemy 
    funkcje odpowiednią dla misji, która obsłuży event.
    */

    // Bramy, teleporty itd. działają tak samo dla wszystkich misji. Wcześniej nie ma żadnego 'return'.

    if (marker > 0 && marker & 1024) // Switch-Auto
    {
        u2 = GetUnit(GetPointX(marker & ~1024), GetPointY(marker & ~1024), GetPointZ(marker & ~1024));
        u2.CommandBuildingSetGateMode(0);
        return false;
    }
    if (marker > 0 && marker & 2048) // Switch-Open
    {
        u2 = GetUnit(GetPointX(marker & ~2048), GetPointY(marker & ~2048), GetPointZ(marker & ~2048));
        u2.CommandBuildingSetGateMode(1);
        return false;
    }
    if (marker > 0 && marker & 4096) // Switch-Close
    {
        u2 = GetUnit(GetPointX(marker & ~4096), GetPointY(marker & ~4096), GetPointZ(marker & ~4096));
        u2.CommandBuildingSetGateMode(2);
        return false;
    }

    if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 1"))
    {
        CheckArtefactEventAdventureGE1(marker, u, p);
    }
    else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 2"))
    {
        CheckArtefactEventAdventureGE2(marker, u, p);
    }
    else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 7"))
    {
        CheckArtefactEventAdventureGE7(marker, u, p);
    }
    else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 9"))
    {
        CheckArtefactEventAdventureGE9(marker, u, p);
    }

    return true;
} 

	state Initialize;
    state Nothing;
    state Victory;
    state Defeat;
    
    state Initialize
    {
        player rPlayer;
        int i;
		int j;
    
		// Wyłączenie podpowiedzi
		EnableAssistant(0xffffff, false);

        SetMoneyPerResource100x(40);
        SetResourceGrowSpeed(400);

    	//---------------------------------

	for(i=140+1; i<180+1; i=i+2) // +1 wynika ze wstecznej kompatybliności 
	{
		SetupTeleportBetweenMarkers(i, i+1);
	}

	for(i=180+1; i<201+1; i=i+2) // +1 wynika ze wstecznej kompatybliności 
	{
		SetupOneWayTeleportBetweenMarkers(i, i+1);
	}
    

		SetupOneWayTeleportBetweenMarkers(181, 182); //GE Teleporty w jedną stronę uniwersalne 
		SetupOneWayTeleportBetweenMarkers(183, 184); //teleporty w jedną stronę między markerami: 182-183, 186-187, 190-191, 194-195, 198-199
		SetupOneWayTeleportBetweenMarkers(185, 186);
		SetupOneWayTeleportBetweenMarkers(187, 188);

		SetupOneWayTeleportBetweenMarkers(189, 190);
		SetupOneWayTeleportBetweenMarkers(191, 192);
		SetupOneWayTeleportBetweenMarkers(193, 194);
		SetupOneWayTeleportBetweenMarkers(195, 196);

		SetupOneWayTeleportBetweenMarkers(197, 198);
		SetupOneWayTeleportBetweenMarkers(199, 200); 






		SetupOneWayTeleportBetweenMarkers(241, 240); // GE teleporty [5 kierujących do 1]
		SetupOneWayTeleportBetweenMarkers(242, 240);
		SetupOneWayTeleportBetweenMarkers(243, 240);
		SetupOneWayTeleportBetweenMarkers(244, 240);
		SetupOneWayTeleportBetweenMarkers(245, 240);

		SetupOneWayTeleportBetweenMarkers(247, 246);
		SetupOneWayTeleportBetweenMarkers(248, 246);
		SetupOneWayTeleportBetweenMarkers(249, 246);
		SetupOneWayTeleportBetweenMarkers(250, 246);
		SetupOneWayTeleportBetweenMarkers(251, 246); // GE KONIEC
		

        //Open - Close gate
        CreateOpenGateSwitch(240, 242); 
    	CreateCloseGateSwitch(241, 242); 

    	CreateOpenGateSwitch(243, 245);
    	CreateCloseGateSwitch(244, 245);

    	CreateOpenGateSwitch(246, 248);
    	CreateCloseGateSwitch(247, 248);

    	CreateOpenGateSwitch(249, 251);
    	CreateCloseGateSwitch(250, 251);

    	CreateOpenGateSwitch(252, 254);
    	CreateCloseGateSwitch(253, 254);

    	CreateOpenGateSwitch(255, 257);
    	CreateCloseGateSwitch(256, 257);

    	CreateOpenGateSwitch(258, 260);
    	CreateCloseGateSwitch(259, 260);

    	CreateOpenGateSwitch(261, 263);
    	CreateCloseGateSwitch(262, 263);

    	CreateOpenGateSwitch(264, 266);
    	CreateCloseGateSwitch(265, 266);

    	CreateOpenGateSwitch(267, 269);
    	CreateCloseGateSwitch(268, 269);
		// ---------------------------
		
		//Auto gate
		
		CreateAutoGateSwitch(270, 271);
		CreateAutoGateSwitch(272, 273);
		CreateAutoGateSwitch(274, 275);
		CreateAutoGateSwitch(276, 277);
		CreateAutoGateSwitch(278, 279);
		CreateAutoGateSwitch(280, 281);
		CreateAutoGateSwitch(282, 283);
		CreateAutoGateSwitch(284, 285);
		CreateAutoGateSwitch(286, 287);
        CreateAutoGateSwitch(288, 289);
         
		//----------------------
		
		//Invisible Open - Close gate
		
		CreateInvisibleOpenGateSwitch(290, 292);
        CreateInvisibleCloseGateSwitch(291, 292);
		
		CreateInvisibleOpenGateSwitch(293, 295);
        CreateInvisibleCloseGateSwitch(294, 295);
		
		CreateInvisibleOpenGateSwitch(296, 298);
        CreateInvisibleCloseGateSwitch(297, 298);
		
		CreateInvisibleOpenGateSwitch(299, 301);
        CreateInvisibleCloseGateSwitch(300, 301);
		
		CreateInvisibleOpenGateSwitch(302, 304);
        CreateInvisibleCloseGateSwitch(303, 304);
		
		CreateInvisibleOpenGateSwitch(305, 307);
        CreateInvisibleCloseGateSwitch(306, 307);
		
		CreateInvisibleOpenGateSwitch(308, 310);
        CreateInvisibleCloseGateSwitch(309, 310);
		
		CreateInvisibleOpenGateSwitch(311, 313);
        CreateInvisibleCloseGateSwitch(312, 313);
		
		CreateInvisibleOpenGateSwitch(314, 316);
        CreateInvisibleCloseGateSwitch(315, 316);
		
		CreateInvisibleOpenGateSwitch(317, 319);
        CreateInvisibleCloseGateSwitch(318, 319);
		
		// ----------------------
		
		//Invisible Auto gate
		
		CreateInvisibleAutoGateSwitch(320, 321);
		CreateInvisibleAutoGateSwitch(322, 323);
		CreateInvisibleAutoGateSwitch(324, 325);
		CreateInvisibleAutoGateSwitch(326, 327);
		CreateInvisibleAutoGateSwitch(328, 329);
		CreateInvisibleAutoGateSwitch(330, 331);
		CreateInvisibleAutoGateSwitch(332, 333);
		CreateInvisibleAutoGateSwitch(334, 335);
        CreateInvisibleAutoGateSwitch(336, 337);
        CreateInvisibleAutoGateSwitch(338, 339);
		//-------------------------------------


        /* Jeśli misja ma swój skrypt to robimy Initialize dla tej misji.
           Jeśli nie to skrypt będzie działać dalej jak wojna wiosek. 
           
            W ifach wykonuemy funkcje InitializeUnitsAdventureXY(), ponieważ przejście do dalszego stanu ma zawsze
            drobny Delay i jesli unity stworzymy dopiero w następnym stanie, to gracz przez chwilę widzi czarny ekran.
        */

        if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 1"))
        {
            InitializePlayerAdventureGE1();
            return InitializeAdventureGE1, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 2"))
        {
            InitializePlayerAdventureGE2();
            return InitializeAdventureGE2, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 3"))
        {
            InitializePlayerAdventureGE3();
            return InitializeAdventureGE3, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 4"))
        {
            InitializePlayerAdventureGE4();
            return InitializeAdventureGE4, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 5"))
        {
            InitializePlayerAdventureGE5();
            return InitializeAdventureGE5, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 6"))
        {
            InitializePlayerAdventureGE6();
            return InitializeAdventureGE6, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 7"))
        {
            InitializePlayerAdventureGE7();
            return InitializeAdventureGE7, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 8"))
        {
            InitializePlayerAdventureGE8();
            return InitializeAdventureGE8, 0;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 9"))
        {
            InitializePlayerAdventureGE9();
            return InitializeAdventureGE9, 0;
        }

        for(i=0; i<maxNormalPlayersCnt; i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer != null) 
            {     
				rPlayer.SetScriptData(0, 0);
                rPlayer.SetMaxMoney(100);
                
                rPlayer.SetMoney(100);

				rPlayer.SetMaxCountLimitForObject("COWSHED", 4);
                rPlayer.SetMaxCountLimitForObject("COURT", 1);
                rPlayer.LookAt(rPlayer.GetStartingPointX(), rPlayer.GetStartingPointY(), 6, 32, 20, 0);
	        }
        }

		SetTimer(0, 100);
        SetTimer(1, 400);
        SetTimer(2, 2400);//2min
		SetTimer(3, 4800);//4min
		SetTimer(4, 1200);//1min

        SetConsoleText("translateAdventureGameTypeDescription");

        SetTimer(7, GetWindTimerTicks());
		StartWind();

		StatisticReset();
		StatisticAddTab("translateStatisticsTabSummary", statisticTabTypeSummary, true);
		StatisticAddTab("translateStatisticsTabMoney", statisticTabTypeMoney, true);
		StatisticAddTab("translateStatisticsTabUnitsStat", statisticTabTypeUnits, true);
		StatisticSetSortOrder(0, 3, true);

        return Nothing;
    }

    event RemoveResources()
    {
	    return false;
    }
    
    event RemoveUnits()
    {
        return false;
    }

    event UseExtraSkirmishPlayers()
    {
        return true;
    }

    event SpecialLevelFlags()
    {
        return 0x01;
    }

    event AIPlayerFlags()
    {
        // Tutaj wyłączamy wybieranie botów.
        
        return false;
        // return 0x0F;
    }
    
	event SetupInterface()
	{
        SetInterfaceOptions(
//	        lockResearchDialog |
//	        lockConstructionDialog |
//	        lockUpgradeWeaponDialog |
            lockAllianceDialog |
            lockToolbarAlliance | 
//            lockGiveMoneyDialog |
//            lockGiveUnitsDialog |
//            lockShowToolbar |
//            lockToolbarMap |
//            lockToolbarPanel |
            lockToolbarSwitchMode |
            lockToolbarLevelName |
//            lockToolbarTunnels |
			lockToolbarObjectives |
//            lockToolbarResearching |
//            lockToolbarConstruction |
//            lockToolbarMenu |
            lockToolbarMoney |
			lockToolbarHelpMode |
//            lockDisplayToolbarLevelName |
            lockDisplayToolbarMoney |
//            lockCreateBuildPanel |
//            lockCreateMoneyProgress | 
            0);
	}
        
    event Timer0()
    {
        int iAlivePlayers;
        int i;
        int j;
        int iCountBuilding;
        int bActiveEnemies;
        int bOneHasBeenDestroyed;   
        player rPlayer;
        player rPlayer2;
        player rLastPlayer;

		if ( state != Nothing ) return;

        rLastPlayer=null;
        iAlivePlayers=0;
        bOneHasBeenDestroyed=false;
        for(i=0;i<maxNormalPlayersCnt;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null)
			{
				if(rPlayer.IsAlive()) 
				{
                    iCountBuilding = rPlayer.GetNumberOfBuildings(buildingHarvestFactory);
                    if(iCountBuilding<2)rPlayer.SetMaxMoney(100);
                    if(iCountBuilding==2)rPlayer.SetMaxMoney(200);
                    if(iCountBuilding==3)rPlayer.SetMaxMoney(300);
                    if(iCountBuilding>=4)rPlayer.SetMaxMoney(400);

					iCountBuilding = rPlayer.GetNumberOfBuildings();

					if(iCountBuilding) rPlayer.SetScriptData(0,1);
						
					if (iCountBuilding==0)
					{
						if(rPlayer.GetScriptData(0)==1)
						{
							rPlayer.SetScriptData(1,1); // Defeat
							KillArea(rPlayer.GetIFF(), GetRight()/2, GetBottom()/2, 0, 128);

							SetStateDelay(150);
							state Defeat;
						}
						else
						{
							if(rPlayer.GetNumberOfUnits()==0)
							{
								rPlayer.SetScriptData(1,1); // Defeat

								SetStateDelay(150);
								state Defeat;
							}
						}
					}
				}
				if(!rPlayer.IsAlive()) bOneHasBeenDestroyed=true;
			}
        }
        
        bActiveEnemies=false;
        for(i=0;i<maxNormalPlayersCnt;i=i+1)
        {
            rPlayer = GetPlayer(i);
            if(rPlayer!=null && rPlayer.IsAlive()) 
            {
                for(j=i+1;j<maxNormalPlayersCnt;j=j+1)
                {
                    rPlayer2 = GetPlayer(j);
                    if(rPlayer2!=null && rPlayer2.IsAlive()) 
                    {
                        bActiveEnemies=true;
                    }
                }
            }
        }
        if(bActiveEnemies) return;
        if(!bOneHasBeenDestroyed) return;
        
		SetStateDelay(150);
		state Victory;
    }
    

    event Timer4()
    {
		if ( RAND(100) < 10 ) // 10 %
		{
			if ( GetCurrentTerrainNum() == 5 ) // zima
			{
				Snow((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 128, 100, 1000, 100, 5+Rand(6));
			}
			else if ( Rand(5) == 0 )
			{
				Rain((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 128, 100, 1000, 100, 5+Rand(6));
			}
		}
	}

	event Timer7()
	{
		StartWind();
	}

	command Initialize()
    {
        return true;
    }
    
    command Uninitialize()
    {
        return true;
    }

    event UnitDestroyed(unitex uUnit)
    {
        if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 1"))
        {
            CheckUnitDestroyedAdventureGE1(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 2"))
        {
            CheckUnitDestroyedAdventureGE2(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 3"))
        {
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 4"))
        {
            CheckUnitDestroyedAdventureGE4(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 5"))
        {
            CheckUnitDestroyedAdventureGE5(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 6"))
        {
            CheckUnitDestroyedAdventureGE6(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 7"))
        {
            CheckUnitDestroyedAdventureGE7(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 8"))
        {
            CheckUnitDestroyedAdventureGE8(uUnit);
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 9"))
        {
            CheckUnitDestroyedAdventureGE9(uUnit);
            return;
        }
    }

    event UnitCreated(unitex uUnit)
    {
        if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 1"))
        {
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 6"))
        {
            CheckUnitCreatedAdventureGE6(uUnit);
            return;
        }
    }
}
