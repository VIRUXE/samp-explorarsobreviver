#include <YSI\y_hooks>

static area;

hook OnGameModeInit()
{
	d:3:GLOBAL_DEBUG("[OnGameModeInit] in extensions/sfn.pwn");

	CreateObject(3350, -962.72461, 5136.90479, 52.29009,   180.00000, 0.00000, 14.88004);
	area = CreateDynamicRectangle(-982.4383, 5091.6768, -950.4024, 5195.4932, 1, 0);
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
	d:3:GLOBAL_DEBUG("[OnPlayerEnterDynArea] in /gamemodes/sss/extensions/sfn.pwn");

	d:3:GLOBAL_DEBUG("[OnPlayerEnterDynArea] in extensions/sfn.pwn");

	if(areaid == area)
	{
		PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/u/45512231/wtf2.3.mp3", -962.72461, 5136.90479, 52.29009, 30.0, 1);
	}
}

public OnPlayerLeaveDynamicArea(playerid, areaid)
{
	if(areaid == area)
	{
		StopAudioStreamForPlayer(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
