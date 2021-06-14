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
	item_TD[playerid][0] = CreatePlayerTextDraw(playerid, 149.000000, 396.500000, "Preview_Model");
	PlayerTextDrawFont(playerid, item_TD[playerid][0], 5);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid][0], 51.000000, 43.500000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, item_TD[playerid][0], 1);
	PlayerTextDrawColor(playerid, item_TD[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawBoxColor(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawUseBox(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetProportional(playerid, item_TD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, item_TD[playerid][0], 0);
	PlayerTextDrawSetPreviewModel(playerid, item_TD[playerid][0], 1271);
	PlayerTextDrawSetPreviewRot(playerid, item_TD[playerid][0], 0.000000, 0.000000, 0.000000, 1.000000);
	PlayerTextDrawSetPreviewVehCol(playerid, item_TD[playerid][0], 1, 1);

	item_TD[playerid][1] = CreatePlayerTextDraw(playerid, 175.000000, 429.000000, "Large Box");
	PlayerTextDrawFont(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid][1], 0.270832, 1.500000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid][1], 280.000000, 288.000000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid][1], 1);
	PlayerTextDrawAlignment(playerid, item_TD[playerid][1], 2);
	PlayerTextDrawColor(playerid, item_TD[playerid][1], -65281);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid][1], 0);
	PlayerTextDrawBoxColor(playerid, item_TD[playerid][1], 0);
	PlayerTextDrawUseBox(playerid, item_TD[playerid][1], 1);
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
	PlayerTextDrawShow(playerid, item_TD[playerid][0]);

	UpdatePlayerPreviewItem(playerid);

	// Temporary fix Special Action on mobile
	if(IsItemTypeCarry(itype) && IsPlayerMobile(playerid)) {
		RemovePlayerAttachedObject(playerid, ITEM_ATTACH_INDEX);
	}

}

/*
hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ){
	UpdatePlayerPreviewItem(i);
}*/


hook OnItemArrayDataChanged(Item:itemid)
{
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