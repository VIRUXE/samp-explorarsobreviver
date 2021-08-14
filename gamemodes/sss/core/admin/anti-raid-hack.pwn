#include <YSI_Coding\y_hooks>

new

Float:	atr_OldPos	[MAX_PLAYERS][3],
Float:	atr_SetPos	[MAX_PLAYERS][3],
bool:	atr_Set		[MAX_PLAYERS],
bool:	atr_Detect	[MAX_PLAYERS],
Timer:	atr_Check	[MAX_PLAYERS],
		atr_Wars	[MAX_PLAYERS];

hook OnPlayerConnect(playerid){   
	atr_OldPos	[playerid][0]	=
	atr_OldPos	[playerid][1]	=
	atr_OldPos	[playerid][2]	= 0.0;

	atr_Detect	[playerid]		=
	atr_Set		[playerid] 	 	= false;
	
	atr_Wars	[playerid]		= 0;
}

hook OnPlayerUpdate(playerid){

	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	if(atr_Set[playerid]) {
		if(atr_SetPos[playerid][0] != x || atr_SetPos[playerid][1] != y || atr_SetPos[playerid][2] != z)
			SetPlayerPos(playerid, atr_SetPos[playerid][0], atr_SetPos[playerid][1], atr_SetPos[playerid][2]);
		else 
			atr_Set[playerid] = false;

		return 1;
	}

	if(!atr_Detect[playerid] && !IsPlayerAtConnectionPos(x, y, z) && !IsPlayerOnAdminDuty(playerid)) {
		new colision;

		// Teleport hack or lag
		if(Distance(x, y, z, atr_OldPos[playerid][0], atr_OldPos[playerid][1], atr_OldPos[playerid][2]) >= 45.0)
			colision = 1;
		else {
			new Float:tmp;

			colision = 
			CA_RayCastLine(atr_OldPos[playerid][0] + 0.15, atr_OldPos[playerid][1] + 0.15, atr_OldPos[playerid][2] + 0.6, x - 0.15, y - 0.15, z, tmp, tmp, tmp);
		}

		if(colision != WATER_OBJECT && colision) {
			if(!IsLocationRoof(x, y, z)) {
				if(colision != 1) {
					if(++atr_Wars[playerid] == 3) {
						ReportPlayer(sprintf("%p", playerid), 
							sprintf("Anti Raid: Colidiu com o Objeto id: %d", colision), 
							-1,
							"A-Raid",
							x, y, z,
							GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid),
							"");
							
						atr_Wars[playerid] = 0;
					}
				}
				atr_Detect[playerid] = true;
				stop atr_Check[playerid];
				atr_Check[playerid] = defer AntiRaidCheck(playerid);
			}
		} else {
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
			!IsLocationRoof(x, y, z)) {
				atr_OldPos[playerid][0] = x;
				atr_OldPos[playerid][1] = y;
				atr_OldPos[playerid][2] = z;
				atr_Detect[playerid] = false;
		} else atr_Check[playerid] = defer AntiRaidCheck(playerid);
	}
}

stock IsLocationRoof(Float:x, Float:y, Float:z)
	return CA_RayCastLine(x, y, z, x, y, z + 600.0, x, y, z);

hook OnPlayerSave(playerid, filename[])
	modio_push(filename, _T<A,R,A,D>, 3, _:atr_OldPos[playerid]);

hook OnPlayerLoad(playerid, filename[])
	modio_read(filename, _T<A,R,A,D>, 3, _:atr_OldPos[playerid]);


AntiRaidWarn(playerid) {
	if(!IsPlayerConnected(playerid))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!atr_Detect[playerid])
		return Y_HOOKS_CONTINUE_RETURN_0;
		
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), "Sair", "");
	return Y_HOOKS_BREAK_RETURN_1;
}

stock bool:IsPlayerRaidBlock(playerid)
	return atr_Detect[playerid];


/*==============================================================================

	Cancel Actions

==============================================================================*/

IRPC:115(playerid, BitStream:bs)
	return atr_Detect[playerid];

IRPC:131(playerid, BitStream:bs)
	return atr_Detect[playerid];

IRPC:26(playerid, BitStream:bs)
	return atr_Detect[playerid];

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
	return AntiRaidWarn(playerid);

hook OnPlayerPickUpItem(playerid, Item:itemid)
	return AntiRaidWarn(playerid);

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
	return AntiRaidWarn(playerid);

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
	return AntiRaidWarn(playerid);

hook OnPlayerOpenInventory(playerid)
	return AntiRaidWarn(playerid);

hook OnPlayerOpenContainer(playerid, Container:containerid)
	return AntiRaidWarn(playerid);

hook OnPlayerUseItem(playerid, Item:itemid)
	return AntiRaidWarn(playerid);

hook OnPlayerDropItem(playerid, Item:itemid)
	return AntiRaidWarn(playerid);