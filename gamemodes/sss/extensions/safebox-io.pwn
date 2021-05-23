#include <YSI\y_hooks>

#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safeboxes/"

forward OnSafeboxLoad(itemid, active, geid[], data[], length);

hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_SAFEBOX, "OnSafeboxLoad");
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);
		dbg("gamemodes/sss/extensions/safebox-io.pwn", 1, "[OnPlayerPickUpItem] Player %p picked up safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

		RemoveSafeboxItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);
		dbg("gamemodes/sss/extensions/safebox-io.pwn", 1, "[OnPlayerDroppedItem] Player %p dropped safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

		SafeboxSaveCheck(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(IsValidItem(itemid))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			geid[GEID_LEN];

		GetPlayerPos(playerid, x, y, z);
		GetItemGEID(itemid, geid);
		dbg("gamemodes/sss/extensions/safebox-io.pwn", 1, "[OnPlayerCloseContainer] Player %p closed safebox item %d (%s) at %f %f %f", playerid, itemid, geid, x, y, z);

		SafeboxSaveCheck(playerid, itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		new safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		new safeboxitem = GetContainerSafeboxItem(containerid);

		if(IsValidItem(safeboxitem))
			SafeboxSaveCheck(playerid, safeboxitem);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	dbg("global", LOG_CORE, "[OnItemDestroy] in /gamemodes/sss/core/world/safebox.pwn");

	if(IsItemTypeSafebox(GetItemType(itemid)))
		RemoveSafeboxItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

SafeboxSaveCheck(playerid, itemid)
{
	new
		ret = SaveSafeboxItem(itemid),
		geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(ret == 0)
	{
		// SetItemLabel(itemid, sprintf("SAVED (itemid: %d, geid: %s)", itemid, geid), 0xFFFF00FF, 2.0);
	}
	else
	{
		// SetItemLabel(itemid, sprintf("NOT SAVED (itemid: %d, geid: %s)", itemid, geid), 0xFF0000FF, 2.0);

		if(ret == 1)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid item.", itemid, geid);
		if(ret == 2)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item isn't safebox.", itemid, geid);
		if(ret == 3)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Item not in world.", itemid, geid);
		if(ret == 4)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Container empty", itemid, geid);
		if(ret == 5)
			ChatMsg(playerid, YELLOW, "ERROR: Can't save item %d GEID: %s: Invalid container (%d).", itemid, geid, GetItemArrayDataAtCell(itemid, 0));
	}
}

RemoveSafeboxItem(itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSafeboxItem(itemid, bool:active = true)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Can't save safebox %d (%s): Item isn't a safebox, type: %d", itemid, geid, _:GetItemType(itemid));
		return 2;
	}

	new containerid = GetItemArrayDataAtCell(itemid, 0);

	if(IsContainerEmpty(containerid))
	{
		dbg("gamemodes/sss/extensions/safebox-io.pwn", 1, "[SaveSafeboxItem] Not saving safebox %d (%s): Container is empty", itemid, geid);
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		err("Can't save safebox %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 5;
	}

	new
		items[12],
		itemcount;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

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

public OnSafeboxLoad(itemid, active, geid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		err("Loaded item %d (%s) is not a safebox (type: %d)", itemid, geid, _:GetItemType(itemid));
		return 0;
	}

	new
		containerid = GetItemArrayDataAtCell(itemid, 0),
		subitem,
		ItemType:itemtype;

	DeserialiseItems(data, length);

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

	ClearSerializer();

	return 1;
}
