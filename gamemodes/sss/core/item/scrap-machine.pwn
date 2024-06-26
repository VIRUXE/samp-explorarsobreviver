
#include <YSI_Coding\y_hooks>


static
	MachineType,
	ItemTypeScrapValue[MAX_ITEM_TYPE] = {-1, ...};

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "ScrapMachine"))
		MachineType = DefineMachineType(GetItemTypeFromUniqueName("ScrapMachine"), 12);
}

stock SetItemTypeScrapValue(ItemType:itemtype, value)
{
	if(!IsValidItemType(itemtype))
	{
		err(true, true, "Tried to assign scrap value to invalid item type.");
		return;
	}

	ItemTypeScrapValue[itemtype] = value;

	return;
}

hook OnMachineFinish(Item:itemid, Container:containerid)
{
	if(GetItemTypeMachineType(GetItemType(itemid)) != MachineType)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		itemcount,
		Item:subitemid,
		scrapcount;

	GetContainerItemCount(containerid, itemcount);
	for(new i = itemcount - 1; i > -1; i--)
	{
		GetContainerSlotItem(containerid, i, subitemid);
		scrapcount += ItemTypeScrapValue[GetItemType(subitemid)];
		DestroyItem(subitemid);
	}

	scrapcount = scrapcount > MAX_MACHINE_ITEMS - 1 ? MAX_MACHINE_ITEMS - 1 : scrapcount;

	for(new i; i < scrapcount; i++)
	{
		subitemid = CreateItem(item_ScrapMetal);
		AddItemToContainer(containerid, subitemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
