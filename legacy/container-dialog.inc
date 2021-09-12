// built-in include guard removal
// just in case the user has a local dependency with the same file name
#if defined _inc_container_dialog
	#undef _inc_container_dialog
#endif
// custom include-guard to ensure we don't duplicate
#if defined _container_dialog_included
	#endinput
#endif
#define _container_dialog_included


#include <a_samp>
#include <container>
#include <inventory-dialog>
#include <YSI_Coding\y_hooks>


// -
// Function API
// -

// DisplayContainerInventory displays a container inventory dialog to a player.
forward DisplayContainerInventory(playerid, Container:containerid);

// ClosePlayerContainer closes an open container dialog if any.
forward ClosePlayerContainer(playerid, call = true);

// GetPlayerCurrentContainer returns the container that a player is viewing.
forward GetPlayerCurrentContainer(playerid, &Container:containerid);

// GetPlayerContainerSlot returns the slot that a player is viewing options for.
forward GetPlayerContainerSlot(playerid, &slot);

// AddContainerOption adds an option to container options menu. This function
// should only ever be used in `OnPlayerViewContainerOpt`. Returns the ID of the
// option row added to the menu.
forward AddContainerOption(playerid, const option[]);


// -
// Event API
// -

// OnPlayerOpenContainer is called before the dialog is shown on
// `DisplayContainerInventory` and returning 1 to this event will cancel the
// dialog from being shown.
forward OnPlayerOpenContainer(playerid, Container:containerid);

// OnPlayerOpenedContainer is called after a container dialog has been shown to
// the player, there are no return controls.
forward OnPlayerOpenedContainer(playerid, Container:containerid);

// OnPlayerCloseContainer is called when a player closes a container or
// `ClosePlayerContainer` is called, return 1 to this event to cancel and force
// the dialog to stay on the player's screen.
forward OnPlayerCloseContainer(playerid, Container:containerid);

// OnPlayerViewContainerOpt is called as a player selects an item in a
// container inventory dialog. This is where options should be added.
forward OnPlayerViewContainerOpt(playerid, Container:containerid);

// OnPlayerSelectContainerOpt is called when a player selects a container option
// other than the default equip/move to inventory options. Return 1 to close the
// dialog afterwards.
forward OnPlayerSelectContainerOpt(playerid, Container:containerid, option);

// OnMoveItemToContainer is called when a player moves an item from their
// inventory to a container. Return 1 to this event to cancel.
forward OnMoveItemToContainer(playerid, Item:itemid, Container:containerid);

// OnMoveItemToInventory is called when a player moves an item from a container
// to their inventory. Return 1 to this event to cancel.
forward OnMoveItemToInventory(playerid, Item:itemid, Container:containerid);


// -
// State
// -


static
	cnt_ItemListTotal[MAX_PLAYERS],
	Container:cnt_CurrentContainer[MAX_PLAYERS],
	cnt_SelectedSlot[MAX_PLAYERS],
	cnt_InventoryContainerItem[MAX_PLAYERS],
	cnt_InventoryOptionID[MAX_PLAYERS];


// -
// API
// -


stock DisplayContainerInventory(playerid, Container:containerid) {
	if(!IsValidContainer(containerid)) {
		return 1;
	}

	new
		containerSize,
		Item:itemid,
		freeSlots,
		itemCount,
		title[MAX_CONTAINER_NAME + 9],
		containername[MAX_CONTAINER_NAME],
		tmp[MAX_ITEM_NAME + MAX_ITEM_TEXT];
	
	GetContainerItemCount(containerid, itemCount);
	GetContainerSize(containerid, containerSize);

	cnt_ItemListTotal[playerid] = -1;

	for(new i; i < itemCount; i++) 
	{
		GetContainerSlotItem(containerid, i, itemid);
		GetItemName(itemid, tmp);
	
		AddDialogDrawItem(playerid, tmp);

		cnt_ItemListTotal[playerid]++;
	}

	GetContainerFreeSlots(containerid, freeSlots);

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, _:containerid)) {
		return 2;
	}

	AddDialogDrawItem(playerid, "Bolsos >", 0x30aa30ff);
	cnt_ItemListTotal[playerid]++;

	cnt_CurrentContainer[playerid] = containerid;
	
	GetContainerName(containerid, containername);

	format(title, sizeof(title), "%s (%d/%d)", containername, containerSize - freeSlots, containerSize);

	ShowDialogDraw(playerid, 35, title);

	CallLocalFunction("OnPlayerOpenedContainer", "dd", playerid, _:containerid);

	return 0;
}

stock ClosePlayerContainer(playerid, call = true) {
	if(!IsPlayerConnected(playerid)) {
		return 1;
	}

	if(cnt_CurrentContainer[playerid] == INVALID_CONTAINER_ID) {
		return 2;
	}

	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;

	if(call) {
		if(CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, _:cnt_CurrentContainer[playerid])) {
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 3;
		}
	}

	return 0;
}

stock GetPlayerCurrentContainer(playerid, &Container:containerid) 
{
	if(!IsPlayerConnected(playerid)) {
		return 1;
	}

	containerid = cnt_CurrentContainer[playerid];
	return 0;
}

stock GetPlayerContainerSlot(playerid, &slot) 
{
	if(!IsPlayerConnected(playerid)) {
		return 1;
	}

	slot = cnt_SelectedSlot[playerid];
	return 0;
}

stock AddContainerOption(playerid, const option[]) 
{
	return AddDialogDrawItem(playerid, option, 0x30aa30ff);
}


// -
// Internal
// -


hook OnPlayerConnect(playerid) 
{
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
}

