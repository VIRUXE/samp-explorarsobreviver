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
#include <YSI_Visual\y_dialog>

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
forward AddInventoryListItem(playerid, const itemname[], modelid = 19300);

// AddInventoryOption adds an inventory option to an item option menu. This
// should only ever be used in `OnPlayerViewInventoryOpt`.
forward AddInventoryOption(playerid, const option[]);

// GetInventoryListItems returns the available inventory list items.
forward GetInventoryListItems(playerid, list[], len = sizeof list);

// GetInventoryOptions returns the available inventory options.
forward GetInventoryOptions(playerid, list[], len = sizeof list);

// GetInventoryListItemCount returns the amount of additional inventory list
// items.
forward GetInventoryListItemCount(playerid);

// GetInventoryOptionCount returns the amount of inventory item options.
forward GetInventoryOptionCount(playerid);

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
	inv_ExtraItemList[MAX_PLAYERS][128],
	inv_ExtraItemCount[MAX_PLAYERS],
	inv_OptionsList[MAX_PLAYERS][128],
	inv_OptionsCount[MAX_PLAYERS],
	inv_PutAwayTick[MAX_PLAYERS],
	Timer:inv_PutAwayTimer[MAX_PLAYERS];


// -
// API
// -

stock DisplayPlayerInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	Logger_Dbg("inventory-dialog", "showing inventory for player",
		Logger_I("playerid", playerid));

	new
		title[18],
		list[(MAX_INVENTORY_SLOTS * (MAX_ITEM_NAME + MAX_ITEM_TEXT + 11))],
		Item:itemid,
		tmp[MAX_ITEM_NAME + MAX_ITEM_TEXT],
		size;

	inv_ItemListTotal[playerid] = 0;

	new ret_outer = GetPlayerInventorySize(playerid, size);
	if(ret_outer) {
		return 2;
	}

	new model, ItemType:itemtype;
	for(new i; i < size; i++)
	{
		ret_outer = GetInventorySlotItem(playerid, i, itemid);

		if(!IsValidItem(itemid) || ret_outer)
			break;

		itemtype = GetItemType(itemid);

		GetItemName(itemid, tmp);
		GetItemTypeModel(itemtype, model);

		format(list, sizeof(list), "%s%d\t%s\n", list, model, tmp);

		inv_ItemListTotal[playerid]++;
	}

	new slots;
	ret_outer = GetInventoryFreeSlots(playerid, slots);
	if(ret_outer) 
		return 3;

	/*for(new i; i < slots; i++)
	{
		strcat(list, "19300\t<Vazio>\n");
		inv_ItemListTotal[playerid]++;
	}*/

	inv_ExtraItemList[playerid][0] = EOS;
	inv_ExtraItemCount[playerid] = 0;

	if(CallLocalFunction("OnPlayerOpenInventory", "d", playerid))
		return 4;

	if(!isnull(inv_ExtraItemList[playerid]))
		strcat(list, inv_ExtraItemList[playerid]);

	format(title, sizeof(title), "~g~Bolsos (%d/%d)", size - slots, size);

	ShowPlayerDialog(playerid, 33, DIALOG_STYLE_PREVIEW_MODEL, title, list, "Enter", "Sair");

	inv_ViewingInventory[playerid] = true;

	CallLocalFunction("OnPlayerOpenedInventory", "d", playerid);
	return 0;
}

stock ClosePlayerInventory(playerid, call = true)
{
	if(!inv_ViewingInventory[playerid])
		return 1;

	Logger_Dbg("inventory-dialog", "hiding inventory for player",
		Logger_I("playerid", playerid));

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

stock AddInventoryListItem(playerid, const itemname[], modelid = 19300)
{
	if(strlen(inv_ExtraItemList[playerid]) + strlen(itemname) > sizeof(inv_ExtraItemList[]))
		return 0;

	Logger_Dbg("inventory-dialog", "adding inventory list item",
		Logger_I("playerid", playerid),
		Logger_S("itemname", itemname));

	if(modelid != 19300)
		format(inv_ExtraItemList[playerid], 128,
			"%s%d(0.0,0.0,180.0,0.64,-1,-1)\t", inv_ExtraItemList[playerid], modelid);
	else
		strcat(inv_ExtraItemList[playerid], "19300\t");

	strcat(inv_ExtraItemList[playerid], itemname);
	strcat(inv_ExtraItemList[playerid], "\n");

	return inv_ExtraItemCount[playerid]++;
}

stock AddInventoryOption(playerid, const option[])
{
	if(strlen(inv_OptionsList[playerid]) + strlen(option) > sizeof(inv_OptionsList[]))
		return 0;

	Logger_Dbg("inventory-dialog", "adding inventory item option",
		Logger_I("playerid", playerid),
		Logger_S("option", option));

	strcat(inv_OptionsList[playerid], option);
	strcat(inv_OptionsList[playerid], "\n");

	return inv_OptionsCount[playerid]++;
}

stock GetInventoryListItems(playerid, list[], len = sizeof list)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	memcpy(list, inv_ExtraItemList[playerid], 0, 4 * inv_ExtraItemCount[playerid], len);

	return 0;
}

stock GetInventoryOptions(playerid, list[], len = sizeof list)
{
	if(!IsPlayerConnected(playerid))
		return 1;

	memcpy(list, inv_OptionsList[playerid], 0, 4 * inv_OptionsCount[playerid], len);

	return 0;
}

