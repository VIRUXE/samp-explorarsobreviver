/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

new PlayerText:item_TD[MAX_PLAYERS][2];

hook OnPlayerConnect(playerid){
	item_TD[playerid][0] = CreatePlayerTextDraw(playerid, 291.000000, 400.000000, "Preview_Model");
	PlayerTextDrawFont(playerid, item_TD[playerid][0], 5);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid][0], 53.000000, 41.000000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawColor(playerid, item_TD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawBoxColor(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawUseBox(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetSelectable(playerid, item_TD[playerid][0], 1);

	item_TD[playerid][1] = CreatePlayerTextDraw(playerid, 318.000000, 435.000000, "Large Box");
	PlayerTextDrawFont(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid][1], 0.254165, 1.250000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid][1], 280.000000, 254.000000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawAlignment(playerid, item_TD[playerid][1], 2);
	PlayerTextDrawColor(playerid, item_TD[playerid][1], 0xFFFF00FF);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid][1], 255);
	PlayerTextDrawBoxColor(playerid, item_TD[playerid][1], 0);
	PlayerTextDrawUseBox(playerid, item_TD[playerid][1], 0);
	PlayerTextDrawSetProportional(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, item_TD[playerid][1], 0);
}

UpdatePlayerPreviewItem(playerid){
	new iname[MAX_ITEM_NAME + MAX_ITEM_TEXT];
	GetItemName(GetPlayerItem(playerid), iname);
	PlayerTextDrawSetString(playerid, item_TD[playerid][1], iname);
	PlayerTextDrawShow(playerid, item_TD[playerid][1]);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	new 
		modelid,
		ItemType:itype = GetItemType(itemid);

	GetItemTypeModel(itype, modelid);
	PlayerTextDrawSetPreviewModel(playerid, item_TD[playerid][0], modelid);

	PlayerTextDrawSetPreviewRot(playerid, item_TD[playerid][0], 0.0, 0.0, 0.0, 0.885);

	PlayerTextDrawShow(playerid, item_TD[playerid][0]);

	UpdatePlayerPreviewItem(playerid);

	// Temporary fix Special Action on mobile
	if(IsItemTypeCarry(itype) && IsPlayerMobile(playerid)) {
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
			PlayerTextDrawHide(i, item_TD[i][0]);
			PlayerTextDrawHide(i, item_TD[i][1]);
		}
	}
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	PlayerTextDrawHide(playerid, item_TD[playerid][0]);
	PlayerTextDrawHide(playerid, item_TD[playerid][1]);
}

hook OnPlayerDisconnect(playerid, reason){
	PlayerTextDrawDestroy(playerid, item_TD[playerid][0]);
	PlayerTextDrawDestroy(playerid, item_TD[playerid][1]);
}

/*==============================================================================
	Temporary fix long pickup on mobile
==============================================================================*/

hook OnButtonPress(playerid, Button:id) {
	new Item:itemid = GetItemFromButtonID(id);
	if(IsValidItem(itemid) && IsItemTypeLongPickup(GetItemType(itemid)) && IsPlayerMobile(playerid)){
		PlayerPickUpItem(playerid, itemid);
	}
	return Y_HOOKS_BREAK_RETURN_1;
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