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

	if(atr_Check[playerid]){
		if(CA_RayCastLine(atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid], x, y, z, tmp, tmp, tmp) &&
			CA_RayCastLine(x, y, z, x, y, z + 600.0, tmp, tmp, tmp))
			return 1;

		atr_Check[playerid] = 0;
		atr_SetX[playerid] = x;
		atr_SetY[playerid] = y;
		atr_SetZ[playerid] = z;
	} else {
		new col = CA_RayCastLine(atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid], x, y, z, tmp, tmp, tmp);
		if(col != WATER_OBJECT && col){
			atr_Check[playerid] = col;
			
			if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
				return 1;

			if(IsPlayerDead(playerid))
				return 1;
				
			if(GetPlayerAdminLevel(playerid) > 0) return 1;

			ChatMsgAdmins(6, RED, "%p(id:%d) Atravessou um objeto, modelid: %d", playerid, playerid, atr_Check[playerid]);
		}
		else {
			atr_SetX[playerid] = x;
			atr_SetY[playerid] = y;
			atr_SetZ[playerid] = z;
		}
	}

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
	if(atr_Check[playerid]) {
		ClearAnimations(playerid);
		new BitStream:bss = BS_New();
		BS_WriteValue(bss,
			PR_FLOAT, atr_SetX[playerid],
			PR_FLOAT, atr_SetY[playerid],
			PR_FLOAT, atr_SetZ[playerid]
		);
		PR_SendRPC(bss, playerid, 12);
		BS_Delete(bss);
		return 0;
	}
	return 1;
}

AntiRaidWarn(playerid){
	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
		return 0;

	inline Response(pid, dialogid, response, listitem, string:inputtext[]){
		#pragma unused pid, dialogid, listitem, inputtext
		if(response)
		{
			/*if(!IsAtConnectionPos(atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid]))
			{
				new BitStream:bs = BS_New();
				BS_WriteValue(bs,
					PR_FLOAT, atr_SetX[playerid],
					PR_FLOAT, atr_SetY[playerid],
					PR_FLOAT, atr_SetZ[playerid]
				);
				PR_SendRPC(bs, playerid, 12);
				BS_Delete(bs);
			} else GetPlayerPos(playerid, atr_SetX[playerid], atr_SetY[playerid], atr_SetZ[playerid]);*/
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX,
		"Anti-Raid Protection", ls(playerid, "ANTRAIDP"), ""C_RED"Voltar", "Sair");

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	if(atr_Check[targetid]){
		AntiRaidWarn(targetid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid){
	if(IsPlayerConnected(playerid)){
		if(atr_Check[playerid]){
			AntiRaidWarn(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	if(atr_Check[playerid]){
		AntiRaidWarn(playerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerRaidBlock(playerid)
	return atr_Check[playerid];