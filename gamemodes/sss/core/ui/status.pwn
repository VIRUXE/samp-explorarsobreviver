#include <YSI\y_hooks>


static
	PlayerText:VersionInfo[MAX_PLAYERS] = PlayerText:INVALID_TEXT_DRAW,
	bool:ShowVersionInfo[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	ShowVersionInfo[playerid] = true;

	VersionInfo[playerid]			=CreatePlayerTextDraw(playerid, 635.000000, 2.000000, "Status Text");
	PlayerTextDrawAlignment			(playerid, VersionInfo[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, VersionInfo[playerid], 255);
	PlayerTextDrawFont				(playerid, VersionInfo[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, VersionInfo[playerid], 0.240000, 1.000000);
	PlayerTextDrawColor				(playerid, VersionInfo[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, VersionInfo[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, VersionInfo[playerid], 1);
}

hook OnPlayerScriptUpdate(playerid)
{
	if(!ShowVersionInfo[playerid])
		return;

	new
		tickrate = GetServerTickRate(),
		colour[4],
		string[128];

	if(tickrate < 150)
		colour = "~r~";

	format(string, sizeof(string), "Scavenge and Survive by Southclaws~n~%sTick: %d Ping: %d Pkt Loss: %.2f", colour, tickrate, GetPlayerPing(playerid), NetStats_PacketLossPercent(playerid));

	PlayerTextDrawSetString(playerid, VersionInfo[playerid], string);
	PlayerTextDrawShow(playerid, VersionInfo[playerid]);

	return;
}

stock ToggleVersionInfo(playerid, bool:toggle) // Level 5 admin cmd
{
	ShowVersionInfo[playerid] = toggle;

	if(toggle)
		PlayerTextDrawShow(playerid, VersionInfo[playerid]);
	else
		PlayerTextDrawHide(playerid, VersionInfo[playerid]);
}
