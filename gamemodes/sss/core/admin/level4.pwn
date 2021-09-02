#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/restart - restart the server\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/setadmin - set a player's staff level\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/setvip - set a player's vip level\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/weather - set weather\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/debug - activate a debug handler\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/sifdebug - activate SIF debug\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/sifgdebug - activate SIF global debug\n");
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "/dbl - toggle debug labels\n");
}


/*==============================================================================

	"Secret" RCON self-admin level command

==============================================================================*/


CMD:adminlvl(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new level;

	if(sscanf(params, "d", level))
		return ChatMsg(playerid, YELLOW, " » Usage: /adminlvl [level]");

	if(!SetPlayerAdminLevel(playerid, level))
		return ChatMsg(playerid, RED, " » Admin level must be equal to or between 0 and 4");

	ChatMsg(playerid, YELLOW, " » Admin Level Secretly Set To: %d", level);

	return 1;
}


/*==============================================================================

	"Secret" RCON self-admin level command

==============================================================================*/


ACMD:restart[4](playerid, params[])
{
	new duration;

	if(sscanf(params, "d", duration))
	{
		ChatMsg(playerid, YELLOW, " » Usage: /restart [seconds] - Always give players 5 or 10 minutes to prepare.");
		return 1;
	}

	ChatMsg(playerid, YELLOW, " » Reiniciando em "C_BLUE"%02d:%02d"C_YELLOW".", duration / 60, duration % 60);
	SetRestart(duration);

	return 1;
}
ACMD:rr[4](playerid, params[])
{
	SetRestart(0);
	return 1;
}


/*==============================================================================

	Set a player's admin level

==============================================================================*/


ACMD:setadmin[4](playerid, params[])
{
	new
		id,
		name[MAX_PLAYER_NAME],
		level;

	if(!sscanf(params, "dd", id, level))
	{
		if(playerid == id)
			return ChatMsg(playerid, RED, " » You cannot set your own level");

		if(!IsPlayerConnected(id))
			return 4;

		if(!SetPlayerAdminLevel(id, level))
			return ChatMsg(playerid, RED, " » Admin level must be equal to or between 0 and 3");

		ChatMsg(playerid, YELLOW, " » You made %P a Level %d Admin", id, level);
		ChatMsg(id, YELLOW, " » %P Made you a Level %d Admin", playerid, level);
	}
	else if(!sscanf(params, "s[24]d", name, level))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(!strcmp(name, playername))
			return ChatMsg(playerid, RED, " » You cannot set your own level");

		UpdateAdmin(name, level);

		ChatMsg(playerid, YELLOW, " » You set %s to admin level %d.", name, level);
	}
	else
		ChatMsg(playerid, YELLOW, " » Usage: /setadmin [playerid] [level]");

	return 1;
}

ACMD:setscore[4](playerid, params[])
{
	new targetid, score;

	if(sscanf(params, "dd", targetid, score))
		return ChatMsg(playerid, YELLOW, " » Usage: /setscore [playerid] [score]");

	if(!IsPlayerConnected(targetid))
		return 4;

	SetPlayerScore(targetid, score);
	ChatMsg(playerid, YELLOW, " » Definiu o score de %p para %d", targetid, score);

	return 1;
}


/*==============================================================================

	Utility commands

==============================================================================*/

ACMD:weather[4](playerid, params[])
{
	gBigString[playerid][0] = EOS;

	for(new i; i < sizeof(WeatherData); i++)
	{	
		strcat(gBigString[playerid], WeatherData[i][weather_name]);
		strcat(gBigString[playerid], "\n");
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext
		if(response)
		{
			foreach(new j : Player)
				SetPlayerWeather(j, listitem);

			SetGlobalWeather(listitem);
			ChatMsgAdmins(GetPlayerAdminLevel(playerid), YELLOW, " » Weather set to "C_BLUE"%s(%d)"C_YELLOW" by %p", WeatherData[listitem], listitem, playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Set Global Weather", gBigString[playerid], "Set", "Cancel");

	return 1;
}


/*==============================================================================

	Debug stuff (SIF mostly)

==============================================================================*/


ACMD:debug[4](playerid, params[])
{
	new
		handlername[32],
		level;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		ChatMsg(playerid, YELLOW, " » Usage: /debug [handlername] [level]");
		return 1;
	}

	debug_set_level(handlername, level);

	ChatMsg(playerid, YELLOW, " » SS debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:dbl[3](playerid, params[])
{
	#if defined SIF_USE_DEBUG_LABELS
		if(IsPlayerToggledAllDebugLabels(playerid))
		{
			HideAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " » Debug labels toggled off.");
		}
		else
		{
			ShowAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " » Debug labels toggled on.");
		}
	#else
		ChatMsg(playerid, YELLOW, " » Debug labels are not compiled.");
	#endif

	return 1;
}