
#include <YSI_Coding\y_hooks>


static
bool:			wl_Active,
bool:			wl_Auto,
				wl_NonWhitelistTime = 300,
bool:			wl_Whitelisted[MAX_PLAYERS],
				wl_Countdown[MAX_PLAYERS],
PlayerText:		wl_CountdownUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
Timer:			wl_CountdownTimer[MAX_PLAYERS];


hook OnScriptInit()
{
	GetSettingInt("server/whitelist", 0, wl_Active);
	GetSettingInt("server/whitelist-auto-toggle", 0, wl_Auto);
}

hook OnPlayerConnect(playerid)
{
	defer _WhitelistConnect(playerid);

	wl_CountdownUI[playerid]		=CreatePlayerTextDraw(playerid, 430.0, 40.0, "Nao se encontra na Whitelist~n~Tempo restante: 00:00");
	PlayerTextDrawAlignment			(playerid, wl_CountdownUI[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, wl_CountdownUI[playerid], 255);
	PlayerTextDrawFont				(playerid, wl_CountdownUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, wl_CountdownUI[playerid], 0.20, 1.0);
	PlayerTextDrawColor				(playerid, wl_CountdownUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, wl_CountdownUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, wl_CountdownUI[playerid], 1);
}

hook OnPlayerDisconnect(playerid)
{
	wl_Whitelisted[playerid] = false;

	// Again, a timer in case the GetAdminsOnline func returns 1 even though
	// that 1 admin is quitting (Admin/Core.pwn hook maybe called after this)
	defer _WhitelistDisconnect(playerid);

	return 1;
}

// Whitelist pelo Discord
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

    if(channel == DCC_FindChannelById("847902208343015484")) // Canal Whitelist
    {
		new	discordUserId[DCC_ID_SIZE];

		DCC_GetMessageAuthor(message, discordUser);
		DCC_GetUserId(discordUser, discordUserId);

		// Verificar se o jogador já tem o id vinculado em alguma conta
		if(!DoesDiscordIdExist(discordUserId))
		{
            new nameProvided[MAX_PLAYER_NAME];

        	DCC_GetMessageContent(message, nameProvided);

			if(DoesAccountExist(nameProvided))
			{
				new	
					playerid = GetPlayerIdByName(nameProvided),
					discordUsername[DCC_USERNAME_SIZE],
					DCC_Guild:guild;

				SetAccountDiscordId(nameProvided, discordUserId); // Guardar id de discord na conta do jogador

				// Se o jogador estiver online no servidor então colocar logo na whitelist
				if(playerid != INVALID_PLAYER_ID)
				{
					wl_Whitelisted[playerid] = true;
					ChatMsg(playerid, GREEN, "Está agora na Whitelist. Pode clicar em Jogar!");
				}
				
				DCC_GetUserName(discordUser, discordUsername);
				DCC_GetChannelGuild(channel, guild);
				DCC_AddGuildMemberRole(guild, discordUser, DCC_FindRoleById("867774790189973514")); // Colocar jogador no cargo "Sobrevivente"

				SendDiscordMessage(channel, "> Conta de Discord `%s` foi vinculada com a Conta de Jogo `%s`", discordUsername, nameProvided);
				DCC_CreatePrivateChannel(discordUser, "OnWhitelistSuccess", "s", nameProvided); // Enviar Mensagem privada. Pois ao colocar no cargo, o canal whitelist desaparece, logo não dá para ver se enviar mensagem para o canal

				log(true, "[WHITELIST] Discord ID %s (%s) foi atribuido para a conta %s", discordUserId, discordUsername, nameProvided);
			}
			else
				SendDiscordMessage(channel, "> Nao existe uma Conta de Jogo com esse nick! **Tem que se registrar primeiro**.");
		}
		else
			SendDiscordMessage(channel, "> Voce ja tem uma Conta de Jogo associada nessa Conta de Discord...");
    }
    return 1;
}

forward OnWhitelistSuccess(const nameProvided[MAX_PLAYER_NAME]);
public OnWhitelistSuccess(const nameProvided[MAX_PLAYER_NAME])
{
	new DCC_Channel:channel = DCC_GetCreatedPrivateChannel();

	SendDiscordMessage(channel, "> Sua Conta de Jogo `%s` foi vinculada com sua Conta de Discord e recebeu o cargo de Sobrevivente. Bom jogo!", nameProvided);
}

stock IsPlayerWhitelisted(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return wl_Whitelisted[playerid];
}

