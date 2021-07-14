
#include <YSI_Coding\y_hooks>

static Text:clock_td[2];

hook OnScriptInit() {
	clock_td[0] = TextDrawCreate(-40.000000, 313.000000, "Preview_Model");
	TextDrawFont(clock_td[0], 5);
	TextDrawLetterSize(clock_td[0], 0.600000, 2.000000);
	TextDrawTextSize(clock_td[0], 166.500000, 142.500000);
	TextDrawSetOutline(clock_td[0], 0);
	TextDrawSetShadow(clock_td[0], 0);
	TextDrawAlignment(clock_td[0], 1);
	TextDrawColor(clock_td[0], -1);
	TextDrawBackgroundColor(clock_td[0], 0);
	TextDrawBoxColor(clock_td[0], 255);
	TextDrawUseBox(clock_td[0], 0);
	TextDrawSetProportional(clock_td[0], 1);
	TextDrawSetSelectable(clock_td[0], 0);
	TextDrawSetPreviewModel(clock_td[0], 19039);
	TextDrawSetPreviewRot(clock_td[0], -50.000000, -91.000000, -30.000000, 0.750000);
	TextDrawSetPreviewVehCol(clock_td[0], 1, 1);

	clock_td[1] = TextDrawCreate(101.000000, 372.000000, "00:00");
	TextDrawFont(clock_td[1], 3);
	TextDrawLetterSize(clock_td[1], 0.554166, 2.449999);
	TextDrawTextSize(clock_td[1], 400.000000, 17.000000);
	TextDrawSetOutline(clock_td[1], 2);
	TextDrawSetShadow(clock_td[1], 0);
	TextDrawAlignment(clock_td[1], 2);
	TextDrawColor(clock_td[1], -1);
	TextDrawBackgroundColor(clock_td[1], 255);
	TextDrawBoxColor(clock_td[1], 50);
	TextDrawUseBox(clock_td[1], 0);
	TextDrawSetProportional(clock_td[1], 1);
	TextDrawSetSelectable(clock_td[1], 0);
}

hook OnPlayerOpenInventory(playerid)
	ShowPlayerClock(playerid);

hook OnPlayerOpenedContainer(playerid, Container:containerid)
	ShowPlayerClock(playerid);

hook OnPlayerCloseInventory(playerid)
	HidePlayerClock(playerid);

hook OnPlayerCloseContainer(playerid, Container:containerid)
	HidePlayerClock(playerid);

ShowPlayerClock(playerid){
	new str[6], hour, minute;
	GetServerTime(hour, minute);
	format(str, 6, "%02d:%02d", hour, minute);
	TextDrawSetString(clock_td[1], str);
	TextDrawShowForPlayer(playerid, clock_td[0]);
	TextDrawShowForPlayer(playerid, clock_td[1]);
}

HidePlayerClock(playerid){
	TextDrawHideForPlayer(playerid, clock_td[0]);
	TextDrawHideForPlayer(playerid, clock_td[1]);
}