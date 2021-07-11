
#include <YSI_Coding\y_hooks>

static MiniMapOverlay;

hook OnScriptInit()
	MiniMapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);

hook OnPlayerSpawn(playerid) {
	GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
}

UpdatePlayerMap(playerid){
	if(PlayerHasMap(playerid)){
		GangZoneHideForPlayer(playerid, MiniMapOverlay);
		static Float:x, Float:y, Float:z;

		if(GetLastSupplyPos(x, y, z))
			SetPlayerMapIcon(playerid, SUPPLY_CRATE_ICON, x, y, z, SUPPLY_CRATE_ICON, 0, MAPICON_GLOBAL);

		if(GetLastWeaponCachePos(x, y, z))
			SetPlayerMapIcon(playerid, WEAPON_CACHE_ICON, x, y, z, WEAPON_CACHE_ICON, 0, MAPICON_GLOBAL);

		if(GetPlayerBedPos(playerid, x, y, z))
			SetPlayerMapIcon(playerid, PLAYER_BED_ICON, x, y, z, PLAYER_BED_ICON, 0, MAPICON_GLOBAL);
			
	} else {
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
		RemovePlayerMapIcon(playerid, SUPPLY_CRATE_ICON);
		RemovePlayerMapIcon(playerid, WEAPON_CACHE_ICON);
		RemovePlayerMapIcon(playerid, PLAYER_BED_ICON);
	}
}

hook OnPlayerLoad(playerid, filename[])
	UpdatePlayerMap(playerid);

hook OnPlayerAddedToInv(playerid, Item:itemid)
	if(GetItemType(itemid) == item_Map)
		UpdatePlayerMap(playerid);

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
	if(GetItemType(itemid) == item_Map)
		UpdatePlayerMap(playerid);

hook OnItemRemoveFromCnt(Container:containerid, slotid, playerid){
	if(IsPlayerConnected(playerid) && IsValidItem(GetContainerBagItem(containerid)))
	{
		new Item:itemid;
		GetContainerSlotItem(containerid, slotid, itemid);
		if(GetItemType(itemid) == item_Map)
			UpdatePlayerMap(playerid);
	}
}

hook OnPlayerGetItem(playerid, Item:itemid)
	if(GetItemType(itemid) == item_Map)
		UpdatePlayerMap(playerid);

bool:PlayerHasMap(playerid) {
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
		if(IsValidContainer(containerid)) {
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
	}

	return false;
}