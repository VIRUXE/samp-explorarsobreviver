#include <YSI\y_hooks>
#include <YSI\y_timers>

static
	hst_extra[49],
	hst_name[64];

hook OnGameModeInit()
{
	GetSettingString("server/hostname", "VIRUXE's Scavenge and Survive", hst_name);
	GetSettingString("server/hostname-extra", "Extra message needs to be configured.", hst_extra);
}

hook OnGameModeExit()
{
	SendRconCommand(sprintf("hostname %s", hst_name));
}

task SwitchHostname[1000]() 
{
	if(isnull(hst_extra))
		return 0;

	static bool:toggleExtra;

	if(!toggleExtra)
		SendRconCommand(sprintf("hostname %s", hst_extra));
	else
		SendRconCommand(sprintf("hostname %s", hst_name));

	toggleExtra = !toggleExtra;

	return 1;
}

SetHostname(string[])
{
	SendRconCommand(sprintf("hostname %s (%s)", hst_name, string));
}

SetLoadingString(string[])
{
	SetHostname(sprintf("Loading %s", string));
}