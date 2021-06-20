#include <YSI_Coding\y_hooks>

static PlayerAliveTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
	PlayerAliveTime[playerid] = 0;
	
hook OnPlayerSave(playerid, filename[]){
	new data[1];
	data[0] = PlayerAliveTime[playerid];
	modio_push(filename, _T<S,C,O,R>, 1, data);
}

hook OnPlayerLoad(playerid, filename[]){
	new data[1];
	modio_read(filename, _T<S,C,O,R>, 1, data);
	PlayerAliveTime[playerid] = data[0];
	SetPlayerScore(playerid, PlayerAliveTime[playerid] / 60);
}

hook OnPlayerSpawnNewChar(playerid){
	PlayerAliveTime[playerid] = 0;
	SetPlayerScore(playerid, 0);
}

ptask UpdatePlayerScore[60000](playerid){
	PlayerAliveTime[playerid] ++;
	if(PlayerAliveTime[playerid] >= 60) 
		SetPlayerScore(playerid, PlayerAliveTime[playerid] / 60);
}

