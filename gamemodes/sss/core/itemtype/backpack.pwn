#include <YSI_Coding\y_hooks>


#define MAX_BAG_TYPE (10)


enum E_BAG_TYPE_DATA
{
			bag_name[MAX_ITEM_NAME],
ItemType:	bag_itemtype,
			bag_size
}


enum E_BAG_FLOAT_DATA
{
Float:		bag_offs_x,
Float:		bag_offs_y,
Float:		bag_offs_z,
Float:		bag_offs_rx,
Float:		bag_offs_ry,
Float:		bag_offs_rz,
Float:		bag_offs_sx,
Float:		bag_offs_sy,
Float:		bag_offs_sz
}


static
			bag_TypeDataFloat[MAX_BAG_TYPE][312][E_BAG_FLOAT_DATA],
			bag_TypeData[MAX_BAG_TYPE][E_BAG_TYPE_DATA],
			bag_TypeTotal,
			bag_ItemTypeBagType[MAX_ITEM_TYPE] = {-1, ...},
Item:		bag_ContainerItem		[MAX_CONTAINER],
			bag_ContainerPlayer		[MAX_CONTAINER],
Item:		bag_PlayerBagID			[MAX_PLAYERS],
bool:		bag_PuttingInBag		[MAX_PLAYERS],
Item:		bag_CurrentBag			[MAX_PLAYERS];


forward OnPlayerWearBag(playerid, Item:itemid);
forward OnPlayerRemoveBag(playerid, Item:itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new Container:i; i < MAX_CONTAINER; i++)
	{
		bag_ContainerPlayer[i] = INVALID_PLAYER_ID;
		bag_ContainerItem[i] = INVALID_ITEM_ID;
	}
}

hook OnPlayerConnect(playerid)
{
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_PuttingInBag[playerid] = false;
	bag_CurrentBag[playerid] = INVALID_ITEM_ID;
	//bag_LookingInBag[playerid] = INVALID_PLAYER_ID;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineBagType(const name[MAX_ITEM_NAME], ItemType:itemtype, size)
{
	if(bag_TypeTotal == MAX_BAG_TYPE)
		return -1;

	bag_TypeData[bag_TypeTotal][bag_name]			= name;
	bag_TypeData[bag_TypeTotal][bag_itemtype]		= itemtype;
	bag_TypeData[bag_TypeTotal][bag_size]			= size;

	bag_ItemTypeBagType[itemtype] = bag_TypeTotal;

	return bag_TypeTotal++;
}

stock SetBagOffsetsForSkin(bagtype, skinid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:sx, Float:sy, Float:sz){
    bag_TypeDataFloat[bagtype][skinid][bag_offs_x] = x;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_y] = y;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_z] = z;

    bag_TypeDataFloat[bagtype][skinid][bag_offs_rx] = rx;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_ry] = ry;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_rz] = rz;

    bag_TypeDataFloat[bagtype][skinid][bag_offs_sx] = sx;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_sy] = sy;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_sz] = sz;
}

stock GivePlayerBag(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{

		new Container:containerid;
		GetItemExtraData(itemid, _:containerid);

		if(!IsValidContainer(containerid))
		{
			err(true, true, "Bag (%d) container ID (%d) was invalid container has to be recreated.", _:itemid, _:containerid);

			containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);
			SetItemExtraData(itemid, _:containerid);
		}

		new colour;
		GetItemTypeColour(bag_TypeData[bagtype][bag_itemtype], colour);

		bag_PlayerBagID[playerid] = itemid;

		new model, skinid = GetPlayerSkin(playerid);
		
		GetItemTypeModel(bag_TypeData[bagtype][bag_itemtype], model);

		SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, model, 1,
			bag_TypeDataFloat[bagtype][skinid][bag_offs_x],
  			bag_TypeDataFloat[bagtype][skinid][bag_offs_y],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_z],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_rx],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_ry],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_rz],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sx],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sy],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sz], colour, colour);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = playerid;
		RemoveItemFromWorld(itemid);
		RemoveCurrentItem(GetItemHolder(itemid));

		return 1;
	}

	return 0;
}

