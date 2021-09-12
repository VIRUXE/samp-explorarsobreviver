// built-in include guard removal
// just in case the user has a local dependency with the same file name
#if defined _inc_inventory_dialog
	#undef _inc_inventory_dialog
#endif
// custom include-guard to ensure we don't duplicate
#if defined _inventory_dialog_included
	#endinput
#endif
#define _inventory_dialog_included


#include <a_samp>
#include <tick-difference>
#include <item>
#include <inventory>
#include <YSI_Coding\y_hooks>


// -
// Function API
// -


// DisplayPlayerInventory displays the inventory dialog.
forward DisplayPlayerInventory(playerid);

// ClosePlayerInventory closes the inventory dialog, optionally calls
// `OnPlayerCloseInventory`.
forward ClosePlayerInventory(playerid, call = true);

// GetPlayerSelectedInventorySlot returns the selected inventory slot.
forward GetPlayerSelectedInventorySlot(playerid);

// AddInventoryListItem adds a list item to the inventory dialog for additional
// actions. This should only ever be used in `OnPlayerOpenInventory`.
forward AddInventoryListItem(playerid, const itemname[]);

// AddInventoryOption adds an inventory option to an item option menu. This
// should only ever be used in `OnPlayerViewInventoryOpt`.
forward AddInventoryOption(playerid, const option[]);

// bool returns true if the player is in the inventory screen.
forward bool:IsPlayerViewingInventory(playerid);


// -
// Event API
//

// OnPlayerOpenInventory is called when the player opens their inventory. Return
// 1 to cancel.
forward OnPlayerOpenInventory(playerid);

// OnPlayerOpenedInventory is called after a inventory dialog has been shown to
// the player, there are no return controls.

forward OnPlayerOpenedInventory(playerid);

// OnPlayerCloseInventory is called when a player closes their inventory via
// close button or if `call` is set on `ClosePlayerInventory`.
forward OnPlayerCloseInventory(playerid);

// OnPlayerSelectExtraItem is called when a player selects an inventory list
// item beyond the list of items, an additional option. Return 0 to keep the
// inventory dialog open and 1 to close it.
forward OnPlayerSelectExtraItem(playerid, item);

// OnPlayerViewInventoryOpt is called when the player views the options for an
// item.
forward OnPlayerViewInventoryOpt(playerid);

// OnPlayerSelectInventoryOpt is called when the player selects an option for an
// item. Return 0 to keep the inventory displayed and 1 to close it.
forward OnPlayerSelectInventoryOpt(playerid, option);

// OnPlayerAddToInventory is called when a player adds an item to their
// inventory using a key.
forward OnPlayerAddToInventory(playerid, Item:itemid, bool:success);

// OnPlayerAddedToInv is called after a player has added an item to their
// inventory.
forward OnPlayerAddedToInv(playerid, Item:itemid);


// -
// State
// -

static
	inv_ItemListTotal[MAX_PLAYERS],
	inv_SelectedSlot[MAX_PLAYERS],
	bool:inv_ViewingInventory[MAX_PLAYERS],
	inv_PutAwayTick[MAX_PLAYERS],
	Timer:inv_PutAwayTimer[MAX_PLAYERS];


// -
// API
// -

stock DisplayPlayerInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	new
		title[18],
		Item:itemid,
		tmp[MAX_ITEM_NAME + MAX_ITEM_TEXT],
		size;

	inv_ItemListTotal[playerid] = -1;

	new ret_outer = GetPlayerInventorySize(playerid, size);
	if(ret_outer) {
		return 2;
	}

	for(new i; i < size; i++)
	{
		ret_outer = GetInventorySlotItem(playerid, i, itemid);

		if(!IsValidItem(itemid) || ret_outer)
			break;

		GetItemName(itemid, tmp);

		AddDialogDrawItem(playerid, tmp);

		inv_ItemListTotal[playerid]++;
	}

	new slots;
	ret_outer = GetInventoryFreeSlots(playerid, slots);
	if(ret_outer) 
		return 3;

	if(CallLocalFunction("OnPlayerOpenInventory", "d", playerid))
		return 4;

	format(title, sizeof(title), "Bolsos (%d/%d)", size - slots, size);

	ShowDialogDraw(playerid, 33, title);

	inv_ViewingInventory[playerid] = true;

	CallLocalFunction("OnPlayerOpenedInventory", "d", playerid);
	return 0;
}

stock ClosePlayerInventory(playerid, call = true)
{
	if(!inv_ViewingInventory[playerid])
		return 1;

	inv_ViewingInventory[playerid] = false;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseInventory", "d", playerid))
		{
			DisplayPlayerInventory(playerid);
			return 2;
		}
	}
	
	return 0;
}

stock GetPlayerSelectedInventorySlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return inv_SelectedSlot[playerid];
}

stock AddInventoryListItem(playerid, const itemname[])
{
	return AddDialogDrawItem(playerid, itemname, 0x30aa30ff);
}

stock AddInventoryOption(playerid, const option[])
{
	return AddDialogDrawItem(playerid, option, 0x30aa30ff);
}

stock bool:IsPlayerViewingInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	return inv_ViewingInventory[playerid];
}


// -
// Internal
// -


hook OnScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
		for(new j; j < MAX_INVENTORY_SLOTS; j++)
			inv_SelectedSlot[i] = -1;
}

hook OnPlayerConnect(playerid)
{
	for(new j; j < MAX_INVENTORY_SLOTS; j++)
		inv_SelectedSlot[playerid] = -1;

	inv_ViewingInventory[playerid] = false;
}

