#include <YSI\y_hooks>
#include <YSI\y_va>

#define DIRECTORY_LOGS				"logs/"
#define MAX_LOG_HANDLER				(128)
#define MAX_LOG_HANDLER_NAME		(32)

enum
{
	LOG_NONE,
	LOG_CORE,
	LOG_DEEP,
	LOG_LOOP
}

enum e_DEBUG_HANDLER
{
	log_name[MAX_LOG_HANDLER_NAME],
	log_level
}

static
		log_Buffer[256],
		log_Table[MAX_LOG_HANDLER][e_DEBUG_HANDLER],
		log_Total;

stock console(text[], va_args<>)
{
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<1>);
	print(log_Buffer);
}

stock log(discord_channel, text[], va_args<>)
{
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<2>);
	print(log_Buffer);

	if(discord_channel != DISCORD_CHANNEL_INVALID)
		DiscordMessage(discord_channel, log_Buffer);
}

stock dbg(handler[], level, text[], va_args<>)
{
	new idx = _debug_get_handler_index(handler);

	if(level <= log_Table[idx][log_level])
	{
		formatex(log_Buffer, sizeof(log_Buffer), text, va_start<3>);
		log(DISCORD_CHANNEL_DEV, "[DEBUG] `%s`", log_Buffer);
	}
}

stock err(text[], va_args<>)
{
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<1>);
	log(DISCORD_CHANNEL_DEV, "[ERROR] `%s`", log_Buffer);
	PrintBacktrace();
}

_debug_get_handler_index(handler[])
{
	for(new i; i < log_Total; ++i)
	{
		if(!strcmp(handler, log_Table[i][log_name]))
			return i;
	}

	return -1;
}

stock debug_set_level(handler[], level)
{
	new idx = _debug_get_handler_index(handler);

	if(idx == -1)
	{
		log_Table[log_Total][log_level] = level;
		log_Total++;
	}
	else
		log_Table[idx][log_level] = level;

	return 1;
}

stock debug_conditional(handler[], level)
{
	new idx = _debug_get_handler_index(handler);

	if(idx != -1)
		return log_Table[idx][log_level] >= level;

	return 0;
}