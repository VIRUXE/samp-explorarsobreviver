#include <YSI_Coding\y_hooks>

/*==============================================================================

	Relatorio

==============================================================================*/

static
bool: 	RelatorioTempo[MAX_PLAYERS],
		RelatorioTempo2[MAX_PLAYERS],
bool:	RelatorioEnviado[MAX_PLAYERS],
bool:   RelatorioBlock[MAX_PLAYERS];

ACMD:blockrr[1](playerid, params[])
{
	new senderId;

	if(sscanf(params, "d", senderId)) 
		return ChatMsg(playerid, RED, " » Use /blockrr [id]");

    RelatorioBlock[senderId] = !RelatorioBlock[senderId];
		
	return ChatMsg(playerid, YELLOW, RelatorioBlock[senderId] ? " » Você bloqueou %p de usar o /relatorio!" : " » %p agora pode usar /relatorio", senderId);
}

ACMD:rrel[1](playerid, params[])
{
	new senderId, msg[200];

	if(sscanf(params, "ds[200]", senderId, msg)) 
		return ChatMsg(playerid, RED, " » Use /rr [id] [Mensagem]");

	if(RelatorioEnviado[senderId] == false) 
		return ChatMsg(playerid, RED, " » Esse player não enviou nenhum relatório ou já foi respondido.");

	if(!IsPlayerConnected(senderId)) 
		return ChatMsg(playerid, RED, " » Jogador não conectado.");

    ChatMsg(senderId, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");
	ChatMsg(senderId, GREEN, "[Relatório] %p(id:%d) respondeu: "C_WHITE"%s", playerid, playerid, msg);
	ChatMsg(senderId, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");
	ChatMsgAdmins(1, GREEN, " » %p (%d) respondeu o relatório de %p(id:%d): %s", playerid, playerid, senderId, senderId, msg);

	RelatorioEnviado[senderId] = RelatorioTempo[senderId] = false, RelatorioTempo2[senderId] = 100;
	return 1;
}

CMD:relatorio(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid))
		return ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");

    if(RelatorioTempo[playerid])
		return ChatMsg(playerid, RED, " » Aguarde"C_YELLOW" %d "C_RED"segundos para usar esse comando novamente.", RelatorioTempo2[playerid]);

	if(RelatorioBlock[playerid])
		return ChatMsg(playerid, RED, " » Aguarde para usar esse comando novamente.");

	new msg[200];

    if(sscanf(params, "s[200]", msg))
		return ChatMsg(playerid, RED, " » Use /Relatorio [Mensagem]");

    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
    ChatMsgAdmins(1, BLUE, "[Relatório]: %p (%d)"C_BLUE": "C_WHITE"%s", playerid, playerid, msg);
    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
	RelatorioTempo[playerid] = true;
    RelatorioTempo2[playerid] = 80;
    RelatorioEnviado[playerid] = true;

    defer RelatorioFalse(playerid);
    
	return ChatMsg(playerid, YELLOW, " » Relatório Enviado com Sucesso. Aguarde a administração do servidor.");
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
	    RelatorioTempo[playerid] = false;
}