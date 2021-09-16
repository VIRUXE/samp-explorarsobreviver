#include <YSI_Coding\y_hooks>

enum E_TICKET_DATA
{
	TICKET_DATE,
	TICKET_ADMIN,
	TICKET_TEXT[128], // Limite do inputbox
}

static
Text: 	ticket_Board,
bool:	ticket_ListVisible[MAX_PLAYERS] = {true, ...},
		ticket_Data[MAX_PLAYERS][E_TICKET_DATA], // Um ticket para cada jogador
		ticket_Count;

hook OnGameModeInit()
{
	ticket_Board = 
	TextDrawCreate(320.000000, 1.000000, "Explorar Sobreviver");
	TextDrawFont			(ticket_Board, 1);
	TextDrawLetterSize		(ticket_Board, 0.300000, 1.200000);
	TextDrawTextSize		(ticket_Board, 600.000000, 17.000000);
	TextDrawSetOutline		(ticket_Board, 1);
	TextDrawSetShadow		(ticket_Board, 1);
	TextDrawAlignment		(ticket_Board, 3);
	TextDrawColor			(ticket_Board, -1);
	TextDrawBackgroundColor	(ticket_Board, 255);
	TextDrawBoxColor		(ticket_Board, 50);
	TextDrawUseBox			(ticket_Board, 1);
	TextDrawSetProportional	(ticket_Board, 1);
	TextDrawSetSelectable	(ticket_Board, 0);

	for(new playerid; playerid < MAX_PLAYERS; playerid++) // Admin pode ser ID 0...
		ticket_Data[playerid][TICKET_ADMIN] = -1;
}

hook OnGameModeExit()
{
	TextDrawDestroy(ticket_Board);
}

hook OnPlayerDisconnect(playerid, reason)
{
	_CloseTicket(playerid);
}

hook OnPlayerLogin(playerid)
{
	if(GetPlayerAdminLevel(playerid) && AreThereTicketsOpen())
		TextDrawShowForPlayer(playerid, ticket_Board);
}

_OpenTicket(playerid, const text[128])
{
	if(ticket_Data[playerid][TICKET_DATE] == 0)
	{
		ticket_Data[playerid][TICKET_DATE] = GetTickCount(); // Apenas precisamos para saber a idade do ticket
		ticket_Data[playerid][TICKET_TEXT] = text;

		ticket_Count++;

		_UpdateTicketList();

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

		_UpdateTicketList();

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

_UpdateTicketList()
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
			PlayerTextDrawSetString(i, ticket_Board[i], ticket_Text);

			if(IsAdminOnDuty(i))
				PlayerTextDrawShow(i, ticket_Board[i]);
		}
	} */

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) && IsTicketListActive(i))
		{
			if(ticket_Count)
				TextDrawShowForPlayer(i, ticket_Board);
			else
				TextDrawHideForPlayer(i, ticket_Board);
		}
	}

	log(false, "ticket board update");
}

stock bool:IsTicketListActive(playerid)
	return ticket_ListVisible[playerid];

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

			if(GetPlayerAdminLevel(playerid)) // Fechar o Ticket que estiver a atender
			{
				// Loop para encontrar um Ticket aberto com o id do admin
				for(new i; i < MAX_PLAYERS; i++)
				{
					if(ticket_Data[i][TICKET_ADMIN] == playerid)
					{
						ticketOwnerId = i;
						break;
					}
				}

				if(ticketOwnerId != -1)
				{
					attendingAdminId = playerid;

					ChatMsg(playerid, GREEN, " » Você fechou o Ticket de %P", ticketOwnerId);

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
				SetPlayerChatMode(attendingAdminId, 3); // ADMIN CHAT

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
						inline Response(pid, dialogid, response, listitem, string:inputtext[])
						{
							#pragma unused pid, dialogid, inputtext

							if(response)
							{
								// TODO: Guardar a avaliacao na base de dados
								log(false, "[TICKET] %p(%d) avaliou o atendimento de %p(%d) como %d", ticketOwnerId, ticketOwnerId, attendingAdminId, attendingAdminId, listitem);
							}

							TogglePlayerMute(ticketOwnerId, false);
							TogglePlayerControllable(ticketOwnerId, true);
							SetPlayerChatMode(ticketOwnerId, CHAT_LOCAL);
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
		if(GetPlayerAdminLevel(playerid)) // Admin - Abrir o Ticket mais antigo para atender (Nota: Nao um admin nao pode criar tickets)
		{
			if(IsAdminAttendingAPlayer(playerid) != -1)
				return ChatMsg(playerid, RED, " » Ja esta em atendimento de um ticket. Nao pode entrar noutro.");

			new ticketOwnerId = _GetOldestTicketOwnerId();

			if(ticketOwnerId == -1)
				return ChatMsg(playerid, GREEN, " » Nao existem Tickets por atender.");

			if(IsPlayerBeingAttended(ticketOwnerId))
				return ChatMsg(playerid, RED, " » Esse jogador já está em atendimento.");

			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, listitem, inputtext

				if(response)
				{
					ticket_Data[ticketOwnerId][TICKET_ADMIN] = playerid;

					ToggleGodMode(ticketOwnerId, true);
					ToggleAdminDuty(playerid, true);
					TeleportPlayerToPlayer(playerid, ticketOwnerId);
					SetPlayerChatMode(playerid, CHAT_MODE_TICKET);
					SetPlayerChatMode(ticketOwnerId, CHAT_MODE_TICKET);

					ChatMsg(playerid, GREEN, " » Está atendendo o jogador %P.", ticketOwnerId);
					ChatMsg(ticketOwnerId, GREEN, " » Está agora a ser atendido pelo Admin %P.", playerid);

					log(true, "[TICKET] %p(%d) is attending %p(%d)", playerid, playerid, ticketOwnerId, ticketOwnerId);
				}
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Ticket - Aceitar Ticket", ticket_Data[ticketOwnerId][TICKET_TEXT], "Aceitar", "Sair");
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
					new ticketText[128];

					strcat(ticketText, inputtext);
					_OpenTicket(playerid, ticketText);
					return ChatMsg(playerid, GREEN, " » Ticket enviado com sucesso. Aguarde até que um Admin atenda.");
				}
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Ticket - Enviar um Ticket", "Por favor, seja o mais detalhado possivel ao descrever o seu problema. (Tem 128 caracteres para o fazer.)\n\nIsso fara com que seja mais facil/rapido para o Admin resolver o seu problema.\n\n\nEsse sistema serve principalmente para tirar duvidas ou resolver problemas 'gerais.\nExemplo, algum tipo de bug e nao para reportar jogadores. Para isso use /report", "Enviar", "Cancelar");
		}
	}

	return 1;
}

ACMD:tickets[1](playerid, params[]) // Mostrar/Esconder board
{
	#pragma unused params
	ticket_ListVisible[playerid] = !ticket_ListVisible[playerid];

	if(IsTicketListActive(playerid))
	{
		if(AreThereTicketsOpen())
			TextDrawShowForPlayer(playerid, ticket_Board);
	}
	else
		TextDrawHideForPlayer(playerid, ticket_Board);

	ChatMsg(playerid, YELLOW, " » Lista de Tickets: %s", IsTicketListActive(playerid) ? "Ativada" : "Desativada");

	return 1;
}