#define MAX_HACKTRAP	(64)


new
			hak_ItemID[MAX_HACKTRAP],
   Iterator:hak_Index<MAX_HACKTRAP>;


stock CreateHackerTrap(Float:x, Float:y, Float:z, lootindex)
{
	new id = Iter_Free(hak_Index);

	if(id == ITER_NONE)
		return INVALID_ITEM_ID;

	hak_ItemID[id] = CreateLootItem(lootindex, x, y, z);

	Iter_Add(hak_Index, id);

	return id;
}


hook OnPlayerPickUpItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerPickUpItem] in /gamemodes/sss/core/admin/hack-trap.pwn");

	foreach(new i : hak_Index)
	{
		if(itemid == hak_ItemID[i])
		{
			TheTrapHasSprung(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


TheTrapHasSprung(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		Float:x,
		Float:y,
		Float:z;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerPos(playerid, x, y, z);

	ReportPlayer(name, "Picked up a hack-trap", -1, REPORT_TYPE_HACKTRAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
	BanPlayer(playerid, "Sprung the hacker trap by picking up an unreachable item!", -1, 0);
}
