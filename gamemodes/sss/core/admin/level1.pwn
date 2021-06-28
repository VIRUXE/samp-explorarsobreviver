/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/mute - Silenciar ou tirar do Silêncio\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/avisar - Avisar um Jogador\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/kick - Kickar um Jogador\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/anuncio - Enviar um Anúncio para todos\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/(all)country - Mostrar dados do País\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/limparchat - Çimpar o Chat para todos\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/aliases - check aliases\n");
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "/history - Verificar história do Jogador?\n");
}


/*==============================================================================

	Mute a player for some seconds or forever (saves to their account)

==============================================================================*/


ACMD:mute[1](playerid, params[])
{
	new
		targetid,
		delay,
		reason[128];

	sscanf(params, "dds[128]", targetid, delay, reason);

	if(!targetid)
		return ChatMsg(playerid,YELLOW," >  Utilização: /mute [id] ([segundos (utilize -1 se desejar que fique permanente)] [razão])");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  ID Inválido");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return 3;

	if(!IsPlayerMuted(targetid))
	{
		if(delay > 0)
		{
			TogglePlayerMute(targetid, true, delay);
			ChatMsg(playerid, YELLOW, " >  Silenciou o Jogador %P "C_WHITE"por %d segundos.", targetid, delay);
			ChatMsgLang(targetid, YELLOW, "MUTEDANTIME", delay, reason);
		}
		else
		{
			TogglePlayerMute(targetid, true);
			ChatMsg(playerid, YELLOW, " >  Silenciou o Jogador %P", targetid);
			ChatMsgLang(targetid, YELLOW, "MUTEDREASON", reason);
		}
	}
	else
	{
		TogglePlayerMute(targetid, false);
		ChatMsg(playerid, YELLOW, " >  Tirou %P do Silencio", targetid);
		ChatMsgLang(targetid, YELLOW, "MUTEDUNMUTE");
	}

	return 1;
}

/*==============================================================================

	Warn a player for misconduct

==============================================================================*/


ACMD:avisar[1](playerid, params[])
{
	new
		targetid,
		reason[128];

	if(sscanf(params, "ds[128]", targetid, reason))
		return ChatMsg(playerid, YELLOW, " >  Utilização: /avisar [id] [razão]");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  ID Inválido");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" foi avisado por: %s", targetid, reason);
	ChatMsgLang(targetid, ORANGE, "WARNEDMESSG", reason);

	return 1;
}


/*==============================================================================

	Kick a player from the server so they must rejoin

==============================================================================*/


ACMD:kick[1](playerid, params[])
{
	new
		targetid,
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin))
			highestadmin = i;
	}

	if(sscanf(params, "ds[64]", targetid, reason))
		return ChatMsg(playerid, YELLOW, " >  Utilização: /kick [id] [razão]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin))
		return ChatMsg(highestadmin, YELLOW, " >  %p requisição para Kickar: (%d)%p Razão: %s", playerid, targetid, targetid, reason);

	if(playerid == targetid)
		ChatMsgAll(PINK, " >  %P"C_PINK" viado burro kickou ele próprio", playerid);

	KickPlayer(targetid, reason);

	return 1;
}


/*==============================================================================

	Output a non-player chat box message to all players in the server

==============================================================================*/


ACMD:anuncio[1](playerid, params[])
{
	if(!(0 < strlen(params) < 128))
		ChatMsg(playerid,YELLOW," >  Utilização: /anuncio [mensagem]");

	new str[130] = {" >  "C_BLUE""};

	strcat(str, TagScan(params));

	ChatMsgAll(YELLOW, str);
	return 1;
}


/*==============================================================================

	Display player countries

==============================================================================*/


