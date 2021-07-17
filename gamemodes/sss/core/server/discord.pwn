
#include <YSI_Coding\y_va>

static stock msgBuffer[4000]; // O Limite de texto no Discord é de 4000 caractéres.

stock SendDiscordMessage(DCC_Channel:channel, const fmat[], va_args<>)
{
    formatex(msgBuffer, sizeof(msgBuffer), fmat, va_start<2>);
    DCC_SendChannelMessage(channel, msgBuffer);

    return 1;
}