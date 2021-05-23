#include <YSI\y_hooks>

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
	{12, 3.0, 1},	// EXP_SMALL
	{00, 8.0, 2},	// EXP_MEDIUM
	{06, 24.0, 3},	// EXP_LARGE
	{02, 5.0, 0},	// EXP_INCEN - large fire anim from explosion
	{04, 8.0, 0},	// EXP_THERM - fire anim from explosion combined with prt
	{00, 12.0, 0},	// EXP_EMP - no exp anim or fire, prt used
	{12, 10.0, 0}	// EXP_SHRAP - knockout range small, bleed range large
};

static
			exp_Data[MAX_EXPLOSIVE_ITEM][E_EXPLOSIVE_ITEM_DATA],
			exp_Total,
			exp_ItemTypeExplosive[ITM_MAX_TYPES] = {INVALID_EXPLOSIVE_TYPE, ...},
ItemType:	exp_RadioTriggerItemType;

static
			exp_ArmingItem[MAX_PLAYERS],
			exp_ArmTick[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	exp_ArmingItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreate(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == RADIO)
			SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
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

stock SetItemToExplode(itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	new
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		parent,
		parenttype[32],
		time[3];

	itemtype = GetItemType(itemid);
	GetItemAbsolutePos(itemid, x, y, z, parent, parenttype);
	gettime(time[0], time[1], time[2]);

	if(time[0] >= 0 && time[0] <= 8) // Alert staff for every explosive detonated in the middle of the night
		log(DISCORD_CHANNEL_ADMINEVENTS, DISCORD_MENTION_STAFF"[EXPLOSIVE] Item `%d` Type `%d` detonated at `%.0f, %.0f, %.0f`", itemid, _:exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger], x, y, z);
	else
		log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Item `%d` Type `%d` detonated at `%.0f, %.0f, %.0f`", itemid, _:exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger], x, y, z);

	if(!isnull(parenttype))
	{
		if(!strcmp(parenttype, "containerid"))
			DestroyContainer(parent);

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
	SetItemToExplode(itemid);
}


/*==============================================================================

	Type-specific Code for Trigger Types

==============================================================================*/


hook OnPlayerUseItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
		{
			PlayerDropItem(playerid);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
		else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == PROXIMITY)
		{
			PlayerDropItem(playerid);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
		else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			PlayerDropItem(playerid);
			exp_ArmingItem[playerid] = itemid;

			StartHoldAction(playerid, 1000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			ShowActionText(playerid, ls(playerid, "ARMINGBOMB", true));
		}
	}
	else if(GetItemType(itemid) == exp_RadioTriggerItemType)
	{
		if(GetTickCountDifference(GetTickCount(), exp_ArmTick[playerid]) < 1000)
			return 0;

		new
			bombitem = GetItemExtraData(itemid),
			ItemType:bombitemtype = GetItemType(bombitem);
		
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

		if(GetItemExtraData(bombitem) != 1)
		{
			ShowActionText(playerid, ls(playerid, "RADIONOSYNC", true));
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);
		log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] `%p` triggering remote explosive item `%d` at `%.0f, %.0f, %.0f`", playerid, itemid, x,y,z);
		SetItemToExplode(bombitem);
		SetItemExtraData(itemid, INVALID_ITEM_ID);

		ShowActionText(playerid, ls(playerid, "RADIOTRIGGD", true));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) != exp_RadioTriggerItemType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new ItemType:itemtype = GetItemType(withitemid);

	if(exp_ItemTypeExplosive[itemtype] == INVALID_EXPLOSIVE_TYPE)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] != RADIO)
		return Y_HOOKS_CONTINUE_RETURN_0;

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
	SetItemExtraData(itemid, withitemid);
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
			new Float:x, Float:y, Float:z;

			GetPlayerPos(playerid, x, y, z);

			if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == TIMED)
			{
				log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Time bomb `%d` placed by `%p` at `%.0f, %.0f, %.0f`", exp_ArmingItem[playerid], playerid, x,y,z);

				exp_ArmTick[playerid] = GetTickCount();
				defer SetItemToExplodeDelay(exp_ArmingItem[playerid], 5000);
				ClearAnimations(playerid);
				ShowActionText(playerid, ls(playerid, "ARMEDBOMB5S", true), 3000);

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
			else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == PROXIMITY)
			{
				log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Prox bomb `%d` placed by `%p` at `%.0f, %.0f, %.0f`", exp_ArmingItem[playerid], playerid, x,y,z);

				defer CreateTntMineProx(exp_ArmingItem[playerid]);
				ChatMsgLang(playerid, YELLOW, "PROXMIARMED");

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
			else if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
			{
				log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Trip bomb `%d` placed by `%p` at `%.0f, %.0f, %.0f`", exp_ArmingItem[playerid], playerid, x,y,z);

				SetItemExtraData(exp_ArmingItem[playerid], 1);
				ClearAnimations(playerid);
				ShowActionText(playerid, ls(playerid, "ARMEDBOMB", true), 3000);

				exp_ArmingItem[playerid] = INVALID_ITEM_ID;
			}
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16) && IsValidItem(exp_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		CancelPlayerMovement(playerid);
		exp_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

// Proximity Mine

timer CreateTntMineProx[5000](itemid)
{
	if(IsItemInWorld(itemid) != 1)
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
	data[1] = itemid;
	Streamer_SetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	return;
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data, 2);

	if(data[0] != EXP_STREAMER_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsValidItem(data[1]))
	{
		err("Proximity mine streamer area contains invalid item id (%d)", data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	if(GetItemExtraData(data[1]) != areaid)
	{
		err("Proximity mine item area (%d) does not match triggered area (%d)", GetItemExtraData(data[1]), areaid);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Prox bomb %d triggered by `%p` at `%f, %f, %f`", data[1], playerid, x,y,z);
	_exp_ProxTrigger(data[1]);
	DestroyDynamicArea(areaid);

	return Y_HOOKS_BREAK_RETURN_1;
}

_exp_ProxTrigger(itemid)
{
	new Float:x, Float:y, Float:z;

	GetItemPos(itemid, x, y, z);
	PlaySoundForAll(6400, x, y, z);
	defer SetItemToExplodeDelay(itemid, 1000);
}

// Trip mine

static exp_ContainerOption[MAX_PLAYERS];

hook OnPlayerViewCntOpt(playerid, containerid)
{
	new
		slot = GetPlayerContainerSlot(playerid),
		itemid = GetContainerSlotItem(containerid, slot),
		ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			if(GetItemExtraData(itemid) == 0)
				exp_ContainerOption[playerid] = AddContainerOption(playerid, "Arm Trip Mine");
			else
				exp_ContainerOption[playerid] = AddContainerOption(playerid, "Disarm Trip Mine");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	new
		slot = GetPlayerContainerSlot(playerid),
		itemid = GetContainerSlotItem(containerid, slot),
		ItemType:itemtype = GetItemType(itemid);

	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			if(option == exp_ContainerOption[playerid])
			{
				if(GetItemExtraData(itemid) == 0)
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

hook OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);
	
	if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
	{
		if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
		{
			if(GetItemExtraData(itemid) == 1)
			{
				new Float:x, Float:y, Float:z;

				GetPlayerPos(playerid, x, y, z);
				log(DISCORD_CHANNEL_ADMINEVENTS, "[EXPLOSIVE] Trip bomb `%d` triggered by `%p` at `%f, %f, %f`", itemid, playerid, x,y,z);
				SetItemToExplode(itemid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	new
		itemid,
		ItemType:itemtype;

	for(new i, j = GetContainerItemCount(containerid); i < j; i++)
	{
		itemid = GetContainerSlotItem(containerid, i);
		itemtype = GetItemType(itemid);

		if(exp_ItemTypeExplosive[itemtype] != INVALID_EXPLOSIVE_TYPE)
		{
			if(exp_Data[exp_ItemTypeExplosive[itemtype]][exp_trigger] == MOTION)
			{
				if(GetItemExtraData(itemid) == 1)
					SetItemToExplode(itemid);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Explosion functions

==============================================================================*/


stock CreateExplosionOfPreset(Float:x, Float:y, Float:z, EXP_PRESET:preset)
{
	switch(preset)
	{
		case EXP_INCEN:
			err("EXP_INCEN not implemented");

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
			items[256],
			count;

		count = GetItemsInRange(x, y, z, exp_Presets[preset][exp_size], items);
		defer _IterateItemDmg(items, sizeof(items), count, 0, exp_Presets[preset][exp_itemDmg]);
	}

	return 1;
}

// i, s, c, o, d = items, size, count, offset, damage
timer _IterateItemDmg[100](i[], s, c, o, d)
{
	#pragma unused s
	SetItemHitPoints(i[o], GetItemHitPoints(i[o]) - d);

	if(o < c)
		defer _IterateItemDmg(i, s, c, o + 1, d);
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
