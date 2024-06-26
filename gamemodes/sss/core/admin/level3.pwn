#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/sethp - Define a vida do Jogador\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/spec - Spectar Jogadores\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/free - Viajar com a Câmera\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/ip - Obter o IP de um Jogador\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/vehicle - vehicle control (duty only)\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/move - nudge yourself\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/teleportes - lista de teleportes\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/additem - spawn an item\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/addvehicle - spawn a vehicle\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/resetpassword - reset a password\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/setactive - (de)activate accounts\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/delete(items/tents/defences/signs) - delete things\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/whitelist - add/remove name or turn whitelist on/off\n");
}

// Definir a vida do Jogador
ACMD:sethp[3](playerid, params[])
{
	new 
			targetid,
	Float:	value;

	if(sscanf(params, "df", targetid, value))
		ChatMsg(playerid, YELLOW, " » Utilização: /sethp [jogador] [valor]");
	/* else if(isnull(params[1]))
		ChatMsg(playerid, YELLOW, "Jogador %P: %fHP", targetid, GetPlayerHP(targetid));	 */
	else
	{
		if(targetid == -1)
			targetid = playerid;

		SetPlayerHP(targetid, value);
		ChatMsg(targetid, YELLOW, "HP do Jogador %P"C_YELLOW" definida para %f", targetid, value);
	}

	return 1;
}

/* 
	Enter spectate mode on a specific player

	Selects a random valid id if the one supplied is not valid
*/
ACMD:spec[2](playerid, params[])
{
	new targetid = !isnull(params) ? strval(params) : -1;

	if(targetid != -1) // ID provided
	{
		if(Iter_Count(Player) == 1)
			return ChatMsg(playerid, RED, "Apenas está você online, vai dar spec em quem?...");

		if(CanAdminSpectatePlayer(playerid, targetid) != -1) // Has Spectate permission
		{
			new tries;

			while(CanAdminSpectatePlayer(playerid, targetid) == 0 && tries < 3)
			{
				targetid = random(GetPlayerPoolSize()); // Não funciona corretamente?
				tries++;

				log(false, "Spec - Target: %d Try: %d", targetid, tries);
			}

			if(tries <= 3)
			{
				ToggleAdminDuty(playerid, true);
				EnterSpectateMode(playerid, targetid);
			}
		}
		else
			ChatMsg(playerid, RED, "Apenas pode dar Spec em Jogadores Reportados.");
	}
	else // No player id provided
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			//ToggleAdminDuty(playerid, false);
			ExitSpectateMode(playerid);
		}
		else
			ChatMsg(playerid, YELLOW, "Não está em Spectate...");
	}

	return 1;
}

ACMD:free[2](playerid)
{
	if(!IsAdminOnDuty(playerid))
		ToggleAdminDuty(playerid, true);

	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);
	else
		EnterFreeMode(playerid);

	return 1;
}

ACMD:recam[2](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	ExitFreeMode(playerid);
	return 1;
}


/*==============================================================================

	Get IP

==============================================================================*/


