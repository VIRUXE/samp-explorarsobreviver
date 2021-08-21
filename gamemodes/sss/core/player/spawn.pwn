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
bool:		spawn_Spawned[MAX_PLAYERS] = {false, ...},
Float:		spawn_PosX[MAX_PLAYERS],
Float:		spawn_PosY[MAX_PLAYERS],
Float:		spawn_PosZ[MAX_PLAYERS],
Float:		spawn_RotZ[MAX_PLAYERS];

new
PlayerText:	ClassButtonMale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonFemale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

forward OnPlayerSpawnCharacter(playerid, bool:existing);

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
	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Homem~n~~n~");
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

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Mulher~n~~n~");
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

hook OnPlayerDisconnect(playerid)
{
	spawn_Spawned[playerid] = false;
}

hook OnPlayerRegister(playerid) // If player finished the tutorial it means he doesn't have a character yet, so let's create him a new one
{
	PromptCharacterGenderSelection(playerid);
}

hook OnPlayerLogin(playerid)
{
	SpawnExistingPlayerCharacter(playerid);
}

hook OnPlayerRequestRespawn(playerid)
{
	PromptCharacterGenderSelection(playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	SpawnNewPlayerCharacter(playerid, playertextid == ClassButtonMale[playerid] ? GENDER_MALE : GENDER_FEMALE);
}

public OnPlayerSpawnCharacter(playerid, bool:existing)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(existing)
		ChatMsg(playerid, CHAT_RADIO, " » Quer jogar com um amigo? Sincronize sua Radio na mesma frequencia dele.");

	SetPlayerHP(playerid, existing ? spawn_NewBlood : spawn_ResBlood);
	SetPlayerFP(playerid, existing ? spawn_NewFood : spawn_ResFood);
	SetPlayerBleedRate(playerid, existing ? spawn_NewBleed : spawn_ResBleed);

	// SetPlayerGender(playerid, GetClothesGender(GetPlayerClothes(playerid)));

	// SetPlayerClothes(playerid, GetPlayerClothesID(playerid));

	SetPlayerVirtualWorld(playerid, 0);

	FreezePlayer(playerid, SEC(gLoginFreezeTime));

	Streamer_Update(playerid); // ?????
	// Streamer_UpdateEx(playerid, x, y, z, 0, 0); // ?????

	SetPlayerSpawnedState(playerid, true);

	SetCameraBehindPlayer(playerid);
	SetAllWeaponSkills(playerid, 500);

	CancelSelectTextDraw(playerid);
	PlayerTextDrawDestroy(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawDestroy(playerid, ClassButtonFemale[playerid]);
	
	SetPlayerBrightness(playerid, 255); // Character ready so show world
}

stock PromptCharacterGenderSelection(playerid)
{
	if(!IsPlayerConnected(playerid))
		return;

	CallLocalFunction("OnPlayerSelectingCharacterGender", "d", playerid);

	SetPlayerBrightness(playerid, 0);

	PlayerTextDrawSetString(playerid, ClassButtonMale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_M")));
	PlayerTextDrawSetString(playerid, ClassButtonFemale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_F")));
	PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
	SelectTextDraw(playerid, 0xFFFFFF88);
}

stock SpawnNewPlayerCharacter(playerid, gender)
{
	if(!IsPlayerConnected(playerid))
		return;

	new
	Item:backpackItem,
	Item:tmpItem,
	Float:spawnX, Float:spawnY, Float:spawnZ, Float:spawnR,
	playerClothes;

	GenerateSpawnPoint(playerid, spawnX, spawnY, spawnZ, spawnR);
	// Streamer_UpdateEx(playerid, spawnX, spawnY, spawnZ, spawnR, 0);
	SetPlayerPos(playerid, spawnX, spawnY, spawnZ);
	SetPlayerFacingAngle(playerid, spawnR);
	
	SetPlayerInterior(playerid, 0);

	new randomClothes = (gender == GENDER_MALE ? 0 : 7) + random(7);
	switch(randomClothes)
	{
		case 0: 	playerClothes = skin_Civ0M;
		case 1: 	playerClothes = skin_Civ1M;
		case 2: 	playerClothes = skin_Civ2M;
		case 3: 	playerClothes = skin_Civ3M;
		case 4: 	playerClothes = skin_Civ4M;
		case 5: 	playerClothes = skin_MechM;
		case 6: 	playerClothes = skin_BikeM;
		case 7: 	playerClothes = skin_Civ0F;
		case 8: 	playerClothes = skin_Civ1F;
		case 9: 	playerClothes = skin_Civ2F;
		case 10: 	playerClothes = skin_Civ3F;
		case 11: 	playerClothes = skin_Civ4F;
		case 12: 	playerClothes = skin_ArmyF;
		case 13: 	playerClothes = skin_IndiF;
	}
	SetPlayerClothesID(playerid, playerClothes);

	log(true, "[SPAWN] RandomClothes %d for Player %p", randomClothes, playerid);

	SetPlayerAP(playerid, 0.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, gender);

	SetPlayerAliveState(playerid, true);

	if(IsValidItemType(spawn_BagType))
	{
		backpackItem = CreateItem(spawn_BagType);
		GivePlayerBag(playerid, backpackItem);
	}

	new i = random(16);

	if(!IsValidItemType(spawn_ResItems[i][e_itmobj_type]))
		i = 0;

	tmpItem = CreateItem(spawn_ResItems[i][e_itmobj_type]);

	if(spawn_ResItems[i][e_itmobj_exdata] != 0)
		SetItemExtraData(tmpItem, spawn_ResItems[i][e_itmobj_exdata]);

	AddItemToInventory(playerid, tmpItem);


	CallLocalFunction("OnPlayerSpawnCharacter", "db", playerid, false);
}

stock SpawnExistingPlayerCharacter(playerid)
{
	if(!IsPlayerConnected(playerid))
		return;

	new
	Float:x,
	Float:y,
	Float:z,
	Float:r;

	GetPlayerSpawnPos(playerid, x, y, z);
	GetPlayerSpawnRot(playerid, r);
	
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	CallLocalFunction("OnPlayerSpawnCharacter", "db", playerid, true);
}

stock IsPlayerSpawned(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return spawn_Spawned[playerid];
}

stock SetPlayerSpawnedState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_Spawned[playerid] = st;

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