#include <YSI_Coding\y_hooks>

new

Float:	atr_OldPos	[MAX_PLAYERS][3],
Float:	atr_SetPos	[MAX_PLAYERS][3],
bool:	atr_Set		[MAX_PLAYERS],
bool:	atr_Detect	[MAX_PLAYERS],
Timer:	atr_Check	[MAX_PLAYERS];

hook OnPlayerConnect(playerid){   
	atr_OldPos	[playerid][0]	=
	atr_OldPos	[playerid][1]	=
	atr_OldPos	[playerid][2]	= 0.0;

	atr_Detect	[playerid]		=
	atr_Set		[playerid] 	 	= false;
}

hook OnPlayerUpdate(playerid){

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	if(atr_Set[playerid])
	{
		if(atr_SetPos[playerid][0] != x || atr_SetPos[playerid][1] != y || atr_SetPos[playerid][2] != z)
			SetPlayerPos(playerid, atr_SetPos[playerid][0], atr_SetPos[playerid][1], atr_SetPos[playerid][2]);
		else 
			atr_Set[playerid] = false;

		return 1;
	}

	if(!atr_Detect[playerid] && !IsAtConnectionPos(x, y, z) && !IsPlayerOnAdminDuty(playerid))
	{
		new colision;

		if(Distance(x, y, z, atr_OldPos[playerid][0], atr_OldPos[playerid][1], atr_OldPos[playerid][2]) >= 45.0)
			colision = 1;
		else {
			new Float:tmp;

			colision = 
			CA_RayCastLine(atr_OldPos[playerid][0] + 0.15, atr_OldPos[playerid][1] + 0.15, atr_OldPos[playerid][2] + 0.6, x - 0.15, y - 0.15, z - 0.05, tmp, tmp, tmp);
		}

		if(colision != WATER_OBJECT && colision)
		{
			ChatMsgAdmins(5, RED, "[Anti-Raid] %p(id:%d) Atravessou um objeto. Posição: %0.1f, %0.1f, %0.1f, id: %d", playerid, playerid, x, y, z, colision);

			atr_Detect[playerid] = true;
			stop atr_Check[playerid];
			atr_Check[playerid] = defer AntiRaidCheck(playerid);
			return 1;
		}
		else {
			atr_OldPos[playerid][0] = x;
			atr_OldPos[playerid][1] = y;
			atr_OldPos[playerid][2] = z;
		}
	}

	return 1;
}

ORPC:12(playerid, BitStream:bs){
	if(!IsPlayerConnected(playerid))
	    return 0;

	atr_Set[playerid] = true;

	BS_ReadValue(bs,
		PR_FLOAT, atr_SetPos[playerid][0],
		PR_FLOAT, atr_SetPos[playerid][1],
		PR_FLOAT, atr_SetPos[playerid][2]
	);

	atr_OldPos[playerid][0] = atr_SetPos[playerid][0];
	atr_OldPos[playerid][1] = atr_SetPos[playerid][1];
	atr_OldPos[playerid][2] = atr_SetPos[playerid][2];

	return 1;
}

timer AntiRaidCheck[1500](playerid){
	if(IsPlayerConnected(playerid) && atr_Detect[playerid]) {
		new Float:x, Float:y, Float:z, Float:tmp;
		GetPlayerPos(playerid, x, y, z);
		if(!CA_RayCastLine(atr_OldPos[playerid][0], atr_OldPos[playerid][1], atr_OldPos[playerid][2], x, y, z, tmp, tmp, tmp) ||
			!CA_RayCastLine(x, y, z, x, y, z + 600.0, tmp, tmp, tmp)) {
				atr_OldPos[playerid][0] = x;
				atr_OldPos[playerid][1] = y;
				atr_OldPos[playerid][2] = z;
				atr_Detect[playerid] = false;
		} else atr_Check[playerid] = defer AntiRaidCheck(playerid);
	}
}


hook OnPlayerSave(playerid, filename[])
	modio_push(filename, _T<A,R,A,D>, 3, _:atr_OldPos[playerid]);

hook OnPlayerLoad(playerid, filename[])
	modio_read(filename, _T<A,R,A,D>, 3, _:atr_OldPos[playerid]);


AntiRaidWarn(playerid)
{
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), "Sair", "");
	return Y_HOOKS_BREAK_RETURN_1;
}


stock bool:IsPlayerRaidBlock(playerid)
	return atr_Detect[playerid];


/*==============================================================================

	Cancel Actions

==============================================================================*/

IRPC:115(playerid, BitStream:bs){
	if(atr_Detect[playerid])
		return 0;
	return 1;
}

IRPC:131(playerid, BitStream:bs){
	if(atr_Detect[playerid])
		return 0;
	return 1;
}

IRPC:26(playerid, BitStream:bs){
	if(atr_Detect[playerid])
		return 0;
	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid){
	if(IsPlayerConnected(playerid))
		if(atr_Detect[playerid])
			return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	if(atr_Detect[playerid])
		return AntiRaidWarn(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}