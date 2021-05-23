#include <YSI\y_hooks>

enum e_SAVED_ITEM_DATA
{
ItemType:	SAVED_ITEM_TYPE,
			SAVED_ITEM_ACTIVE,
Float:		SAVED_ITEM_POS_X,
Float:		SAVED_ITEM_POS_Y,
Float:		SAVED_ITEM_POS_Z,
Float:		SAVED_ITEM_ROT_X,
Float:		SAVED_ITEM_ROT_Y,
Float:		SAVED_ITEM_ROT_Z,
			SAVED_ITEM_WORLD,
			SAVED_ITEM_INTERIOR,
			SAVED_ITEM_HITPOINTS
}

static big_data[8192];

SaveWorldItem(itemid, subdir[], bool:active, savearray = true, data[] = "", data_size = 0)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(gServerInitialising)
	{
		dbg("item-io", 1, "[SaveItem] Not saving %d (%s) while gServerInitialising.", itemid, geid);
		return 1;
	}

	if(!IsValidItem(itemid))
	{
		err("Can't save item %d (%s) Not valid item.", itemid, geid);
		return 2;
	}

	if(!IsItemInWorld(itemid))
	{
		dbg("item-io", 1, "[SaveItem] ERROR: Can't save item %d (%s) Item not in world.", itemid, geid);
		return 3;
	}

	if(isnull(geid))
	{
		dbg("item-io", 1, "[SaveItem] ERROR: Can't save item %d (%s) Item has null GEID.", itemid, geid);
		return 4;
	}

	new
		filename[256],
		info[e_SAVED_ITEM_DATA];

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	info[SAVED_ITEM_TYPE] = GetItemType(itemid);
	info[SAVED_ITEM_ACTIVE] = active;
	GetItemPos(itemid, info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
	GetItemRot(itemid, info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);
	info[SAVED_ITEM_WORLD] = GetItemWorld(itemid);
	info[SAVED_ITEM_INTERIOR] = GetItemInterior(itemid);
	info[SAVED_ITEM_HITPOINTS] = GetItemHitPoints(itemid);

	log(DISCORD_CHANNEL_INVALID, "[SAVE] Item %d (%s) info: %d %d %d (%f, %f, %f, %f, %f, %f)",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE], info[SAVED_ITEM_HITPOINTS],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z],
		info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);

	modio_push(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info);

	if(savearray)
	{
		dbg("item-io", 1, "[SaveItem] Saving arraydata associated with item");
		new arraydatalen = GetItemArrayDataSize(itemid);

		if(arraydatalen > 0)
		{
			dbg("item-io", 1, "[SaveItem] array data length %d", arraydatalen);
			new arraydata[ITM_ARR_MAX_ARRAY_DATA];

			GetItemArrayData(itemid, arraydata);

			modio_push(filename, _T<A,R,R,Y>, arraydatalen, arraydata);
		}
	}

	if(data_size > 0)
	{
		modio_push(filename, _T<D,A,T,A>, data_size, data);
	}

	modio_finalise_write(modio_getsession_write(filename));

	return 0;
}

RemoveSavedItem(itemid, subdir[])
{
	new
		geid[GEID_LEN],
		filename[256];

	GetItemGEID(itemid, geid);

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	fremove(filename);
}

LoadItems(subdir[], callback[])
{
	new
		path[64],
		dir:direc,
		item[46],
		type,
		ret,
		count;

	format(path, sizeof(path), DIRECTORY_SCRIPTFILES"%s", subdir);

	direc = dir_open(path);

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			if(strlen(item) != 14)
			{
				err("Rogue file detected ('%s') in directory %s", item, subdir);
				continue;
			}

			ret = LoadItem(subdir, item, callback);

			if(ret != INVALID_ITEM_ID)
				count++;
		}
	}

	dir_close(direc);

	log(DISCORD_CHANNEL_EVENTS, "[ITEM] Loaded %d items from `%s`", count, subdir);
}

LoadItem(subdir[], geid[], callback[])
{
	new
		filename[128],
		length,
		info[e_SAVED_ITEM_DATA];

	format(filename, sizeof(filename), "%s%s", subdir, geid);

	length = modio_read(filename, _T<I,N,F,O>, _:e_SAVED_ITEM_DATA, _:info, false, false);

	if(length < 0)
	{
		err("modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(length == 0)
	{
		err("Item %s data length is 0", filename);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	if(info[SAVED_ITEM_POS_X] == 0.0 && info[SAVED_ITEM_POS_Y] == 0.0 && info[SAVED_ITEM_POS_Z] == 0.0)
	{
		err("Item %s position is %f %f %f", filename, info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z]);
		modio_finalise_read(modio_getsession_read(filename));
		return INVALID_ITEM_ID;
	}

	new itemid = CreateItem(
		info[SAVED_ITEM_TYPE],
		info[SAVED_ITEM_POS_X],
		info[SAVED_ITEM_POS_Y],
		info[SAVED_ITEM_POS_Z],
		.rx = info[SAVED_ITEM_ROT_X],
		.ry = info[SAVED_ITEM_ROT_Y],
		.rz = info[SAVED_ITEM_ROT_Z],
		.world = info[SAVED_ITEM_WORLD],
		.interior = info[SAVED_ITEM_INTERIOR],
		.geid = geid,
		.hitpoints = info[SAVED_ITEM_HITPOINTS],
		.applyrotoffsets = 0);

	/*log("[LOAD] Item %d (%s) info: %d %d %d (%f, %f, %f, %f, %f, %f)",
		itemid, geid,
		_:info[SAVED_ITEM_TYPE], info[SAVED_ITEM_ACTIVE], info[SAVED_ITEM_HITPOINTS],
		info[SAVED_ITEM_POS_X], info[SAVED_ITEM_POS_Y], info[SAVED_ITEM_POS_Z],
		info[SAVED_ITEM_ROT_X], info[SAVED_ITEM_ROT_Y], info[SAVED_ITEM_ROT_Z]);*/
/*
	Todo: Figure out a way to block setting arraydata for certain items without
	a dumb function or lookup table of any sort
*/
	if(!IsItemTypeExtraDataDependent(GetItemType(itemid)))
	{
		dbg("item-io", 1, "[LoadItem] item is not extradata dependent");
		length = modio_read(filename, _T<A,R,R,Y>, sizeof(big_data), big_data, false, false);

		if(length > 0)
		{
			dbg("item-io", 1, "[LoadItem] loaded array data of length %d, assigning to item", length);
			SetItemArrayData(itemid, big_data, length);
		}
	}

	length = modio_read(filename, _T<D,A,T,A>, sizeof(big_data), big_data, true);

	if(length <= 0)
	{
		big_data[0] = 65;
		big_data[1] = 0;
		length = 0;
	}

	CallLocalFunction(callback, "ddsad", itemid, info[SAVED_ITEM_ACTIVE], geid, big_data, length);

	return itemid;
}
