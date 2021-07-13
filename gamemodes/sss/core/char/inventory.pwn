#include <YSI_Coding\y_hooks>


#define UI_ELEMENT_TITLE	(0)
#define UI_ELEMENT_TILE		(1)
#define UI_ELEMENT_ITEM		(2)


static
	inv_GearActive[MAX_PLAYERS],
	PlayerText:GearSlot_Head[3],
	PlayerText:GearSlot_Face[3],
	PlayerText:GearSlot_Hand[3],
	PlayerText:GearSlot_Hols[3],
	PlayerText:GearSlot_Tors[3],
	PlayerText:GearSlot_Back[3],
	Container:inv_TempContainerID[MAX_PLAYERS],
	inv_InventoryOptionID[MAX_PLAYERS];


forward CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height);

hook OnPlayerConnect(playerid)
{
	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 517.0, 183.0, 53.0, 55.0);
	CreatePlayerTile(playerid, GearSlot_Face[0], GearSlot_Face[1], GearSlot_Face[2], 580.0, 183.0, 53.0, 55.0);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 517.0, 283.0, 53.0, 55.0);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 580.0, 283.0, 53.0, 55.0);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 517.0, 383.0, 53.0, 55.0);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 580.0, 383.0, 53.0, 55.0);

	PlayerTextDrawSetString(playerid, GearSlot_Head[0], "Cabeca");
	PlayerTextDrawSetString(playerid, GearSlot_Face[0], "Rosto");
	PlayerTextDrawSetString(playerid, GearSlot_Hand[0], "Mao");
	PlayerTextDrawSetString(playerid, GearSlot_Hols[0], "Coldre");
	PlayerTextDrawSetString(playerid, GearSlot_Tors[0], "Tronco");
	PlayerTextDrawSetString(playerid, GearSlot_Back[0], "Costas");
}

CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height)
{
	title							=CreatePlayerTextDraw(playerid, x + width / 2.0, y - 12.0, "_");
	PlayerTextDrawAlignment			(playerid, title, 2);
	PlayerTextDrawBackgroundColor	(playerid, title, 255);
	PlayerTextDrawFont				(playerid, title, 1);
	PlayerTextDrawLetterSize		(playerid, title, 0.20, 1.00);
	PlayerTextDrawColor				(playerid, title, -1);
	PlayerTextDrawSetOutline		(playerid, title, 1);
	PlayerTextDrawSetProportional	(playerid, title, 1);
	PlayerTextDrawTextSize			(playerid, title, height, width - 4);
	PlayerTextDrawBoxColor			(playerid, title, 150);
	PlayerTextDrawUseBox			(playerid, title, true);

	tile							=CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont				(playerid, tile, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, tile, 100);
	PlayerTextDrawColor				(playerid, tile, -1);
	PlayerTextDrawTextSize			(playerid, tile, width, height);
	PlayerTextDrawSetSelectable		(playerid, tile, true);
	PlayerTextDrawSetPreviewModel	(playerid, tile, 19300);

	item							=CreatePlayerTextDraw(playerid, x + width / 2.0, y + height, "_");
	PlayerTextDrawAlignment			(playerid, item, 2);
	PlayerTextDrawBackgroundColor	(playerid, item, 255);
	PlayerTextDrawFont				(playerid, item, 1);
	PlayerTextDrawLetterSize		(playerid, item, 0.20, 1.00);
	PlayerTextDrawColor				(playerid, item, -1);
	PlayerTextDrawSetOutline		(playerid, item, 1);
	PlayerTextDrawSetProportional	(playerid, item, 1);
	PlayerTextDrawTextSize			(playerid, item, height, width + 10);
}

