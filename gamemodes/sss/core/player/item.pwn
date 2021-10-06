
#include <YSI_Coding\y_hooks>

static 
	Text:item_Prev,
	PlayerText:item_TD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};
	
hook OnGameModeInit(){
	item_Prev = TextDrawCreate	(291.0, 400.0, "_");
	TextDrawFont				(item_Prev, 5);
	TextDrawLetterSize			(item_Prev,	0.5, 2.0);
	TextDrawTextSize			(item_Prev, 53.0, 41.0);		
	TextDrawBackgroundColor		(item_Prev, 0);
	TextDrawSetPreviewRot		(item_Prev, -10.0, 0.0, -20.0, 1.0);
}

hook OnGameModeExit()
	TextDrawDestroy(item_Prev);

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
	PlayerTextDrawFont				(playerid, item_TD[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, item_TD[playerid], 0.3, 1.2);
	PlayerTextDrawTextSize			(playerid, item_TD[playerid], 280.000000, 320.000000);
	PlayerTextDrawSetOutline		(playerid, item_TD[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, item_TD[playerid], 1);
	PlayerTextDrawAlignment			(playerid, item_TD[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, item_TD[playerid], 255);
	PlayerTextDrawColor				(playerid, item_TD[playerid], ORANGE);
	PlayerTextDrawShow				(playerid, item_TD[playerid]);
	defer HideCredit(playerid);
	PlayerTextDrawColor				(playerid, item_TD[playerid], 0xFFFF00FF);
}

timer HideCredit[5000](playerid){
	if(!IsValidItem(GetPlayerItem(playerid))){
		PlayerTextDrawHide(playerid, item_TD[playerid]);
	}
}
UpdatePreviewItemText(playerid){
	new iname[MAX_ITEM_NAME + MAX_ITEM_TEXT];
	GetItemName(GetPlayerItem(playerid), iname);
	PlayerTextDrawSetString(playerid, item_TD[playerid], iname);
	PlayerTextDrawShow(playerid, item_TD[playerid]);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	UpdatePreviewItemText(playerid);

	new 
		modelid,
		ItemType:itype = GetItemType(itemid);

	GetItemTypeModel(itype, modelid);
	TextDrawSetPreviewModel(item_Prev, modelid);
	TextDrawShowForPlayer(playerid, item_Prev);

	// Temporary fix Special Action on mobile
	if(IsItemTypeCarry(itype) && IsPlayerUsingMobile(playerid)) 
		RemovePlayerAttachedObject(playerid, ITEM_ATTACH_INDEX);
}

hook OnItemArrayDataChanged(Item:itemid) {
	if(IsPlayerConnected(GetItemHolder(itemid))) {
		UpdatePreviewItemText(GetItemHolder(itemid));
	}
}

hook OnPlayerSpawnNewChar(playerid){
	PlayerTextDrawHide(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);	
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	PlayerTextDrawHide(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);

	if(IsItemTypeCarry(GetItemType(itemid)))
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

hook OnItemDestroy(Item:itemid) {
	if(IsPlayerConnected(GetItemHolder(itemid))) {
		PlayerTextDrawHide(GetItemHolder(itemid), item_TD[GetItemHolder(itemid)]);
		TextDrawHideForPlayer(GetItemHolder(itemid), item_Prev);
	}
}

hook OnPlayerDisconnect(playerid, reason){
	PlayerTextDrawDestroy(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);
}

/*==============================================================================

	Default item button text
	
==============================================================================*/

hook OnItemCreateInWorld(Item:itemid) {
	new Button:buttonid;
	GetItemButtonID(itemid, buttonid);
	SetButtonText(buttonid, "~w~"KEYTEXT_INTERACT"~h~ pegar item");
}

hook OnPlayerEnterButArea(playerid, Button:buttonid) {
	if(!IsValidItem(GetPlayerItem(playerid)) && IsValidItem(GetItemFromButtonID(buttonid))) {
		new text[BTN_MAX_TEXT];
		GetButtonText(buttonid, text);
		if(strfind(text, "Para pegar")) {
			HideActionText(playerid);
		}
	}
}

/*==============================================================================

	Fix Default item name extra
	
==============================================================================*/

hook OnItemCreate(Item:itemid) 
	SetItemNameExtra(itemid, "");

/*==============================================================================

	Temporary Disable Give Item
	
==============================================================================*/

hook OnPlayerGiveItem(playerid, targetid, Item:itemid){
	PlayerDropItem(playerid);
	return Y_HOOKS_BREAK_RETURN_1;
}

/*==============================================================================

	Until callback
	
==============================================================================*/

hook OnMoveItemToInventory(playerid, Item:itemid, Container:containerid){
	return Y_HOOKS_BREAK_RETURN_0;
}

hook OnMoveItemToContainer(playerid, Item:itemid, Container:containerid){
	return Y_HOOKS_BREAK_RETURN_0;
}

/*==============================================================================

	Fix use item
	
==============================================================================*/

hook OnPlayerUseItemWithBtn(playerid, Button:buttonid, Item:itemid){
	new Button:id;
	GetPlayerPressingButton(playerid, id);
	if(!IsValidButton(id))
		CallLocalFunction("OnButtonPress", "dd", playerid, _:buttonid);
		
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	View inventory in Vehicle
	
==============================================================================*/

hook OnPlayerOpenInventory(playerid){
	if(IsPlayerInAnyVehicle(playerid))
		DisplayContainerInventory(playerid, GetVehicleContainer(GetPlayerVehicleID(playerid)));
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
	if( (newkeys == KEY_YES) && GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
		HideVehicleUI(playerid), DisplayPlayerInventory(playerid);
	

hook OnPlayerCloseContainer(playerid, Container:containerid){
	if(IsPlayerInAnyVehicle(playerid))
		ShowVehicleUI(playerid, GetPlayerLastVehicle(playerid));
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
		ShowVehicleUI(playerid, GetPlayerLastVehicle(playerid));
		
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	if(IsPlayerInAnyVehicle(playerid))
		return Y_HOOKS_BREAK_RETURN_1;
		
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Destruir todos itens do jogador
	
==============================================================================*/

stock DestroyPlayerItems(playerid){
	for(new i = MAX_INVENTORY_SLOTS - 1; i >= 0; i--){
		new Item:subitemid;
		GetInventorySlotItem(playerid, i, subitemid);
		if(IsValidItem(subitemid))
			DestroyItem(subitemid);
	}

	DestroyPlayerBag(playerid);

	if(IsValidItem(GetPlayerItem(playerid)))
		DestroyItem(GetPlayerItem(playerid));

	if(IsValidItem(GetPlayerHolsterItem(playerid))) {
		DestroyItem(GetPlayerHolsterItem(playerid));
		RemovePlayerHolsterItem(playerid);
	}

	if(IsValidItem(GetPlayerHatItem(playerid))){
		DestroyItem(GetPlayerHatItem(playerid));
		RemovePlayerHatItem(playerid);
	}

	if(IsValidItem(GetPlayerMaskItem(playerid))){
		DestroyItem(GetPlayerMaskItem(playerid));
		RemovePlayerMaskItem(playerid);
	}
}