stock GetInventoryListItemCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemCount[playerid];
}

stock GetInventoryOptionCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsCount[playerid];
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

_inv_displaySlotOptions(playerid, slotid)
{
	new
		name[MAX_ITEM_NAME + MAX_ITEM_TEXT + 6],
		Item:itemid,
		itemsize,
		ret_outer;
	
	ret_outer = GetInventorySlotItem(playerid, slotid, itemid);
	if(ret_outer) {
		return 1;
	}

	GetItemName(itemid, name);
	GetItemTypeSize(GetItemType(itemid), itemsize);
	format(name, sizeof(name), "[%d]%s", itemsize, name);
	
	inv_OptionsList[playerid] = "Equipar\nUsar\nJogar Fora\n";
	inv_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewInventoryOpt", "d", playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[]) {
		#pragma unused pid, dialogid

		Logger_Dbg("inventory-dialog", "player responded to inventory item options",
			Logger_I("playerid", playerid),
			Logger_I("response", response),
			Logger_I("listitem", listitem),
			Logger_S("inputtext", inputtext));

		if(!response) {
			DisplayPlayerInventory(playerid);
			return 1;
		}

		switch(listitem) {
			case 0: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid2,
						ret;
					
					ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid2);
					if(ret) {
						Logger_Err("failed to get inventory slot item", Logger_I("playerid", playerid), Logger_I("slotid", inv_SelectedSlot[playerid]), Logger_I("ret", ret));
						DisplayPlayerInventory(playerid);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid2)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayPlayerInventory(playerid);
						return 1;
					}

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
					GiveWorldItemToPlayer(playerid, itemid2, 1);
					DisplayPlayerInventory(playerid);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 1: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid2,
						ret;
					
					ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid2);
					if(ret) {
						Logger_Err("failed to get inventory slot item", Logger_I("playerid", playerid), Logger_I("slotid", inv_SelectedSlot[playerid]), Logger_I("ret", ret));
						DisplayPlayerInventory(playerid);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid2)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayPlayerInventory(playerid);
						return 1;
					}

					RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);

					ClosePlayerInventory(playerid);

					GiveWorldItemToPlayer(playerid, itemid2, 1);
					
					PlayerUseItem(playerid);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayPlayerInventory(playerid);
				}
			}
			case 2: {
				new
					Item:itemid2,
					ret;
				
				ret = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid], itemid2);
				if(ret) {
					Logger_Err("failed to get inventory slot item", Logger_I("playerid", playerid), Logger_I("slotid", inv_SelectedSlot[playerid]), Logger_I("ret", ret));
					DisplayPlayerInventory(playerid);
					return 1;
				}

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);

				new Float:x, Float:y, Float:z;

				if(!IsPlayerInAnyVehicle(playerid)) {

					if(IsItemTypeCarry(GetItemType(itemid2))) {
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
				
				CreateItemInWorld(itemid2,
					x, y, z,
					.world = GetPlayerVirtualWorld(playerid),
					.interior = GetPlayerInterior(playerid),
					.label = 1);

				DisplayPlayerInventory(playerid);
			}
			default: {
				if(!CallLocalFunction("OnPlayerSelectInventoryOpt", "dd", playerid, listitem - 3)) {
					Logger_Dbg("inventory-dialog", "opening inventory via extra item response");
					DisplayPlayerInventory(playerid);
				} else {
					Logger_Dbg("inventory-dialog", "closing inventory via option response");
					ClosePlayerInventory(playerid);
				}
			}
		}
		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, name, inv_OptionsList[playerid], "Opções", "Sair");

	return 0;
}

hook OnDialogModelResponse(playerid, dialogid, response, listitem)
{
	if(dialogid == 33)
	{
		Logger_Dbg("inventory-dialog", "player responded to inventory dialog",
			Logger_I("playerid", playerid),
			Logger_I("response", response),
			Logger_I("listitem", listitem));

		if(!response) {
			ClosePlayerInventory(playerid);
			return 1;
		}

		if(listitem >= inv_ItemListTotal[playerid]) {
			if(!CallLocalFunction("OnPlayerSelectExtraItem", "dd", playerid, listitem - inv_ItemListTotal[playerid])) {
				Logger_Dbg("inventory-dialog", "opening inventory via extra item response");
				DisplayPlayerInventory(playerid);
			} else {
				Logger_Dbg("inventory-dialog", "closing inventory via extra item response");
				ClosePlayerInventory(playerid, false);
			}
			return 1;
		}

		new
			Item:itemid2,
			ret;
			
		ret = GetInventorySlotItem(playerid, listitem, itemid2);
		if(ret || !IsValidItem(itemid2)) {
			DisplayPlayerInventory(playerid);
		} else {
			inv_SelectedSlot[playerid] = listitem;
			_inv_displaySlotOptions(playerid, listitem);
		}

		return 0;
	}
	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!IsPlayerInAnyVehicle(playerid))
	{
		Logger_Dbg("inventory-dialog", "OnPlayerKeyStateChange",
			Logger_I("playerid", playerid),
			Logger_I("newkeys", newkeys),
			Logger_I("oldkeys", oldkeys));

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
		Logger_Err("failed to get inventory free slots",
			Logger_I("return", ret));
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