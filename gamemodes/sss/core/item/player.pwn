
#include <YSI_Coding\y_hooks>

static PlayerText:item_TD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

hook OnPlayerConnect(playerid){
	/*
	If you have any respect for me or my work that I do completely free:
	DO NOT REMOVE THIS MESSAGE.
	It's just one line of text that appears when a player joins.
	Feel free to add your own message UNDER this one with information regarding
	your own modifications you've made to the code but DO NOT REMOVE THIS!

	Thank you :)
	*/
	item_TD[playerid] = CreatePlayerTextDraw(playerid, 318.000000, 435.000000, "Scavenge and Survive ~b~(Copyright (C) 2016 \"Southclaws\")");
	PlayerTextDrawFont(playerid, item_TD[playerid], 1);
	PlayerTextDrawLetterSize(playerid, item_TD[playerid], 0.254165, 1.250000);
	PlayerTextDrawTextSize(playerid, item_TD[playerid], 280.000000, 254.000000);
	PlayerTextDrawSetOutline(playerid, item_TD[playerid], 1);
	PlayerTextDrawSetShadow(playerid, item_TD[playerid], 1);
	PlayerTextDrawAlignment(playerid, item_TD[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, item_TD[playerid], 255);
	PlayerTextDrawColor(playerid, item_TD[playerid], ORANGE);
	PlayerTextDrawShow(playerid, item_TD[playerid]);
	defer HideCredit(playerid);
	PlayerTextDrawColor(playerid, item_TD[playerid], 0xFFFF00FF);
}

timer HideCredit[5000](playerid){
	if(!IsValidItem(GetPlayerItem(playerid))){
		PlayerTextDrawHide(playerid, item_TD[playerid]);
	}
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
	if(IsItemTypeDefence(GetItemType(itemid))){
		new Float:x, Float:y, Float:z;
		GetItemPos(itemid, x, y, z);
		CA_RayCastLine(x, y, z, x, y, z - 3.0, z, z, z);
		SetItemPos(itemid, x, y, z + 0.15);
	}
}

/*==============================================================================

	Player trying to get an item while having another in his hand
	
==============================================================================*/

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	ShowActionText(playerid, ls(playerid, "INVHOLDINGI"), 3000);
	return Y_HOOKS_CONTINUE_RETURN_0;
}