
#include <YSI_Coding\y_hooks>


static
			BrightnessLevel[MAX_PLAYERS],
PlayerText:	BrightnessUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};


hook OnPlayerConnect(playerid)
{
	BrightnessLevel[playerid] = 255;

	BrightnessUI[playerid]			=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, BrightnessUI[playerid], 255);
	PlayerTextDrawFont				(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, BrightnessUI[playerid], 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, BrightnessUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, BrightnessUI[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawUseBox			(playerid, BrightnessUI[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, BrightnessUI[playerid], 255);
	PlayerTextDrawTextSize			(playerid, BrightnessUI[playerid], 640.000000, 0.000000);

	PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
	PlayerTextDrawShow(playerid, BrightnessUI[playerid]);
}

ptask BrightnessUpdate[100](playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	new Float:hp = GetPlayerHP(playerid);

	if(BrightnessLevel[playerid] > 0.0)
	{
		PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
		PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

		BrightnessLevel[playerid] -= 4;

		if(BrightnessLevel[playerid] < 0)
			BrightnessLevel[playerid] = 0;

		if(hp <= 40.0)
		{
			if(BrightnessLevel[playerid] <= floatround((40.0 - hp) * 4.4))
				BrightnessLevel[playerid] = 0;
		}

		return;
	}

	if(hp >= 40.0)
	{
		if(IsPlayerSpawned(playerid))
			PlayerTextDrawHide(playerid, BrightnessUI[playerid]);

		return;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Painkill))
	{
		PlayerTextDrawHide(playerid, BrightnessUI[playerid]);
	}
	else if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		PlayerTextDrawHide(playerid, BrightnessUI[playerid]);
	}
	else
	{
		PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], floatround((40.0 - hp) * 4.4));
		PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

		if(!IsPlayerKnockedOut(playerid))
		{
			if(GetTickCountDifference(GetTickCount(), GetPlayerKnockOutTick(playerid)) > 5000 * hp)
			{
				new Float:bleedrate;
				GetPlayerBleedRate(playerid, bleedrate);
				if(bleedrate > 0.0)
				{
					if(frandom(40.0) < (50.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (50.0 - hp) + frandom(200 * (50.0 - hp))));
				}
				else
				{
					if(frandom(40.0) < (40.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (40.0 - hp) + frandom(200 * (40.0 - hp))));
				}
			}
		}
	}

	return;
}

stock SetPlayerBrightness(playerid, level)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(level > 255)
		level = 255;

	if(level < 0)
		level = 0;

	BrightnessLevel[playerid] = level;

	PlayerTextDrawBoxColor(playerid, BrightnessUI[playerid], BrightnessLevel[playerid]);
	PlayerTextDrawShow(playerid, BrightnessUI[playerid]);

	if(level <= 0)
		PlayerTextDrawHide(playerid, BrightnessUI[playerid]);

	return 1;
}

ACMD:brightness[4](playerid, params[])
{
	SetPlayerBrightness(playerid, strval(params));
	return 1;
}
