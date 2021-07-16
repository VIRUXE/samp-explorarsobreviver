
#include <YSI_Coding\y_hooks>


new
PlayerBar:	ActionBar = INVALID_PLAYER_BAR_ID,
			HoldActionLimit[MAX_PLAYERS],
			HoldActionProgress[MAX_PLAYERS],
Timer:		HoldActionTimer[MAX_PLAYERS],
			HoldActionState[MAX_PLAYERS];


forward OnHoldActionUpdate(playerid, progress);
forward OnHoldActionFinish(playerid);


hook OnPlayerConnect(playerid)
{
	ActionBar = CreatePlayerProgressBar(playerid, 291.0, 390.0, 57.50, 5.19, GREY, 100.0, BAR_DIRECTION_RIGHT);
}

hook OnPlayerDisconnect(playerid, reason)
{
	StopHoldAction(playerid);
	DestroyPlayerProgressBar(playerid, ActionBar);
}

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
	StopHoldAction(playerid);


hook OnPlayerOpenInventory(playerid)
{
	defer t_StopHoldAction(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	defer t_StopHoldAction(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer t_StopHoldAction[100](playerid)
	StopHoldAction(playerid);

StartHoldAction(playerid, duration, startvalue = 0)
{
	if(HoldActionState[playerid] == 1)
		return 0;

	stop HoldActionTimer[playerid];
	HoldActionTimer[playerid] = repeat HoldActionUpdate(playerid);

	HoldActionLimit[playerid] = duration;
	HoldActionProgress[playerid] = startvalue;
	HoldActionState[playerid] = 1;

	SetPlayerProgressBarMaxValue(playerid, ActionBar, HoldActionLimit[playerid]);
	SetPlayerProgressBarValue(playerid, ActionBar, HoldActionProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	return 1;
}

StopHoldAction(playerid)
{
	if(HoldActionState[playerid] == 0)
		return 0;

	stop HoldActionTimer[playerid];
	HoldActionLimit[playerid] = 0;
	HoldActionProgress[playerid] = 0;
	HoldActionState[playerid] = 0;

	HidePlayerProgressBar(playerid, ActionBar);

	return 1;
}

timer HoldActionUpdate[100](playerid)
{
	if(HoldActionProgress[playerid] >= HoldActionLimit[playerid])
	{
		StopHoldAction(playerid);
		CallLocalFunction("OnHoldActionFinish", "d", playerid);
		return;
	}

	SetPlayerProgressBarMaxValue(playerid, ActionBar, HoldActionLimit[playerid]);
	SetPlayerProgressBarValue(playerid, ActionBar, HoldActionProgress[playerid]);
	ShowPlayerProgressBar(playerid, ActionBar);

	CallLocalFunction("OnHoldActionUpdate", "dd", playerid, HoldActionProgress[playerid]);

	HoldActionProgress[playerid] += 100;

	return;
}
