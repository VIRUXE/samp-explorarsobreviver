#include <YSI_Coding\y_hooks>


new
		tab_Check[MAX_PLAYERS],
bool:	tab_IsTabbed[MAX_PLAYERS],
		tab_TabOutTick[MAX_PLAYERS];


forward OnPlayerFocusChange(playerid, status);


hook OnPlayerUpdate(playerid)
{
	tab_Check[playerid] = 0;
	return 1;
}


ptask AfkCheckUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000)
		return;

	new
		comparison = 500,
		Float:x,
		Float:y,
		Float:z,
		playerstate;

	playerstate = GetPlayerState(playerid);

	if(playerstate <= 1)
		GetPlayerVelocity(playerid, z, y, z);

	else if(playerstate <= 3)
		GetVehicleVelocity(GetPlayerVehicleID(playerid), x, y, z);

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 2000)
		comparison = 3000;

	else if(IsPlayerBeingHijacked(playerid))
		comparison = 3800;

	else if((x == 0.0 && y == 0.0 && z == 0.0))
		comparison = 2500;

	comparison += GetPlayerPing(playerid);

	// ShowActionText(playerid, sprintf("%d :: %s%d - %d", playerstate, (tab_Check[playerid] > comparison) ? ("~r~") : ("~w~"), tab_Check[playerid], comparison), 0);

	if(tab_Check[playerid] > comparison)
	{
		if(!tab_IsTabbed[playerid])
		{
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 0);

			log(true, "[FOCUS] %p unfocused game", playerid);

			if(gMaxTaboutTime == 0)
			{
				KickPlayer(playerid, "Unfocused from the game, could starve and cause bugs");
				return;
			}

			tab_TabOutTick[playerid] = GetTickCount();
			tab_IsTabbed[playerid] = true;
		}
		return;
	}

	if(!tab_Check[playerid])
	{
		if(tab_IsTabbed[playerid])
		{
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 1);

			log(true, "[FOCUS] %p focused back to game", playerid);

			tab_IsTabbed[playerid] = false;
		}
	}

	tab_Check[playerid] += 100;

	return;
}

hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
	AFK_CheckKick(damagedid);

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
	AFK_CheckKick(playerid);

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
	AFK_CheckKick(targetid);

stock AFK_CheckKick(playerid)
{
	if(IsPlayerConnected(playerid) && !IsAdminOnDuty(playerid) && tab_IsTabbed[playerid])
	{
		if(GetTickCountDifference(GetTickCount(), tab_TabOutTick[playerid]) > SEC(gMaxTaboutTime))
		{
			KickPlayer(playerid, sprintf("Ausente por mais de %d segundos", gMaxTaboutTime));
		}
	}
}

stock IsPlayerUnfocused(playerid)
	return tab_IsTabbed[playerid];

