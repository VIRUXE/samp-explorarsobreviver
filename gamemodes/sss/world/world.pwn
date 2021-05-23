#include "sss/world/spawn.pwn"

#include "sss/world/zones/ls.pwn"
#include "sss/world/zones/sf.pwn"
#include "sss/world/zones/lv.pwn"
#include "sss/world/zones/rc.pwn"
#include "sss/world/zones/fc.pwn"
#include "sss/world/zones/bc.pwn"
#include "sss/world/zones/tr.pwn"
//#include "sss/world/misc/ls_apartments1.pwn"
#include "sss/world/misc/ls_apartments2.pwn"
//#include "sss/world/misc/ls_beachside.pwn"
//#include "sss/world/misc/sf_zombotech.pwn"
#include "sss/world/puzzles/area69.pwn"
#include "sss/world/puzzles/ranch.pwn"
#include "sss/world/puzzles/mtchill.pwn"
#include "sss/world/puzzles/codehunt.pwn"
//#include "sss/world/houseloot.pwn"

#include "sss/world/xmas.pwn"

static
	MapName[32] = "San Androcalypse",
	ItemCounts[ITM_MAX_TYPES];

#include <YSI\y_hooks>


hook OnGameModeInit()
{
	console("[WORLD] Loading world entities...");
	DiscordMessage(DISCORD_CHANNEL_GLOBAL, "**Loading world...**");
	defer LoadWorld();
}

timer LoadWorld[100]()
{
	gServerInitialising = true;

	// store this to a list and compare after
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i))
			break;

		if(GetItemTypeCount(i) == 0)
			continue;

		ItemCounts[i] = GetItemTypeCount(i);
	}

	defer _Load_LS();
}

timer _Load_LS[100]()
{
	SetLoadingString("10%");
	console("[WORLD] Loading Los Santos.");
	Load_LS();
	defer _Load_SF();
}

timer _Load_SF[100]()
{
	SetLoadingString("20%");
	console("[WORLD] Loading San Fierro.");
	Load_SF();
	defer _Load_LV();
}

timer _Load_LV[100]()
{
	SetLoadingString("35%");
	console("[WORLD] Loading Las Venturas.");
	Load_LV();
	defer _Load_RC();
}

timer _Load_RC[100]()
{
	SetLoadingString("40%");
	console("[WORLD] Loading Red County.");
	Load_RC();
	defer _Load_FC();
}

timer _Load_FC[100]()
{
	SetLoadingString("55%");
	console("[WORLD] Loading Fort Carson.");
	Load_FC();
	defer _Load_BC();
}

timer _Load_BC[100]()
{
	SetLoadingString("75%");
	console("[WORLD] Loading Bone County.");
	Load_BC();
	defer _Load_TR();
}

timer _Load_TR[100]()
{
	SetLoadingString("90%");
	console("[WORLD] Loading Tierra Robada.");
	Load_TR();
	defer _Finalise();
}

timer _Finalise[100]()
{
	new bool:printItems;

	GetSettingInt("server/print-items", 1, printItems, false);

	//Load_HouseLoot();

	if(printItems)
	{
		new itemtypename[ITM_MAX_NAME];

		// compare with previous list and print differences
		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			if(!IsValidItemType(i))
				break;

			if(GetItemTypeCount(i) == 0)
				continue;

			GetItemTypeUniqueName(i, itemtypename);

			console("[WORLD] Loaded: %04d, Spawned: %04d, Total: %04d of '%s' (%03d)", ItemCounts[i], GetItemTypeCount(i) - ItemCounts[i], GetItemTypeCount(i), itemtypename, _:i);
		}
	}
	gServerInitialising = false;

	//SendRconCommand("password 0");

	DiscordMessage(DISCORD_CHANNEL_GLOBAL, "**Finished loading world.** (Running version: %d)", gGamemodeVersion);
}

stock GetMapName()
	return MapName;