ACMD:country[1](playerid, params[])
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

		new data[256];

		GetPlayerCountryDataAsString(targetid, data);

		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "IP Data", data, "Sair", "");
	}
	else
	{
		if(!AccountExists(params))
		{
			ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", params);
			return 1;
		}

		new
			ipint,
			// ipstr[17],
			country[32];

		GetAccountIP(params, ipint);
		// TODO: Use a different country service
		// ipstr = IpIntToStr(ipint);
		// GetIPCountry(ipstr, country);

		ChatMsg(playerid, YELLOW, " >  "C_BLUE"%s"C_YELLOW"'s GeoIP location: "C_BLUE"%s", params, country);
	}

	return 1;
}

ACMD:allcountry[1](playerid, params[])
{
	new
		country[32],
		list[(MAX_PLAYER_NAME + 3 + 32 + 1) * MAX_PLAYERS];

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(playerid))
			country = "Desconhecido";
		else
			GetPlayerCachedCountryName(i, country);

		format(list, sizeof(list), "%s%p - %s\n", list, i, country);
	}

	Dialog_Show(playerid, DIALOG_STYLE_LIST, "Países", list, "Sair", "");

	return 1;
}


/*==============================================================================

	Clear the chat box

==============================================================================*/


ACMD:clearchat[1](playerid, params[])
{
	for(new i;i<100;i++)
		ChatMsgAll(WHITE, " ");

	return 1;
}
ACMD:limparchat[1](playerid, params[]) return acmd_clearchat_1(playerid, params);

/*==============================================================================

	Display a player's aliases (other accounts they have used)

==============================================================================*/


ACMD:aliases[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type;

	if(sscanf(params, "s[24]C(a)", name, type))
	{
		ChatMsg(playerid, YELLOW, " >  Utilização: /aliases [playerid/name] [i/p/h/a]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);
		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  No aliases found for %s", name);
			return 1;
		}
	}

	new
		ret,
		list[32][MAX_PLAYER_NAME],
		count,
		adminlevel;

	if(type == 'a')
		ret = GetAccountAliasesByAll(name, list, count, 32, adminlevel);
	else if(type == 'i')
		ret = GetAccountAliasesByIP(name, list, count, 32, adminlevel);
	else if(type == 'p')
		ret = GetAccountAliasesByPass(name, list, count, 32, adminlevel);
	else if(type == 'h')
		ret = GetAccountAliasesByHash(name, list, count, 32, adminlevel);
	else
	{
		ChatMsg(playerid, YELLOW, " >  Lookup type must be one of: 'i'(ip) 'p'(password) 'h'(hash) 'a'(all)");
		return 1;
	}

	if(ret == 0)
	{
		ChatMsg(playerid, RED, " >  An error occurred.");
		return 1;
	}

	if(count == 0 || adminlevel > GetPlayerAdminLevel(playerid))
	{
		ChatMsg(playerid, YELLOW, " >  No aliases found for %s", name);
		return 1;
	}

	ShowPlayerList(playerid, list, (count > 32) ? 32 : count, true);

	return 1;
}

ACMD:history[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type,
		lookup;

	if(sscanf(params, "s[24]C(a)C()", name, type, lookup))
	{
		ChatMsg(playerid, YELLOW, " >  Utilização: /history [playerid/name] [i/h] [n]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);
		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  Numeric value '%d' isn't a player ID that is currently online, treating it as a name.", targetid);
		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  The account '%s' does not exist.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  No aliases found for %s", name);
			return 1;
		}
	}

	if(type == 'i')
	{
		if(lookup == 'n')
			ShowAccountIPHistoryFromName(playerid, name);
		else
		{
			new ip;
			GetAccountIP(name, ip);
			ShowAccountIPHistoryFromIP(playerid, ip);
		}
	}
	else if(type == 'h')
	{
		if(lookup == 'n')
			ShowAccountGpciHistoryFromName(playerid, name);
		else
		{
			new hash[MAX_GPCI_LEN];
			GetAccountGPCI(name, hash);
			ShowAccountGpciHistoryFromGpci(playerid, hash);
		}
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Lookup type must be one of: 'i'(ip) 'h'(hash), optional parameter 'n' lists the history for that player only.");
		return 1;
	}

	return 1;
}