hook OnDialogDrawResponse(playerid, dialogid, response, listitem)
{
	if(dialogid == 36)
	{
		if(!response) {
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 1;
		}

		switch(listitem) {
			case 0: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid,
						ret;

					ret = GetContainerSlotItem(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], itemid);
					if(ret) {
						ShowActionText(playerid, "Erro", 3000, 200);
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
						return 1;
					}

					RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
					GiveWorldItemToPlayer(playerid, itemid);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
			}
			case 1: {
				if(GetPlayerItem(playerid) == INVALID_ITEM_ID) {
					new
						Item:itemid,
						ret;

					ret = GetContainerSlotItem(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], itemid);
					if(ret) {
						ShowActionText(playerid, "Erro", 3000, 200);
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
						return 1;
					}

					if(IsPlayerInAnyVehicle(playerid) && IsItemTypeCarry(GetItemType(itemid)))
					{
						ShowActionText(playerid, "Nao pode pegar este item no veiculo", 3000, 200);
						DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
						return 1;
					}
					
					RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
					GiveWorldItemToPlayer(playerid, itemid);

					ClosePlayerContainer(playerid);
					
					PlayerUseItem(playerid);
				} else {
					ShowActionText(playerid, "Voce ja esta segurando um item", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				}
			}
			case 2: {
				new
					Item:itemid,
					ret;

				ret = GetContainerSlotItem(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], itemid);
				if(ret) {
					ShowActionText(playerid, "Erro", 3000, 200);
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
					return 1;
				}

				if(!IsValidItem(itemid)) {
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
					return 0;
				}

				if(CallLocalFunction("OnMoveItemToInventory", "ddd", playerid, _:itemid, _:cnt_CurrentContainer[playerid])) {
					return 0;
				}

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);

				new required = AddItemToInventory(playerid, itemid);

				if(required > 0) {
					new str[32];
					format(str, sizeof(str), "Requer %d slots nos bolsos", required);
					ShowActionText(playerid, str, 3000, 150);
				}
				
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);

				return 1;
			}
			case 3: {
				new
					Item:itemid,
					ret;

				ret = GetContainerSlotItem(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], itemid);
				if(ret) {
					ShowActionText(playerid, "Erro", 3000, 200);
					return 1;
				}

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);

				if(IsItemTypeCarry(GetItemType(itemid))) {
					ApplyAnimation(playerid, "CARRY", "putdwn", 5.0, 0, 0, 0, 0, 0);
				} else {
					ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
				}

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

				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
			default: {
				if(!CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, _:cnt_CurrentContainer[playerid], listitem)) {
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				} else {
					ClosePlayerContainer(playerid);
				}
			}
		}

		return 1;
	}
	if(dialogid == 35)
	{
		if(response) {
			if(!IsValidContainer(cnt_CurrentContainer[playerid])) {
				return 0;
			}

			if(listitem >= cnt_ItemListTotal[playerid]) {
				DisplayPlayerInventory(playerid);
			} else {
				if(!(0 <= listitem < MAX_CONTAINER_SLOTS)) {
					return 0;
				}

				new Item:itemid;
				new ret = GetContainerSlotItem(cnt_CurrentContainer[playerid], listitem, itemid);
				if(ret || !IsValidItem(itemid)) {
					DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				} else {
					new
						title[MAX_ITEM_NAME + MAX_ITEM_TEXT + 6],
						itemsize;
					
					GetItemName(itemid, title);
					GetItemTypeSize(GetItemType(itemid), itemsize);

					format(title, sizeof(title), "(%d) %s", itemsize, title);
					
					AddDialogDrawItem(playerid, "Equipar", 0x30aa30ff);
					AddDialogDrawItem(playerid, "Usar", 0x30aa30ff);
					AddDialogDrawItem(playerid, "Mover para o bolso", 0x30aa30ff);
					AddDialogDrawItem(playerid, "Soltar item", 0x30aa30ff);
					cnt_SelectedSlot[playerid] = listitem;

					CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, _:cnt_CurrentContainer[playerid]);

					ShowDialogDraw(playerid, 36, title);
				}
			}
		} else {
			ClosePlayerContainer(playerid);
		}
	}
	return 1;
}

hook OnPlayerViewInvOpt(playerid) {
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID) {
		new
			containerName[MAX_CONTAINER_NAME],
			str[8 + MAX_CONTAINER_NAME];

		GetContainerName(cnt_CurrentContainer[playerid], containerName);

		str = "Mover para ";
		strcat(str, containerName);
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, str);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectInvOpt(playerid, option) {
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID) 
	{
		if(option == cnt_InventoryOptionID[playerid]) 
		{
			new
				slot,
				Item:itemid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			GetInventorySlotItem(playerid, slot, itemid);

			if(IsContainerFull(cnt_CurrentContainer[playerid])) {
				ShowActionText(playerid, "Container Cheio", 3000, 200);
			}

			if(!IsValidItem(itemid)) {
				DisplayPlayerInventory(playerid);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new required = AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);

			if(required == 0) {
				if(CallLocalFunction("OnMoveItemToContainer", "ddd", playerid, _:itemid, _:cnt_CurrentContainer[playerid]))
					return Y_HOOKS_BREAK_RETURN_1;
			}
			return Y_HOOKS_BREAK_RETURN_0;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid) {
	if(IsValidContainer(cnt_CurrentContainer[playerid])) {
		new str[4 + MAX_CONTAINER_NAME];
		GetContainerName(cnt_CurrentContainer[playerid], str);
		format(str, sizeof(str), "%s >", str);

		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectExtraItem(playerid, item) {
	if(IsValidContainer(cnt_CurrentContainer[playerid])) {
		if(item == cnt_InventoryContainerItem[playerid]) {
			ClosePlayerInventory(playerid, false);
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}