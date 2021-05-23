#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/spec /free - spectate and freecam\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/ip - get a player's IP\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/vehicle - vehicle control (duty only)\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/move - nudge yourself\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/additem - spawn an item\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/addvehicle - spawn a vehicle\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/resetpassword - reset a password\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/setactive - (de)activate accounts\n");
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, "/delete(items/tents/defences/signs) - delete things\n");
}

/*==============================================================================

	Enter spectate mode on a specific player

==============================================================================*/
ACMD:spec[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)))
		return 6;

	if(isnull(params))
		ExitSpectateMode(playerid);
	else if(isnumeric(params))
	{
		new targetid = strval(params);

		if(IsPlayerConnected(targetid) && targetid != playerid)
		{
			if(GetPlayerAdminLevel(playerid) == STAFF_LEVEL_GAME_MASTER)
			{
				new name[MAX_PLAYER_NAME];

				GetPlayerName(targetid, name, MAX_PLAYER_NAME);

				if(!IsPlayerReported(name))
				{
					ChatMsg(playerid, YELLOW, " >  You can only spectate reported players.");
					return 1;
				}
			}
			EnterSpectateMode(playerid, targetid);
		}
	}
	return 1;
}

ACMD:free[2](playerid)
{
	if(!IsPlayerOnAdminDuty(playerid))
		return 6;

	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);
	else
		EnterFreeMode(playerid);

	return 1;
}

ACMD:recam[2](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}