ACMD:ip[3](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " » Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
			else
				return 4;
		}

		ChatMsg(playerid, YELLOW, " » IP for %P"C_YELLOW": %s", targetid, IpIntToStr(GetPlayerIpAsInt(targetid)));
	}
	else
	{
		if(!DoesAccountExistByName(params))
		{
			ChatMsg(playerid, YELLOW, " » The account '%s' does not exist.", params);
			return 1;
		}

		new ip;

		GetAccountIP(params, ip);

		ChatMsg(playerid, YELLOW, " » IP for "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}


/*==============================================================================

	Control vehicles

==============================================================================*/


ACMD:vehicle[3](playerid, params[])
{
	if(!IsAdminOnDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
		return 6;

	new
		command[10],
		vehicleid;

	if(sscanf(params, "s[10]D(-1)", command, vehicleid))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /vehicle [get/goto/enter/owner/delete/respawn/reset/lock/unlock/removekey] [id]");
		return 1;
	}

	if(vehicleid == -1)
		vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 4;

	if(!strcmp(command, "get"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z + 2);
		SetCameraBehindPlayer(playerid);

		return 1;
	}

	if(!strcmp(command, "goto"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	if(!strcmp(command, "enter"))
	{
		PutPlayerInVehicle(playerid, vehicleid, 0);

		return 1;
	}

	if(!strcmp(command, "owner"))
	{
		new owner[MAX_PLAYER_NAME];

		GetVehicleOwner(vehicleid, owner);

		ChatMsg(playerid, YELLOW, " » Vehicle owner: '%s'", owner);

		return 1;
	}

	if(!strcmp(command, "delete"))
	{
		DestroyWorldVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " » Vehicle %d deleted", vehicleid);

		return 1;
	}

	if(!strcmp(command, "respawn"))
	{
		RespawnVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " » Vehicle %d respawned", vehicleid);

		return 1;
	}

	if(!strcmp(command, "reset"))
	{
		ResetVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " » Vehicle %d reset", vehicleid);

		return 1;
	}

	if(!strcmp(command, "lock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);

		ChatMsg(playerid, YELLOW, " » Vehicle %d locked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "unlock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

		ChatMsg(playerid, YELLOW, " » Vehicle %d unlocked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "removekey"))
	{
		SetVehicleKey(vehicleid, 0);

		ChatMsg(playerid, YELLOW, " » Vehicle %d unlocked", vehicleid);

		return 1;
	}

	if(!strcmp(command, "destroy"))
	{
		SetVehicleHealth(vehicleid, 0.0);

		ChatMsg(playerid, YELLOW, " » Vehicle %d set on fire", vehicleid);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " » Utilização: /vehicle [get/enter/owner/delete/respawn/reset/lock/unlock] [id]");

	return 1;
}


/*==============================================================================

	Teleportes para pontos de interesse

==============================================================================*/

ACMD:bb[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /bb", playerid, playerid);
    SetPlayerPos(playerid,0.22, 0.21, 3.11);
	return 1;
}

ACMD:sf[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /sf", playerid, playerid);
    SetPlayerPos(playerid,-2026.95, 156.70, 29.03);
	return 1;
}

ACMD:lv[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /lv", playerid, playerid);
    SetPlayerPos(playerid,2026.64, 1008.28, 10.82);
	return 1;
}

ACMD:ls[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ls", playerid, playerid);
    SetPlayerPos(playerid,1481.09, -1764.00, 18.79);
	return 1;
}

ACMD:fc[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /fc", playerid, playerid);
    SetPlayerPos(playerid,-216.36, 979.20, 20.94);
	return 1;
}

ACMD:bs[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /bs", playerid, playerid);
    SetPlayerPos(playerid,-2506.8413, 2358.6741, 4.9860);
	return 1;
}

ACMD:mg[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /mg", playerid, playerid);
    SetPlayerPos(playerid,1347.8447, 313.6524, 20.5547);
	return 1;
}

ACMD:dm[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /dm", playerid, playerid);
    SetPlayerPos(playerid,619.8964, -542.9938, 16.4536);
	return 1;
}

ACMD:pc[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /pc", playerid, playerid);
    SetPlayerPos(playerid,2332.5959, 38.6790, 26.4816);
	return 1;
}

ACMD:ap[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ap", playerid, playerid);
    SetPlayerPos(playerid,-2144.5183, -2338.9004, 30.6250);
	return 1;
}

ACMD:lp[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /lp", playerid, playerid);
    SetPlayerPos(playerid,-240.3974, 2713.4150, 62.6875);
	return 1;
}

ACMD:lb[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /lb", playerid, playerid);
    SetPlayerPos(playerid,-736.2372, 1547.7043, 39.0007);
	return 1;
}

ACMD:eq[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /eq", playerid, playerid);
    SetPlayerPos(playerid,-1464.2638, 2589.4426, 55.8359);
	return 1;
}

ACMD:ec[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ec", playerid, playerid);
    SetPlayerPos(playerid,-388.5280, 2212.0117, 42.4249);
	return 1;
}

ACMD:mcd[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /mcd", playerid, playerid);
    SetPlayerPos(playerid,-2323.0515, -1637.6571, 483.7031);
	return 1;
}

ACMD:69[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /69", playerid, playerid);
    SetPlayerPos(playerid,-1359.2432, 498.4693, 21.2500);
	return 1;
}

ACMD:cb[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /cb", playerid, playerid);
    SetPlayerPos(playerid,-1918.1047, 640.4106, 46.5625);
	return 1;
}

ACMD:51[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /51", playerid, playerid);
    SetPlayerPos(playerid,249.6743, 1887.9854, 20.6406);
	return 1;
}

ACMD:kacc[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /kacc", playerid, playerid);
    SetPlayerPos(playerid,2590.4778, 2800.8882, 10.8203);
	return 1;
}

ACMD:militarls1[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /militarls1", playerid, playerid);
    SetPlayerPos(playerid,1900.0914, -457.6173, 27.4642);
	return 1;
}

ACMD:militarls2[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /militarls2", playerid, playerid);
    SetPlayerPos(playerid,-1039.7141, -918.3206, 132.6531);
	return 1;
}

ACMD:ilhals[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ilhals", playerid, playerid);
    SetPlayerPos(playerid, 4516.3730, -1731.4437, 19.0619);
	return 1;
}

ACMD:ilhalv[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ilhalv", playerid, playerid);
    SetPlayerPos(playerid, 291.6670, 4330.2515, 2.9280);
	return 1;
}

ACMD:ilhasf[3](playerid)
{
    if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) usou o teleporte /ilhasf", playerid, playerid);
    SetPlayerPos(playerid, -4496.7695, 437.8691, 17.0272);
	return 1;
}

ACMD:teleportes[3](playerid)
{
    new stringtp[800];
    strcat(stringtp, ""C_BLUE"Los Santos - /ls\n");
    strcat(stringtp, ""C_BLUE"Las Venturas - /lv\n");
    strcat(stringtp, ""C_BLUE"San Fierro - /sf\n");
    strcat(stringtp, ""C_BLUE"BlueBerry - /bb\n");
    strcat(stringtp, ""C_BLUE"Bayside - /bs\n");
    strcat(stringtp, ""C_BLUE"Montgomery - /mg\n");
    strcat(stringtp, ""C_BLUE"Dillimore - /dm\n");
    strcat(stringtp, ""C_BLUE"PalominoCreek - /pc\n");
    strcat(stringtp, ""C_BLUE"AngelPine - /ap\n");
    strcat(stringtp, ""C_BLUE"LasPayasadas - /lp\n");
    strcat(stringtp, ""C_BLUE"LasBarrancas - /lb\n");
    strcat(stringtp, ""C_BLUE"ElQuebrados - /eq\n");
    strcat(stringtp, ""C_BLUE"ElCastillo - /ec\n");
    strcat(stringtp, ""C_BLUE"MontiChillad - /mcd\n");
    strcat(stringtp, ""C_BLUE"69 - /69\n");
    strcat(stringtp, ""C_BLUE"Casa Branca - /cb\n");
    strcat(stringtp, ""C_BLUE"51 - /51\n");
    strcat(stringtp, ""C_BLUE"K.A.C.C - /kacc\n");
    strcat(stringtp, ""C_BLUE"Militar do Barranco - /militarls1\n");
    strcat(stringtp, ""C_BLUE"Militar da Fazenda - /militarls2\n");
    strcat(stringtp, ""C_BLUE"Ilha de Los Santos - /ilhals\n");
	strcat(stringtp, ""C_BLUE"Ilha de Los Santos - /ilhalv\n");
	strcat(stringtp, ""C_BLUE"Ilha de Los Santos - /ilhasf\n");
    ShowPlayerDialog(playerid, 11478, DIALOG_STYLE_MSGBOX, "Teleportes", stringtp, "Fechar", "");
	return 1;
}

ACMD:move[3](playerid, params[])
{
	if(!IsAdminOnDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new
		direction[10],
		Float:amount;

	if(!sscanf(params, "s[10]F(2.0)", direction, amount))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		if(direction[0] == 'f') // forwards
			x += amount * floatsin(-r, degrees), y += amount * floatcos(-r, degrees);

		if(direction[0] == 'b') // backwards
			x -= amount * floatsin(-r, degrees), y -= amount * floatcos(-r, degrees);

		if(direction[0] == 'u') // up
			z += amount;

		if(direction[0] == 'd') // down
			z -= amount;

		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " » Utilização: /move [f/b/u/d] [optional:distance]");

	return 1;
}


/*==============================================================================

	Spawn a new item into the game world

==============================================================================*/


ACMD:additem[3](playerid, params[])
{
	new name[MAX_ITEM_NAME];

	if(sscanf(params, "s["#MAX_ITEM_NAME"]", name))
		return ChatMsg(playerid, YELLOW, " » Utilize: /additem [nome/id do item]");

	new 
		uniquename[MAX_ITEM_NAME],
		typename[MAX_ITEM_NAME];

	if(IsNumeric(name) && IsValidItemType(ItemType:strval(name)))
	{
		AdminAddItem(playerid, ItemType:strval(name));
		return 1;
	}
	else
	{
		new
			ItemType:list[_:MAX_ITEM_TYPE] = {ItemType:INVALID_ITEM_TYPE, ...},
			count = -1;

		gBigString[playerid][0] = EOS;

		strcat(gBigString[playerid], "ID:\tNome:\tChave:\tExistentes:\n");

		for(new ItemType:i; i < MAX_ITEM_TYPE; i++)
		{
			if(!IsValidItemType(i))
				break;

			GetItemTypeUniqueName(i, uniquename);
			GetItemTypeName(i, typename);

			if(strfind(uniquename, name, true) != -1 || strfind(typename, name, true) != -1)
			{
				list[++count] = i;

				strcat(gBigString[playerid], ret_valstr(_:i)); // id
				strcat(gBigString[playerid], "\t");

				strcat(gBigString[playerid], typename); // type name
				strcat(gBigString[playerid], "\t");
				
				strcat(gBigString[playerid], uniquename); // unic name
				strcat(gBigString[playerid], "\t");

				strcat(gBigString[playerid], ret_valstr(GetItemTypeCount(i))); // count
				strcat(gBigString[playerid], "\n");
			}
		}

		if(count > 1)
		{
			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, inputtext

				if(response)
					AdminAddItem(playerid, list[listitem]);
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_TABLIST_HEADERS, "Adicionar Item", gBigString[playerid], "Selecionar", "Sair");
			return 1;
		}
		else if(list[0] != INVALID_ITEM_TYPE)
		{
			AdminAddItem(playerid, list[0]);
			return 1;
		}
	}

	ChatMsg(playerid, RED, " » Nenhum item encontrado.");

	return 1;
}

AdminAddItem(playerid, ItemType:type)
{
	new 
		Float:x,
		Float:y,
		Float:z, 
		Float:r,
		Item:itemid = INVALID_ITEM_ID,
		typename[MAX_ITEM_NAME + MAX_ITEM_TEXT];

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);
	itemid = GetNextItemID();

	if(Item:0 <= itemid < MAX_ITEM)
	{
		SetItemLootIndex(itemid, random(GetLootIndexTotal()));

		CreateItem(type,
			x + (0.5 * floatsin(-r, degrees)),
			y + (0.5 * floatcos(-r, degrees)),
			z - ITEM_FLOOR_OFFSET,
			.rz = r,
			.world = GetPlayerVirtualWorld(playerid),
			.interior = GetPlayerInterior(playerid)
		);

		GetItemName(itemid, typename);

		ChatMsg(playerid, GREEN, " » Item "C_YELLOW"%s"C_GREEN" (ID "C_BLUE"%d"C_GREEN") Added - Count: %d", typename, _:type, GetItemTypeCount(type));
	}
}

/*==============================================================================

	Spawn a new vehicle into the game world

==============================================================================*/


ACMD:addvehicle[3](playerid, params[])
{
	new name[32];

	if(sscanf(params, "s[32]", name))
		return ChatMsg(playerid, YELLOW, " » Utilize: /addvehicle [nome/id do veiculo]");

	new vname[MAX_VEHICLE_TYPE_NAME];

	if(IsNumeric(name) && IsValidVehicleType(strval(name))) {
		AdminAddVehicle(playerid, GetVehicleTypeModel(strval(name)));
		return 1;
	} else {
		new
			list[MAX_VEHICLE_TYPE] = {INVALID_VEHICLE_TYPE, ...},
			count = -1;

		gBigString[playerid][0] = EOS;

		for(new i; i < MAX_VEHICLE_TYPE; i++)
		{
			if(!IsValidVehicleType(i))
				break;

			GetVehicleTypeName(i, vname);

			if(strfind(vname, name, true) != -1)
			{
				list[++count] = i;
				strcat(gBigString[playerid], ret_valstr(i)); // type
				strcat(gBigString[playerid], ".\t"); // space
				strcat(gBigString[playerid], vname); // type name
				strcat(gBigString[playerid], "\n");
			}
		}
		if(count > 1)
		{
			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, inputtext

				if(response)
					AdminAddVehicle(playerid, list[listitem]);
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Adicionar veiculo", gBigString[playerid], "Selecionar", "Sair");
			return 1;
		}
		else if(list[0] != INVALID_VEHICLE_TYPE)
		{
			AdminAddVehicle(playerid, list[0]);
			return 1;
		}
	}

	ChatMsg(playerid, YELLOW, " » Tipo de Veículo Inválido.");

	return 1;	
}

AdminAddVehicle(playerid, type) {
	new
		vehicleId,
		Float:playerAngle,
		Float:camPosX, 		Float:camPosY, 		Float:camPosZ,
		Float:camVectorX, 	Float:camVectorY, 	Float:camVectorZ,
		Float:vehicleX, 	Float:vehicleY, 	Float:vehicleZ;

	GetPlayerFacingAngle(playerid, playerAngle);
	GetPlayerCameraPos(playerid, camPosX, camPosY, camPosZ);
	GetPlayerCameraFrontVector(playerid, camVectorX, camVectorY, camVectorZ);

	vehicleX = camPosX + floatmul(camVectorX, 6.0);
	vehicleY = camPosY + floatmul(camVectorY, 6.0);
	vehicleZ = camPosZ + floatmul(camVectorZ, 6.0);

	vehicleId = CreateLootVehicle(type, vehicleX, vehicleY, vehicleZ, playerAngle);
	SetVehicleFuel(vehicleId, 100000.0); // All the fuel
	SetVehicleHealth(vehicleId, 990.0);
	SetVehicleParamsEx(vehicleId, 1, 1, 0, 1, 0, 0, 0); // Fully fixed
	SetVehicleEngine(vehicleId, true);
	SetVehicleExternalLock(vehicleId, E_LOCK_STATE_OPEN);
	SetVehicleTrunkLock(vehicleId, 0);
	ToggleVehicleWheels(vehicleId, true);
	PutPlayerInVehicle(playerid, vehicleId, 0);

	if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			log(true, "[ADDVEHICLE] %p added vehicle %d reason: %s", pid, type, inputtext);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Justificação", "Introduz a Motivo para ter adicionado esse veículo:", "OK", "");
	}
}


/*==============================================================================

	Reset a player's password

==============================================================================*/


ACMD:resetpassword[3](playerid, params[])
{
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /resetpassword [account user-name]");
		return 1;
	}

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
		ChatMsg(playerid, YELLOW, " » Password for '%s' reset.", params);
	else
		ChatMsg(playerid, RED, " » An error occurred.");

	return 1;
}


ACMD:setactive[3](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		active;

	if(sscanf(params, "s[24]d", name, active))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /setactive [name] [1/0]");
		return 1;
	}

	if(!DoesAccountExistByName(name))
	{
		ChatMsg(playerid, RED, " » That account doesn't exist.");
		return 1;
	}

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " » %s "C_BLUE"'%s' "C_YELLOW"account.", active ? ("Activated") : ("Deactivated"), name);

	return 1;
}

