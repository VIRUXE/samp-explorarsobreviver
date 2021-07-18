#include <YSI_Coding\y_hooks>

hook OnPlayerSave(playerid, filename[])
{
	new data[2];
	data[0] = GetPlayerScore(playerid);
	data[1] = GetPlayerWantedLevel(playerid);
	modio_push(filename, _T<S,C,O,R>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[2];
	modio_read(filename, _T<S,C,O,R>, 1, data);
	SetPlayerScore(playerid, data[0]);
	SetPlayerWantedLevel(playerid, data[1]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	SetPlayerScore(playerid, 0);
	SetPlayerWantedLevel(playerid, 0);
}

ptask UpdatePlayerScore[60000](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(IsPlayerUnfocused(playerid))
		return;

	if(IsPlayerRaidBlock(playerid))
		return;

	SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);

	if(GetPlayerScore(playerid) == 60) {
		SetPlayerWantedLevel(playerid, 1);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"1"C_YELLOW" hora, tome cuidado.", playerid);
	} else if(GetPlayerScore(playerid) == 2 * 60) {
		SetPlayerWantedLevel(playerid, 2);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"2"C_YELLOW" horas! Deve estar trancado na base..", playerid);
	} else if(GetPlayerScore(playerid) == 3 * 60) {
		SetPlayerWantedLevel(playerid, 3);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"3"C_YELLOW" horas! Acho que esqueceram de mata-lo.", playerid);
	} else if(GetPlayerScore(playerid) == 4 * 60) {
		SetPlayerWantedLevel(playerid, 4);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"4"C_YELLOW" horas! Deve estar isolalado nas montanhas.", playerid);
	} else if(GetPlayerScore(playerid) == 5 * 60) {
		SetPlayerWantedLevel(playerid, 5);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"5"C_YELLOW" horas! Deve valer apena ser amigo deste :)", playerid);
	} else if(GetPlayerScore(playerid) == 6 * 60) {
		SetPlayerWantedLevel(playerid, 6);
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"6"C_YELLOW" horas! Alguem precisa resolver isso *-*", playerid);
	}

	else if(GetPlayerScore(playerid) == 7 * 60) 
		ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"7"C_YELLOW" horas! Mate ele e consiga muitos itens! xD", playerid);
	else if(GetPlayerScore(playerid) == 8 * 60) 
		ChatMsgAll(YELLOW, ""C_RED" » %P"C_YELLOW" ja esta vivo a "C_RED"8"C_YELLOW" horas! Com certeza esta escondido dentro da base! Mate-o e ganhe muita coisa!", playerid);
	else if(GetPlayerScore(playerid) == 9 * 60) 
		ChatMsgAll(YELLOW, ""C_RED" » %P"C_YELLOW" ja esta vivo a "C_RED"9"C_YELLOW" horas! Com certeza esta escondido dentro da base! Mate-o e ganhe muita coisa!", playerid);
	else if(GetPlayerScore(playerid) == 10 * 60) 
		ChatMsgAll(YELLOW, ""C_RED" » %P"C_YELLOW" ja esta vivo a "C_RED"10"C_YELLOW" horas! Uauu, este definitivamente é um especialista em sobrevivência!", playerid);
}

