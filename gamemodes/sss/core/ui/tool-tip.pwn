
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
	format(str, sizeof(str),  "~r~!~w~ %s~n~~y~(/dicas para desativar)", text);

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
	ToolTipText[playerid] = CreatePlayerTextDraw(playerid, 500.000000, 122.000000, "As Setas indicam a 'Frente', ou seja, o lado 'vulneravel' da Defesa~n~Afaste da frente, para a conseguir mover~n~Segure para mos");
	PlayerTextDrawFont(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawLetterSize(playerid, ToolTipText[playerid], 0.312499, 1.199999);
	PlayerTextDrawTextSize(playerid, ToolTipText[playerid], 635.000000, -158.000000);
	PlayerTextDrawSetOutline(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetShadow(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawAlignment(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawColor(playerid, ToolTipText[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, ToolTipText[playerid], 255);
	PlayerTextDrawBoxColor(playerid, ToolTipText[playerid], 50);
	PlayerTextDrawUseBox(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetProportional(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, ToolTipText[playerid], 0);
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
	{
		defer tHideHelpTip(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer tHideHelpTip[100](playerid)
	if(IsPlayerConnected(playerid))
		HideHelpTip(playerid);

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(ToolTips[playerid])
		HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenedContainer(playerid, containerid)
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
