
#include <YSI_Coding\y_hooks>
#include <YSI\y_va>

static
DCC_Channel:	log_DiscordChannel,
DCC_Channel:	log_DiscordChannelErrors;

hook OnGameModeInit()
{
	log_DiscordChannel = DCC_Channel:DCC_FindChannelById("864931954516295690");
	log_DiscordChannelErrors = DCC_Channel:DCC_FindChannelById("863050555676819456");
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
	if(level <= GetSVarInt(handler))
		log(false, text, va_start<3>);
}

stock err(bool:backtrace, bool:discord, const text[], va_args<>)
{
	log(discord, "[ERROR] %s", text, va_start<3>);

	if(backtrace)
	{
		if(!discord)
			PrintBacktrace();
		else
		{
			new traceBuffer[2000];

			GetBacktrace(traceBuffer);
			SendDiscordMessage(log_DiscordChannelErrors, "```%s```", traceBuffer);
		}
	}
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
