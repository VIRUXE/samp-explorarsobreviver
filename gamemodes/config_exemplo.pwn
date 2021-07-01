/*==============================================================================

	Library Predefinitions

==============================================================================*/

#undef MAX_PLAYERS
#define MAX_PLAYERS						(10)

// YSI
#define _DEBUG							0
#define CGEN_MEMORY						(71000)//(69420)
#define YSI_NO_VERSION_CHECK
#define YSI_NO_OPTIMISATION_MESSAGE
#define YSI_NO_MODE_CACHE
#define YSI_NO_HEAP_MALLOC
#define YSI_NO_CACHE_MESSAGE


// SQLitei
#define DB_DEBUG						false 
#define DB_MAX_STATEMENTS				(128)
#define DB_DEBUG_BACKTRACE_NOTICE		(true)
#define DB_DEBUG_BACKTRACE_WARNING		(true)
#define DB_DEBUG_BACKTRACE_ERROR		(true)

// strlib
#define STRLIB_RETURN_SIZE				(256)

// modio
#define MODIO_DEBUG						(0)
#define MODIO_FILE_STRUCTURE_VERSION	(20)
#define MODIO_SCRIPT_EXIT_FIX			(1)
#define MAX_MODIO_SESSION				(2048)

// SS/inventory
#define MAX_INVENTORY_SLOTS				(7)

// SS/button
#define BTN_MAX							Button:32768
#define BTN_TELEPORT_FREEZE_TIME		(3000)

// SS/item
#define MAX_ITEM						Item:32768
#define MAX_ITEM_TYPE					(ItemType:324)
#define MAX_ITEM_NAME					(20)
#define MAX_ITEM_TEXT					(64)
#define MAX_CONTAINER_SLOTS				(100)

// Optidraw
#define OD_METHOD METHOD_BOX

// Nex Anti-cheat
#define AC_USE_AMMUNATIONS  			(false)
#define AC_USE_PICKUP_WEAPONS  			(false)
#define AC_USE_RESTAURANTS  			(false)
#define AC_USE_VENDING_MACHINES  		(false)
#define AC_USE_TUNING_GARAGES  			(true)
#define AC_USE_PAYNSPRAY  				(true)
#define AC_USE_CASINOS  				(false)
#define AC_USE_NPC  					(false)
#define AC_USE_QUERY  					(true)
#define AC_DEFAULT_COLOR  				(-1)
#define AC_MAX_CLASSES  				(1)
#define AC_MAX_SKINS  					(312)
#define AC_MAX_CONNECTS_FROM_IP  		(5)
#define AC_MAX_RCON_LOGIN_ATTEMPT  		(2)
#define AC_MAX_MSGS_REC_DIFF  			(800)
#define AC_MAX_PING              		(800)
#define AC_MIN_TIME_RECONNECT  			(12)

// pawn-errors
#pragma warning disable 208 // TODO: Fix reparse issues and remove!
#pragma dynamic 64000
#pragma warning disable 214 // Temporary fix remove const warning
#pragma warning disable 239 // Temporary fix remove const warning
// #define PRINT_BACKTRACES