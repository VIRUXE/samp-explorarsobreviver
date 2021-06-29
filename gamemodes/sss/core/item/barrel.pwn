
#include <YSI_Coding\y_hooks>

static 
Item:CurrenteBarrel[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
Item:CurrenteBarrelOut[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};

hook OnItemCreateInWorld(Item:itemid) {
	if(GetItemType(itemid) == item_Barrel){
		new 
			Button:buttonid,
			name[MAX_ITEM_NAME + MAX_ITEM_TEXT];

		GetItemName(itemid, name);
		GetItemButtonID(itemid, buttonid);
		SetButtonLabel(buttonid, name);
	}
}

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if(GetItemType(itemid) == item_Barrel){
		new 
			liqcont = GetItemTypeLiquidContainerType(GetItemType(itemid)),
			Float:amount = GetLiquidItemLiquidAmount(itemid),
			Float:capacity = GetLiquidContainerTypeCapacity(liqcont);

		if(amount > (capacity / 2) ) {
			ShowActionText(playerid, sprintf(ls(playerid, "BARRELHEAVY"), amount, capacity), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if(GetItemType(withitemid) == item_Barrel){
		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1){
			if(IsValidItem(CurrenteBarrel[playerid])) {
				StopBarrelInteract(playerid);
			} else {
				new 
					liqcont = GetItemTypeLiquidContainerType(GetItemType(withitemid)),
					Float:amount = GetLiquidItemLiquidAmount(withitemid),
					Float:capacity = GetLiquidContainerTypeCapacity(liqcont);

				CancelPlayerMovement(playerid);

				if(GetLiquidItemLiquidType(itemid) != GetLiquidItemLiquidType(withitemid)){
					if(GetLiquidItemLiquidAmount(withitemid) == 0.0) {
						SetLiquidItemLiquidType(withitemid, GetLiquidItemLiquidType(itemid));
					} 
				}

				if(GetLiquidItemLiquidAmount(itemid) == 0.0) {
					CurrenteBarrelOut[playerid] = withitemid;
				} else {
					CurrenteBarrelOut[playerid] = INVALID_ITEM_ID;
				}

				CurrenteBarrel[playerid] = withitemid;
				ApplyAnimation(playerid, "PED", "DRIVE_BOAT", 4.1, 1, 0, 0, 0, 0, 1);

				StartHoldAction(playerid, floatround(capacity * 1000), floatround(amount * 1000));
			}
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress){
	if(IsValidItem(CurrenteBarrel[playerid])) {
		new Item:itemid = GetPlayerItem(playerid);
		if(!IsValidLiquidType(GetLiquidItemLiquidType(itemid))){
			StopBarrelInteract(playerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(GetLiquidItemLiquidType(itemid) != GetLiquidItemLiquidType(CurrenteBarrel[playerid])){
			StopBarrelInteract(playerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		new 
			Float:x, Float:y, Float:z, Float:ix, Float:iy;
			
		GetPlayerPos(playerid, x, y, z);
		GetItemPos(CurrenteBarrel[playerid], ix, iy, z);
		SetPlayerFacingAngle(playerid, GetAngleToPoint(x, y, ix, iy));
		
		new 
			liqcont = GetItemTypeLiquidContainerType(GetItemType(CurrenteBarrel[playerid])),
			Float:amount = GetLiquidItemLiquidAmount(CurrenteBarrel[playerid]),
			Float:capacity = GetLiquidContainerTypeCapacity(liqcont),
			Float:canfuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer = 0.1,
			Button:buttonid,
			name[MAX_ITEM_NAME + MAX_ITEM_TEXT];

		GetItemName(CurrenteBarrel[playerid], name);
		GetItemButtonID(CurrenteBarrel[playerid], buttonid);
		SetButtonLabel(buttonid, name);

		SetPlayerProgressBarValue(playerid, ActionBar, floatround(amount * 1000));
		SetPlayerProgressBarMaxValue(playerid, ActionBar, floatround(capacity * 1000));
		ShowPlayerProgressBar(playerid, ActionBar);

		if(IsValidItem(CurrenteBarrelOut[playerid])) {
			if(amount <= transfer || canfuel >= GetLiquidContainerTypeCapacity(GetItemTypeLiquidContainerType(GetItemType(itemid)))){
				StopBarrelInteract(playerid);
			} else {
				SetLiquidItemLiquidAmount(itemid, canfuel + transfer);
				SetLiquidItemLiquidAmount(CurrenteBarrel[playerid], amount - transfer);
			}
		} else {
			if(amount >= capacity || canfuel <= transfer){
				StopBarrelInteract(playerid);
			} else {
				SetLiquidItemLiquidAmount(GetPlayerItem(playerid), canfuel - transfer);
				SetLiquidItemLiquidAmount(CurrenteBarrel[playerid], amount + transfer);
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid) {
	if(IsValidItem(CurrenteBarrel[playerid])){
		StopBarrelInteract(playerid);
	}
}

StopBarrelInteract(playerid){
	CancelPlayerMovement(playerid);
	StopHoldAction(playerid);
	CurrenteBarrel[playerid] = INVALID_ITEM_ID;
	CurrenteBarrelOut[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDroppedItem(playerid, Item:itemid){
	if(GetItemType(itemid) == item_Barrel) {
		new Float:x, Float:y, Float:z, Float:r;
		GetItemPos(itemid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		x += 0.443265 * floatsin(-r, degrees), y += 0.443265 * floatcos(-r, degrees);
		SetItemPos(itemid, x, y, z);
	}
}
