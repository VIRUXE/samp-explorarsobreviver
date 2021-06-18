/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

new MiniMapOverlay;

hook OnScriptInit(){
	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);
}

hook OnPlayerLoad(playerid, filename[])
{
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
}

hook OnPlayerSpawn(playerid) {
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	if(GetItemType(itemid) == item_Map){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	}
}
hook OnPlayerAddToInventory(playerid, Item:itemid, success) {
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
}

hook OnPlayerCloseContainer(playerid, containerid){
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
}

hook OnPlayerCloseInventory(playerid)
{
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	if(IsPlayerMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
}

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