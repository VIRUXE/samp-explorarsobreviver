
#include <YSI_Coding\y_hooks>


static
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];

hook OnPlayerConnect(playerid)
{
	KeyActions[playerid] = CreatePlayerTextDraw(playerid, 5.000000, 211.000000, "~y~H~W~ Abrir bolsos~n~~y~N ~W~Dropar item");
	PlayerTextDrawFont(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize(playerid, KeyActions[playerid], 0.304165, 1.250000);
	PlayerTextDrawTextSize(playerid, KeyActions[playerid], 215.000000, 464.500000);
	PlayerTextDrawSetOutline(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetShadow(playerid, KeyActions[playerid], 1);
	PlayerTextDrawAlignment(playerid, KeyActions[playerid], 1);
	PlayerTextDrawColor(playerid, KeyActions[playerid], 0xc4a656ff);
	PlayerTextDrawBackgroundColor(playerid, KeyActions[playerid], 255);
	PlayerTextDrawBoxColor(playerid, KeyActions[playerid], 50);
	PlayerTextDrawUseBox(playerid, KeyActions[playerid], 0);
	PlayerTextDrawSetProportional(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, KeyActions[playerid], 0);
}


/*==============================================================================

	Core

==============================================================================*/


stock ShowPlayerKeyActionUI(playerid)
{
	PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
	PlayerTextDrawShow(playerid, KeyActions[playerid]);
}

stock HidePlayerKeyActionUI(playerid)
{
	PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock AddToolTipText(playerid, const key[], const use[])
{
	new tmp[128];

	if(IsPlayerMobile(playerid))
	{
		if(!strcmp(key, KEYTEXT_INTERACT)) 			strcat(tmp, "F");
		else if(!strcmp(key, KEYTEXT_RELOAD)) 		strcat(tmp, "ALT");
		else if(!strcmp(key, KEYTEXT_PUT_AWAY)) 	strcat(tmp, "Y");
		else if(!strcmp(key, KEYTEXT_DROP_ITEM)) 	strcat(tmp, "N");
		else if(!strcmp(key, KEYTEXT_INVENTORY)) 	strcat(tmp, "H");
		else if(!strcmp(key, KEYTEXT_ENGINE)) 		strcat(tmp, "Y");
		else if(!strcmp(key, KEYTEXT_LIGHTS)) 		strcat(tmp, "N");
		else if(!strcmp(key, KEYTEXT_DOORS)) 		strcat(tmp, "2");

		format(tmp, sizeof(tmp), "%s ~w~%s~n~~y~", tmp, use);
	}
	else
		format(tmp, sizeof(tmp), "%s ~w~%s~n~~y~", key, use);

	strcat(KeyActionsText[playerid], tmp);
}


/*==============================================================================

	Internal

==============================================================================*/

// Enter/exit inventory
hook OnPlayerOpenedInventory(playerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerOpenedContainer(playerid, Container:containerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseInventory(playerid)
{
	_UpdateKeyActions(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	_UpdateKeyActions(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGetItem(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGivenItem(playerid, targetid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
	_UpdateKeyActions(playerid);
}

// Areas
hook OnPlayerEnterDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	_UpdateKeyActions(playerid);
	return 1;
}

hook OnAdminToggleDuty(playerid, bool:duty)
{
	_UpdateKeyActions(playerid);
}

hook OnAdminToggleFly(playerid, flying)
{
	_UpdateKeyActions(playerid);
}

_UpdateKeyActions(playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	// Hide
	if(IsPlayerViewingInventory(playerid) || IsValidContainer(containerid) || !IsPlayerHudOn(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	// Show

	KeyActionsText[playerid][0] = EOS; // Clear Text

	if(IsPlayerKnockedOut(playerid))
	{
		AddToolTipText(playerid, "~w~Voce foi", "~r~Imobilizado");
		ShowPlayerKeyActionUI(playerid);
		return;		
	}

	if(GetPlayerAdminLevel(playerid) >= STAFF_LEVEL_MODERATOR)
	{
		if(IsPlayerOnAdminDuty(playerid))
		{
			if(IsAdminFlying(playerid))
			{
				AddToolTipText(playerid, "SHIFT + RMB", "Velocidade");
				AddToolTipText(playerid, "~k~~PED_SPRINT~", "Cima");
				AddToolTipText(playerid, "~k~~PED_DUCK~", "Baixo");
				AddToolTipText(playerid, "~k~~PED_JUMPING~ ", "Modo lento");
			}

			AddToolTipText(playerid, "~k~~PED_JUMPING~ + ~k~~VEHICLE_ENTER_EXIT~", !IsAdminFlying(playerid) ? "Ativar Fly" : "Desativar Fly");
			AddToolTipText(playerid, "~k~~PED_JUMPING~ + ~k~~PED_DUCK~", "Sair de ADM");
			AddToolTipText(playerid, "~k~~PED_JUMPING~ + ~k~~PED_DUCK~ +~k~~SNEAK_ABOUT~", "Sair de ADM no Local");

			ShowPlayerKeyActionUI(playerid);
			return;
		}
		else
			AddToolTipText(playerid, "~k~~PED_JUMPING~ + ~k~~PED_DUCK~", "Entrar em ADM");
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			AddToolTipText(playerid, KEYTEXT_ENGINE, "Motor");
			AddToolTipText(playerid, KEYTEXT_LIGHTS, "Luzes");
			AddToolTipText(playerid, KEYTEXT_DOORS, "Fechadura");
			AddToolTipText(playerid, "~k~~GROUP_CONTROL_BWD~", "Buzina");
		} 
		else if(GetPlayerState(playerid) == PLAYER_STATE_PASSENGER)
		{
			AddToolTipText(playerid, KEYTEXT_DOORS, "Fechadura");
			AddToolTipText(playerid, "~k~~CONVERSATION_YES~", "Abrir bolso");
		}

		ShowPlayerKeyActionUI(playerid);
		return;
	}

	new
		Item:itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;

	if(invehiclearea != INVALID_VEHICLE_ID)
	{
		if(IsPlayerAtVehicleTrunk(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Abrir Porta-malas");

		if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Reparar com Ferramenta");
	}

	foreach(new i : Player)
	{
		if(IsPlayerNextToPlayer(playerid, i))
		{
			inplayerarea = i;
			break;
		}
	}

	if(!IsValidItem(itemid))
	{
		if(IsPlayerCuffed(inplayerarea))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Remover Algemas");
			ShowPlayerKeyActionUI(playerid);
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, "Abrir bolso");

		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Remover Mochila");

		ShowPlayerKeyActionUI(playerid);
		
		return;
	}

	new ItemType:itemtype = GetItemType(itemid);

	// Single items

	if(itemtype == item_Note)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Ler/Escrever");
	if(itemtype == item_Sign)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Colocar Placa");
	else if(itemtype == item_Armour)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Vestir");
	else if(itemtype == item_Crowbar)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Desmontar");
	else if(itemtype == item_Shield)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Colocar Barreira");
	else if(itemtype == item_HandCuffs)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Algemar Jogador");
	}
	else if(itemtype == item_Wheel)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Reparar Roda");
	else if(itemtype == item_GasCan)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Reabastecer veiculo");
		}
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Encher na Bomba");
	}
	else if(itemtype == item_Clothes)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Vestir Roupa");
	else if(itemtype == item_Headlight)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Trocar Farol");
	}
	else if(itemtype == item_Pills)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Tomar Comprimido");
	else if(itemtype == item_AutoInjec)
		AddToolTipText(playerid, KEYTEXT_INTERACT, inplayerarea == -1 ? "Injetar em Si" : "Injetar no Jogador");
	else if(itemtype == item_HerpDerp)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-derp");
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
		AddToolTipText(playerid, KEYTEXT_INTERACT, inplayerarea != -1 ? "Curar Jogador" : "Curar a Si mesmo");
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer || itemtype == item_Spanner)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Reparar Motor");
	}
	else
	{
		if(IsItemTypeFood(itemtype))
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Comer");
		else if(IsItemTypeBag(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Abrir");
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Vestir");
		}
		else if(GetHatFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Vestir");
		else if(GetMaskFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Vestir");
		else if(GetItemTypeExplosiveType(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Armar Explosivo");
		else if(GetItemTypeLiquidContainerType(itemtype) != -1 && itemtype != item_GasCan)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Beber");
	}

	if(GetItemTypeWeapon(itemtype) != -1)
	{
		if(IsValidHolsterItem(itemtype))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Guardar no Coldre");

		if(GetItemWeaponCalibre(GetItemTypeWeapon(itemtype)) != NO_CALIBRE)
		{
			AddToolTipText(playerid, KEYTEXT_RELOAD, "Recarregar");

			if(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)) != -1 && GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid) != 0)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar/Descarregar");
			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar");
		}
	}
	else
	{
		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Guardar");
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar");
	}
	
	if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR)
		AddToolTipText(playerid, KEYTEXT_INVENTORY, "Abrir bolso");

	ShowPlayerKeyActionUI(playerid);

	return;
}
