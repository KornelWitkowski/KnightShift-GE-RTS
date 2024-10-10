mission "translateZGarniec"
{

/* 
 Deklaracja zmiennych dla unitów. Tworzymy jakąś postać, np. Mieszko, w dalszej częsci skryptu
 i zapisanie do niej odwołania pozwala przechwycić, w evencie, że dana postać zginęła lub zebrała artefakt.
 Zmienne są potrzebne do celów misji.
*/

unitex uHero1, uHero2;


#include "Common\States.ech"
#include "Common\Common.ech"
#include "Common\MarkerFunctions.ech"

/*
    Importowanie funkcji dla poszczególnych misji. Trzeba uważać, bo jak zdefinujemy zmienną lub funkcje w jednym pliku,
    to będzie ona dostępna wszędzie. Najlepiej dodawać opis na koniec funkcji typu  `NazwaFunkcjiAdventureGEXY`, gdzie XY
    to numer misji.
*/

#include "Adventure\AdventureGE_1.ech"
#include "Adventure\AdventureGE_2.ech"
#include "Adventure\AdventureGE_3.ech"
#include "Adventure\AdventureGE_4.ech"
#include "Adventure\AdventureGE_5.ech"
#include "Adventure\AdventureGE_6.ech"
#include "Adventure\AdventureGE_7.ech"
#include "Adventure\AdventureGE_8.ech"
#include "Adventure\AdventureGE_9.ech"


event Artefact(int iArtefactNum,  unitex uUnitOnArtefact, player rPlayerOnArtefact)
{
    /*
        Jeśli event Artefact zwraca `false`, to dany "artefakt" może zostać ponownie wykorzystany.
        Jeśli zwraca `true`, to artefakt jest usuwany.
    
    */
    // teleporty, bramy i inne funkcje
    if(iArtefactNum >= 70)
    {
        MarkerFunctionsEventArtefact(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
        return false;
    }
    else
    {
        // eventy dla konkretnych misji
        if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 1"))
        {
            CheckArtefactEventAdventureGE1(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 2"))
        {
            CheckArtefactEventAdventureGE2(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 7"))
        {
            CheckArtefactEventAdventureGE7(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 9"))
        {
            CheckArtefactEventAdventureGE9(iArtefactNum, uUnitOnArtefact, rPlayerOnArtefact);
        }

        return true;
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

        InitializeMarkerFunctions();

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
	    return 8;
      //  return 0x01;
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
            lockAllianceDialog |
            lockToolbarAlliance | 
            lockToolbarSwitchMode |
            lockToolbarLevelName |
            lockToolbarObjectives |
            lockToolbarMoney |
            lockToolbarHelpMode |
            lockDisplayToolbarMoney |
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
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 2"))
        {
            CheckUnitDestroyedAdventureGE2(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 3"))
        {
            return;
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 4"))
        {
            CheckUnitDestroyedAdventureGE4(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 5"))
        {
            CheckUnitDestroyedAdventureGE5(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 6"))
        {
            CheckUnitDestroyedAdventureGE6(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 7"))
        {
            CheckUnitDestroyedAdventureGE7(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 8"))
        {
            CheckUnitDestroyedAdventureGE8(uUnit);
        }
        else if(!CompareStringsNoCase(GetLevelName(), "AdventureGE 9"))
        {
            CheckUnitDestroyedAdventureGE9(uUnit);
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
