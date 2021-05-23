#include <YSI\y_hooks>


#define DIRECTORY_DEFENCE	DIRECTORY_MAIN"defences/"


forward OnDefenceLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCE);
}

hook OnGameModeInit()
{
	LoadItems(DIRECTORY_DEFENCE, "OnDefenceLoad");
}

hook OnDefenceCreate(itemid)
{
	SaveDefenceItem(itemid);
}

hook OnItemDestroy(itemid)
{
	if(IsItemTypeDefence(GetItemType(itemid)))
		RemoveDefenceItem(itemid);
}

hook OnItemHitPointsUpdate(itemid, oldvalue, newvalue)
{
	if(IsItemTypeDefence(GetItemType(itemid)))
		SaveDefenceItem(itemid);
}

hook OnDefenceDestroy(itemid)
{
	RemoveDefenceItem(itemid);
}

hook OnDefenceModified(itemid)
{
	SaveDefenceItem(itemid);
}

hook OnDefenceMove(itemid)
{
	SaveDefenceItem(itemid);
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveDefenceItem(itemid, bool:active = true)
{
	if(!IsValidItem(itemid))
		return 1;

	SaveWorldItem(itemid, DIRECTORY_DEFENCE, active, true);

	return 0;
}

public OnDefenceLoad(itemid, active, geid[], data[], length)
{
	ActivateDefenceItem(itemid);

	return 1;
}

stock RemoveDefenceItem(itemid)
{
	RemoveSavedItem(itemid, DIRECTORY_DEFENCE);
}
