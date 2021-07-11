
#include <YSI_Coding\y_hooks>


#define PILL_TYPE_ANTIBIOTICS	(0)
#define PILL_TYPE_PAINKILL		(1)
#define PILL_TYPE_LSD			(2)


static
	Item:pill_CurrentlyTaking[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Pills"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Pills"), 1);
}

hook OnPlayerConnect(playerid)
{
	pill_CurrentlyTaking[playerid] = INVALID_ITEM_ID;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Pills)
		{
			SetItemExtraData(itemid, random(3));
		}
	}
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Pills)
	{
		new type;
		GetItemExtraData(itemid, type);
		switch(type)
		{
			case PILL_TYPE_ANTIBIOTICS:		SetItemNameExtra(itemid, "Antibiotico");
			case PILL_TYPE_PAINKILL:		SetItemNameExtra(itemid, "Analgesico");
			case PILL_TYPE_LSD:				SetItemNameExtra(itemid, "LSD");
			default:						SetItemNameExtra(itemid, "Vazio");
		}
	}
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Pills)
	{
		StartTakingPills(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartTakingPills(playerid)
{
	if(pill_CurrentlyTaking[playerid] != INVALID_ITEM_ID)
		StopTakingPills(playerid);
	else {
		pill_CurrentlyTaking[playerid] = GetPlayerItem(playerid);
		ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 1000, 1);
		StartHoldAction(playerid, 1000);
	}
}

StopTakingPills(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);
	pill_CurrentlyTaking[playerid] = INVALID_ITEM_ID;
}

hook OnHoldActionFinish(playerid)
{
	if(pill_CurrentlyTaking[playerid] != INVALID_ITEM_ID)
	{
		if(!IsValidItem(pill_CurrentlyTaking[playerid]))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(GetPlayerItem(playerid) != pill_CurrentlyTaking[playerid])
			return Y_HOOKS_CONTINUE_RETURN_0;

		new type;
		GetItemExtraData(pill_CurrentlyTaking[playerid], type);
		switch(type)
		{
			case PILL_TYPE_ANTIBIOTICS:
			{
				SetPlayerInfectionIntensity(playerid, 0, 0);

				if(random(100) < 50)
					SetPlayerInfectionIntensity(playerid, 1, 0);

				ApplyDrug(playerid, drug_Antibiotic);
			}
			case PILL_TYPE_PAINKILL:
			{
				GivePlayerHP(playerid, 10.0);
				ApplyDrug(playerid, drug_Painkill);
			}
			case PILL_TYPE_LSD:
			{
				ApplyDrug(playerid, drug_Lsd);

				new
					hour = 22,
					minute = 3,
					weather = 33;

				SetTimeForPlayer(playerid, hour, minute);
				SetWeatherForPlayer(playerid, weather);
			}
		}

		DestroyItem(pill_CurrentlyTaking[playerid]);
		pill_CurrentlyTaking[playerid] = INVALID_ITEM_ID;

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrugWearOff(playerid, drugtype)
{
	if(drugtype == drug_Lsd)
	{
		SetTimeForPlayer(playerid, -1, -1, true);
		SetWeatherForPlayer(playerid, GetGlobalWeather());
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
