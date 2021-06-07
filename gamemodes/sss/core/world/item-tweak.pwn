
/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/

#include <YSI_Coding\y_hooks>

forward OnItemTweakUpdate(playerid, itemid);
forward OnItemTweakFinish(playerid, itemid);

static Item:twk_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};

hook OnPlayerConnect(playerid)
	twk_Item[playerid] = INVALID_ITEM_ID;
	
hook OnPlayerDisconnect(playerid, reason)
	TweakFinalise(playerid);

stock TweakItem(playerid, Item:itemid){
	if(twk_Item[playerid] != INVALID_ITEM_ID)
		return 0;
	
	new objectid;
	GetItemObjectID(itemid, objectid);

	for(new i = 0; i < 15; i++)
		SetDynamicObjectMaterial(objectid, i, -1, "none", "none", 0xBE00FF00); // Temporary
		
    twk_Item[playerid] = itemid;
	return 1;
}

stock TweakFinalise(playerid){
	if(twk_Item[playerid] != INVALID_ITEM_ID){

		new objectid;
		GetItemObjectID(twk_Item[playerid], objectid);

		for(new i = 0; i < 15; i++) {
			SetDynamicObjectMaterial(objectid, i, -1, "none", "none", -1); // Temporary
		}

        CallLocalFunction("OnItemTweakFinish", "dd", playerid, _:twk_Item[playerid]);
   		twk_Item[playerid] = INVALID_ITEM_ID;
    }
    return 1;
}

hook OnPlayerUpdate(playerid){
    if (twk_Item[playerid] != INVALID_ITEM_ID){
		new Keys, ud, lr;
		GetPlayerKeys(playerid, Keys, ud, lr);
		if(Keys == KEY_CROUCH || Keys == KEY_NO){
			TweakFinalise(playerid);
			ShowActionText(playerid, "~g~Finalised");
		} else {
			new Float:x, Float:y, Float:z, Float:a,
				Float:new_x, Float:new_y, Float:new_z,
				Float:new_rx, Float:new_ry, Float:new_rz,
				modelid, Float:offx, Float:offy, Float:offz, Float:radius;
			GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, a);
			GetItemPos(twk_Item[playerid], new_x, new_y, new_z);
			GetItemRot(twk_Item[playerid], new_rx, new_ry, new_rz);
			GetItemTypeModel(GetItemType(twk_Item[playerid]), modelid);
			CA_GetModelBoundingSphere(modelid, offx, offy, offz, radius);
			new_x = x + radius * floatsin(-a, degrees);
			new_y = y + radius * floatcos(-a, degrees);
			//new_rx = offx;
			//new_ry = offy;
			new_rz = absoluteangle(a);
			SetItemPos(twk_Item[playerid], new_x, new_y, new_z);
			SetItemRot(twk_Item[playerid], new_rx, new_ry, new_rz);
			ShowActionText(playerid, "~y~Moving Item...~n~~y~Press C ou N to finalise");
			CallLocalFunction("OnItemTweakUpdate", "dd", playerid, _:twk_Item[playerid]);
		}
    }
    return 1;
}

stock Item:twk_ItemPlayer(playerid)
	return twk_Item[playerid];