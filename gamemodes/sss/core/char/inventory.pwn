
#include <YSI_Coding\y_hooks>


#define GEAR_POS_Y			(183.000000)


static
	inv_GearCount[MAX_PLAYERS],
	PlayerText:GearSlot_Head[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:GearSlot_Face[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:GearSlot_Hand[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:GearSlot_Hols[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:GearSlot_Tors[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:GearSlot_Back[MAX_PLAYERS] = { PlayerText:INVALID_TEXT_DRAW, ...},
	Container:inv_TempContainerID[MAX_PLAYERS],
	inv_InventoryOptionID[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	inv_InventoryOptionID[playerid] = -1;
	inv_GearCount[playerid] = 0;
	GearSlot_Head[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Face[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Hand[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Hols[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Tors[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Back[playerid] = PlayerText:INVALID_TEXT_DRAW;
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
	inv_GearCount[playerid] = 0;

	if(GearSlot_Head[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Head[playerid] );

	if(GearSlot_Face[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Face[playerid] );

	if(GearSlot_Hand[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Hand[playerid] );

	if(GearSlot_Hols[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Hols[playerid] );

	if(GearSlot_Tors[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Tors[playerid] );

	if(GearSlot_Back[playerid] != PlayerText:INVALID_TEXT_DRAW)
		PlayerTextDrawDestroy(playerid, GearSlot_Back[playerid] );

	GearSlot_Head[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Face[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Hand[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Hols[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Tors[playerid] = PlayerText:INVALID_TEXT_DRAW;
	GearSlot_Back[playerid] = PlayerText:INVALID_TEXT_DRAW;
}

timer UpdatePlayerGear[10](playerid)
{
	HidePlayerGear(playerid);

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(!IsValidContainer(containerid) && !IsPlayerViewingInventory(playerid))
		return 0;

	new
		tmp[5 + MAX_ITEM_NAME + MAX_ITEM_TEXT],
		Item:itemid;
	
	/*
		Hand
	*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "Mao:~w~ %s",tmp);

		GearSlot_Hand[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Hand[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Hand[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Hand[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Hand[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Hand[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Hand[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Hand[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Hand[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Hand[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Hand[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Hand[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Hand[playerid]);

		inv_GearCount[playerid] ++;
	}

	/*
		Back
	*/

	itemid = GetPlayerBagItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		
		format(tmp, sizeof(tmp), "Costas:~w~ %s", tmp);

		GearSlot_Back[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Back[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Back[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Back[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Back[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Back[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Back[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Back[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Back[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Back[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Back[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Back[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Back[playerid]);

		inv_GearCount[playerid] ++;
	}

	/*
		Hols
	*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "Coldre:~w~ %s", tmp);
		
		GearSlot_Hols[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Hols[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Hols[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Hols[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Hols[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Hols[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Hols[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Hols[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Hols[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Hols[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Hols[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Hols[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Hols[playerid]);

		inv_GearCount[playerid] ++;
	}

	/*
		Head
	*/

	itemid = GetPlayerHatItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		format(tmp, sizeof(tmp), "Cabeca:~w~ %s", tmp);

		GearSlot_Head[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Head[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Head[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Head[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Head[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Head[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Head[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Head[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Head[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Head[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Head[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Head[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Head[playerid]);

		inv_GearCount[playerid] ++;
	}

	/*
		Face
	*/

	itemid = GetPlayerMaskItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		format(tmp, sizeof(tmp), "Rosto:~w~ %s", tmp);

		GearSlot_Face[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Face[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Face[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Face[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Face[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Face[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Face[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Face[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Face[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Face[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Face[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Face[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Face[playerid]);

		inv_GearCount[playerid] ++;
	}


	/*
		Torso
	*/

	if(GetPlayerAP(playerid) > 0.0)
	{
		format(tmp, sizeof(tmp), "Colete:~w~ %0.1f", GetPlayerAP(playerid));

		GearSlot_Tors[playerid] = CreatePlayerTextDraw(playerid, 508.000000, GEAR_POS_Y + (inv_GearCount[playerid] * 38.0), tmp);
		PlayerTextDrawFont(playerid, GearSlot_Tors[playerid], 2);
		PlayerTextDrawLetterSize(playerid, GearSlot_Tors[playerid], 0.229166, 1.049999);
		PlayerTextDrawTextSize(playerid, GearSlot_Tors[playerid], 638.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, GearSlot_Tors[playerid], 1);
		PlayerTextDrawAlignment(playerid, GearSlot_Tors[playerid], 1);
		PlayerTextDrawColor(playerid, GearSlot_Tors[playerid], 0xFFFF00FF);
		PlayerTextDrawBackgroundColor(playerid, GearSlot_Tors[playerid], 255);
		PlayerTextDrawBoxColor(playerid, GearSlot_Tors[playerid], 50);
		PlayerTextDrawUseBox(playerid, GearSlot_Tors[playerid], 1);
		PlayerTextDrawSetProportional(playerid, GearSlot_Tors[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, GearSlot_Tors[playerid], 1);

		PlayerTextDrawShow(playerid, GearSlot_Tors[playerid]);

		inv_GearCount[playerid] ++;
	}

	return 1;
}


static bag_InventoryItem[MAX_PLAYERS];

hook OnPlayerOpenInventory(playerid)
{
	if(IsValidItem(GetPlayerBagItem(playerid)))
	{
		new modelid;
		GetItemTypeModel(GetItemType(GetPlayerBagItem(playerid)), modelid);
		bag_InventoryItem[playerid] = AddInventoryListItem(playerid, "Abrir Mochila >", modelid);
	}

	defer UpdatePlayerGear(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	if(item == bag_InventoryItem[playerid])
	{
		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			_inv_HandleGearSlotClick_Back(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	defer UpdatePlayerGear(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	HidePlayerGear(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
			defer UpdatePlayerGear(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromInv(playerid, Item:itemid, slot)
{
	defer UpdatePlayerGear(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, Item:itemid, slot)
{
	if(IsItemTypeCarry(GetItemType(itemid)))
		return 1;

	defer UpdatePlayerGear(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	if(inv_GearCount[playerid])
		defer UpdatePlayerGear(playerid);
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	defer UpdatePlayerGear(playerid);
}

hook OnPlayerGetItem(playerid, Item:itemid){
	defer UpdatePlayerGear(playerid);
}


hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == GearSlot_Head[playerid])
		_inv_HandleGearSlotClick_Head(playerid);

	if(playertextid == GearSlot_Face[playerid])
		_inv_HandleGearSlotClick_Face(playerid);

	if(playertextid == GearSlot_Hand[playerid])
		_inv_HandleGearSlotClick_Hand(playerid);

	if(playertextid == GearSlot_Hols[playerid])
		_inv_HandleGearSlotClick_Hols(playerid);

	if(playertextid == GearSlot_Tors[playerid])
		_inv_HandleGearSlotClick_Tors(playerid);

	if(playertextid == GearSlot_Back[playerid])
		_inv_HandleGearSlotClick_Back(playerid);

	return 1;
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

	defer UpdatePlayerGear(playerid);

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

	defer UpdatePlayerGear(playerid);

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

	defer UpdatePlayerGear(playerid);

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

	defer UpdatePlayerGear(playerid);

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

	defer UpdatePlayerGear(playerid);

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

	defer UpdatePlayerGear(playerid);

	return 1;
}
