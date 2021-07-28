
#include <YSI_Coding\y_hooks>


#define MAX_DEFENCE_ITEM		(14)
#define INVALID_DEFENCE_ID		(-1)
#define INVALID_DEFENCE_TYPE	(-1)

enum
{
	DEFENCE_POSE_HORIZONTAL,
	DEFENCE_POSE_VERTICAL,
	DEFENCE_POSE_SUPPORTED,
}

enum E_DEFENCE_ITEM_DATA
{
ItemType:	def_itemtype,
Float:		def_verticalRotX,
Float:		def_verticalRotY,
Float:		def_verticalRotZ,
Float:		def_horizontalRotX,
Float:		def_horizontalRotY,
Float:		def_horizontalRotZ,
Float:		def_placeOffsetZ,
bool:		def_movable
}

enum e_DEFENCE_DATA
{
bool:		def_active,
			def_pose,
			def_motor,
			def_keypad,
			def_pass,
			def_mod,
			def_hit,
Float:		def_buttonz,
			def_owner[MAX_PLAYER_NAME]
}

static
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeTotal,
			def_ItemTypeDefenceType[MAX_ITEM_TYPE] = {INVALID_DEFENCE_TYPE, ...},
			def_TweakArrow[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
Item:		def_CurrentDefenceItem[MAX_PLAYERS],
Item:		def_CurrentDefenceEdit[MAX_PLAYERS],
Item:		def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS],
			def_Col[MAX_ITEM] = {-1, ...},
PlayerText:	def_MoveTD[MAX_PLAYERS][2],
Timer:		def_MoveTime[MAX_PLAYERS];

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

	def_MoveTD[playerid][0] = CreatePlayerTextDraw(playerid, 473.000000, 270.000000, "up");
	PlayerTextDrawFont(playerid, def_MoveTD[playerid][0], 5);
	PlayerTextDrawLetterSize(playerid, def_MoveTD[playerid][0], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, def_MoveTD[playerid][0], 38.000000, 45.000000);
	PlayerTextDrawSetOutline(playerid, def_MoveTD[playerid][0], 0);
	PlayerTextDrawSetShadow(playerid, def_MoveTD[playerid][0], 0);
	PlayerTextDrawAlignment(playerid, def_MoveTD[playerid][0], 1);
	PlayerTextDrawColor(playerid, def_MoveTD[playerid][0], 0xFFFFFFFF);
	PlayerTextDrawBackgroundColor(playerid, def_MoveTD[playerid][0], 125);
	PlayerTextDrawSetProportional(playerid, def_MoveTD[playerid][0], 1);
	PlayerTextDrawSetSelectable(playerid, def_MoveTD[playerid][0], 1);
	PlayerTextDrawSetPreviewModel(playerid, def_MoveTD[playerid][0], 19133);
	PlayerTextDrawSetPreviewVehCol(playerid, def_MoveTD[playerid][0], 1, 1);
	PlayerTextDrawSetPreviewRot(playerid, def_MoveTD[playerid][0], 180.000000, 0.000000, 90.000000, 1.000000);

	def_MoveTD[playerid][1] = CreatePlayerTextDraw(playerid, 583.000000, 270.000000, "down");
	PlayerTextDrawFont(playerid, def_MoveTD[playerid][1], 5);
	PlayerTextDrawLetterSize(playerid, def_MoveTD[playerid][1], 0.600000, 2.000000);
	PlayerTextDrawTextSize(playerid, def_MoveTD[playerid][1], 38.000000, 45.000000);
	PlayerTextDrawSetOutline(playerid, def_MoveTD[playerid][1], 0);
	PlayerTextDrawSetShadow(playerid, def_MoveTD[playerid][1], 0);
	PlayerTextDrawAlignment(playerid, def_MoveTD[playerid][1], 1);
	PlayerTextDrawColor(playerid, def_MoveTD[playerid][1], 0xFFFFFFFF);
	PlayerTextDrawBackgroundColor(playerid, def_MoveTD[playerid][1], 125);
	PlayerTextDrawSetProportional(playerid, def_MoveTD[playerid][1], 1);
	PlayerTextDrawSetSelectable(playerid, def_MoveTD[playerid][1], 1);
	PlayerTextDrawSetPreviewModel(playerid, def_MoveTD[playerid][1], 19133);
	PlayerTextDrawSetPreviewRot(playerid, def_MoveTD[playerid][1], -10.000000, 0.000000, 90.000000, 1.000000);
}

