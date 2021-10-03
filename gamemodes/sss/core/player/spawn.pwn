
#include <YSI_Coding\y_hooks>

enum e_item_object
{
	ItemType:e_itmobj_type,
	e_itmobj_exdata
}

static
ItemType:	spawn_BagType,
// properties given to new players
Float:		spawn_NewBlood,
Float:		spawn_NewFood,
Float:		spawn_NewBleed,
ItemType:	spawn_NewItems[16][e_item_object],

// properties given on respawns
Float:		spawn_ResBlood,
Float:		spawn_ResFood,
Float:		spawn_ResBleed,
ItemType:	spawn_ResItems[16][e_item_object];

static
bool:		spawn_State[MAX_PLAYERS] = {false, ...},
Float:		spawn_PosX[MAX_PLAYERS],
Float:		spawn_PosY[MAX_PLAYERS],
Float:		spawn_PosZ[MAX_PLAYERS],
Float:		spawn_RotZ[MAX_PLAYERS];

new
PlayerText:	ClassButtonMale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonFemale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};


forward OnPlayerCreateChar(playerid);
forward OnPlayerSpawnChar(playerid);
forward OnPlayerSpawnNewChar(playerid);


hook OnGameModeInit()
{
	new
		newitems[16][32],
		newitems_total,

		resitems[16][32],
		resitems_total,

		bagtype[MAX_ITEM_NAME];

	GetSettingString("spawn/bagtype", "Satchel", bagtype);
	spawn_BagType = GetItemTypeFromUniqueName(bagtype, true);

	if(!IsValidItemType(spawn_BagType))
		printf("spawn/bagtype item name '%s' results in invalid item type %d", bagtype, _:spawn_BagType);

	GetSettingFloat("spawn/new-blood", 90.0, spawn_NewBlood);
	GetSettingFloat("spawn/new-food", 80.0, spawn_NewFood);
	GetSettingFloat("spawn/new-bleed", 0.0001, spawn_NewBleed);
	GetSettingStringArray("spawn/new-items", "Knife", 16, newitems, newitems_total, 32);

	for(new i; i < 16; i++)
	{
		spawn_NewItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(newitems[i], true);

		if(newitems[i][0] != EOS && !IsValidItemType(spawn_NewItems[i][e_itmobj_type]))
			err(false, false, "item '%s' from spawn/new-items/%d is invalid type %d.", newitems[i], i, _:spawn_NewItems[i][e_itmobj_type]);
	}

	GetSettingFloat("spawn/res-blood", 100.0, spawn_ResBlood);
	GetSettingFloat("spawn/res-food", 40.0, spawn_ResFood);
	GetSettingFloat("spawn/res-bleed", 0.0, spawn_ResBleed);
	GetSettingStringArray("spawn/res-items", "AntiSepBandage", 16, resitems, resitems_total, 32);

	for(new i; i < 16; i++)
	{
		spawn_ResItems[i][e_itmobj_type] = GetItemTypeFromUniqueName(resitems[i], true);

		if(resitems[i][0] != EOS && !IsValidItemType(spawn_ResItems[i][e_itmobj_type]))
			err(false, false, "item '%s' from spawn/res-items/%d is invalid type %d.", resitems[i], i, _:spawn_ResItems[i][e_itmobj_type]);
	}
}

hook OnPlayerConnect(playerid)
{
	spawn_State[playerid] = false;

	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale[playerid], true);

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale[playerid], true);
}

SpawnLoggedInPlayer(playerid)
{
	if(IsPlayerAlive(playerid))
	{
		new ret = PlayerSpawnExistingCharacter(playerid);

		if(!ret)
		{
			SetPlayerBrightness(playerid, 255);
			return 1;
		}
		else
			err(false, false, "PlayerSpawnExistingCharacter returned %d", ret);
	}
	
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 255);

	return 0;
}

PrepareForSpawn(playerid)
{
	SetPlayerSpawnedState(playerid, true);

	SetCameraBehindPlayer(playerid);
	SetAllWeaponSkills(playerid, 500);
	CancelSelectTextDraw(playerid);
}

PlayerSpawnExistingCharacter(playerid)
{
	if(IsPlayerSpawned(playerid))
		return 1;

	if(!LoadPlayerChar(playerid))
		return 2;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerSpawnPos(playerid, x, y, z);
	GetPlayerSpawnRot(playerid, r);

	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothes(playerid)));

	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	FreezePlayer(playerid, SEC(gLoginFreezeTime));

	PrepareForSpawn(playerid);

	if(GetPlayerStance(playerid) == 1)
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	else if(GetPlayerStance(playerid) == 2)
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	else if(GetPlayerStance(playerid) == 3)
		ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);

	Logger_Log("player spawned existing character",
		Logger_P(playerid),
		Logger_F("x", x),
		Logger_F("y", y),
		Logger_F("z", z),
		Logger_F("r", r));

	CallLocalFunction("OnPlayerSpawnChar", "d", playerid);
	return 0;
}

