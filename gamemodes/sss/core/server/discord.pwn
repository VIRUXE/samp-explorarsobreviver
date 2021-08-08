
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_va>

static stock msgBuffer[4000]; // O Limite de texto no Discord é de 4000 caractéres.

static DCC_Channel:dc_GlobalChatChannel;

hook OnGameModeInit()
{
	dc_GlobalChatChannel = DCC_FindChannelById("874061189330665562");
}

hook OnPlayerSendChat(playerid, text[], Float:frequency)
{
	if(frequency == 1.0)
		SendDiscordMessage(dc_GlobalChatChannel, "**%p**: %s", playerid, text);
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

    if(channel == dc_GlobalChatChannel)
	{
		new 
			discordUserName[DCC_USERNAME_SIZE],
			discordMessage[145];

		DCC_GetUserName(discordUser, discordUserName);
		DCC_GetMessageContent(message, discordMessage);

		ChatMsgAll(WHITE, "[Discord] "C_GREY"%s"C_WHITE": %s", discordUserName, TagScan(discordMessage));
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

	log(true, "DoesDiscordIdExist - DiscordId: %s", discordId);

	stmt_bind_value(stmt_IdExists, 0, DB::TYPE_STRING, discordId, DCC_ID_SIZE);
	stmt_bind_result_field(stmt_IdExists, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_IdExists))
		stmt_fetch_row(stmt_IdExists);
	else
		err(false, true, "Não foi possível executar stmt_IdExists");

	return count > 0 ? true : false;
}