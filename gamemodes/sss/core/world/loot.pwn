
#include <YSI_Coding\y_hooks>


#define MAX_LOOT_INDEX			(15)
#define MAX_LOOT_INDEX_ITEMS	(256)
#define MAX_LOOT_INDEX_NAME		(32)
#define MAX_LOOT_SPAWN			(12683)
#define MAX_ITEMS_PER_SPAWN	 	(6)


enum E_LOOT_INDEX_ITEM_DATA
{
ItemType:	lootitem_type,
Float:		lootitem_weight,
			lootitem_limit
}

enum E_LOOT_SPAWN_DATA
{
Float:		loot_posX,
Float:		loot_posY,
Float:		loot_posZ,
			loot_world,
			loot_interior,
Float:		loot_weight,
			loot_size,
			loot_index,
Item:		loot_items[MAX_ITEMS_PER_SPAWN],
			loot_total
}


static
			loot_IndexTotal,
			loot_IndexSize[MAX_LOOT_INDEX],
			loot_IndexItems[MAX_LOOT_INDEX][MAX_LOOT_INDEX_ITEMS][E_LOOT_INDEX_ITEM_DATA],
			loot_IndexName[MAX_LOOT_INDEX][MAX_LOOT_INDEX_NAME],

			loot_SpawnData[MAX_LOOT_SPAWN][E_LOOT_SPAWN_DATA],
			loot_SpawnTotal,

			loot_ItemTypeLimit[MAX_ITEM_TYPE],
			loot_ItemLootIndex[MAX_ITEM] = {-1, ...},

Float:		loot_SpawnMult = 1.0;


hook OnScriptInit()
{
	GetSettingFloat("server/loot-spawn-multiplier", 1.0, loot_SpawnMult);
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineLootIndex(name[MAX_LOOT_INDEX_NAME])
{
	if(loot_IndexTotal >= MAX_LOOT_INDEX)
		err(false, false, "Loot index limit reached at '%s'.", name);

	loot_IndexName[loot_IndexTotal] = name;

	return loot_IndexTotal++;
}

stock AddItemToLootIndex(index, ItemType:itemtype, Float:weight, perspawnlimit = 3, serverspawnlimit = 0)
{
	if(index > loot_IndexTotal)
		return 0;

	if(loot_IndexSize[index] >= MAX_LOOT_INDEX_ITEMS)
		err(false, false, "Loot index item limit reached.");

	loot_IndexItems[index][loot_IndexSize[index]][lootitem_type] = itemtype;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_weight] = weight;
	loot_IndexItems[index][loot_IndexSize[index]][lootitem_limit] = perspawnlimit;
	
	loot_ItemTypeLimit[itemtype] = serverspawnlimit;

	loot_IndexSize[index] += 1;

	return 1;
}

