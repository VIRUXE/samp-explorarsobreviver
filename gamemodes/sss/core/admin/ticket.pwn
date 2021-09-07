#include <YSI_Coding\y_hooks>

#define MAX_TICKETS         10
#define MAX_TICKET_LEN      64

static 
ticket_HelpText[MAX_TICKETS][MAX_TICKET_LEN],
ticket_Beggar[MAX_TICKETS] = {INVALID_PLAYER_ID, ...},
Timestamp:ticket_Timestamp[MAX_TICKETS],
ticket_Text[MAX_TICKETS * (MAX_TICKET_LEN + MAX_PLAYER_NAME + 12)] = "~w~Tickets",
ticket_Count,
PlayerText:ticket_Draw[MAX_PLAYERS],
ticket_Helping[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...};

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

hook OnPlayerDisconnect(playerid, reason)
{
    ticket_Helping[playerid] = INVALID_PLAYER_ID;
    PlayerTextDrawDestroy(playerid, ticket_Draw[playerid]);
}

CMD:ticket(playerid, params[])
{
    if(ticket_Count == MAX_TICKETS - 1)
        return ChatMsg(playerid, RED, " » Muitos pedidos no momento, tente novamente em instantes...");

    if(IsPlayerConnected(ticket_Helping[playerid]))
        return ChatMsg(playerid, RED, " » Ja esta em atendimento");

    new
        lastattacker,
        lastweapon;

    if(IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
        return ChatMsg(playerid, RED, " » Foi atacado, aguarde para usar isso.");

    if(sscanf(params, "s["#MAX_TICKET_LEN"]", ticket_HelpText[ticket_Count]))
        return ChatMsg(playerid, RED, " » Use /Ticket [Mensagem]");

    ticket_Beggar[ticket_Count] = playerid;
    ticket_Timestamp[ticket_Count] = Now();

    PlayerTextDrawSetString(playerid, ticket_Draw[playerid], "~y~Aguardando atendimento...");
    PlayerTextDrawShow(playerid, ticket_Draw[playerid]);

    ++ticket_Count;

    _UpdateTicket();

    return 1;
}

ACMD:helper[3](playerid, params[])
{
    if(!IsAdminOnDuty(playerid))
        return 6;

    new ticketid = strval(params);

    if(!IsPlayerConnected(ticket_Beggar[ticketid]))
    {
        _UpdateTicket();
        return ChatMsg(playerid, RED, " » Jogador não conectado, atualizando ticket...");
    }

    if(IsPlayerConnected(ticket_Helping[ticket_Beggar[ticketid]]))
        return ChatMsg(playerid, RED, " » Jogador em atendimento.");

    if(IsPlayerConnected(ticket_Helping[playerid]))
        return ChatMsg(playerid, RED, " » Voce já está atendendo um jogador.");

    new
        lastattacker,
        lastweapon;

    if(IsPlayerCombatLogging(ticket_Beggar[ticketid], lastattacker, Item:lastweapon))
        return ChatMsg(playerid, RED, " » O jogador foi atacado, aguarde para ajuda-lo.");

    ticket_Helping[ticket_Beggar[ticketid]] = playerid;
    ticket_Helping[playerid] = ticket_Beggar[ticketid];

    PlayerTextDrawSetString(ticket_Beggar[ticketid], ticket_Draw[ticket_Beggar[ticketid]], "_~n~~g~Em atendimento!");
    PlayerTextDrawShow(ticket_Beggar[ticketid], ticket_Draw[ticket_Beggar[ticketid]]);

    TeleportPlayerToPlayer(playerid, ticket_Beggar[ticketid]);

    --ticket_Count;

    _UpdateTicket();

    return 1;
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
    new timeformat[6];
    for(new i; i < ticket_Count; i++)
    {
        if(!IsPlayerConnected(ticket_Beggar[i]))
        {
            ticket_Beggar[i] = INVALID_PLAYER_ID;
        }
        else if(!IsPlayerConnected(ticket_Helping[ticket_Beggar[i]]))
        {
            TimeFormat(ticket_Timestamp[i], "%H:%M", timeformat);
            format(ticket_Text, sizeof(ticket_Text),
                "%s~w~%i. %s ~g~%p(%d)~w~: %s~n~",
            ticket_Text, i, timeformat, ticket_Beggar[i], ticket_Beggar[i], ticket_HelpText[i]);
        }
    }
    
    foreach(new i : Player)
    {
        if(GetPlayerAdminLevel(i) && !IsPlayerConnected(ticket_Helping[i]))
        {
            PlayerTextDrawSetString(i, ticket_Draw[i], ticket_Text);
            if(IsAdminOnDuty(i))
            {
                PlayerTextDrawShow(i, ticket_Draw[i]);
            }
        }
    }
}

stock GetPlayerHelper(playerid)
    return IsPlayerConnected(playerid) ? -1 : ticket_Helping[playerid];