#include <YSI_Coding\y_hooks>

hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/adm - Entrar em Modo de Administração\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/goto, /get - Teleportar Jogadores\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/gotopos - go to coordinates\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/cong - (Des)Congelar Jogadores\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/(un)ban - (Des)Banir Jogadores\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/bans - Visualizar lista de Bans\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/banido - Verificar se um Jogador está banido\n");
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "/defmdd - Definir Mensagem do Dia\n");
}


/*==============================================================================

	Enter admin duty mode, disabling normal gameplay mechanics

==============================================================================*/
ACMD:adm[2](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		ChatMsg(playerid, YELLOW, " » Não pode entrar em Modo de Admin enquanto está em Spectate.");
		return 1;
	}
	
	if(!TogglePlayerAdminDuty(playerid, !IsPlayerOnAdminDuty(playerid), strcmp(params, "aqui", true, 4)))
		ChatMsg(playerid, YELLOW, " » Aguarde para usar o modo admin.");

	return 1;
}


/*==============================================================================

	Teleport players to other players or yourself to 

==============================================================================*/


ACMD:goto[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /goto [id]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	if(TeleportPlayerToPlayer(playerid, targetid))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		ChatMsg(playerid, YELLOW, " » Você teleportou para %P", targetid);
		ChatMsgLang(targetid, YELLOW, "TELEPORTEDT", playerid);
	}
	else
		ChatMsg(playerid, RED, " » Não foi possível teleportar para %P", targetid);

	return 1;
}

ACMD:get[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /get [id]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(targetid, playerid);

	ChatMsg(playerid, YELLOW, " » Você teleportou %P para si", targetid);
	ChatMsgLang(targetid, YELLOW, "TELEPORTEDY", playerid);

	return 1;
}


/*==============================================================================

	Teleport to a specific position

==============================================================================*/


ACMD:gotopos[2](playerid, params[])
{
	new Float:x, Float:y, Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return ChatMsg(playerid, YELLOW, "Utilização: /gotopos x, y, z (Com ou sem virgulas)");

	ChatMsg(playerid, YELLOW, " » Teleportado para %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}


/*==============================================================================

	Freeze a player for questioning/investigation

==============================================================================*/


ACMD:freeze[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay))
		return ChatMsg(playerid, YELLOW, " » Utilização: /cong [id] (seconds)");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	if(!IsPlayerFrozen(targetid))
	{
		FreezePlayer(targetid, SEC(delay), true);
			
		if(delay > 0)
		{
			ChatMsg(playerid, YELLOW, " » Congelou %P por %d segundos", targetid, delay);
			ChatMsgLang(targetid, YELLOW, "FREEZETIMER", delay);
		}
		else
		{
			ChatMsg(playerid, YELLOW, " » Congelou %P", targetid);
			ChatMsgLang(targetid, YELLOW, "FREEZEFROZE");
		}
	}
	else
	{
		UnfreezePlayer(targetid);

		ChatMsg(playerid, YELLOW, " » Descongelou %P", targetid);
		ChatMsgLang(targetid, YELLOW, "FREEZEUNFRE");
	}

	return 1;
}
ACMD:cong[2](playerid, params[]) return acmd_freeze_2(playerid, params);

/*==============================================================================

	Ban a player from the server for a set time or forever

==============================================================================*/


ACMD:ban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /ban [id/nick]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else
			ChatMsg(playerid, YELLOW, " » Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " » The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE)
		return 2;

	BanAndEnterInfo(playerid, name);

	ChatMsg(playerid, YELLOW, " » Preparing ban for %s", name);

	return 1;
}

ACMD:unban[2](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
		return ChatMsg(playerid, YELLOW, " » Utilização: /unban [player name]");

	if(UnBanPlayer(name))
		ChatMsg(playerid, YELLOW, " » Unbanned "C_BLUE"%s"C_YELLOW".", name);

	else
		ChatMsg(playerid, YELLOW, " » Player '%s' is not banned.");

	return 1;
}


/*==============================================================================

	Show the list of banned players and check if someone is banned

==============================================================================*/


ACMD:bans[2](playerid, params[])
{
	new ret = ShowListOfBans(playerid, 0);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " » Não existem bans.");

	if(ret == -1)
		ChatMsg(playerid, YELLOW, " » An error occurred while executing 'stmt_BanGetList'.");

	return 1;
}

ACMD:banido[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		ChatMsg(playerid, RED, " » Nome de Jogador Inválido '%s'.", params);
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);
	else
		ChatMsg(playerid, YELLOW, " » Jogador '%s' "C_BLUE"não está "C_YELLOW"banido.", name);

	return 1;
}


/*==============================================================================

	Set the message of the day

==============================================================================*/


ACMD:defmdd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		ChatMsg(playerid, YELLOW, " » Utilização: /defmdd [mensagem]");
		return 1;
	}

	ChatMsgAll(YELLOW, " » Mensagem do Dia é Agora: "C_BLUE"%s", gMessageOfTheDay);

	return 1;
}