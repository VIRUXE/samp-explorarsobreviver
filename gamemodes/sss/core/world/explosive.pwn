
#include <YSI_Coding\y_hooks>

#define MAX_EXPLOSIVE_ITEM				(16)
#define INVALID_EXPLOSIVE_TYPE			(-1)
#define EXP_STREAMER_AREA_IDENTIFIER	(700)

enum EXP_TRIGGER
{
	TIMED,
	RADIO,
	PROXIMITY,
	MOTION
}

enum EXP_PRESET
{
	EXP_SMALL,
	EXP_MEDIUM,
	EXP_LARGE,
	EXP_INCEN,
	EXP_THERM,
	EXP_EMP,
	EXP_SHRAP
}


enum EXP_PRESET_DATA
{
			exp_type,
Float:		exp_size,
			exp_itemDmg
}

enum E_EXPLOSIVE_ITEM_DATA
{
ItemType:	exp_itemtype,
EXP_TRIGGER:exp_trigger,
EXP_PRESET:	exp_preset
}


static		exp_Presets[EXP_PRESET][EXP_PRESET_DATA] =
{

//	type	size	Damage

	{12, 	3.0, 	1},	// EXP_SMALL
	{00, 	8.0, 	2},	// EXP_MEDIUM
	{06, 	24.0, 	3},	// EXP_LARGE
	{02, 	5.0, 	0},	// EXP_INCEN - large fire anim from explosion
	{04, 	8.0, 	0},	// EXP_THERM - fire anim from explosion combined with prt
	{00, 	12.0, 	0},	// EXP_EMP - no exp anim or fire, prt used
	{12, 	10.0, 	0}	// EXP_SHRAP - knockout range small, bleed range large
	
};

static
			exp_Data[MAX_EXPLOSIVE_ITEM][E_EXPLOSIVE_ITEM_DATA],
			exp_Total,
			exp_ItemTypeExplosive[MAX_ITEM_TYPE] = {INVALID_EXPLOSIVE_TYPE, ...},
ItemType:	exp_RadioTriggerItemType;

static
Item:		exp_ArmingItem[MAX_PLAYERS],
			exp_ArmTick[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	exp_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreate(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == RADIO)
			SetItemExtraData(itemid, _:INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid)
{
	if(exp_ItemTypeExplosive[GetItemType(itemid)] != -1)
	{
		if(GetItemHitPoints(itemid) <= 0)
		{
			SetItemToExplode(itemid);
		}
	}
}

stock DefineExplosiveItem(ItemType:itemtype, EXP_TRIGGER:trigger, EXP_PRESET:preset)
{
	if(0 <= exp_Total >= MAX_EXPLOSIVE_ITEM - 1)
	{
		err("Explosive item definition limit reached!");
		return -1;
	}

	SetItemTypeMaxArrayData(itemtype, 1);

	exp_Data[exp_Total][exp_itemtype] = itemtype;
	exp_Data[exp_Total][exp_trigger] = trigger;
	exp_Data[exp_Total][exp_preset] = preset;

	exp_ItemTypeExplosive[itemtype] = exp_Total;

	return exp_Total++;
}

stock SetRadioExplosiveTriggerItem(ItemType:itemtype)
{
	SetItemTypeMaxArrayData(itemtype, 1);
	exp_RadioTriggerItemType = itemtype;
}

stock SetItemToExplode(Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		parent,
		parenttype[32];

	itemtype = GetItemType(itemid);
	GetItemAbsolutePos(itemid, x, y, z, parent, parenttype);

	log(true, "[EXPLOSIVE] Item %d Type %d detonated at %f, %f, %f", _:itemid, _:exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger], x, y, z);

	if(!isnull(parenttype))
	{
		if(!strcmp(parenttype, "containerid") && IsValidContainer(Container:parent))
			DestroyContainer(Container:parent);

		if(!strcmp(parenttype, "vehicleid"))
			SetVehicleHealth(parent, 0.0);

		if(!strcmp(parenttype, "playerid"))
			SetPlayerHP(parent, 0.0);
	}

	DestroyItem(itemid);
	CreateExplosionOfPreset(x, y, z, exp_Data[exp_ItemTypeExplosive[itemtype]][exp_preset]);

	return 0;
}

