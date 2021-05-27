#include <YSI_Coding\y_hooks>

static Text3D: player_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};

hook OnPlayerSpawn(playerid)
{
	foreach(new i : Player)
		ShowPlayerNameTagForPlayer(playerid, i, IsPlayerMobile(playerid));
}

hook OnPlayerConnect(playerid)
{
	new name[30];
	GetPlayerName(playerid, name, 24);

	format(name, 30, "%s (%d)", name, playerid);

    player_Nametag[playerid] = CreateDynamic3DTextLabel(
		name,
		0xB8B8B8FF,
		0.0,
		0.0,
		0.2,
		gNameTagDistance,
		playerid,
		.testlos = 1
	);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(player_Nametag[playerid]);
	player_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;
	return 1;
}

