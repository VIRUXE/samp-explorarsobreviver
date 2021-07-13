
#include <YSI_Coding\y_hooks>


static
	Item:arm_PlayerArmourItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Armour"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Armour"), 1);
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Armour)
		{
			SetItemExtraData(itemid, 25 + random(75));
		}
	}
}

hook OnPlayerConnect(playerid)
	arm_PlayerArmourItem[playerid] = INVALID_ITEM_ID;

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Armour)
	{
		if(GetPlayerAP(playerid) <= 0.0)
		{
			new data, Float:armour = 0.00001;

			GetItemExtraData(itemid, data);

			if(data > 0)
				armour = float(data);

			SetPlayerArmourItem(playerid, itemid);
			SetPlayerAP(playerid, armour);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Armour)
	{
		new
			amount,
			str[16];

		GetItemExtraData(itemid, amount);
		format(str, sizeof(str),  "%d%", amount);
		
		SetItemNameExtra(itemid, str);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{
	if(bodypart == 3)
	{
		new Float:ap = GetPlayerAP(targetid);

		if(ap > 0.0)
		{
			new Float:penetration = GetAmmoTypePenetration(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(GetPlayerItem(playerid))));

			bleedrate *= penetration;
			ap -= ((ap + 10) * (bleedrate * 10.0));

			SetPlayerAP(targetid, ap);
			SetItemExtraData(arm_PlayerArmourItem[playerid], floatround(ap));

			if(ap <= 0.0)
				DestroyItem(RemovePlayerArmourItem(playerid));

			DMG_FIREARM_SetBleedRate(targetid, bleedrate);
		}
		else if(IsValidItem(arm_PlayerArmourItem[playerid]))
			DestroyItem(RemovePlayerArmourItem(playerid));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock CreatePlayerArmour(playerid)
{
	return SetPlayerArmourItem(playerid, CreateItem(item_Armour));
}

stock SetPlayerArmourItem(playerid, Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	// TODO: Fix the coordinate for each skin in the future
	SetPlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR, 19515, 1,
		0.072999, 0.036000, 0.002999,  0.000000, 0.000000, 4.400002,  1.043000, 1.190000, 1.139000);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));

	if(IsValidItem(arm_PlayerArmourItem[playerid]))
	{
		GiveWorldItemToPlayer(playerid, arm_PlayerArmourItem[playerid]);
	}

	arm_PlayerArmourItem[playerid] = itemid;

	return 1;
}

stock Item:RemovePlayerArmourItem(playerid)
{
	new Item:itemid = arm_PlayerArmourItem[playerid];

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR);
	arm_PlayerArmourItem[playerid] = INVALID_ITEM_ID;

	return itemid;
}

stock Item:GetPlayerArmourItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return arm_PlayerArmourItem[playerid];
}
