
/*==============================================================================

	Lazy RCON commands

==============================================================================*/


ACMD:serverpass[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," » Usage: /serverpass [password]");

	new str[74];
	format(str, sizeof(str), "password %s", params);
	SendRconCommand(str);

	ChatMsg(playerid, YELLOW, " » Server password set to "C_BLUE"%s", params);

	return 1;
}

ACMD:gamename[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," » Usage: /gamename [name]");

	SetGameModeText(params);
	ChatMsg(playerid, YELLOW, " » GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," » Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	ChatMsg(playerid, YELLOW, " » Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid,YELLOW," » Usage: /mapname [name]");

	new str[74];
	format(str, sizeof(str), "mapname %s", params);
	SendRconCommand(str);

	return 1;
}

ACMD:gmx[5](playerid, params[])
{
	RestartGamemode();
	return 1;
}

ACMD:loadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid, YELLOW, " » Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " » Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid, YELLOW, " » Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " » Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64))
		return ChatMsg(playerid, YELLOW, " » Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " » Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}


/*==============================================================================

	Testing stuff

==============================================================================*/


ACMD:nametags[5](playerid, params[])
{
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	ChatMsg(playerid, YELLOW, " » Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

	return 1;
}

ACMD:gotoitem[4](playerid, params[])
{
	new
		Item:itemid = Item:strval(params),
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:addloot[5](playerid, params[])
{
	new
		lootindexname[MAX_LOOT_INDEX_NAME],
		lootindex,
		size;

	if(sscanf(params, "s[32]d", lootindexname, size))
	{
		ChatMsg(playerid, YELLOW, " » Usage: /addloot [indexname] [size]");
		return 1;
	}

	lootindex = GetLootIndexFromName(lootindexname);

	if(lootindex == -1)
	{
		ChatMsg(playerid, RED, " » Loot index name invalid!");
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	CreateLootItem(lootindex, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
	//CreateStaticLootSpawn(x, y, z - 0.8568, lootindex, 100, size, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

	return 1;
}

ACMD:setitemhp[5](playerid, params[])
{
	new
		Item:itemid,
		hitpoints;

	if(sscanf(params, "dd", _:itemid, hitpoints))
	{
		ChatMsg(playerid, YELLOW, " » Usage: /setitemhp [itemid] [hitpoints]");
		return 1;
	}

	SetItemHitPoints(itemid, hitpoints);

	return 1;
}


/*==============================================================================

	Dev-"cheats"

==============================================================================*/


ACMD:vw[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Virtual World Actual: %d", GetPlayerVirtualWorld(playerid));
	else
		SetPlayerVirtualWorld(playerid, strval(params));

	return 1;
}

ACMD:int[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Interior Actual: %d", GetPlayerInterior(playerid));
	else
		SetPlayerInterior(playerid, strval(params));

	return 1;
}

ACMD:health[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Vida %f", GetPlayerHP(playerid));
		return 1;
	}

	SetPlayerHP(playerid, value);
	ChatMsg(playerid, YELLOW, "Set health to %f", value);

	return 1;
}

ACMD:food[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Current food %f", GetPlayerFP(playerid));
		return 1;
	}

	SetPlayerFP(playerid, value);
	ChatMsg(playerid, YELLOW, "Set food to %f", value);

	return 1;
}

ACMD:bleed[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		GetPlayerBleedRate(playerid, value);
		ChatMsg(playerid, YELLOW, "Current bleed rate %f", value);
		return 1;
	}

	SetPlayerBleedRate(playerid, value);
	ChatMsg(playerid, YELLOW, "Set bleed rate to %f", value);

	return 1;
}

ACMD:knockout[5](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Set knockout time to %d", strval(params));
	return 1;
}

ACMD:showdamage[5](playerid, params[])
{
	new Float:bleedrate;
	GetPlayerBleedRate(playerid, bleedrate);
	ShowActionText(playerid, sprintf("bleedrate: %f~n~wounds: %d", bleedrate, GetPlayerWounds(playerid)), 5000);
	return 1;
}

ACMD:removewounds[5](playerid, params[])
{
	RemovePlayerWounds(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Removed %d wounds.", strval(params));
	return 1;
}

ACMD:wc[5](playerid, params[])
{
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	WeaponsCacheDrop(x, y, z - 0.8);
	SetPlayerPos(playerid, x, y, z + 1.0);

	return 1;
}

ACMD:setskill[5](playerid, params[])
{
	new
		skill[32],
		Float:amount;

	sscanf(params, "s[32]f", skill, amount);

	PlayerGainSkillExperience(playerid, skill, amount);

	return 1;
}

ACMD:editatt[5](playerid, params[])
{
	EditAttachedObject(playerid, 0);
	return 1;
}

public OnPlayerEditAttachedObject( playerid, response, index, modelid, boneid,
                                   Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ,
                                   Float:fRotX, Float:fRotY, Float:fRotZ,
                                   Float:fScaleX, Float:fScaleY, Float:fScaleZ )
{
    new debug_string[256+1];
	format(debug_string,256,"SetPlayerAttachedObject(playerid,%d,%d,%d,%f,%f,%f,%f,%f,%f,%f,%f,%f)",
           index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);

	print(debug_string);
    SendClientMessage(playerid, 0xFFFFFFFF, debug_string);
    
    SetPlayerAttachedObject(playerid,index,modelid,boneid,fOffsetX,fOffsetY,fOffsetZ,fRotX,fRotY,fRotZ,fScaleX,fScaleY,fScaleZ);
    SendClientMessage(playerid, 0xFFFFFFFF, "You finished editing an attached object");
    
    return 1;
}