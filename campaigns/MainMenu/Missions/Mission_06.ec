mission "translateMM03"
{
    state Initialize;
    state MoveCamera1;
    state MoveCamera2;
    state MoveCamera3;
    state MoveCamera4;
    state MoveCamera5;
    state MoveCamera6;
    state MoveCamera7;
    state MoveCamera8;
    state MoveCamera9;
    state MoveCamera10;
    state MoveCamera11;
    state MoveCamera12;
	
	#include "..\..\Common.ech"
	
	player m_pPlayer;
	player m_pEnemy;
	player m_pGates;
	
	unitex m_auFootman[];
	
	function void CreateRandomAttack(int nFromMarker, int nToMarker)
	{
		platoon platTmp;
		int nTmp;
		
		if ( m_pEnemy.GetNumberOfUnits() > 7 ) return;
		
		nTmp = Rand(4);
		
		if ( nFromMarker == 8 )
		{
			if ( nTmp == 0 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WOLF"     , 1+Rand(4));
			else if ( nTmp == 1 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WHITEWOLF", 1+Rand(2));
			else if ( nTmp == 2 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "BROWNWOLF", 1+Rand(3));
			else if ( nTmp == 3 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "BEAR"     , 1        );
			else __ASSERT_FALSE();
		}
		else
		{
			if ( nTmp == 0 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "SKELETON1"        , 1+Rand(3));
			else if ( nTmp == 1 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "SKELETON_HUNTER"  , 1+Rand(3));
			else if ( nTmp == 2 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "SKELETON_SPEARMAN", 1+Rand(3));
			else if ( nTmp == 3 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "SKELETON3"        , 1        );
			else __ASSERT_FALSE();
		}
		
		
		CommandMoveAndDefendPlatoonToMarker(platTmp, nToMarker);
	}
	
    state Initialize
    {
		m_pPlayer = GetPlayer(1);
		m_pEnemy = GetPlayer(0);
		m_pGates = GetPlayer(2);
		
		m_pPlayer.EnableAI(false);
		m_pEnemy.EnableAI(false);
		m_pGates.EnableAI(false);
		
		SetEnemies(m_pPlayer, m_pEnemy);
		SetAlly(m_pPlayer, m_pGates);
		SetAlly(m_pEnemy , m_pGates);
		
		m_pPlayer.SpyPlayer(m_pEnemy, true, -1);
		
		SetTime(100);
		
		EnableAssistant(0xffffff, false);
        EnableCameraMovement(false);
		
		SetAllBridgesImmortal(true);

		m_pPlayer.LookAt(GetLeft()+21, GetTop()+43, 10, 160, 42, 0);
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
		
		m_auFootman[0] = CreateUnitAtMarker(m_pPlayer, 0, "FOOTMAN");
		m_auFootman[1] = CreateUnitAtMarker(m_pPlayer, 1, "FOOTMAN");
		m_auFootman[2] = CreateUnitAtMarker(m_pPlayer, 2, "PRIESTESS");
		m_auFootman[3] = CreateUnitAtMarker(m_pPlayer, 3, "HUNTER");
		
		SetTimer(0,  100);
		SetTimer(7, 5000);
		
		SetTimer(1, 1000);
		SetTimer(2,  800);
		SetTimer(3, 1300);
		SetTimer(4, 9999);
		SetTimer(5, 9000);
		
		CreateRandomAttack(4, 5);
		
		return MoveCamera1, 20;
	}
	
	state MoveCamera1
	{
		m_pPlayer.DelayedLookAt(GetLeft()+21, GetTop()+43, 10, 139, 37, 0, 25, false);
		
		return MoveCamera2, 25;
	}
	
	state MoveCamera2
	{
		m_pPlayer.DelayedLookAt(GetLeft()+22, GetTop()+44, 10, 90, 15, 0, 50, false);
		
		return MoveCamera3, 50;
	}
	
	state MoveCamera3
	{
		m_pPlayer.DelayedLookAt(GetLeft()+26, GetTop()+43, 8, 10, 35, 0, 50, false);
		
		return MoveCamera4, 50;
	}
	
	state MoveCamera4
	{
		m_pPlayer.DelayedLookAt(GetLeft()+23, GetTop()+35, 8, 0, 45, 0, 50, false);
		
		return MoveCamera5, 50;
	}
	
	state MoveCamera5
	{
		m_pPlayer.DelayedLookAt(GetLeft()+23, GetTop()+29, 8, 0, 45, 0, 50, false);
		
		return MoveCamera6, 50;
	}
	
	state MoveCamera6
	{
		m_pPlayer.DelayedLookAt(GetLeft()+28, GetTop()+25, 10, 46, 42, 0, 50, true);
		
		return MoveCamera7, 50;
	}
	
	state MoveCamera7
	{
		m_pPlayer.DelayedLookAt(GetLeft()+34, GetTop()+26, 12, 74, 40, 0, 50, true);
		
		return MoveCamera8, 50;
	}
	
	state MoveCamera8
	{
		m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 0, 35, 0, 50, false);
		
		return MoveCamera9, 50;
	}
	
	state MoveCamera9
	{
		int nTmp;
		
		nTmp = Rand(2);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 192, 35, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 10, 192, 45, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera10, 300;
	}
	
	state MoveCamera10
	{
		int nTmp;
		
		nTmp = Rand(2);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 128, 35, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 10, 128, 45, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera11, 300;
	}
	
	state MoveCamera11
	{
		int nTmp;
		
		nTmp = Rand(2);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 64, 35, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 18, 64, 30, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera12, 300;
	}
	
	state MoveCamera12
	{
		int nTmp;
		
		nTmp = Rand(2);
		
		if ( nTmp == 0 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 0, 35, 0, 300, false);
		else if ( nTmp == 1 ) m_pPlayer.DelayedLookAt(GetLeft()+37, GetTop()+28, 15, 0, 35, 0, 300, false);
		else __ASSERT_FALSE();
		
		return MoveCamera9, 300;
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
		CreateRandomAttack(4, 5);
	}
	
	event Timer2()
	{
		CreateRandomAttack(6, 7);
	}
	
	event Timer3()
	{
		CreateRandomAttack(8, 9);
	}
	
	event Timer4()
	{
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
				if ( false && Rand(5) == 0 )
				{
					m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 10, "KNIGHT");
				}
				else
				{
					nTmp = Rand(5+2+2+2);
					
					if ( nTmp <  5 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 10, "FOOTMAN"   );
					else if ( nTmp <  7 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 10, "PRIESTESS" );
					else if ( nTmp <  9 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 10, "HUNTER"    );
					else if ( nTmp < 11 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, 10, "SPEARMAN"  );
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
