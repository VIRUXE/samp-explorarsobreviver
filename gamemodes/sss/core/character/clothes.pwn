
#include <YSI_Coding\y_hooks>


#define MAX_CLOTHES			(55)
#define MAX_CLOTHES_NAME	(32)


enum E_SKIN_DATA
{
			skin_model,
			skin_name[MAX_CLOTHES_NAME],
			skin_gender,
Float:		skin_lootSpawnChance,
			skin_canWearHats,
			skin_canWearMasks
}


static
			skin_Total,
			skin_Data[MAX_CLOTHES][E_SKIN_DATA],
			skin_CurrentSkin[MAX_PLAYERS],
Item:		skin_CurrentlyUsing[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Clothes"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Clothes"), 1);
}

hook OnPlayerConnect(playerid)
{
	skin_CurrentlyUsing[playerid] = INVALID_ITEM_ID;
}


DefineClothesType(modelid, const name[MAX_CLOTHES_NAME], gender, Float:spawnchance, bool:wearhats, bool:wearmasks)
{
	skin_Data[skin_Total][skin_model] = modelid;
	skin_Data[skin_Total][skin_name] = name;
	skin_Data[skin_Total][skin_gender] = gender;
	skin_Data[skin_Total][skin_lootSpawnChance] = spawnchance;
	skin_Data[skin_Total][skin_canWearHats] = wearhats;
	skin_Data[skin_Total][skin_canWearMasks] = wearmasks;
	
	return skin_Total++;
}

hook OnItemCreate(Item:itemid)
{
	if(GetItemType(itemid) == item_Clothes)
	{
		new
			list[MAX_CLOTHES],
			idx,
			skinid;

		for(new i; i < skin_Total; i++)
		{
			if(frandom(1.0) < skin_Data[i][skin_lootSpawnChance])
				list[idx++] = i;
		}

		skinid = list[random(idx)];

		SetItemExtraData(itemid, skinid);
	}

	return 1;
}


hook OnItemNameRender(Item:itemid, ItemType:itemtype)
{
	if(itemtype == item_Clothes)
	{
		new
			data,
			exname[32];

		GetItemExtraData(itemid, data);

		strcat(exname, skin_Data[data][skin_gender] == GENDER_MALE ? "Homem " : "Mulher ");
		strcat(exname, skin_Data[data][skin_name]);

		SetItemNameExtra(itemid, exname);
	}

	//return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) // Quando tenta vestir roupa
{
	if(newkeys & 16)
	{
		if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
			StopUsingClothes(playerid);
		else 
		{
			new Item:itemid = GetPlayerItem(playerid);

			if(GetItemType(itemid) == item_Clothes)
			{
				new skinid;
				GetItemExtraData(itemid, skinid);

				if(skin_Data[skinid][skin_gender] == GetPlayerGender(playerid))
					StartUsingClothes(playerid, itemid);
				else
					ShowActionText(playerid, ls(playerid, "CLOTHESWRGE"), 3000, 130);
			}
		}
	}

	return 1;
}

StartUsingClothes(playerid, Item:itemid)
{
	StartHoldAction(playerid, 3000);
	CancelPlayerMovement(playerid);
	skin_CurrentlyUsing[playerid] = itemid;
	ApplyAnimation(playerid, "CLOTHES", "CLO_Pose_Loop", 4.0, 0, 0, 0, 0, 0, 1);
}

StopUsingClothes(playerid)
{
	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
		StopHoldAction(playerid);
		ClearAnimations(playerid, 1);
		skin_CurrentlyUsing[playerid] = INVALID_ITEM_ID;
	}
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
	 	if(GetPlayerTotalVelocity(playerid) > 1.0)
		 	StopUsingClothes(playerid);

		return Y_HOOKS_BREAK_RETURN_0;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}
hook OnHoldActionFinish(playerid)
{
	if(skin_CurrentlyUsing[playerid] != INVALID_ITEM_ID)
	{
		new currentclothes = skin_CurrentSkin[playerid], skinid;
		GetItemExtraData(skin_CurrentlyUsing[playerid], skinid);
		SetPlayerClothes(playerid, skinid);
		SetItemExtraData(skin_CurrentlyUsing[playerid], currentclothes);
		StopUsingClothes(playerid);

		SetPlayerHatItem(playerid, RemovePlayerHatItem(playerid));
		SetPlayerMaskItem(playerid, RemovePlayerMaskItem(playerid));
		//GivePlayerBag(playerid, GetPlayerBagItem(playerid));

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


stock IsValidClothes(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	return 1;
}

stock GetPlayerClothes(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	return skin_CurrentSkin[playerid];
}
stock SetPlayerClothes(playerid, skinid)
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	SetPlayerSkin(playerid, skin_Data[skinid][skin_model]);
	skin_CurrentSkin[playerid] = skinid;

	return 1;
}
stock GetClothesModel(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return -1;

	return skin_Data[skinid][skin_model];
}
stock GetClothesName(skinid, name[])
{
	if(!(0 <= skinid < skin_Total))
		return 0;

	name[0] = EOS;
	strcat(name, skin_Data[skinid][skin_name], MAX_CLOTHES_NAME);

	return 1;
}

stock GetClothesGender(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return -1;

	return skin_Data[skinid][skin_gender];
}

stock GetClothesHatStatus(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return false;

	return skin_Data[skinid][skin_canWearHats];
}

stock GetClothesMaskStatus(skinid)
{
	if(!(0 <= skinid < skin_Total))
		return false;

	return skin_Data[skinid][skin_canWearMasks];
}