
#include <YSI_Coding\y_hooks>
#include <YSI_Coding\y_va>

static stock buffer[2000]; // O Limite de texto no Discord é de 2000 caractéres.

stock SendDiscordMessage(DCC_Channel:channel, const fmat[], va_args<>)
{
    formatex(buffer, sizeof(buffer), fmat, va_start<2>);
    DCC_SendChannelMessage(channel, buffer);

    return 1;
}