hook OnPlayerDisconnet(playerid, reason)
{
	PlayerTextDrawDestroy(playerid, def_MoveTD[playerid][0]);
	PlayerTextDrawDestroy(playerid, def_MoveTD[playerid][1]);
	stop def_MoveTime[playerid];
}

/*==============================================================================

	Core

==============================================================================*/

stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, bool:movable)
{
	SetItemTypeMaxArrayData(itemtype, e_DEFENCE_DATA);

	def_TypeData[def_TypeTotal][def_itemtype] = itemtype;
	def_TypeData[def_TypeTotal][def_verticalRotX] = v_rx;
	def_TypeData[def_TypeTotal][def_verticalRotY] = v_ry;
	def_TypeData[def_TypeTotal][def_verticalRotZ] = v_rz;
	def_TypeData[def_TypeTotal][def_horizontalRotX] = h_rx;
	def_TypeData[def_TypeTotal][def_horizontalRotY] = h_ry;
	def_TypeData[def_TypeTotal][def_horizontalRotZ] = h_rz;
	def_TypeData[def_TypeTotal][def_placeOffsetZ] = zoffset;
	def_TypeData[def_TypeTotal][def_movable] = movable;
	def_ItemTypeDefenceType[itemtype] = def_TypeTotal;

	return def_TypeTotal++;
}

hook OnItemCreateInWorld(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		new itemdata[e_DEFENCE_DATA];

		GetItemArrayData(itemid, itemdata);

		itemdata[def_active] = false;

		if(itemdata[def_hit] > 0)
			SetItemHitPoints(itemid, itemdata[def_hit]);

		SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnGameModeExit(){
    foreach(new i : itm_WorldIndex){
		if(IsItemTypeDefence(GetItemType(Item:i))){
			new active;
			GetItemArrayDataAtCell(Item:i, active, def_active);
			if(active){
				CA_DestroyObject(def_Col[Item:i]);
			}
		}
    }
}

CreateDefenceColision(Item:itemid)
{
	new 
		Float:x, Float:y, Float:z,
		Float:rx, Float:ry, Float:rz,
		model;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
	GetItemTypeModel(GetItemType(itemid), model);

    def_Col[itemid] = CA_CreateObject(model, x, y, z, rx, ry, rz, true);
	CA_SetObjectExtraID(def_Col[itemid], 0, _:itemid);
}

ActivateDefenceItem(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		err(true, true, "Attempted to create defence from item with invalid type (%d)", _:itemtype);
		return 1;
	}

	new defencetype = def_ItemTypeDefenceType[itemtype];

	if(defencetype == INVALID_DEFENCE_TYPE)
	{
		err(true, true, "Attempted to create defence from item that is not a defence type (%d)", _:itemtype);
		return 2;
	}

	new
		itemtypename[MAX_ITEM_NAME],
		itemdata[e_DEFENCE_DATA],
		Float:x, Float:y, Float:z,
		Button:buttonid;

	GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);
	GetItemArrayData(itemid, itemdata);
	GetItemButtonID(itemid, buttonid);

	itemdata[def_active] = true;

	if(itemdata[def_motor])
	{
		SetButtonText(buttonid, sprintf("F para abrir %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}
	else
	{
		SetButtonText(buttonid, sprintf("F para modificar %s", itemtypename));
		SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)));
	}

	if(itemdata[def_hit] > 0)
		SetItemHitPoints(itemid, itemdata[def_hit]);


	GetButtonPos(buttonid, x, y, z);
	SetButtonPos(buttonid, x, y, itemdata[def_buttonz]);

	SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);

	return 0;
}

DeconstructDefence(Item:itemid, playerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		ItemType:itemtype,
		itemdata[e_DEFENCE_DATA],
		name[MAX_ITEM_NAME];

	GetItemPos(itemid, x, y, z);
	itemtype = GetItemType(itemid);
	GetItemArrayData(itemid, itemdata);
	GetItemTypeName(itemtype, name);

	CA_DestroyObject(def_Col[itemid]);
	def_Col[itemid] = -1;

	GetPlayerPos(playerid, x, y, z);
	SetItemLabel(itemid, name);
	SetItemPos(itemid, x, y, z - ITEM_FLOOR_OFFSET);
	SetItemRot(itemid, 0.0, 0.0, 0.0, true);

	SetItemArrayDataAtCell(itemid, false, def_active);
	SetItemArrayDataAtCell(itemid, 0, def_pose);
	SetItemArrayDataAtCell(itemid, 0, def_motor);
	SetItemArrayDataAtCell(itemid, 0, def_keypad);
	SetItemArrayDataAtCell(itemid, 0, def_pass);
	SetItemArrayDataAtCell(itemid, 0, def_mod);

	CallLocalFunction("OnDefenceDestroy", "d", _:itemid);
}


