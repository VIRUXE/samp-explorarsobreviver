
#include <YSI_Coding\y_hooks>


#define MAX_TENT			(2048)
#define MAX_TENT_ITEMS		(50)
#define INVALID_TENT_ID		(-1)
#define DIRECTORY_TENT		DIRECTORY_MAIN"tent/"


enum E_TENT_DATA
{
Item:		tnt_itemId,
Container:	tnt_containerId
}

enum E_TENT_OBJECT_DATA
{
			tnt_objSideR1,
			tnt_objSideR2,
			tnt_objSideL1,
			tnt_objSideL2,
			tnt_objDownR1,
			tnt_objDownR2,
			tnt_objDownL1,
			tnt_objDownL2,	
			tnt_objPoleF,
			tnt_objPoleB
}

static
			tnt_Data[MAX_TENT][E_TENT_DATA],
			tnt_ObjData[MAX_TENT][E_TENT_OBJECT_DATA],
			tnt_ContainerTent[MAX_CONTAINER] = {-1, ...},
Item:		tnt_CurrentTentItem[MAX_PLAYERS],
			tnt_TweakID[MAX_PLAYERS];

new
   Iterator:tnt_Index<MAX_TENT>;


forward OnTentCreate(tentid);
forward OnTentDestroy(tentid);
forward OnTentLoad(Item:itemid, active, uuid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_TENT);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_TENT, "OnTentLoad");
}

hook OnPlayerConnect(playerid)
{
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
	tnt_TweakID[playerid] = INVALID_TENT_ID;
}

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "TentPack"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("TentPack"), 1);
}

hook OnItemCreated(Item:itemid)
{
	if(GetItemType(itemid) == item_TentPack)
	{
		SetItemExtraData(itemid, INVALID_TENT_ID);
	}
}


/*==============================================================================

	Core

==============================================================================*/


stock CreateTentFromItem(Item:itemid)
{
	if(GetItemType(itemid) != item_TentPack)
	{
		err(true, true, "Attempted to create tent from non-tentpack item %d type: %d", _:itemid, _:GetItemType(itemid));
		return -1;
	}

	new id = Iter_Free(tnt_Index);

	if(id == -1)
	{
		err(false, true, "MAX_TENT limit reached.");
		return -1;
	}

	Iter_Add(tnt_Index, id);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz,
		worldid,
		interiorid;

	GetItemWorld(itemid, worldid);
	GetItemInterior(itemid, interiorid);
	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);

	z += 1.45;
	rz += 90.0;

	tnt_Data[id][tnt_itemId] = itemid;
	tnt_Data[id][tnt_containerId] = CreateContainer("Tenda", MAX_TENT_ITEMS);

	tnt_ContainerTent[tnt_Data[id][tnt_containerId]] = id;

	SetItemExtraData(itemid, id);

	// Side Right
	tnt_ObjData[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z, 0.0, 45.0, rz, worldid, interiorid);
	tnt_ObjData[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z, 0.0, 45.0, rz, worldid, interiorid);

	// Side Left
	tnt_ObjData[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z, 0.0, -45.0, rz, worldid, interiorid);
	tnt_ObjData[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z, 0.0, -45.0, rz, worldid, interiorid);

	// Down Right
	tnt_ObjData[id][tnt_objDownR1] = CreateDynamicObject(19477,
		x + (1.48 * floatsin(-rz + 270.0, degrees)),
		y + (1.48 * floatcos(-rz + 270.0, degrees)),
		z - 0.98, 0.0, 45.0, rz, worldid, interiorid);
	tnt_ObjData[id][tnt_objDownR2] = CreateDynamicObject(19477,
		x + (1.47 * floatsin(-rz + 270.0, degrees)),
		y + (1.47 * floatcos(-rz + 270.0, degrees)),
		z - 0.98, 0.0, 45.0, rz, worldid, interiorid);
		
	// Down Left
	tnt_ObjData[id][tnt_objDownL1] = CreateDynamicObject(19477,
		x + (1.48 * floatsin(-rz + 90.0, degrees)),
		y + (1.48 * floatcos(-rz + 90.0, degrees)),
		z - 0.98, 0.0, -45.0, rz, worldid, interiorid);
	tnt_ObjData[id][tnt_objDownL2] = CreateDynamicObject(19477,
		x + (1.47 * floatsin(-rz + 90.0, degrees)),
		y + (1.47 * floatcos(-rz + 90.0, degrees)),
		z - 0.98, 0.0, -45.0, rz, worldid, interiorid);

	tnt_ObjData[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48, 0.0, 0.0, rz, worldid, interiorid);

	tnt_ObjData[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48, 0.0, 0.0, rz, worldid, interiorid);

	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objDownR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objDownR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objDownL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objDownL2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleF],	 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleB],  0, 1270, "signs", "lamppost", 0);

	CallLocalFunction("OnTentCreate", "d", id);

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	CallLocalFunction("OnTentDestroy", "d", tentid);
	_tent_Remove(tentid);

	if(GetItemType(tnt_Data[tentid][tnt_itemId]) != item_TentPack)
		return 0;

	SetItemExtraData(tnt_Data[tentid][tnt_itemId], INVALID_TENT_ID);

	if(IsValidContainer(tnt_Data[tentid][tnt_containerId]))
	{
		tnt_ContainerTent[tnt_Data[tentid][tnt_containerId]] = -1;
		DestroyContainer(tnt_Data[tentid][tnt_containerId]);
	}

	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objDownR1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objDownR2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objDownL1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objDownL2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleB]);

	tnt_ObjData[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objDownR1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objDownR2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objDownL1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objDownL2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;

	Iter_SafeRemove(tnt_Index, tentid, tentid);

	return tentid;
}

