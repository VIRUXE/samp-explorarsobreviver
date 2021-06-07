/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_DEFENCE_ITEM		(14)
#define INVALID_DEFENCE_ID		(-1)
#define INVALID_DEFENCE_TYPE	(-1)


enum E_DEFENCE_ITEM_DATA
{
ItemType:	def_itemtype,
Float:		def_openRotX,
Float:		def_openRotY,
Float:		def_openRotZ,
bool:		def_correctZ,
bool:		def_movable
}

enum e_DEFENCE_DATA
{
bool:		def_active,
bool:		def_open,
			def_motor,
			def_keypad,
			def_pass,
			def_Owner[MAX_PLAYER_NAME],
			def_mod,
}


static
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeTotal,
			def_ItemTypeDefenceType[MAX_ITEM_TYPE] = {INVALID_DEFENCE_TYPE, ...};

static
			def_OpenObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
Item:		def_CurrentDefenceItem[MAX_PLAYERS],
Item:		def_CurrentDefenceEdit[MAX_PLAYERS],
Item:		def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_LastPassword[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS],
			def_Col[MAX_ITEM],
Timer:		MoveDefenceDelay[MAX_PLAYERS];

stock CreateDefenceColision(Item:itemid)
{
	new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, model;
	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
	GetItemTypeModel(GetItemType(itemid), model);
    def_Col[itemid] = CA_CreateObject(model, x, y, z, rx, ry, rz, true);
	CA_SetObjectExtraID(def_Col[itemid], 0, _:itemid);
}
forward OnDefenceCreate(Item:itemid);
forward OnDefenceDestroy(Item:itemid);
forward OnDefenceModified(Item:itemid);
forward OnDefenceMove(Item:itemid);
forward OnPlayerInteractDefence(playerid, Item:itemid);


/*==============================================================================

	Zeroing

==============================================================================*/

public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z)
{
	return 1;
}

hook OnPlayerConnect(playerid)
{
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
	def_LastPassEntry[playerid] = 0;
	def_Cooldown[playerid] = 2000;
	def_PassFails[playerid] = 0;
	def_LastPassword[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, bool:cz, bool:movable)
{
	SetItemTypeMaxArrayData(itemtype, e_DEFENCE_DATA);

	def_TypeData[def_TypeTotal][def_itemtype] = itemtype;
	def_TypeData[def_TypeTotal][def_openRotX] = v_rx;
	def_TypeData[def_TypeTotal][def_openRotY] = v_ry;
	def_TypeData[def_TypeTotal][def_openRotZ] = v_rz;
	def_TypeData[def_TypeTotal][def_correctZ] = cz;
	def_TypeData[def_TypeTotal][def_movable] = movable;
	def_ItemTypeDefenceType[itemtype] = def_TypeTotal;

	return def_TypeTotal++;
}

ActivateDefenceItem(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		err("Attempted to create defence from item with invalid type (%d)", _:itemtype);
		return 1;
	}

	new defencetype = def_ItemTypeDefenceType[itemtype];

	if(defencetype == INVALID_DEFENCE_TYPE)
	{
		err("Attempted to create defence from item that is not a defence type (%d)", _:itemtype);
		return 2;
	}

	new
		itemtypename[MAX_ITEM_NAME],
		itemdata[e_DEFENCE_DATA],
		Button:buttonid;

	GetItemButtonID(itemid, buttonid);
	GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);
	GetItemArrayData(itemid, itemdata);

	if(itemdata[def_motor])
	{
		SetButtonText(buttonid, sprintf(""KEYTEXT_INTERACT" to open %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}
	else
	{
		SetButtonText(buttonid, sprintf(""KEYTEXT_INTERACT" to modify %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}
	
	SetButtonSize(buttonid, 2.2);

	itemdata[def_active] = true;

	SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);
	return 0;
}

DeconstructDefence(Item:itemid, playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		ItemType:itemtype = GetItemType(itemid),
		itemdata[e_DEFENCE_DATA],
		Button:buttonid;

	GetPlayerPos(playerid, x, y, z);
	GetItemArrayData(itemid, itemdata);
	GetItemButtonID(itemid, Button:buttonid);

	new itemtypename[MAX_ITEM_NAME];
	GetItemTypeName(def_TypeData[def_ItemTypeDefenceType[itemtype]][def_itemtype], itemtypename);

	SetButtonText(Button:buttonid, sprintf("%s", itemtypename));
    SetItemLabel(itemid, sprintf("%s", itemtypename), 0xFFFF00FF);

	SetItemPos(itemid, x, y, z - ITEM_FLOOR_OFFSET);
	SetItemRot(itemid, 0.0, 0.0, 0.0, true);

	SetItemArrayDataAtCell(itemid, 0, def_keypad);
	SetItemArrayDataAtCell(itemid, 0, def_motor);
	SetItemArrayDataAtCell(itemid, false, def_open);

	SetItemArrayDataAtCell(itemid, 0, 0);

	CA_DestroyObject(def_Col[itemid]);
	CallLocalFunction("OnDefenceDestroy", "d", _:itemid);
}


/*==============================================================================

	Internal

==============================================================================*/

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		new active;
		GetItemArrayDataAtCell(itemid, active, def_active);
		if(active)
		{
			_InteractDefence(playerid, itemid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	new ItemType:withitemtype = GetItemType(withitemid);

	if(def_ItemTypeDefenceType[withitemtype] != INVALID_DEFENCE_TYPE)
	{
		new active;
		GetItemArrayDataAtCell(withitemid, active, def_active);
		if(active)
		{
			if(!_InteractDefenceWithItem(playerid, withitemid, itemid))
				_InteractDefence(playerid, withitemid);
		}
		else
		{
			new ItemType:itemtype = GetItemType(itemid);

			if(itemtype == item_Screwdriver)
				StartBuildingDefence(playerid, withitemid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopBuildingDefence(playerid);
	}
}

StartBuildingDefence(playerid, Item:itemid)
{
	new itemtypename[MAX_ITEM_NAME];

	GetItemTypeName(GetItemType(itemid), itemtypename);

	def_CurrentDefenceItem[playerid] = itemid;
	StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, "Construction"));
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, sprintf(ls(playerid, "DEFBUILDING"), itemtypename));

	return 1;
}

StopBuildingDefence(playerid)
{
	if(!IsValidItem(GetPlayerItem(playerid)))
		return;

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);

		return;
	}

	if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
	{
		def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);
		
		return;
	}

	return;
}

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = def_LastPassword[playerid];

	modio_push(filename, _T<D,P,A,W>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];

	modio_read(filename, _T<D,P,A,W>, 1, data);

	def_LastPassword[playerid] = data[0];
}

