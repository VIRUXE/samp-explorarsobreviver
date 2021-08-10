
#include <YSI_Coding\y_hooks>

new
	Text:GearSlot_Head[2],
	Text:GearSlot_Hand[2],
	Text:GearSlot_Tors[2],

	Text:GearSlot_Face[2],
	Text:GearSlot_Hols[2],
	Text:GearSlot_Back[2],

	Container:inv_TempContainerID[MAX_PLAYERS],
	inv_InventoryOptionID[MAX_PLAYERS];

hook OnGameModeInit()
{
	/*
		Head
	*/

	GearSlot_Head[0] = TextDrawCreate(512.000000, 183.000000, "Cabeca~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Head[0], 2);
	TextDrawLetterSize(GearSlot_Head[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Head[0], 568.500000, 50.000000);
	TextDrawSetOutline(GearSlot_Head[0], 1);
	TextDrawSetShadow(GearSlot_Head[0], 0);
	TextDrawAlignment(GearSlot_Head[0], 1);
	TextDrawColor(GearSlot_Head[0], -1);
	TextDrawBackgroundColor(GearSlot_Head[0], 255);
	TextDrawBoxColor(GearSlot_Head[0], 164);
	TextDrawUseBox(GearSlot_Head[0], 1);
	TextDrawSetProportional(GearSlot_Head[0], 1);
	TextDrawSetSelectable(GearSlot_Head[0], 1);

	GearSlot_Head[1] = TextDrawCreate(508.000000, 190.000000, "Preview_Model");
	TextDrawFont(GearSlot_Head[1], 5);
	TextDrawLetterSize(GearSlot_Head[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Head[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Head[1], 0);
	TextDrawSetShadow(GearSlot_Head[1], 0);
	TextDrawAlignment(GearSlot_Head[1], 1);
	TextDrawColor(GearSlot_Head[1], -1);
	TextDrawBackgroundColor(GearSlot_Head[1], 0);
	TextDrawBoxColor(GearSlot_Head[1], 255);
	TextDrawUseBox(GearSlot_Head[1], 0);
	TextDrawSetProportional(GearSlot_Head[1], 1);
	TextDrawSetSelectable(GearSlot_Head[1], 0);
	TextDrawSetPreviewModel(GearSlot_Head[1], 0);
	TextDrawSetPreviewRot(GearSlot_Head[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Head[1], 1, 1);

	/*
		Hand
	*/

	GearSlot_Hand[0] = TextDrawCreate(512.000000, 253.000000, "Mao~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Hand[0], 2);
	TextDrawLetterSize(GearSlot_Hand[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Hand[0], 568.500000, 50.000000);
	TextDrawSetOutline(GearSlot_Hand[0], 1);
	TextDrawSetShadow(GearSlot_Hand[0], 0);
	TextDrawAlignment(GearSlot_Hand[0], 1);
	TextDrawColor(GearSlot_Hand[0], -1);
	TextDrawBackgroundColor(GearSlot_Hand[0], 255);
	TextDrawBoxColor(GearSlot_Hand[0], 164);
	TextDrawUseBox(GearSlot_Hand[0], 1);
	TextDrawSetProportional(GearSlot_Hand[0], 1);
	TextDrawSetSelectable(GearSlot_Hand[0], 1);

	GearSlot_Hand[1] = TextDrawCreate(508.000000, 259.000000, "Preview_Model");
	TextDrawFont(GearSlot_Hand[1], 5);
	TextDrawLetterSize(GearSlot_Hand[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Hand[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Hand[1], 0);
	TextDrawSetShadow(GearSlot_Hand[1], 0);
	TextDrawAlignment(GearSlot_Hand[1], 1);
	TextDrawColor(GearSlot_Hand[1], -1);
	TextDrawBackgroundColor(GearSlot_Hand[1], 0);
	TextDrawBoxColor(GearSlot_Hand[1], 255);
	TextDrawUseBox(GearSlot_Hand[1], 0);
	TextDrawSetProportional(GearSlot_Hand[1], 1);
	TextDrawSetSelectable(GearSlot_Hand[1], 0);
	TextDrawSetPreviewModel(GearSlot_Hand[1], 0);
	TextDrawSetPreviewRot(GearSlot_Hand[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Hand[1], 1, 1);

	/*
		Torso
	*/
	
	GearSlot_Tors[0] = TextDrawCreate(512.000000, 323.000000, "Colete~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Tors[0], 2);
	TextDrawLetterSize(GearSlot_Tors[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Tors[0], 568.500000, 50.000000);
	TextDrawSetOutline(GearSlot_Tors[0], 1);
	TextDrawSetShadow(GearSlot_Tors[0], 0);
	TextDrawAlignment(GearSlot_Tors[0], 1);
	TextDrawColor(GearSlot_Tors[0], -1);
	TextDrawBackgroundColor(GearSlot_Tors[0], 255);
	TextDrawBoxColor(GearSlot_Tors[0], 164);
	TextDrawUseBox(GearSlot_Tors[0], 1);
	TextDrawSetProportional(GearSlot_Tors[0], 1);
	TextDrawSetSelectable(GearSlot_Tors[0], 1);

	GearSlot_Tors[1] = TextDrawCreate(508.000000, 330.000000, "Preview_Model");
	TextDrawFont(GearSlot_Tors[1], 5);
	TextDrawLetterSize(GearSlot_Tors[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Tors[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Tors[1], 0);
	TextDrawSetShadow(GearSlot_Tors[1], 0);
	TextDrawAlignment(GearSlot_Tors[1], 1);
	TextDrawColor(GearSlot_Tors[1], -1);
	TextDrawBackgroundColor(GearSlot_Tors[1], 0);
	TextDrawBoxColor(GearSlot_Tors[1], 255);
	TextDrawUseBox(GearSlot_Tors[1], 0);
	TextDrawSetProportional(GearSlot_Tors[1], 1);
	TextDrawSetSelectable(GearSlot_Tors[1], 0);
	TextDrawSetPreviewModel(GearSlot_Tors[1], 0);
	TextDrawSetPreviewRot(GearSlot_Tors[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Tors[1], 1, 1);

	/*
		Face
	*/

	GearSlot_Face[0] = TextDrawCreate(578.000000, 183.000000, "Rosto~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Face[0], 2);
	TextDrawLetterSize(GearSlot_Face[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Face[0], 635.000000, 50.000000);
	TextDrawSetOutline(GearSlot_Face[0], 1);
	TextDrawSetShadow(GearSlot_Face[0], 0);
	TextDrawAlignment(GearSlot_Face[0], 1);
	TextDrawColor(GearSlot_Face[0], -1);
	TextDrawBackgroundColor(GearSlot_Face[0], 255);
	TextDrawBoxColor(GearSlot_Face[0], 164);
	TextDrawUseBox(GearSlot_Face[0], 1);
	TextDrawSetProportional(GearSlot_Face[0], 1);
	TextDrawSetSelectable(GearSlot_Face[0], 1);

	GearSlot_Face[1] = TextDrawCreate(575.000000, 190.000000, "Preview_Model");
	TextDrawFont(GearSlot_Face[1], 5);
	TextDrawLetterSize(GearSlot_Face[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Face[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Face[1], 0);
	TextDrawSetShadow(GearSlot_Face[1], 0);
	TextDrawAlignment(GearSlot_Face[1], 1);
	TextDrawColor(GearSlot_Face[1], -1);
	TextDrawBackgroundColor(GearSlot_Face[1], 0);
	TextDrawBoxColor(GearSlot_Face[1], 255);
	TextDrawUseBox(GearSlot_Face[1], 0);
	TextDrawSetProportional(GearSlot_Face[1], 1);
	TextDrawSetSelectable(GearSlot_Face[1], 0);
	TextDrawSetPreviewModel(GearSlot_Face[1], 0);
	TextDrawSetPreviewRot(GearSlot_Face[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Face[1], 1, 1);

	/*
		Hols
	*/

	GearSlot_Hols[0] = TextDrawCreate(578.000000, 253.000000, "Coldre~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Hols[0], 2);
	TextDrawLetterSize(GearSlot_Hols[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Hols[0], 635.000000, 50.000000);
	TextDrawSetOutline(GearSlot_Hols[0], 1);
	TextDrawSetShadow(GearSlot_Hols[0], 0);
	TextDrawAlignment(GearSlot_Hols[0], 1);
	TextDrawColor(GearSlot_Hols[0], -1);
	TextDrawBackgroundColor(GearSlot_Hols[0], 255);
	TextDrawBoxColor(GearSlot_Hols[0], 164);
	TextDrawUseBox(GearSlot_Hols[0], 1);
	TextDrawSetProportional(GearSlot_Hols[0], 1);
	TextDrawSetSelectable(GearSlot_Hols[0], 1);

	GearSlot_Hols[1] = TextDrawCreate(575.000000, 259.000000, "Preview_Model");
	TextDrawFont(GearSlot_Hols[1], 5);
	TextDrawLetterSize(GearSlot_Hols[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Hols[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Hols[1], 0);
	TextDrawSetShadow(GearSlot_Hols[1], 0);
	TextDrawAlignment(GearSlot_Hols[1], 1);
	TextDrawColor(GearSlot_Hols[1], -1);
	TextDrawBackgroundColor(GearSlot_Hols[1], 0);
	TextDrawBoxColor(GearSlot_Hols[1], 255);
	TextDrawUseBox(GearSlot_Hols[1], 0);
	TextDrawSetProportional(GearSlot_Hols[1], 1);
	TextDrawSetSelectable(GearSlot_Hols[1], 0);
	TextDrawSetPreviewModel(GearSlot_Hols[1], 0);
	TextDrawSetPreviewRot(GearSlot_Hols[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Hols[1], 1, 1);

	/*
		Back
	*/

	GearSlot_Back[0] = TextDrawCreate(578.000000, 323.000000, "Costas~n~~n~~n~~n~~n~~n~~n~~n~");
	TextDrawFont(GearSlot_Back[0], 2);
	TextDrawLetterSize(GearSlot_Back[0], 0.220833, 0.850000);
	TextDrawTextSize(GearSlot_Back[0], 635.000000, 50.000000);
	TextDrawSetOutline(GearSlot_Back[0], 1);
	TextDrawSetShadow(GearSlot_Back[0], 0);
	TextDrawAlignment(GearSlot_Back[0], 1);
	TextDrawColor(GearSlot_Back[0], -1);
	TextDrawBackgroundColor(GearSlot_Back[0], 255);
	TextDrawBoxColor(GearSlot_Back[0], 164);
	TextDrawUseBox(GearSlot_Back[0], 1);
	TextDrawSetProportional(GearSlot_Back[0], 1);
	TextDrawSetSelectable(GearSlot_Back[0], 1);


	GearSlot_Back[1] = TextDrawCreate(575.000000, 330.000000, "Preview_Model");
	TextDrawFont(GearSlot_Back[1], 5);
	TextDrawLetterSize(GearSlot_Back[1], 0.600000, 2.000000);
	TextDrawTextSize(GearSlot_Back[1], 63.500000, 57.500000);
	TextDrawSetOutline(GearSlot_Back[1], 0);
	TextDrawSetShadow(GearSlot_Back[1], 0);
	TextDrawAlignment(GearSlot_Back[1], 1);
	TextDrawColor(GearSlot_Back[1], -1);
	TextDrawBackgroundColor(GearSlot_Back[1], 0);
	TextDrawBoxColor(GearSlot_Back[1], 255);
	TextDrawUseBox(GearSlot_Back[1], 0);
	TextDrawSetProportional(GearSlot_Back[1], 1);
	TextDrawSetSelectable(GearSlot_Back[1], 0);
	TextDrawSetPreviewModel(GearSlot_Back[1], 0);
	TextDrawSetPreviewRot(GearSlot_Back[1], -10.000000, 0.000000, -20.000000, 1.000000);
	TextDrawSetPreviewVehCol(GearSlot_Back[1], 1, 1);
}


hook OnPlayerConnect(playerid)
{
	inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	inv_InventoryOptionID[playerid] = -1;
}

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			new
				name[MAX_CONTAINER_NAME],
				str[12 + MAX_CONTAINER_NAME];

			GetContainerName(inv_TempContainerID[playerid], name);
			format(str, sizeof(str), "Mover para %s", name);

			inv_InventoryOptionID[playerid] = AddContainerOption(playerid, str);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, Container:containerid, option)
{
	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			if(option == inv_InventoryOptionID[playerid])
			{
				new
					slot,
					Item:itemid;

				GetPlayerContainerSlot(playerid, slot);
				GetContainerSlotItem(containerid, slot, itemid);

				if(!IsValidItem(itemid))
				{
					DisplayContainerInventory(playerid, containerid);
					return 0;
				}

				new required = AddItemToContainer(inv_TempContainerID[playerid], itemid, playerid);

				if(required > 0)
				{
					ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
				}
				else
				{
					DisplayContainerInventory(playerid, containerid);
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

HidePlayerGear(playerid)
{
	TextDrawHideForPlayer(playerid, GearSlot_Head[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Head[1]);

	TextDrawHideForPlayer(playerid, GearSlot_Hand[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Hand[1]);

	TextDrawHideForPlayer(playerid, GearSlot_Tors[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Tors[1]);

	TextDrawHideForPlayer(playerid, GearSlot_Face[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Face[1]);

	TextDrawHideForPlayer(playerid, GearSlot_Hols[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Hols[1]);

	TextDrawHideForPlayer(playerid, GearSlot_Back[0]);
	TextDrawHideForPlayer(playerid, GearSlot_Back[1]);
}

ShowPlayerGear(playerid)
{
	new
		Item:itemid = INVALID_ITEM_ID,
		modelid;
	
	/*
		Head
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Head[0]);

	itemid = GetPlayerHatItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Head[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Head[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Head[1]);

	/*
		Hand
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Hand[0]);

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Hand[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Hand[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Hand[1]);

	/*
		Torso
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Tors[0]);

	itemid = GetPlayerArmourItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Tors[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Tors[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Tors[1]);

	/*
		Face
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Face[0]);

	itemid = GetPlayerMaskItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Face[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Face[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Face[1]);

	/*
		Hols
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Hols[0]);

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Hols[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Hols[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Hols[1]);
	
	/*
		Back
	*/

	TextDrawShowForPlayer(playerid, GearSlot_Back[0]);

	itemid = GetPlayerBagItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeModel(GetItemType(itemid), modelid);
		TextDrawSetPreviewModel(GearSlot_Back[1], modelid);
		TextDrawShowForPlayer(playerid, GearSlot_Back[1]);
	}
	else TextDrawHideForPlayer(playerid, GearSlot_Back[1]);
}

hook OnPlayerOpenedInventory(playerid)
{
	ShowPlayerGear(playerid);
	
}

hook OnPlayerOpenedContainer(playerid, Container:containerid)
{
	ShowPlayerGear(playerid);
}

hook OnPlayerHolsterItem(playerid, Item:itemid)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid) || IsPlayerViewingInventory(playerid))
	{
		ShowPlayerGear(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid) || IsPlayerViewingInventory(playerid))
	{
		ShowPlayerGear(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUnHolsterItem(playerid, Item:itemid)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid) || IsPlayerViewingInventory(playerid))
	{
		ShowPlayerGear(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUnHolsteredItem(playerid, Item:itemid)
{
	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid) || IsPlayerViewingInventory(playerid))
	{
		ShowPlayerGear(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);
	ClosePlayerContainer(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	HidePlayerGear(playerid);
	ClosePlayerInventory(playerid, false);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == GearSlot_Head[0])
		_inv_HandleGearSlotClick_Head(playerid);

	if(clickedid == GearSlot_Hand[0])
		_inv_HandleGearSlotClick_Hand(playerid);

	if(clickedid == GearSlot_Tors[0])
		_inv_HandleGearSlotClick_Tors(playerid);

	if(clickedid == GearSlot_Face[0])
		_inv_HandleGearSlotClick_Face(playerid);

	if(clickedid == GearSlot_Hols[0])
		_inv_HandleGearSlotClick_Hols(playerid);

	if(clickedid == GearSlot_Back[0])
		_inv_HandleGearSlotClick_Back(playerid);
}

_inv_HandleGearSlotClick_Head(playerid)
{
	new Item:itemid = GetPlayerHatItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT", true), 3000);
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
			}
		}
		else
		{
			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
			else if(required == 0)
			{
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT", true), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT", true), 3000, 150);
			}
			else
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
		}
		else
		{
			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO", true), required), 3000, 150);
			else if(required == 0)
			{
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVHAT", true), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	ShowPlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Face(playerid)
{
	new Item:itemid = GetPlayerMaskItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS", true), 3000, 150);
			}
			else
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
		}
		else
		{
			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
			else if(required == 0)
			{
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS", true), 3000, 150);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS", true), 3000, 150);
			}
			else
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
		}
		else
		{
			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO", true), required), 3000, 150);
			else if(required == 0)
			{
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, ls(playerid, "INVREMOVMAS", true), 3000, 150);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	ShowPlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hand(playerid)
{
	new Item:itemid = GetPlayerItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid)))
		{
			if(containerid == GetBagItemContainerID(itemid))
				return 1;
		}

		if(IsItemTypeSafebox(GetItemType(itemid)))
		{
			if(GetContainerSafeboxItem(containerid) == itemid)
				return 1;
		}

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
			return 1;
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO", true), required), 3000, 150);
			return 1;
		}

		DisplayPlayerInventory(playerid);
	}

	ShowPlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hols(playerid)
{
	new Item:itemid = GetPlayerHolsterItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid)))
		{
			if(containerid == GetBagItemContainerID(itemid))
				return 1;
		}

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);
		else if(required == 0)
			RemovePlayerHolsterItem(playerid);

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO", true), required), 3000, 150);
		else if(required == 0)
			RemovePlayerHolsterItem(playerid);
		
		DisplayPlayerInventory(playerid);
	}

	ShowPlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Tors(playerid)
{
	if(GetPlayerAP(playerid) == 0.0)
		return 0;

	new
		Item:itemid = GetPlayerArmourItem(playerid),
		Container:containerid;

	GetPlayerCurrentContainer(playerid, containerid);

	if(IsValidContainer(containerid))
	{
		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "CNTEXTRASLO", true), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, ls(playerid, "INVREMOVARM", true), 3000);
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(ls(playerid, "INVEXTRASLO", true), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else
				ShowActionText(playerid, ls(playerid, "INVHOLDINGI", true), 3000);
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, ls(playerid, "INVREMOVARM", true), 3000);
		}

		DisplayPlayerInventory(playerid);
	}

	ShowPlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Back(playerid)
{
	new Item:itemid = GetPlayerBagItem(playerid);
	
	if(!IsValidItem(itemid))
		return 0;

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(containerid == GetBagItemContainerID(itemid))
	{
		ClosePlayerContainer(playerid);

		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			DisplayContainerInventory(playerid, inv_TempContainerID[playerid]);
		}
		else
		{
			DisplayPlayerInventory(playerid);
		}

		inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	}
	else
	{
		GetPlayerCurrentContainer(playerid, inv_TempContainerID[playerid]);

		DisplayContainerInventory(playerid, GetBagItemContainerID(itemid));
	}

	ShowPlayerGear(playerid);

	return 1;
}
