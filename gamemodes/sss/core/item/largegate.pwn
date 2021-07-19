#include <YSI_Coding\y_hooks>

hook OnDefenceDestroy(Item:itemid)
{
	if(GetItemType(itemid) == item_LargeGate)
	{
		new Float:x, Float:y, Float:z;

		GetItemPos(itemid, x, y, z);

		CreateItem(item_MetalGate, x, y, z);
		CreateItem(item_MetalGate, x, y, z + 0.2);

		DestroyItem(itemid);
	}
}