_InteractDefence(playerid, Item:itemid)
{
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemid, data);

	if(data[def_motor])
	{
		if(def_LastPassword[playerid] == data[def_pass] && def_LastPassword[playerid] != 0)
		{
			ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
			stop MoveDefenceDelay[playerid];
			MoveDefenceDelay[playerid] = defer MoveDefence(_:itemid, playerid);
			PlayerPlaySound(playerid, 21002, 0.0, 0.0, 0.0); // Keyboard sound
		}
		else if(data[def_keypad] == 1)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_Keypad(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_Keypad(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else if(data[def_keypad] == 2)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_KeypadAdv(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
				{
					HideKeypad(playerid);
					Dialog_Hide(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_KeypadAdv(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
			stop MoveDefenceDelay[playerid];
			MoveDefenceDelay[playerid] = defer MoveDefence(_:itemid, playerid);
		}
	}

	CallLocalFunction("OnPlayerInteractDefence", "dd", playerid, _:itemid);
}

_InteractDefenceWithItem(playerid, Item:itemid, Item:tool)
{	
	new
		defencetype,
		ItemType:tooltype,
		pName[MAX_PLAYER_NAME],
		itemdata[e_DEFENCE_DATA];

	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];
	tooltype = GetItemType(tool);

	GetPlayerName(playerid, pName, MAX_PLAYER_NAME);
	GetItemArrayData(itemid, itemdata);

	if(strcmp(pName, itemdata[def_Owner], false))
	{
		new Float:tx, Float:ty, Float:tz, Float:ix, Float:iy, Float:iz, tents;
		GetItemPos(itemid, ix, iy, iz);

		foreach(new i : tnt_Index)
		{
			GetTentPos(i, tx, ty, tz);
			if(Distance(ix, iy, iz, tx, ty, tz) < 20.0)
				tents ++;
		}
		if(tents > 0)
			ChatMsg(playerid, RED,
				" > Você precisa ser o dono dessa defesa para edita-la ou destrua todas as tendas próximas.");
		return 0;
	}

	if(tooltype == item_Crowbar)
	{
		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, sprintf(ls(playerid, "DEFREMOVING"), itemtypename));

		return 1;
	}

	if(tooltype == item_Motor)
	{
		if(!def_TypeData[defencetype][def_movable])
		{
			ShowActionText(playerid, ls(playerid, "DEFNOTMOVAB"));
			return 1;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_Keypad)
	{
		new hasmotor;
		GetItemArrayDataAtCell(itemid, hasmotor, _:def_motor);
		if(!hasmotor)
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 1;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	if(tooltype == item_AdvancedKeypad)
	{
		new hasmotor;
		GetItemArrayDataAtCell(itemid, hasmotor, _:def_motor);
		if(!hasmotor)
		{
			ShowActionText(playerid, ls(playerid, "DEFNEEDMOTO"));
			return 0;
		}

		new itemtypename[MAX_ITEM_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 6000, "Construction"));
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "DEFMODIFYIN"), itemtypename));

		return 1;
	}

	return 0;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_0;

		new
			Item:itemid = def_CurrentDefenceItem[playerid];

		new Float:x, Float:y, Float:z, Float:ang;
		GetItemPos(itemid, x, y, z);
		GetPlayerFacingAngle(playerid, ang);

		x += 1 * floatsin(-ang, degrees), y += 1 * floatcos(-ang, degrees);

		SetItemPos(itemid, x, y, z);
		
		ConvertItemToDefenceItem(itemid);

		SetItemRot(itemid, 0.0, 0.0, ang - 30.0);


		if(!IsValidItem(itemid))
		{
			ChatMsgLang(playerid, RED, "DEFLIMITREA");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		StopBuildingDefence(playerid);

		TweakItem(playerid, itemid);
		PlayerGainSkillExperience(playerid, "Construction");
		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
	{
		new
			Item:itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_Motor)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTMOTO"));
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], true, def_motor);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);

			new
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz;

			GetItemPos(def_CurrentDefenceEdit[playerid], x, y, z);
			GetItemRot(def_CurrentDefenceEdit[playerid], rx, ry, rz);

			TweakItem(playerid, def_CurrentDefenceEdit[playerid]);
			DefenceOpenObject(playerid, def_CurrentDefenceEdit[playerid]);
		}

		if(itemtype == item_Keypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTKEYP"));
			ShowSetPassDialog_Keypad(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 1, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_AdvancedKeypad)
		{
			ShowActionText(playerid, ls(playerid, "DEFINSTADKP"));
			ShowSetPassDialog_KeypadAdv(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 2, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Crowbar)
		{
			new
				uuid[UUID_LEN],
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz,
				model;

			GetItemUUID(def_CurrentDefenceEdit[playerid], uuid);
			GetItemPos(def_CurrentDefenceEdit[playerid], x, y, z);
			GetItemRot(def_CurrentDefenceEdit[playerid], rz, rz, rz);
			ShowActionText(playerid, ls(playerid, "DEFDISMANTL"));
			GetItemTypeModel(GetItemType(def_CurrentDefenceEdit[playerid]), model);

			DeconstructDefence(def_CurrentDefenceEdit[playerid], playerid);

			log("[CROWBAR] %p broke defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
				playerid, _:def_CurrentDefenceEdit[playerid], uuid,
				model, x, y, z, rx, ry, rz);

			/*
				Note:
				This log entry is designed to help with reconstructing bases
				in the case that they are wrongfully deconstructed. The
				section in parentheses mimics the structure of the arguments
				for CreateObject so it can easily be plugged into a map
				editor to view the original base.
			*/

			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
		{
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], code, def_pass);
			CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;

			if(code == 0)
				ChatMsgLang(playerid, YELLOW, "DEFCODEZERO");

			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(def_CurrentDefenceOpen[playerid] != INVALID_ITEM_ID)
		{
			if(code == match)
			{
				def_LastPassword[playerid] = match;
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				stop MoveDefenceDelay[playerid];
				MoveDefenceDelay[playerid] = defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_Keypad(playerid, 2);
					return Y_HOOKS_BREAK_RETURN_0;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
					return Y_HOOKS_BREAK_RETURN_0;
				}

				new uuid[UUID_LEN];

				GetItemUUID(def_CurrentDefenceOpen[playerid], uuid);

				log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, code);
				ShowEnterPassDialog_Keypad(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;

				return Y_HOOKS_BREAK_RETURN_0;
			}

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ConvertItemToDefenceItem(Item:itemid)
{
	new ret = ActivateDefenceItem(itemid);
	if(ret)
		return ret;

	SetItemArrayDataAtCell(itemid, false, def_open);

	new
		ItemType:itemtype = GetItemType(itemid), model,
		Float:x, Float:y, Float:z, objectid,
		Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz,
		Float:rz;

	GetItemObjectID(itemid, objectid);
	GetItemTypeModel(itemtype, model);
	CA_GetModelBoundingBox(model, minx, miny, minz, maxx, maxy, maxz);
	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);
	SetItemPos(itemid, x, y, z + floatabs(minz));
	SetItemRot(itemid, 0.0, 0.0, rz);

	return CallLocalFunction("OnDefenceCreate", "d", _:itemid);
}

DefenceOpenObject(playerid, Item:itemid)
{
	new hasmotor;
	GetItemArrayDataAtCell(itemid, hasmotor, _:def_motor);
	if(!hasmotor)
		return 0;

	new 
		world, interior, ItemType:itemtype = GetItemType(itemid), model, objectid,
		Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
	
	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
	GetItemWorld(itemid, world);
	GetItemInterior(itemid, interior);
	GetItemTypeModel(itemtype, model);
	GetItemObjectID(itemid, objectid);

	new Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz;
	if(def_TypeData[def_ItemTypeDefenceType[itemtype]][def_correctZ])
		CA_GetModelBoundingBox(model, minx, miny, minz, maxx, maxy, maxz);

	rx += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotX];
	ry += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotY];
	rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotZ];
	z += minz;

	if(!IsValidDynamicObject(def_OpenObject[playerid]))
		def_OpenObject[playerid] = CreateDynamicObject(model, x, y, z, rx, ry, rz, world, interior);

	SetDynamicObjectPos(def_OpenObject[playerid], x, y, z);
	SetDynamicObjectRot(def_OpenObject[playerid], rx, ry, rz);

	for(new i = 0; i < 15; i++)
		SetDynamicObjectMaterial(def_OpenObject[playerid], i, -1, "none", "none", 0xBE00FF00);

	return 1;
}

