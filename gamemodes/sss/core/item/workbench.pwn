
#include <YSI_Coding\y_hooks>


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_WORK_BENCH			(14)

static
bool:	wb_ConstructionSetWorkbench[MAX_CONSTRUCT_SET],
		wb_CurrentConstructSet[MAX_PLAYERS],
Item:	wb_CurrentWorkbench[MAX_PLAYERS],
Item:	wb_DefaultWorkbench[MAX_WORK_BENCH];


/*==============================================================================

	Default Workbench

==============================================================================*/

hook OnGameModeInit()
{
	defer CreateDefaultWk();
}

timer CreateDefaultWk[10000]()
{
	// BC
	wb_DefaultWorkbench[0] = CreateItem(item_Workbench, 585.17377, 873.72583, -43.51944, 0.0, 0.0, 94.26003);
	wb_DefaultWorkbench[1] = CreateItem(item_Workbench, -371.56595, 2235.98975, 41.43906, 0.0, 0.0, 12.84000);
	// FC
	wb_DefaultWorkbench[2] = CreateItem(item_Workbench, -2176.33765, -2536.95630, 29.59808, 0.0, 0.0, -219.05981);
	wb_DefaultWorkbench[3] = CreateItem(item_Workbench, -392.98178, -1433.41199, 24.67424, 0.0, 0.0, 0.00000);
	wb_DefaultWorkbench[4] = CreateItem(item_Workbench, -372.71423, -1040.36572, 58.21876, 0.0, 0.0, 95.58000);
	// LS
	wb_DefaultWorkbench[5] = CreateItem(item_Workbench, 2458.86377, -1974.19800, 12.45251, 0.0, 0.0, -91.14005);
	// SF
	wb_DefaultWorkbench[6] = CreateItem(item_Workbench, 94.44927, -168.05229, 1.55108, 0.0, 0.0, -180.77998);
	wb_DefaultWorkbench[7] = CreateItem(item_Workbench, -2124.13916, 219.68687, 34.16147, 0.0, 0.0, -128.63998);
	// RC
	wb_DefaultWorkbench[8] = CreateItem(item_Workbench, 2560.82031, 73.39390, 25.42815, 0.0, 0.0, 0.00000);
	// TR
	wb_DefaultWorkbench[9] = CreateItem(item_Workbench, -1513.53040, 1978.50232, 47.35660, 0.0, 0.0, 85.37996);
    // Island
	wb_DefaultWorkbench[10] = CreateItem(item_Workbench, -4411.9224, 440.2445, 13.1791, 0.0000, 0.0000, 138.0000); // SF
	wb_DefaultWorkbench[11] = CreateItem(item_Workbench, 4481.7817, -1709.5874, 6.1832, 0.0000, 0.0000, 90.0000); // LS
	wb_DefaultWorkbench[12] = CreateItem(item_Workbench, 259.5319, 4294.3921, 6.3021, 0.0000, 0.0000, -41.0000); // LV
}

/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	wb_CurrentConstructSet[playerid] = -1;
	wb_CurrentWorkbench[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(wb_CurrentWorkbench[playerid] != INVALID_ITEM_ID)
		_wb_StopWorking(playerid);
}

/*==============================================================================

	Core

==============================================================================*/


stock SetConstructionSetWorkbench(consset)
{
	wb_ConstructionSetWorkbench[consset] = true;
}

