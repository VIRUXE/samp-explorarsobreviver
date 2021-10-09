
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_va>

static stock msgBuffer[4000]; // O Limite de texto no Discord é de 4000 caractéres.

static
// DCC_Channel:	dc_EntradaChannel,
// DCC_Channel:	dc_BatePapoChannel,
DCC_Channel:	dc_GlobalChatChannel,
DCC_Channel:	dc_AdminChatChannel,
DCC_Channel:	dc_StaffChatChannel,
DCC_Role:		dc_RoleSobrevivente,
DCC_Role:		dc_RoleBanido;

hook OnGameModeInit()
{
	// dc_EntradaChannel		= DCC_FindChannelById("871853782626103366");
	// dc_BatePapoChannel		= DCC_FindChannelById("847970255254716436");
	dc_GlobalChatChannel 	= DCC_FindChannelById("874061189330665562");
	dc_AdminChatChannel		= DCC_FindChannelById("865056486765494283");
	dc_StaffChatChannel 	= DCC_FindChannelById("846031149285638195");
	dc_RoleSobrevivente		= DCC_FindRoleById("867774790189973514");
	dc_RoleBanido			= DCC_FindRoleById("868524903672971294");

	SendDiscordMessage(dc_GlobalChatChannel, "**Servidor a iniciar. Aguarde...");
}

hook OnServerStarted()
{
	SendDiscordMessage(dc_GlobalChatChannel, "**Servidor terminou de iniciar! Podem conectar. @here");
}

hook OnPlayerSendChat(playerid, text[], Float:frequency)
{
	new DCC_Channel:channel;

	switch(frequency)
	{
		case 1.0:
			channel = dc_GlobalChatChannel;
		case 3.0:
			channel = dc_AdminChatChannel;
		/* case 3.0 .. 100.0: // Radio Frequencies
		{
			new DCC_Channel:radioChannel = DCC_Channel:DCC_FindChannelByName(frequency);
		} */
	}
	if(strfind(text, "@everyone") == -1)
		SendDiscordMessage(channel, "**%p**(%d)%s: %s", playerid, playerid, IsPlayerUsingMobile(playerid) ? "(m)" : "", text);
}

hook OnPlayerRegister(playerid)
    SendDiscordMessage(dc_GlobalChatChannel, "**%p(%d) %sregistrou conta.**", playerid, playerid, IsPlayerUsingMobile(playerid) ? "(Mobile) " : "");

hook OnPlayerLogin(playerid)
	SendDiscordMessage(dc_GlobalChatChannel, "**%s%p(%d) %sentrou no servidor.**", IsPlayerStaff(playerid) ? "Admin " : "", playerid, playerid, IsPlayerUsingMobile(playerid) ? "(Mobile) " : "");

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerLoggedIn(playerid) && !gServerRestarting)
		SendDiscordMessage(dc_GlobalChatChannel, "**%p(%d) %s.**", playerid, playerid, reason ? "saiu" : IsPlayerUsingMobile(playerid) ? "saiu" : "perdeu a conexao");
}

public DCC_OnGuildMemberAdd(DCC_Guild:guild, DCC_User:user)
{
	new
		userId[DCC_ID_SIZE],
		userNickname[DCC_NICKNAME_SIZE],
		playerAccountName[MAX_PLAYER_NAME],
		bool:isUserLinked;

	DCC_GetUserId(user, userId);
	GetAccountNameByDiscordId(userId, playerAccountName);
	isUserLinked = isnull(playerAccountName) ? false : true;
	DCC_GetGuildMemberNickname(guild, user, userNickname);
	DCC_CreatePrivateChannel(user, "OnMemberJoined", "sb", userNickname, isUserLinked);

	if(isUserLinked) // Já está vinculada, por isso atribuir o cargo correto
		DCC_AddGuildMemberRole(guild, user, !IsPlayerBanned(playerAccountName) ? dc_RoleSobrevivente : dc_RoleBanido); // Colocar jogador no cargo "Sobrevivente"
}

forward OnMemberJoined(const nickname[DCC_NICKNAME_SIZE], bool:isNew);
public OnMemberJoined(const nickname[DCC_NICKNAME_SIZE], bool:isNew)
{
	new DCC_Channel:channel = DCC_GetCreatedPrivateChannel();

	if(isNew)
		SendDiscordMessage(channel, "Bem-vindo! Você ainda não vinculou essa Conta de Discord com uma Conta de Jogo. Como tal, primeiro entre no servidor e registre sua conta. `sv.explorarsobreviver.com:7777`");
	else
		SendDiscordMessage(channel, "Você já tem essa conta de Discord vinculada. Foi atribuido o cargo de Sobrevivente automáticamente.");
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
	RemoveAccents(discordMessage);

	if(channel == dc_GlobalChatChannel)
		ChatMsgAll(WHITE, "[Discord] "C_GREY"%s"C_WHITE": %s", discordUserName, TagScan(discordMessage));
	else if(channel == dc_AdminChatChannel)
		ChatMsgAdmins(1, 0xff4d00FF, "[Discord] "C_GREY"%s"C_WHITE": %s", discordUserName, TagScan(discordMessage));
	else if(channel == dc_StaffChatChannel) // Apenas para executar comandos
	{
		if(!strfind(discordMessage, ".rr", true))
		{
			new restartSeconds;

			strdel(discordMessage, 0, 3); // remove .rr
			restartSeconds = strval(discordMessage);

			SendDiscordMessage(dc_GlobalChatChannel, "**Servidor vai reiniciar em %02d:%02d** @here", restartSeconds / 60, restartSeconds % 60);
			log(true, "[RESTART] %s set the server to restart.", discordUserName);

			SetRestart(restartSeconds);
			return 1;
		}
	}

	return 1;
}

stock SendDiscordMessage(DCC_Channel:channel, const fmat[], va_args<>)
{
	formatex(msgBuffer, sizeof(msgBuffer), fmat, va_start<2>);
	DCC_SendChannelMessage(channel, msgBuffer);

	return 1;
}

stock GetAccountNameByDiscordId(const discordId[DCC_ID_SIZE], accountName[MAX_PLAYER_NAME])
{
	new DBStatement:stmt = db_prepare(gAccounts, "SELECT name FROM Player WHERE discord_id=? COLLATE NOCASE");

	stmt_bind_value(stmt, 0, DB::TYPE_STRING, discordId, DCC_ID_SIZE);
	stmt_bind_result_field(stmt, 0, DB::TYPE_STRING, accountName, MAX_PLAYER_NAME);

	if(stmt_execute(stmt))
		stmt_fetch_row(stmt);
	else
		err(false, true, "[DISCORD] Couldn't execute GetAccountNameByDiscordId");

	log(true, "[DISCORD] GetAccountNameByDiscordId(%s) - Name: %s", discordId, accountName);

	return accountName;
}