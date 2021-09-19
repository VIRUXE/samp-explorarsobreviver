#include <YSI_Coding\y_hooks>

enum E_TICKET_DATA
{
	TICKET_DATE,
	TICKET_ADMIN,
	TICKET_TEXT[128], // Limite do inputbox
}

static
Text: 	ticket_Notification,
bool:	ticket_NotificationVisible[MAX_PLAYERS] = {true, ...},
		ticket_Data[MAX_PLAYERS][E_TICKET_DATA], // Um ticket para cada jogador
		ticket_Count;

hook OnGameModeInit()
{
	ticket_Notification = 
	TextDrawCreate(640.000000, 1.000000, "Tickets: 0");
	TextDrawFont			(ticket_Notification, 1);
	TextDrawLetterSize		(ticket_Notification, 0.300000, 1.200000);
	TextDrawTextSize		(ticket_Notification, 600.000000, 17.000000);
	TextDrawSetOutline		(ticket_Notification, 1);
	TextDrawSetShadow		(ticket_Notification, 1);
	TextDrawAlignment		(ticket_Notification, 3);
	TextDrawColor			(ticket_Notification, -1);
	TextDrawBackgroundColor	(ticket_Notification, 255);
	TextDrawBoxColor		(ticket_Notification, 50);
	TextDrawUseBox			(ticket_Notification, 1);
	TextDrawSetProportional	(ticket_Notification, 1);
	TextDrawSetSelectable	(ticket_Notification, 0);

	for(new playerid; playerid < MAX_PLAYERS; playerid++) // Admin pode ser ID 0...
		ticket_Data[playerid][TICKET_ADMIN] = -1;
}

hook OnGameModeExit()
{
	TextDrawDestroy(ticket_Notification);
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerStaff(playerid))
	{
		new attendingPlayerId = IsAdminAttendingAPlayer(playerid);

		if(attendingPlayerId != -1)
		{
			ticket_Data[playerid][TICKET_ADMIN] = -1;

			ChatMsg(playerid, YELLOW, " » O Admin %P saiu. Espere que seja atendido por outro Admin.", playerid);
			
			_UpdateTicketNotification();
		}
	}
	else
	{
		if(DoesPlayerHaveATicket(playerid))
		{
			new adminId = IsPlayerBeingAttended(playerid);

			if(adminId != -1)
			{
				ToggleAdminDuty(adminId, false);

				ChatMsg(playerid, GREEN, " » O Jogador %P saiu. Ticket fechado automaticamente.", playerid);
			}

			_CloseTicket(playerid);
		}
	}
}

hook OnPlayerLogin(playerid)
{
	if(GetPlayerAdminLevel(playerid) && AreThereTicketsOpen())
		TextDrawShowForPlayer(playerid, ticket_Notification);
}

_OpenTicket(playerid, const text[128])
{
	if(ticket_Data[playerid][TICKET_DATE] == 0)
	{
		ticket_Data[playerid][TICKET_DATE] = GetTickCount(); // Apenas precisamos para saber a idade do ticket
		ticket_Data[playerid][TICKET_TEXT] = text;

		ticket_Count++;

		_UpdateTicketNotification();

		log(false, "[TICKET] %p(%d): %s", playerid, playerid, text);

		return 1;
	}

	return 0;
}

_CloseTicket(playerid)
{
	if(DoesPlayerHaveATicket(playerid))
	{
		ticket_Data[playerid][TICKET_DATE] = 0;
		ticket_Data[playerid][TICKET_ADMIN] = -1;
		ticket_Data[playerid][TICKET_TEXT][0] = EOS;

		ticket_Count--;

		_UpdateTicketNotification();

		log(false, "[TICKET] Eliminado para o Jogador %p(%d)", playerid, playerid);

		return 1;
	}

	return 0;
}

_GetOldestTicketOwnerId()
{
	new ticket[2]; // ticket -> {Date, ID}

	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
		if(ticket_Data[playerid][TICKET_DATE] > ticket[0])
		{
			ticket[0] = ticket_Data[playerid][TICKET_DATE];
			ticket[1] = playerid;	
		}
	}

	return ticket[0] ? ticket[1] : -1;
}

_UpdateTicketNotification()
{
/* 	for(new i; i < ticket_Count; i++)
	{
		if(!IsPlayerConnected(ticket_Beggar[i]))
			ticket_Beggar[i] = INVALID_PLAYER_ID;
		else if(!IsPlayerConnected(ticket_Helping[ticket_Beggar[i]]))
		{
			new timeformat[6];

			TimeFormat(ticket_Timestamp[i], "%H:%M", timeformat);
			
			format(ticket_Text, sizeof(ticket_Text), "%s~w~%i. %s ~g~%p(%d)~w~: %s~n~", ticket_Text, i, timeformat, ticket_Beggar[i], ticket_Beggar[i], ticket_HelpText[i]);
		}
	}
	
	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) && !IsPlayerConnected(ticket_Helping[i]))
		{
			PlayerTextDrawSetString(i, ticket_Notification[i], ticket_Text);

			if(IsAdminOnDuty(i))
				PlayerTextDrawShow(i, ticket_Notification[i]);
		}
	} */

	new str[11];
	format(str, sizeof(str), "Tickets: %d", ticket_Count);
	TextDrawSetString(ticket_Notification, str);

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) && IsTicketListActive(i))
		{
			if(ticket_Count)
				TextDrawShowForPlayer(i, ticket_Notification);
			else
				TextDrawHideForPlayer(i, ticket_Notification);
		}
	}

	log(false, "ticket board update");
}