stock IsValidWorkbenchConstructionSet(consset)
{
	if(!IsValidConstructionSet(consset))
	{
		err(true, true, "Tried to assign workbench properties to invalid construction set ID.");
		return 0;
	}

	return wb_ConstructionSetWorkbench[consset];
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	{
		new Container:containerid;
		GetItemArrayDataAtCell(itemid, _:containerid, 0);
		DisplayContainerInventory(playerid, containerid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	{
		new Container:containerid;
		GetItemArrayDataAtCell(itemid, _:containerid, 0);
		DisplayContainerInventory(playerid, containerid);
	}
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(GetItemType(withitemid) == item_Workbench)
	{
		new
			craftitems[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			Container:containerid,
			itemcount,
			CraftSet:craftset,
			consset;

		GetItemArrayDataAtCell(withitemid, _:containerid, 0);
		GetContainerItemCount(containerid, itemcount);

		if(itemcount >= MAX_CONSTRUCT_SET_ITEMS - 1)
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(!IsValidContainer(containerid))
		{
			err(true, true, "Workbench (%d) has invalid container ID (%d)", _:withitemid, _:containerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		dbg("workbench", 1, "[OnPlayerUseItemWithItem] Workbench item %d container %d itemcount %d", _:withitemid, _:containerid, itemcount);

		for(new i; i < itemcount; i++)
		{
			new Item:slotitem;
			GetContainerSlotItem(containerid, i, slotitem);
			craftitems[i][craft_selectedItemType] = GetItemType(slotitem);
			craftitems[i][craft_selectedItemID] = slotitem;
			dbg("workbench", 3, "[OnPlayerUseItemWithItem] Workbench item: %d (%d) valid: %d", _:craftitems[i][craft_selectedItemType], _:craftitems[i][craft_selectedItemID], IsValidItem(craftitems[i][craft_selectedItemID]));
		}

		craftset = _craft_FindCraftset(craftitems, itemcount);
		consset = GetCraftSetConstructSet(craftset);

		if(IsValidConstructionSet(consset))
		{
			if(wb_ConstructionSetWorkbench[consset])
			{
				dbg("workbench", 2, "[OnPlayerUseItemWithItem] Valid consset %d", consset);

				if(GetConstructionSetTool(consset) == GetItemType(itemid))
				{
					new ItemType:resulttype;
					GetCraftSetResult(craftset, resulttype);
					new uniqueid[MAX_ITEM_NAME];
					GetItemTypeName(resulttype, uniqueid);

					wb_CurrentConstructSet[playerid] = consset;
					_wb_StartWorking(playerid, withitemid, GetPlayerSkillTimeModifier(playerid, itemcount * 3600, uniqueid));

					return Y_HOOKS_CONTINUE_RETURN_0;
				}
			}
		}

		if(GetItemType(itemid) != item_Crowbar)
			DisplayContainerInventory(playerid, containerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wb_ClearWorkbench(Item:itemid)
{
	new
		Container:containerid,
		itemcount;

	GetItemArrayDataAtCell(itemid, _:containerid, 0);
	GetContainerItemCount(containerid, itemcount);

	for(; itemcount >= 0; itemcount--)
	{
		new Item:slotitem;
		GetContainerSlotItem(containerid, itemcount, slotitem);
		DestroyItem(slotitem);
	}
}

_wb_StartWorking(playerid, Item:itemid, buildtime)
{
	if(wb_CurrentWorkbench[playerid] != INVALID_ITEM_ID) {
			dbg("workbench", 1, "[OnPlayerKeyStateChange] stopping workbench build");
			_wb_StopWorking(playerid);
	} else {
		new Container:containerid, Container:containerid2;

		GetItemArrayDataAtCell(itemid, _:containerid, 0);

		foreach(new i : Player)
		{
			if(wb_CurrentWorkbench[i] == itemid)
				_wb_StopWorking(i);

			GetPlayerCurrentContainer(i, containerid2);
			if(containerid2 == containerid)
			{
				ShowPlayerDialog(i, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
				CancelSelectTextDraw(playerid);
				HidePlayerGear(i);
			}
		}
		
		new Button:buttonid, Float:angle;
		GetItemButtonID(itemid, buttonid);
		GetPlayerAngleToButton(playerid, buttonid, angle);
		SetPlayerFacingAngle(playerid, angle);
		ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
		StartHoldAction(playerid, buildtime);
		wb_CurrentWorkbench[playerid] = itemid;
	}
}

_wb_StopWorking(playerid)
{
	ClearAnimations(playerid);

	StopHoldAction(playerid);
	wb_CurrentWorkbench[playerid] = INVALID_ITEM_ID;
}

_wb_CreateResult(Item:itemid, CraftSet:craftset)
{
	dbg("workbench", 1, "[_wb_CreateResult] itemid %d craftset %d", _:itemid, _:craftset);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz,
		ItemType:resulttype;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);
	GetCraftSetResult(craftset, resulttype);

	CreateItem(resulttype, x, y, z + 0.95, 0.0, 0.0, rz - 95.0 + frandom(10.0));
}

hook OnHoldActionFinish(playerid)
{
	if(wb_CurrentWorkbench[playerid] != INVALID_ITEM_ID)
	{
		dbg("workbench", 1, "[OnHoldActionFinish] workbench build complete, workbenchid: %d, construction set: %d", _:wb_CurrentWorkbench[playerid], wb_CurrentConstructSet[playerid]);

		new
			CraftSet:craftset = GetConstructionSetCraftSet(wb_CurrentConstructSet[playerid]),
			ItemType:resulttype,
			uniqueid[MAX_ITEM_NAME];

		GetCraftSetResult(craftset, resulttype);
		GetItemTypeName(resulttype, uniqueid);

		_wb_ClearWorkbench(wb_CurrentWorkbench[playerid]);
		_wb_CreateResult(wb_CurrentWorkbench[playerid], craftset);
		_wb_StopWorking(playerid);
		wb_CurrentWorkbench[playerid] = INVALID_ITEM_ID;
		wb_CurrentConstructSet[playerid] = -1;

		PlayerGainSkillExperience(playerid, uniqueid);
	}
}

hook OnPlayerConstruct(playerid, consset)
{
	if(!IsValidConstructionSet(consset))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(wb_ConstructionSetWorkbench[consset] == true)
	{
		dbg("workbench", 2, "[OnPlayerConstruct] playerid %d consset %d attempted construction of workbench consset", playerid, consset);
		ShowActionText(playerid, ls(playerid, "NEEDWORKBE", true), 5000);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDeconstruct(playerid, Item:itemid)
{
	if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	{
		for(new i; i < MAX_WORK_BENCH; i++)
		{
			if(wb_DefaultWorkbench[i] == itemid)
			{
				ShowActionText(playerid, "Essa mesa nao pode ser desmontada~n~Construa a sua: /Receitas", 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}