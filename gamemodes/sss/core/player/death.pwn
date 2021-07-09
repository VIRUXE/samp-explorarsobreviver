#include <YSI_Coding\y_hooks>


static
Text:	DeathText = Text:INVALID_TEXT_DRAW,
Text:	DeathButton = Text:INVALID_TEXT_DRAW,
bool:	death_Dying[MAX_PLAYERS],
		death_LastDeath[MAX_PLAYERS],
Float:	death_PosX[MAX_PLAYERS],
Float:	death_PosY[MAX_PLAYERS],
Float:	death_PosZ[MAX_PLAYERS],
Float:	death_RotZ[MAX_PLAYERS],
		death_LastKilledBy[MAX_PLAYERS][MAX_PLAYER_NAME],
		death_LastKilledById[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	death_LastKilledBy[playerid][0] = EOS;
	death_LastKilledById[playerid] = INVALID_PLAYER_ID;
	TextDrawHideForPlayer(playerid, DeathText);
	TextDrawHideForPlayer(playerid, DeathButton);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	death_Dying[playerid] = false;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(GetTickCountDifference(GetTickCount(), death_LastDeath[playerid]) < 1000)
		return 0;

	death_LastDeath[playerid] = GetTickCount();

	if(killerid == INVALID_PLAYER_ID)
	{
		killerid = GetLastHitById(playerid);

		if(!IsPlayerConnected(killerid))
			killerid = INVALID_PLAYER_ID;
	}

	_OnDeath(playerid, killerid);

	return 1;
}

