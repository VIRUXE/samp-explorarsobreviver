
#include <YSI_Coding\y_hooks>

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == item_HeartShapedBox)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			new Container:containerid = GetBagItemContainerID(itemid);
			
			if(IsValidContainer(containerid))
			{
				switch(random(4))
				{
					case 0: AddItemToContainer(containerid, CreateItem(item_Dildo1));
					case 1: AddItemToContainer(containerid, CreateItem(item_Dildo2));
					case 2: AddItemToContainer(containerid, CreateItem(item_Dildo3));
					case 3: AddItemToContainer(containerid, CreateItem(item_Dildo4));
				}

				AddItemToContainer(containerid, CreateItem(item_Flowers));
				AddItemToContainer(containerid, CreateItem(item_AntiSepBandage));
				AddItemToContainer(containerid, CreateItem(item_ZorroMask));
			}
		}
	}
}