stock bool:IsTicketListActive(playerid)
	return ticket_NotificationVisible[playerid];

stock bool:AreThereTicketsOpen()
{
	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
		if(DoesPlayerHaveATicket(playerid) && !IsPlayerBeingAttended(playerid))
			return true;
	}

	return false;
}

stock IsAdminAttendingAPlayer(adminId)
{
	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
		if(ticket_Data[playerid][TICKET_ADMIN] == adminId)
			return playerid;
	}

	return -1;
}

stock IsPlayerBeingAttended(playerid)
	return ticket_Data[playerid][TICKET_ADMIN];

stock bool:DoesPlayerHaveATicket(playerid)
{
	if(ticket_Data[playerid][TICKET_DATE] != 0)
		return true;

	return false;
}

stock bool:DoesPlayerHaveATicketOpen(playerid)
{
	if(DoesPlayerHaveATicket(playerid) && !IsPlayerBeingAttended(playerid))
		return true;

	return false;
}

CMD:ticket(playerid, params[])
{
	if(!isnull(params)) // Com parametros
	{
		if(isequal(params, "fechar", true))
		{
			new 
				ticketOwnerId = -1,
				attendingAdminId = -1;

			if(IsPlayerStaff(playerid)) // Fechar o Ticket que estiver a atender
			{
				ticketOwnerId = IsAdminAttendingAPlayer(playerid);

				if(ticketOwnerId != -1)
				{
					attendingAdminId = playerid;

					ChatMsg(playerid, GREEN, " » Você fechou o Ticket de %P", ticketOwnerId);
					ChatMsg(ticketOwnerId, GREEN, " » %P"C_GREEN" fechou o seu Ticket", playerid);

					log(false, "[TICKET] %p(%d) Fechou o Ticket de %p(%d)", playerid, playerid, ticketOwnerId, ticketOwnerId);
				}
				else
					return ChatMsg(playerid, YELLOW, " » Você não está atendendo ninguém no momento.");	
			}
			else // Fechar o Ticket criado pelo Jogador
			{
				if(DoesPlayerHaveATicket(playerid))
				{
					ticketOwnerId = playerid;

					attendingAdminId = IsPlayerBeingAttended(ticketOwnerId);

					if(attendingAdminId != -1)
						ChatMsg(attendingAdminId, GREEN, " » O Jogador fechou o Ticket.", ticketOwnerId);

					ChatMsg(playerid, GREEN, " » Você fechou o seu Ticket.", ticketOwnerId);

					log(false, "[TICKET] %p(%d) Fechou o seu proprio Ticket", ticketOwnerId, ticketOwnerId);
				}
				else
					return ChatMsg(playerid, YELLOW, " » Você não abriu nenhum Ticket.");	
			}
			
			if(attendingAdminId != -1) 
			{
				ToggleAdminDuty(attendingAdminId, false);
				SetPlayerChatMode(attendingAdminId, CHAT_MODE_ADMIN); // ADMIN CHAT

				// Avaliar apenas se estava a ser atendido
				TogglePlayerMute(ticketOwnerId, true);
				TogglePlayerControllable(ticketOwnerId, false);

				new dialogText[240+MAX_PLAYER_NAME];

				format(dialogText, sizeof(dialogText), "O seu Ticket foi Fechado.\n\nAntes de poder voltar a jogar é necessário você avaliar a qualidade do atendimento do Admin %p.\n\nIsso é muito importante para avaliarmos a nossa equipe e verificar se todos os jogadores são tratados justamente.", attendingAdminId);

				inline ResponseA(pid, dialogid, response, listitem, string:inputtext[])
				{
					#pragma unused pid, dialogid, listitem, inputtext

					if(response)
					{
						inline Response(pid2, dialogid2, response2, listitem2, string:inputtext2[])
						{
							#pragma unused pid2, dialogid2, inputtext2

							if(response2)
							{
								// TODO: Guardar a avaliacao na base de dados
								if(listitem != -1)
									log(false, "[TICKET] %p(%d) avaliou o atendimento de %p(%d) como %d", ticketOwnerId, ticketOwnerId, attendingAdminId, attendingAdminId, listitem2);
								else
									log(false, "[TICKET] %p(%d) escolheu nao avaliar %p(%d)", ticketOwnerId, ticketOwnerId, attendingAdminId, attendingAdminId);
							}
							else
								log(false, "[TICKET] %p(%d) escolheu nao avaliar %p(%d)", ticketOwnerId, ticketOwnerId, attendingAdminId, attendingAdminId);

							TogglePlayerMute(ticketOwnerId, false);
							TogglePlayerControllable(ticketOwnerId, true);
							SetPlayerChatMode(ticketOwnerId, CHAT_MODE_LOCAL);
							ToggleGodMode(ticketOwnerId, false);
						}
						Dialog_ShowCallback(ticketOwnerId, using inline Response, DIALOG_STYLE_LIST, "Ticket - Avaliar Atendimento", "Bom\nNormal\nMau", "Avaliar", "");
					}
				}
				Dialog_ShowCallback(ticketOwnerId, using inline ResponseA, DIALOG_STYLE_MSGBOX, "Ticket - Avaliar Atendimento", dialogText, "Seguinte", "");
			}

			_CloseTicket(ticketOwnerId);
		}
		else
			ChatMsg(playerid, YELLOW, " » Use: /ticket (Opcional: 'fechar')");
	}
	else // Sem parametros
	{
		if(IsPlayerStaff(playerid)) // Admin - Abrir o Ticket mais antigo para atender (Nota: Nao um admin nao pode criar tickets)
		{
			if(IsAdminAttendingAPlayer(playerid) != -1)
				return ChatMsg(playerid, RED, " » Já está em atendimento de um ticket. Não pode entrar noutro.");

			new ticketOwnerId = _GetOldestTicketOwnerId();

			if(ticketOwnerId == -1)
				return ChatMsg(playerid, GREEN, " » Não existem Tickets por atender.");
			else
			{
				while(IsPlayerBeingAttended(ticketOwnerId) != -1)
				{
					ticketOwnerId = _GetOldestTicketOwnerId();

					if(ticketOwnerId == -1)
						return ChatMsg(playerid, GREEN, " » Não existem Tickets por atender.");
				}
			}

			new ticketText[256];

			format(ticketText, sizeof(ticketText), C_YELLOW"Jogador:\n\t"C_BLUE"%p\n\n"C_YELLOW"Descrição:\n\t"C_BLUE"%s", ticketOwnerId, ticket_Data[ticketOwnerId][TICKET_TEXT]);

			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, listitem, inputtext

				if(response)
				{
					while(IsPlayerBeingAttended(ticketOwnerId) != -1)
					{
						ticketOwnerId = _GetOldestTicketOwnerId();

						if(ticketOwnerId == -1)
							return ChatMsg(playerid, GREEN, " » Todos os Tickets já foram atendidos..");
					}

					ticket_Data[ticketOwnerId][TICKET_ADMIN] = playerid;

					ToggleGodMode(ticketOwnerId, true);
					ToggleAdminDuty(playerid, true);

					TeleportPlayerToPlayer(playerid, ticketOwnerId);
					SetPlayerToFacePlayer(ticketOwnerId, playerid);
					SetPlayerToFacePlayer(playerid, ticketOwnerId);

					SetPlayerChatMode(playerid, CHAT_MODE_TICKET);
					SetPlayerChatMode(ticketOwnerId, CHAT_MODE_TICKET);

					ChatMsg(playerid, GREEN, " » Está atendendo o jogador %P.", ticketOwnerId);
					ChatMsg(ticketOwnerId, GREEN, " » Está agora a ser atendido pelo Admin %P.", playerid);

					log(true, "[TICKET] %p(%d) is attending %p(%d)", playerid, playerid, ticketOwnerId, ticketOwnerId);
				}
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Ticket - Detalhes do Ticket", ticketText, "Aceitar", "Sair");
		}
		else // Jogador normal
		{
			if(DoesPlayerHaveATicket(playerid))
				return ChatMsg(playerid, YELLOW, " » Você já fez um Ticket. Aguarde até que um Admin atenda ou feche.");

			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, listitem
				if(response)
				{
					if(strlen(inputtext) < 10)
						return ChatMsg(playerid, YELLOW, " » Tem que escrever um Ticket de pelomenos 10 caracteres..");

					new ticketText[128];

					strcat(ticketText, inputtext);
					_OpenTicket(playerid, ticketText);
					return ChatMsg(playerid, GREEN, " » Ticket enviado com sucesso. Aguarde até que um Admin atenda ou use /ticket fechar.");
				}
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Ticket - Enviar um Ticket", "Por favor, seja o mais detalhado possivel ao descrever o seu problema. (Tem 128 caracteres para o fazer.)\n\nIsso fará com que seja mais fácil/rápido para o Admin resolver o seu problema.\n\nEsse sistema serve principalmente para tirar duvidas ou resolver problemas 'gerais.\n\nExemplo, algum tipo de bug e não para reportar jogadores. Para isso use /report", "Enviar", "Cancelar");
		}
	}

	return 1;
}

ACMD:tickets[1](playerid, params[]) // Mostrar/Esconder board
{
	#pragma unused params
	ticket_NotificationVisible[playerid] = !ticket_NotificationVisible[playerid];

	if(IsTicketListActive(playerid))
	{
		if(AreThereTicketsOpen())
			TextDrawShowForPlayer(playerid, ticket_Notification);
	}
	else
		TextDrawHideForPlayer(playerid, ticket_Notification);

	ChatMsg(playerid, YELLOW, " » Lista de Tickets: %s", IsTicketListActive(playerid) ? "Ativada" : "Desativada");

	return 1;
}