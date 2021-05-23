public CAC_OnCheatDetect(player_id, cheat_id, opt1, opt2)
{
	DiscordMessage(DISCORD_CHANNEL_DEV, "`%p` OnCheatDetect.", player_id);
}
public CAC_OnPlayerKick(player_id, reason_id)
{
	DiscordMessage(DISCORD_CHANNEL_DEV, "`%p` OnPlayerKick - SAMPCAC.", player_id);
}
public CAC_OnMemoryRead(player_id, address, size, const content[])
{
	DiscordMessage(DISCORD_CHANNEL_DEV, "`%p` OnMemoryRead.", player_id);
}
public CAC_OnGameResourceMismatch(player_id, model_id, component_type, checksum)
{
	DiscordMessage(DISCORD_CHANNEL_DEV, "`%p` OnGameResourceMismatch.", player_id);
}