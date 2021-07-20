
#include <YSI_Coding\y_hooks>

static PlayerBodyWorkRepair[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_ToolBox)
	{
		if(angle < 25.0 || angle > 335.0)
		{
			_BodyWorkRepair(playerid, vehicleid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

_BodyWorkRepair(playerid, vehicleid)
{
	if(PlayerBodyWorkRepair[playerid] != INVALID_VEHICLE_ID) {
		StopBodyWorkRepair(playerid);
		return 0;
	}

	new Float:health;
	GetVehicleHealth(vehicleid, health);

	if(health < VEHICLE_HEALTH_MAX - 5.0){
		ShowActionText(playerid, "Veiculo preisa estar mais consertado.", 2000);
		return 0;
	}

	StartHoldAction(playerid, 10000, 1);
	ShowActionText(playerid, "Reparando Lataria...", 10000);
	PlayerBodyWorkRepair[playerid] = vehicleid;
	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);

	return 1;
}

hook OnPlayerOpenInventory(playerid){
	StopBodyWorkRepair(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	StopBodyWorkRepair(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	StopBodyWorkRepair(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	StopBodyWorkRepair(playerid);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
	StopBodyWorkRepair(playerid);
	return 1;
}

StopBodyWorkRepair(playerid) {
	if(PlayerBodyWorkRepair[playerid] != INVALID_VEHICLE_ID) {
		StopHoldAction(playerid);
		PlayerBodyWorkRepair[playerid] = INVALID_VEHICLE_ID;
		ClearAnimations(playerid);
	}
}

hook OnHoldActionUpdate(playerid, progress){
	if(PlayerBodyWorkRepair[playerid] != INVALID_VEHICLE_ID) {
		if(GetPlayerTotalVelocity(playerid) > 1.0){
			StopBodyWorkRepair(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(PlayerBodyWorkRepair[playerid] != INVALID_VEHICLE_ID)
	{
		RepairVehicle(PlayerBodyWorkRepair[playerid]);
		SetVehicleHealth(PlayerBodyWorkRepair[playerid], VEHICLE_HEALTH_MAX - 1.0);
		ClearAnimations(playerid);
		PlayerBodyWorkRepair[playerid] = INVALID_VEHICLE_ID;
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

