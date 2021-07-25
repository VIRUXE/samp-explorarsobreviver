#include <YSI_Coding\y_hooks>

hook OnPlayerSave(playerid, filename[])
{
	new data[2];
	data[0] = GetPlayerScore(playerid);
	data[1] = GetPlayerWantedLevel(playerid);
	modio_push(filename, _T<S,C,O,R>, 2, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[2];
	modio_read(filename, _T<S,C,O,R>, 2, data);
	SetPlayerScore(playerid, data[0]);
	SetPlayerWantedLevel(playerid, data[1]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	SetPlayerScore(playerid, 0);
	SetPlayerWantedLevel(playerid, 0);
}

ptask UpdatePlayerScore[MIN(1)](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(IsPlayerUnfocused(playerid))
		return;

	if(IsPlayerRaidBlock(playerid))
		return;

	if(IsPlayerInTutorial(playerid))
		return;

	new
		score = GetPlayerScore(playerid),
		horasVivo = score / 60,
		msg[71];

	if(horasVivo >= 1 && horasVivo <= 6)
		SetPlayerWantedLevel(playerid, horasVivo);

	SetPlayerScore(playerid, score++);

	switch(horasVivo)
	{
		case 1: msg = "Tome cuidado.";
		case 2: msg = "Deve estar trancado na base...";
		case 3:	msg = "Acho que esqueceram de mata-lo..";
		case 4: msg = "Deve estar isolado nas montanhas";
		case 5: msg = "Deve valer apenas ser amigo deste :)";
		case 6: msg = "Alguem precisa resolver isso *-*";
		case 7: msg = "Mate ele e consiga muitos itens! xD";
		case 8: msg = "Com certeza esta escondido dentro da base! Mate-o e ganhe muita coisa!";
		case 9: msg = "Caramba! este precisa ir no Largados e Pelados.";
		case 10: msg = "Uauu, este definitivamente é um especialista em sobrevivência!";
	}
	ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"%d"C_YELLOW" %s. %s", playerid, horasVivo, horasVivo > 1 ? "horas" : "hora", msg);
}