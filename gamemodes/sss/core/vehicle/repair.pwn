#include <YSI\y_hooks>


static
		fix_TargetVehicle[MAX_PLAYERS],
Float:	fix_Progress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerConnect] in /gamemodes/sss/core/vehicle/repair.pwn");

	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	dbg("global", LOG_CORE, "[OnPlayerInteractVehicle] in /gamemodes/sss/core/vehicle/repair.pwn");

	if(angle < 25.0 || angle > 335.0)
	{
		new
			Float:vehiclehealth,
			ItemType:itemtype;

		GetVehicleHealth(vehicleid, vehiclehealth);
		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Wrench)
		{
			if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_2 || VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}	
		else if(itemtype == item_Screwdriver)
		{
			if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}	
		else if(itemtype == item_Hammer)
		{
			if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, ls(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}
		else if(itemtype == item_Wheel)
		{
			CancelPlayerMovement(playerid);
			//ShowActionText(playerid, ls(playerid, "INTERACTWHE", true), 5000);
			ShowActionText(playerid, ls(playerid, "INTERACTWHE", true), 5000);
		}
		else if(itemtype == item_Headlight)
		{
			CancelPlayerMovement(playerid);
			ShowLightList(playerid, vehicleid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", LOG_CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/vehicle/repair.pwn");

	if(oldkeys & 16)
	{
		StopRepairingVehicle(playerid);
		StopRefuellingVehicle(playerid);
	}
}

StartRepairingVehicle(playerid, vehicleid)
{
	GetVehicleHealth(vehicleid, fix_Progress[playerid]);

	if(fix_Progress[playerid] >= 990.0)
	{
		return 0;
	}

	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	VehicleBonnetState(fix_TargetVehicle[playerid], 1);
	StartHoldAction(playerid, 50000, floatround(fix_Progress[playerid] * 50));

	fix_TargetVehicle[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid)
{
	if(fix_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	if(fix_Progress[playerid] > 990.0)
	{
		SetVehicleHealth(fix_TargetVehicle[playerid], 990.0);
	}

	VehicleBonnetState(fix_TargetVehicle[playerid], 0);
	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{
	dbg("global", LOG_CORE, "[OnHoldActionUpdate] in /gamemodes/sss/core/vehicle/repair.pwn");

	if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		if(!IsValidItemType(itemtype))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(!IsPlayerInVehicleArea(playerid, fix_TargetVehicle[playerid]) || !IsValidVehicle(fix_TargetVehicle[playerid]))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(CompToolHealth(itemtype, fix_Progress[playerid]))
		{
			new mult = 2000;
			mult = GetPlayerSkillTimeModifier(playerid, mult, "Repair");
			fix_Progress[playerid] += (float(mult) / 1000.0);
			SetVehicleHealth(fix_TargetVehicle[playerid], fix_Progress[playerid]);
			SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);	
		}
		else
		{
			PlayerGainSkillExperience(playerid, "Repair");
			StopRepairingVehicle(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

CompToolHealth(ItemType:itemtype, Float:health)
{
	if(health <= VEHICLE_HEALTH_CHUNK_2 - 2.0)
	{
		if(itemtype == item_Wrench)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_3 - 2.0)
	{
		if(itemtype == item_Screwdriver)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_4 - 2.0)
	{
		if(itemtype == item_Hammer)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= health <= VEHICLE_HEALTH_MAX - 2.0)
	{
		if(itemtype == item_Wrench)
			return 1;
	}

	return 0;
}
