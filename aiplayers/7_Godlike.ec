#define AI_GOLDEN_EDITION
#define AIGODLIKE

#include "Translates.ech"

player "translateAIPlayerGodlike"
{

////    Declarations    ////

    state Initialize;
    state StateSetStrategy;
    state State1;
    state State2;
    state State3;
    state State4;
    state State5;
    state StateCows;

    int iStartegy;
    int bControlTowers;

    #include "Common.ech"
    #include "Objects.ech"
    #include "BattleMode.ech"


    ////    States    ////

    state Initialize
    {

        if ( GetIFFNumber() == 0 )      SetName("translateAINameGodlike0");
        else if ( GetIFFNumber() == 1 ) SetName("translateAINameGodlike1");
        else if ( GetIFFNumber() == 2 ) SetName("translateAINameGodlike2");
        else if ( GetIFFNumber() == 3 ) SetName("translateAINameGodlike3");
        else if ( GetIFFNumber() == 4 ) SetName("translateAINameGodlike4");
        else if ( GetIFFNumber() == 5 ) SetName("translateAINameGodlike5");
        else if ( GetIFFNumber() == 6 ) SetName("translateAINameGodlike6");
        else if ( GetIFFNumber() == 7 ) SetName("translateAINameGodlike7");
        else                            SetName("translateAIPlayerGodlike");

        ResetAIFeatures();
        ResetAIFeatures2();

        EnableAIFeatures(aiBuildRoads |
                        aiBuildNewBuildings |
                        aiRebuildLostDefenceBuildings | 
                       // aiBuildTowersEx |
                        aiBuildNewBridges | 
                        aiRebuildLostBridges |
                        aiAllowBuildClose |
                        aiCaptureStartingPoints |
                        aiProduceUnits, true);

        EnableAIFeatures2(
                        ai2ControlTowers |
                        ai2ControlBuildersBuild | 
                        ai2ControlBuildersRepair | 
                        ai2ControlHarvesters | 
                        ai2ControlConverters | 
                        ai2ControlHarvestIncreasers | 
                        ai2ControlCapturers | 
                        ai2ControlBuildIncreasers |
                        ai2ControlOffense | 
                        ai2ControlDefense | 
                        ai2ControlOffenseMagic | 
                        ai2UseAutoMagic |
                        ai2DefendBuildings | 
                        ai2DefendUnits | 
                        ai2DefendDestroyedObjects |
                        // ai2SmartHarvesters | 
                        ai2TakeEquipmentArtefacts   | 
                        ai2MovePlatoonsOutsideBase |
                        ai2PlatoonAttackInGroup | 
                        ai2PlatoonEscapeOnStorm | 
                        ai2DefendUnitsInPlatoon | 
                        // ai2RandomizedBehaviours | 
                        ai2SetSmartUnitAttackMode | 
                        ai2ResearchUpdatesLevelAll, true);

        SetThinkSpeed(aiThinkSpeedBuildUnits, 5);
        SetThinkSpeed(aiThinkSpeedExecuteOrders, 60);
        SetThinkSpeed(aiThinkSpeedControlUnits, 100);
        SetThinkSpeed(aiThinkSpeedControlUnitsEx, 200);
        SetThinkSpeed(aiThinkSpeedBuildBuildingsEx, 20);
        SetThinkSpeed(aiThinkSpeedMakeDefense, 40);
        SetThinkSpeed(aiThinkSpeedMovePlatoonsOutsideBase, 4*MINUTE);

        SetThinkSpeed(aiThinkSpeedControlConverters, 2*MINUTE);
        SetThinkSpeed(aiThinkSpeedControlCapturers, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedBuildNewBridges, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedRebuildLostBridges, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedResearchUpdates, 1*MINUTE);

        /* ustawiamy dla poszczególnych strategii osobno
        SetThinkSpeed(aiThinkSpeedMakeSmallAttack, 10*MINUTE);
        SetThinkSpeed(aiThinkSpeedMakeBigAttack, (8+RAND(14))*MINUTE);
        SetStartAttacksTime((5+RAND(15))*MINUTE);
        */

        SetUnitsInPlatoon(30);
        SetPlatoonsProportions(2, 1); //offensive/defensive

        SetUnitsBuildTimePercent(20);
        SetMinHarvesters(9);
        SetMinBuilders(6);

        // Informacja dla skryptów misji o poziomie trudności bota
        // Wykorzystywane do zajmowania wież
        SetScriptData(10, 1);

        return StateCows, 25;
    }

    state StateCows
    {
        int iMaxCowNumber;
        int iNumberOfCows;

        iMaxCowNumber = GetMaxCowNumber();
        iNumberOfCows = GetNumberOfUnits(U_COW);

        if(iNumberOfCows < iMaxCowNumber)
        {
            SetUnitProdCount(U_COW, 1);
        }
        else
        {
            return StateSetStrategy, 50;
        }

        return StateCows, 50;
    }

    state StateSetStrategy
    {

        iStartegy = RAND(5);

        // Jeśli gramy tryb miecze i sandały lub balans to wykorzystujemy strategie nie nastawione na magów
        if((GetMaxCountLimitForObject("SHRINE")==0) || (GetMaxCountLimitForObject("SHRINE")==2))
        {
            if(iStartegy > 2)
                iStartegy = 0;
        }
        else if(GetMaxCountLimitForObject("SHRINE")==1)
        // W fastgame używamy tylko standard i atakujemy szybciej
        {
            iStartegy = 0;
            EnableAIFeatures2(ai2ControlTowers, false);
            SetStartAttacksTime((4+RAND(8))*MINUTE);
        }
  
        SetStrategy(1, iStartegy);

        return State1, 25;
    }

    state State1
    {
        ControlMilk(30+RAND(20), 100000);

        UseSeeing(20);
        EnterSleepMode();

        ChangeEscapeOnStormStrategy();

        if(RAND(500) <= 10)
        {
            MakeSuicidalSorcererAttack(1);
        }        
            
        if ((GetMissionTime() > 5*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(2, iStartegy);
            return State2, 50;
        }

        return State1, 50;
    }

    state State2
    {
        ControlMilk(40+RAND(30), 100000);

        UseSeeing(20);
        EnterSleepMode();

        ChangeEscapeOnStormStrategy();

        if(RAND(500) <= 10)
            MakeSuicidalSorcererAttack(2);

        if ((GetMissionTime() > 10*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(3, iStartegy);   
            return State3, 50;
        }

        return State2, 50;
    }

    state State3
    {
        ControlMilk(50+RAND(40), 100000);

        UseSeeing(20);
        EnterSleepMode();

        ChangeEscapeOnStormStrategy();

        if(RAND(500) <= 10)
        {
            MakeSuicidalSorcererAttack(3);
        }

        if ((GetMissionTime() > 15*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(4, iStartegy); 

            return State4, 50;
        }

        return State3, 50;
    }

    state State4
    {
        ControlMilk(60+RAND(50), 100000);

        UseSeeing(20);
        EnterSleepMode();

        ChangeEscapeOnStormStrategy();

        if(RAND(500) <= 10)
        {
            MakeSuicidalSorcererAttack(4);
        }

        if ((GetMissionTime() > 20*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(4, iStartegy); 

            return State4, 50;
        }

        return State4, 50;
    }

    state State5
    {
        ControlMilk(70+RAND(60), 100000);

        UseSeeing(20);
        EnterSleepMode();

        ChangeEscapeOnStormStrategy();

        if(RAND(500) <= 10)
        {
            MakeSuicidalSorcererAttack(4);
        }

        SetStrategy(6, iStartegy); 

        return State5, 50;
    }
}
