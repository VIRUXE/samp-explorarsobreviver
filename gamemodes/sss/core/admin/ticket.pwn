#include <YSI_Coding\y_hooks>

enum E_TICKET_DATA
{
	TICKET_DATE,
	TICKET_ADMIN,
	TICKET_TEXT[128],
}

static
Text: 	ticket_Board,
		ticket_Data[MAX_PLAYERS][E_TICKET_DATA], // Um ticket para cada jogador
		ticket_Count;

hook OnGameModeInit()
{
	ticket_Board = 
	TextDrawCreate(320.000000, 1.000000, "Explorar Sobreviver");
	TextDrawFont			(ticket_Board, 1);
	TextDrawLetterSize		(ticket_Board, 0.300000, 1.200000);
	TextDrawTextSize		(ticket_Board, 1000.000000, 17.000000);
	TextDrawSetOutline		(ticket_Board, 1);
	TextDrawSetShadow		(ticket_Board, 1);
	TextDrawAlignment		(ticket_Board, 1);
	TextDrawColor			(ticket_Board, -1);
	TextDrawBackgroundColor	(ticket_Board, 255);
	TextDrawBoxColor		(ticket_Board, 50);
	TextDrawUseBox			(ticket_Board, 1);
	TextDrawSetProportional	(ticket_Board, 1);
	TextDrawSetSelectable	(ticket_Board, 0);

	for(new playerid; playerid < MAX_PLAYERS; playerid++) // Meh gambiarra...
		ticket_Data[playerid][TICKET_ADMIN] = -1;
}

hook OnGameModeExit()
{
	TextDrawDestroy(ticket_Board);
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(ticket_Data[playerid][TICKET_DATE] != 0)
		_DeleteTicket(playerid);
}

_CreateTicket(playerid, const text[128])
{
	if(ticket_Data[playerid][TICKET_DATE] == 0)
	{
		ticket_Data[playerid][TICKET_DATE] = GetTickCount(); // Apenas precisamos para saber a idade do ticket
		ticket_Data[playerid][TICKET_TEXT] = text;

		ticket_Count++;

		_UpdateTicketsBoard();

		return 1;
	}

	return 0;
}

_DeleteTicket(playerid)
{
	if(ticket_Data[playerid][TICKET_DATE] != 0)
	{
		ticket_Data[playerid][TICKET_DATE] = 0;
		ticket_Data[playerid][TICKET_ADMIN] = -1;
		ticket_Data[playerid][TICKET_TEXT][0] = EOS;

		ticket_Count--;

		_UpdateTicketsBoard();

		return 1;
	}

	return 0;
}

_AssignAdminToPlayer(adminId, playerId)
{
	/* if(playerId == adminId)
		return -1; */

	if(ticket_Data[playerId][TICKET_ADMIN] == -1) // Apenas se ja nao estiver a ser atendido
	{
		ticket_Data[playerId][TICKET_ADMIN] = adminId;

		return 1;
	}
	else
		return 0;
}

_UpdateTicketsBoard()
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

	if(ticket_Count)
	{

	}
	log(false, "ticket board");
}

stock bool:AreThereTicketsOpen()
{
	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
		if(ticket_Data[playerid][TICKET_DATE] != 0 && ticket_Data[playerid][TICKET_ADMIN] == -1)
			return true;
	}

	return false;
}

stock bool:IsAdminOnTicket(adminId)
{
	for(new playerid; playerid < MAX_PLAYERS; playerid++)
	{
		if(ticket_Data[playerid][TICKET_ADMIN] == adminId)
			return true;
	}

	return false;
}

CMD:ticket(playerid, params[])
{
	if(!isnull(params))
	{
		if(GetPlayerAdminLevel(playerid))
		{
			if(isnumeric(params))
			{
				new ticketOwnerId = strval(params);

				if(!IsPlayerConnected(ticketOwnerId))
					return 4;

				if(IsAdminOnTicket(playerid))
					return ChatMsg(playerid, RED, "Ja esta em atendimento de um ticket. Nao pode entrar noutro.");

				// Answer ticket
				if(_AssignAdminToPlayer(playerid, ticketOwnerId))
				{
					ToggleGodMode(ticketOwnerId, true);
					ToggleAdminDuty(playerid, true);
					TeleportPlayerToPlayer(playerid, ticketOwnerId);
					SetPlayerChatMode(playerid, CHAT_MODE_TICKET);
					SetPlayerChatMode(ticketOwnerId, CHAT_MODE_TICKET);

					ChatMsg(playerid, GREEN, "Esta agora a atender o jogador %P.", ticketOwnerId);
					ChatMsg(ticketOwnerId, GREEN, "Esta agora a ser atendido pelo Admin %P.", playerid);
				}
				else
					return ChatMsg(playerid, RED, "Esse jogador ja se encontra a ser atendido.");
			}
			else
			{
				if(isequal(params, "fechar", true))
				{
					new ticketOwnerId = -1;

					// Loop para encontrar o ticket aberto com o id do admin
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
						ToggleGodMode(ticketOwnerId, false);
						SetPlayerChatMode(ticketOwnerId, CHAT_LOCAL);
						ChatMsg(ticketOwnerId, GREEN, "O seu Ticket foi Fechado. Avalie por favor, de 1 a 3 (1 mau, 2 normal, 3 bom), o atendimento de %P", playerid);

						ToggleAdminDuty(playerid, false);
						SetPlayerChatMode(playerid, 3); // ADMIN CHAT
						ChatMsg(playerid, GREEN, "Voce Fechou o Ticket de %P", ticketOwnerId);

						_DeleteTicket(ticketOwnerId);
					}
					else
						return ChatMsg(playerid, YELLOW, "Nao esta a atender ninguem para poder fechar.");
				}
				else
					ChatMsg(playerid, YELLOW, "Utilizacao: /ticket (id/fechar)");
			}
		}
		else
			return ChatMsg(playerid, YELLOW, "Utilizacao: /ticket (sem parametros)");
	}
	else
	{
		if(ticket_Data[playerid][TICKET_DATE] != 0)
			return ChatMsg(playerid, YELLOW, "Ja tem um Ticket em aberto. Tem que esperar que um admin atenda.");

		// ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption[], info[], button1[], button2[]);
		_CreateTicket(playerid, "teste");
	}

	return 1;
}

ACMD:toggletickets[1](playerid, params[]) // Mostrar/Esconder board
{

	return 1;
}