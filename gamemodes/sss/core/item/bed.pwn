
#include <YSI_Coding\y_hooks>

static 
Item:	Bed_Item[MAX_PLAYERS] = {Item:INVALID_ITEM_ID, ...},
Float:	Bed_Pos[MAX_PLAYERS][3];

hook OnPlayerConnect(playerid)
	Bed_Pos[playerid][0] = Bed_Pos[playerid][1] = Bed_Pos[playerid][2] = 0.0;

hook OnPlayerSave(playerid, filename[])
	modio_push(filename, _T<B,E,D,P>, 3, _:Bed_Pos[playerid]);

hook OnPlayerLoad(playerid, filename[])
	modio_read(filename, _T<B,E,D,P>, 3, _:Bed_Pos[playerid]);

hook OnPlayerSpawnNewChar(playerid){
	if(Bed_Pos[playerid][0] != 0.0){
		new 
			Item:item[BTN_MAX_INRANGE],
			size;
	
		size = GetItemsInRange(Bed_Pos[playerid][0], Bed_Pos[playerid][1], Bed_Pos[playerid][2], 1.0, item);

		if(size > 0) {
			for(new i; i < size; i++)
			{
				if(!IsValidItem(item[i]))
					continue;

				if(GetItemType(item[i]) != item_Bed)
					continue;

				BedCheck(playerid, item[i], true);
				return 1;
			}
		}

		ChatMsgLang(playerid, RED, "BEDDESTRO");
		Bed_Pos[playerid][0] = Bed_Pos[playerid][1] = Bed_Pos[playerid][2] = 0.0;
	}
	return 1;
}

BedCheck(playerid, Item:itemid, bool:spawn = false){
	if(!IsPlayerSpawned(playerid))
	    return 0;

	if(Bed_Item[playerid] != INVALID_ITEM_ID)
		return 0;

	if(!spawn){
		new hour, minute;
		gettime(hour, minute);
		
		if(hour < 20 && hour > 8) {
			ShowActionText(playerid, ls(playerid, "SLEPHOUR"), 6000);
			return 0;
		}
	}

	foreach(new i : Player)
		if(Bed_Item[i] == itemid)
			return 0;
			
	UnfreezePlayer(playerid);
	
	new Float:rz, Float:tmp;

	GetItemPos(itemid, Bed_Pos[playerid][0], Bed_Pos[playerid][1], Bed_Pos[playerid][2]);
    GetItemRot(itemid, rz, rz, rz);

	SetPlayerFacingAngle(playerid, rz + 90.0);

	// Any collision between player and bed. Cancel action
	if(CA_RayCastLine(Bed_Pos[playerid][0], Bed_Pos[playerid][1], Bed_Pos[playerid][2],
		Bed_Pos[playerid][0] + 2.45 * floatsin(-rz + 7.0, degrees),
		Bed_Pos[playerid][1] + 2.30 * floatcos(-rz, degrees), Bed_Pos[playerid][2] + 1.0, tmp, tmp, tmp)) 
			return 0;

	SetPlayerPos(playerid,
		Bed_Pos[playerid][0] + 2.45 * floatsin(-rz + 7.0, degrees),
		Bed_Pos[playerid][1] + 2.30 * floatcos(-rz, degrees),
		Bed_Pos[playerid][2] + 1.0);

	ApplyAnimation(playerid,"CRACK","crckdeth2", 4.1, 0, 1, 1, 1, 0, 1);

    Bed_Item[playerid] = itemid;
	SetPlayerBrightness(playerid, 255);
	
    StartHoldAction(playerid, spawn ? (5 * 1000) : (30 * 1000) );
	return 1;
}

hook OnHoldActionUpdate(playerid, progress){
	if(IsValidItem(Bed_Item[playerid])) {
		if(GetPlayerAnimationIndex(playerid) != 386 && GetPlayerAnimationIndex(playerid) != 0 &&
			GetPlayerAnimationIndex(playerid) != 1183){
			new Float:rz;

			GetItemRot(Bed_Item[playerid], rz, rz, rz);

			SetPlayerPos(playerid,
				Bed_Pos[playerid][0] + 2.45 * floatsin(-rz + 7.0, degrees),
				Bed_Pos[playerid][1] + 2.30 * floatcos(-rz, degrees),
				Bed_Pos[playerid][2] + 1.0);

			ApplyAnimation(playerid,"CRACK","crckdeth2", 4.1, 0, 1, 1, 1, 0, 1);
		}
		SetPlayerBrightness(playerid, 200 - (progress / (300)) );
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid){
	if(IsValidItem(Bed_Item[playerid])) {
		ClearAnimations(playerid, 1);
		GetItemPos(Bed_Item[playerid], Bed_Pos[playerid][0], Bed_Pos[playerid][1], Bed_Pos[playerid][2]);

		SetPlayerPos(playerid, Bed_Pos[playerid][0], Bed_Pos[playerid][1], Bed_Pos[playerid][2] + 0.9);

		Bed_Item[playerid] = INVALID_ITEM_ID;

		SetPlayerHP(playerid, 100.0);
		SetPlayerFP(playerid, GetPlayerFP(playerid) + 30);

		UpdatePlayerMap(playerid);

		ClearAnimations(playerid);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Bed)
	{
		BedCheck(playerid, itemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_Bed)
	{
		new ItemType:type = GetItemType(itemid);
		
		if(type == item_Crowbar || IsItemTypeCarry(type))
			return Y_HOOKS_CONTINUE_RETURN_0;

		BedCheck(playerid, withitemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock GetPlayerBedPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(Bed_Pos[playerid][0] == 0.0)
		return 0;

	x = Bed_Pos[playerid][0];
	y = Bed_Pos[playerid][1];
	z = Bed_Pos[playerid][2];

	return 1;
}

stock IsPlayerSleeping(playerid)
{
	if(Bed_Item[playerid] != INVALID_ITEM_ID)
	    return 1;

	return 0;
}
