
#include <YSI_Coding\y_hooks>

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
