
#include <YSI_Coding\y_hooks>


hook OnGameModeInit()
{
	CreateItem(item_HeartShapedBox, 2912.3301, 2910.2800, 29.7780);
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == item_HeartShapedBox)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			new Container:containerid;
			GetItemArrayDataAtCell(itemid, _:containerid, 1);

			if(IsValidContainer(containerid))
			{
				AddItemToContainer(containerid, CreateItem(item_Dildo1));
				AddItemToContainer(containerid, CreateItem(item_Flowers));
				AddItemToContainer(containerid, CreateItem(item_AntiSepBandage));
				AddItemToContainer(containerid, CreateItem(item_ZorroMask));
			}
		}
	}
}
