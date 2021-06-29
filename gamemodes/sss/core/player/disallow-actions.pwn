
#define IsBadInteract(%0) GetPlayerSpecialAction(%0) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(%0) || IsPlayerKnockedOut(%0) || GetPlayerAnimationIndex(%0) == 1381

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsBadInteract(targetid) || GetPlayerSpectateTarget(playerid) != INVALID_PLAYER_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetPlayerWeapon(targetid) != 0)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(IsBadInteract(playerid))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(IsBadInteract(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == ItemType:0)
		return Y_HOOKS_BREAK_RETURN_0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}
