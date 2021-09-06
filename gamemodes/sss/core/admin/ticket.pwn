#include <YSI_Coding\y_hooks>

#define MAX_TICKETS         10
#define MAX_TICKET_LEN      64

static 
ticket_HelpText[MAX_TICKETS][MAX_TICKET_LEN],
ticket_Beggar[MAX_TICKETS] = {INVALID_PLAYER_ID, ...},
ticket_Helper[MAX_TICKETS] = {INVALID_PLAYER_ID, ...},
ticket_Timestamp[MAX_TICKETS],
ticket_Text[MAX_TICKETS * (MAX_TICKET_LEN + MAX_PLAYER_NAME + 12)] = "~w~Tickets",
ticket_Count = MAX_TICKETS - 1,
PlayerText:ticket_Draw[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    ticket_Draw[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 1.000000, ticket_Text);
	PlayerTextDrawFont              (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawLetterSize        (playerid, ticket_Draw[playerid], 0.300000, 1.200000);
	PlayerTextDrawTextSize          (playerid, ticket_Draw[playerid], 1000.000000, 17.000000);
	PlayerTextDrawSetOutline        (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawSetShadow         (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawAlignment         (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawColor             (playerid, ticket_Draw[playerid], -1);
	PlayerTextDrawBackgroundColor   (playerid, ticket_Draw[playerid], 255);
	PlayerTextDrawBoxColor          (playerid, ticket_Draw[playerid], 50);
	PlayerTextDrawUseBox            (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawSetProportional   (playerid, ticket_Draw[playerid], 1);
	PlayerTextDrawSetSelectable     (playerid, ticket_Draw[playerid], 0);
    return 1;
}

CMD:ticket(playerid, params[])
{
    if(ticket_Count == -1)
        return ChatMsg(playerid, RED, " » Muitos pedidos no momento, tente novamente em instantes...");

    new
        lastattacker,
        lastweapon;

    if(IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
        return ChatMsg(playerid, RED, " » Foi atacado, aguarde para usar isso.");

    if(sscanf(params, "s["#MAX_TICKET_LEN"]", ticket_HelpText[ticket_Count]))
        return ChatMsg(playerid, RED, " » Use /Ticket [Mensagem]");

    ticket_Beggar[ticket_Count] = playerid;
    ticket_Timestamp[ticket_Count] = gettime();

    PlayerTextDrawSetString(playerid, ticket_Draw[playerid], "~y~Aguardando atendimento...");
    PlayerTextDrawShow(playerid, ticket_Draw[playerid]);

    _UpdateTicket();

    return --ticket_Count;
}

hook OnAdminToggleDuty(playerid, bool:duty, bool:goback)
{
    if(duty)
        PlayerTextDrawShow(playerid, ticket_Draw[playerid]);
    else
        PlayerTextDrawHide(playerid, ticket_Draw[playerid]);
}

_UpdateTicket()
{
    ticket_Text = "~y~Tickets~n~";
    new timeformat[9];
    for(new i; i < MAX_TICKETS; i++)
    {
        if(IsPlayerConnected(ticket_Beggar[i]))
        {
            TimeFormat(Timestamp:ticket_Timestamp[i], ISO6801_TIME, timeformat);
            format(ticket_Text, sizeof(ticket_Text),
                "%s~w~%s ~g~%p(%d)~w~: %s~n~",
            ticket_Text, timeformat, ticket_Beggar[i], ticket_Beggar[i], ticket_HelpText[i]);
        }
    }
    
    foreach(new i : Player)
    {
        if(GetPlayerAdminLevel(i))
        {
            PlayerTextDrawSetString(i, ticket_Draw[i], ticket_Text);
            if(IsAdminOnDuty(i))
            {
                PlayerTextDrawShow(i, ticket_Draw[i]);
            }
        }
    }
}