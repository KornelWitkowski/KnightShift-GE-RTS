#define NO_DEBUG

mission "translateMM04"
{
    state Initialize;
    state MoveCamera;
	
    state MoveCamera1a;
    state MoveCamera2a;
	
    state MoveCamera1b;
    state MoveCamera2b;
    state MoveCamera3b;
    state MoveCamera4b;
	
    state MoveCamera1c;
    state MoveCamera2c;
    state MoveCamera3c;
    state MoveCamera4c;
    state MoveCamera5c;
	
	#include "..\..\Common.ech"
	
	player m_pPlayer;
	player m_pEnemy;
	
	unitex m_auFootman[];
	
	int m_nCamera;
	
	function void CreateRandomAttack(int nFromMarker, int nToMarker)
	{
		platoon platTmp;
		int nTmp;
		
		if ( m_pEnemy.GetNumberOfUnits() > 7 ) return;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WOLF"     , 1+Rand(2));
		else if ( nTmp == 1 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WHITEWOLF", 1        );
		else if ( nTmp == 2 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "BROWNWOLF", 1+Rand(2));
		else __ASSERT_FALSE();
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, nToMarker);
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

		m_pPlayer.LookAt(GetLeft()+32, GetTop()+34, 22, 0, 32, 0);
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
		
		m_auFootman.Create(8);
		
		// FOOTMAN - BF
		// HUNTER - BH
		// PRIEST - DOG
		// WOODCUTTER - BW
		
		m_auFootman[0] = CreateUnitAtMarker(m_pPlayer, 0, "RPG_BANDIT_FOOTMAN2");
		m_auFootman[1] = CreateUnitAtMarker(m_pPlayer, 1, "RPG_BANDIT_HUNTER3");
		m_auFootman[2] = CreateUnitAtMarker(m_pPlayer, 2, "RPG_BANDIT_WOODCUTTER");
		m_auFootman[3] = CreateUnitAtMarker(m_pPlayer, 3, "DOG");
		
		SetTimer(0,  100);
		SetTimer(7, 5000);
		
		SetTimer(1, 1000);
		SetTimer(2,  800);
		SetTimer(3, 3000);
		SetTimer(4, 1300);
		SetTimer(5, 9000);
		
		CreateRandomAttack(4+Rand(4), 0+Rand(4));
		
		return MoveCamera, 20;
	}
	
	state MoveCamera
	{
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) return MoveCamera1a, 0;
		else if ( nTmp == 1 ) return MoveCamera1b, 0;
		else if ( nTmp == 2 ) return MoveCamera1c, 0;
		else __ASSERT_FALSE();
	}
	
	state MoveCamera1a
	{
		m_nCamera = 0;
		
		if ( m_nCamera == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 16, 128, 52, 0, 300, false);
		else if ( m_nCamera == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 18, 128, 33, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera2a, 300;
	}
	
	state MoveCamera2a
	{
		if ( m_nCamera == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 16,   0, 52, 0, 300, false);
		else if ( m_nCamera == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 18,   0, 29, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera, 300;
	}
	
    state MoveCamera1b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 15, 192, 52, 0, 150, false);
		
		return MoveCamera2b, 150;
	}
	
    state MoveCamera2b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 24, 128, 52, 0, 150, false);
		
		return MoveCamera3b, 150;
	}
	
    state MoveCamera3b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 28, 64, 52, 0, 150, false);
		
		return MoveCamera4b, 150;
	}
	
    state MoveCamera4b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 22, 0, 52, 0, 150, false);
		
		return MoveCamera, 150;
	}
	
    state MoveCamera1c
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 14,  23, 42, 0, 470, false);
		
		return MoveCamera2c, 470;
	}
	
    state MoveCamera2c
	{
		m_pPlayer.DelayedLookAt(GetLeft()+33, GetTop()+31, 10,   7, 53, 0, 100, false);
		
		return MoveCamera3c, 100;
	}
	
    state MoveCamera3c
	{
		m_pPlayer.DelayedLookAt(GetLeft()+30, GetTop()+32, 10, 225, 53, 0, 150, false);
		
		return MoveCamera4c, 150;
	}
	
    state MoveCamera4c
	{
		m_pPlayer.DelayedLookAt(GetLeft()+29, GetTop()+35, 10, 176, 52, 0, 150, false);
		
		return MoveCamera5c, 150;
	}
	
    state MoveCamera5c
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+34, 12,   0, 45, 0, 412, false);
		
		return MoveCamera, 412;
	}
	
	event Timer0()
	{
		m_pPlayer.SetMoney(0);
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
		CreateRandomAttack(4+Rand(4), 0+Rand(4));
	}
	
	event Timer2()
	{
		CreateRandomAttack(4+Rand(4), 0+Rand(4));
	}
	
	event Timer3()
	{
		CreateRandomAttack(4+Rand(4), 0+Rand(4));
	}
	
	event Timer4()
	{
		CreateRandomAttack(4+Rand(4), 0+Rand(4));
	}
	
	event Timer5()
	{
		platoon platTmp;
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 4, "RPG_BANDIT_FOOTMAN2" , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 4, "RPG_BANDIT_SPEARMAN", 1);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 0);
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 5, "RPG_BANDIT_HUNTER3" , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 5, "RPG_BANDIT_FOOTMAN2"  , 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 1);
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 6, "RPG_BANDIT_HUNTER3"   , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 6, "RPG_BANDIT_WOODCUTTER", 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 2);
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 7, "RPG_BANDIT_WOODCUTTER", 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 7, "DOG"  , 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 3);
	}
	
	event UnitDestroyed(unitex uUnit)
	{
		int nTmp;
		int i;
		
		for ( i=0; i<=7; ++i )
		{
			if ( uUnit == m_auFootman[i] )
			{
				if ( i == 3 && Rand(5) == 0 )
				{
					m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 4+Rand(4), "PRIEST");
				}
				else
				{
					nTmp = Rand(5+2+2+2);

					if ( nTmp <  5 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 4+Rand(4), "RPG_BANDIT_FOOTMAN2"   );
					else if ( nTmp <  7 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 4+Rand(4), "RPG_BANDIT_HUNTER3");
					else if ( nTmp <  9 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 4+Rand(4), "RPG_BANDIT_WOODCUTTER"    );
					else if ( nTmp < 11 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 4+Rand(4), "DOG"  );
					else __ASSERT_FALSE();
				}
				
				CommandMoveAndDefendUnitToMarker(m_auFootman[i], i);
			}
		}
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