stock RemovePlayerBag(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemExtraData(bag_PlayerBagID[playerid], _:containerid);

	if(!IsValidContainer(containerid))
	{
		new bagtype = bag_ItemTypeBagType[GetItemType(bag_PlayerBagID[playerid])];

		if(bagtype == -1)
		{
			err(true, true, "Player (%d) bag item type (%d) is not a valid bag type.", playerid, bagtype);
			return 0;
		}

		err(true, true, "Bag (%d) container ID (%d) was invalid container has to be recreated.", _:bag_PlayerBagID[playerid], _:containerid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);
		SetItemExtraData(bag_PlayerBagID[playerid], _:containerid);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

stock DestroyPlayerBag(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemExtraData(bag_PlayerBagID[playerid], _:containerid);

	if(IsValidContainer(containerid))
	{
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
		DestroyContainer(containerid);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	DestroyItem(bag_PlayerBagID[playerid]);

	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnItemCreate(Item:itemid)
{
	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		new
			Container:containerid,
			lootindex = GetItemLootIndex(itemid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		if(IsValidContainer(containerid))
		{
			bag_ContainerItem[containerid] = itemid;
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

			SetItemExtraData(itemid, _:containerid);

			if(lootindex != -1)
				FillContainerWithLoot(containerid, random(4), lootindex);
		}
	}
}

hook OnItemDestroy(Item:itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		new Container:containerid;
		GetItemExtraData(itemid, _:containerid);
		if(IsValidContainer(containerid))
		{
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
			bag_ContainerItem[containerid] = INVALID_ITEM_ID;
			DestroyContainer(containerid);
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(bag_ItemTypeBagType[GetItemType(itemid)] != -1)
	{
		new Container:containerid;
		GetPlayerCurrentContainer(playerid, containerid);
		if(IsValidContainer(containerid))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
			GiveWorldItemToPlayer(playerid, itemid),
			_DisplayBagDialog(playerid, itemid, true);

		else
		
			_DisplayBagDialog(playerid, itemid, false);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(bag_ItemTypeBagType[GetItemType(withitemid)] != -1)
	{
		_DisplayBagDialog(playerid, withitemid, true);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsAdminOnDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381 || GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 1;

	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys & KEY_YES)
	{
		_BagEquipHandler(playerid);
	}

	if(newkeys & KEY_NO)
	{
		_BagDropHandler(playerid);
	}

	return 1;
}

_BagEquipHandler(playerid)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	if(bag_PuttingInBag[playerid])
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
	{
		if(IsValidItem(bag_PlayerBagID[playerid]))
		{
			new Item:currentbagitem = bag_PlayerBagID[playerid];

			RemovePlayerBag(playerid);
			GivePlayerBag(playerid, itemid);
			GiveWorldItemToPlayer(playerid, currentbagitem, 1);
		}
		else
		{
			if(CallLocalFunction("OnPlayerWearBag", "dd", playerid, _:itemid))
				return 0;

			GivePlayerBag(playerid, itemid);
		}

		return 0;
	}

	return 1;
}

_BagDropHandler(playerid)
{
	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	if(IsValidItem(GetPlayerItem(playerid)))
		return 0;

	if(IsValidItem(GetPlayerInteractingItem(playerid)))
		return 0;

	if(CallLocalFunction("OnPlayerRemoveBag", "dd", playerid, _:bag_PlayerBagID[playerid]))
		return 0;

	new Container:containerid;
	GetItemExtraData(bag_PlayerBagID[playerid], _:containerid);

	if(!IsValidContainer(containerid))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	GiveWorldItemToPlayer(playerid, bag_PlayerBagID[playerid], 1);
	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

_DisplayBagDialog(playerid, Item:itemid, animation)
{
	new Container:containerid;
	GetItemExtraData(itemid, _:containerid);
	DisplayContainerInventory(playerid, containerid);
	bag_CurrentBag[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else
		CancelPlayerMovement(playerid);
}

hook OnItemAddToInventory(playerid, Item:itemid, slot)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsItemTypeCarry(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerAddToInventory(playerid, Item:itemid, success)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsItemTypeCarry(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsValidHolsterItem(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(success)
	{
		ShowActionText(playerid, ls(playerid, "INVITMADDED"), 3000, 150);
	}
	else
	{
		if(IsValidItem(bag_PlayerBagID[playerid]))
		{
			AddItemToPlayer(playerid, itemid);
		}
		else
		{
			new
				itemsize,
				freeslots;

			GetItemTypeSize(GetItemType(itemid), itemsize);
			GetInventoryFreeSlots(playerid, freeslots);

			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO"), itemsize - freeslots), 3000, 150);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

AddItemToPlayer(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return;

	if(bag_PuttingInBag[playerid])
		return;

	if(GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return;

	if(GetPlayerItem(playerid) != itemid)
		return;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return;

	if(IsValidItem(bag_CurrentBag[playerid]))
		return;

	new Container:containerid;
	GetItemExtraData(bag_PlayerBagID[playerid], _:containerid);

	if(!IsValidContainer(containerid))
		return;

	new
		itemsize,
		freeslots;

	GetItemTypeSize(GetItemType(itemid), itemsize);
	GetContainerFreeSlots(containerid, freeslots);

	if(itemsize > freeslots)
	{
		ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO"), itemsize - freeslots), 3000, 150);
		return;
	}

	ShowActionText(playerid, ls(playerid, "BAGITMADDED"), 3000, 150);
	ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
	bag_PuttingInBag[playerid] = true;
	defer bag_PutItemIn(playerid, _:itemid, _:containerid);

	return;
}

timer bag_PutItemIn[150](playerid, itemid, containerid)
{
	if(!IsValidItem(Item:itemid))
		return;

	if(!IsValidContainer(Container:containerid))
		return;

	AddItemToContainer(Container:containerid, Item:itemid, playerid);
	bag_PuttingInBag[playerid] = false;

	return;
}


hook OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(bag_CurrentBag[playerid]))
	{
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	if(IsValidItem(bag_CurrentBag[playerid]))
	{
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToContainer(Container:containerid, Item:itemid, playerid)
{
	if(GetContainerBagItem(containerid) != INVALID_ITEM_ID)
	{
		if(IsItemTypeCarry(GetItemType(itemid)))
		{
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Bag button

==============================================================================*/

new 
	bag_InvOptionID[MAX_PLAYERS],
	bag_CntOptionID[MAX_PLAYERS];


/*
	Inventory button
*/

hook OnPlayerViewInvOpt(playerid)
{
	if(IsValidItem(bag_PlayerBagID[playerid]))
	{
		bag_InvOptionID[playerid] = AddInventoryOption(playerid, "Mover para Mochila >");
	}
}

hook OnPlayerSelectInvOpt(playerid, option)
{
	if(IsValidItem(bag_PlayerBagID[playerid]))
	{
		if(option == bag_InvOptionID[playerid])
		{
			new
				slot,
				Item:itemid,
				Container:containerid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			GetInventorySlotItem(playerid, slot, itemid);
			GetItemExtraData(bag_PlayerBagID[playerid], _:containerid);

			if(IsValidItem(itemid) && IsValidContainer(containerid))
			{
				RemoveItemFromInventory(playerid, slot);

				new required = AddItemToContainer(containerid, itemid, playerid);

				if(required > 0)
					ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO"), required), 3000, 150);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*
	Container button
*/

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	if(IsValidItem(bag_PlayerBagID[playerid]))
	{
		new Container:bagcontainerid;
		GetItemExtraData(bag_PlayerBagID[playerid], _:bagcontainerid);
		if(IsValidContainer(bagcontainerid) && containerid != bagcontainerid)
		{
			bag_CntOptionID[playerid] = AddContainerOption(playerid, "Mover para Mochila >");
		}
	}
}

hook OnPlayerSelectCntOpt(playerid, Container:containerid, option)
{
	if(IsValidItem(bag_PlayerBagID[playerid]))
	{
		new Container:bagcontainerid;
		GetItemExtraData(bag_PlayerBagID[playerid], _:bagcontainerid);
		if(IsValidContainer(bagcontainerid) && containerid != bagcontainerid)
		{
			if(option == bag_CntOptionID[playerid])
			{
				new
					slot,
					Item:itemid;

				GetPlayerContainerSlot(playerid, slot);
				GetContainerSlotItem(containerid, slot, itemid);

				if(IsValidItem(itemid))
				{
					RemoveItemFromContainer(containerid, slot, playerid, true);

					new required = AddItemToContainer(bagcontainerid, itemid, playerid);

					if(required > 0)
						ShowActionText(playerid, sprintf(ls(playerid, "BAGEXTRASLO"), required), 3000, 150);
				}
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeBag(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return (bag_ItemTypeBagType[itemtype] != -1) ? (true) : (false);
}

stock GetItemBagType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return bag_ItemTypeBagType[itemtype];
}

stock Item:GetPlayerBagItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return bag_PlayerBagID[playerid];
}

stock Item:GetPlayerCurrentBag(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;
		
	return bag_CurrentBag[playerid];
}

stock GetContainerPlayerBag(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_PLAYER_ID;

	return bag_ContainerPlayer[containerid];
}

stock Item:GetContainerBagItem(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return bag_ContainerItem[containerid];
}

stock Container:GetBagItemContainerID(Item:itemid)
{
	if(!IsItemTypeBag(GetItemType(itemid)))
		return INVALID_CONTAINER_ID;

	new Container:containerid;
	GetItemExtraData(itemid, _:containerid);

	return containerid;
}