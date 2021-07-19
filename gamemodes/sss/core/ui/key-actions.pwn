
#include <YSI_Coding\y_hooks>


static
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];


hook OnPlayerConnect(playerid)
{
	KeyActions[playerid]			=CreatePlayerTextDraw(playerid, 618.000000, 122.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, KeyActions[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, KeyActions[playerid], 255);
	PlayerTextDrawFont				(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, KeyActions[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, KeyActions[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, KeyActions[playerid], 1);
}


/*==============================================================================

	Core

==============================================================================*/


stock ShowPlayerKeyActionUI(playerid)
{
	if(!IsValidItem(GetPlayerTweakItem(playerid))) {
		PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
		PlayerTextDrawShow(playerid, KeyActions[playerid]);
	}
}

stock HidePlayerKeyActionUI(playerid)
{
	PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock ClearPlayerKeyActionUI(playerid)
{
	KeyActionsText[playerid][0] = EOS;
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

		format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", tmp, use);
	}
	else
		format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);

	strcat(KeyActionsText[playerid], tmp);
}


/*==============================================================================

	Internal

==============================================================================*/


// Enter/exit inventory
hook OnPlayerOpenInventory(playerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseInventory(playerid)
{
	defer t_UpdateKeyActions(playerid);
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	defer t_UpdateKeyActions(playerid);
}

hook OnPlayerAddToInventory(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromInv(playerid, Item:itemid, slot)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid)
{
	_UpdateKeyActions(playerid);
}

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, Item:itemid)
{
	defer t_UpdateKeyActions(playerid);
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


timer t_UpdateKeyActions[100](playerid)
	_UpdateKeyActions(playerid);

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	_UpdateKeyActions(playerid);

	if(!IsPlayerToolTipsOn(playerid))
		return 1;

	if(newstate != PLAYER_STATE_DRIVER)
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 1;

	_ShowRepairTip(playerid, vehicleid);

	return 1;
}

_UpdateKeyActions(playerid)
{
	if(!IsPlayerSpawned(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerViewingInventory(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);
	if(IsValidContainer(containerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerKnockedOut(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(!IsPlayerHudOn(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		ClearPlayerKeyActionUI(playerid);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			AddToolTipText(playerid, KEYTEXT_ENGINE, "Motor");
			AddToolTipText(playerid, KEYTEXT_LIGHTS, "Luzes");
			AddToolTipText(playerid, KEYTEXT_DOORS, "Fechadura");
		}

		AddToolTipText(playerid, KEYTEXT_RELOAD, "Abrir inventario");

		ShowPlayerKeyActionUI(playerid);
		return;
	}

	new
		Item:itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;

	ClearPlayerKeyActionUI(playerid);

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

		AddToolTipText(playerid, KEYTEXT_INVENTORY, "Abrir Inventario");

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
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Refuel vehicle");
		}
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Encher na Bomba");
	}
	else if(itemtype == item_Clothes)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Vestir Roupa");
	}
	else if(itemtype == item_Headlight)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Trocar Farol");
		}
	}
	else if(itemtype == item_Pills)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Tomar Comprimido");
	}
	else if(itemtype == item_AutoInjec)
	{
		if(inplayerarea == -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Injetar em Si");
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Injetar no Jogador");
	}
	else if(itemtype == item_HerpDerp)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-derp");
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Curar Jogador");
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Curar a Si Proprio");
	}
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer || itemtype == item_Spanner)
	{
		if(invehiclearea != INVALID_VEHICLE_ID)
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Reparar Motor");
		}
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
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Usar Chapeu");
		else if(GetMaskFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Usar Chapeu");
		else if(GetItemTypeExplosiveType(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Armar Explosivo");
		else if(GetItemTypeLiquidContainerType(itemtype) != -1 && itemtype != item_GasCan)
			AddToolTipText(playerid, KEYTEXT_INTERACT, "Beber");
	}

	if(GetItemTypeWeapon(itemtype) != -1)
	{
		ClearPlayerKeyActionUI(playerid);

		if(IsValidHolsterItem(itemtype))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Guardar no Coldre");

		if(GetItemWeaponCalibre(GetItemTypeWeapon(itemtype)) != NO_CALIBRE){
			AddToolTipText(playerid, KEYTEXT_RELOAD, "Recarregar");
			if(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)) != -1 && GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid) != 0)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar/Descarregar");
			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar");
		}
	}
	else {
		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, "Guardar");
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, "Soltar");
	}
	
	AddToolTipText(playerid, KEYTEXT_INVENTORY, "Abrir Inventario");
	ShowPlayerKeyActionUI(playerid);

	return;
}

_ShowRepairTip(playerid, vehicleid){
	new Float:health;
	GetVehicleHealth(vehicleid, health);
	if(health <= VEHICLE_HEALTH_CHUNK_2)
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHVER"), 20000);
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHBRO"), 20000);
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHBIT"), 20000);
	else if(health <= VEHICLE_HEALTH_MAX)
		ShowHelpTip(playerid, ls(playerid, "TUTORVEHSLI"), 20000);

	return;
}
