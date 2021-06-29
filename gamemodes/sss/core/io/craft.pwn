
#include <YSI_Coding\y_hooks>


#define DIRECTORY_CRAFTS	DIRECTORY_MAIN"crafts/"

forward OnCraftLoad(Item:itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerDeconstructed(playerid, Item:itemid)
{
    RemoveSavedItem(itemid, DIRECTORY_CRAFTS);
}

hook OnPlayerConstructed(playerid, consset, Item:result)
{
	if(!IsPlayerInTutorial(playerid))
    	SaveCraftItem(result);
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(!IsPlayerInTutorial(playerid))
    	SaveCraftItem(itemid);
}

hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_CRAFTS);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_CRAFTS, "OnCraftLoad");
}

/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveCraftItem(Item:itemid)
{
	new ItemType:type = GetItemType(itemid);

	if(GetDefenceType(itemid) != -1)
		return 0;

	if(type == item_TentPack)
		return 0;

	if(type == item_Locker)
		return 0;

    SaveWorldItem(itemid, DIRECTORY_CRAFTS, true, true);
	return 1;
}

public OnCraftLoad(Item:itemid, active, geid[], data[], length)
{

	return 1;
}

