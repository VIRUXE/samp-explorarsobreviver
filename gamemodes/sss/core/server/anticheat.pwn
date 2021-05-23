#include "sss/core/server/anticheat/sampcac.pwn"

IsPlayerUsingAnticheat(playerid)
{
	if(CAC_GetStatus(playerid))
		return 1;

	return 0;
}