timer SetItemToExplodeDelay[delay](itemid, delay)
{
	#pragma unused delay

	if(!IsItemInWorld(Item:itemid))
		return;

	SetItemToExplode(Item:itemid);
}


/*==============================================================================

	Type-specific Code for Trigger Types

==============================================================================*/

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetItemPos(itemid, x, y, z - 0.9);
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(IsValidItem(exp_ArmingItem[playerid]))
		{
			StopHoldAction(playerid);
			CancelPlayerMovement(playerid);
			exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);

		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
		{
			CreateItemInWorld(RemoveCurrentItem(playerid), x, y, z - 0.90);

			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
		else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == PROXIMITY)
		{
			CreateItemInWorld(RemoveCurrentItem(playerid), x, y, z - 0.90);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
		else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			CreateItemInWorld(RemoveCurrentItem(playerid), x, y, z - 0.90);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0, 1);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
	}
	else if(GetItemType(itemid) == exp_RadioTriggerItemType)
	{
		if(GetTickCountDifference(GetTickCount(), exp_ArmTick[playerid]) < 1000)
			return 0;

		new
			Item:bombitem,
			ItemType:bombitemtype;

		GetItemExtraData(itemid, _:bombitem);
		bombitemtype = GetItemType(bombitem);

		if(!IsValidItem(bombitem))
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC", true));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(exp_ItemTypeExplosive[bombitemtype] == INVALID_EXPLOSIVE_TYPE)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC", true));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		if(exp_Data[exp_ItemTypeExplosive[bombitemtype]][exp_trigger] != RADIO)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC", true));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		new value;
		GetItemExtraData(bombitem, value);
		if(value != 1)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC", true));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		log(true, "[EXPLOSIVE] Player %p triggering remote explosive item %d", playerid, _:itemid);
		SetItemToExplode(bombitem);
		SetItemExtraData(itemid, _:INVALID_ITEM_ID);

		ShowActionText(playerid, ls(playerid, "RADIOTRIGGD", true));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(itemid) != exp_RadioTriggerItemType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(IsValidItem(exp_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		CancelPlayerMovement(playerid);
		exp_ArmingItem[playerid] = INVALID_ITEM_ID;
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new ItemType:itemtype = GetItemType(withitemid);

	if(exp_ItemTypeExplosive[itemtype] == INVALID_EXPLOSIVE_TYPE)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] != RADIO)
		return Y_HOOKS_CONTINUE_RETURN_0;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0, 1);
	SetItemExtraData(itemid, _:withitemid);
	SetItemExtraData(withitemid, 1);
	exp_ArmTick[playerid] = GetTickCount();

	ChatMsgLang(playerid, YELLOW, "ARMEDRADIOB");

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(IsValidItem(exp_ArmingItem[playerid]))
	{
		new ItemType:itemtype = GetItemType(exp_ArmingItem[playerid]);

		if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
		{
			if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
			{
				log(true, "[EXPLOSIVE] Time bomb %d placed by %p", _:exp_ArmingItem[playerid], playerid);

				exp_ArmTick[playerid] = GetTickCount();
				defer SetItemToExplodeDelay(_:exp_ArmingItem[playerid], 5000);
				ClearAnimations(playerid);
				ShowActionText(playerid, ls(playerid, "ARMEDBOMB5S", true), 3000);

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
			else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == PROXIMITY)
			{
				log(true, "[EXPLOSIVE] Prox bomb %d placed by %p", _:exp_ArmingItem[playerid], playerid);

				defer CreateTntMineProx(_:exp_ArmingItem[playerid]);
				ChatMsgLang(playerid, YELLOW, "PROXMIARMED");

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
			else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
			{
				log(true, "[EXPLOSIVE] Trip bomb %d placed by %p", _:exp_ArmingItem[playerid], playerid);

				SetItemExtraData(exp_ArmingItem[playerid], 1);
				ClearAnimations(playerid);
				ShowActionText(playerid, ls(playerid, "ARMEDBOMB", true), 3000);

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
		}
	}
}

// Proximity Mine

timer CreateTntMineProx[5000](_itemid)
{
	new Item:itemid = Item:_itemid;
	if(!IsItemInWorld(itemid))
		return;

	new
		Float:x,
		Float:y,
		Float:z,
		areaid,
		data[2];

	GetItemPos(itemid, x, y, z);

	areaid = CreateDynamicSphere(x, y, z, 6.0);
	SetItemExtraData(itemid, areaid);
	data[0] = EXP_STREAMER_AREA_IDENTIFIER;
	data[1] = _:itemid;
	Streamer_SetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	return;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != EXP_STREAMER_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsValidItem(Item:data[1]))
	{
		err("Proximity mine streamer area contains invalid item id (%d)", data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new itemarea;
	GetItemExtraData(Item:data[1], itemarea);
	if(itemarea != areaid)
	{
		err("Proximity mine item area (%d) does not match triggered area (%d)", itemarea, areaid);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	log(true, "[EXPLOSIVE] Prox bomb %d triggered by %p", data[1], playerid);
	_exp_ProxTrigger(Item:data[1]);
	DestroyDynamicArea(areaid);

	return Y_HOOKS_BREAK_RETURN_1;
}

_exp_ProxTrigger(Item:itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	PlaySoundForAll(6400, x, y, z);
	defer SetItemToExplodeDelay(_:itemid, 1000);
}

// Trip mine

static exp_ContainerOption[MAX_PLAYERS];

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	new
		slot,
		Item:itemid,
		ItemType:itemtype;

	GetPlayerContainerSlot(playerid, slot);
	GetContainerSlotItem(containerid, slot, itemid);
	itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			new armed;
			GetItemExtraData(itemid, armed);
			if(armed == 0)
				exp_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");

			else
				exp_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, Container:containerid, option)
{
	new
		slot,
		Item:itemid,
		ItemType:itemtype;

	GetPlayerContainerSlot(playerid, slot);
	GetContainerSlotItem(containerid, slot, itemid);

	if(!IsValidItem(itemid))
		return Y_HOOKS_CONTINUE_RETURN_0;
		
	itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			if(option == exp_ContainerOption[playerid])
			{
				new armed;
				GetItemExtraData(itemid, armed);
				if(armed == 0)
				{
					DisplayContainerInventory(playerid, containerid);
					SetItemExtraData(itemid, 1);
				}
				else
				{
					SetItemExtraData(itemid, 0);
					DisplayContainerInventory(playerid, containerid);
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			new armed;
			GetItemExtraData(itemid, armed);
			if(armed == 1)
			{
				log(true, "[EXPLOSIVE] Trip bomb %d triggered by %p", _:itemid, playerid);
				SetItemToExplode(itemid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	new
		Item:itemid,
		ItemType:itemtype,
		count;

	GetContainerItemCount(containerid, count);

	for(new i; i < count; i++)
	{
		GetContainerSlotItem(containerid, i, itemid);
		itemtype = GetItemType(itemid);

		if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
		{
			if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
			{
				new armed;
				GetItemExtraData(itemid, armed);
				if(armed == 1)
				{
					SetItemToExplode(itemid);
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Explosion functions

==============================================================================*/

new Timer:exp_HitItemExp[MAX_ITEM];

stock CreateExplosionOfPreset(Float:x, Float:y, Float:z, EXP_PRESET:preset)
{
	switch(preset)
	{
		case EXP_INCEN:
			CreateIncenExplosion(x, y, z, exp_Presets[preset][exp_size]);

		case EXP_THERM:
			err("EXP_THERM not implemented");

		case EXP_EMP:
			CreateEmpExplosion(x, y, z, exp_Presets[preset][exp_size]);

		default:
			CreateExplosion(x, y, z, exp_Presets[preset][exp_type], exp_Presets[preset][exp_size]);
	}

	if(exp_Presets[preset][exp_itemDmg] > 0)
	{
		new
			streamer_items[256],
			streamer_count,
			data[2],
			Item:id,
			count,
			Float:ix, Float:iy, Float:iz,
			Float:tmp;

		streamer_count = Streamer_GetNearbyItems(x, y, z, STREAMER_TYPE_AREA, streamer_items, .range = exp_Presets[preset][exp_size]);

		for(new i; i < streamer_count && count < 256; ++i) {
			Streamer_GetArrayData(STREAMER_TYPE_AREA, streamer_items[i], E_STREAMER_EXTRA_ID, data);

			if(data[0] != BTN_STREAMER_AREA_IDENTIFIER)
				continue;

			id = GetItemFromButtonID(Button:data[1]);

			// Explode itens
			if(IsValidItem(id)){
				GetItemPos(Item:id, ix, iy, iz);
				if(!CA_RayCastLine(ix, iy, iz, x, y, z, tmp, tmp, tmp)){
					stop exp_HitItemExp[Item:id];
					exp_HitItemExp[Item:id] = defer HitItemExp(_:id, GetItemHitPoints(Item:id) - exp_Presets[preset][exp_itemDmg]);
				}
			}
		}

		// RayCastLineExplode for defences
		for(new Float:lat = -180.0; lat < 180.0; lat += (10.0 * 0.75)){
			for(new Float:lon = -90.0; lon < 90.0; lon += 10.0){
				new Float:LAT = lat * 3.141593 / 180.0,
					Float:LON = lon * 3.141593 / 180.0,
					Float:ex = -1.0 * floatcos(LAT) * floatcos(LON),
					Float:ey = 1.0 * floatcos(LAT) * floatsin(LON),
					Float:ez = 1.0 * floatsin(LAT);

				id = Item:CA_GetObjectExtraID(CA_RayCastLineID(x, y, z, x + ex, y + ey, z + ez, tmp, tmp, tmp), 0);
				if(IsItemTypeDefence(GetItemType(id))){
					stop exp_HitItemExp[Item:id];
					exp_HitItemExp[Item:id] = defer HitItemExp(_:id, GetItemHitPoints(id) - exp_Presets[preset][exp_itemDmg]);
				}
			}
		}
	}

	return 1;
}

timer HitItemExp[200](id, hit)
	if(IsValidItem(Item:id) && IsItemInWorld(Item:id))
		SetItemHitPoints(Item:id, hit);

CreateIncenExplosion(Float:x, Float:y, Float:z, Float:range)
{
	CreateTimedDynamicObject(18689, x, y, z - 1.5, 0.0, 0.0, 0.0, 60000);
	CreateExplosion(x, y, z, 1, range);
	//CreateExplosion(x, y, z, 9, range);

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			KnockOutPlayer(i, 30000);
		}
	}

	foreach(new i : veh_Index)
	{
		if(IsVehicleInRangeOfPoint(i, range, x, y, z))
		{
			SetVehicleEngine(i, false);
		}
	}

	defer CheckPlayerInIncen(x, y, z, range, 0);
}

timer CheckPlayerInIncen[1000](Float:x, Float:y, Float:z, Float:range, timer)
{
	new Float:bleedrate;
	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			GetPlayerBleedRate(i, bleedrate);
			SetPlayerBleedRate(i, bleedrate + 2.5);
			SetPlayerHP(i, (GetPlayerHP(i) - 3.0));
		}
	}

	if(timer < 60)
		defer CheckPlayerInIncen(x, y, z, range, timer + 1);
}

CreateEmpExplosion(Float:x, Float:y, Float:z, Float:range)
{
	CreateTimedDynamicObject(18724, x, y, z - 1.0, 0.0, 0.0, 0.0, 3000);

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, range, x, y, z))
		{
			KnockOutPlayer(i, 60000);
		}
	}

	foreach(new i : veh_Index)
	{
		if(IsVehicleInRangeOfPoint(i, range, x, y, z))
		{
			SetVehicleEngine(i, false);
		}
	}
}

/*==============================================================================

	Interface functions

==============================================================================*/


// exp_ItemTypeExplosive[itemtype]
stock GetItemTypeExplosiveType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return INVALID_EXPLOSIVE_TYPE;

	return exp_ItemTypeExplosive[itemtype];
}

// exp_itemtype
stock ItemType:GetExplosiveTypeItemtype(explosivetype)
{
	if(!(0 <= explosivetype < exp_Total))
		return INVALID_ITEM_TYPE;

	return exp_Data[explosivetype][exp_itemtype];
}

// exp_trigger
stock EXP_TRIGGER:GetExplosiveTypeTrigger(explosivetype)
{
	if(!(0 <= explosivetype < exp_Total))
		return EXP_TRIGGER:-1;

	return exp_Data[explosivetype][exp_trigger];
}

// exp_preset
stock EXP_PRESET:GetExplosiveTypePreset(explosivetype)
{
	if(!(0 <= explosivetype < exp_Total))
		return EXP_PRESET:-1;

	return exp_Data[explosivetype][exp_preset];
}
