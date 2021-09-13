#include <YSI_Coding\y_hooks>

#define MAX_TICKETS         10
#define MAX_TICKET_LEN      64

static
PlayerText: ticket_Board,
			ticket_Data[MAX_PLAYERS],

enum E_TICKET_DATA
{
	TICKET_DATE,
	TICKET_TYPE, // Report (Player/Bug), Duvidas
	TICKET_OWNER[MAX_PLAYER_NAME],
	TICKET_TEXT[128],
	TICKET_STATE = {-1, ...}, // 0 - Open / 1 - In Process
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
	if(ticket_Data[playerid][TICKET_STATE] != -1)
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

CMD:ticket(playerid, params[])
{
	if(!isnull(params))
	{
		if(GetPlayerAdminLevel(playerid))
		{
			if(!isnumeric(params))
				return ChatMsg(playerid, RED, "Tem de especificar um Id de Jogador.");

			new targetId = strval(params);

			if(!IsPlayerConnected(targetId))
				return 4;

			// Answer ticket
			ToggleGodMode(targetId);
			ToggleAdminDuty(playerid, true);
			TeleportPlayerToPlayer(playerid, targetId);
			SetPlayerChatMode(playerid, CHAT_TICKETS);
			SetPlayerChatMode(targetId, CHAT_TICKETS);
		}
		else
			return ChatMsg(playerid, YELLOW, "Utilizacao: /ticket (sem parametros)");
	}
	else
	{
		if(ticket_Data[playerid][TICKET_STATE] != -1)
			return ChatMsg(playerid, YELLOW, "Ja tem um Ticket aberto.");

		ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, caption[], info[], button1[], button2[]);

		_UpdateTicketsBoard();
	}

	return 1;
}

_CreateTicket(playerid)
{}

_DeleteTicket(playerid)
{
	ticket_Data[TICKET_DATE] =;
	ticket_Data[TICKET_TYPE] = -1;
	ticket_Data[TICKET_OWNER][0] =;
	ticket_Data[TICKET_TEXT][0] = ;
	ticket_Data[TICKET_STATE] = -1;
}

_UpdateTicketsBoard()
{

	ticket_Text = "~y~Tickets~n~";

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
	foreach(i : Player)
	{
		if(ticket_Data[i][TICKET_STATE] != -1)
			return true;
	}

	return false;
}