hook OnItemTweakUpdate(playerid, Item:itemid)
{
	DefenceOpenObject(playerid, itemid);
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(def_ItemTypeDefenceType[GetItemType(itemid)] != -1)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz,
			itemdata[e_DEFENCE_DATA];

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);
		GetItemArrayData(itemid, itemdata);
		GetPlayerName(playerid, itemdata[def_Owner], MAX_PLAYER_NAME);
		SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);

		CA_DestroyObject(def_Col[itemid]);
		new ItemType:itemtype, model;
		itemtype = GetItemType(Item:itemid);
		GetItemTypeModel(itemtype, model);
	
		def_Col[itemid] = CA_CreateObject(model, x, y, z, rx, ry, rz, true);
		CA_SetObjectExtraID(def_Col[itemid], 0, _:itemid);
		CallLocalFunction("OnDefenceModified", "d", _:itemid);
	}
	if(def_OpenObject[playerid] != INVALID_OBJECT_ID)
	{
		stop MoveDefenceDelay[playerid];
		MoveDefenceDelay[playerid] = defer MoveDefence(_:itemid, playerid);
		DestroyDynamicObject(def_OpenObject[playerid]);
		def_OpenObject[playerid] = INVALID_OBJECT_ID;
	}
}

hook OnPlayerKeypadCancel(playerid, keypadid)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID)
		{
			ShowSetPassDialog_Keypad(playerid);
			def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;

			return 1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ShowSetPassDialog_Keypad(playerid)
{
	ChatMsgLang(playerid, YELLOW, "DEFSETPASSC");

	ShowKeypad(playerid, 100);
}

ShowEnterPassDialog_Keypad(playerid, msg = 0)
{
	if(msg == 0)
		ChatMsgLang(playerid, YELLOW, "DEFENTERPAS");

	if(msg == 1)
		ChatMsgLang(playerid, YELLOW, "DEFINCORREC");

	if(msg == 2)
		ChatMsgLang(playerid, YELLOW, "DEFTOOFASTE", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	new pass;
	GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], pass, def_pass);
	ShowKeypad(playerid, 100, pass);
}

