/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

static wheel_Interact[MAX_PLAYERS] = {-1, ...};

hook OnPlayerConnect(playerid)
{
	wheel_Interact[playerid] = -1;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	new Item:itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_Wheel)
	{
		if(wheel_Interact[playerid] != -1)
			return Y_HOOKS_BREAK_RETURN_0;

		if(_WheelRepair(playerid, vehicleid, itemid))
			return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_WheelRepair(playerid, vehicleid, Item:itemid)
{
	new
		wheel = GetPlayerVehicleTire(playerid, vehicleid),
		vehicletype = GetVehicleType(vehicleid),
		panels,
		doors,
		lights,
		tires,
		Float:x, Float:y, Float:z,
		Float:r;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);
	
	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT, WHEELSFRONT_RIGHT: // Front
			{
				if(tires & 0b0010)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1101);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFT", true), 5000);

					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;

					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSMID_LEFT, WHEELSMID_RIGHT, WHEELSREAR_LEFT, WHEELSREAR_RIGHT: // back
			{
				if(tires & 0b0001)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1110);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPRT", true), 5000);

					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;
					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
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
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b0111);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFL", true), 5000);

					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;
					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSFRONT_RIGHT:
			{
				if(tires & 0b0010)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1101);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPFR", true), 5000);
					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;
					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSREAR_LEFT:
			{
				if(tires & 0b0100)
				{
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1011);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPBL", true), 5000);
					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;
					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			case WHEELSREAR_RIGHT:
			{
				if(tires & 0b0001)
				{
					wheel_Interact[playerid] = wheel;
					StartHoldAction(playerid, 7000);
					UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1110);
					DestroyItem(itemid);
					ShowActionText(playerid, ls(playerid, "TIREREPBR", true), 5000);
					SetPlayerFacingAngle(playerid, r - 180);
					SetPlayerPos(playerid, x - (0.8 * floatsin(-r, degrees)), y - (0.8 * floatcos(-r, degrees)), z);
					wheel_Interact[playerid] = wheel;
					StopHoldAction(playerid);
					StartHoldAction(playerid, 7000);
					ApplyAnimation(playerid, "CAR", "FIXN_CAR_LOOP", 4.0, 0, 0, 0, 1, 0);
				}
				else
				{
					ShowActionText(playerid, ls(playerid, "TIRENOTBROK", true), 5000);
				}
			}

			default:
				return 0;
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(wheel_Interact[playerid] != -1)
	{
		ApplyAnimation(playerid, "CAR", "FIXN_CAR_OUT", 4.0, 0, 0, 0, 0, 0);
		wheel_Interact[playerid] = -1;
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}