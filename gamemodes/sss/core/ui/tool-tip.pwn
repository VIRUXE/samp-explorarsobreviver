/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


static
bool:		ToolTips[MAX_PLAYERS] = {bool:true, ...},
PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

ShowHelpTip(playerid, const text[], time = 0)
{
	if(!ToolTips[playerid])
		return 0;

	if(strlen(text) < 3)
		return 0;
		
	new str[270];
	format(str, sizeof(str),  "~r~!~w~ %s~n~~y~(/tools to disable)", text);

	PlayerTextDrawSetString(playerid, ToolTipText[playerid], str);
	PlayerTextDrawShow(playerid, ToolTipText[playerid]);

	if(time > 0)
		defer HideHelpTip_Delay(playerid, time);

	return 1;
}

timer HideHelpTip_Delay[time](playerid, time)
{
	HideHelpTip(playerid);
	#pragma unused time
}

HideHelpTip(playerid)
{
	PlayerTextDrawHide(playerid, ToolTipText[playerid]);
}

hook OnPlayerConnect(playerid)
{
	ToolTipText[playerid] = CreatePlayerTextDraw(playerid, 3.0, 185.0, "Tip: You can access the trunks of cars by pressing F at the back");
	PlayerTextDrawLetterSize(playerid, ToolTipText[playerid], 0.25, 1.05);
	PlayerTextDrawTextSize(playerid, ToolTipText[playerid], 145.0, 35.0);
	PlayerTextDrawAlignment(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawColor(playerid, ToolTipText[playerid], -1);
	PlayerTextDrawUseBox(playerid, ToolTipText[playerid], true);
	PlayerTextDrawBoxColor(playerid, ToolTipText[playerid], 100);
	PlayerTextDrawSetShadow(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetOutline(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, ToolTipText[playerid], 255);
	PlayerTextDrawFont(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetProportional(playerid, ToolTipText[playerid], 1);
}

hook OnPlayerPickedUpItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
	{
		new
			itemname[MAX_ITEM_NAME],
			itemtipkey[12];

		GetItemTypeUniqueName(GetItemType(itemid), itemname);

		if(strlen(itemname) > 9)
			itemname[9] = EOS;

		format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
		itemtipkey[11] = EOS;

		ShowHelpTip(playerid, ls(playerid, itemtipkey), 20000);
	}
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerToolTipsOn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ToolTips[playerid];
}

stock SetPlayerToolTips(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ToolTips[playerid] = st;

	return 1;
}
