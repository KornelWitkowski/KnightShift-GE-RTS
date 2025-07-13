#define NO_DEBUG

mission "translateMM01"
{
    state Initialize;
    state MoveCamera1;
    state MoveCamera2;
    state MoveCamera3;
    state MoveCamera4;
	
	#include "..\..\Common.ech"
	
	player m_pPlayer;
	player m_pEnemy;
	
	unitex m_auFootman[];
	
	function void CreateRandomAttack(int nFromMarker, int nToMarker)
	{
		platoon platTmp;
		int nTmp;
		
		if ( m_pEnemy.GetNumberOfUnits() > 7 ) return;
		
		nTmp = Rand(4);
		
		if ( nTmp == 0 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WOLF"     , 1+Rand(4));
		else if ( nTmp == 1 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WHITEWOLF", 1+Rand(2));
		else if ( nTmp == 2 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "BROWNWOLF", 1+Rand(3));
		else if ( nTmp == 3 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "BEAR"     , 1        );
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
		
		SetTime(100);
		
		EnableAssistant(0xffffff, false);
        EnableCameraMovement(false);
		
		SetAllBridgesImmortal(true);

		m_pPlayer.LookAt(GetLeft()+29, GetTop()+30, 16, 64, 45, 0);
		ShowArea(m_pPlayer.GetIFF(), (GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 0, 256);
		
		// TRACE2("GetCurrentTerrainNum() =", GetCurrentTerrainNum());
		
		if ( GetCurrentTerrainNum() == 5 ) // zima
		{
			Snow((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 64, 600, 1000+Rand(2000), 600, 5+Rand(6));
		}
		else if ( Rand(5) == 0 )
		{
			Rain((GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 64, 600, 1000+Rand(2000), 600, 5+Rand(6));
		}
		
		m_auFootman.Create(8);
		
		m_auFootman[4] = CreateUnitAtMarker(m_pPlayer, 4, "FOOTMAN");
		m_auFootman[5] = CreateUnitAtMarker(m_pPlayer, 5, "FOOTMAN");
		m_auFootman[6] = CreateUnitAtMarker(m_pPlayer, 6, "WOODCUTTER");
		m_auFootman[7] = CreateUnitAtMarker(m_pPlayer, 7, "HUNTER");
		
		SetTimer(0,  100);
		SetTimer(7, 5000);
		
		SetTimer(1, 1000);
		SetTimer(2,  800);
		SetTimer(3, 3000);
		SetTimer(4, 1300);
		SetTimer(5, 9000);
		
		CreateRandomAttack(2, 0);
		
		return MoveCamera1, 20;
	}
	
	state MoveCamera1
	{
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+33, 16, 0, 40, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+33, 23, 0, 25, 0, 300, false);
		else if ( nTmp == 2 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+33,  8, 0, 50, 0, 300, false);
		else __ASSERT_FALSE();
		
		TRACE2("m_pEnemy.GetNumberOfUnits() =", m_pEnemy.GetNumberOfUnits());
		
		return MoveCamera2, 300;
	}
	
	state MoveCamera2
	{
		m_pPlayer.DelayedLookAt(GetLeft()+35, GetTop()+30, 16, 192, 45, 0, 300, false);
		
		return MoveCamera3, 300;
	}
	
	state MoveCamera3
	{
		int nTmp;
		
		nTmp = Rand(3);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+27, 16, 128, 40, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+27,  8, 128, 50, 0, 300, false);
		else if ( nTmp == 2 ) m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+27, 23, 128, 25, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera4, 300;
	}
	
	state MoveCamera4
	{
		m_pPlayer.DelayedLookAt(GetLeft()+29, GetTop()+30, 16,  64, 45, 0, 300, false);
		
		return MoveCamera1, 300;
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
		CreateRandomAttack(2, 0);
	}
	
	event Timer2()
	{
		CreateRandomAttack(3, 1);
	}
	
	event Timer3()
	{
		CreateRandomAttack(3, 1);
	}
	
	event Timer4()
	{
		CreateRandomAttack(9, 10);
	}
	
	event Timer5()
	{
		platoon platTmp;
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 2, "FOOTMAN" , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 2, "SPEARMAN", 1);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 0);
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 3, "FOOTMAN" , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 3, "HUNTER"  , 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 1);
		
		platTmp = CreateUnitsAtMarker(m_pEnemy, 9, "FOOTMAN"   , 1);
		CreateUnitsAtMarker(platTmp,  m_pEnemy, 9, "WOODCUTTER", 2);
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, 10);
	}
	
	event UnitDestroyed(unitex uUnit)
	{
		int nTmp;
		int i;
		
		for ( i=0; i<=7; ++i )
		{
			if ( uUnit == m_auFootman[i] )
			{
				if ( i == 7 && Rand(5) == 0 )
				{
					m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 8, "KNIGHT");
				}
				else
				{
					nTmp = Rand(5+2+2+2);
					
					if ( nTmp <  5 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 8, "FOOTMAN"   );
					else if ( nTmp <  7 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 8, "WOODCUTTER");
					else if ( nTmp <  9 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 8, "HUNTER"    );
					else if ( nTmp < 11 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 8, "SPEARMAN"  );
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

