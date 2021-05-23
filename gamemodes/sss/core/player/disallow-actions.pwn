#define IsBadInteract(%0) GetPlayerSpecialAction(%0) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(%0) || IsPlayerKnockedOut(%0) || GetPlayerAnimationIndex(%0) == 1381

hook OnPlayerPickUpItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerPickUpItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerGiveItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsBadInteract(targetid) || GetPlayerSpectateTarget(playerid) != INVALID_PLAYER_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetPlayerWeapon(targetid) != 0)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
{
	dbg("global", LOG_CORE, "[OnItemRemoveFromCnt] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	dbg("global", LOG_CORE, "[OnPlayerOpenContainer] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(itemid)
{
	dbg("global", LOG_CORE, "[OnItemCreate] in /gamemodes/sss/core/player/disallow-actions.pwn");

	if(GetItemType(itemid) == ItemType:0)
		return Y_HOOKS_BREAK_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}