stock AskPlayerToWhitelist(playerid)
{
	new whitelistMsg[999];

	log(true, "[WHITELIST] %p foi notificado para efetuar whitelist.", playerid);

	ClearChatForPlayer(playerid, 20);

	format(whitelistMsg, sizeof(whitelistMsg), ""C_WHITE"Você precisa registrar na WhiteList para jogar no servidor.\n\n\
		"C_WHITE"\t1. Entre em: http://"C_BLUE"%s"C_WHITE". "C_WHITE"(Nota: necessita de vincular seu celular no Discord)\n\
		"C_WHITE"\t2. Digite %P"C_WHITE" em #whitelist\n\
		"C_WHITE"\t3. Volte aqui, clique em \"Jogar\" e pronto, você ja pode se divertir! :) \n\n\
		"C_YELLOW"Aviso:"C_WHITE" Isso serve como proteção para o servidor.\nPedimos sua compreensão.",
		gWebsiteURL, playerid);
		
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			if(IsPlayerAdmin(playerid))
				wl_Whitelisted[playerid] = true;

			if(!wl_Whitelisted[playerid])
				AskPlayerToWhitelist(playerid);
		}
		else
			KickPlayer(playerid, "Decidiu sair");
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "WhiteList", whitelistMsg, "Jogar", "Sair");
}

stock ToggleWhitelist(bool:toggle)
{
	wl_Active = toggle;

	if(toggle)
	{
		foreach(new i : Player)
		{
			if(!wl_Whitelisted[i])
			{
				wl_Countdown[i] = wl_NonWhitelistTime;
				PlayerTextDrawSetString(i, wl_CountdownUI[i], sprintf("Não se encontra na Whitelist~n~Tempo restante: %02d:%02d", wl_Countdown[i] / 60, wl_Countdown[i] % 60));
				PlayerTextDrawShow(i, wl_CountdownUI[i]);
				stop wl_CountdownTimer[i];
				wl_CountdownTimer[i] = repeat _UpdateWhitelistCountdown(i);
			}
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(!wl_Whitelisted[i])
			{
				stop wl_CountdownTimer[i];
				PlayerTextDrawHide(i, wl_CountdownUI[i]);
			}
		}
	}
}

stock ToggleAutoWhitelist(bool:toggle)
{
	wl_Auto = toggle;

	// If auto whitelist is being turned on.
	if(toggle)
	{
		// If the whitelist is on and admins are on, turn it off.
		if(wl_Active && GetAdminsOnline(2))
			ToggleWhitelist(false);

		// If the whitelist is off and there are no admins, turn it on.
		else
			ToggleWhitelist(true);
	}
}


/*
	Internal
*/


timer _UpdateWhitelistCountdown[1000](playerid)
{
	if(!IsPlayerLoggedIn(playerid))
	{
		stop wl_CountdownTimer[playerid];
		return;
	}

	if(wl_Whitelisted[playerid])
	{
		stop wl_CountdownTimer[playerid];
		PlayerTextDrawHide(playerid, wl_CountdownUI[playerid]);
	}

	if(wl_Countdown[playerid] == 0)
	{
		AskPlayerToWhitelist(playerid);
		KickPlayer(playerid, "Whitelist");
		stop wl_CountdownTimer[playerid];
		return;
	}

	PlayerTextDrawSetString(playerid, wl_CountdownUI[playerid], sprintf("Not whitelisted~n~Time remaining: %02d:%02d", wl_Countdown[playerid] / 60, wl_Countdown[playerid] % 60));
	PlayerTextDrawShow(playerid, wl_CountdownUI[playerid]);

	wl_Countdown[playerid]--;

	return;
}

/*
	If auto whitelist toggle is on, turn the whitelist off when an admin joins
	and turn it back on when there are no admins on the server.

	Works for level 2 admins and higher since level 1 admins don't have any
	anti-hack tools at disposal.
*/

timer _WhitelistConnect[SEC(5)](playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		log(true, "[_WhitelistConnect] Player %d not connected any more.", playerid);
		return;
	}

	if(!IsPlayerInTutorial(playerid))
	{
		if(DoesAccountHaveDiscord(playerid))
		{
			wl_Whitelisted[playerid] = true;
			log(true, "[_WhitelistConnect] Player %d is whitelisted.", playerid);
		}
		else
		{
			AskPlayerToWhitelist(playerid);
			log(true, "[_WhitelistConnect] Player %d was asked to whitelist.", playerid);
		}
	}
	else
		log(true, "[_WhitelistConnect] Player %d is in the tutorial. Not doing anything.", playerid);
}

hook OnPlayerLogin(playerid)
{
	if(wl_Auto && wl_Active)
	{
		if(GetAdminsOnline(2) > 0) // turn off if whitelist is on and are admins online
		{
			ChatMsg(playerid, YELLOW, " » Auto-whitelist: Deactivated the whitelist.");
			ToggleWhitelist(false);
			log(true, "[AUTOWHITELIST] Whitelist turned off by %p joining", playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer _WhitelistDisconnect[100](playerid)
{
	if(wl_Auto && !wl_Active)
	{
		if(GetAdminsOnline(2) == 0) // turn on if whitelist is off and no admins remain online
		{
			ToggleWhitelist(true);
			log(true, "[AUTOWHITELIST] Whitelist turned on by %d quitting.", playerid);
		}
	}
}


/*
	Interface
*/


stock IsWhitelistAuto()
{
	return wl_Auto;
}

stock IsWhitelistActive()
{
	return wl_Active;
}

stock SetNonWhitelistTime(value)
{
	wl_NonWhitelistTime = value;
}

stock GetNonWhitelistTime()
{
	return wl_NonWhitelistTime;
}