_OnDeath(playerid, killerid)
{
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid))
		return 0;

	new
		Item:deathreason = GetLastHitByWeapon(playerid),
		deathreasonstring[256];

	death_Dying[playerid] = true;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);

	GetPlayerPos(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	GetPlayerFacingAngle(playerid, death_RotZ[playerid]);

	if(IsPlayerInAnyVehicle(playerid))
	{
		RemovePlayerFromVehicle(playerid);
		//TogglePlayerSpectating(playerid, true);
		//TogglePlayerSpectating(playerid, false);
		death_PosZ[playerid] += 0.5;
	}
	
	DropItems(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	RemovePlayerWeapon(playerid);
	RemoveAllDrugs(playerid);
	SpawnPlayer(playerid);

	KillPlayer(playerid, killerid, _:deathreason);

	if(IsPlayerConnected(killerid))
	{
		log("[KILL] %p killed %p with %d at %f, %f, %f (%f)", killerid, playerid, _:deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		GetPlayerName(killerid, death_LastKilledBy[playerid], MAX_PLAYER_NAME);
		death_LastKilledById[playerid] = killerid;

		switch(deathreason)
		{
			case 0..3, 5..7, 10..15:
				deathreasonstring = "They were beaten to death.";
			case 4:
				deathreasonstring = "They suffered small lacerations on the torso, possibly from a knife.";
			case 8:
				deathreasonstring = "Large lacerations cover the torso and head, looks like a finely sharpened sword.";
			case 9:
				deathreasonstring = "There's bits everywhere, probably suffered a chainsaw to the torso.";
			case 16, 39, 35, 36, 255:
				deathreasonstring = "They suffered massive concussion due to an explosion.";
			case 18, 37:
				deathreasonstring = "The entire body is charred and burnt.";
			case 22..34, 38:
				deathreasonstring = "They died of blood loss caused by what looks like bullets.";
			case 41, 42:
				deathreasonstring = "They were sprayed and suffocated by a high pressure substance.";
			case 44, 45:
				deathreasonstring = "Somehow, they were killed by goggles.";
			case 43:
				deathreasonstring = "Somehow, they were killed by a camera.";
			default:
				deathreasonstring = "They bled to death.";
		}
	}
	else
	{
		log("[DEATH] %p died because of %d at %f, %f, %f (%f)", playerid, _:deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		death_LastKilledBy[playerid][0] = EOS;
		death_LastKilledById[playerid] = INVALID_PLAYER_ID;

		switch(deathreason)
		{
			case 53:
				deathreasonstring = "They drowned.";
			case 54:
				deathreasonstring = "Most bones are broken, looks like they fell from a great height.";
			case 255:
				deathreasonstring = "They suffered massive concussion due to an explosion.";
			default:
				deathreasonstring = "They died for an unknown reason.";
		}
	}

	//TODO: Translate the reason and activate
	//defer DestroyReason(:_CreateDynamic3DTextLabel(sprintf("Alguem morreu aqui, motivo:\n%s", deathreasonstring),
		//-1, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - 0.1, 2.0));

	return 1;
}

//timer DestroyReason[10 * 60000](label)
	//DestroyDynamic3DTextLabel(STREAMER_TAG_3D_TEXT_LABEL:label);

timer DestroyTorso[10 * 60000](itemid)
	if(IsValidItem(Item:itemid))
		DestroyItem(Item:itemid);

DropItems(playerid, Float:x, Float:y, Float:z)
{
	new
		Item:itemid;

	new Float:cx, Float:cy, Float:cz;

	if(CA_RayCastLine(x, y, z, x, y, z - 600.0, cx, cy, cz) != WATER_OBJECT)
		itemid = CreateItem(ItemType:item_Torso,  cx, cy, cz + 0.2,
		.world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	else
		return;

	defer DestroyTorso(_:itemid);

	// Head
	//CreateDynamicObject(2908, cx, cy, cz + 0.2, 0.0, 0.0, 0.0);
	
	//arm
	//CreateDynamicObject(2906, cx, cy, cz + 0.2, 0.0, 0.0, 60.0);
	//CreateDynamicObject(2906, cx, cy, cz + 0.2, 0.0, 0.0, 60.0);

	// Leg
	/*cx += 0.6 * floatsin(-r, degrees);
    cy += 0.6 * floatcos(-r, degrees);
	CreateDynamicObject(2905, cx, cy, cz + 0.2, 0.0, 0.0, 270.0);

	cx += 0.45 * floatsin(-r, degrees);
    cy += 0.45 * floatcos(-r, degrees);
	CreateDynamicObject(2905, cx, cy, cz + 0.2, 0.0, 0.0, -90.0);*/

	new Container:containerid;

	GetItemArrayDataAtCell(itemid, _:containerid, 0);

	new name[MAX_PLAYER_NAME + 8];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(name, sizeof(name), "Corpo de %s", name);
	SetContainerName(containerid, name);
	SetItemLabel(itemid, name);
	
	/*
		Clothes item
	*/

	itemid = CreateItem(item_Clothes);

	SetItemExtraData(itemid, GetPlayerClothes(playerid));

	AddItemToContainer(containerid, itemid);
	
	/*
		Held item
	*/
	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
		AddItemToContainer(containerid, itemid);

	/*
		Holstered item
	*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid))
	{
		RemovePlayerHolsterItem(playerid);

		AddItemToContainer(containerid, itemid);
	}

	/*
		Inventory
	*/

	for(new i; i < MAX_INVENTORY_SLOTS; i++)
	{
		GetInventorySlotItem(playerid, 0, itemid);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		AddItemToContainer(containerid, itemid);
	}

	/*
		Bag item
	*/

	itemid = GetPlayerBagItem(playerid);

	if(IsValidItem(itemid))
	{
		RemovePlayerBag(playerid);

		AddItemToContainer(containerid, itemid);
	}

	/*
		Head-wear item
	*/

	itemid = RemovePlayerHatItem(playerid);

	if(IsValidItem(itemid))
		AddItemToContainer(containerid, itemid);

	/*
		Face-wear item
	*/

	itemid = RemovePlayerMaskItem(playerid);

	if(IsValidItem(itemid))
		AddItemToContainer(containerid, itemid);

	/*
		Armour item
	*/

	if(GetPlayerAP(playerid) > 0.0)
	{
		itemid = RemovePlayerArmourItem(playerid);
		AddItemToContainer(containerid, itemid);

		SetPlayerAP(playerid, 0.0);
	}

	/*
		Handcuffs
	*/

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
		itemid = CreateItem(item_HandCuffs);
		AddItemToContainer(containerid, itemid);
		SetPlayerCuffs(playerid, false);
	}
	
	return;
}

hook OnPlayerSpawn(playerid)
{
	if(IsPlayerDead(playerid))
	{
		TogglePlayerControllable(playerid, false);
		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
			death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
			death_PosZ[playerid]);

		SetPlayerCameraLookAt(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);

		SelectTextDraw(playerid, 0xFFFFFF88);
		SetPlayerHP(playerid, 1.0);
		SetPlayerBrightness(playerid, 200);
		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
	}
}

timer SetDeathCamera[500](playerid)
{
	if(!IsPlayerDead(playerid))
		return;

	TogglePlayerSpectating(playerid, true);

	SelectTextDraw(playerid, 0xFFFFFF88);
	
	InterpolateCameraPos(playerid,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 1.0,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid],
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid] + 1.0,
		30000, CAMERA_MOVE);

	return;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == DeathButton)
	{
		if(!IsPlayerDead(playerid))
			return 1;

		death_Dying[playerid] = false;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
		SetPlayerBrightness(playerid, 255);
		defer SpawnDeathDelay(playerid);
	}

	return 1;
}

timer SpawnDeathDelay[1200](playerid)
	SpawnLoggedInPlayer(playerid);

hook OnGameModeInit()
{
	DeathText					=TextDrawCreate(320.000000, 300.000000, "VOCE MORREU!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Jogar Novamente<");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);
}


stock IsPlayerDead(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_Dying[playerid];
}

stock GetPlayerDeathPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = death_PosX[playerid];
	y = death_PosY[playerid];
	z = death_PosZ[playerid];

	return 1;
}

stock GetPlayerDeathRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = death_RotZ;

	return 1;
}

// death_LastKilledBy
stock GetLastKilledBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name = death_LastKilledBy[playerid];

	return 1;
}

// death_LastKilledById
stock GetLastKilledById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_LastKilledById[playerid];
}