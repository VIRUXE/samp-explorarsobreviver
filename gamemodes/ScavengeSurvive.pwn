/*==============================================================================


	Southclaws' Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <a_samp>

#include "config.pwn"

/*==============================================================================

	Guaranteed first call

	OnGameModeInit_Setup is called before ANYTHING else, the purpose of this is
	to prepare various internal and external systems that may need to be ready
	for other modules to use their functionality. This function isn't hooked.

	OnScriptInit (from YSI) is then called through modules which is used to
	prepare dependencies such as databases, folders and register debuggers.

	OnGameModeInit is then finally called throughout modules and starts inside
	the "Server/Init.pwn" module (very important) so itemtypes and other object
	types can be defined. This callback is used throughout other scripts as a
	means for declaring entities with relevant data.

==============================================================================*/

public OnGameModeInit()
{
	// Note: DO NOT CHANGE THIS STRING!
	print("[OnGameModeInit] FIRST_INIT");
	
	DisableInteriorEnterExits();
	ShowNameTags(1);
	EnableStuntBonusForAll(false);
	OnGameModeInit_Setup();

	#if defined main_OnGameModeInit
		return main_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
	forward main_OnGameModeInit();
#endif

/*==============================================================================

	Libraries

==============================================================================*/
#include <crashdetect>
#include <sscanf2>
#include <mathutil>
#include <YSI_Core\y_utils>
#include <YSI_Coding\y_va>
#include <YSI_Coding\y_timers>
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_iterate>
#include <YSI_Storage\y_ini>
#include <YSI_Visual\y_dialog>
#include <PreviewModelDialog>
#include <Pawn.RakNet>
#include <colandreas> 
#include <streamer>
#include <optidraw>
#include <nex-ac>
#include <whirlpool>
#include <sqlitei>
#include <formatex>
#include <strlib>
#include <md-sort>
#include <chrono>
#include <progress2>
#include <fsutil>
#include <mobile>
#include <ini>
#include <modio>
#include <personal-space>
#include <new-action-text>
#include <button>
#include <door>
#include <item>
#include <inventory>
#include <container>
#include <item-array-data>
#include <item-serializer>
#include <inventory-dialog>
#include <container-dialog>
#include <craft>
#include <debug-labels>
#include <weapon-data>
#include <linegen>
#include <zipline>
#include <ladders>
#include <attachment-fix>
#include <BustAim>
#include <no-reload>
#include <rapid-fire>
#include <optud>
#include <discord-connector>
//#include <mapfix>
/*==============================================================================

	Definitions

==============================================================================*/


// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_WEBSITE_NAME			(64)
#define MAX_RULE					(24)
#define MAX_RULE_LEN				(128)
#define MAX_STAFF					(24)
#define MAX_STAFF_LEN				(24)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(48)
#define MAX_PASSWORD_LEN			(129)
#define MAX_GPCI_LEN				(41)
#define MAX_HOST_LEN				(256)


// Directories
#define DIRECTORY_SCRIPTFILES		"./scriptfiles/"
#define DIRECTORY_MAIN				"data/"


// Files
#define ACCOUNT_DATABASE			DIRECTORY_MAIN"accounts.db"
#define WORLD_DATABASE				DIRECTORY_MAIN"world.db"
#define SETTINGS_FILE				DIRECTORY_MAIN"settings.ini"


// Macros
#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward acmd_%1_%2(%3);\
									public acmd_%1_%2(%3)

#define SCMD:%1(%2)					forward scmd_%1(%2);\
									public scmd_%1(%2)

#define HOLDING(%0)					((newkeys & (%0)) == (%0))
#define RELEASED(%0)				(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0)					(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// Colours
#define YELLOW						0xFFFF00FF
#define RED							0xE85454FF
#define GREEN						0x33AA33FF
#define BLUE						0x33CCFFFF
#define ORANGE						0xFFAA00FF
#define GREY						0xAFAFAFFF
#define PINK						0xFFC0CBFF
#define NAVY						0x000080FF
#define GOLD						0xB8860BFF
#define LGREEN						0x00FD4DFF
#define TEAL						0x008080FF
#define BROWN						0xA52A2AFF
#define AQUA						0xF0F8FFFF
#define BLACK						0x000000FF
#define WHITE						0xFFFFFFFF
#define CHAT_LOCAL					0xADABD1FF
#define CHAT_RADIO					0x00FF00FF


// Embedding Colours
#define C_YELLOW					"{FFFF00}"
#define C_RED						"{E85454}"
#define C_GREEN						"{33AA33}"
#define C_BLUE						"{33CCFF}"
#define C_ORANGE					"{FFAA00}"
#define C_GREY						"{AFAFAF}"
#define C_PINK						"{FFC0CB}"
#define C_NAVY						"{000080}"
#define C_GOLD						"{B8860B}"
#define C_LGREEN					"{00FD4D}"
#define C_TEAL						"{008080}"
#define C_BROWN						"{A52A2A}"
#define C_AQUA						"{F0F8FF}"
#define C_BLACK						"{000000}"
#define C_WHITE						"{FFFFFF}"
#define C_SPECIAL					"{0025AA}"


// Body parts
#define BODY_PART_TORSO				(3)
#define BODY_PART_GROIN				(4)
#define BODY_PART_LEFT_ARM			(5)
#define BODY_PART_RIGHT_ARM			(6)
#define BODY_PART_LEFT_LEG			(7)
#define BODY_PART_RIGHT_LEG			(8)
#define BODY_PART_HEAD				(9)


// Genders
#define GENDER_MALE					(0)
#define GENDER_FEMALE				(1)


// Icons (Same id for iconid and markertype)
#define SUPPLY_CRATE_ICON			(38)		
#define WEAPON_CACHE_ICON			(18)
#define PLAYER_BED_ICON				(35)


// Key text
#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_RELOAD				"~k~~SNEAK_ABOUT~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"
#define KEYTEXT_DOORS				"~k~~TOGGLE_SUBMISSIONS~"
#define KEYTEXT_RADIO				"R"


// Attachment slots
enum
{
	ATTACHSLOT_ITEM,		// 0 - Same as SIF/Item
	ATTACHSLOT_BAG,			// 1 - Bag on back
	ATTACHSLOT_HOLSTER,		// 2 - Item holstering
	ATTACHSLOT_HAT,			// 3 - Head-wear slot
	ATTACHSLOT_FACE,		// 4 - Face-wear slot
	ATTACHSLOT_BLOOD,		// 5 - Bleeding particle effect
	ATTACHSLOT_ARMOUR		// 6 - Armour model slot
}

// Redefine Item Extra Data API with the Array Data API
#define SetItemExtraData(%0,%1) SetItemArrayDataAtCell(%0,%1,0,true)
#define GetItemExtraData(%0) GetItemArrayDataAtCell(%0,0)


/*==============================================================================

	Global values

==============================================================================*/


new
bool:	gServerInitialising = true,
		gServerInitialiseTick,
bool:	gServerRestarting = false,
		gServerMaxUptime,
		gServerUptime,
		gGlobalDebugLevel;

// DATABASES
new
DB:		gAccounts;

// GLOBAL SERVER SETTINGS (Todo: modularise)
new
		// player
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gRuleList[MAX_RULE][MAX_RULE_LEN],
		gStaffList[MAX_STAFF][MAX_STAFF_LEN],

		// server
bool:	gAutoLoginWithIP,
bool:	gPauseMap,
bool:	gPlayerAnimations,
bool:	gVehicleSurfing,
Float:	gNameTagDistance,
		gCombatLogWindow,
		gLoginFreezeTime,
		gMaxTaboutTime,
		gPingLimit,
		gCrashOnExit;

// INTERNAL
new
		gBigString[MAX_PLAYERS][4096],
		gTotalRules,
		gTotalStaff;

new stock
		GLOBAL_DEBUG = -1;


/*==============================================================================

	Gamemode Scripts

==============================================================================*/

/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/

// API Pre
#tryinclude "sss/extensions/ext_pre.pwn"

// UTILITIES
#include "sss/utils/logging.pwn"
#include "sss/utils/math.pwn"
#include "sss/utils/misc.pwn"
#include "sss/utils/time.pwn"
#include "sss/utils/camera.pwn"
#include "sss/utils/message.pwn"
#include "sss/utils/vehicle.pwn"
#include "sss/utils/vehicle-data.pwn"
#include "sss/utils/vehicle-parts.pwn"
#include "sss/utils/zones.pwn"
#include "sss/utils/player.pwn"
#include "sss/utils/object.pwn"
#include "sss/utils/string.pwn"
#include "sss/utils/dialog-pages.pwn"
#include "sss/utils/item.pwn"
#include "sss/utils/headoffsets.pwn"

// SERVER CORE
#include "sss/core/server/settings.pwn"
#include "sss/core/server/text-tags.pwn"
#include "sss/core/server/weather.pwn"
#include "sss/core/server/save-block.pwn"
#include "sss/core/server/info-message.pwn"
#include "sss/core/server/language.pwn"
#include "sss/core/player/language.pwn"
#include "sss/core/admin/anti-raid-hack.pwn"
//#include "sss/core/admin/anti-object-wall.pwn"
#include "sss/core/admin/discord.pwn"
//#include "sss/core/admin/telegram.pwn"


/*
	PARENT SYSTEMS
	Modules that declare setup functions and constants used throughout.
*/

#include "sss/core/vehicle/vehicle-type.pwn"
#include "sss/core/vehicle/lock.pwn"
#include "sss/core/player/player.pwn"
#include "sss/core/vehicle/vehicle.pwn"
#include "sss/core/admin/admin.pwn"
#include "sss/core/weapon/ammunition.pwn"
#include "sss/core/weapon/weapon.pwn"
#include "sss/core/weapon/damage.pwn"
#include "sss/core/ui/hold-action.pwn"
#include "sss/core/item/liquid.pwn"
#include "sss/core/world/tree.pwn"
#include "sss/core/world/explosive.pwn"
#include "sss/core/world/craft-construct.pwn"

#include "sss/core/player/item.pwn"

/*
	MODULE INITIALISATION CALLS
	Calls module constructors to set up entity types.
*/
#include "sss/core/server/init.pwn"

// ITEM IO
#include "sss/core/io/loot.pwn"
#include "sss/core/io/item.pwn"
#include "sss/core/io/craft.pwn"
#include "sss/core/io/defence.pwn"
#include "sss/core/io/safebox.pwn"
#include "sss/core/io/tree.pwn"

/*
	CHILD SYSTEMS
	Modules that do not declare anything globally accessible besides interfaces.
*/

// VEHICLE
#include "sss/core/vehicle/player-vehicle.pwn"
#include "sss/core/vehicle/loot-vehicle.pwn"
#include "sss/core/vehicle/spawn.pwn"
#include "sss/core/vehicle/interact.pwn"
#include "sss/core/vehicle/trunk.pwn"
#include "sss/core/vehicle/repair.pwn"
#include "sss/core/vehicle/lock-break.pwn"
#include "sss/core/vehicle/locksmith.pwn"
#include "sss/core/vehicle/carmour.pwn"
#include "sss/core/vehicle/anti-ninja.pwn"
#include "sss/core/vehicle/bike-collision.pwn"
#include "sss/core/vehicle/trailer.pwn"

// PLAYER INTERNAL SCRIPTS
#include "sss/core/player/accounts.pwn"
#include "sss/core/player/aliases.pwn"
#include "sss/core/player/ipv4-log.pwn"
#include "sss/core/player/gpci-log.pwn"
#include "sss/core/player/gpci-whitelist.pwn"
#include "sss/core/player/brightness.pwn"
#include "sss/core/player/spawn.pwn"
#include "sss/core/player/damage.pwn"
#include "sss/core/player/death.pwn"
#include "sss/core/player/tutorial.pwn"
#include "sss/core/player/chat.pwn"
#include "sss/core/player/cmd-process.pwn"
#include "sss/core/player/commands.pwn"
#include "sss/core/player/alt-tab-check.pwn"
#include "sss/core/player/disallow-actions.pwn"
#include "sss/core/player/whitelist.pwn"
#include "sss/core/player/country.pwn"
#include "sss/core/player/recipes.pwn"
#include "sss/core/player/score.pwn"

// CHARACTER SCRIPTS
#include "sss/core/char/movement.pwn"
#include "sss/core/char/food.pwn"
#include "sss/core/char/drugs.pwn"
#include "sss/core/char/clothes.pwn"
#include "sss/core/char/inventory.pwn"
#include "sss/core/char/animations.pwn"
#include "sss/core/char/knockout.pwn"
#include "sss/core/char/disarm.pwn"
#include "sss/core/char/overheat.pwn"
#include "sss/core/char/infection.pwn"
#include "sss/core/char/handcuffs.pwn"
#include "sss/core/char/aim-shout.pwn"
#include "sss/core/char/bleed.pwn"
#include "sss/core/char/skills.pwn"
#include "sss/core/char/travel-stats.pwn"
#include "sss/core/char/headgear-pop.pwn"

// WEAPON
#include "sss/core/weapon/loot.pwn"
#include "sss/core/weapon/interact.pwn"
#include "sss/core/weapon/damage-firearm.pwn"
#include "sss/core/weapon/damage-melee.pwn"
#include "sss/core/weapon/damage-vehicle.pwn"
#include "sss/core/weapon/damage-explosive.pwn"
#include "sss/core/weapon/damage-world.pwn"
#include "sss/core/weapon/animset.pwn"
#include "sss/core/weapon/misc.pwn"
#include "sss/core/weapon/anti-combat-log.pwn"
#include "sss/core/weapon/tracer.pwn"

// UI
#include "sss/core/ui/radio.pwn"
#include "sss/core/ui/tool-tip.pwn"
#include "sss/core/ui/key-actions.pwn"
//#include "sss/core/ui/watch.pwn"
#include "sss/core/ui/keypad.pwn"
#include "sss/core/ui/body-preview.pwn"
//#include "sss/core/ui/status.pwn"

// WORLD ENTITIES
#include "sss/core/world/fuel.pwn"
#include "sss/core/world/supply-crate.pwn"
#include "sss/core/world/weapons-cache.pwn"
#include "sss/core/world/loot.pwn"
#include "sss/core/world/item-tweak.pwn"

// ITEM TYPE CATEGORIES
#include "sss/core/itemtype/defences.pwn"
#include "sss/core/itemtype/furniture.pwn"
#include "sss/core/itemtype/liquid-container.pwn"
#include "sss/core/itemtype/machine.pwn"
#include "sss/core/itemtype/safebox.pwn"
#include "sss/core/itemtype/hats.pwn"
#include "sss/core/itemtype/backpack.pwn"
#include "sss/core/itemtype/medical.pwn"
#include "sss/core/itemtype/masks.pwn"
#include "sss/core/itemtype/holster.pwn"

// ITEMS
#include "sss/core/item/food.pwn"
#include "sss/core/item/firework.pwn"
#include "sss/core/item/shield.pwn"
#include "sss/core/item/handcuffs.pwn"
#include "sss/core/item/wheel.pwn"
#include "sss/core/item/headlight.pwn"
#include "sss/core/item/pills.pwn"
#include "sss/core/item/dice.pwn"
#include "sss/core/item/armour.pwn"
#include "sss/core/item/injector.pwn"
#include "sss/core/item/parachute.pwn"
#include "sss/core/item/molotov.pwn"
#include "sss/core/item/screwdriver.pwn"
#include "sss/core/item/campfire.pwn"
#include "sss/core/item/herpderp.pwn"
#include "sss/core/item/stungun.pwn"
#include "sss/core/item/note.pwn"
#include "sss/core/item/seedbag.pwn"
#include "sss/core/item/plantpot.pwn"
#include "sss/core/item/heartshapedbox.pwn"
#include "sss/core/item/fishingrod.pwn"
#include "sss/core/item/locator.pwn"
#include "sss/core/item/locker.pwn"
#include "sss/core/item/largeframe.pwn"
#include "sss/core/item/barbecue.pwn"
#include "sss/core/item/campfire.pwn"
#include "sss/core/item/sign.pwn"
#include "sss/core/item/workbench.pwn"
#include "sss/core/item/scrap-machine.pwn"
#include "sss/core/item/refine-machine.pwn"
#include "sss/core/item/water-purifier.pwn"
#include "sss/core/item/plot-pole.pwn"
#include "sss/core/item/tent.pwn"
#include "sss/core/item/laserpoint.pwn"
#include "sss/core/item/bed.pwn"
#include "sss/core/item/map.pwn"
#include "sss/core/item/trash.pwn"
#include "sss/core/item/barrel.pwn"
#include "sss/core/item/wooddoor.pwn"

// HATS
#include "sss/core/apparel/hats/HelmArmy.pwn"
#include "sss/core/apparel/hats/TruckCap.pwn"
#include "sss/core/apparel/hats/BoaterHat.pwn"
#include "sss/core/apparel/hats/FireHelmet.pwn"
#include "sss/core/apparel/hats/FireHelmet1.pwn"
#include "sss/core/apparel/hats/BowlerHat.pwn"
#include "sss/core/apparel/hats/PoliceCap.pwn"
#include "sss/core/apparel/hats/TopHat.pwn"
#include "sss/core/apparel/hats/SwatHelmet.pwn"
#include "sss/core/apparel/hats/XmasHat.pwn"
#include "sss/core/apparel/hats/PizzaHat.pwn"
#include "sss/core/apparel/hats/WitchesHat.pwn"
#include "sss/core/apparel/hats/PoliceHelm.pwn"
#include "sss/core/apparel/hats/StrawHat.pwn"
#include "sss/core/apparel/hats/headphones04.pwn"
#include "sss/core/apparel/hats/ArmyHelmet2.pwn"
#include "sss/core/apparel/hats/CowboyHat.pwn"
/*
#include "sss/core/apparel/hats/CaptainsCap.pwn"
#include "sss/core/apparel/hats/CapBack5.pwn"
#include "sss/core/apparel/hats/CapBack4.pwn"
#include "sss/core/apparel/hats/CapBack3.pwn"
#include "sss/core/apparel/hats/CapBack2.pwn"
#include "sss/core/apparel/hats/CapBack1.pwn"*/

// MASKS
#include "sss/core/apparel/masks/GasMask.pwn"
#include "sss/core/apparel/masks/BandanaBlue.pwn"
#include "sss/core/apparel/masks/BandanaPattern.pwn"
#include "sss/core/apparel/masks/HockeyMask.pwn"
//#include "sss/core/apparel/masks/MaskGreen.pwn"
//#include "sss/core/apparel/masks/MaskRed.pwn"
#include "sss/core/apparel/masks/BandanaWhite.pwn"
#include "sss/core/apparel/masks/DiaboMask.pwn"
#include "sss/core/apparel/masks/BandanaGrey.pwn"
#include "sss/core/apparel/masks/CluckinBellHat1.pwn"
#include "sss/core/apparel/masks/Balaclava.pwn"
//#include "sss/core/apparel/masks/GimpMask1.pwn"
//#include "sss/core/apparel/masks/ZorroMask.pwn"
//#include "sss/core/apparel/masks/PussyMask.pwn"

// BAGS
#include "sss/core/apparel/bags/Backpack.pwn"
#include "sss/core/apparel/bags/Daypack.pwn"
#include "sss/core/apparel/bags/HeartShapedBox.pwn"
#include "sss/core/apparel/bags/LargeBackpack.pwn"
#include "sss/core/apparel/bags/MediumBag.pwn"
#include "sss/core/apparel/bags/ParaBag.pwn"
#include "sss/core/apparel/bags/Rucksack.pwn"
#include "sss/core/apparel/bags/Satchel.pwn"

// ADMINISTRATION TOOLS
#include "sss/core/admin/report.pwn"
#include "sss/core/admin/report-cmds.pwn"
#include "sss/core/admin/hack-detect.pwn"
#include "sss/core/admin/hack-trap.pwn"
#include "sss/core/admin/ban.pwn"
#include "sss/core/admin/ban-command.pwn"
#include "sss/core/admin/ban-list.pwn"
#include "sss/core/admin/spectate.pwn"
#include "sss/core/admin/level1.pwn"
#include "sss/core/admin/level2.pwn"
#include "sss/core/admin/level3.pwn"
#include "sss/core/admin/level4.pwn"
#include "sss/core/admin/level5.pwn"
#include "sss/core/admin/bug-report.pwn"
#include "sss/core/admin/detfield.pwn"
#include "sss/core/admin/detfield-cmds.pwn"
#include "sss/core/admin/detfield-draw.pwn"
#include "sss/core/admin/mute.pwn"
#include "sss/core/admin/rcon.pwn"
#include "sss/core/admin/freeze.pwn"
#include "sss/core/admin/name-tags.pwn"
#include "sss/core/admin/player-list.pwn"
#include "sss/core/admin/relatorio.pwn"

// POST-CODE

#include "sss/core/player/save-load.pwn"
#include "sss/core/player/body.pwn"
#include "sss/core/server/auto-save.pwn"
#tryinclude "sss/extensions/ext_post.pwn"

// WORLD

#include "sss/world/world.pwn"

#if !defined GetMapName
	#error World script MUST have a "GetMapName" function!
#endif

#if !defined GenerateSpawnPoint
	#error World script MUST have a "GenerateSpawnPoint" function!
#endif


static
Text:RestartCount = Text:INVALID_TEXT_DRAW;

main() {
	print("[main] Finished initialising Southclaws' Scavenge and Survive");

	gServerInitialising = false;
	gServerInitialiseTick = GetTickCount();
	SetCrashDetectLongCallTime(5000);
}

/*
	This is called absolutely first before any other call.
*/
OnGameModeInit_Setup()
{
	print("[OnGameModeInit_Setup] Setting up...");

	Logger_Log("Initialising Scavenge and Survive");

	Streamer_ToggleErrorCallback(true);

	if(Exists(DIRECTORY_SCRIPTFILES"SSS/"))
	{
		print("ERROR: ./scriptfiles directory detected using old directory structure, please see release notes for stable release #04");
		for(;;){}
	}

	if(!Exists(DIRECTORY_SCRIPTFILES))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES);
	}

	if(!Exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAIN"' not found. Creating directory.");
		CreateDir(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN);
	}

	gAccounts = db_open_persistent(ACCOUNT_DATABASE);

	LoadSettings();

	SendRconCommand(sprintf("mapname %s", GetMapName()));

	GetSettingInt("server/global-debug-level", 0, gGlobalDebugLevel);
	debug_set_level("global", gGlobalDebugLevel);

	RestartCount				=TextDrawCreate(410.000000, 10.000000, "Reiniciando em:~n~00:00");
	TextDrawAlignment			(RestartCount, 2);
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 1);
	TextDrawLetterSize			(RestartCount, 0.400000, 2.000000);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);
}