ShowSetPassDialog_KeypadAdv(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new pass;

			if(!sscanf(inputtext, "x", pass) && strlen(inputtext) >= 4)
			{
				SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], pass, def_pass);
				CallLocalFunction("OnDefenceModified", "d", _:def_CurrentDefenceEdit[playerid]);
				def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;
			}
			else
			{
				ShowSetPassDialog_KeypadAdv(playerid);
			}
		}
		else
		{
			ShowSetPassDialog_KeypadAdv(playerid);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Set passcode", "Enter a passcode between 4 and 8 characters long using characers 0-9, a-f.", "Enter", "");

	return 1;
}

ShowEnterPassDialog_KeypadAdv(playerid, msg = 0)
{
	if(msg == 2)
		ChatMsgLang(playerid, YELLOW, "DEFTOOFASTE", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new pass, defpass;

			sscanf(inputtext, "x", pass);
			GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], defpass, def_pass);

			if(pass == defpass && strlen(inputtext) >= 4)
			{
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				stop MoveDefenceDelay[playerid];
				MoveDefenceDelay[playerid] = defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = INVALID_ITEM_ID;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_KeypadAdv(playerid, 2);
					return 1;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
					return 1;
				}

				new uuid[UUID_LEN];

				GetItemUUID(def_CurrentDefenceOpen[playerid], uuid);

				log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, pass);
				ShowEnterPassDialog_KeypadAdv(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;
			}
		}
		else
		{
			return 0;
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Enter passcode", (msg == 1) ? ("Incorrect passcode!") : ("Enter the 4-8 character hexadecimal passcode to open."), "Enter", "Cancel");

	return 1;
}