ACMD:ip[3](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
			else
				return 4;
		}

		ChatMsg(playerid, YELLOW, " >  IP for %P"C_YELLOW": %s", targetid, IpIntToStr(GetPlayerIpAsInt(targetid)));
	}
	else
	{
		if(!AccountExists(params))
		{
			ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", params);
			return 1;
		}

		new ip;

		GetAccountIP(params, ip);

		ChatMsg(playerid, YELLOW, " >  IP for "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}

ACMD:vehicle[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
		return 6;

	new
		command[10],
		vehicleid;

	if(sscanf(params, "s[10]D(-1)", command, vehicleid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /vehicle [get/goto/enter/owner/disable/delete/respawn/reset/lock/unlock/removekey] (id)");
		return 1;
	}

	if(vehicleid == -1)
		vehicleid = GetPlayerCameraTargetVehicle(playerid);

	if(!IsValidVehicle(vehicleid))
		return 4;

	new 
		vehiclename[MAX_VEHICLE_NAME],
		vehicleowner[MAX_PLAYER_NAME],
		zone[MAX_ZONE_NAME],
		Float:vx,
		Float:vy,
		Float:vz,
		Float:px,
		Float:py,
		Float:pz,
		Float:pr;

	vehiclename = GetVehicleName(vehicleid);
	GetVehicleOwner(vehicleid, vehicleowner);
	GetPlayerZone(playerid, zone);
	GetVehiclePos(vehicleid, vx, vy, vz);
	GetPlayerPos(playerid, px, py, pz);
	GetPlayerFacingAngle(playerid, pr);

	if(isnull(vehicleowner))
		vehicleowner = "None";

	if(!strcmp(command, "get"))
	{
		GetXYInFrontOfPlayer(playerid, px, py, 2.0);
		SetVehiclePos(vehicleid, px, py, pz);
		SetVehicleZAngle(vehicleid,  pr + 90.0);

		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` (`%.0f, %.0f, %.0f`) teleported vehicle `%d` (Name: %s, Owner: %s, Location: `%.0f, %.0f, %.0f` (%s)) to him.", playerid, px,py,pz, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "goto"))
	{
		SetPlayerPos(playerid, vx, vy, vz+5);

		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` (`%.0f, %.0f, %.0f`) teleported to vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, px,py,pz, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "enter"))
	{
		PutPlayerInVehicle(playerid, vehicleid, 0);

		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` (`%.0f, %.0f, %.0f`) entered vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, px,py,pz, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "owner"))
	{
		ChatMsg(playerid, YELLOW, " >  Vehicle owner: '%s'", vehicleowner);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` checked the owner (`%s`) of vehicle `%d` (%s).", playerid, vehicleowner, vehicleid, vehiclename);

		return 1;
	}
	if(!strcmp(command, "disable"))
	{
		DestroyWorldVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d disabled", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` disabled vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	/*if(!strcmp(command, "delete"))
	{
		DestroyWorldVehicle(vehicleid, true);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d deleted", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "`%p` deleted vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f`).", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz);

		return 1;
	}*/
	if(!strcmp(command, "respawn"))
	{
		RespawnVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d respawned", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` respawned vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "reset"))
	{
		ResetVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d reset", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` reset vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "lock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d locked", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` locked vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "unlock"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d unlocked", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` unlocked vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "removekey"))
	{
		SetVehicleKey(vehicleid, 0);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d had it's key removed", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` removed the key from vehicle `%d` (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	if(!strcmp(command, "destroy"))
	{
		SetVehicleHealth(vehicleid, 0.0);

		ChatMsg(playerid, YELLOW, " >  Vehicle %d set on fire", vehicleid);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` set vehicle `%d` on fire (destroy) (Name: `%s`, Owner: `%s`, Location: `%.0f, %.0f, %.0f` (%s))", playerid, vehicleid, vehiclename, vehicleowner, vy,vx,vz, zone);

		return 1;
	}
	ChatMsg(playerid, YELLOW, " >  Usage: /vehicle [get/enter/owner/delete/respawn/reset/lock/unlock] [id]");

	return 1;
}

ACMD:move[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
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
			Float:r,
			zone[MAX_ZONE_NAME];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);
		GetPlayerZone(playerid, zone);

		if(direction[0] == 'f')
		{
			x += amount * floatsin(-r, degrees), y += amount * floatcos(-r, degrees);
			log(DISCORD_CHANNEL_ADMINEVENTS, "[MOVE] `%p` moved FORWARD `%.0f meters` at `%.0f, %.0f, %.0f` (%s)", playerid, amount, x, y, z, zone);
		}
		if(direction[0] == 'b')
		{
			x -= amount * floatsin(-r, degrees), y -= amount * floatcos(-r, degrees);
			log(DISCORD_CHANNEL_ADMINEVENTS, "[MOVE] `%p` moved BACKWARDS `%.0f meters` at `%.0f, %.0f, %.0f` (%s)", playerid, amount, x, y, z, zone);
		}
		if(direction[0] == 'u')
		{
			z += amount;
			log(DISCORD_CHANNEL_ADMINEVENTS, "[MOVE] `%p` moved UP `%.0f meters` at `%.0f, %.0f, %.0f` (%s)", playerid, amount, x, y, z, zone);
		}
		if(direction[0] == 'd')
		{
			z -= amount;
			log(DISCORD_CHANNEL_ADMINEVENTS, "[MOVE] `%p` moved DOWN `%.0f meters` at `%.0f, %.0f, %.0f` (%s)", playerid, amount, x, y, z, zone);
		}
		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Usage: /move [f/b/u/d] [optional:distance]");

	return 1;
}

ACMD:additem[3](playerid, params[])
{
	new
		ItemType:type = INVALID_ITEM_TYPE,
		itemname[ITM_MAX_NAME],
		exdata[8];

	if(sscanf(params, "p<,>dA<d>(-2147483648)[8]", _:type, exdata) != 0)
	{
		new tmp[ITM_MAX_NAME];

		if(sscanf(params, "p<,>s[32]A<d>(-2147483648)[8]", tmp, exdata))
		{
			ChatMsg(playerid, YELLOW, " >  Usage: /additem [itemid/itemname], [optional:extradata array, comma separated]");
			return 1;
		}

		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			GetItemTypeUniqueName(i, itemname);

			if(strfind(itemname, tmp, true) != -1)
			{
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
			for(new ItemType:i; i < ITM_MAX_TYPES; i++)
			{
				GetItemTypeName(i, itemname);

				if(strfind(itemname, tmp, true) != -1)
				{
					type = i;
					break;
				}
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
			ChatMsg(playerid, RED, " >  No items found matching: '%s'.", tmp);
			return 1;
		}
	}

	if(type == INVALID_ITEM_TYPE)
	{
		ChatMsg(playerid, RED, " >  Invalid item type: %d", _:type);
		return 1;
	}

	new
		exdatasize,
		typemaxsize = GetItemTypeArrayDataSize(type),
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		zone[MAX_ZONE_NAME];

	for(new i; i < 8; ++i)
	{
		if(exdata[i] != cellmin)
			++exdatasize;
	}

	if(exdatasize > typemaxsize)
		exdatasize = typemaxsize;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);
	GetPlayerZone(playerid, zone);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET, .rz = r);

	if(exdatasize > 0)
		SetItemArrayData(itemid, exdata, exdatasize);

	if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, response, listitem

			log(DISCORD_CHANNEL_ADMINEVENTS, DISCORD_MENTION_STAFF"[ITEM] `%p` added item `%s` at `%.0f, %.0f, %.0f` (%s). Reason: `%s`", playerid, itemname, x,y,z, zone, inputtext);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Justification", "Type a reason for adding this item:", "Enter", "");
	}
	else
		log(DISCORD_CHANNEL_ADMINEVENTS, "[ITEM] `%p` added item `%s` at `%.0f, %.0f, %.0f` (%s)", playerid, itemname, x,y,z, zone);

	return 1;
}

ACMD:addvehicle[3](playerid, params[])
{
	new
		type,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehicleid;

	if(isnumeric(params))
		type = strval(params);
	else
		type = GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type))
	{
		ChatMsg(playerid, YELLOW, " >  Invalid vehicle type (%s). (Specify by name or type)", params);
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetXYInFrontOfPlayer(playerid, x, y, 2.0);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateLootVehicle(type, x, y, z + 2.0, r + 90.0);
	SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	SetVehicleFuel(vehicleid, 100000.0);
	SetVehicleHealth(vehicleid, 990.0);
	SetVehicleDamageData(vehicleid, encode_panels(0, 0, 0, 0, 0, 0, 0), encode_doors(0, 0, 0, 0), encode_lights(0, 0, 0, 0), encode_tires(0, 0, 0, 0));
	SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
	SetVehicleTrunkLock(vehicleid, false);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused dialogid, response, listitem

		/*if(response)
			reason = inputtext;
		else
			reason = "None given";*/
		log(DISCORD_CHANNEL_ADMINEVENTS, "[VEHICLE] `%p` (`%.0f, %.0f, %.0f` - %s) added vehicle with ID `%d` (%s). Reason: `%s`", pid, x,y,z, GetPlayerZoneEx(playerid), type, GetVehicleName(vehicleid), inputtext);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Justification", "Type a reason for adding this vehicle:", "Enter", "");

	return 1;
}

ACMD:resetpassword[3](playerid, params[])
{
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /resetpassword [account user-name]");
		return 1;
	}

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
	{
		ChatMsg(playerid, YELLOW, " >  Password for '%s' reset. Tell the player to use /changepass on next login.", params);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[ACCOUNT] `%p` reset the password for `%s`.", playerid, params);
	}
	else
		ChatMsg(playerid, RED, " >  An error occurred.");

	return 1;
}

ACMD:setactive[3](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		active;

	if(sscanf(params, "s[24]d", name, active))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setactive [name] [1/0]");
		return 1;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, RED, " >  That account doesn't exist.");
		return 1;
	}

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " >  %s "C_BLUE"'%s' "C_YELLOW"account.", active ? ("Activated") : ("Deactivated"), name);

	return 1;
}

ACMD:delete[3](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) == STAFF_LEVEL_ADMINISTRATOR)
		return 6;

	new
		type[16],
		Float:range;

	if(sscanf(params, "s[16]F(1.5)", type, range))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences/signs] [optional:range(1.5)]");
		return 1;
	}

	if(range > 100.0)
	{
		ChatMsg(playerid, YELLOW, " >  Range limit: 100 metres");
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
			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyItem(i);
		}
		log(DISCORD_CHANNEL_ADMINEVENTS, "[ITEM] `%p` deleted all `items` within %.0f meters.", playerid, range);

		return 1;
	}
	else if(!strcmp(type, "tent", true, 4))
	{
		foreach(new i : tnt_Index)
		{
			GetTentPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyTent(i);
		}
		log(DISCORD_CHANNEL_ADMINEVENTS, "[ITEM] `%p` deleted all `tents` within %.0f meters.", playerid, range);

		return 1;
	}
	else if(!strcmp(type, "defence", true, 7))
	{
		foreach(new i : itm_Index)
		{
			if(GetItemTypeDefenceType(GetItemType(i)) == INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyItem(i);
		}
		log(DISCORD_CHANNEL_ADMINEVENTS, "[ITEM] `%p` deleted all `defences` within %.0f meters.", playerid, range);

		return 1;
	}
	ChatMsg(playerid, YELLOW, " >  Usage: /delete [items/tents/defences] [optional:range(1.5)]");

	return 1;
}
