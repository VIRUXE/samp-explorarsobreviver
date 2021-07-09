#include <YSI_Coding\y_hooks>

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = GetPlayerScore(playerid);
	modio_push(filename, _T<S,C,O,R>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];
	modio_read(filename, _T<S,C,O,R>, 1, data);
	SetPlayerScore(playerid, data[0]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	SetPlayerScore(playerid, 0);
}

ptask UpdatePlayerScore[60000](playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(IsPlayerUnfocused(playerid))
		return;

	SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
}