/*==============================================================================

	Internal

==============================================================================*/

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);
	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		CA_RayCastLine(x, y, z, x, y, z - 2.0, z, z, z);
		SetItemPos(itemid, x, y, z + 0.15);
	}
}

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

	return Y_HOOKS_CONTINUE_RETURN_0;
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
			if(IsValidItem(def_CurrentDefenceEdit[playerid]))
			{
				StopBuildingDefence(playerid);
			}
			else if(!_InteractDefenceWithItem(playerid, withitemid, itemid))
				_InteractDefence(playerid, withitemid);
		}
		else if(IsValidItem(def_CurrentDefenceItem[playerid]))
		{
			StopBuildingDefence(playerid);
		}
		else
		{
			new ItemType:itemtype = GetItemType(itemid);

			if(itemtype == item_Hammer || itemtype == item_Screwdriver)
				StartBuildingDefence(playerid, withitemid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
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

_InteractDefence(playerid, Item:itemid)
{
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemid, data);

	if(data[def_motor])
	{
		if(data[def_keypad] == 1)
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
			stop def_MoveTime[playerid];
			def_MoveTime[playerid] = defer MoveDefence(_:itemid, playerid);
		}
	}

	CallLocalFunction("OnPlayerInteractDefence", "dd", playerid, _:itemid);
}

_InteractDefenceWithItem(playerid, Item:itemid, Item:tool)
{
	new
		defencetype,
		ItemType:tooltype,
		Float:angle,
		Float:angletoplayer,
		Button:buttonid;

	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];
	tooltype = GetItemType(tool);
	GetItemRot(itemid, angle, angle, angle);
	GetItemButtonID(itemid, buttonid);
	GetButtonAngleToPlayer(playerid, buttonid, angletoplayer);

	angle = absoluteangle((angle - def_TypeData[defencetype][def_verticalRotZ]) - angletoplayer);

	// ensures the player can only perform these actions on the back-side.
	if(!(90.0 < angle < 270.0))
	{
		new name[MAX_PLAYER_NAME], itemdata[e_DEFENCE_DATA];

		GetItemArrayData(itemid, itemdata);
		GetPlayerName(playerid, name);

		if(!strcmp(name, itemdata[def_owner]))
			ShowActionText(playerid, "Essa defesa é sua, por isso poderá modificá-la.", 5000);
		else 	
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
		StartHoldAction(playerid, GetPlayerSkillTimeModifier(playerid, 10000, "Construction"));
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
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]) || GetPlayerTotalVelocity(playerid) > 1.0)
			StopBuildingDefence(playerid), StopHoldAction(playerid);
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
			Item:itemid = def_CurrentDefenceItem[playerid],
			ItemType:itemtype,
			pose;

		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Screwdriver)
			pose = DEFENCE_POSE_VERTICAL;

		if(itemtype == item_Hammer)
			pose = DEFENCE_POSE_HORIZONTAL;

		ConvertItemToDefenceItem(itemid, pose, playerid);

		if(!IsValidItem(itemid))
		{
			ChatMsgLang(playerid, RED, "DEFLIMITREA");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		StopBuildingDefence(playerid);
		TweakItem(playerid, itemid);
		_UpdateDefenceTweakArrow(playerid, itemid);
		PlayerGainSkillExperience(playerid, "Construction");
		ShowHelpTip(playerid, ls(playerid, "TIPTWEAKDEF"));

		PlayerTextDrawShow(playerid, def_MoveTD[playerid][0]);
		PlayerTextDrawShow(playerid, def_MoveTD[playerid][1]);

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

			log(true, "[CROWBAR] %p broke defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
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
				ShowActionText(playerid, ls(playerid, "DEFMOVINGIT"), 3000);
				stop def_MoveTime[playerid];
				def_MoveTime[playerid] = defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
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

				log(true, "[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, code);
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

ConvertItemToDefenceItem(Item:itemid, pose, playerid)
{
	new ret = ActivateDefenceItem(itemid);
	if(ret)
		return ret;
		
	new
		itemdata[e_DEFENCE_DATA],
		ItemType:itemtype = GetItemType(itemid),
		Float:x, Float:y, Float:z,
		Float:ix, Float:iy, Float:iz,
		Float:rx, Float:ry, Float:rz,
		Float:a, Button:buttonid, name[MAX_PLAYER_NAME];

	GetItemArrayData(itemid, itemdata);
	GetPlayerPos(playerid, x, y, z);
	GetItemPos(itemid, ix, iy, iz);
	GetItemRot(itemid, rx, ry, rz);
	a = GetAngleToPoint(x, y, ix, iy);
	GetItemButtonID(itemid, buttonid);
	GetPlayerName(playerid, name, sizeof(name));

	itemdata[def_pose] = pose;

	if(pose == DEFENCE_POSE_HORIZONTAL)
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotZ];
	}
	else if(pose == DEFENCE_POSE_VERTICAL)
	{
		iz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotZ];
	}

	x += 0.9 * floatsin(-a, degrees);
	y += 0.9 * floatcos(-a, degrees);

	SetItemPos(itemid, x, y, iz);
	SetItemRot(itemid, rx, ry, rz);

	itemdata[def_buttonz] = z;
	GetPlayerName(playerid, itemdata[def_owner]);
	SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);

	SetButtonPos(buttonid, x, y, z);

	_UpdateDefenceTweakArrow(playerid, itemid);
	
	return CallLocalFunction("OnDefenceCreate", "d", _:itemid);
}

