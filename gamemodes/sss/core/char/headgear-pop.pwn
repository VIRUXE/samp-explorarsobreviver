
#include <YSI_Coding\y_hooks>


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(bodypart == BODY_PART_HEAD)
	{
		if(IsValidItem(GetPlayerHatItem(playerid)))
			PopHat(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid)))
			PopMask(playerid);
	}

	return 1;
}

PopHat(playerid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		objectid,
		model;

	itemid = RemovePlayerHatItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeRotation(itemtype, rx, ry, rz);
	GetItemTypeModel(itemtype, model);
	GetPlayerPos(playerid, x, y, z);

	objectid = CreateDynamicObject(model, x + 0.3, y, z + 0.8, rx, ry, rz);
	MoveDynamicObject(objectid, x + 0.3, y, z - ITEM_FLOOR_OFFSET, 1.0, rx, ry, rz);
	defer pop_DropHat(objectid, _:itemid, x + 0.3, y, z);
}

PopMask(playerid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		objectid,
		model;

	itemid = RemovePlayerMaskItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	GetItemTypeRotation(itemtype, rx, ry, rz);

	GetPlayerPos(playerid, x, y, z);

	objectid = CreateDynamicObject(model, x, y - 0.3, z + 0.8, rx, ry, rz);
	MoveDynamicObject(objectid, x, y - 0.3, z - ITEM_FLOOR_OFFSET, 1.0, rx, ry, rz);
	defer pop_DropMask(objectid, _:itemid, x, y - 0.3, z);
}


timer pop_DropHat[1200](o, it, Float:x, Float:y, Float:z)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(Item:it, x, y, z - ITEM_FLOOR_OFFSET, 0.0, 0.0, 0.0);
}

timer pop_DropMask[1200](o, it, Float:x, Float:y, Float:z)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(Item:it, x, y, z - ITEM_FLOOR_OFFSET, 0.0, 0.0, 0.0);
}

CMD:pophat(playerid, params[])
{
	PopHat(playerid);
	return 1;
}

CMD:popmask(playerid, params[])
{
	PopMask(playerid);
	return 1;
}
