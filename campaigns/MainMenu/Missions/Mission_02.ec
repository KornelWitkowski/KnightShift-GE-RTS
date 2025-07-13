#define NO_DEBUG

mission "translateMM02"
{
    state Initialize;
    state MoveCamera;
	
    state MoveCamera1a;
    state MoveCamera2a;
    state MoveCamera3a;
    state MoveCamera4a;
	
    state MoveCamera1b;
    state MoveCamera2b;
    state MoveCamera3b;
    state MoveCamera4b;
    state MoveCamera5b;
    state MoveCamera6b;
    state MoveCamera7b;
	
	#include "..\..\Common.ech"
	
	player m_pPlayer;
	player m_pEnemy;
	
	unitex m_auFootman[];
	
	function void CreateRandomAttack(int nFromMarker, int nToMarker)
	{
		platoon platTmp;
		int nTmp;
		unitex uTmp;
		
		if ( m_pEnemy.GetNumberOfUnits() > 9 )
		{
			uTmp = CreateUnitAtMarker(m_pPlayer, 8, "FOOTMAN");
			CommandMoveAndDefendPlatoonToMarker(platTmp, nToMarker);
			
			uTmp = CreateUnitAtMarker(m_pPlayer, 9, "FOOTMAN");
			CommandMoveAndDefendPlatoonToMarker(platTmp, nToMarker);
		}
		
		nTmp = Rand(4);
		
		if ( nTmp == 0 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "FOOTMAN"   , 1+Rand(2));
		else if ( nTmp == 1 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "SPEARMAN"  , 1+Rand(3));
		else if ( nTmp == 2 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "HUNTER"    , 2+Rand(3));
		else if ( nTmp == 3 ) platTmp = CreateUnitsAtMarker(m_pEnemy, nFromMarker, "WOODCUTTER", 2+Rand(2));
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

		m_pPlayer.LookAt(GetLeft()+45, GetTop()+35, 19, 213, 47, 0);
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
		m_auFootman[2] = CreateUnitAtMarker(m_pPlayer, 2, "SPEARMAN");
		m_auFootman[5] = CreateUnitAtMarker(m_pPlayer, 5, "FOOTMAN");
		m_auFootman[6] = CreateUnitAtMarker(m_pPlayer, 6, "FOOTMAN");
		m_auFootman[7] = CreateUnitAtMarker(m_pPlayer, 7, "SPEARMAN");
		
		SetTimer(0,  100);
		SetTimer(7, 5000);
		
		SetTimer(1, 1000);
		SetTimer(2,  800);
		SetTimer(3, 3000);
		SetTimer(4, 1300);
		SetTimer(5, 9000);
		
		CreateRandomAttack(3, 0+Rand(3));
		CreateRandomAttack(4, 5+Rand(3));
		
		return MoveCamera, 20;
	}
	
	state MoveCamera
	{
		int nTmp;
		
		nTmp = Rand(2);
		
		if ( nTmp == 0 ) return MoveCamera1a, 0;
		else if ( nTmp == 1 ) return MoveCamera1b, 0;
		else __ASSERT_FALSE();
	}
	
	state MoveCamera1a
	{
		m_pPlayer.DelayedLookAt(GetLeft()+21, GetTop()+36, 21, 173, 40, 0, 200, false);
		
		return MoveCamera2a, 200;
	}
	
	state MoveCamera2a
	{
		m_pPlayer.DelayedLookAt(GetLeft()+22, GetTop()+35, 21, 48, 41, 0, 300, false);
		
		return MoveCamera3a, 300;
	}
	
	state MoveCamera3a
	{
		m_pPlayer.DelayedLookAt(GetLeft()+30, GetTop()+32, 22, 27, 40, 0, 160, false);
		
		return MoveCamera4a, 160;
	}
	
	state MoveCamera4a
	{
		m_pPlayer.DelayedLookAt(GetLeft()+45, GetTop()+35, 19, 213, 47, 0, 250, false);
		
		return MoveCamera, 250;
	}
	
    state MoveCamera1b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+36, GetTop()+25, 19, 163, 52, 0, 100, false);
		
		return MoveCamera2b, 100;
	}
	
    state MoveCamera2b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+20, GetTop()+20, 19, 86, 46, 0, 200, false);
		
		return MoveCamera3b, 200;
	}
	
    state MoveCamera3b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+32, GetTop()+29, 10, 102, 45, 0, 150, true);
		
		return MoveCamera4b, 150;
	}
	
    state MoveCamera4b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+28, GetTop()+34, 27, 202, 22, 0, 200, true);
		
		return MoveCamera5b, 200;
	}
	
    state MoveCamera5b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+20, GetTop()+32, 19, 161, 44, 0, 200, false);
		
		return MoveCamera6b, 200;
	}
	
    state MoveCamera6b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+25, GetTop()+35, 21, 44, 45, 0, 200, false);
		
		return MoveCamera7b, 200;
	}
	
    state MoveCamera7b
	{
		m_pPlayer.DelayedLookAt(GetLeft()+45, GetTop()+35, 19, 213, 47, 0, 300, false);
		
		return MoveCamera, 300;
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
		CreateRandomAttack(3, 0+Rand(3));
	}
	
	event Timer2()
	{
		CreateRandomAttack(3, 5+Rand(3));
	}
	
	event Timer3()
	{
		CreateRandomAttack(4, 0+Rand(3));
	}
	
	event Timer4()
	{
		CreateRandomAttack(4, 5+Rand(3));
	}
	
	event Timer5()
	{
	/*
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
		*/
	}
	
	event UnitDestroyed(unitex uUnit)
	{
		int nTmp;
		int i;
		int nMarker;
		
		for ( i=0; i<=7; ++i )
		{
			if ( uUnit == m_auFootman[i] )
			{
				if ( i < 4 ) nMarker = 9; else nMarker = 8;
				
				if ( i == 7 && Rand(5) == 0 )
				{
					m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, nMarker, "KNIGHT");
				}
				else
				{
					nTmp = Rand(5+2+2+2);
					
					if ( nTmp <  5 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, nMarker, "FOOTMAN"   );
					else if ( nTmp <  7 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, nMarker, "WOODCUTTER");
					else if ( nTmp <  9 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, nMarker, "HUNTER"    );
					else if ( nTmp < 11 ) m_auFootman[i] = CreateUnitAtMarker(m_pPlayer, nMarker, "SPEARMAN"  );
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

