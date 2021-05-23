#include <YSI\y_hooks>

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Locator"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Locator"), 1);
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", LOG_CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator && GetItemType(withitemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);

		ChatMsgLang(playerid, YELLOW, "LOCATORSYNC");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) != item_Locator)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new phoneitemid = GetItemExtraData(itemid);

	if(!IsValidItem(phoneitemid) || GetItemType(phoneitemid) != item_MobilePhone)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemExtraData(phoneitemid) != 1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:phone_x,
		Float:phone_y,
		Float:phone_z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);
	GetItemAbsolutePos(phoneitemid, phone_x, phone_y, phone_z);
	distance = Distance(phone_x, phone_y, phone_z, x, y, z);

	ShowActionText(playerid, sprintf(ls(playerid, "DISTANCEVAL", true), distance), 2000);

	// ShowActionText(playerid, ls(playerid, "LOCATORDIS", true), 2000);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(itemid)
{
	dbg("global", LOG_CORE, "[OnItemCreate] in /gamemodes/sss/core/item/locator.pwn");

	if(GetItemType(itemid) == item_Locator)
		SetItemExtraData(itemid, INVALID_ITEM_ID);

	return Y_HOOKS_CONTINUE_RETURN_0;
}
