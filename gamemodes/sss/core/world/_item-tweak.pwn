
/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/

#include <YSI_Coding\y_hooks>

forward OnItemTweakUpdate(playerid, itemid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
forward OnItemTweakFinish(playerid, itemid);

static 
Item:	twk_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
		twk_pMoveType[MAX_PLAYERS],
		twk_TickStart[MAX_PLAYERS],
		twk_Object[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...};

hook OnPlayerConnect(playerid)
	twk_Item[playerid] = INVALID_ITEM_ID;
	
hook OnPlayerDisconnect(playerid, reason)
	TweakFinalise(playerid);

stock TweakItem(playerid, Item:itemid){
	if(twk_Item[playerid] != INVALID_ITEM_ID)
		return 0;
	
	new modelid, Float:new_x, Float:new_y, Float:new_z,
		Float:new_rx, Float:new_ry, Float:new_rz,
		Float:r, Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz;

	GetItemPos(itemid, new_x, new_y, new_z);
	GetItemRot(itemid, new_rx, new_ry, new_rz);
	GetItemTypeModel(GetItemType(itemid), modelid);
	GetPlayerFacingAngle(playerid, r);
	CA_GetModelBoundingBox(modelid, minx, miny, minz, maxx, maxy, maxz);
		
	twk_Object[playerid] = CreateDynamicObject(modelid, new_x, new_y, new_z + floatabs(minz), new_rx, new_ry, r + 60, .playerid = playerid);

	for(new i = 0; i < 15; i++)
		SetDynamicObjectMaterial(twk_Object[playerid], i, -1, "none", "none", 0xBE00FF00);

    twk_Item[playerid] = itemid;
	twk_pMoveType[playerid] = 0;
	twk_TickStart[playerid] = gettime() + 3;
	ClearAnimations(playerid);
	return 1;
}

stock TweakFinalise(playerid){
	if(twk_Item[playerid] != INVALID_ITEM_ID){

		new	Float:new_x, Float:new_y, Float:new_z,
			Float:new_rx, Float:new_ry, Float:new_rz;

		GetDynamicObjectPos(twk_Object[playerid], new_x, new_y, new_z);
		GetDynamicObjectRot(twk_Object[playerid], new_rx, new_ry, new_rz);

		DestroyDynamicObject(twk_Object[playerid]);

		SetItemPos(twk_Item[playerid], new_x, new_y, new_z);
		SetItemRot(twk_Item[playerid], new_rx, new_ry, new_rz);

        CallLocalFunction("OnItemTweakFinish", "dd", playerid, _:twk_Item[playerid]);
   		twk_Item[playerid] = INVALID_ITEM_ID;

		ShowActionText(playerid, "~g~Item moved successfully", 2000);
    }
    return 1;
}

hook OnPlayerUpdate(playerid){
    if (twk_Item[playerid] != INVALID_ITEM_ID){
		new Float:ix, Float:iy, Float:iz,
			Float:x, Float:y, Float:z, Float:a,
			Float:new_x, Float:new_y, Float:new_z,
			Float:new_rx, Float:new_ry, Float:new_rz,
			modelid, Float:offx, Float:offy, Float:offz, Float:radius;

		GetItemPos(twk_Item[playerid], ix, iy, iz);
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);
		GetDynamicObjectPos(twk_Object[playerid], new_x, new_y, new_z);
		GetDynamicObjectRot(twk_Object[playerid], new_rx, new_ry, new_rz);
		GetItemTypeModel(GetItemType(twk_Item[playerid]), modelid);
		CA_GetModelBoundingSphere(modelid, offx, offy, offz, radius);
		
		if(twk_pMoveType[playerid] == 1) {
			new Float:vx, Float:vy, Float:vz;
			GetPlayerVelocity(playerid, vx, vy, vz);
			
			if(vx > 0.0) new_rz = absoluteangle(new_rz + 2.6);
			else if(vx < 0.0) new_rz = absoluteangle(new_rz - 2.6);
			else if(vy > 0.0) new_rz = absoluteangle(new_rz + 2.3);
			else if(vy < 0.0) new_rz = absoluteangle(new_rz - 2.3);
			ShowActionText(playerid, "~n~~n~~n~~y~Moving Item...~n~~y~Press H to move item~n~~y~Press Y to move up/down~n~~y~Press F to finalise");
		}
		else if(twk_pMoveType[playerid] == 2) {
			new Float:vx, Float:vy, Float:vz;
			GetPlayerVelocity(playerid, vx, vy, vz);
			
			if(vx > 0.0 && new_z < iz + (radius * 2)) new_z += 0.05;
			else if(vx < 0.0 && new_z > iz - 1) new_z -= 0.05;
			else if(vy > 0.0 && new_z < iz + (radius * 2)) new_z += 0.05;
			else if(vy < 0.0 && new_z > iz - 1) new_z -= 0.05;
			ShowActionText(playerid, "~n~~n~~n~~y~Moving Item...~n~~y~Press H to rotation item~n~~y~Press Y to move item~n~~y~Press F to finalise");
		} else {
			new_x = x + radius * floatsin(-a, degrees);
			new_y = y + radius * floatcos(-a, degrees);
			ShowActionText(playerid, "~n~~n~~n~~y~Moving Item...~n~~y~Press H to rotation item~n~~y~Press Y to move up/down~n~~y~Press F to finalise");
		}

		if(Distance2D(new_x, new_y, ix, iy) > radius * 4)
		{
			ShowActionText(playerid, "~n~~n~~n~~r~ you went too far~n~~y~Press H to rotation item~n~~y~Press Y to move up/down~n~~y~Press F to finalise");
			return 1;
		}

		if(Distance(x, y, z, ix, iy, iz) > 45.0)
		{
			TweakFinalise(playerid);
			return 1;
		}

		SetDynamicObjectPos(twk_Object[playerid], new_x, new_y, new_z);
		SetDynamicObjectRot(twk_Object[playerid], new_rx, new_ry, new_rz);

		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, new_x, new_y) + 25);
		SetCameraBehindPlayer(playerid);
				
		CallLocalFunction("OnItemTweakUpdate", "ddffffff", playerid, _:twk_Item[playerid], new_x, new_y, new_z, new_rx, new_ry, new_rz);
    }
    return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(twk_Item[playerid] != INVALID_ITEM_ID) {
		if(newkeys & KEY_CTRL_BACK) {
			if(twk_pMoveType[playerid] == 1) {
				twk_pMoveType[playerid] = 0;
			} else {
				twk_pMoveType[playerid] = 1;
			}
		} if(newkeys & KEY_YES) {
			if(twk_pMoveType[playerid] == 2) {
				twk_pMoveType[playerid] = 0;
			} else {
				twk_pMoveType[playerid] = 2;
			}
		} else if(newkeys & 16 && twk_TickStart[playerid] < gettime()) {
			TweakFinalise(playerid);
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	if (twk_Item[playerid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock Item:twk_ItemPlayer(playerid)
	return twk_Item[playerid];