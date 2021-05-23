#include <YSI\y_hooks>

enum
{
		CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
		CHAT_MODE_GLOBAL,		// 1 - Speak to all players
		CHAT_MODE_RADIO,		// 2 - Speak to players on the same radio frequency
		CHAT_MODE_ADMIN			// 3 - Speak to admins
}

new
		chat_Mode[MAX_PLAYERS],
Float:	chat_Freq[MAX_PLAYERS],
bool:	chat_Quiet[MAX_PLAYERS],
		chat_MessageStreak[MAX_PLAYERS],
		chat_LastMessageTick[MAX_PLAYERS];

forward Float:GetPlayerRadioFrequency(playerid);
forward OnPlayerSendChat(playerid, text[], Float:frequency);

hook OnPlayerConnect(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/chat.pwn");

	chat_LastMessageTick[playerid] = 0;
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	dbg("global", LOG_CORE, "[OnPlayerText] in /gamemodes/sss/core/player/chat.pwn");

	if(IsPlayerInTutorial(playerid))
	{
		ChatMsg(playerid, RED, "> Help? Join http://chat.viruxe.party");
		return 0;
	}

	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");
		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 1000)
		{
			chat_MessageStreak[playerid]++;
			if(chat_MessageStreak[playerid] == 3)
			{
				TogglePlayerMute(playerid, true, 30);
				ChatMsgLang(playerid, RED, "MUTEDFLOODM");
				return 0;
			}
		}
		else
		{
			if(chat_MessageStreak[playerid] > 0)
				chat_MessageStreak[playerid]--;
		}
	}

	chat_LastMessageTick[playerid] = GetTickCount();

	if(chat_Mode[playerid] == CHAT_MODE_LOCAL)
		PlayerSendChat(playerid, text, 0.0);

	if(chat_Mode[playerid] == CHAT_MODE_GLOBAL)
		PlayerSendChat(playerid, text, 1.0);

	if(chat_Mode[playerid] == CHAT_MODE_ADMIN)
		PlayerSendChat(playerid, text, 3.0);

	if(chat_Mode[playerid] == CHAT_MODE_RADIO)
		PlayerSendChat(playerid, text, chat_Freq[playerid]);

	return 0;
}

PlayerSendChat(playerid, chat[], Float:frequency)
{
	if(!IsPlayerLoggedIn(playerid))
		return 0;

	if(IsPlayerInTutorial(playerid))
	{
		ChatMsg(playerid, RED, "> Help? Join http://chat.viruxe.party");
		return 0;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 1000) // ??
		return 0;

	if(CallLocalFunction("OnPlayerSendChat", "dsf", playerid, chat, frequency))
		return 0;

	new
		line1[256],
		line2[128],
		tmpChat[256];

	tmpChat = TagScan(chat);

	if(frequency == 0.0)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Local] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			tmpChat);

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		SetPlayerChatBubble(playerid, tmpChat, WHITE, 40.0, 10000);

		log(DISCORD_CHANNEL_INVALID, "[CHAT][LOCAL] '%p': `%s` (%s `%.0f,%.0f,%.0f`)", playerid, tmpChat, GetPlayerZoneEx(playerid), x,y,z);
		log(DISCORD_CHANNEL_LOCAL, "(%d) `%p` says: `%s` (%s `%.0f,%.0f,%.0f`)", playerid, playerid, tmpChat, GetPlayerZoneEx(playerid), x,y,z);

		return 1;
	}
	else if(frequency == 1.0)
	{
		format(line1, 256, "[Global] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			tmpChat);

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(chat_Quiet[i])
				continue;

			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2))
				SendClientMessage(i, WHITE, line2);
		}

		log(DISCORD_CHANNEL_INVALID, "[CHAT][GLOBAL] '%p' says: %s", playerid, tmpChat);
		DiscordMessage(DISCORD_CHANNEL_GLOBAL, "(%d) `%p` says: `%s`", playerid, playerid, tmpChat);

		return 1;
	}
	else if(frequency == 2.0)
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Me] %P %s",
			playerid,
			tmpChat);

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z))
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		SetPlayerChatBubble(playerid, tmpChat, CHAT_LOCAL, 40.0, 10000);
		log(DISCORD_CHANNEL_LOCAL, "[CHAT][LOCALME] `%p`: %s", playerid, tmpChat);

		return 1;
	}
	else if(frequency == 3.0)
	{
		format(line1, 256, "%C[Admin] (%d) %P"C_WHITE": %s",
			GetAdminRankColour(GetPlayerAdminLevel(playerid)),
			playerid,
			playerid,
			tmpChat);

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) > 0)
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		log(DISCORD_CHANNEL_INVALID, "[CHAT][ADMIN] '%p': %s", playerid, tmpChat);
		DiscordMessage(DISCORD_CHANNEL_ADMIN, "(%d) `%p` says: `%s`", playerid, playerid, tmpChat);

		return 1;
	}
	else
	{
		format(line1, 256, "[%.2f] (%d) %P"C_WHITE": %s",
			frequency,
			playerid,
			playerid,
			tmpChat);

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(-0.05 < frequency - chat_Freq[i] < 0.05)
			{
				SendClientMessage(i, CHAT_RADIO, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_RADIO, line2);
			}
		}

		format(line1, sizeof(line1), "* %s *", chat);

		SetPlayerChatBubble(playerid, TagScan(line1), CHAT_RADIO, 40.0, 10000);

		log(DISCORD_CHANNEL_INVALID, "[CHAT][RADIO][%.2f] '%p': %s", frequency, playerid, tmpChat);
		DiscordMessage(DISCORD_CHANNEL_RADIO, "[`%.2f`] `%p` says: %s", frequency, playerid, tmpChat);

		return 1;
	}
}

stock GetPlayerChatMode(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return chat_Mode[playerid];
}

stock SetPlayerChatMode(playerid, chatmode)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	chat_Mode[playerid] = chatmode;

	return 1;
}

stock IsPlayerGlobalQuiet(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return chat_Quiet[playerid];
}

stock Float:GetPlayerRadioFrequency(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return chat_Freq[playerid];
}
stock SetPlayerRadioFrequency(playerid, Float:frequency)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	chat_Freq[playerid] = frequency;

	return 1;
}

CMD:g(playerid, params[])
{
	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");
		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 7;
	}

	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);
		ChatMsgLang(playerid, WHITE, "RADIOGLOBAL");
	}
	else
		PlayerSendChat(playerid, params, 1.0);

	return 7;
}

CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		ChatMsgLang(playerid, WHITE, "RADIOLOCAL");
	}
	else
		PlayerSendChat(playerid, params, 0.0);

	return 7;
}

CMD:me(playerid, params[])
{
	PlayerSendChat(playerid, params, 2.0);

	return 1;
}

CMD:r(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_RADIO);
		ChatMsgLang(playerid, WHITE, "RADIOFREQUN", chat_Freq[playerid]);
	}
	else
		PlayerSendChat(playerid, params, chat_Freq[playerid]);

	return 7;
}

CMD:quiet(playerid, params[])
{
	if(chat_Quiet[playerid])
	{
		chat_Quiet[playerid] = false;
		ChatMsgLang(playerid, WHITE, "RADIOQUIET0");
	}
	else
	{
		chat_Quiet[playerid] = true;
		ChatMsgLang(playerid, WHITE, "RADIOQUIET1");
	}

	return 1;
}

ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_ADMIN);
		ChatMsgLang(playerid, WHITE, "RADIOADMINC");
	}
	else
		PlayerSendChat(playerid, params, 3.0);

	return 7;
}