PlayerCreateNewCharacter(playerid)
{
	SetPlayerPos(playerid, DEFAULT_POS_X + 5, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	SetPlayerCameraLookAt(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerCameraPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z - 1.0);
	Streamer_UpdateEx(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	SetPlayerBrightness(playerid, 255);
	TogglePlayerControllable(playerid, false);

	if(IsPlayerLoggedIn(playerid))
	{
		PlayerTextDrawSetString(playerid, ClassButtonMale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_M")));
		PlayerTextDrawSetString(playerid, ClassButtonFemale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_F")));
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
		SelectTextDraw(playerid, 0xFFFFFF88);
	}

	CallLocalFunction("OnPlayerCreateChar", "d", playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonMale[playerid])
		PlayerSpawnNewCharacter(playerid, GENDER_MALE);
	else if(playertextid == ClassButtonFemale[playerid])
		PlayerSpawnNewCharacter(playerid, GENDER_FEMALE);
}


hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
	 	if(!IsPlayerSpawned(playerid) && IsPlayerLoggedIn(playerid) && !IsPlayerDead(playerid))
			SelectTextDraw(playerid, 0xFFFFFF88);
	}
}

PlayerSpawnNewCharacter(playerid, gender)
{
	if(IsPlayerSpawned(playerid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	SetPlayerTotalSpawns(playerid, GetPlayerTotalSpawns(playerid) + 1);

	SetAccountLastSpawnTimestamp(name, gettime());

	SetAccountTotalSpawns(name, GetPlayerTotalSpawns(playerid));

	new Item:backpackitem, Item:tmpitem, Float:x, Float:y, Float:z;

	SpawnPlayerAtRandomPoint(playerid, x,y,z);
	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	if(gender == GENDER_MALE)
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_Civ0M);
			case 1: SetPlayerClothesID(playerid, skin_Civ1M);
			case 2: SetPlayerClothesID(playerid, skin_Civ2M);
			case 3: SetPlayerClothesID(playerid, skin_Civ3M);
			case 4: SetPlayerClothesID(playerid, skin_Civ4M);
			case 5: SetPlayerClothesID(playerid, skin_MechM);
			case 6: SetPlayerClothesID(playerid, skin_BikeM);
		}
	}
	else
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_Civ0F);
			case 1: SetPlayerClothesID(playerid, skin_Civ1F);
			case 2: SetPlayerClothesID(playerid, skin_Civ2F);
			case 3: SetPlayerClothesID(playerid, skin_Civ3F);
			case 4: SetPlayerClothesID(playerid, skin_Civ4F);
			case 5: SetPlayerClothesID(playerid, skin_ArmyF);
			case 6: SetPlayerClothesID(playerid, skin_IndiF);
		}
	}

	if(IsNewPlayer(playerid))
	{
		SetPlayerHP(playerid, spawn_NewBlood);
		SetPlayerFP(playerid, spawn_NewFood);
		SetPlayerBleedRate(playerid, spawn_NewBleed);
		ChatMsg(playerid, CHAT_RADIO, " » Quer jogar com um amigo? Sincronize sua Radio na mesma frequencia dele.");
	}
	else
	{
		SetPlayerHP(playerid, spawn_ResBlood);
		SetPlayerFP(playerid, spawn_ResFood);
		SetPlayerBleedRate(playerid, spawn_ResBleed);
	}

	SetPlayerAP(playerid, 0.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, gender);

	SetPlayerAliveState(playerid, true);

	FreezePlayer(playerid, SEC(gLoginFreezeTime));
	PrepareForSpawn(playerid);

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	if(IsValidItemType(spawn_BagType))
	{
		backpackitem = CreateItem(spawn_BagType);

		GivePlayerBag(playerid, backpackitem);
	}

	new i = random(16), size;

	if(IsValidItemType(spawn_ResItems[i][e_itmobj_type]))
	{
		GetItemTypeSize(spawn_ResItems[i][e_itmobj_type], size);
		if(size < 4)
		{
			tmpitem = CreateItem(spawn_ResItems[i][e_itmobj_type]);

			if(spawn_ResItems[i][e_itmobj_exdata] != 0)
				SetItemExtraData(tmpitem, spawn_ResItems[i][e_itmobj_exdata]);

			AddItemToInventory(playerid, tmpitem);
		}
		else
		{
			log(true, "item too big for respawn. itemtype: %d", _:spawn_ResItems[i][e_itmobj_type]);
		}
	}

	if(IsNewPlayer(playerid))
	{
		i = random(16);

		if(IsValidItemType(spawn_NewItems[i][e_itmobj_type]))
		{
			GetItemTypeSize(spawn_NewItems[i][e_itmobj_type], size);
			if(size < 4)
			{
				tmpitem = CreateItem(spawn_NewItems[i][e_itmobj_type]);

				if(spawn_NewItems[i][e_itmobj_exdata] != 0)
					SetItemExtraData(tmpitem, spawn_NewItems[i][e_itmobj_exdata]);

				AddItemToInventory(playerid, tmpitem);
			}
			else
				log(true, "item too big for new player respawn. itemtype: %d", _:spawn_NewItems[i][e_itmobj_type]);
		}
	}

	SetPlayerBrightness(playerid, 255);

	/* new spawnMsg = 
	{
		{

		},
		{
			
		}
	} */

	ChatMsg(playerid, WHITE, z >= 500 ? "O seu aviao comecou a cair e voce nao teve outra hipotese senao saltar..." : "Acordou de um desmaio, sem qualquer lembranca...");

	CallLocalFunction("OnPlayerSpawnNewChar", "d", playerid);

	Logger_Log("player spawned new character",
		Logger_P(playerid),
		Logger_F("x", x),
		Logger_F("y", y),
		Logger_F("z", z));

	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


// spawn_State
stock IsPlayerSpawned(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return spawn_State[playerid];
}

stock SetPlayerSpawnedState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_State[playerid] = st;

	return 1;
}

stock GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = spawn_PosX[playerid];
	y = spawn_PosY[playerid];
	z = spawn_PosZ[playerid];

	return 1;
}

stock SetPlayerSpawnPos(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_PosX[playerid] = x;
	spawn_PosY[playerid] = y;
	spawn_PosZ[playerid] = z;

	return 1;
}

// spawn_RotZ
stock GetPlayerSpawnRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = spawn_RotZ[playerid];

	return 1;
}

stock SetPlayerSpawnRot(playerid, Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_RotZ[playerid] = r;

	return 1;
}