/*==============================================================================

	Delete a bunch of a specific type of entity within a radius

==============================================================================*/


ACMD:delete[3](playerid, params[])
{
	if(!(IsAdminOnDuty(playerid)) && GetPlayerAdminLevel(playerid) == STAFF_LEVEL_ADMINISTRATOR)
		return 6;

	new
		type[16],
		Float:range;

	if(sscanf(params, "s[16]F(1.5)", type, range))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /delete [items/tents/defences/signs] [optional:range(1.5)]");
		return 1;
	}

	if(range > 100.0)
	{
		ChatMsg(playerid, YELLOW, " » Range limit: 100 metres");
		return 1;
	}

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetPlayerPos(playerid, px, py, pz);

	if(!strcmp(type, "item", true, 4))
	{
		foreach(new i : itm_Index)
		{
			GetItemPos(Item:i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = _:DestroyItem(Item:i);
		}

		return 1;
	}
	else if(!strcmp(type, "tent", true, 4))
	{
		foreach(new i : tnt_Index)
		{
			GetTentPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range){
				//i = DestroyTent(i);
			}
		}

		return 1;
	}
	else if(!strcmp(type, "defence", true, 7))
	{
		foreach(new i : itm_Index)
		{
			if(GetItemTypeDefenceType(GetItemType(Item:i)) == INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(Item:i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range){
				CallLocalFunction("OnDefenceDestroy", "d", i);
				i = _:DestroyItem(Item:i);
			}
		}

		return 1;
	}

	ChatMsg(playerid, YELLOW, " » Utilização: /delete [items/tents/defences/signs] [opcional: raio(1.5)]");

	return 1;
}
