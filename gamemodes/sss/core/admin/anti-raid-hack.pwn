#include <YSI_Coding\y_hooks>

new
	atr_Check[MAX_PLAYERS],
	Float:atr_SetX[MAX_PLAYERS],
	Float:atr_SetY[MAX_PLAYERS],
	Float:atr_SetZ[MAX_PLAYERS],
	Timer:AntiRaidTimer[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
    atr_Check[playerid] = 1;

public OnIncomingPacket(playerid, packetid, BitStream:bs){
	// ONFOOT_SYNC
	if(packetid == 207){
     	new data[PR_OnFootSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadOnFootSync(bs, data);
		atr_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}
	// DRIVER_SYNC
	if(packetid == 200){
	    new data[PR_InCarSync];
		BS_IgnoreBits(bs, 8);
		BS_ReadInCarSync(bs, data);
		atr_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}
	// PASSENGER_SYNC
	if(packetid == 211){
		new data[PR_PassengerSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadPassengerSync(bs, data);
		atr_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}
	return 1;
}

atr_PosCheck(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid))
	    return 0;

	if(IsPlayerInTutorial(playerid) || IsPlayerOnAdminDuty(playerid)){
		atr_Check[playerid] = 0;
		return 1;
	}

	new Float:tmp;

	if(atr_Check[playerid])
	{
		if(GetPlayerCurrentInt(playerid) != -1)
		{
			GetPropertyExit( GetPlayerCurrentInt(playerid), atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid] );
		}
		else if(CA_RayCastLine(x, y, z, x, y, z + 600.0, tmp, tmp, tmp))
		{
			if(atr_Check[playerid] == 50 || atr_Check[playerid] == 100)
			{
				new name[MAX_PLAYER_NAME];
				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				ReportPlayer(name, "Atravessou algum objeto", -1, "Anti-Raid", x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			}
			atr_Check[playerid] ++;
			StopHoldAction(playerid);
			return 1;
		}
		atr_Check[playerid] = 0;
		atr_SetX[playerid] = x;
		atr_SetY[playerid] = y;
		atr_SetZ[playerid] = z;
		return 1;
	}
	else
	{
		new col = CA_RayCastLine(atr_SetX[playerid] + 0.15, atr_SetY[playerid] + 0.15, atr_SetZ[playerid] + 0.3, x - 0.15, y - 0.15, z - 0.3, tmp, tmp, tmp);

		if(col != WATER_OBJECT && col)
		{
			atr_Check[playerid] = 1;
			return 1;
		}
	}

	atr_SetX[playerid] = x;
	atr_SetY[playerid] = y;
	atr_SetZ[playerid] = z;

	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = atr_Check[playerid];
	modio_push(filename, _T<A,R,A,D>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];
	modio_read(filename, _T<A,R,A,D>, 1, data);

	atr_Check[playerid] = data[0];
	stop AntiRaidTimer[playerid];
	AntiRaidTimer[playerid] = defer SetPlayerAntiRaid(playerid, data[0], 0);
}

timer SetPlayerAntiRaid[500](playerid, check, timer)
{
	atr_Check[playerid] = check;

	if(timer < 5)
		AntiRaidTimer[playerid] = defer SetPlayerAntiRaid(playerid, check, timer + 1);	
}

//SetPlayerPos
ORPC:12(playerid, BitStream:bs){
	if(!IsPlayerConnected(playerid))
	    return 0;
	    
	atr_Check[playerid] = 0;

	BS_ReadValue(bs,
		PR_FLOAT, atr_SetX[playerid],
		PR_FLOAT, atr_SetY[playerid],
		PR_FLOAT, atr_SetZ[playerid]
	);

	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if(newinteriorid != 0)
		GetPropertyExit( GetPlayerCurrentInt(playerid), atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid] );

    return 1;
}

// GiveTakeDamage
IRPC:115(playerid, BitStream:bs){
	if(atr_Check[playerid])
		return 0;
	return 1;
}

// OnPlayerPickupPickup
IRPC:131(playerid, BitStream:bs){
	if(atr_Check[playerid])
		return 0;
	return 1;
}

// EnterVehicle
IRPC:26(playerid, BitStream:bs){
	if(atr_Check[playerid]){
		SetPlayerPos(playerid, atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid]);
		return 0;
	}
	return 1;
}
hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	if(atr_Check[targetid])
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(atr_Check[playerid])
		{
			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(atr_Check[playerid])
	{
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"X", "");
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerRaidBlock(playerid)
	return atr_Check[playerid];