
#include <YSI_Coding\y_hooks>

static
			trunk_ContainerVehicle	[MAX_CONTAINER] = {INVALID_VEHICLE_ID, ...},
Container:	trunk_ContainerID		[MAX_VEHICLES] = {INVALID_CONTAINER_ID, ...},
			trunk_Locked			[MAX_VEHICLES],
			trunk_CurrentVehicle	[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};


/*==============================================================================

	Internal
	
==============================================================================*/

hook OnPlayerConnect(playerid)
{
	trunk_CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnVehicleCreated(vehicleid)
{
	new
		vehicletype,
		trunksize;

	vehicletype = GetVehicleType(vehicleid);
	trunksize = GetVehicleTypeTrunkSize(vehicletype);

	if(trunksize > 0)
	{
		trunk_ContainerID[vehicleid] = CreateContainer("porta-malas", trunksize);
		trunk_ContainerVehicle[trunk_ContainerID[vehicleid]] = vehicleid;
		trunk_Locked[vehicleid] = false;
	}
}


hook OnVehicleReset(oldid, newid)
{
	if(oldid != newid)
	{
		trunk_ContainerID[newid] = trunk_ContainerID[oldid];
		trunk_Locked[newid] = trunk_Locked[oldid];
		trunk_ContainerVehicle[trunk_ContainerID[oldid]] = INVALID_VEHICLE_ID;
		trunk_ContainerVehicle[trunk_ContainerID[newid]] = newid;
	}
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(155.0 < angle < 205.0)
	{
		if(IsValidContainer(GetVehicleContainer(vehicleid)))
		{
			if(IsVehicleTrunkLocked(vehicleid))
			{
				ShowActionText(playerid, ls(playerid, "TRUNKLOCKED", true), 3000);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			if(GetVehicleLockState(vehicleid) == E_LOCK_STATE_EXTERNAL)
			{
				ShowActionText(playerid, ls(playerid, "TRUNKLOCKED", true), 3000);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			if(IsValidItem(GetPlayerInteractingItem(playerid)))
				return Y_HOOKS_CONTINUE_RETURN_0;

			if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) == VEHICLE_CATEGORY_MOTORBIKE)
				return Y_HOOKS_CONTINUE_RETURN_0;

			if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) == VEHICLE_CATEGORY_PUSHBIKE)
				return Y_HOOKS_CONTINUE_RETURN_0;

			new Float:vehicleangle;

			GetVehicleZAngle(vehicleid, vehicleangle);

			VehicleBootState(vehicleid, 1);
			CancelPlayerMovement(playerid);
			SetPlayerFacingAngle(playerid, (vehicleangle-angle)-180.0);

			trunk_CurrentVehicle[playerid] = vehicleid;

			DisplayContainerInventory(playerid, GetVehicleContainer(vehicleid));

			HideActionText(playerid);

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	new vehicleid = trunk_ContainerVehicle[containerid];

	if(IsValidVehicle(vehicleid))
	{
		if(!IsPlayerAtVehicleTrunk(playerid, vehicleid))
		{
			printf("player has opened a trunk of vehicle %d without being near it.", vehicleid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		VehicleBootState(trunk_CurrentVehicle[playerid], 0);
		VehicleTrunkUpdateSave(playerid);
		trunk_CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		VehicleBootState(trunk_CurrentVehicle[playerid], 0);
		VehicleTrunkUpdateSave(playerid);
		trunk_CurrentVehicle[playerid] = INVALID_VEHICLE_ID;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(Container:containerid, slotid, playerid)
{
	if(IsPlayerConnected(playerid))
		VehicleTrunkUpdateSave(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

VehicleTrunkUpdateSave(playerid)
{
	if(IsValidVehicle(trunk_CurrentVehicle[playerid]))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		SaveVehicle(trunk_CurrentVehicle[playerid]);
		GetVehiclePos(trunk_CurrentVehicle[playerid], x, y, z);
		GetVehicleZAngle(trunk_CurrentVehicle[playerid], r);
		SetVehicleSpawnPoint(trunk_CurrentVehicle[playerid], x, y, z, r);
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock Container:GetVehicleContainer(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return INVALID_CONTAINER_ID;

	return trunk_ContainerID[vehicleid];
}

stock GetContainerTrunkVehicleID(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_VEHICLE_ID;

	return trunk_ContainerVehicle[containerid];
}

stock IsVehicleTrunkLocked(vehicleid)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	return trunk_Locked[vehicleid];
}

stock SetVehicleTrunkLock(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid))
		return 0;

	trunk_Locked[vehicleid] = toggle;
	return 1;
}

