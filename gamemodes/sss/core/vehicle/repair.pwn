
#include <YSI_Coding\y_hooks>


static
		fix_TargetVehicle[MAX_PLAYERS],
Float:	fix_Progress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(angle < 25.0 || angle > 335.0)
	{
		new
			Float:vehiclehealth,
			ItemType:itemtype;

		GetVehicleHealth(vehicleid, vehiclehealth);
		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Wrench)
		{
			CancelPlayerMovement(playerid);

			if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_2)
				StartRepairingVehicle(playerid, vehicleid);
			else
				NeedAToolInfo(playerid, vehiclehealth);

			return Y_HOOKS_BREAK_RETURN_1;
		}

		else if(itemtype == item_Screwdriver)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
				StartRepairingVehicle(playerid, vehicleid);
			else
				NeedAToolInfo(playerid, vehiclehealth);

			return Y_HOOKS_BREAK_RETURN_1;
		}	

		else if(itemtype == item_Hammer)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
				StartRepairingVehicle(playerid, vehicleid);
			else
				NeedAToolInfo(playerid, vehiclehealth);

			return Y_HOOKS_BREAK_RETURN_1;
		}

		else if(itemtype == item_Spanner)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
				StartRepairingVehicle(playerid, vehicleid);
			else
				NeedAToolInfo(playerid, vehiclehealth);

			return Y_HOOKS_BREAK_RETURN_1;
		}

		else if(itemtype == item_Wheel)
		{
			CancelPlayerMovement(playerid);
			ShowActionText(playerid, ls(playerid, "INTERACTWHE"), 5000);
		}

		else if(itemtype == item_Headlight)
		{
			CancelPlayerMovement(playerid);
			ShowLightList(playerid, vehicleid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartRepairingVehicle(playerid, vehicleid)
{
	if(IsValidVehicle(fix_TargetVehicle[playerid])) {
		StopRepairingVehicle(playerid);
	} else {
		GetVehicleHealth(vehicleid, fix_Progress[playerid]);

		if(fix_Progress[playerid] >= 990.0)
			return 0;

		SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);
		
		ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
		VehicleBonnetState(fix_TargetVehicle[playerid], 1);
		StartHoldAction(playerid, 50000, floatround(fix_Progress[playerid] * 50));

		ShowActionText(playerid, ls(playerid, "REPAIRVEH"), 7000, 100);
		
		fix_TargetVehicle[playerid] = vehicleid;
	}
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
	if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(GetPlayerTotalVelocity(playerid) > 1.0){
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		if(!IsValidItemType(itemtype))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		if(!IsPlayerInVehicleArea(playerid, fix_TargetVehicle[playerid]) || !IsValidVehicle(fix_TargetVehicle[playerid]))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		if(CompToolHealth(itemtype, fix_Progress[playerid]))
		{
			new mult = 2000;
			mult = GetPlayerSkillTimeModifier(playerid, mult, "Repair");
			fix_Progress[playerid] += (float(mult) / 1000.0);

			if(fix_Progress[playerid] > 990.0){
				PlayerGainSkillExperience(playerid, "Repair");
				StopRepairingVehicle(playerid);
				fix_Progress[playerid] = 990.0;
				NeedAToolInfo(playerid, fix_Progress[playerid]);
			}

			SetVehicleHealth(fix_TargetVehicle[playerid], fix_Progress[playerid]);
			SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);	
		}
		else
		{
			PlayerGainSkillExperience(playerid, "Repair");
			StopRepairingVehicle(playerid);
			NeedAToolInfo(playerid, fix_Progress[playerid]);
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

NeedAToolInfo(playerid, Float:vehiclehealth){
	if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_2)
		ShowActionText(playerid, ls(playerid, "NEEDAWRENC"), 3000, 100);
	else if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
		ShowActionText(playerid, ls(playerid, "NEEDASCREW"), 3000, 100);
	else if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
		ShowActionText(playerid, ls(playerid, "NEEDAHAMER"), 3000, 100);
	else if(vehiclehealth <= VEHICLE_HEALTH_MAX - 2.0)
		ShowActionText(playerid, ls(playerid, "NEEDSPANER"), 3000, 100);
}

CompToolHealth(ItemType:itemtype, Float:health)
{
	if(health - 2.0 <= VEHICLE_HEALTH_CHUNK_2)
	{
		if(itemtype == item_Wrench)
			return 1;
	}
	else if(health - 2.0 <= VEHICLE_HEALTH_CHUNK_3)
	{
		if(itemtype == item_Screwdriver)
			return 1;
	}
	else if(health - 2.0 <= VEHICLE_HEALTH_CHUNK_4)
	{
		if(itemtype == item_Hammer)
			return 1;
	}
	else if(health - 2.0 <= VEHICLE_HEALTH_MAX)
	{
		if(itemtype == item_Spanner)
			return 1;
	}

	return 0;
}
