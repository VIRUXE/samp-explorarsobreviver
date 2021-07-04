#include <YSI_Coding\y_hooks>

/*==============================================================================

	Relatorio

==============================================================================*/

static
bool: 	RelatorioTempo[MAX_PLAYERS],
		RelatorioTempo2[MAX_PLAYERS],
bool:	RelatorioEnviado[MAX_PLAYERS],
bool:   RelatorioBlock[MAX_PLAYERS];

ACMD:blockrr[1](playerid, params[]){
	new prid;
	if(sscanf(params, "d", prid)) return ChatMsg(playerid, RED, " > Use /blockrr [id]");
    RelatorioBlock[prid] = !RelatorioBlock[prid];
    if(RelatorioBlock[prid]) ChatMsg(playerid, YELLOW, " > Você bloqueou %p de usar o /relatorio!", prid);
    else ChatMsg(playerid, YELLOW, " > %p agora pode usar /relatorio", prid);
	return 1;
}

ACMD:rr[1](playerid, params[])
{
	new prid, msg[200];

	if(sscanf(params, "ds[200]", prid, msg)) return ChatMsg(playerid, RED, " > Use /rr [id] [Mensagem]");

	if(RelatorioEnviado[prid] == false) return ChatMsg(playerid, RED, " > Esse player não enviou nenhum relatório ou já foi respondido.");

	if(!IsPlayerConnected(prid)) return ChatMsg(playerid, RED, " > Jogador não conectado.");

    ChatMsg(prid, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");

	new string[500];
	format(string, 500, "[Relatório] %p(id:%d) respondeu: "C_WHITE"%s", playerid, playerid, msg);
	ChatMsg(prid, GREEN, string);

	ChatMsg(prid, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");

	format(string, 500, " > %p(id:%d) respondeu o relatório de %p(id:%d): %s", playerid, playerid, prid, prid, msg);
	ChatMsgAdmins(1, GREEN, string);

	RelatorioEnviado[prid] = RelatorioTempo[prid] = false, RelatorioTempo2[prid] = 100;
	return 1;
}
CMD:relatorio(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}

    if(RelatorioTempo[playerid] == true)
	{
		new string[128];
		format(string, 128, " > Aguarde"C_YELLOW" %d "C_RED"segundos para usar esse comando novamente.", RelatorioTempo2[playerid]);
		ChatMsg(playerid, RED, string);
		return 1;
	}

	if(RelatorioBlock[playerid]) return ChatMsg(playerid, RED, " > Aguarde para usar esse comando novamente.");

	new msg[200];

    if(sscanf(params, "s[200]", msg)) return ChatMsg(playerid, RED, " > Use /Relatorio [Mensagem]");

    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
    ChatMsgAdmins(1, BLUE, "[Relatório]: %p(id:%d)"C_BLUE": "C_WHITE"%s", playerid, playerid, msg);
    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
	RelatorioTempo[playerid] = true;
    RelatorioTempo2[playerid] = 80;
    RelatorioEnviado[playerid] = true;

    defer RelatorioFalse(playerid);

    ChatMsg(playerid, YELLOW, " > Relatório Enviado com Sucesso. Aguarde a administração do servidor.");
	return 1;
}

hook OnPlayerConnect(playerid)
{
	RelatorioTempo2[playerid] = 0;
	RelatorioBlock[playerid] = false;
}

timer RelatorioFalse[1000](playerid)
{
	if(RelatorioTempo2[playerid] > 0)
	{
        RelatorioTempo2[playerid] --;
        defer RelatorioFalse(playerid);
	}
	else
	{
	    RelatorioTempo[playerid] = false;
	}
}