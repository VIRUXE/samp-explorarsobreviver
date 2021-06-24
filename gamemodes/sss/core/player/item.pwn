/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

static PlayerText:item_TD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

hook OnPlayerConnect(playerid){
	item_TD[playerid] = CreatePlayerTextDraw(playerid, 318.000000, 435.000000, "Large Box");
	PlayerTextDrawFont(playerid, item_TD[playerid], 1);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid], 0.254165, 1.250000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid], 280.000000, 254.000000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid], 1);
	PlayerTextDrawAlignment(playerid, item_TD[playerid], 2);
	PlayerTextDrawColor(playerid, item_TD[playerid], 0xFFFF00FF);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid], 255);
}

UpdatePlayerPreviewItem(playerid){
	new iname[MAX_ITEM_NAME + MAX_ITEM_TEXT];
	GetItemName(GetPlayerItem(playerid), iname);
	PlayerTextDrawSetString(playerid, item_TD[playerid], iname);
	PlayerTextDrawShow(playerid, item_TD[playerid]);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	UpdatePlayerPreviewItem(playerid);

	// Temporary fix Special Action on mobile
	if(IsItemTypeCarry(GetItemType(itemid)) && IsPlayerMobile(playerid)) {
		RemovePlayerAttachedObject(playerid, ITEM_ATTACH_INDEX);
	}

}

hook OnItemArrayDataChanged(Item:itemid){
	foreach(new i : Player){
		if(GetPlayerItem(i) == itemid){
			UpdatePlayerPreviewItem(i);
		}
	}
}

hook OnItemDestroy(Item:itemid){
	foreach(new i : Player){
		if(GetPlayerItem(i) == itemid){
			PlayerTextDrawHide(i, item_TD[i]);
		}
	}
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	PlayerTextDrawHide(playerid, item_TD[playerid]);
}

hook OnPlayerDisconnect(playerid, reason){
	PlayerTextDrawDestroy(playerid, item_TD[playerid]);
}

/*==============================================================================

	Temporary fix long pickup on mobile

==============================================================================*/

hook OnButtonPress(playerid, Button:id) {
	if(IsPlayerMobile(playerid)) {
		new Item:itemid = GetItemFromButtonID(id);
		if(IsValidItem(itemid) && IsItemTypeLongPickup(GetItemType(itemid))){
			PlayerPickUpItem(playerid, itemid);
		}
	}
}

/*==============================================================================

	Anti Drop item bug
	
==============================================================================*/

hook OnPlayerDroppedItem(playerid, Item:itemid){
	new Float:x, Float:y, Float:z;
	GetItemPos(itemid, x, y, z);
	CA_RayCastLine(x, y, z, x, y, z - 3.0, z, z, z);
	SetItemPos(itemid, x, y, z);
}