
#include <YSI_Coding\y_hooks>

#define INVALID_FUEL_OUTLET_ID	(-1)
#define MAX_FUEL_LOCATIONS		(90)


enum E_FUEL_DATA
{
			fuel_state,
Button:		fuel_buttonId,
Float:		fuel_capacity,
Float:		fuel_amount,
Float:		fuel_posX,
Float:		fuel_posY,
Float:		fuel_posZ
}


new
			fuel_Data[MAX_FUEL_LOCATIONS][E_FUEL_DATA],
			fuel_Total,
			fuel_CurrentFuelOutlet[MAX_PLAYERS],
			fuel_CurrentlyRefuelling[MAX_PLAYERS],
			fuel_ButtonFuelOutlet[BTN_MAX] = {INVALID_FUEL_OUTLET_ID, ...};


hook OnGameModeInit()
{
	// BC
	CreateFuelOutlet(603.48438, 1707.23438, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(606.89844, 1702.21875, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(610.25000, 1697.26563, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(613.71875, 1692.26563, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(617.12500, 1687.45313, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(620.53125, 1682.46094, 6.17969, 2.0, 130.0, frandom(40));
	CreateFuelOutlet(624.04688, 1677.60156, 6.17969, 2.0, 130.0, frandom(40));
	// FC
	CreateFuelOutlet(-2246.7031, -2559.7109, 31.0625, 2.0, 100.0, frandom(50.0));
	CreateFuelOutlet(-2241.7188, -2562.2891, 31.0625, 2.0, 100.0, frandom(50.0));
	CreateFuelOutlet(-1600.6719, -2707.8047, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1603.9922, -2712.2031, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1607.3047, -2716.6016, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1610.6172, -2721.0000, 47.9297, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-85.2422, -1165.0313, 2.6328, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-90.1406, -1176.6250, 2.6328, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-92.1016, -1161.7891, 2.9609, 2.0, 130.0, frandom(40.0));
	CreateFuelOutlet(-97.0703, -1173.7500, 3.0313, 2.0, 130.0, frandom(40.0));
	// LS
	CreateFuelOutlet(1941.65625, -1778.45313, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1774.31250, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1771.34375, 14.14063, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1941.65625, -1767.28906, 14.14063, 2.0, 100.0, frandom(40.0));
	// LV
	CreateFuelOutlet(2120.82031, 914.718750, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2114.90625, 914.718750, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2109.04688, 914.718750, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2120.82031, 925.507810, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2114.90625, 925.507810, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2109.04688, 925.507810, 11.25781, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2207.69531, 2480.32813, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2207.69531, 2474.68750, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2207.69531, 2470.25000, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2196.89844, 2480.32813, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2196.89844, 2474.68750, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2196.89844, 2470.25000, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2153.31250, 2742.52344, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2147.53125, 2742.52344, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2141.67188, 2742.52344, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2153.31250, 2753.32031, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2147.53125, 2753.32031, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2141.67188, 2753.32031, 11.27344, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1590.35156, 2204.50000, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1596.13281, 2204.50000, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1602.00000, 2204.50000, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1590.35156, 2193.71094, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1596.13281, 2193.71094, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(1602.00000, 2193.71094, 11.31250, 2.0, 100.0, frandom(25.0));
	CreateFuelOutlet(2634.64063, 1100.94531, 11.25000, 2.0, 100.0, frandom(20.0));
	CreateFuelOutlet(2639.87500, 1100.96094, 11.25000, 2.0, 100.0, frandom(20.0));
	CreateFuelOutlet(2645.25000, 1100.96094, 11.25000, 2.0, 100.0, frandom(20.0));
	CreateFuelOutlet(2634.64063, 1111.75000, 11.25000, 2.0, 100.0, frandom(20.0));
	CreateFuelOutlet(2639.87500, 1111.75000, 11.25000, 2.0, 100.0, frandom(20.0));
	CreateFuelOutlet(2645.25000, 1111.75000, 11.25000, 2.0, 100.0, frandom(20.0));
	// RC
	CreateFuelOutlet(1378.96094, 461.03906, 19.32813, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1380.63281, 460.27344, 19.32813, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1383.39844, 459.07031, 19.32813, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(1385.07813, 458.29688, 19.32813, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(655.66406, -558.92969, 15.35938, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(655.66406, -560.54688, 15.35938, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(655.66406, -569.60156, 15.35938, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(655.66406, -571.21094, 15.35938, 2.0, 100.0, frandom(40.0));
	// SF
	CreateFuelOutlet(-2410.80, 970.85, 44.48, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2410.80, 976.19, 44.48, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2410.80, 981.52, 44.48, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1679.3594, 403.0547, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1675.2188, 407.1953, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1669.9063, 412.5313, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1665.5234, 416.9141, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1685.9688, 409.6406, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1681.8281, 413.7813, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1676.5156, 419.1172, 6.3828, 2.0, 100.0, frandom(35.0));
	CreateFuelOutlet(-1672.1328, 423.5000, 6.3828, 2.0, 100.0, frandom(35.0));
	// TR
	CreateFuelOutlet(-1465.4766, 1868.2734, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1464.9375, 1860.5625, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.8516, 1867.3125, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.6563, 1859.7344, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1327.0313, 2685.5938, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1327.7969, 2680.1250, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1328.5859, 2674.7109, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1329.2031, 2669.2813, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1465.4766, 1868.2734, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1464.9375, 1860.5625, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.8516, 1867.3125, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.6563, 1859.7344, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1327.0313, 2685.5938, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1327.7969, 2680.1250, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1328.5859, 2674.7109, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1329.2031, 2669.2813, 50.4531, 2.0, 100.0, frandom(40.0));
	//News
	CreateFuelOutlet(-2026.59753, 155.41299, 28.83670, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2026.59753, 156.73370, 28.83670, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-2026.59753, 158.03380, 28.83670, 2.0, 100.0, frandom(40.0));
}

hook OnPlayerConnect(playerid)
{
	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;
	fuel_CurrentFuelOutlet[playerid] = INVALID_FUEL_OUTLET_ID;
}

stock CreateFuelOutlet(Float:x, Float:y, Float:z, Float:areasize, Float:capacity, Float:startamount)
{
	if(fuel_Total >= MAX_FUEL_LOCATIONS - 1)
	{
		err(false, false, "MAX_FUEL_LOCATIONS limit reached!");
		return -1;
	}

	fuel_Data[fuel_Total][fuel_buttonId]	= CreateButton(x, y, z + 0.5, "Bomba de Combustivel", .label = true, .labeltext = "0.0", .areasize = areasize, .streamdist = areasize + 1.0, .testlos = false);

	fuel_Data[fuel_Total][fuel_state]		= 1;
	fuel_Data[fuel_Total][fuel_capacity]	= capacity;
	fuel_Data[fuel_Total][fuel_amount]		= startamount;

	fuel_Data[fuel_Total][fuel_posX]		= x;
	fuel_Data[fuel_Total][fuel_posY]		= y;
	fuel_Data[fuel_Total][fuel_posZ]		= z;

	fuel_ButtonFuelOutlet[fuel_Data[fuel_Total][fuel_buttonId]] = fuel_Total;

	UpdateFuelText(fuel_Total);

	return fuel_Total++;
}

hook OnPlayerUseItemWithBtn(playerid, Button:buttonid, Item:itemid)
{
	if(fuel_ButtonFuelOutlet[buttonid] == INVALID_FUEL_OUTLET_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(fuel_Data[fuel_ButtonFuelOutlet[buttonid]][fuel_buttonId] != buttonid)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid));

	if(liqcont == -1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetLiquidItemLiquidAmount(itemid) >= GetLiquidContainerTypeCapacity(liqcont))
	{
		ShowActionText(playerid, ls(playerid, "FUELCANFULL", true), 3000);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	StartRefuellingFuelCan(playerid, fuel_ButtonFuelOutlet[buttonid]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(angle < 25.0 || angle > 335.0)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));
		
		if(GetItemTypeLiquidContainerType(itemtype) != -1)
			StartRefuellingVehicle(playerid, vehicleid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartRefuellingFuelCan(playerid, outletid)
{
	if(!(0 <= outletid < fuel_Total))
	{
		err(false, false, "[StartRefuellingFuelCan] invalid outletid: %d", outletid);
		return 0;
	}

	new liqcont = GetItemTypeLiquidContainerType(GetItemType(GetPlayerItem(playerid)));

	if(liqcont == -1)
	{
		ShowActionText(playerid, ls(playerid, "YOUNEEDFCAN"), 3000, 120);
		return 0;
	}

	if(fuel_Data[outletid][fuel_amount] <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY"), 3000, 80);
		return 0;
	}

	if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID) {
		StopRefuellingFuelCan(playerid);
		return 0;
	}

	CancelPlayerMovement(playerid);
	StartHoldAction(playerid, floatround(GetLiquidContainerTypeCapacity(liqcont) * 1000), floatround(GetLiquidItemLiquidAmount(GetPlayerItem(playerid)) * 1000));
	fuel_CurrentFuelOutlet[playerid] = outletid;

	ApplyAnimation(playerid, "HEIST9", "USE_SWIPECARD", 4.0, 0, 0, 0, 0, 500, 1);

	return 1;
}

StopRefuellingFuelCan(playerid)
{
	if(!(0 <= fuel_CurrentFuelOutlet[playerid] < fuel_Total))
		return 0;

	HidePlayerProgressBar(playerid, ActionBar);
	ClearAnimations(playerid);

	StopHoldAction(playerid);
	fuel_CurrentFuelOutlet[playerid] = INVALID_FUEL_OUTLET_ID;

	return 1;
}

StartRefuellingVehicle(playerid, vehicleid)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemTypeLiquidContainerType(GetItemType(itemid)) == -1)
		return 0;

	if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
	{
		ShowActionText(playerid, ls(playerid, "FUELNOTPETR", true), 3000);
		return 0;
	}

	if(GetLiquidItemLiquidAmount(itemid) <= 0.0)
	{
		ShowActionText(playerid, ls(playerid, "EMPTY"), 3000);
		return 0;
	}

	CancelPlayerMovement(playerid);
	ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0, 1);
	StartHoldAction(playerid, floatround(GetVehicleTypeMaxFuel(GetVehicleType(vehicleid)) * 1000), floatround(GetVehicleFuel(vehicleid) * 1000));
	fuel_CurrentlyRefuelling[playerid] = vehicleid;

	return 1;
}

StopRefuellingVehicle(playerid)
{
	if(!IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return 0;

	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fuel_CurrentlyRefuelling[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnHoldActionFinish(playerid) 
{
	if(IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
	{
		StopRefuellingVehicle(playerid);
	}
	else if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID)
	{
		StopRefuellingFuelCan(playerid);
	}
}

hook OnHoldActionUpdate(playerid, progress)
{	
	if(IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
	{
		new
			Item:itemid = GetPlayerItem(playerid),
			Float:canfuel,
			Float:transfer,
			Float:vehiclefuel,
			Float:px,
			Float:py,
			Float:pz,
			Float:vx,
			Float:vy,
			Float:vz;

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) == -1)
		{
			StopRefuellingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		canfuel = GetLiquidItemLiquidAmount(itemid);
		vehiclefuel = GetVehicleFuel(fuel_CurrentlyRefuelling[playerid]);

		if(canfuel <= 0.0)
		{
			ShowActionText(playerid, ls(playerid, "EMPTY"), 3000, 80);
			StopRefuellingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(vehiclefuel >= GetVehicleTypeMaxFuel(GetVehicleType(fuel_CurrentlyRefuelling[playerid])) || !IsPlayerInVehicleArea(playerid, fuel_CurrentlyRefuelling[playerid]))
		{
			StopRefuellingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		SetPlayerProgressBarValue(playerid, ActionBar, vehiclefuel * 1000);
		SetPlayerProgressBarMaxValue(playerid, ActionBar, GetVehicleTypeMaxFuel(GetVehicleType(fuel_CurrentlyRefuelling[playerid])) * 1000);
		ShowPlayerProgressBar(playerid, ActionBar);

		GetPlayerPos(playerid, px, py, pz);
		GetVehiclePos(fuel_CurrentlyRefuelling[playerid], vx, vy, vz);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, vx, vy));

		transfer = (canfuel - 0.8 < 0.0) ? canfuel : 0.8;
		SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
		SetVehicleFuel(fuel_CurrentlyRefuelling[playerid], vehiclefuel + transfer);
		return Y_HOOKS_BREAK_RETURN_1;
	}
	else if(fuel_CurrentFuelOutlet[playerid] != INVALID_FUEL_OUTLET_ID)
	{
		if(fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0) {
			defer ReFuelOutlet(fuel_CurrentFuelOutlet[playerid]);
			fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] = 0.0;
			StopRefuellingFuelCan(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
		
		new
			Item:itemid,
			liqcont,
			Float:transfer,
			Float:amount,
			Float:capacity,
			Float:px,
			Float:py,
			Float:pz;

		itemid = GetPlayerItem(playerid);
		liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid));

		if(liqcont == -1)
		{
			StopRefuellingFuelCan(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		amount = GetLiquidItemLiquidAmount(itemid);
		capacity = GetLiquidContainerTypeCapacity(liqcont);

		
		if(amount >= capacity || fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] <= 0.0)
		{
			StopRefuellingFuelCan(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		GetPlayerPos(playerid, px, py, pz);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posX], fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_posY]));

		SetPlayerProgressBarValue(playerid, ActionBar, amount * 1000);
		SetPlayerProgressBarMaxValue(playerid, ActionBar, capacity * 1000);
		ShowPlayerProgressBar(playerid, ActionBar);

		ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.0, 1, 0, 0, 0, 0, 1);

		transfer = (amount + 1.2 > capacity) ? capacity - amount : 1.2;
		SetLiquidItemLiquidAmount(itemid, amount + transfer);
		SetLiquidItemLiquidType(itemid, liquid_Petrol);
		fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] -= transfer;

		if(fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] < 0.0)
			fuel_Data[fuel_CurrentFuelOutlet[playerid]][fuel_amount] = 0.0;
			
		UpdateFuelText(fuel_CurrentFuelOutlet[playerid]);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrink(playerid, Item:itemid)
{
	if(IsValidVehicle(fuel_CurrentlyRefuelling[playerid]))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsPlayerAtAnyVehicleBonnet(playerid))
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetLiquidItemLiquidType(itemid) == liquid_Petrol)
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetLiquidItemLiquidType(itemid) == liquid_Oil)
		return Y_HOOKS_BREAK_RETURN_1;

	if(GetItemType(itemid) == item_GasCan)
		return Y_HOOKS_BREAK_RETURN_1;
		
	return Y_HOOKS_CONTINUE_RETURN_0;
}

UpdateFuelText(outletid)
{
	return SetButtonLabel(fuel_Data[outletid][fuel_buttonId], sprintf("%.1f/%.1f", fuel_Data[outletid][fuel_amount], fuel_Data[outletid][fuel_capacity]));
}

timer ReFuelOutlet[ITEM_RESPAWN_DELAY](id) {
	fuel_Data[id][fuel_amount] = frandom(80.0);
}
