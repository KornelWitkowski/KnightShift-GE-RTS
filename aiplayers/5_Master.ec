#define AI_GOLDEN_EDITION
#define AIMASTER_EC

#include "Translates.ech"

player "translateAIPlayerMaster"
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

    int iRandNum;
    int iStartegy;
    int bUseSeeing;

    #include "Common.ech"
    #include "Objects.ech"
    #include "BattleMode.ech"


    ////    States    ////

    state Initialize
    {
        int iRandNum;

        if ( GetIFFNumber() == 0 )      SetName("translateAINameMaster0");
        else if ( GetIFFNumber() == 1 ) SetName("translateAINameMaster1");
        else if ( GetIFFNumber() == 2 ) SetName("translateAINameMaster2");
        else if ( GetIFFNumber() == 3 ) SetName("translateAINameMaster3");
        else if ( GetIFFNumber() == 4 ) SetName("translateAINameMaster4");
        else if ( GetIFFNumber() == 5 ) SetName("translateAINameMaster5");
        else if ( GetIFFNumber() == 6 ) SetName("translateAINameMaster6");
        else if ( GetIFFNumber() == 7 ) SetName("translateAINameMaster7");
        else                            SetName("translateAIPlayerMaster");

        ResetAIFeatures();
        ResetAIFeatures2();

        EnableAIFeatures(
                        aiBuildRoads |
                        aiBuildNewBuildings |
                        aiRebuildLostDefenceBuildings | 
                       // aiBuildTowersEx |
                        aiBuildNewBridges | 
                        aiRebuildLostBridges |
                        aiAllowBuildClose |
                        aiCaptureStartingPoints |
                        aiProduceUnits, true);

        EnableAIFeatures2(ai2ControlTowers |
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
        SetThinkSpeed(aiThinkSpeedMakeSmallAttack, 12*MINUTE);
        SetThinkSpeed(aiThinkSpeedMakeBigAttack, (8+RAND(16))*MINUTE);
        SetThinkSpeed(aiThinkSpeedControlConverters, 2*MINUTE);
        SetThinkSpeed(aiThinkSpeedControlCapturers, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedBuildNewBridges, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedRebuildLostBridges, 3*MINUTE);
        SetThinkSpeed(aiThinkSpeedResearchUpdates, 3*MINUTE);

        SetStartAttacksTime((5+RAND(15))*MINUTE);

        SetUnitsInPlatoon(30);
        SetPlatoonsProportions(2, 1); //offensive/defensive

        SetUnitsBuildTimePercent(70);
        SetMinHarvesters(9);
        SetMinBuilders(6);   
 
        bUseSeeing = RAND(2);

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
        iRandNum = RAND(100);

        if(iRandNum < 60)
        {
            // Strategia standard - 60% szans
            iStartegy = 0;
        }
        else if(iRandNum < 80)
        {
            // Strategia włócznicy - 20% szans
            iStartegy = 1;
        }
        else
        {
            // Strategia drwale - 20% szans
            iStartegy = 2;
        }

        // W trybie fastgame używamy tylko strategie standard
        if(GetMaxCountLimitForObject("SHRINE")==1)
        {
            EnableAIFeatures2(ai2ControlTowers, false);
            iStartegy = 0;
        }
        SetStrategy(1, iStartegy); 

        return State1, 25;
    }

    state State1
    {
        ControlMilk(3+RAND(5+1), 100000);
        if(bUseSeeing != 0)
            UseSeeing(5);
        EnterSleepMode();
        GoBackWhenLowHP();

        if ((GetMissionTime() > 7*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(2, iStartegy);
            return State2, 50;
        }

        return State1, 50;
    }

    state State2
    {
        ControlMilk(5+RAND(5+1), 100000);
        if(bUseSeeing != 0)
            UseSeeing(5);
        EnterSleepMode();
        GoBackWhenLowHP();

        if ((GetMissionTime() > 14*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(3, iStartegy);   
            return State3, 50;
        }

        return State2, 50;
    }

    state State3
    {
        ControlMilk(7+RAND(5+1), 100000);
        if(bUseSeeing != 0)
            UseSeeing(5);
        EnterSleepMode();
        GoBackWhenLowHP();

        if ((GetMissionTime() > 21*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(4, iStartegy); 

            return State4, 50;
        }

        return State3, 50;
    }

    state State4
    {
        ControlMilk(10+RAND(10+1), 100000);

        if(bUseSeeing != 0)
            UseSeeing(5);
        EnterSleepMode();
        GoBackWhenLowHP();

        if ((GetMissionTime() > 28*MINUTE) || IsReachedLimitForAllProdCountUnits())
        {
            SetStrategy(5, iStartegy); 
            return State5, 50;
        }

        return State4, 50;
    }

    state State5
    {
        ControlMilk(20+RAND(15+1), 100000);

        if(bUseSeeing != 0)
            UseSeeing(5);
        EnterSleepMode();
        GoBackWhenLowHP();

        SetStrategy(6, iStartegy); 

        return State5, 50;
    }
}
