#include <YSI\y_hooks>

hook OnPlayerConnect(playerid)
{
    //DiscordMessage(DISCORD_CHANNEL_GLOBAL, "`%p` has joined the server.", playerid));

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	//DiscordMessage(DISCORD_CHANNEL_GLOBAL, "`%p` has disconnected from the server.", playerid));

	return 1;
}