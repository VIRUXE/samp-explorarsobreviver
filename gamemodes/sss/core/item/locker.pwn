
#include <YSI_Coding\y_hooks>

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	new Item:itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
			return Y_HOOKS_BREAK_RETURN_1;
			
		new objectid;
		GetItemObjectID(itemid, objectid);
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID, 11730);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	new Item:itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		new objectid;
		GetItemObjectID(itemid, objectid);
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, objectid, E_STREAMER_MODEL_ID, 11729);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Locker)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
