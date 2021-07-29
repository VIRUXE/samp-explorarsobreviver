
#include <YSI_Coding\y_hooks>

static
bool:		ToolTips[MAX_PLAYERS] = {bool:true, ...},
PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
Timer:		ToolTipTimer[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	ToolTipText[playerid] = CreatePlayerTextDraw(playerid,		   500.000000, 122.000000, "text");
	PlayerTextDrawLetterSize	 (playerid, ToolTipText[playerid], 0.404165, 1.049998);
	PlayerTextDrawTextSize		 (playerid, ToolTipText[playerid], 635.000000, -158.000000);
	PlayerTextDrawSetOutline	 (playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetShadow		 (playerid, ToolTipText[playerid], 1);
	PlayerTextDrawAlignment		 (playerid, ToolTipText[playerid], 1);
	PlayerTextDrawColor			 (playerid, ToolTipText[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, ToolTipText[playerid], 255);
	PlayerTextDrawBoxColor		 (playerid, ToolTipText[playerid], 50);
	PlayerTextDrawUseBox		 (playerid, ToolTipText[playerid], 1);
}

/*==============================================================================

	Show

==============================================================================*/

ShowHelpTip(playerid, const text[], time = 0)
{
	if(!ToolTips[playerid])
		return 0;

	if(strlen(text) < 3)
		return 0;

	if(IsValidItem(GetPlayerTweakItem(playerid)))
		return 0;
		
	new str[270];
	format(str, sizeof(str),  "~r~!~w~ %s~n~~y~(/dicas para desativar)", text);

	PlayerTextDrawSetString(playerid, ToolTipText[playerid], str);
	PlayerTextDrawShow(playerid, ToolTipText[playerid]);

	stop ToolTipTimer[playerid];

	if(time > 0)
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, time);

	return 1;
}

hook OnPlayerPickedUpItem(playerid, Item:itemid)
{
	if(ToolTips[playerid])
	{
		new ItemType:itype = GetItemType(itemid);
		
		if(IsItemTypeDefence(itype))
			ShowHelpTip(playerid, ls(playerid, "DEFENCE_T"), 20000);

		else if(IsItemTypeSafebox(itype))
			ShowHelpTip(playerid, ls(playerid, "SAFEBOX_T"), 20000);

		else if(IsItemTypeBag(itype))
			ShowHelpTip(playerid, ls(playerid, "BAG_T"), 20000);

		else if(GetHatFromItem(itype) != -1)
			ShowHelpTip(playerid, ls(playerid, "HAT_T"), 20000);

		else if(GetMaskFromItem(itype) != -1)
			ShowHelpTip(playerid, ls(playerid, "MASK_T"), 20000);

		if(GetItemTypeLiquidContainerType(itype) != -1)
			ShowHelpTip(playerid, ls(playerid, "LIQUID_T"), 20000);

		else if(GetItemTypeWeaponBaseWeapon(itype))
			ShowHelpTip(playerid, ls(playerid, "WEAPON_T"), 20000);

		else if(IsValidHolsterItem(itype))
			ShowHelpTip(playerid, ls(playerid, "HOLSTER_T"), 20000);
			
		else if(GetItemTypeAmmoType(itype) != -1)
			ShowHelpTip(playerid, ls(playerid, "AMMO_T"), 20000);

		else if(IsItemTypeFood(itype))
			ShowHelpTip(playerid, ls(playerid, "FOOD_T"), 20000);

		else {
			new	itemname[MAX_ITEM_NAME],
				itemtipkey[MAX_LANGUAGE_KEY_LEN];

			GetItemTypeUniqueName(itype, itemname);
			
			if(strlen(itemname) > MAX_LANGUAGE_KEY_LEN - 3)
				itemname[MAX_LANGUAGE_KEY_LEN - 3] = EOS;

			format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
			itemtipkey[MAX_LANGUAGE_KEY_LEN - 1] = EOS;

			ShowHelpTip(playerid, ls(playerid, itemtipkey), 20000);
		}
	}
}

/*==============================================================================

	Hide

==============================================================================*/

timer HideHelpTip_Delay[time](playerid, time)
{
	HideHelpTip(playerid);
	#pragma unused time
}

HideHelpTip(playerid)
{
	stop ToolTipTimer[playerid];
	PlayerTextDrawHide(playerid, ToolTipText[playerid]);
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
	if(ToolTips[playerid])
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, 100);

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
	if(ToolTips[playerid])
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, 100);

hook OnPlayerOpenInventory(playerid)
	if(ToolTips[playerid])
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, 100);

hook OnPlayerOpenedContainer(playerid, Container:containerid)
	if(ToolTips[playerid])
		ToolTipTimer[playerid] = defer HideHelpTip_Delay(playerid, 100);


/*==============================================================================

	Functions

==============================================================================*/


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

	HideHelpTip(playerid);

	return 1;
}
