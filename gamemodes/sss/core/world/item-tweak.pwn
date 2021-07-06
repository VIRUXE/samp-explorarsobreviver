#include <YSI_Coding\y_hooks>


static

Item:		twk_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			twk_Tweaker[MAX_ITEM] = {INVALID_PLAYER_ID, ...},
Float:		twk_Origin[MAX_PLAYERS][3],
			twk_Locked[MAX_PLAYERS],
PlayerText:	twk_MoveF[MAX_PLAYERS],
PlayerText:	twk_MoveB[MAX_PLAYERS],
PlayerText:	twk_MoveL[MAX_PLAYERS],
PlayerText:	twk_MoveR[MAX_PLAYERS],
PlayerText:	twk_RotR[MAX_PLAYERS],
PlayerText:	twk_RotL[MAX_PLAYERS],
PlayerText:	twk_Unlock[MAX_PLAYERS],
PlayerText:	twk_Done[MAX_PLAYERS],
PlayerText: twk_Click[MAX_PLAYERS],
	   		twk_ClickTick[MAX_PLAYERS],
Timer: 		twk_TimerClick[MAX_PLAYERS];

forward OnItemTweakUpdate(playerid, itemid);
forward OnItemTweakFinish(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	twk_Item[playerid] = INVALID_ITEM_ID;
	_twk_Reset(playerid);
	_twk_BuildUI(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsValidItem(twk_Item[playerid]))
	{
		_twk_Commit(playerid);
	}
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock TweakItem(playerid, Item:itemid)
{
	new
		uuid[UUID_LEN],
		world,
		interior;

	GetItemUUID(itemid, uuid);

	if(twk_Item[playerid] != INVALID_ITEM_ID)
		err("twk_Item already set to %d", _:twk_Item[playerid]);

	log("[TWEAK] %p Tweaked item %d (%s)", playerid, _:itemid, uuid);

	GetItemWorld(itemid, world);
	GetItemInterior(itemid, interior);

	twk_Item[playerid] = itemid;
	twk_Tweaker[itemid] = playerid;
	GetItemPos(itemid, twk_Origin[playerid][0], twk_Origin[playerid][1], twk_Origin[playerid][2]);

	HidePlayerKeyActionUI(playerid);

	_twk_ShowUI(playerid);
	_twk_ToggleMouse(playerid, false);
	ShowHelpTip(playerid, ls(playerid, "TIPTWEAKITM"), 10000);
	CallLocalFunction("OnItemTweakUpdate", "dd", playerid, _:twk_Item[playerid]);
	return 1;
}

stock Item:GetPlayerTweakItem(playerid){
	return twk_Item[playerid];
}

/*==============================================================================

	Internal

==============================================================================*/


_twk_Reset(playerid)
{
	twk_Locked[playerid] = false;

	if(IsValidItem(twk_Item[playerid]))
		twk_Tweaker[twk_Item[playerid]] = INVALID_PLAYER_ID;

	twk_Item[playerid] = INVALID_ITEM_ID;

	_twk_HideUI(playerid);
}

_twk_Commit(playerid)
{
	if(!IsValidItem(twk_Item[playerid]))
		return 0;

	new
		uuid[UUID_LEN],
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		model;

	GetItemUUID(twk_Item[playerid], uuid);
	GetItemPos(twk_Item[playerid], x, y, z);
	GetItemRot(twk_Item[playerid], rx, ry, rz);
	GetItemTypeModel(GetItemType(twk_Item[playerid]), model);

	log("[TWEAK] %p Tweaked item %d (%s) %d (%f, %f, %f, %f, %f, %f)",
		playerid, _:twk_Item[playerid], uuid, model,
		x, y, z, rx, ry, rz);

	CallLocalFunction("OnItemTweakFinish", "dd", playerid, _:twk_Item[playerid]);

	_twk_HideUI(playerid);
	CancelSelectTextDraw(playerid);
	CancelPlayerMovement(playerid);
	ShowActionText(playerid, ls(playerid, "ITEMTWKFINI"), 5000);
	_twk_Reset(playerid);
	HideHelpTip(playerid);

	return 1;
}

_twk_ShowUI(playerid)
{
	PlayerTextDrawShow(playerid, twk_MoveF[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveB[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveL[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveR[playerid]);
	PlayerTextDrawShow(playerid, twk_RotR[playerid]);
	PlayerTextDrawShow(playerid, twk_RotL[playerid]);
	PlayerTextDrawShow(playerid, twk_Unlock[playerid]);
	PlayerTextDrawShow(playerid, twk_Done[playerid]);
}

_twk_HideUI(playerid)
{
	PlayerTextDrawHide(playerid, twk_MoveF[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveB[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveL[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveR[playerid]);
	PlayerTextDrawHide(playerid, twk_RotR[playerid]);
	PlayerTextDrawHide(playerid, twk_RotL[playerid]);
	PlayerTextDrawHide(playerid, twk_Unlock[playerid]);
	PlayerTextDrawHide(playerid, twk_Done[playerid]);
}

_twk_ToggleMouse(playerid, bool:toggle)
{
	if(toggle)
	{
		twk_Locked[playerid] = true;
		SelectTextDraw(playerid, 0xffff00ff);
		PlayerTextDrawSetString(playerid, twk_Unlock[playerid], ls(playerid, "ITEMTWKBTNM"));
	}
	else
	{
		twk_Locked[playerid] = false;
		CancelSelectTextDraw(playerid);
		PlayerTextDrawSetString(playerid, twk_Unlock[playerid], ls(playerid, "ITEMTWKBTNE"));
	}

	PlayerTextDrawColor(playerid, twk_Click[playerid], -1);
	stop twk_TimerClick[playerid];
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid){
	if(IsValidItem(twk_Item[playerid])) {
		PlayerTextDrawColor(playerid, twk_MoveF[playerid], -1);
		PlayerTextDrawColor(playerid, twk_MoveB[playerid], -1);
		PlayerTextDrawColor(playerid, twk_MoveL[playerid], -1);
		PlayerTextDrawColor(playerid, twk_MoveR[playerid], -1);
		PlayerTextDrawColor(playerid, twk_RotR[playerid], -1);
		PlayerTextDrawColor(playerid, twk_RotL[playerid], -1);

		if(playertextid == PlayerText:twk_Click[playerid] && (GetTickCount() - twk_ClickTick[playerid]) <= 200) {
			PlayerTextDrawColor(playerid, playertextid, 0xffff00ff);
			PlayerTextDrawShow(playerid, playertextid);
			stop twk_TimerClick[playerid];
			twk_TimerClick[playerid] = repeat TweakClick(playerid, _:playertextid);
		}
		else {
			if(PlayerText:playertextid != twk_Unlock[playerid] && PlayerText:playertextid != twk_Done[playerid])
				twk_ClickTick[playerid] = GetTickCount();
				
			twk_Click[playerid] = playertextid;
			stop twk_TimerClick[playerid];
			twk_TimerClick[playerid] = defer TweakClick(playerid, _:playertextid);
		}

		PlayerTextDrawShow(playerid, twk_MoveF[playerid]);
		PlayerTextDrawShow(playerid, twk_MoveB[playerid]);
		PlayerTextDrawShow(playerid, twk_MoveL[playerid]);
		PlayerTextDrawShow(playerid, twk_MoveR[playerid]);
		PlayerTextDrawShow(playerid, twk_RotR[playerid]);
		PlayerTextDrawShow(playerid, twk_RotL[playerid]);
	}
}

timer TweakClick[100](playerid, playertextid){
	if(PlayerText:playertextid == twk_Unlock[playerid])
		_twk_ToggleMouse(playerid, false);
		
	if(PlayerText:playertextid == twk_Done[playerid])
		_twk_Commit(playerid);

	if(PlayerText:playertextid == twk_MoveF[playerid])
		_twk_AdjustItemPos(playerid, 0.05, 0.0, 0.0);

	if(PlayerText:playertextid == twk_MoveB[playerid])
		_twk_AdjustItemPos(playerid, 0.05, 180.0, 0.0);

	if(PlayerText:playertextid == twk_MoveL[playerid])
		_twk_AdjustItemPos(playerid, 0.05, 90.0, 0.0);

	if(PlayerText:playertextid == twk_MoveR[playerid])
		_twk_AdjustItemPos(playerid, 0.05, -90.0, 0.0);

	if(PlayerText:playertextid == twk_RotR[playerid])
		_twk_AdjustItemPos(playerid, 0.0, 0.0, -1.5);

	if(PlayerText:playertextid == twk_RotL[playerid])
		_twk_AdjustItemPos(playerid, 0.0, 0.0, 1.5);
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
	 	if(twk_Locked[playerid])
		{
		    _twk_ToggleMouse(playerid, false);
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsValidItem(twk_Item[playerid]))
	{
		if(!twk_Locked[playerid] && newkeys & KEY_WALK)
			_twk_ToggleMouse(playerid, true);

		else if(twk_Locked[playerid] && newkeys & 16)
			_twk_Commit(playerid);
	}
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerDropItem(playerid, Item:itemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerGiveItem(playerid, targetid, Item:itemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerOpenInventory(playerid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

_twk_AdjustItemPos(playerid, Float:distance, Float:direction, Float:rotation)
{
	if(!IsPlayerConnected(playerid))
	{
		err("Called on invalid player %d", playerid);
		return 1;
	}

	if(!IsValidItem(twk_Item[playerid]))
	{
		err("Called on invalid item %d", _:twk_Item[playerid]);
		_twk_Reset(playerid);
		return 2;
	}

	new
		Float:new_x,
		Float:new_y,
		Float:new_z,
		Float:rx,
		Float:ry,
		Float:rz,
		modelid,
		Float:radius;

	GetItemPos(twk_Item[playerid], new_x, new_y, new_z);
	GetItemRot(twk_Item[playerid], rx, ry, rz);
	GetItemTypeModel(GetItemType(twk_Item[playerid]), modelid);
	CA_GetModelBoundingSphere(modelid, radius, radius, radius, radius);

	new_x += distance * floatsin(-(rz + direction), degrees);
	new_y += distance * floatcos(-(rz + direction), degrees);
	rz += rotation;

	if(Distance(new_x, new_y, new_z, twk_Origin[playerid][0], twk_Origin[playerid][1], twk_Origin[playerid][2]) > radius * 2)
	{
		stop twk_TimerClick[playerid];
		ShowActionText(playerid, ls(playerid, "ITEMTWKTFAR"), 6000);
		return 4;
	}

	SetItemPos(twk_Item[playerid], new_x, new_y, new_z);
	SetItemRot(twk_Item[playerid], rx, ry, rz);

	CallLocalFunction("OnItemTweakUpdate", "dd", playerid, _:twk_Item[playerid]);

	return 0;
}

_twk_BuildUI(playerid)
{
	twk_MoveF[playerid]				=CreatePlayerTextDraw(playerid, 540.000000, 130.000000, "+");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveF[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveF[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveF[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveF[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveF[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_MoveF[playerid], 554.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveF[playerid], true);

	twk_MoveB[playerid]				=CreatePlayerTextDraw(playerid, 540.000000, 170.000000, "-");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveB[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveB[playerid], 0.750000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveB[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveB[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveB[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_MoveB[playerid], 554.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveB[playerid], true);

	twk_MoveL[playerid]				=CreatePlayerTextDraw(playerid, 520.000000, 150.000000, "<");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveL[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveL[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveL[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveL[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveL[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_MoveL[playerid], 534.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveL[playerid], true);

	twk_MoveR[playerid]				=CreatePlayerTextDraw(playerid, 560.000000, 150.000000, ">");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveR[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveR[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveR[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveR[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveR[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_MoveR[playerid], 574.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveR[playerid], true);
																						
	twk_RotR[playerid]				=CreatePlayerTextDraw(playerid, 570.000000, 120.000000, "R");
	PlayerTextDrawBackgroundColor	(playerid, twk_RotR[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_RotR[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, twk_RotR[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_RotR[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_RotR[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_RotR[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_RotR[playerid], 584.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_RotR[playerid], true);

	twk_RotL[playerid]				=CreatePlayerTextDraw(playerid, 510.000000, 120.000000, "L");
	PlayerTextDrawBackgroundColor	(playerid, twk_RotL[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_RotL[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, twk_RotL[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_RotL[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_RotL[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_RotL[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_RotL[playerid], 524.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_RotL[playerid], true);

	twk_Unlock[playerid]			=CreatePlayerTextDraw(playerid, 547.000000, 200.000000, "Move");
	PlayerTextDrawAlignment			(playerid, twk_Unlock[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, twk_Unlock[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_Unlock[playerid], 0.400000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_Unlock[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_Unlock[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_Unlock[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_Unlock[playerid], 20.0, 80.0);
	PlayerTextDrawSetSelectable		(playerid, twk_Unlock[playerid], true);

	twk_Done[playerid]				=CreatePlayerTextDraw(playerid, 547.000000, 230.000000, "Done");
	PlayerTextDrawAlignment			(playerid, twk_Done[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, twk_Done[playerid], 175);
	PlayerTextDrawFont				(playerid, twk_Done[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_Done[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_Done[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_Done[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_Done[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_Done[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_Done[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_Done[playerid], 175);
	PlayerTextDrawTextSize			(playerid, twk_Done[playerid], 20.0, 80.0);
	PlayerTextDrawSetSelectable		(playerid, twk_Done[playerid], true);
}

/*==============================================================================

	Disallow

==============================================================================*/

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if(IsValidItem(twk_Item[playerid]))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid){
	if(IsValidItem(twk_Item[playerid]))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}