_UpdateDefenceTweakArrow(playerid, Item:itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz,
		world,
		interior,
		ItemType:type = GetItemType(itemid),
		Button:buttonid, 
		Float:buttonz;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
	GetItemWorld(itemid, world);
	GetItemInterior(itemid, interior);
	GetItemButtonID(itemid, buttonid);
	GetItemArrayDataAtCell(itemid, _:buttonz, def_buttonz);

	SetButtonPos(buttonid, x, y, buttonz);

	if(!IsValidDynamicObject(def_TweakArrow[playerid])){
		def_TweakArrow[playerid] = CreateDynamicObject(19133, x, y, z, 0.0, 0.0, 0.0, world, interior);
		SetDynamicObjectMaterial(def_TweakArrow[playerid], 0, 10765, "airportgnd_sfse", "desgreengrass", 0xFF00FF00);
		SetDynamicObjectMaterial(def_TweakArrow[playerid], 1, -1, "none", "none", 0xFF00FF00);
		PlayerTextDrawShow(playerid, def_MoveTD[playerid][0]);
		PlayerTextDrawShow(playerid, def_MoveTD[playerid][1]);
	}
		
	new pose;
	GetItemArrayDataAtCell(itemid, pose, def_pose);
	if(pose == DEFENCE_POSE_VERTICAL)
	{
		SetDynamicObjectPos(def_TweakArrow[playerid], x, y, z - def_TypeData[def_ItemTypeDefenceType[type]][def_placeOffsetZ]);
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[type]][def_verticalRotX] + 90,
			ry - def_TypeData[def_ItemTypeDefenceType[type]][def_verticalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[type]][def_verticalRotZ]);
	}
	else
	{
		SetDynamicObjectPos(def_TweakArrow[playerid], x, y, z);
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[type]][def_horizontalRotX],
			ry - def_TypeData[def_ItemTypeDefenceType[type]][def_horizontalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[type]][def_horizontalRotZ]);
	}
}

