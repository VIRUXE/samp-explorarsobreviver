
#include <YSI_Coding\y_hooks>

static Text:clock_td[2];

hook OnScriptInit() {
	clock_td[0] = TextDrawCreate(-40.000000, 313.000000, "Preview_Model");
	TextDrawFont			(clock_td[0], 5);
	TextDrawLetterSize		(clock_td[0], 0.5, 2.000000);
	TextDrawTextSize		(clock_td[0], 166.500000, 142.500000);
	TextDrawColor			(clock_td[0], -1);
	TextDrawBackgroundColor	(clock_td[0], 0);
	TextDrawSetPreviewModel	(clock_td[0], 19039);
	TextDrawSetPreviewRot	(clock_td[0], -50.000000, -91.000000, -30.000000, 0.750000);

	clock_td[1] = TextDrawCreate(101.000000, 372.000000, "00:00");
	TextDrawFont			(clock_td[1], 3);
	TextDrawLetterSize		(clock_td[1], 0.5, 2.0);
	TextDrawTextSize		(clock_td[1], 400.000000, 17.000000);
	TextDrawSetOutline		(clock_td[1], 2);
	TextDrawSetShadow		(clock_td[1], 0);
	TextDrawAlignment		(clock_td[1], 2);
	TextDrawColor			(clock_td[1], -1);
	TextDrawBackgroundColor	(clock_td[1], 255);
	TextDrawSetProportional	(clock_td[1], 1);
	TextDrawSetSelectable	(clock_td[1], 0);
}

ShowClockForPlayer(playerid) {
	if(PlayerHasClock(playerid)) {
		new str[6], hour, minute;
		GetServerTime(hour, minute);
		format(str, 6, "%02d:%02d", hour, minute);
		TextDrawSetString(clock_td[1], str);
		TextDrawShowForPlayer(playerid, clock_td[0]);
		TextDrawShowForPlayer(playerid, clock_td[1]);
	}
}

HideClockForPlayer(playerid) {
	TextDrawHideForPlayer(playerid, clock_td[0]);
	TextDrawHideForPlayer(playerid, clock_td[1]);
}

hook OnPlayerOpenedInventory(playerid)
	ShowClockForPlayer(playerid);

hook OnPlayerOpenedContainer(playerid, Container:containerid)
	ShowClockForPlayer(playerid);

hook OnPlayerCloseInventory(playerid) {
	HideClockForPlayer(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid) {
	HideClockForPlayer(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

bool:PlayerHasClock(playerid) {
	new Item:itemid = GetPlayerItem(playerid);
	
	if(GetItemType(itemid) == item_Clock)
		return true;

	for(new i; i < MAX_INVENTORY_SLOTS; i++){
		GetInventorySlotItem(playerid, i, itemid);

		if(!IsValidItem(itemid))
			break;

		if(GetItemType(itemid) == item_Clock)
			return true;
	}

	if(IsValidItem(GetPlayerBagItem(playerid))){
		new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));
		if(IsValidContainer(containerid)) {
			new itemcount;
			GetContainerItemCount(containerid, itemcount);
			for(new i = itemcount - 1; i > -1; i--)
			{
				GetContainerSlotItem(containerid, i, itemid);
				
				if(GetItemType(itemid) == item_Clock)
					return true;
			}
		}
	}

	return false;
}