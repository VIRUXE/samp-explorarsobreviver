
#include <YSI_Coding\y_hooks>

static 
	Text:item_Prev,
	PlayerText:item_TD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};
	
hook OnGameModeInit(){
	item_Prev = TextDrawCreate	(291.000000, 400.000000, "Preview_Model");
	TextDrawFont				(item_Prev, 5);
	TextDrawLetterSize			(item_Prev,	0.600000, 2.000000);
	TextDrawTextSize			(item_Prev, 53.000000, 41.000000);		
	TextDrawBackgroundColor		(item_Prev, 0);
	TextDrawSetPreviewRot		(item_Prev, -10.000000, 0.100000, -20.000000, 1.0);
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

	new 
		modelid,
		ItemType:itype = GetItemType(itemid);

	GetItemTypeModel(itype, modelid);
	TextDrawSetPreviewModel(item_Prev, modelid);
	TextDrawShowForPlayer(playerid, item_Prev);

	// Temporary fix Special Action on mobile
	if(IsItemTypeCarry(itype) && IsPlayerMobile(playerid)) 
		RemovePlayerAttachedObject(playerid, ITEM_ATTACH_INDEX);
}

hook OnPlayerUseItem(playerid, Item:itemid)
	UpdatePlayerPreviewItem(playerid);

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	UpdatePlayerPreviewItem(playerid);
	return 1;
}

hook OnHoldActionFinish(playerid)
	UpdatePlayerPreviewItem(playerid);

hook OnHoldActionUpdate(playerid, progress)
	UpdatePlayerPreviewItem(playerid);

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	UpdatePlayerPreviewItem(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	PlayerTextDrawHide(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);

	if(IsItemTypeCarry(GetItemType(itemid)))
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

hook OnPlayerDroppedItem(playerid, Item:itemid){
	PlayerTextDrawHide(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);
}

hook OnPlayerDisconnect(playerid, reason){
	PlayerTextDrawDestroy(playerid, item_TD[playerid]);
	TextDrawHideForPlayer(playerid, item_Prev);
}

/*==============================================================================

	Default item button text
	
==============================================================================*/

hook OnItemCreateInWorld(Item:itemid){
	new Button:buttonid;
	GetItemButtonID(itemid, buttonid);
	SetButtonText(buttonid, "Pressione F para pegar");
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

	Move itens
	
==============================================================================*/

hook OnMoveItemToInventory(playerid, Item:itemid, Container:containerid){
	return Y_HOOKS_BREAK_RETURN_0;
}

hook OnMoveItemToContainer(playerid, Item:itemid, Container:containerid){
	return Y_HOOKS_BREAK_RETURN_0;
}

/*==============================================================================

	View inventory in Vehicle
	
==============================================================================*/

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
	if( (newkeys == KEY_ACTION) && IsPlayerInAnyVehicle(playerid))
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

	Fix Button press
	
==============================================================================*/

hook OnButtonPress(playerid, Button:buttonid) 
{
	// Por algum motivo, o botão 0 é chamado quando é criado em cima do jogador
	// Correção temporária, provavelmente algo na include button ou streamer plugin.
	if(buttonid == Button:0 || !IsValidButton(buttonid))
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		Streamer_UpdateEx(playerid, x, y, z);
		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}