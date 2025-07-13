mission "translateB_TEST"
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
    state Exit1;
    state Exit2;
    state Nothing;

	#include "..\..\Common.ech"

	player m_pPlayer;
	player m_pEnemy;

	unitex m_PlayerUnit1;
	unitex m_PlayerUnit2;
	unitex m_PlayerUnit3;
	
	unitex m_Unit1;
	unitex m_Unit2;
	unitex m_Unit3;
	unitex m_Unit4;
	unitex m_Unit5;
	unitex m_Unit6;

    int m_nFrameRateSum;
    int m_nFrameRateCnt;

	consts
	{
		markerStart = 0;
		markerGate  = 5;
	}

    state Initialize
    {
		m_pPlayer = GetPlayer(2);
		m_pEnemy = GetPlayer(0);

		m_pPlayer.EnableAI(false);
		m_pEnemy.EnableAI(false);

		SetNeutrals(m_pPlayer, m_pEnemy);
	
		m_Unit1 = GetUnitAtMarker(1);
		m_Unit2 = GetUnitAtMarker(2);
		m_Unit3 = GetUnitAtMarker(3);
		m_Unit4 = GetUnitAtMarker(4);
		m_Unit5 = GetUnitAtMarker(8);
		m_Unit6 = GetUnitAtMArker(9);
		
		m_PlayerUnit1 = GetUnitAtMarker(0);
		m_PlayerUnit2 = GetUnitAtMarker(6);
		m_PlayerUnit3 = GetUnitAtMarker(7);
		
		OPEN_GATE(markerGate);

		SetTime(100);

//		CallCamera();		
				
	 	EnableAssistant(0xffffff, false);
        EnableInterface(false);
        EnableCameraMovement(false);

   		m_pPlayer.LookAt(GetLeft()+23, GetTop()+77, 30, 55, 45, 0);
		ShowArea(m_pPlayer.GetIFF(), (GetLeft() + GetRight())/2, (GetTop() + GetBottom())/2, 0, 256);
	
		m_PlayerUnit1.CommandMove(51, 68, 0);
		m_PlayerUnit2.CommandMove(51, 68, 0);
		m_PlayerUnit3.CommandMove(51, 68, 0);

        SetTimer(0, 1);
				
		return MoveCamera1, 20;
	}

	state MoveCamera1
	{	   		
		m_PlayerUnit1.CommandMove(54, 62, 0);
		m_PlayerUnit2.CommandMove(54, 62, 0);
		m_PlayerUnit3.CommandMove(54, 62, 0);
	
		m_pPlayer.DelayedLookAt(GetLeft()+30, GetTop()+77, 25, 45, 45, 0, 40, false);
		return MoveCamera2, 38;
	}

	state MoveCamera2
	{
		m_PlayerUnit1.CommandMove(GetPointX(markerGate),GetPointY(markerGate),GetPointZ(markerGate));
		m_PlayerUnit2.CommandMove(GetPointX(markerGate),GetPointY(markerGate),GetPointZ(markerGate));
		m_PlayerUnit3.CommandMove(GetPointX(markerGate),GetPointY(markerGate),GetPointZ(markerGate));
		
		m_pPlayer.DelayedLookAt(GetLeft()+45, GetTop()+72, 25, 35, 43, 0, 50, false);
		return MoveCamera3, 48;
	}

	state MoveCamera3
	{
		m_pPlayer.DelayedLookAt(GetLeft()+60, GetTop()+69, 25, 20, 43, 0, 45, false);	
		return MoveCamera4, 43;
	}

	state MoveCamera4
	{
		m_pPlayer.DelayedLookAt(GetLeft()+72, GetTop()+64, 25, 240, 43, 0, 70, false);	
		return MoveCamera5, 68;
	}

	state MoveCamera5
	{
		m_pPlayer.DelayedLookAt(GetLeft()+75, GetTop()+62, 25, 210, 43, 0, 50, false);			
		SetEnemies(m_pPlayer, m_pEnemy);						
		m_Unit1.CommandMove(70, 48, 0);
		m_Unit2.CommandMove(70, 48, 0);
		m_Unit3.CommandMove(70, 49, 0);
		m_Unit4.CommandMove(70, 49, 0);
		m_Unit5.CommandMove(70, 49, 0);
		m_Unit6.CommandMove(70, 49, 0);

		m_Unit1.CommandAttackOnPoint(71, 52, 0);
		m_Unit2.CommandAttackOnPoint(71, 52, 0);
		m_Unit3.CommandAttackOnPoint(71, 52, 0);
		m_Unit4.CommandAttackOnPoint(71, 52, 0);
		m_Unit5.CommandAttackOnPoint(71, 52, 0);
		m_Unit6.CommandAttackOnPoint(71, 52, 0);

		return MoveCamera6, 48;
	}

	state MoveCamera6
	{	
		
		m_pPlayer.DelayedLookAt(GetLeft()+75, GetTop()+58, 25, 190, 43, 0, 30, false);	
		return MoveCamera7, 28;
	}

	state MoveCamera7
	{
		m_pPlayer.DelayedLookAt(GetLeft()+73, GetTop()+56, 25, 170, 43, 0, 30, false);	
		return MoveCamera8, 28;
	}

	state MoveCamera8
	{
		m_pPlayer.DelayedLookAt(GetLeft()+73, GetTop()+52, 25, 140, 43, 0, 45, false);		

		CLOSE_GATE(markerGate);
		return MoveCamera9, 40;
	}

	state MoveCamera9
	{
		m_pPlayer.DelayedLookAt(GetLeft()+70, GetTop()+50, 25, 65, 43, 0, 130, false);		
		return Exit1, 160 - 30;	
	}

    state Exit1
    {
        return Exit2, 30;
    }

    state Exit2
    {
		//EndMission(true);
        CloseProgram(m_nFrameRateSum/m_nFrameRateCnt);
		return Nothing, 20;
    }

    state Nothing
    {
		return Nothing, 20;
    }

    event Timer0()
    {
        int nFrameRate;

        if (GetMissionTime() > 80)
        {
            nFrameRate = GetCurrentFrameRate();
            m_nFrameRateSum = m_nFrameRateSum + nFrameRate;
            ++m_nFrameRateCnt;
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

