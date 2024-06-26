
#include <YSI_Coding\y_hooks>


static MachineType;

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "RefineMachine"))
		MachineType = DefineMachineType(GetItemTypeFromUniqueName("RefineMachine"), 12);
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemTypeMachineType(GetItemType(itemid)) != -1)
	{
		new Button:buttonid;
		GetItemButtonID(itemid, buttonid);
		SetButtonSize(buttonid, 2.0);
	}
}

hook OnItemAddToContainer(Container:containerid, Item:itemid, playerid)
{
	if(playerid == INVALID_PLAYER_ID)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new ItemType:itemtype = GetItemType(GetContainerMachineItem(containerid));

	if(itemtype != item_RefineMachine)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemType(itemid) != item_ScrapMetal)
	{
		ShowActionText(playerid, sprintf(
			ls(playerid, "MACHITEMTYP"),
			"Metal de Sucata"
		));
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnMachineFinish(Item:itemid, Container:containerid)
{
	if(GetItemTypeMachineType(GetItemType(itemid)) != MachineType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Item:subitemid,
		itemcount;

	GetContainerItemCount(containerid, itemcount);
	for(new i = itemcount - 1; i > -1; i--)
	{
		GetContainerSlotItem(containerid, i, subitemid);
		DestroyItem(subitemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++)
	{
		subitemid = CreateItem(item_RefinedMetal);
		AddItemToContainer(containerid, subitemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
