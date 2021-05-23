#include <YSI\y_hooks>


#define DIRECTORY_TENT		DIRECTORY_MAIN"tents/"


forward OnTentLoad(itemid, active, geid[], data[], length);


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


/*==============================================================================

	Core

==============================================================================*/


/*hook OnTentCreate(tentid)
{
	SaveTent(tentid);
}*/

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	if(gServerInitialising)
		return Y_HOOKS_CONTINUE_RETURN_0;

	SaveTent(GetContainerTent(containerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
	if(gServerInitialising)
		return Y_HOOKS_CONTINUE_RETURN_0;

	SaveTent(GetContainerTent(containerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnTentDestroy(tentid)
{
	RemoveTent(tentid);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveTent(tentid, bool:active = true)
{
	dbg("gamemodes/sss/extensions/tent-io.pwn", 1, "[SaveTent] %d %d", tentid, active);

	if(!Iter_Contains(tnt_Index, tentid))
	{
		dbg("gamemodes/sss/extensions/tent-io.pwn", 2, "[SaveTent] ERROR: Attempted to save tent ID %d active: %d that was not found in index.", tentid, active);
		return 1;
	}

	new
		itemid = GetTentItem(tentid),
		containerid = GetTentContainer(tentid);

	if(IsContainerEmpty(containerid))
	{
		dbg("gamemodes/sss/extensions/tent-io.pwn", 1, "[SaveTent] Empty, removing");
		RemoveSavedItem(itemid, DIRECTORY_TENT);
		return 2;
	}

	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(!IsValidContainer(containerid))
	{
		err("Can't save tent %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 3;
	}

	new
		items[MAX_TENT_ITEMS],
		itemcount = GetContainerItemCount(containerid);

	for(new i; i < itemcount; i++)
		items[i] = GetContainerSlotItem(containerid, i);

	if(!SerialiseItems(items, itemcount))
	{
		SaveWorldItem(itemid, DIRECTORY_TENT, active, false, itm_arr_Serialized, GetSerialisedSize());
		ClearSerializer();
	}

	return 0;
}

RemoveTent(tentid)
{
	RemoveSavedItem(GetTentItem(tentid), DIRECTORY_TENT);
}

public OnTentLoad(itemid, active, geid[], data[], length)
{
	new
		tentid,
		containerid,
		ItemType:itemtype,
		subitem;

	tentid = CreateTentFromItem(itemid);
	containerid = GetTentContainer(tentid);

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

		ClearSerializer();
	}

	return 1;
}
