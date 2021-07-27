/* 
	Linking the Player account with their Discord account.

	They can only play with everyone else if they link the account.
*/

#include <YSI_Coding\y_hooks>

#define DISCORD_LINK_ROLE_ID 	"867774790189973514"
#define DISCORD_LINK_CHANNEL_ID "847902208343015484"

forward OnLinkingPrivateChannelCreated(const nameProvided[MAX_PLAYER_NAME]);
forward OnPlayerAccountLinked(const playerName[MAX_PLAYER_NAME], playerid = INVALID_PLAYER_ID);

hook OnPlayerAccountCheck(playerid, accountState)
{
	if(accountState == ACCOUNT_STATE_REGISTERED) // Account still not linked, so ask player to link it
		PromptPlayerToLinkAccount(playerid);
}

// Handle linking via discord channel
public DCC_OnMessageCreate(DCC_Message:message)
{
    new
        DCC_Channel:    channel,
        DCC_User:       discordUser,
        bool:           is_bot;

    DCC_GetMessageChannel(message, channel);
    DCC_GetMessageAuthor(message, discordUser);

    DCC_IsUserBot(discordUser, is_bot);
    
    if(is_bot)
        return 0;

    if(channel == DCC_FindChannelById(DISCORD_LINK_CHANNEL_ID))
    {
		new	discordUserId[DCC_ID_SIZE];

		DCC_GetMessageAuthor(message, discordUser);
		DCC_GetUserId(discordUser, discordUserId);

		// Verificar se o jogador já tem o id vinculado em alguma conta
		if(!DoesDiscordIdExist(discordUserId))
		{
            new nameProvided[MAX_PLAYER_NAME];

        	DCC_GetMessageContent(message, nameProvided);

			if(DoesPlayerAccountExist(nameProvided))
			{
				new	
					playerId = GetPlayerIdByName(nameProvided),
					discordUsername[DCC_USERNAME_SIZE],
					DCC_Guild:guild;

				if(SetPlayerAccountDiscordId(nameProvided, discordUserId)) // Guardar id de discord na conta do jogador
				{
					DCC_CreatePrivateChannel(discordUser, "OnLinkingPrivateChannelCreated", "s", nameProvided); // Enviar Mensagem privada. Pois ao colocar no cargo, o canal whitelist desaparece, logo não dá para ver se enviar mensagem para o canal

					// Se o jogador estiver online no servidor então colocar logo na whitelist
					if(playerId != INVALID_PLAYER_ID)
					{
						SetPlayerAccountState(playerId, ACCOUNT_STATE_LINKED);
						ChatMsg(playerId, GREEN, "Está agora na Whitelist. Pode clicar em Jogar!");
					}
					
					DCC_GetUserName(discordUser, discordUsername);
					DCC_GetChannelGuild(channel, guild);
					DCC_AddGuildMemberRole(guild, discordUser, DCC_FindRoleById(DISCORD_LINK_ROLE_ID)); // Colocar jogador no cargo "Sobrevivente"

					SendDiscordMessage(channel, "> Conta de Discord `%s` foi vinculada com a Conta de Jogo `%s`", discordUsername, nameProvided);

					log(true, "[WHITELIST] Discord ID %s (%s) foi atribuido para a conta %s", discordUserId, discordUsername, nameProvided);

					CallLocalFunction("OnPlayerAccountLinked", "sd", nameProvided, playerId);
				}
				else
					err(true, true, "[DISCORD-LINKING] Error executing SetPlayerAccountDiscordId (%s, %s)", nameProvided, discordUserId);
			}
			else
				SendDiscordMessage(channel, "> Nao existe uma Conta de Jogo com esse nick! **Tem que se registrar primeiro**.");
		}
		else
			SendDiscordMessage(channel, "> Voce ja tem uma Conta de Jogo associada nessa Conta de Discord...");
    }
    return 1;
}

public OnLinkingPrivateChannelCreated(const nameProvided[MAX_PLAYER_NAME])
{
	new DCC_Channel:channel = DCC_GetCreatedPrivateChannel();

	SendDiscordMessage(channel, "> Sua Conta de Jogo `%s` foi vinculada com sua Conta de Discord e recebeu o cargo de Sobrevivente. Bom jogo!", nameProvided);
}

stock PromptPlayerToLinkAccount(playerid)
{
	new whitelistMsg[999];

	log(true, "[WHITELIST] %p foi notificado para efetuar whitelist.", playerid);

	ClearChatForPlayer(playerid, 20);

	format(whitelistMsg, sizeof(whitelistMsg), ""C_WHITE"Você precisa vincular sua Conta de Jogo com sua Conta de Discord, para que possa jogar com outros jogadores.\n\n\
		"C_WHITE"\t1. Entre em: "C_BLUE"%s"C_WHITE". "C_WHITE"(Nota: necessita de vincular seu celular no Discord)\n\
		"C_WHITE"\t2. Digite %P"C_WHITE" em #vincular-conta\n\
		"C_WHITE"\t3. Volte aqui, clique em \"Jogar\" e pronto, você ja pode se divertir! :) \n\n\
		"C_YELLOW"Aviso:"C_WHITE" Isso serve como proteção para o servidor.\nPedimos sua compreensão.",
		gWebsiteURL, playerid);
		
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			if(IsPlayerAccountLinked(playerid)) 
				PromptPlayerToLinkAccount(playerid);
		}
		else
			KickPlayer(playerid, "Decidiu sair");
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "WhiteList", whitelistMsg, "Jogar", "Sair");
}