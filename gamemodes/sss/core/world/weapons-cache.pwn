
#include <YSI_Coding\y_hooks>


#define MAX_WEPCACHE_LOCATIONS			(256)
#define WEPCACHE_INTERVAL				(1500000 + random(600000)) // 25 minutes + random 10 minutes
#define WEPCACHE_SIGNAL_INTERVAL		(200000)


enum E_WEPCACHE_LOCATION_DATA
{
Float:	wepc_posX,
Float:	wepc_posY,
Float:	wepc_posZ
}

static
Float:		wepc_DropLocationData[MAX_WEPCACHE_LOCATIONS][E_WEPCACHE_LOCATION_DATA],
   Iterator:wepc_Index<MAX_WEPCACHE_LOCATIONS>,
Float:		wepc_CurrentPosX,
Float:		wepc_CurrentPosY,
Float:		wepc_CurrentPosZ,
			wepc_Object,
			webc_ActiveDrop = -1,
Container:	webc_Containerid = INVALID_CONTAINER_ID,
Button:		webc_Button = INVALID_BUTTON_ID;


hook OnGameModeInit()
{
	defer WeaponsCacheTimer();
	return 1;
}

DefineWeaponsCachePos(Float:x, Float:y, Float:z)
{
	new id = Iter_Free(wepc_Index);

	if(id == ITER_NONE)
	{
		err("Weapons cache pos definition limit reached.");
		return -1;
	}

	wepc_DropLocationData[id][wepc_posX] = x;
	wepc_DropLocationData[id][wepc_posY] = y;
	wepc_DropLocationData[id][wepc_posZ] = z;

	Iter_Add(wepc_Index, id);

	return id;
}

timer WeaponsCacheTimer[WEPCACHE_INTERVAL]()
{
	if(Iter_Count(Player) < 4)
		return;

	// There are no more locations available, kill the timer.
	if(Iter_Count(wepc_Index) == 0)
	{
		err("Weapons caches run out, stopping weapons cache timer.");
		return;
	}

	// Pick a location without any players nearby
	new
		id = Iter_Random(wepc_Index),
		checked;

	while(GetPlayersNearDropLocation(id) > 0)
	{
		if(checked == Iter_Count(wepc_Index))
		{
			checked = -1;
			break;
		}

		id = Iter_Random(wepc_Index);
		checked++;
	}

	if(checked > -1)
	{
		WeaponsCacheDrop(wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]);

		Iter_Remove(wepc_Index, id);

		webc_ActiveDrop = id;
	}

	defer WeaponsCacheTimer();

	return;
}

GetPlayersNearDropLocation(id)
{
	new count;

	foreach(new i : Player)
	{
		UpdatePlayerMap(i);
		if(IsPlayerInRangeOfPoint(i, 500.0, wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]))
			count++;
	}

	return count;
}

WeaponsCacheDrop(Float:x, Float:y, Float:z)
{
	if(webc_ActiveDrop != -1)
		return 0;

	if(IsValidDynamicObject(wepc_Object))
		DestroyDynamicObject(wepc_Object);

	wepc_Object = CreateDynamicObject(964, x, y, z - 0.0440, 0.0, 0.0, 0.0, .streamdistance = 1000.0, .drawdistance = 1000.0);

	wepc_CurrentPosX = x;
	wepc_CurrentPosY = y;
	wepc_CurrentPosZ = z;

	if(IsValidContainer(webc_Containerid))
		DestroyContainer(webc_Containerid);

	if(IsValidButton(webc_Button))
		DestroyButton(webc_Button);

	webc_Containerid = CreateContainer("Caixa de Armamento", 32);
	
	webc_Button = CreateButton(x, y - 0.5, z + 1.0, "Caixa de Armamento", .label = 1, .labeltext = "Cache de Armamento");

	FillContainerWithLoot(webc_Containerid, 22 + random(11), GetLootIndexFromName("airdrop_military_weapons"));
	
	defer WeaponsCacheSignal(1, x, y, z);

	return 1;
}

hook OnButtonPress(playerid, Button:id)
{
	if(id == webc_Button && IsValidContainer(webc_Containerid))
		DisplayContainerInventory(playerid, webc_Containerid);
}

stock GetLastWeaponCachePos(&Float:x, &Float:y, &Float:z)
{
	if(wepc_CurrentPosX == 0.0)
		return 0;

	x = wepc_CurrentPosX;
	y = wepc_CurrentPosY;
	z = wepc_CurrentPosZ;

	return 1;
}

timer WeaponsCacheSignal[WEPCACHE_SIGNAL_INTERVAL](count, Float:x, Float:y, Float:z)
{
	// Gets a random weapons-cache drop location and uses it as a reference point.
	// Announces the angle and distance from that location to the weapons cache.
	new
		locationlist[MAX_WEPCACHE_LOCATIONS],
		idx,
		Float:ref_x,
		Float:ref_y,
		Float:ref_z;

	for(new i, j = random(Iter_Free(wepc_Index)) - 1; i < j; i++)
	{
		ref_x = wepc_DropLocationData[i][wepc_posX];
		ref_y = wepc_DropLocationData[i][wepc_posY];
		ref_z = wepc_DropLocationData[i][wepc_posZ];

		if(Distance(ref_x, ref_y, ref_z, wepc_CurrentPosX, wepc_CurrentPosY, wepc_CurrentPosZ) < 100.0)
			locationlist[idx++] = i;
	}

	if(idx > 0)
		ChatMsgAll(YELLOW, " » "C_GREEN"[Exército]: "C_YELLOW"Caixa de Armas caindo no mapa... (Icone '"C_WHITE"Arma"C_YELLOW"')");
	else
	{
		log(true, "No reference point found for Weapons Cache.");
		return;
	}

	if(count < 3)
		defer WeaponsCacheSignal(count + 1, x, y, z);
	else
		webc_ActiveDrop = -1;

	return;
}