stock CreateStaticLootSpawn(Float:x, Float:y, Float:z, lootindex, Float:weight, size = -1, worldid = 0, interiorid = 0)
{
	if(loot_SpawnTotal >= MAX_LOOT_SPAWN - 1)
	{
		err(false, false, "Loot spawn limit reached.");
		return -1;
	}

	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err(false, false, "Loot index (%d) is invalid.", lootindex);
		return -1;
	}

	if(size > MAX_ITEMS_PER_SPAWN)
		size = -1;

	if(size == -1)
		size = MAX_ITEMS_PER_SPAWN / 2 + random(MAX_ITEMS_PER_SPAWN / 2);

	new lootspawnid = loot_SpawnTotal;

	loot_SpawnData[lootspawnid][loot_posX] = x;
	loot_SpawnData[lootspawnid][loot_posY] = y;
	loot_SpawnData[lootspawnid][loot_posZ] = z + 0.1;
	loot_SpawnData[lootspawnid][loot_world] = worldid;
	loot_SpawnData[lootspawnid][loot_interior] = interiorid;
	loot_SpawnData[lootspawnid][loot_weight] = weight;
	loot_SpawnData[lootspawnid][loot_size] = size;
	loot_SpawnData[lootspawnid][loot_index] = lootindex;

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		ItemType:itemtype,
		Item:itemid,
		Float:rot = frandom(360.0);

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);

	if(samplelistsize == 0)
		return -1;

	// log(false, "[CreateStaticLootSpawn] index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));

	for(new i; i < size; i++)
	{
		if(loot_SpawnMult < 1.0 && (frandom(100.0) > weight * loot_SpawnMult))
			continue;
			
		// Generate an item from the sample list
		if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
			continue;

		if(itemtype == item_NULL)
		{
			err(false, false, "Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
			continue;
		}

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
			continue;

		// Create the item
		itemid = GetNextItemID();

		if(!(Item:0 <= itemid < MAX_ITEM))
		{
			err(false, false, "Item limit reached while generating loot.");
			return -1;
		}

		loot_ItemLootIndex[itemid] = lootindex;

		x = (x + (frandom(1.0) * floatsin(((360 / size) * i) + rot, degrees)));
		y = (y + (frandom(1.0) * floatcos(((360 / size) * i) + rot, degrees)));

		CreateItem(itemtype, x, y, z + 0.1, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

		loot_SpawnData[lootspawnid][loot_items][loot_SpawnData[lootspawnid][loot_total]] = itemid;
		loot_SpawnData[lootspawnid][loot_total]++;

		if(frandom(100.0) > weight * loot_SpawnMult)
			DestroyItem(itemid);
	}

	return loot_SpawnTotal++;
}

stock Item:CreateLootItem(lootindex, Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, worldid = 0, interiorid = 0)
{
	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err(false, false, "Loot index (%d) is invalid.", lootindex);
		return INVALID_ITEM_ID;
	}

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		ItemType:itemtype;

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);

	if(samplelistsize == 0)
		return INVALID_ITEM_ID;

	// Generate an item from the sample list
	if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
		return INVALID_ITEM_ID;

	if(itemtype == item_NULL)
	{
		err(false, false, "Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
		return INVALID_ITEM_ID;
	}

	if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) > loot_ItemTypeLimit[itemtype])
		return INVALID_ITEM_ID;

	new Item:itemid = GetNextItemID();

	if(!(Item:0 <= itemid < MAX_ITEM))
		return INVALID_ITEM_ID;

	loot_ItemLootIndex[itemid] = lootindex;

	CreateItem(itemtype, x, y, z, .rz = frandom(360.0), .world = worldid, .interior = interiorid);

	return itemid;
}

stock FillContainerWithLoot(Container:containerid, slots, lootindex)
{
	if(!(0 <= lootindex < loot_IndexTotal))
	{
		err(false, false, "Loot index (%d) is invalid.", lootindex);
		return -1;
	}

	new containersize;
	GetContainerSize(containerid, containersize);

	if(slots > containersize)
		slots = containersize;

	else if(slots <= 0)
		return 0;

	new
		ItemType:samplelist[MAX_LOOT_INDEX_ITEMS],
		samplelistsize,
		items,
		Item:itemid,
		ItemType:itemtype,
		freeslots;

	samplelistsize = _loot_GenerateSampleList(samplelist, lootindex);
	GetContainerFreeSlots(containerid, freeslots);

	if(samplelistsize == 0)
		return 0;

	while(items < slots && samplelistsize > 0 && freeslots > 0)
	{
		// Generate an item from the sample list
		if(!_loot_PickFromSampleList(samplelist, samplelistsize, itemtype))
			continue;

		if(itemtype == item_NULL)
		{
			err(false, false, "Chosen cell contained itemtype 0, index %d size %d: %s", lootindex, samplelistsize, atosr(_:samplelist, samplelistsize));
			continue;
		}

		// Check if the generated item is legal
		if(loot_ItemTypeLimit[itemtype] > 0 && GetItemTypeCount(itemtype) >= loot_ItemTypeLimit[itemtype])
		{
			continue;
		}

		// Create the item
		itemid = GetNextItemID();

		if(!(Item:0 <= itemid < MAX_ITEM))
		{
			err(false, false, "Item limit reached while generating loot.");
			return -1;
		}

		loot_ItemLootIndex[itemid] = lootindex;

		itemid = AllocNextItemID(itemtype);
		AddItemToContainer(containerid, itemid);
		CreateItem_ExplicitID(itemid);

		items++;
	}

	return 1;
}


/*==============================================================================

	Automatic item respawn

==============================================================================*/


new Timer:item_AutoDestroy[MAX_ITEM];

