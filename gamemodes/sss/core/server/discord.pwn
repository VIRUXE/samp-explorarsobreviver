#include <YSI\y_hooks>
#include <YSI\y_timers>
#include <YSI\y_va>

#define DISCORD_MENTION_STAFF 	"<@&580158122073784320> "// Staff Role
#define DISCORD_MENTION_DEV 	"<@159298655361171456> "// VIRUXE

enum
{
	DISCORD_CHANNEL_INVALID,
	DISCORD_CHANNEL_LOCAL,
	DISCORD_CHANNEL_GLOBAL,
	DISCORD_CHANNEL_GLOBALANDADMIN,
	DISCORD_CHANNEL_RADIO,
	DISCORD_CHANNEL_ADMIN,
	DISCORD_CHANNEL_EVENTS,
	DISCORD_CHANNEL_ADMINEVENTS,
	DISCORD_CHANNEL_DEV,
	DISCORD_CHANNEL_ALL
}

static
	DCC_Channel:dc_LocalChat,
	DCC_Channel:dc_GlobalChat,
	DCC_Channel:dc_RadioChat,
	DCC_Channel:dc_AdminChat,
	DCC_Channel:dc_Events,
	DCC_Channel:dc_AdminEvents,
	DCC_Channel:dc_Dev;

public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User:author, const message[])
{
	new 
		bool:	isAuthorBot,
				authorName[MAX_PLAYER_NAME];

	DCC_GetUserName(author, authorName, sizeof(authorName));
	DCC_IsUserBot(author, isAuthorBot);

	if(!isAuthorBot)
	{
		if(channel == dc_GlobalChat)
		{
			// TODO: Handle player commands
			// players, restart

			ChatMsgAll(WHITE, "[Discord] {8faa79}%s"C_WHITE": %s", authorName, message);
			//ChatMsgAll(WHITE, "[Discord] %s: %s", author, TagScan(message));

			log(DISCORD_CHANNEL_INVALID, "[DISCORD] '%s': %s", authorName, message);
		}
		else if(channel == dc_AdminChat)
		{
			// TODO: Handle admin only commands
			// restart, ban, kick

			ChatMsgAdmins(1, WHITE, "[Discord] {c67373}%s"C_WHITE": %s", authorName, message);
			//ChatMsgAdmins(1, RED, "[Discord] %s: %s", author, TagScan(message));

			log(DISCORD_CHANNEL_INVALID, "[DISCORD][ADMIN] '%s': %s", authorName, message);

			/*
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
		*/
		}
	}

	return 1;
}

DiscordConnectBot() // Gameserver #1 channels loaded by default (Ultron)
{
	if(gDiscord)
	{
		new tmp[19];

		console("[DISCORD] Connected Bot.");

		GetSettingString("discord/channel/localchat", 		"572138072616206347", tmp);
		dc_LocalChat	= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/globalchat", 		"548834423664017408", tmp);
		dc_GlobalChat 	= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/radiochat", 		"571455348989493258", tmp);
		dc_RadioChat 	= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/adminchat", 		"548834449236951070", tmp);
		dc_AdminChat 	= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/events", 			"548834474259906563", tmp);
		dc_Events 		= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/adminevents", 	"548834510054096898", tmp);
		dc_AdminEvents 	= DCC_FindChannelById(tmp);
		GetSettingString("discord/channel/dev", 			"548834530564243456", tmp);
		dc_Dev 			= DCC_FindChannelById(tmp);

		DiscordMessage(DISCORD_CHANNEL_GLOBAL, "*has respawned...*");
	}
	else
		console("[DISCORD] Discord is disabled.");

	return;
}

DiscordMessage(channel, text[], va_args<>)
{
	if(!gDiscord)
		return 0;

	new msgBuffer[256];

	formatex(msgBuffer, sizeof(msgBuffer), text, va_start<2>);

	if(channel == DISCORD_CHANNEL_LOCAL)
		DCC_SendChannelMessage(dc_LocalChat, msgBuffer);
	else if(channel == DISCORD_CHANNEL_GLOBAL || channel == DISCORD_CHANNEL_GLOBALANDADMIN)
		DCC_SendChannelMessage(dc_GlobalChat, msgBuffer);
	else if(channel == DISCORD_CHANNEL_RADIO)
		DCC_SendChannelMessage(dc_RadioChat, msgBuffer);
	else if(channel == DISCORD_CHANNEL_ADMIN || channel == DISCORD_CHANNEL_GLOBALANDADMIN) // Just for admin or both channels
		DCC_SendChannelMessage(dc_AdminChat, msgBuffer);
	else if(channel == DISCORD_CHANNEL_EVENTS)
		DCC_SendChannelMessage(dc_Events, msgBuffer);
	else if(channel == DISCORD_CHANNEL_ADMINEVENTS)
		DCC_SendChannelMessage(dc_AdminEvents, msgBuffer);
	else if(channel == DISCORD_CHANNEL_DEV)
		DCC_SendChannelMessage(dc_Dev, msgBuffer);
	else if(channel == DISCORD_CHANNEL_ALL)
	{
		DCC_SendChannelMessage(dc_GlobalChat, msgBuffer);
		DCC_SendChannelMessage(dc_RadioChat, msgBuffer);
		DCC_SendChannelMessage(dc_AdminChat, msgBuffer);
		DCC_SendChannelMessage(dc_Events, msgBuffer);
		DCC_SendChannelMessage(dc_AdminEvents, msgBuffer);
		DCC_SendChannelMessage(dc_Dev, msgBuffer);
	}

	return 1;
}