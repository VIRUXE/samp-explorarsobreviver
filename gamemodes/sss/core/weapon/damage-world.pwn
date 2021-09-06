#include <YSI_Coding\y_hooks>

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(IsAdminOnDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	if(issuerid == INVALID_PLAYER_ID)
	{
		switch(weaponid)
		{
			case 37:
				GivePlayerHP(playerid, -(amount * 0.1));
			case 53:
				KnockOutPlayer(playerid, 1500 + random(1500));
			case 54:
			{
				if(amount > 10.0)
					_DoFallDamage(playerid, amount * 2.5);
			}
		}
	}

	return 1;
}

_DoFallDamage(playerid, Float:multiplier)
{
	if(frandom(100.0) < multiplier)
		PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WOUND_MELEE, (multiplier > 1.0) ? multiplier * 0.00024 : 0.0, multiplier * 0.9, -1, random(2) ? BODY_PART_LEFT_LEG : BODY_PART_RIGHT_LEG, "Queda");
}