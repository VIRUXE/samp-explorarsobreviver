/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

new MiniMapOverlay;

hook OnScriptInit()
	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

hook OnPlayerSpawn(playerid) {
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	if(GetItemType(itemid) == item_Map){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	}
}

UpdatePlayerMap(playerid){
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
		new Float:x, Float:y, Float:z;
		GetLastSupplyPos(x, y, z);
		SetPlayerMapIcon(playerid, SUPPLY_CRATE_ICON, x, y, z, SUPPLY_CRATE_ICON, 0, MAPICON_GLOBAL);
		GetLastWeaponCachePos(x, y, z);
		SetPlayerMapIcon(playerid, WEAPON_CACHE_ICON, x, y, z, WEAPON_CACHE_ICON, 0, MAPICON_GLOBAL);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
		RemovePlayerMapIcon(playerid, SUPPLY_CRATE_ICON);
		RemovePlayerMapIcon(playerid, WEAPON_CACHE_ICON);
	}
}

hook OnPlayerLoad(playerid, filename[])
	UpdatePlayerMap(playerid);

hook OnPlayerAddToInventory(playerid, Item:itemid, success)
	UpdatePlayerMap(playerid);

hook OnPlayerCloseContainer(playerid, containerid)
	UpdatePlayerMap(playerid);

hook OnPlayerCloseInventory(playerid)
	UpdatePlayerMap(playerid);

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
	UpdatePlayerMap(playerid);


stock bool:IsPlayerMap(playerid) {
	new Item:itemid = GetPlayerItem(playerid);
	
	if(GetItemType(itemid) == item_Map)
		return true;

	for(new i; i < MAX_INVENTORY_SLOTS; i++){
		GetInventorySlotItem(playerid, i, itemid);

		if(!IsValidItem(itemid))
			break;

		if(GetItemType(itemid) == item_Map)
			return true;
	}

	if(IsValidItem(GetPlayerBagItem(playerid))){
		new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));
		new size;
		GetContainerSize(containerid, size);

		// 19 = MAX_BAG_CONTAINER_SIZE !!
		for(new i; i < size && i < 19; i++){
			GetContainerSlotItem(containerid, i, itemid);

			if(!IsValidItem(itemid))
				break;

			if(GetItemType(itemid) == item_Map)
				return true;
		}
	}

	return false;
}