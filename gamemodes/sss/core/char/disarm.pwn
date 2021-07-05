
#include <YSI_Coding\y_hooks>

new Timer:DisarmDelay[MAX_PLAYERS];

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)))
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerNextToPlayer(playerid, i))
			{
				if(IsPlayerKnockedOut(i) || GetPlayerAnimationIndex(i) == 1381)
				{
					stop DisarmDelay[playerid];
					DisarmDelay[playerid] = defer DisarmPlayer(playerid, i);
					break;
				}
			}
		}
	}

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
	stop DisarmDelay[playerid];

timer DisarmPlayer[1000](playerid, i)
{
	if(IsValidItem(GetPlayerItem(playerid)))
		return;

	if(!IsPlayerKnockedOut(i) && GetPlayerAnimationIndex(i) != 1381)
		return;
		
	if(!IsPlayerConnected(i))
		return;

	new Item:itemid = GetPlayerItem(i);

	if(IsValidItem(itemid))
	{
		RemoveCurrentItem(i);
		GiveWorldItemToPlayer(playerid, itemid);

		return;
	}

	itemid = GetPlayerHolsterItem(i);

	if(IsValidItem(itemid))
	{
		RemovePlayerHolsterItem(i);
		CreateItemInWorld(itemid);
		GiveWorldItemToPlayer(playerid, itemid);

		return;
	}

	return;
}
