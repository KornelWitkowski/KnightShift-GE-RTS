#define NO_DEBUG

mission "translateMM05"
{
    state Initialize;
    state MoveCamera1;
    state MoveCamera2;
	
	#include "..\..\Common.ech"
	
	player m_pPlayer;
	player m_pEnemy;
	
	unitex m_uHero;
	platoon m_platEnemy;
	
	function void CreateRandomAttack(int nFromMarker, int nToMarker)
	{
		platoon platTmp;
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) m_platEnemy = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "RPG_SPIDER2"     , 1);
		else if ( nTmp == 1 ) m_platEnemy = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "RPG_POISON_SPIDER", 1);
		else if ( nTmp == 2 ) m_platEnemy = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "RPG_FIRE_SPIDER", 1);
		else __ASSERT_FALSE();
		
		CommandMoveAndDefendPlatoonToMarker(m_platEnemy, nToMarker);
	}
	
    state Initialize
    {
		m_pPlayer = GetPlayer(1);
		m_pEnemy = GetPlayer(0);
		
		m_pPlayer.EnableAI(false);
		m_pEnemy.EnableAI(false);
		
		SetEnemies(m_pPlayer, m_pEnemy);
		
		m_pPlayer.SpyPlayer(m_pEnemy, true, -1);
		
		SetTime(500);
		
		EnableAssistant(0xffffff, false);
        EnableCameraMovement(false);
		
		SetAllBridgesImmortal(true);

		m_pPlayer.LookAt((GetLeft()+30)*256, (GetTop()+31)*256+128, 9, 0, 55, 0);
		ShowArea(m_pPlayer.GetIFF(), (GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 0, 256);
		
		TRACE2("GetCurrentTerrainNum() =", GetCurrentTerrainNum());
		
		if ( GetCurrentTerrainNum() == 5 ) // zima
		{
			Snow((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 64, 600, 1000+Rand(2000), 600, 5+Rand(6));
		}
		else if ( Rand(5) == 0 )
		{
			Rain((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 64, 600, 1000+Rand(2000), 600, 5+Rand(6));
		}
		
		m_uHero = GetUnitAtMarker(0);
		m_uHero.SetExperienceLevel(10);
		m_uHero.CommandSetMovementMode(modeHoldPos);
		
		SetTimer(0,  50);
		SetTimer(7, 5000);
		
		SetTimer(1, 30*30);
		
		CreateRandomAttack(1+Rand(4), 0);
		
		return MoveCamera1, 20;
	}
	
	state MoveCamera1
	{
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128,  9, 128, 55, 0, 600, true);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128,  8, 128, 59, 0, 600, true);
		else if ( nTmp == 2 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128, 14, 128, 40, 0, 600, true);
		else __ASSERT_FALSE();
		
		return MoveCamera2, 600;
	}
	
	state MoveCamera2
	{
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128,  9,   0, 55, 0, 600, true);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128,  8,   0, 59, 0, 600, true);
		else if ( nTmp == 2 ) m_pPlayer.DelayedLookAt((GetLeft()+30)*256, (GetTop()+31)*256+128, 14,   0, 40, 0, 600, true);
		else __ASSERT_FALSE();
		
		return MoveCamera1, 600;
	}
	
	event Timer0()
	{
		m_uHero.RegenerateHP();
		m_platEnemy.CommandAttack(m_uHero);
	}
	
	event Timer7()
	{
		if ( GetCurrentTerrainNum() != 5 && Rand(5) == 0 ) // nie zima
		{
			Rain((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 64, 600, 1000+Rand(2000), 600, 5+Rand(6));
		}
	}
	
	event Timer1()
	{
		CreateRandomAttack(1+Rand(4), 0);
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
			lockShowToolbar |
			lockToolbarMap |
			lockToolbarPanel |
			lockToolbarLevelName |
			lockToolbarTunnels |
			lockToolbarObjectives |
			lockToolbarMenu |
			lockDisplayToolbarLevelName |
			lockCreateBuildPanel |
			lockCreatePanel |
			lockCreateMap |
			0);
	}
}

