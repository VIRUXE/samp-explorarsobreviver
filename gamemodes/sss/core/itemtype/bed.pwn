/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

#define TIME_SLEEP 	(30)

static Item:Bed_Item[MAX_PLAYERS] = {Item:INVALID_ITEM_ID, ...};

BedCheck(playerid, Item:itemid){
	if(!IsPlayerSpawned(playerid))
	    return 0;

	if(Bed_Item[playerid] != INVALID_ITEM_ID)
		return 0;

	new 
		Float:x, Float:y, Float:z,
		Float:rz, Float:tmp;

 	GetItemPos(itemid, x, y, z);
    GetItemRot(itemid, rz, rz, rz);

	SetPlayerFacingAngle(playerid, rz + 90.0);

	// Any collision between player and bed. Cancel action
	if(CA_RayCastLine(x, y, z,
		x + 2.45 * floatsin(-rz + 7.0, degrees), y + 2.30 * floatcos(-rz, degrees), z + 1.0, tmp, tmp, tmp))
		return 0;

	SetPlayerPos(playerid, x + 2.45 * floatsin(-rz + 7.0, degrees), y + 2.30 * floatcos(-rz, degrees), z + 1.0);
    Bed_Item[playerid] = itemid;
    StartHoldAction(playerid, TIME_SLEEP * 1000);
	return 1;
}

hook OnHoldActionUpdate(playerid, progress){
	if(IsValidItem(Bed_Item[playerid])) {
		ApplyAnimation(playerid,"CRACK","crckdeth2", 10.1, 0, 1, 1, 1, 0, 1);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid){
	if(IsValidItem(Bed_Item[playerid])) {
		ClearAnimations(playerid);
		new Float:x, Float:y, Float:z;
		GetItemPos(Bed_Item[playerid], x, y, z);
		SetPlayerPos(playerid, x, y, z + 0.9);
		Bed_Item[playerid] = INVALID_ITEM_ID;

		// TODO: Implement more functions
		SetPlayerHP(playerid, 100.0);

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

stock IsPlayerSleeping(playerid)
{
	if(Bed_Item[playerid] != INVALID_ITEM_ID)
	    return 1;

	return 0;
}