ShowPlayerGear(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;
		
	inv_GearActive[playerid] = true;

	for(new i; i < 3; i++)
	{
		PlayerTextDrawShow(playerid, GearSlot_Head[i]);
		PlayerTextDrawShow(playerid, GearSlot_Face[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hand[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hols[i]);
		PlayerTextDrawShow(playerid, GearSlot_Tors[i]);
		PlayerTextDrawShow(playerid, GearSlot_Back[i]);
	}

	return 1;
}

HidePlayerGear(playerid)
{
	inv_GearActive[playerid] = false;

	for(new i; i < 3; i++)
	{
		PlayerTextDrawHide(playerid, GearSlot_Head[i]);
		PlayerTextDrawHide(playerid, GearSlot_Face[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hand[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hols[i]);
		PlayerTextDrawHide(playerid, GearSlot_Tors[i]);
		PlayerTextDrawHide(playerid, GearSlot_Back[i]);
	}
}

ShowPlayerHealthInfo(playerid)
{
	new
		tmp,
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate,
		Float:hunger = GetPlayerFP(playerid),
		infected1 = GetPlayerInfectionIntensity(playerid, 0),
		infected2 = GetPlayerInfectionIntensity(playerid, 1);

	drugs = GetPlayerDrugsList(playerid, drugslist);
	GetPlayerBleedRate(playerid, bleedrate);

	SetBodyPreviewLabel(playerid, tmp++, sprintf("Feridas: %d", GetPlayerWounds(playerid)),
		GetPlayerWounds(playerid) ? RGBAToHex(max(GetPlayerWounds(playerid) * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	if(bleedrate > 0)
		SetBodyPreviewLabel(playerid, tmp++, sprintf("Sangramento: %0.1f%", bleedrate * 3200.0), RGBAToHex(truncateforbyte(floatround(bleedrate * 3200.0)), truncateforbyte(255 - floatround(bleedrate * 3200.0)), 0, 255));

	if(hunger < 90.0)
		SetBodyPreviewLabel(playerid, tmp++, sprintf("Energia: %0.1f%", hunger), RGBAToHex(truncateforbyte(floatround((66.6 - hunger) * 4.8)), truncateforbyte(255 - floatround((66.6 - hunger) * 4.8)), 0, 255));

	if(infected1)
		SetBodyPreviewLabel(playerid, tmp++, "Infecao alimentar", 0xFF0000FF);

	if(infected2)
		SetBodyPreviewLabel(playerid, tmp++, "Infecao de Ferida", 0xFF0000FF);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, tmp++, drugname, RED);
	}

	SetBodyPreviewLabel(playerid, tmp++, sprintf("Chance de Desmaio: %.1f%%", (GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6) / 2) ), 0xFFFFFFFF);
}

UpdatePlayerGear(playerid, show = 1)
{
	new
		tmp[5 + MAX_ITEM_NAME + MAX_ITEM_TEXT],
		Item:itemid,
		ItemType:itemtype,
		model;

	itemid = GetPlayerHatItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], model);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Head[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerMaskItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], model);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Face[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	if(IsValidItem(itemid))
	{
		new size;
		GetItemTypeSize(GetItemType(itemid), size);
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", size, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], model);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerHolsterItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	if(IsValidItem(itemid))
	{
		new size;
		GetItemTypeSize(GetItemType(itemid), size);
		GetItemName(itemid, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", size, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], model);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 19300);
	}

	if(GetPlayerAP(playerid) > 0.0)
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], sprintf("Armadura (%.0f)", GetPlayerAP(playerid)));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19515);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerBagItem(playerid);
	itemtype = GetItemType(itemid);
	GetItemTypeModel(itemtype, model);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], model);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Back[UI_ELEMENT_TILE], 0.0, 0.0, 0.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], 19300);
	}

	if(show)
		ShowPlayerGear(playerid);

	return;
}

hook OnPlayerOpenInventory(playerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	HidePlayerGear(playerid);
	HideBodyPreviewUI(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	HidePlayerGear(playerid);
	HideBodyPreviewUI(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
			UpdatePlayerGear(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromInv(playerid, Item:itemid, slot)
{
	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, Item:itemid, slot)
{
	if(IsItemTypeCarry(GetItemType(itemid)))
		return 1;

	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
{
	if(IsItemTypeCarry(GetItemType(itemid)))
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	if(inv_GearActive[playerid])
		UpdatePlayerGear(playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Head(playerid);

	if(playertextid == GearSlot_Face[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Face(playerid);

	if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hand(playerid);

	if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hols(playerid);

	if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Tors(playerid);

	if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
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

	UpdatePlayerGear(playerid);

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

	UpdatePlayerGear(playerid);

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
			if(GetPlayerCurrentBag(playerid) == itemid)
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

	UpdatePlayerGear(playerid);

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

	UpdatePlayerGear(playerid);

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

	UpdatePlayerGear(playerid);

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

	UpdatePlayerGear(playerid);

	return 1;
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