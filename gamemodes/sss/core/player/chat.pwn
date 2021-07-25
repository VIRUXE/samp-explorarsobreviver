#include <YSI_Coding\y_hooks>

// Chat modes
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
	chat_LastMessageTick[playerid] = 0;
	chat_Freq[playerid] = 0.0;
	chat_Mode[playerid] = 0;
	return 1;
}

hook OnPlayerText(playerid, text[])
{
	new Float:freq = chat_Freq[playerid];

	switch(chat_Mode[playerid])
	{
		case CHAT_MODE_LOCAL:
			freq = 0.0;
		case CHAT_MODE_GLOBAL:
			freq = 1.0;
		case CHAT_MODE_ADMIN:
			freq = 3.0;
	}
	PlayerSendChat(playerid, text, freq);

	return 0;
}

stock ClearChatForPlayer(playerid, lines)
{
	for(new i; i < lines; i++)
		SendClientMessage(playerid, -1, "");
}

stock ClearChatForAllPlayers(lines)
{
	for(new i; i < lines; i++)
		SendClientMessageToAll(-1, "");
}

stock PlayerSendChat(playerid, chat[], Float:frequency)
{
	if(isnull(chat))
		return 0;
		
	if(!IsPlayerLoggedIn(playerid))
		return 0;

	if(!IsPlayerWhitelisted(playerid))
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < SEC(1))
		return 0;

	if(CallLocalFunction("OnPlayerSendChat", "dsf", playerid, chat, frequency))
		return 0;

	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");
		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(SEC(GetPlayerMuteRemainder(playerid)), "%1h:%1m:%1s"));

		return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < SEC(1) && !GetPlayerAdminLevel(playerid))
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

	if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 4500 && frequency == 1.0 && !GetPlayerAdminLevel(playerid))
	{
		ChatMsgLang(playerid, RED, "GLOBALFLOOD");
		return 0;
	}

	chat_LastMessageTick[playerid] = GetTickCount();

	new
		line1[256],
		line2[128];

	if(frequency == 0.0)
	{
		log(false, "[CHAT][LOCAL] [%p]: %s", playerid, chat);

		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Local] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			TagScan(chat));

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

		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
	else if(frequency == 1.0)
	{
		log(false, "[CHAT][GLOBAL] [%p]: %s", playerid, chat);

		format(line1, 256, "[Global] (%d) %P"C_WHITE": %s",
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(chat_Quiet[i])
				continue;

			if(IsPlayerInTutorial(i))
				continue;
				
			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2))
				SendClientMessage(i, WHITE, line2);
		}

		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
	else if(frequency == 2.0)
	{
		log(false, "[CHAT][LOCALME] [%p]: %s", playerid, chat);

		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[Local] %P %s",
			playerid,
			TagScan(chat));

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

		SetPlayerChatBubble(playerid, TagScan(chat), CHAT_LOCAL, 40.0, 10000);

		return 1;
	}
	else if(frequency == 3.0)
	{
		log(false, "[CHAT][ADMIN] [%p]: %s", playerid, chat);

		format(line1, 256, "%C[Admin] (%d) %P"C_WHITE": %s",
			GetAdminRankColour(GetPlayerAdminLevel(playerid)),
			playerid,
			playerid,
			TagScan(chat));

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

		return 1;
	}
	else
	{
		log(false, "[CHAT][RADIO] [%.2f] [%p]: %s", frequency, playerid, chat);

		format(line1, 256, "[%.2f] (%d) %P"C_WHITE": %s",
			frequency,
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(!IsPlayerLoggedIn(i)) 
				continue ; 
				
			if(-0.05 < frequency - chat_Freq[i] < 0.05)
			{
				SendClientMessage(i, CHAT_RADIO, line1);

				if(!isnull(line2))
					SendClientMessage(i, CHAT_RADIO, line2);
			}
		}
		SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
}

stock GetPlayerChatMode(playerid)
{
	if(!IsPlayerConnected(playerid))
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
	if(!IsPlayerConnected(playerid))
		return 0;

	return chat_Quiet[playerid];
}

stock Float:GetPlayerRadioFrequency(playerid)
{
	if(!IsPlayerConnected(playerid))
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
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(SEC(GetPlayerMuteRemainder(playerid)), "%1h:%1m:%1s"));

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
	chat_Quiet[playerid] = !chat_Quiet[playerid];
	ChatMsgLang(playerid, WHITE, chat_Quiet[playerid] ? "RADIOQUIET1" : "RADIOQUIET0");

	return 1;
}
CMD:goff(playerid, params[]) return cmd_quiet(playerid, params);

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