
#include <YSI_Coding\y_hooks>


static lsk_TargetVehicle[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == item_Key)
	{
		SetItemArrayDataSize(itemid, 2);
	}
}

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(225.0 < angle < 315.0)
	{
		new
			Item:itemid,
			ItemType:itemtype,
			vehicletype;

		itemid = GetPlayerItem(playerid);

		if(!IsValidItem(itemid))
			return Y_HOOKS_CONTINUE_RETURN_0;

		itemtype = GetItemType(itemid);
		vehicletype = GetVehicleType(vehicleid);
		
		if(itemtype == item_LocksmithKit)
		{
			CancelPlayerMovement(playerid);

			if(!IsVehicleTypeLockable(vehicletype))
			{
				ShowActionText(playerid, ls(playerid, "LOCKNODOORS"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKALREADY"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_WheelLock)
		{
			CancelPlayerMovement(playerid);

			new key;
			GetItemArrayDataAtCell(itemid, key, 0);
			if(key != 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKCHNOKEY"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(GetVehicleKey(vehicleid) != 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKALREADY"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			StartCraftingKey(playerid, vehicleid);
		}

		if(itemtype == item_Key)
		{
			CancelPlayerMovement(playerid);

			new
				keyid,
				vehiclekey = GetVehicleKey(vehicleid);

			GetItemArrayDataAtCell(itemid, keyid, 0);

			if(keyid == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKKEYNCUT"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(vehiclekey == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKVNOLOCK"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(keyid != vehiclekey)
			{
				ShowActionText(playerid, ls(playerid, "LOCKKEYNFIT"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			// Update old keys to the correct vehicle type.
			SetItemArrayDataAtCell(itemid, vehicletype, 1);

			if(GetVehicleLockState(vehicleid) != E_LOCK_STATE_OPEN)
			{
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
				ShowActionText(playerid, ls(playerid, "UNLOCKED"), 3000);
				log(true, "[VLOCK] %p unlocked vehicle %s (%d)", playerid, GetVehicleUUID(vehicleid), vehicleid);
			}
			else
			{
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);
				ShowActionText(playerid, ls(playerid, "LOCKED"), 3000);
				log(true, "[VLOCK] %p locked vehicle %s (%d)", playerid, GetVehicleUUID(vehicleid), vehicleid);
			}

			if(IsVehicleTypeTrailer(vehicletype))
				SaveVehicle(GetTrailerVehicleID(vehicleid));

			SaveVehicle(vehicleid);
		}

		if(itemtype == item_LockBreaker)
		{
			if(GetVehicleKey(vehicleid) == 0)
			{
				ShowActionText(playerid, ls(playerid, "LOCKVNOLOCK"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			CancelPlayerMovement(playerid);
			StartBreakingVehicleLock(playerid, vehicleid, 0);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartCraftingKey(playerid, vehicleid)
{
	if(IsValidVehicle(lsk_TargetVehicle[playerid])) {
		StopCraftingKey(playerid);
	} else {
		lsk_TargetVehicle[playerid] = vehicleid;
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		StartHoldAction(playerid, 3000);
	}
	return 0;
}

StopCraftingKey(playerid)
{
	if(lsk_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	ClearAnimations(playerid);
	StopHoldAction(playerid);

	lsk_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		if(
			!IsValidVehicle(lsk_TargetVehicle[playerid]) ||
			(GetItemType(GetPlayerItem(playerid)) != item_LocksmithKit && GetItemType(GetPlayerItem(playerid)) != item_WheelLock) ||
			!IsPlayerInVehicleArea(playerid, lsk_TargetVehicle[playerid]))
		{
			StopCraftingKey(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		SetPlayerToFaceVehicle(playerid, lsk_TargetVehicle[playerid]);

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(lsk_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new
			Item:itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_LocksmithKit || itemtype == item_WheelLock)
		{
			new key = 1 + random(2147483646);

			DestroyItem(itemid);
			itemid = CreateItem(item_Key);
			GiveWorldItemToPlayer(playerid, itemid);

			SetItemArrayDataAtCell(itemid, key, 0);
			SetItemArrayDataAtCell(itemid, GetVehicleType(lsk_TargetVehicle[playerid]), 1);
			SetVehicleKey(lsk_TargetVehicle[playerid], key);
			SaveVehicle(lsk_TargetVehicle[playerid]);
		}

		StopCraftingKey(playerid);			

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}


hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Key)
	{
		new value, Error:e;
		e = GetItemArrayDataAtCell(itemid, value, 0);

		if(!IsError(e))
		{
			if(value != 0)
			{
				new
					vehicletype,
					vehicletypename[MAX_VEHICLE_TYPE_NAME];

				e = GetItemArrayDataAtCell(itemid, vehicletype, 1);
				if(!IsError(e))
				{
					GetVehicleTypeName(vehicletype, vehicletypename);
					SetItemNameExtra(itemid, vehicletypename);
				}
			}
		}
	}
}

hook OnPlayerCrafted(playerid, CraftSet:craftset, Item:result)
{
	new ItemType:resulttype;
	GetCraftSetResult(craftset, resulttype);
	if(resulttype == item_WheelLock)
	{
		SetItemArrayDataAtCell(result, 1, 0);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerConstructed(playerid, consset, Item:result)
{
	new CraftSet:craftset = GetConstructionSetCraftSet(consset);
	new ItemType:resulttype;
	GetCraftSetResult(craftset, resulttype);
	if(resulttype == item_Key)
	{
		new
			items[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			count,
			Item:tmp,
			data,
			Item:itemid = INVALID_ITEM_ID,
			Error:e;

		GetPlayerConstructionItems(playerid, items, count);

		for(new i; i < count; i++)
		{
			tmp = items[i][craft_selectedItemID];
			e = GetItemArrayDataAtCell(tmp, data, 0);

			if(!IsError(e))
			{
				if(GetItemType(tmp) == item_Key && data > 0)
				{
					itemid = tmp;
					break;
				}
			}
		}

		if(IsValidItem(itemid))
		{
			new v1, v2;

			e = GetItemArrayDataAtCell(itemid, v1, 0);
			if(!IsError(e))
				SetItemArrayDataAtCell(result, v1, 0);

			e = GetItemArrayDataAtCell(itemid, v2, 1);
			if(IsError(e))
				SetItemArrayDataAtCell(result, v2, 1);
		}
		else
		{
			err(false, false, "Key duplicated attempt failed %d %d %d %d", consset, _:craftset, _:result, _:tmp);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}