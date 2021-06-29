
#include <YSI_Coding\y_hooks>


static
	PlayerText:VersionInfo[MAX_PLAYERS] = PlayerText:INVALID_TEXT_DRAW,
	bool:ShowVersionInfo[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	ShowVersionInfo[playerid] = true;

	VersionInfo[playerid]			=CreatePlayerTextDraw(playerid, 600.000000, 2.000000, "www.southcla.ws");
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
		//tickrate = GetServerTickRate(),
		//colour[4],
		string[128];

	//if(tickrate < 150)
		//colour = "~r~";

	/*
		Note:
		DO NOT REMOVE OFFICIAL WEBSITE LINK.
		Write your own website into the settings.ini file.
	*/
	//format(string, sizeof(string), "%sBuild %d - scavengesurvive.com - %s ~n~ Tick: %d Ping: %d Pkt Loss: %.2f", colour, gBuildNumber, gWebsiteURL, tickrate, GetPlayerPing(playerid), NetStats_PacketLossPercent(playerid));
	format(string, sizeof(string), "%s", gWebsiteURL);

	PlayerTextDrawSetString(playerid, VersionInfo[playerid], string);
	PlayerTextDrawShow(playerid, VersionInfo[playerid]);

	return;
}

stock ToggleVersionInfo(playerid, bool:toggle)
{
	ShowVersionInfo[playerid] = toggle;

	if(toggle)
		PlayerTextDrawShow(playerid, VersionInfo[playerid]);

	else
		PlayerTextDrawHide(playerid, VersionInfo[playerid]);
}
