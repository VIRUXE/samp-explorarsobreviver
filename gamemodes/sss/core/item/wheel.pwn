/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

static 
	Timer:UpdateVehWheel[MAX_PLAYERS],
	PlayerUpdateWheel[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};

hook OnPlayerDisconnect(playerid, reason)
{
	stop UpdateVehWheel[playerid];
	PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle){
	new Item:itemid = GetPlayerItem(playerid);
	if(GetItemType(itemid) == item_Wheel && PlayerUpdateWheel[playerid] == INVALID_VEHICLE_ID){
		_WheelRepair(playerid, vehicleid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

_WheelRepair(playerid, vehicleid)
{
	new
		wheel = GetPlayerVehicleTire(playerid, vehicleid),
		vehicletype = GetVehicleType(vehicleid),
		panels,
		doors,
		lights,
		tires;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	
	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT, WHEELSFRONT_RIGHT: // Front
			{
				if(tires & 0b0010)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b1101);
					ShowActionText(playerid, ls(playerid, "TIREREPFT"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			case WHEELSMID_LEFT, WHEELSMID_RIGHT, WHEELSREAR_LEFT, WHEELSREAR_RIGHT: // back
			{
				if(tires & 0b0001)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b1110);
					ShowActionText(playerid, ls(playerid, "TIREREPRT"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			default:
				return 0;
		}
	}
	else
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT:
			{
				if(tires & 0b1000)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b0111);
					ShowActionText(playerid, ls(playerid, "TIREREPFL"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			case WHEELSFRONT_RIGHT:
			{
				if(tires & 0b0010)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b1101);
					ShowActionText(playerid, ls(playerid, "TIREREPFR"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			case WHEELSREAR_LEFT:
			{
				if(tires & 0b0100)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b1011);
					ShowActionText(playerid, ls(playerid, "TIREREPBL"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			case WHEELSREAR_RIGHT:
			{
				if(tires & 0b0001)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, panels, doors, lights, tires & 0b1110);
					ShowActionText(playerid, ls(playerid, "TIREREPBR"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
					StartHoldAction(playerid, 7000, 1);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
				}
			}

			default:
				return 0;
		}
	}

	return 1;
}

timer upVehWheel[7000](playerid, vehicleid, panels, doors, lights, tires){
	StopHoldAction(playerid);
	ClearAnimations(playerid);
	PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	PlayerPlaySound(playerid, 4202, 0.0, 0.0, 0.0);
	ShowActionText(playerid, ls(playerid, "TIREREPP", true), 2000);
	DestroyItem(GetPlayerItem(playerid));
}

hook OnPlayerOpenInventory(playerid){
	StopInstallWheel(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	StopInstallWheel(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	StopInstallWheel(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, Item:itemid){
	StopInstallWheel(playerid);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
	StopInstallWheel(playerid);
	return 1;
}

StopInstallWheel(playerid) {
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) {
		stop UpdateVehWheel[playerid];
		StopHoldAction(playerid);
		PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
		ClearAnimations(playerid);
	}
}

hook OnHoldActionUpdate(playerid, progress){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) {
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid){

}