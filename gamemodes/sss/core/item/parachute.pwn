#include <YSI\y_hooks>


new
	bool:para_TakingOff[MAX_PLAYERS];


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", LOG_CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/parachute.pwn");

	if(newkeys & KEY_YES)
	{
		new itemid = GetPlayerItem(playerid);

		if(GetItemType(itemid) == item_Parachute)
		{
			if(!IsValidItem(GetPlayerBagItem(playerid)))
			{
				_EquipParachute(playerid);
			}
		}
	}
	if(newkeys & KEY_NO)
	{
		if(GetPlayerWeapon(playerid) == 46)
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				para_TakingOff[playerid] = true;
				RemovePlayerWeapon(playerid);
				GiveWorldItemToPlayer(playerid, CreateItem(item_Parachute, 0.0, 0.0, 0.0));
			}
		}
	}
}

hook OnPlayerDropItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerDropItem] in /gamemodes/sss/core/item/parachute.pwn");

	if(GetItemType(itemid) == item_Parachute)
	{
		if(para_TakingOff[playerid])
		{
			para_TakingOff[playerid] = false;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_EquipParachute(playerid)
{
	ChatMsg(playerid, YELLOW, " >  Not implemented.");
}
