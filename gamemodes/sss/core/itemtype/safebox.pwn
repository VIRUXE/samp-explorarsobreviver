

#include <YSI_Coding\y_hooks>


#define MAX_SAFEBOX_TYPE	(13)
#define MAX_SAFEBOX_NAME	(32)


enum E_SAFEBOX_TYPE_DATA
{
ItemType:	box_itemtype,
			box_size,
			box_display,
			box_animate
}

static
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
			box_ItemTypeBoxType[MAX_ITEM_TYPE] = {-1, ...},
Item:		box_ContainerSafebox[MAX_CONTAINER] = {INVALID_ITEM_ID, ...};

static
Item: 		box_CurrentBoxItem[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineSafeboxType(ItemType:itemtype, size, displayonuse = true, animateonuse = true)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 1);

	box_TypeData[box_TypeTotal][box_itemtype]	= itemtype;
	box_TypeData[box_TypeTotal][box_size]		= size;
	box_TypeData[box_TypeTotal][box_display]	= displayonuse;
	box_TypeData[box_TypeTotal][box_animate]	= animateonuse;

	box_ItemTypeBoxType[itemtype] = box_TypeTotal;

	return box_TypeTotal++;
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnItemCreate(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new
				name[MAX_ITEM_NAME],
				Container:containerid;

			GetItemTypeName(itemtype, name);

			containerid = CreateContainer(name, box_TypeData[box_ItemTypeBoxType[itemtype]][box_size]);

			box_ContainerSafebox[containerid] = itemid;

			SetItemArrayDataSize(itemid, 1);
			SetItemArrayDataAtCell(itemid, _:containerid, 0);
		}
	}
}

hook OnItemCreateInWorld(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);

		if(itemtype == ItemType:item_Torso)
		{
			SetButtonText(buttonid, "Pressione "KEYTEXT_INTERACT" para revistar o corpo");
		}
		else if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			SetButtonText(buttonid, "Segure "KEYTEXT_INTERACT" para pegar~n~Pressione "KEYTEXT_INTERACT" para abrir");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new Container:containerid;
			GetItemArrayDataAtCell(itemid, _:containerid, 0);

			DestroyContainer(containerid);
			box_ContainerSafebox[containerid] = INVALID_ITEM_ID;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Player interaction

==============================================================================*/


hook OnPlayerUseItem(playerid, Item:itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		new Container:containerid;
		GetPlayerCurrentContainer(playerid, containerid);
		if(IsValidContainer(containerid))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
		{
			if(IsPlayerMobile(playerid) && box_TypeData[box_ItemTypeBoxType[itemtype]][box_animate])
				PlayerPickUpItem(playerid, itemid);

			if(_DisplaySafeboxDialog(playerid, itemid, box_TypeData[box_ItemTypeBoxType[itemtype]][box_animate]))
				return Y_HOOKS_BREAK_RETURN_1;
		}

		else
		{
			if(_DisplaySafeboxDialog(playerid, itemid, false))
				return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	new ItemType:itemtype = GetItemType(withitemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(_DisplaySafeboxDialog(playerid, withitemid, box_TypeData[box_ItemTypeBoxType[itemtype]][box_animate]))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_DisplaySafeboxDialog(playerid, Item:itemid, animation)
{
	if(!box_TypeData[box_ItemTypeBoxType[GetItemType(itemid)]][box_display])
		return 0;

	new Container:containerid;
	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	//if(box_ContainerSafebox[containerid] != itemid)
		//return 0;
		
	DisplayContainerInventory(playerid, containerid);
	box_CurrentBoxItem[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else
		CancelPlayerMovement(playerid);

	return 1;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	if(IsValidItem(box_CurrentBoxItem[playerid]))
	{
		CancelPlayerMovement(playerid);
		box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == ItemType:item_Torso)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}
	
	return Y_HOOKS_CONTINUE_RETURN_1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeSafebox(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(ItemType:itemtype == ItemType:item_Torso)
		return 0;
		
	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	return 0;
}

stock Item:GetContainerSafeboxItem(Container:containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return box_ContainerSafebox[containerid];
}

stock IsItemTypeExtraDataDependent(ItemType:itemtype)
{
	if(IsItemTypeBag(itemtype))
		return 1;

	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	if(itemtype == item_Workbench)
		return 1;

	if(itemtype == item_Bed)
		return 1;

	if(itemtype == item_Torso)
		return 1;

	if(itemtype == item_Campfire)
		return 1;

	if(itemtype == item_Barbecue)
		return 1;

	if(itemtype == item_TentPack)
		return 1;

	if(GetItemTypeMachineType(itemtype) != -1)
		return 1;

	return 0;
}
