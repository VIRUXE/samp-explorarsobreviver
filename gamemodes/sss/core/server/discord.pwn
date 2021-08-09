
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_va>

static stock msgBuffer[4000]; // O Limite de texto no Discord é de 4000 caractéres.

static
DCC_Channel:	dc_GlobalChatChannel,
DCC_Channel:	dc_StaffChatChannel;

hook OnGameModeInit()
{
	dc_GlobalChatChannel 	= DCC_FindChannelById("874061189330665562");
	dc_StaffChatChannel 	= DCC_FindChannelById("846031149285638195");
}

hook OnPlayerSendChat(playerid, text[], Float:frequency)
{
	if(strfind(text, "@everyone") != -1)
		return 0;

	new DCC_Channel:channel;

	switch(frequency)
	{
		case 1.0:
			channel = dc_GlobalChatChannel;
		case 3.0:
			channel = dc_StaffChatChannel;
		/* case 3.0 .. 100.0: // Radio Frequencies
		{
			new DCC_Channel:radioChannel = DCC_Channel:DCC_FindChannelByName(frequency);
		} */
	}
	SendDiscordMessage(channel, "**%p** (%d): %s", playerid, playerid, text);

	return 1;
}

hook OnPlayerLogin(playerid)
{
	SendDiscordMessage(dc_GlobalChatChannel, "**%p (%d) %sentrou no servidor.**", playerid, playerid, IsPlayerMobile(playerid) ? "(Mobile) " : "");
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerLoggedIn(playerid) && !gServerRestarting)
		SendDiscordMessage(dc_GlobalChatChannel, "**%p (%d) %s.**", playerid, playerid, reason ? "decidiu sair" : "perdeu a conexao");
}

public DCC_OnMessageCreate(DCC_Message:message)
{
	new
	DCC_Channel:    channel,
	DCC_User:       discordUser,
	bool:           isUserBot;

    DCC_GetMessageChannel(message, channel);
    DCC_GetMessageAuthor(message, discordUser);

    DCC_IsUserBot(discordUser, isUserBot);
    
    if(isUserBot)
        return 0;

	new 
		discordUserName[DCC_USERNAME_SIZE],
		discordMessage[145];

	DCC_GetUserName(discordUser, discordUserName);
	DCC_GetMessageContent(message, discordMessage);

	if(channel == dc_GlobalChatChannel)
		ChatMsgAll(0x5865F2FF, "[Discord] "C_GREY"%s"C_WHITE": %s", discordUserName, TagScan(discordMessage));
	else if(channel == dc_StaffChatChannel)
	{
		if(isequal(discordMessage, ".restart", true))
		{
			SendDiscordMessage(dc_GlobalChatChannel, "**Servidor vai agora reiniciar...**");
			SetRestart(0);
		}
		else
			ChatMsgAdmins(1, 0xff4d00FF, "[Discord] "C_GREY"%s"C_WHITE": %s", discordUserName, TagScan(discordMessage));
	}

	return 1;
}

stock SendDiscordMessage(DCC_Channel:channel, const fmat[], va_args<>)
{
	formatex(msgBuffer, sizeof(msgBuffer), fmat, va_start<2>);
	DCC_SendChannelMessage(channel, msgBuffer);

	return 1;
}

stock bool:DoesDiscordIdExist(const discordId[DCC_ID_SIZE])
{
	new
		DBStatement:stmt_IdExists = db_prepare(gAccounts, "SELECT COUNT(*) FROM Player WHERE discord_id=? COLLATE NOCASE"),
		count;

	log(true, "[DISCORD] DoesDiscordIdExist - DiscordId: %s", discordId);

	stmt_bind_value(stmt_IdExists, 0, DB::TYPE_STRING, discordId, DCC_ID_SIZE);
	stmt_bind_result_field(stmt_IdExists, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_IdExists))
		stmt_fetch_row(stmt_IdExists);
	else
		err(false, true, "Não foi possível executar stmt_IdExists");

	return count > 0 ? true : false;
}