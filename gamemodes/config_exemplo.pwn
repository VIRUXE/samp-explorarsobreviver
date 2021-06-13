#undef MAX_PLAYERS
#define MAX_PLAYERS						(10)

// YSI
#define _DEBUG							0
#define CGEN_MEMORY						(71000)//(69420)

#define YSI_NO_VERSION_CHECK
#define YSI_NO_OPTIMISATION_MESSAGE
#define YSI_NO_MODE_CACHE
#define YSI_NO_HEAP_MALLOC

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

// SS/button
#define BTN_TELEPORT_FREEZE_TIME		(3000)

// SS/inventory
#define MAX_INVENTORY_SLOTS				(6)

// SS/button
#define BTN_MAX							Button:32768

// SS/item
#define MAX_ITEM						Item:32768
#define MAX_ITEM_TYPE					(ItemType:306)
#define MAX_ITEM_NAME					(20)
#define MAX_ITEM_TEXT					(64)
#define MAX_CONTAINER_SLOTS				(100)

// pawn-errors
// #define PRINT_BACKTRACES

#pragma warning disable 208 // TODO: Fix reparse issues and remove!
#pragma dynamic 64000

#pragma warning disable 214 // Temporary fix remove const warning
#pragma warning disable 239 // Temporary fix remove const warning