SaveTent(tentid, bool:active = true)
{
	if(!Iter_Contains(tnt_Index, tentid))
	{
		err(true, true, "[SaveTent] ERROR: Attempted to save tent ID %d active: %d that was not found in index.", tentid, active);
		return 0;
	}

	new
		Item:itemid = GetTentItem(tentid),
		Container:containerid = GetTentContainer(tentid),
		uuid[UUID_LEN],
		world;

	GetItemUUID(itemid, uuid);
	GetItemWorld(itemid, world);

	if(world != 0)
		return 1;

	if(!IsValidContainer(containerid))
	{
		err(true, true, "Can't save tent %d (%s): Not valid container (%d).", _:itemid, uuid, _:containerid);
		return 2;
	}

	if(GetItemType(itemid) != item_TentPack || IsContainerEmpty(containerid))
	{
		RemoveSavedItem(itemid, DIRECTORY_TENT);
		return 3;
	}

	new
		Item:items[MAX_TENT_ITEMS],
		itemcount;

	GetContainerItemCount(containerid, itemcount);

	for(new i; i < itemcount; i++)
	{
		if(!IsValidItem(items[i]))
			break;

		GetContainerSlotItem(containerid, i, items[i]);
	}

	if(!SerialiseItems(items, itemcount))
	{
		SaveWorldItem(itemid, DIRECTORY_TENT, active, false, itm_arr_Serialized, GetSerialisedSize());
		ClearSerializer();
	}

	return 0;
}