hook OnItemCreateInWorld(Item:itemid) {	
	stop item_AutoDestroy[itemid];
	item_AutoDestroy[itemid] = defer DestroyUntilItem(_:itemid);

	if(loot_ItemLootIndex[itemid] != -1 && gServerInitialising) {
		new 
			Float:x, Float:y, Float:z,
			world, interior;

		GetItemPos(itemid, x, y, z);
		GetItemWorld(itemid, world);
		GetItemInterior(itemid, interior);

		defer RespawnItem(loot_ItemLootIndex[itemid], x, y, z, world, interior);
	}
}

timer DestroyUntilItem[ITEM_RESPAWN_DELAY + random(MIN(Iter_Count(Player) + floatround(loot_SpawnMult, floatround_ceil)))](itemid)
	DestroyItem(Item:itemid);

timer RespawnItem[ITEM_RESPAWN_DELAY - random(MIN(GetPlayerPoolSize() + floatround(loot_SpawnMult, floatround_ceil)))](lootindex, Float:x, Float:y, Float:z, world, interior)
	CreateLootItem(lootindex, x, y, z, world, interior);

hook OnItemRemoveFromWorld(Item:itemid) {
	loot_ItemLootIndex[itemid] = -1;
	stop item_AutoDestroy[itemid];
}

hook OnItemDestroyed(Item:itemid)
	stop item_AutoDestroy[itemid];

hook OnPlayerConstructed(playerid, consset, Item:result)
	stop item_AutoDestroy[result];

hook OnItemSave(Item:itemid)
	stop item_AutoDestroy[itemid];


/*==============================================================================

	Internal

==============================================================================*/


_loot_GenerateSampleList(ItemType:list[MAX_LOOT_INDEX_ITEMS], lootindex)
{
	new size;

	for(new i; i < loot_IndexSize[lootindex]; ++i)
	{
		if(frandom(100.0) > loot_IndexItems[lootindex][i][lootitem_weight])
			continue;

		if(loot_IndexItems[lootindex][i][lootitem_type] == item_NULL)
		{
			// log(false, "[_loot_GenerateSampleList] Prevented entering NULL ITEM into samplelist");
			continue;
		}

		list[size++] = loot_IndexItems[lootindex][i][lootitem_type];
	}

	// log(false, "[_loot_GenerateSampleList] Generated: %s", atosr(_:list, size));

	return size;
}

_loot_PickFromSampleList(ItemType:list[MAX_LOOT_INDEX_ITEMS], &listsize, &ItemType:itemtype)
{
	if(listsize <= 0)
		return -1;

	new cell = random(listsize);
	itemtype = list[cell];

	for(new i = cell; i < listsize - 1; i++)
		list[i] = list[i+1];

	listsize -= 1;

	return 1;
}

hook OnItemDestroy(Item:itemid)
{
	loot_ItemLootIndex[itemid] = -1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Interface

==============================================================================*/

stock GetLootIndexTotal()
{
	return loot_IndexTotal;
}

stock IsValidLootIndex(index)
{
	return (0 <= index < loot_IndexTotal);
}

stock GetItemLootIndex(Item:itemid)
{
	if(!IsValidItem(itemid))
		return -1;

	return loot_ItemLootIndex[itemid];
}

stock SetItemLootIndex(Item:itemid, index) {
	if(!(0 <= index < loot_IndexTotal))
		return -1;

	loot_ItemLootIndex[itemid] = index;
	return 1;
}

// loot_posX
// loot_posY
// loot_posZ
stock GetLootSpawnPos(lootspawn, &Float:x, &Float:y, &Float:z)
{
	x = loot_SpawnData[lootspawn][loot_posX];
	y = loot_SpawnData[lootspawn][loot_posY];
	z = loot_SpawnData[lootspawn][loot_posZ];

	return 1;
}

// loot_world
stock GetLootSpawnWorld(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_world];
}

// loot_interior
stock GetLootSpawnInterior(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_interior];
}

// loot_weight
stock GetLootSpawnWeight(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_weight];
}

// loot_size
stock GetLootSpawnSize(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_size];
}

// loot_index
stock GetLootSpawnIndex(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_index];
}

// loot_items
stock GetLootSpawnItems(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_items];
}

// loot_total
stock GetLootSpawnTotalItems(lootspawn)
{
	return loot_SpawnData[lootspawn][loot_total];
}

stock GetLootIndexFromName(const name[])
{
	for(new i; i < loot_IndexTotal; i++)
	{
		if(!strcmp(name, loot_IndexName[i], true))
			return i;
	}

	err(false, false, "specified index name is invalid ('%s')", name);
	PrintAmxBacktrace();

	return -1;
}
