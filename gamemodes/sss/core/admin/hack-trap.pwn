#include <YSI_Coding\y_hooks>

#define MAX_HACKTRAP	(64)


new
       Item:hak_ItemID[MAX_HACKTRAP],
   Iterator:hak_Index<MAX_HACKTRAP>;


stock CreateHackerTrap(Float:x, Float:y, Float:z, lootindex)
{
	new id = Iter_Free(hak_Index);

	if(id == ITER_NONE)
		return -1;

	hak_ItemID[id] = CreateLootItem(lootindex, x, y, z);

	Iter_Add(hak_Index, _:id);

	return id;
}


hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	foreach(new i : hak_Index)
		if(itemid == hak_ItemID[i])
		{
			TheTrapHasSprung(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


stock TheTrapHasSprung(playerid)
{
	new
		playerName[MAX_PLAYER_NAME],
		Float:x, Float:y, Float:z;

	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
	GetPlayerPos(playerid, x, y, z);

	ReportPlayer(playerName, "Picked up a hack-trap", -1, REPORT_TYPE_HACKTRAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
	BanPlayer(playerid, "Se fodeu mesmo. Nem vale a pena tentar mais.", -1, 0);
}
