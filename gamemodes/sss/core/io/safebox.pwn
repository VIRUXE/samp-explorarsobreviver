
#include <YSI_Coding\y_hooks>


#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safebox/"


forward OnSafeboxLoad(Item:itemid, active, uuid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_SAFEBOX, "OnSafeboxLoad");
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		RemoveSafeboxItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		SafeboxSaveCheck(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	new Item:itemid = GetContainerSafeboxItem(containerid);

	if(IsValidItem(itemid) && IsItemTypeSafebox(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			uuid[UUID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemUUID(itemid, uuid);

		SafeboxSaveCheck(itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new Item:safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem) && IsItemTypeSafebox(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
			SafeboxSaveCheck(safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		new Item:safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem) && IsItemTypeSafebox(GetItemType(safeboxitem)) && !IsPlayerInTutorial(playerid))
			SafeboxSaveCheck(safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
		RemoveSafeboxItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

SafeboxSaveCheck(Item:itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	    return 0;

	new
		ret = SaveSafeboxItem(itemid),
		uname[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(itemid), uname);

	if(ret == 0)
		SetItemLabel(itemid, uname, 0xFFFF00FF, 2.0);
	else
		SetItemLabel(itemid, uname, 0xFF0000FF, 2.0);

	return 1;
}

RemoveSafeboxItem(Item:itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(Item:itemid, bool:active = true)
{
	new uuid[UUID_LEN];

	GetItemUUID(itemid, uuid);

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err(true, true, "Can't save safebox %d (%s): Item isn't a safebox, type: %d", _:itemid, uuid, _:GetItemType(itemid));
		return 2;
	}

	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	if(IsContainerEmpty(containerid))
	{
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		err(true, true, "Can't save safebox %d (%s): Not valid container (%d).", _:itemid, uuid, _:containerid);
		return 5;
	}

	new
		Item:items[12],
		itemcount,
		size;

	GetContainerSize(containerid, size);

	for(new i; i < size; i++)
	{
		GetContainerSlotItem(containerid, i, items[i]);

		if(!IsValidItem(items[i]))
			break;

		itemcount++;
	}

	if(!SerialiseItems(items, itemcount))
	{
		SaveWorldItem(itemid, DIRECTORY_SAFEBOX, active, false, itm_arr_Serialized, GetSerialisedSize());
	}

	return 0;
}

public OnSafeboxLoad(Item:itemid, active, uuid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err(true, true, "Loaded item %d (%s) is not a safebox (type: %d)", _:itemid, uuid, _:GetItemType(itemid));
		return 0;
	}

	new
		Container:containerid,
		Item:subitem,
		ItemType:itemtype;

	GetItemArrayDataAtCell(itemid, _:containerid, 0);

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

			subitem = CreateItem(itemtype);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
				SetItemArrayDataFromStored(subitem, i);

			AddItemToContainer(containerid, subitem);
		}

		log(false, "safebox loaded - uuid: %s itemid: %d containerid: %d active: %d items: %d", uuid, _:itemid, _:containerid, active, GetStoredItemCount());

		ClearSerializer();
	}

	return 1;
}
