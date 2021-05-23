#include <YSI\y_hooks>

hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/duty - go on admin duty\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/goto, /get - teleport players\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/gotopos - go to coordinates\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/(un)freeze - freeze/unfreeze player\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/(un)ban - ban/unban player\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/banlist - show list of bans\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/banned - check if banned\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/setmotd - set message of the day\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/field - manage detection fields\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/freezecam - no idea yet\n");
}

ACMD:duty[2](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		ChatMsg(playerid, YELLOW, " >  You cannot do that while spectating.");
		return 1;
	}

	new bool:here;

	if(!strcmp(params, "here"))
		here = true;
	else
		here = false;

	TogglePlayerAdminDuty(playerid, .exitAtSameLocation = here);

	return 1;
}

ACMD:goto[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /goto [target]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	if(targetid == playerid)
		return 0;

	TeleportPlayerToPlayer(playerid, targetid);

	ChatMsg(playerid, YELLOW, " >  You have teleported to %P", targetid);
	ChatMsgLang(targetid, YELLOW, "TELEPORTEDT", playerid);
	DiscordMessage(DISCORD_CHANNEL_ADMINEVENTS, "[TELEPORT] `%p` (%s) teleported to `%p` (%s).", playerid, GetPlayerZoneEx(playerid), targetid, GetPlayerZoneEx(targetid));

	return 1;
}

ACMD:get[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /get [target]");
		return 1;
	}

	if(targetid == playerid)
		return 1;

	if(!IsPlayerConnected(targetid))
		return 4;

	new 
		Float:x, 
		Float:y, 
		Float:z;

	GetPlayerPos(targetid, x,y,z);

	TeleportPlayerToPlayer(targetid, playerid);

	ChatMsg(playerid, YELLOW, " >  You have teleported %P", targetid);
	ChatMsgLang(targetid, YELLOW, "TELEPORTEDY", playerid);
	DiscordMessage(DISCORD_CHANNEL_ADMINEVENTS, "[TELEPORT] `%p` (%s) teleported `%p` from `%.0f, %.0f, %.0f` (%s) to him.", playerid, GetPlayerZoneEx(playerid), targetid, x,y,z, GetPlayerZoneEx(targetid));

	return 1;
}

ACMD:gotopos[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:px,
		Float:py,
		Float:pz;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return ChatMsg(playerid, YELLOW, "Usage: /gotopos x, y, z (With or without commas)");

	GetPlayerPos(playerid, px,py,pz);
	SetPlayerPos(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, " >  Teleported to %f, %f, %f", x, y, z);
	DiscordMessage(DISCORD_CHANNEL_ADMINEVENTS, "[TELEPORT] `%p` (`%.0f, %.0f, %.0f` %s) teleported to `%.0f, %.0f, %.0f`", playerid, px,py,pz, GetPlayerZoneEx(playerid), x,y,z);

	return 1;
}

ACMD:freeze[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay))
		return ChatMsg(playerid, YELLOW, " >  Usage: /freeze [playerid] (seconds)");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0)
	{
		ChatMsg(playerid, YELLOW, " >  Frozen %P for %d seconds", targetid, delay);
		ChatMsgLang(targetid, YELLOW, "FREEZETIMER", delay);
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Frozen %P (performing 'mod_sa' check)", targetid);
		ChatMsgLang(targetid, YELLOW, "FREEZEFROZE");
	}
	DiscordMessage(DISCORD_CHANNEL_ADMINEVENTS, "[FREEZE] `%p` froze `%p` for %d seconds", playerid, targetid, delay);

	return 1;
}

ACMD:unfreeze[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return ChatMsg(playerid, YELLOW, " >  Usage: /unfreeze [playerid]");

	if(!IsPlayerConnected(targetid))
		return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Unfrozen %P", targetid);
	ChatMsgLang(targetid, YELLOW, "FREEZEUNFRE");
	DiscordMessage(DISCORD_CHANNEL_ADMINEVENTS, "[FREEZE] `%p` unfroze `%p`", playerid, targetid);

	return 1;
}

ACMD:ban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /ban [playerid/name]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);
		else
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE)
		return 2;

	BanAndEnterInfo(playerid, name);

	ChatMsg(playerid, YELLOW, " >  Preparing ban for %s", name);

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
		return ChatMsg(playerid, YELLOW, " >  Usage: /unban [player name]");

	if(UnBanPlayer(name))
	{
		ChatMsg(playerid, YELLOW, " >  Unbanned "C_BLUE"%s"C_YELLOW".", name);
		DiscordMessage(DISCORD_CHANNEL_GLOBAL, "`%p` unbanned `%s`.", playerid, name);
	}
	else
		ChatMsg(playerid, YELLOW, " >  Player '%s' is not banned.");

	return 1;
}

ACMD:banlist[2](playerid, params[])
{
	new ret = ShowListOfBans(playerid, 0);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  No bans to list.");

	if(ret == -1)
		ChatMsg(playerid, YELLOW, " >  An error occurred while executing 'stmt_BanGetList'.");

	return 1;
}

ACMD:banned[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		ChatMsg(playerid, RED, " >  Invalid player name '%s'.", params);
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);
	else
		ChatMsg(playerid, YELLOW, " >  Player '%s' "C_BLUE"isn't "C_YELLOW"banned.", name);

	return 1;
}

ACMD:setmotd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setmotd [message]");
		return 1;
	}

	ChatMsgAll(YELLOW, " >  MOTD updated: "C_BLUE"%s", gMessageOfTheDay);
	DiscordMessage(DISCORD_CHANNEL_GLOBAL, "`%p` set the MoTD to `%s`.", playerid, gMessageOfTheDay);

	return 1;
}