hook OnItemTweakUpdate(playerid, Item:itemid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
		_UpdateDefenceTweakArrow(playerid, itemid);
		ShowActionText(playerid, "Movendo..", 1000);
	}
	return 1;
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
		PlayerTextDrawHide(playerid, def_MoveTD[playerid][0]);
		PlayerTextDrawHide(playerid, def_MoveTD[playerid][1]);

		DestroyDynamicObject(def_TweakArrow[playerid]);
		def_TweakArrow[playerid] = INVALID_OBJECT_ID;
		CreateDefenceColision(itemid);
		CallLocalFunction("OnDefenceModified", "d", _:itemid);
	}
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
		new Item:itemid = GetPlayerTweakItem(playerid);

		if(IsValidItem(itemid))
		{
			new Float:x, Float:y, Float:z, Float:pz;

			GetItemPos(itemid, x, y, z);
			GetPlayerPos(playerid, pz, pz, pz);

			if(playertextid == def_MoveTD[playerid][0])
				if(z < pz + (3.0) )
					SetItemPos(itemid, x, y, z + 0.05), ShowActionText(playerid, "Movendo..", 1000);
				else
					ShowActionText(playerid, "Nao sobe mais que isto", 1000);

			if(playertextid == def_MoveTD[playerid][1])
				if(z > pz - 1.0)
					SetItemPos(itemid, x, y, z - 0.05), ShowActionText(playerid, "Movendo..", 1000);
				else
					ShowActionText(playerid, "Nao desce mais que isto", 1000);

			_UpdateDefenceTweakArrow(playerid, itemid);
		}
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
				stop def_MoveTime[playerid];
				def_MoveTime[playerid] = defer MoveDefence(_:def_CurrentDefenceOpen[playerid], playerid);
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

				log(true, "[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, _:def_CurrentDefenceOpen[playerid], uuid, pass);
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

	if(!IsItemInWorld(Item:itemid))
		return;
		
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetItemPos(Item:itemid, ix, iy, iz);

	foreach(new i : Player)
	{
		GetPlayerPos(i, px, py, pz);

		if(Distance(px, py, pz, ix, iy, iz) < 3.0)
		{
			def_MoveTime[playerid] = defer MoveDefence(itemid, playerid);
			return;
		}
	}

	new
		ItemType:itemtype = GetItemType(Item:itemid),
		Float:rx,
		Float:ry,
		Float:rz,
		uuid[UUID_LEN],
		pose,
		Button:buttonid,
		Float:buttonz;

	GetItemRot(Item:itemid, rx, ry, rz);
	GetItemUUID(Item:itemid, uuid);
	GetItemArrayDataAtCell(Item:itemid, pose, def_pose);
	GetItemButtonID(Item:itemid, buttonid);

	if(pose == DEFENCE_POSE_HORIZONTAL)
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_verticalRotZ];
		iz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
		SetItemArrayDataAtCell(Item:itemid, DEFENCE_POSE_VERTICAL, def_pose);
	}
	else
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotZ];
		iz -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
		SetItemArrayDataAtCell(Item:itemid, DEFENCE_POSE_HORIZONTAL, def_pose);
	}

	SetItemPos(Item:itemid, ix, iy, iz);
	SetItemRot(Item:itemid, rx, ry, rz);
	
	GetItemArrayDataAtCell(Item:itemid, _:buttonz, def_buttonz);
	SetButtonPos(buttonid, ix, iy, buttonz);

	CA_DestroyObject(def_Col[Item:itemid]);
	def_Col[Item:itemid] = -1;
	CreateDefenceColision(Item:itemid);

	CallLocalFunction("OnDefenceMove", "d", itemid);

	return;
}


hook OnItemHitPointsUpdate(Item:itemid, oldvalue, newvalue)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
	{
		new itemdata[e_DEFENCE_DATA];
		GetItemArrayData(itemid, itemdata);
		if(itemdata[def_active])
		{
			SetItemLabel(itemid, sprintf("%d/%d", GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)), RED, 20.0);
			itemdata[def_hit] = GetItemHitPoints(itemid);
			CallLocalFunction("OnDefenceModified", "d", _:itemid);
		}
		SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);
	}
		
}

hook OnItemDestroy(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
	{
		if(def_Col[itemid] != -1)
			CA_DestroyObject(def_Col[itemid]), def_Col[itemid] = -1;
		
		new active;
		GetItemArrayDataAtCell(itemid, active, def_active);
		if(active)
		{
			CallLocalFunction("OnDefenceDestroy", "d", _:itemid);
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

// def_verticalRotX
// def_verticalRotY
// def_verticalRotZ
stock GetDefenceTypeVerticalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_verticalRotX];
	y = def_TypeData[defencetype][def_verticalRotY];
	z = def_TypeData[defencetype][def_verticalRotZ];

	return 1;
}

// def_horizontalRotX
// def_horizontalRotY
// def_horizontalRotZ
stock GetDefenceTypeHorizontalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_horizontalRotX];
	y = def_TypeData[defencetype][def_horizontalRotY];
	z = def_TypeData[defencetype][def_horizontalRotZ];

	return 1;
}

// def_placeOffsetZ
forward Float:GetDefenceTypeOffsetZ(defencetype);
stock Float:GetDefenceTypeOffsetZ(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0.0;

	return def_TypeData[defencetype][def_placeOffsetZ];
}

// def_type
stock GetDefenceType(Item:itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	return def_ItemTypeDefenceType[GetItemType(itemid)];
}