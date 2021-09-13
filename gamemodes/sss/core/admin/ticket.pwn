#include <YSI_Coding\y_hooks>

#define MAX_TICKETS         10
#define MAX_TICKET_LEN      64

static
PlayerText: ticket_Board,
			ticket_Data[MAX_PLAYERS], // Um ticket para cada jogador
			ticket_Count;

enum E_TICKET_DATA
{
	TICKET_DATE,
	TICKET_ADMIN = {-1, ...},
	TICKET_TEXT[128],
}

hook OnGameModeInit
{
	ticket_Board = CreateTextDraw	(playerid, 320.000000, 1.000000, "Explorar Sobreviver");
	TextDrawFont					(playerid, ticket_Board, 1);
	TextDrawLetterSize				(playerid, ticket_Board, 0.300000, 1.200000);
	TextDrawTextSize				(playerid, ticket_Board, 1000.000000, 17.000000);
	TextDrawSetOutline				(playerid, ticket_Board, 1);
	TextDrawSetShadow				(playerid, ticket_Board, 1);
	TextDrawAlignment				(playerid, ticket_Board, 1);
	TextDrawColor					(playerid, ticket_Board, -1);
	TextDrawBackgroundColor			(playerid, ticket_Board, 255);
	TextDrawBoxColor				(playerid, ticket_Board, 50);
	TextDrawUseBox					(playerid, ticket_Board, 1);
	TextDrawSetProportional			(playerid, ticket_Board, 1);
	TextDrawSetSelectable			(playerid, ticket_Board, 0);
}

hook OnGameModeExit
{
	TextDrawDestroy(playerid, ticket_Board);
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(ticket_Data[playerid][TICKET_DATE] != 0)
		_DeleteTicket(playerid);
}

hook OnAdminToggleDuty(playerid, bool:duty, bool:goback)
{
	if(duty)
	{
		if(AreThereTicketsOpen())
			TextDrawShowForPlayer(playerid, ticket_Board);
	}
	else
		TextDrawHideForPlayer(playerid, ticket_Board);
}

_CreateTicket(playerid, text[128])
{
	ticket_Data[playerid][TICKET_DATE] = GetTickCount(); // Apenas precisamos para saber a idade do ticket
	ticket_Data[playerid][TICKET_TEXT] = text;

	ticket_Count++;

	_UpdateTicketsBoard();
}

_DeleteTicket(playerid)
{
	ticket_Data[playerid][TICKET_DATE] = 0;
	ticket_Data[playerid][TICKET_ADMIN] = -1;
	ticket_Data[playerid][TICKET_TEXT][0] = EOS;

	ticket_Count--;
}

_AssignAdminToPlayer(adminId, playerId)
{
	ticket_Data[playerId][TICKET_ADMIN] = adminId;

	ChatMsg(playerId, GREEN, "Voce sera agora atendido por %P", adminId);
}

_UpdateTicketsBoard()
{
	for(new i; i < ticket_Count; i++)
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
	}
}

stock bool:AreThereTicketsOpen()
{
	for(new idx = 0; )
}

CMD:ticket(playerid, params[])
{
	if(!isnull(params))
	{
		if(GetPlayerAdminLevel(playerid))
		{
			if(isnumeric(params))
			{
				new targetId = strval(params);

				if(!IsPlayerConnected(targetId))
					return 4;

				_AssignAdminToPlayer(adminId, playerId);

				// Answer ticket
				// ToggleGodMode(targetId);
				ToggleAdminDuty(playerid, true);
				TeleportPlayerToPlayer(playerid, targetId);
				// SetPlayerChatMode(playerid, CHAT_TICKETS);
				// SetPlayerChatMode(targetId, CHAT_TICKETS);
			}
			else
			{
				if(isequal(params, "close", true))
				{
					// Loop para encontrar o ticket aberto com o id do admin
					for(new i; i < MAX_PLAYERS; i++)
					{
						if(ticket_Data[i][TICKET_ADMIN] == playerid)
						{
							ChatMsg(i, YELLOW, "O seu Ticket foi Fechado.");
							ChatMsg(playerid, GREEN, "Voce Fechou o Ticket de %P", i);

							_DeleteTicket(i);
							break;
						}
					}
				}
				else
				{

				}
			}

		}
		else
			return ChatMsg(playerid, YELLOW, "Utilizacao: /ticket (sem parametros)");
	}
	else
	{
		if(ticket_Data[playerid][TICKET_STATE] != -1)
			return ChatMsg(playerid, YELLOW, "Ja tem um Ticket aberto.");

		ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption[], info[], button1[], button2[]);
	}

	return 1;
}