timer MoveDefence[1000](itemid, playerid)
{
	new objectid;
	GetItemObjectID(Item:itemid, objectid);
	if(IsDynamicObjectMoving(objectid))
		return;

	new ItemType:itemtype = GetItemType(Item:itemid),
		Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz,
		Float:px, Float:py, Float:pz, bool:open, model;

	GetPlayerPos(playerid, px, py, pz);
	GetItemPos(Item:itemid, x, y, z);
	GetDynamicObjectRot(objectid, rx, ry, rz);
	GetItemArrayDataAtCell(Item:itemid, open, def_open);
	GetItemTypeModel(itemtype, model);


	if(open)
	{
		rx -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotX];
		ry -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotY];
		rz -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotZ];
		SetItemArrayDataAtCell(Item:itemid, false, def_open);
	}
	else
	{
		rx += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotX];
		ry += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_openRotZ];
		if(def_TypeData[def_ItemTypeDefenceType[itemtype]][def_correctZ])
		{
			new Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz;
			CA_GetModelBoundingBox(model, minx, miny, minz, maxx, maxy, maxz);
			z += minz;
		}
		SetItemArrayDataAtCell(Item:itemid, true, def_open);
	}

	MoveDynamicObject(objectid, x, y, z, 0.75, rx, ry, rz);

	CA_DestroyObject(def_Col[Item:itemid]);
	def_Col[Item:itemid] = CA_CreateObject(model, x, y, z, rx, ry, rz, true);
	CA_SetObjectExtraID(def_Col[Item:itemid], 0, _:itemid);
	//SetPlayerPos(playerid, px, py, pz);
	return;
}

hook OnItemHitPointsUpdate(Item:itemid, oldvalue, newvalue)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
}

hook OnItemDestroy(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
	{
		if(GetItemHitPoints(itemid) <= 0)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz,
				model;

			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, rx, ry, rz);
			GetItemTypeModel(itemtype, model);
			CA_DestroyObject(def_Col[itemid]);
			CallLocalFunction("OnDefenceDestroy", "d", _:itemid);
			log("[DESTRUCTION] Defence %d (%d) Object: (%d, %f, %f, %f, %f, %f, %f)", _:itemid, _:itemtype, model, x, y, z, rx, ry, rz);
		}
	}
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock IsValidDefenceType(type)
{
	if(0 <= type < def_TypeTotal)
		return 1;

	return 0;
}

stock GetItemTypeDefenceType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return INVALID_DEFENCE_TYPE;

	return def_ItemTypeDefenceType[itemtype];
}

stock IsItemTypeDefence(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return false;

	if(def_ItemTypeDefenceType[itemtype] != -1)
		return true;

	return false;
}

// def_itemtype
forward ItemType:GetDefenceTypeItemType(defencetype);
stock ItemType:GetDefenceTypeItemType(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return INVALID_ITEM_TYPE;

	return def_TypeData[defencetype][def_itemtype];
}

// def_type
stock GetDefenceType(Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	return def_ItemTypeDefenceType[GetItemType(itemid)];
}

// def_pose
stock GetDefencePose(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pose);
}

// def_motor
stock GetDefenceMotor(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_motor);
}

// def_keypad
stock GetDefenceKeypad(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_keypad);
}

// def_pass
stock GetDefencePass(Item:itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pass);
}

// def_active
stock GetDefenceActive(Item:itemid)
{
	new active;
	GetItemArrayDataAtCell(itemid, active, def_active);
	return active;
}