public OnTentLoad(Item:itemid, active, uuid[], data[], length)
{
	new
		tentid,
		Container:containerid,
		ItemType:itemtype,
		Item:subitem;

	tentid = CreateTentFromItem(itemid);
	containerid = GetTentContainer(tentid);

	if(GetItemType(itemid) != item_TentPack)
	{
		RemoveSavedItem(itemid, DIRECTORY_TENT);
		return 0;
	}

	if(!DeserialiseItems(data, length))
	{
		for(new i, j = GetStoredItemCount(); i < j; i++)
		{
			itemtype = GetStoredItemType(i);

			if(length == 0)
				break;

			if(itemtype == INVALID_ITEM_TYPE)
				break;

			if(itemtype == ItemType:0)
				break;

			subitem = CreateItem(itemtype, .virtual = 1);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromStored(subitem, i);

			AddItemToContainer(containerid, subitem);
		}

		ClearSerializer();
	}

	return 1;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


_tent_Remove(tentid)
{
	RemoveSavedItem(GetTentItem(tentid), DIRECTORY_TENT);
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(gServerInitialising || !IsPlayerConnected(playerid))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetContainerTent(containerid) != -1 && !IsPlayerInTutorial(playerid))
		SaveTent(GetContainerTent(containerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(Container:containerid, slotid, playerid)
{
	if(gServerInitialising || !IsPlayerConnected(playerid))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetContainerTent(containerid) != -1 && !IsPlayerInTutorial(playerid))
		SaveTent(GetContainerTent(containerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	if(gServerInitialising)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetContainerTent(containerid) != -1 && !IsPlayerInTutorial(playerid))
		SaveTent(GetContainerTent(containerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_TentPack && !IsPlayerInTutorial(playerid))
	{
		new tentid;
		GetItemExtraData(itemid, tentid);

		if(IsValidTent(tentid) && GetItemType(tnt_Data[tentid][tnt_itemId]) == item_TentPack)
		{
			DisplayContainerInventory(playerid, tnt_Data[tentid][tnt_containerId]);
			SaveTent(tentid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_TentPack)
	{
		new tentid;
		GetItemExtraData(withitemid, tentid);

		if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID){
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

			if(itemtype == item_Hammer)
			{
				StopBuildingTent(playerid);
			}
			else if(itemtype == item_Crowbar)
			{
				StopRemovingTent(playerid);
			}
		} else {
			if(!IsValidTent(tentid))
			{
				if(GetItemType(itemid) == item_Hammer)
				{
					StartBuildingTent(playerid, withitemid);
					return Y_HOOKS_BREAK_RETURN_1;
				}
			}
			else
			{
				if(GetItemType(itemid) == item_Crowbar)
				{
					StartRemovingTent(playerid, withitemid);
					return Y_HOOKS_BREAK_RETURN_1;
				}
				else
				{
					DisplayContainerInventory(playerid, tnt_Data[tentid][tnt_containerId]);
					return Y_HOOKS_BREAK_RETURN_1;
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartBuildingTent(playerid, Item:itemid)
{
	StartHoldAction(playerid, 10000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "TENTBUILD"));
	tnt_CurrentTentItem[playerid] = itemid;
}

StopBuildingTent(playerid)
{
	if(tnt_CurrentTentItem[playerid] == INVALID_ITEM_ID)
		return;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
	tnt_TweakID[playerid] = INVALID_TENT_ID;

	return;
}

StartRemovingTent(playerid, Item:itemid)
{
	StartHoldAction(playerid, 15000);
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "TENTREMOVE"));
	tnt_CurrentTentItem[playerid] = itemid;
}

StopRemovingTent(playerid)
{
	if(tnt_CurrentTentItem[playerid] == INVALID_ITEM_ID)
		return;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;

	return;
}

hook OnItemTweakUpdate(playerid, Item:itemid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		new Float:x, Float:y, Float:z, Float:rz, tentid;
		
		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);

		z += 1.45;
		rz += 90.0;
		tentid = tnt_TweakID[playerid];
		
		// Side Right
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objSideR1],
			x + (0.49 * floatsin(-rz + 270.0, degrees)),
			y + (0.49 * floatcos(-rz + 270.0, degrees)), z);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objSideR1], 0.0, 45.0, rz);

		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objSideR2],
			x + (0.48 * floatsin(-rz + 270.0, degrees)),
			y + (0.48 * floatcos(-rz + 270.0, degrees)), z);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objSideR2], 0.0, 45.0, rz);

		// Side Left
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objSideL1],
			x + (0.49 * floatsin(-rz + 90.0, degrees)),
			y + (0.49 * floatcos(-rz + 90.0, degrees)), z);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objSideL1], 0.0, -45.0, rz);

		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objSideL2],
			x + (0.48 * floatsin(-rz + 90.0, degrees)),
			y + (0.48 * floatcos(-rz + 90.0, degrees)), z);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objSideL2], 0.0, -45.0, rz);

		// Down Right
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objDownR1],
			x + (1.48 * floatsin(-rz + 270.0, degrees)),
			y + (1.48 * floatcos(-rz + 270.0, degrees)), z - 0.98);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objDownR1], 0.0, 45.0, rz);

		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objDownR2],
			x + (1.47 * floatsin(-rz + 270.0, degrees)),
			y + (1.47 * floatcos(-rz + 270.0, degrees)), z - 0.98);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objDownR2], 0.0, 45.0, rz);

		// Down Left
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objDownL1],
			x + (1.48 * floatsin(-rz + 90.0, degrees)),
			y + (1.48 * floatcos(-rz + 90.0, degrees)), z - 0.98);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objDownL1], 0.0, -45.0, rz);

		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objDownL2],
			x + (1.47 * floatsin(-rz + 90.0, degrees)),
			y + (1.47 * floatcos(-rz + 90.0, degrees)), z - 0.98);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objDownL2], 0.0, -45.0, rz);

		// Pole F
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objPoleF],
			x + (1.3 * floatsin(-rz, degrees)),
			y + (1.3 * floatcos(-rz, degrees)), z + 0.48);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objPoleF], 0.0, 0.0, rz);

		// Pole B
		SetDynamicObjectPos(tnt_ObjData[tentid][tnt_objPoleB],
			x - (1.3 * floatsin(-rz, degrees)),
			y - (1.3 * floatcos(-rz, degrees)), z + 0.48);
		SetDynamicObjectRot(tnt_ObjData[tentid][tnt_objPoleB], 0.0, 0.0, rz);
	}
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		StopBuildingTent(playerid);
	}
}

