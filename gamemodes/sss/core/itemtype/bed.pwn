/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define TIME_SLEEP 30 //Segundos

static
Timer:  Bed_Sleeping[MAX_PLAYERS],
Timer:  Bed_SleepingBrightness[MAX_PLAYERS],
Item:	Bed_PlayerSleeping[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    Bed_PlayerSleeping[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDisconnect(playerid, reason)
{
    stop Bed_Sleeping[playerid];
    stop Bed_SleepingBrightness[playerid];
}

CMD:dormir(playerid, params[])
{
	if(!IsPlayerSpawned(playerid))
	    return 1;

	if(Bed_PlayerSleeping[playerid] != INVALID_ITEM_ID)
	    return 1;

	new Float:x, Float:y, Float:z;
	new Float:x2, Float:y2, Float:z2;
	GetPlayerPos(playerid, x, y, z);

    new
		Item:items[256],
		count,
		Float:rz,
		Item:Bed_ItemID;

	count = GetItemsInRange(x, y, z, 1.0, items);

	if(count == 0)
	    return 1;

	for (new o; o < count; o++)
	{
		if(GetItemType(items[o]) == item_Bed)
		    Bed_ItemID = items[o];
	}

	if(!Bed_ItemID)
	    return ChatMsg(playerid, PINK, " > N�o h� nenhuma cama por perto");

    foreach(new i : Player)
	{
	    if(Bed_PlayerSleeping[i] == Bed_ItemID && i != playerid)
	    	Bed_ItemID = INVALID_ITEM_ID;
	}

	if(!Bed_ItemID) return ChatMsg(playerid, PINK, " > Algu�m est� dormindo nesta cama.");

 	GetItemPos(Bed_ItemID, x, y, z);
 	GetItemPos(Bed_ItemID, x2, y2, z2);

    GetItemRot(Bed_ItemID, rz, rz, rz);

	SetPlayerFacingAngle(playerid, rz + 90.0);

    x += 2.45 * floatsin(-rz + 7.0, degrees);
    y += 2.30 * floatcos(-rz, degrees);

	SetPlayerPos(playerid, x, y, z + 1.0);

    stop Bed_SleepingBrightness[playerid];
    Bed_SleepingBrightness[playerid] = defer SleepingBrightness(playerid, 0);

    Bed_PlayerSleeping[playerid] = Bed_ItemID;
    //ApplyAnimation(playerid,"CRACK","crckdeth2", 10.1, 0, 1, 1, 1, 0, 1);
    stop Bed_Sleeping[playerid];
    Bed_Sleeping[playerid] = defer Stop_Sleeping(playerid, x2, y2, z2);

    StartHoldAction(playerid, TIME_SLEEP * 900);

    GetPlayerFacingAngle(playerid, rz);
    GetPlayerPos(playerid, z, z, z);

    defer CheckPlayerSlep(playerid);

    GameTextForPlayer(playerid, "_~n~Dormindo...", TIME_SLEEP * 1000, 3);
	return 1;
}

timer CheckPlayerSlep[1000](playerid)
{
	ApplyAnimation(playerid,"CRACK","crckdeth2", 10.1, 0, 1, 1, 1, 0, 1);
}

timer SleepingBrightness[300](playerid, bri)
{
    SetPlayerBrightness(playerid, bri + 6);
    if(bri < 200) Bed_SleepingBrightness[playerid] = defer SleepingBrightness(playerid, bri + 6);
}

timer Stop_Sleeping[TIME_SLEEP * 1000](playerid, Float:x, Float:y, Float:z)
{
    Bed_PlayerSleeping[playerid] = INVALID_ITEM_ID;
	ClearAnimations(playerid);
	SetPlayerPos(playerid, x, y, z + 1.0);
	SetPlayerHP(playerid, 100.0);
	ChatMsg(playerid, PINK, " > Voc� dormiu e recuperou a vida. Quando voc� morrer nascer� aqui.");
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Bed)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}

stock IsPlayerSleeping(playerid)
{
	if(Bed_PlayerSleeping[playerid] != INVALID_ITEM_ID)
	    return 1;

	return 0;
}