public OnGameModeExit()
{
	print("[OnGameModeExit] Shutting down...");

	if(gCrashOnExit)
	{
		new File:f = fopen("nonexistentfile", io_read), _s[1];
		fread(f, _s);
		fclose(f);
	}

	return 1;
}

public OnScriptExit()
{
	// Note: DO NOT CHANGE THIS STRING!
	print("[OnScriptExit] LAST_EXIT");
	return 1;
}

forward SetRestart(seconds);
public SetRestart(seconds)
{
	printf("Restarting server in: %ds", seconds);
	gServerUptime = gServerMaxUptime - seconds;
}

RestartGamemode()
{
	print("[RestartGamemode] Initialising gamemode restart...");
	gServerRestarting = true;

	foreach(new i : Player)
	{
		SavePlayerData(i);
		ResetVariables(i);
		
		if(IsPlayerInAnyVehicle(i))
			SaveVehicle(GetPlayerVehicleID(i));
	}

	CloseSaveSessions();

	SendRconCommand("gmx");

	ChatMsgAll(BLUE, " ");
	ChatMsgAll(ORANGE, "Scavenge and Survive");
	ChatMsgAll(BLUE, "    Copyright (C) 2020 Barnaby \"Southclaws\" Keene");
	ChatMsgAll(BLUE, "    This Source Code Form is subject to the terms of the Mozilla Public");
	ChatMsgAll(BLUE, "    License, v. 2.0. If a copy of the MPL was not distributed with this");
	ChatMsgAll(BLUE, "    file, You can obtain one at http://mozilla.org/MPL/2.0/.");
	ChatMsgAll(BLUE, " ");
	ChatMsgAll(BLUE, " ");
	ChatMsgAll(BLUE, "=======================================================");
	ChatMsgAll(YELLOW, "Reiniciando. Por favor aguarde...");
	ChatMsgAll(BLUE, "=======================================================");
}

