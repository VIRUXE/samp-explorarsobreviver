/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(bodypart == BODY_PART_HEAD)
	{
		if(IsValidItem(GetPlayerHatItem(playerid))){
			PopHat(playerid);

			new ItemType:type = GetItemType(GetPlayerHatItem(playerid));

			if(type == item_HelmArmy || type == item_ArmyHelmet2 || type == item_PoliceHelm || type == item_SwatHelmet){
				ShowActionText(playerid, ls(playerid, "HELMPROTECT"), 5000);
				ShowActionText(issuerid, ls(issuerid, "HELMISSUER"), 5000);
				PlayerPlaySound(playerid, 1135, 0.0, 0.0, 0.0);
				return 0;
			}
		}

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
