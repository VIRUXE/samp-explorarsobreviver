#include <YSI\y_hooks>


static
	cro_TargetVehicle[MAX_PLAYERS],
	cro_OpenType[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerConnect] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	dbg("global", LOG_CORE, "[OnPlayerInteractVehicle] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		if(GetVehicleLockState(vehicleid) == E_LOCK_STATE_EXTERNAL)
		{
			ShowActionText(playerid, ls(playerid, "LOCKBREAKNO"), 8000);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(225.0 < angle < 315.0)
		{
			if(StartBreakingVehicleLock(playerid, vehicleid, 0))
				return Y_HOOKS_BREAK_RETURN_1;
		}

		if(155.0 < angle < 205.0)
		{
			if(StartBreakingVehicleLock(playerid, vehicleid, 1))
				return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", LOG_CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(oldkeys & 16)
	{
		StopBreakingVehicleLock(playerid);
	}
}

StartBreakingVehicleLock(playerid, vehicleid, type)
{
	if(type == 0)
	{
		if(GetVehicleLockState(vehicleid) == E_LOCK_STATE_OPEN)
			return 0;

		cro_OpenType[playerid] = 0;
		ShowActionText(playerid, ls(playerid, "LOCKBREAKDR"), 6000);
	}

	if(type == 1)
	{
		if(!IsVehicleTrunkLocked(vehicleid))
			return 0;

		cro_OpenType[playerid] = 1;
		ShowActionText(playerid, ls(playerid, "LOCKBREAKTR"), 6000);
	}

	cro_TargetVehicle[playerid] = vehicleid;
	ApplyAnimation(playerid, "POLICE", "DOOR_KICK", 3.0, 1, 1, 1, 0, 0);
	StartHoldAction(playerid, 3000);

	return 1;
}

StopBreakingVehicleLock(playerid)
{
	if(cro_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	cro_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(!IsValidVehicle(cro_TargetVehicle[playerid]) || !IsPlayerInVehicleArea(playerid, cro_TargetVehicle[playerid]))
		{
			StopBreakingVehicleLock(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		SetPlayerToFaceVehicle(playerid, cro_TargetVehicle[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", LOG_CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/vehicle/lock-break.pwn");

	if(cro_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(cro_OpenType[playerid] == 0)
		{
			SetVehicleExternalLock(cro_TargetVehicle[playerid], E_LOCK_STATE_OPEN);
		}
		if(cro_OpenType[playerid] == 1)
		{
			SetVehicleTrunkLock(cro_TargetVehicle[playerid], 0);
		}

		StopBreakingVehicleLock(playerid);			

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}
