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

	// Score
	SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);

	// Wanted Level
	switch(GetPlayerScore(playerid))
	{
		case 60:
		{
			SetPlayerWantedLevel(playerid, 1);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"1"C_YELLOW" hora. Tome cuidado.", playerid);
		}
		case 60 * 2:
		{
			SetPlayerWantedLevel(playerid, 2);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"2"C_YELLOW" horas. Deve estar trancado na base...", playerid);
		}
		case 60 * 3:
		{
			SetPlayerWantedLevel(playerid, 3);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"3"C_YELLOW" horas. Acho que esqueceram de mata-lo..", playerid);
		}
		case 60 * 4:
		{
			SetPlayerWantedLevel(playerid, 4);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"4"C_YELLOW" horas. Deve estar isolado nas montanhas.", playerid);
		}
		case 60 * 5:
		{
			SetPlayerWantedLevel(playerid, 5);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"5"C_YELLOW" horas. Deve valer apenas ser amigo deste :)", playerid);
		}
		case 60 * 6:
		{
			SetPlayerWantedLevel(playerid, 6);
			ChatMsgAll(RED, " » %P"C_YELLOW" ja esta vivo a "C_RED"6"C_YELLOW" horas. Alguem precisa resolver isso *-*", playerid);
		}

		case 60 * 7: ChatMsgAll(RED,
			" » %P"C_YELLOW" ja esta vivo a "C_RED"7"C_YELLOW" horas. Mate ele e consiga muitos itens! xD", playerid);

		case 60 * 8: ChatMsgAll(RED,
			" » %P"C_YELLOW" ja esta vivo a "C_RED"8"C_YELLOW" horas. Com certeza esta escondido dentro da base!", playerid);

		case 60 * 9: ChatMsgAll(RED,
			" » %P"C_YELLOW" ja esta vivo a "C_RED"9"C_YELLOW" horas. Uau, deve ter amizade com Bear Grylls", playerid);

		case 60 * 10: ChatMsgAll(RED,
			" » %P"C_YELLOW" ja esta vivo a "C_RED"9"C_YELLOW" horas. Uauu, este definitivamente é um especialista em sobrevivência!", playerid);
	}
	
	return;
}