task RestartUpdate[1000]()
{
	if(gServerMaxUptime > 0)
	{
		if(gServerUptime >= gServerMaxUptime)
			RestartGamemode();

		if(gServerUptime >= gServerMaxUptime - 3600)
		{
			new str[36];
			format(str, 36, "Reiniciando em:~n~%02d:%02d", (gServerMaxUptime - gServerUptime) / 60, (gServerMaxUptime - gServerUptime) % 60);
			TextDrawSetString(RestartCount, str);

			foreach(new i : Player)
			{
				if(IsPlayerHudOn(i))
					TextDrawShowForPlayer(i, RestartCount);
				else
					TextDrawHideForPlayer(i, RestartCount);
			}
		}

		gServerUptime++;
	}

	HTTP(0, HTTP_GET, "localhost:7788/update", "", "OnUpdateCheck");
}

forward OnUpdateCheck(index, response_code, data[]);
public OnUpdateCheck(index, response_code, data[])
{
	if(response_code != 200)
		return;

	if(strlen(data) == 0)
		return;

	new status[8], time;
	if(sscanf(data, "s[8]d", status, time))
		return;

	if(strcmp(status, "update"))
		return;

	Logger_Log("updated amx ready to go", Logger_I("restart_seconds", time));
	SetRestart(time);
}

DirectoryCheck(const directory[])
{
	if(!Exists(directory))
	{
		Logger_Log("creating directory", Logger_S("directory", directory));
		CreateDir(directory);
	}
}

DatabaseTableCheck(DB:database, const tablename[], expectedcolumns)
{
	new
		query[96],
		DBResult:result,
		dbcolumns;

	format(query, sizeof(query), "pragma table_info(%s)", tablename);
	result = db_query(database, query);

	dbcolumns = db_num_rows(result);

	if(dbcolumns != expectedcolumns)
	{
		err("Table '%s' has %d columns, expected %d:", tablename, dbcolumns, expectedcolumns);

		// Put the server into a loop to stop it so the user can read the message.
		// It won't function correctly with bad databases anyway.
		for(;;){}
	}
}

public Streamer_OnPluginError(const error[])
{
	err(error);
}