hook OnHoldActionUpdate(playerid, progress) {
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID && GetPlayerTotalVelocity(playerid) > 1.0)
	{
		StopBuildingTent(playerid);
		return Y_HOOKS_BREAK_RETURN_0;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
		{
			ClearAnimations(playerid);
			HideActionText(playerid);
			tnt_TweakID[playerid] = CreateTentFromItem(tnt_CurrentTentItem[playerid]);
			TweakItem(playerid, tnt_CurrentTentItem[playerid]);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				tentid,
				count;

			GetItemExtraData(tnt_CurrentTentItem[playerid], tentid);

			if(!IsValidTent(tentid))
			{
				err(true, true, "Player %d attempted to destroy invalid tent %d from item %d", playerid, tentid, _:tnt_CurrentTentItem[playerid]);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			GetItemPos(tnt_CurrentTentItem[playerid], x, y, z);
			GetContainerItemCount(tnt_Data[tentid][tnt_containerId], count);

			for(new i = count; i >= 0; i--)
			{
				new Item:slotitem;
				GetContainerSlotItem(tnt_Data[tentid][tnt_containerId], i, slotitem);
				CreateItemInWorld(slotitem, x, y, z, 0.0, 0.0, frandom(360.0));
			}

			DestroyTent(tentid);
			StopRemovingTent(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid) 
{
	if(GetItemType(itemid) == item_TentPack && IsItemInWorld(itemid))
	{
		new tentid;
		GetItemExtraData(itemid, tentid);
		if(IsValidTent(tentid))
		{
			new count;
			GetContainerItemCount(tnt_Data[tentid][tnt_containerId], count);
			for(new i = count; i >= 0; i--)
			{
				new Item:slotitem;
				GetContainerSlotItem(tnt_Data[tentid][tnt_containerId], i, slotitem);
				DestroyItem(slotitem);
			}
			DestroyTent(tentid);
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Interface

==============================================================================*/


stock IsValidTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return 1;
}

// tnt_itemId
stock Item:GetTentItem(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return INVALID_ITEM_ID;

	return tnt_Data[tentid][tnt_itemId];
}

// tnt_containerId
stock Container:GetTentContainer(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return INVALID_CONTAINER_ID;

	return tnt_Data[tentid][tnt_containerId];
}

stock GetContainerTent(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_TENT_ID;

	return tnt_ContainerTent[containerid];
}

stock GetTentPos(tentid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return GetItemPos(tnt_Data[tentid][tnt_itemId], x, y, z);
}