hook OnDialogDrawResponse(playerid, dialogid, response, listitem)
{
	if(dialogid == 32)
	{
		if(!response) {
			DisplayPlayerInventory(playerid);
			return 1;
		}

		switch(listitem) {
			case 0: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid,
						ret;
					
					ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid);
					if(ret) {
						DisplayPlayerInventory(playerid);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayPlayerInventory(playerid);
						return 1;
					}

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					GiveWorldItemToPlayer(playerid, itemid, 1);
					DisplayPlayerInventory(playerid);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 1: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid,
						ret;
					
					ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid);
					if(ret) {
						DisplayPlayerInventory(playerid);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayPlayerInventory(playerid);
						return 1;
					}

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);

					ClosePlayerInventory(playerid);

					GiveWorldItemToPlayer(playerid, itemid, 1);
					
					PlayerUseItem(playerid);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 2: {
				new
					Item:itemid,
					ret;
				
				ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid);
				if(ret) {
					DisplayPlayerInventory(playerid);
					return 1;
				}

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);

				new Float:x, Float:y, Float:z;

				if(!IsPlayerInAnyVehicle(playerid)) {

					if(IsItemTypeCarry(GetItemType(itemid))) {
						ApplyAnimation(playerid, "CARRY", "putdwn", 5.0, 0, 0, 0, 0, 0);
					} else {
						ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
					}

					GetPlayerPos(playerid, x, y, z);
					z -= ITEM_FLOOR_OFFSET;
				} else {

					new 
						vehicleid = GetPlayerVehicleID(playerid),
						Float:size_x,
						Float:size_y,
						Float:size_z,
						Float:ang;

					GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);
					GetVehicleZAngle(vehicleid, ang);
					GetVehiclePos(vehicleid, x, y, z);

					x -= (size_y / 1.85) * floatsin(-ang, degrees), y -= (size_y / 1.85) * floatcos(-ang, degrees);

					z -= 0.7;
				}
				
				CreateItemInWorld(itemid,
					x, y, z,
					.world = GetPlayerVirtualWorld(playerid),
					.interior = GetPlayerInterior(playerid),
					.label = 1);

				DisplayPlayerInventory(playerid);
			}
			default: {
				if(!CallLocalFunction("OnPlayerSelectInventoryOpt", "dd", playerid, listitem)) {
					DisplayPlayerInventory(playerid);
				} else {
					ClosePlayerInventory(playerid);
				}
			}
		}
		return 1;
	}
	if(dialogid == 33)
	{
		if(!response) {
			ClosePlayerInventory(playerid);
			return 1;
		}

		if(listitem > inv_ItemListTotal[playerid]) {
			if(!CallLocalFunction("OnPlayerSelectExtraItem", "dd", playerid, listitem)) {
				DisplayPlayerInventory(playerid);
			} else {
				ClosePlayerInventory(playerid, false);
			}
			return 1;
		}

		new
			Item:itemid,
			ret;
			
		ret = GetInventorySlotItem(playerid, listitem, itemid);
		if(ret || !IsValidItem(itemid)) {
			DisplayPlayerInventory(playerid);
		} else {
			inv_SelectedSlot[playerid] = listitem;

			new
				title[MAX_ITEM_NAME + MAX_ITEM_TEXT + 6],
				itemsize;
			
			GetItemName(itemid, title);
			GetItemTypeSize(GetItemType(itemid), itemsize);

			format(title, sizeof(title), "(%d) %s", itemsize, title);

			AddDialogDrawItem(playerid, "Equipar", 0x30aa30ff);
			AddDialogDrawItem(playerid, "Usar", 0x30aa30ff);
			AddDialogDrawItem(playerid, "Soltar item", 0x30aa30ff);

			CallLocalFunction("OnPlayerViewInventoryOpt", "d", playerid);

			ShowDialogDraw(playerid, 32, title);
		}

		return 0;
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		if(newkeys & KEY_CTRL_BACK)
			DisplayPlayerInventory(playerid);
		else if(newkeys & KEY_YES)
			_inv_putAway(playerid);
	}

	return 1;
}

_inv_putAway(playerid) {
	if(GetTickCountDifference(GetTickCount(), inv_PutAwayTick[playerid]) < 1000) {
		return;
	}

	new Item:itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid)) {
		return;
	}

	new
		itemsize,
		freeslots;

	GetItemTypeSize(GetItemType(itemid), itemsize);
	
	new ret = GetInventoryFreeSlots(playerid, freeslots);
	if(ret) {
		return;
	}

	if(itemsize > freeslots) {
		CallLocalFunction("OnPlayerAddToInventory", "ddd", playerid, _:itemid, 0);
		return;
	}

	if(CallLocalFunction("OnPlayerAddToInventory", "ddd", playerid, _:itemid, 1)) {
		return;
	}

	inv_PutAwayTick[playerid] = GetTickCount();

	ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
	stop inv_PutAwayTimer[playerid];
	inv_PutAwayTimer[playerid] = defer PlayerPutItemInInventory(playerid, _:itemid);

	return;
}

hook OnPlayerDisconnect(playerid)
	stop inv_PutAwayTimer[playerid];
	
timer PlayerPutItemInInventory[300](playerid, itemid) {
	AddItemToInventory(playerid, Item:itemid);
	CallLocalFunction("OnPlayerAddedToInv", "dd", playerid, itemid);
}