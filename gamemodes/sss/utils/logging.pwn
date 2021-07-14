
#include <YSI_Coding\y_hooks>
#include <YSI\y_va>


enum
{
	NONE,
	CORE,
	DEEP,
	LOOP
}

static DCC_Channel:log_DiscordChannel;

hook OnGameModeInit()
{
	log_DiscordChannel = DCC_Channel:DCC_Channel:DCC_FindChannelById("864931954516295690");
}

stock log(bool:discord, const text[], va_args<>)
{
	new log_Buffer[256];
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<2>);
	print(log_Buffer);

	if(discord)
		SendDiscordMessage(log_DiscordChannel, log_Buffer);
}

stock dbg(const handler[], level, const text[], va_args<>)
{
	new log_Buffer[256];
	if(level <= GetSVarInt(handler))
	{
		formatex(log_Buffer, sizeof(log_Buffer), text, va_start<3>);
		print(log_Buffer);
	}
}

stock err(const text[], va_args<>)
{
	new log_Buffer[256];
	formatex(log_Buffer, sizeof(log_Buffer), text, va_start<1>);
	print(log_Buffer);
	PrintAmxBacktrace();
}


/*==============================================================================

	Internal/utility

==============================================================================*/


stock debug_set_level(const handler[], level)
{
	SetSVarInt(handler, level);
	return 1;
}

stock debug_conditional(const handler[], level)
{
	return GetSVarInt(handler) >= level;
}
