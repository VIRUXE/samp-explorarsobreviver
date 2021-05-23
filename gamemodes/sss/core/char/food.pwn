#include <YSI\y_hooks>


#define IDLE_FOOD_RATE (0.004)


static 
PlayerBar:HungerBar[MAX_PLAYERS],
PlayerText:HungerBarBackground[MAX_PLAYERS],
PlayerText:HungerBarForeground[MAX_PLAYERS];


hook OnPlayerScriptUpdate(playerid)
{
	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(!IsPlayerSpawned(playerid))
		return;

	new
		infectionIntensity = GetPlayerInfectionIntensity(playerid, 0),
		anim = GetPlayerAnimationIndex(playerid),
		k,
		ud,
		lr,
		Float:food;

	GetPlayerKeys(playerid, k, ud, lr);
	food = GetPlayerFP(playerid);

	if(infectionIntensity)
		food -= IDLE_FOOD_RATE;

	if(anim == 43) // Sitting
		food -= IDLE_FOOD_RATE * 0.2;
	else if(anim == 1159) // Crouching
		food -= IDLE_FOOD_RATE * 1.1;
	else if(anim == 1195) // Jumping
		food -= IDLE_FOOD_RATE * 3.2;	
	else if(anim == 1231) // Running
	{
		if(k & KEY_WALK) // Walking
			food -= IDLE_FOOD_RATE * 1.2;
		else if(k & KEY_SPRINT) // Sprinting
			food -= IDLE_FOOD_RATE * 2.2;
		else if(k & KEY_JUMP) // Jump
			food -= IDLE_FOOD_RATE * 3.2;
		else
			food -= IDLE_FOOD_RATE * 2.0;
	}
	else
		food -= IDLE_FOOD_RATE; // Default rate

	if(food > 100.0)
		food = 100.0;

	if(!IsPlayerUnderDrugEffect(playerid, drug_Morphine) && !IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		if(food < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
			{
				if(infectionIntensity == 0)
					SetPlayerDrunkLevel(playerid, 0);
			}
			else
				SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - food) * 300.0));
		}
		else
		{
			if(infectionIntensity == 0)
				SetPlayerDrunkLevel(playerid, 0);
		}
	}

	if(food < 20.0)
		SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);

	if(food < 0.0)
		food = 0.0;

	if(IsPlayerHudOn(playerid))
		SetPlayerProgressBarValue(playerid, HungerBar[playerid], food);

	SetPlayerFP(playerid, food);

	return;
}

stock TogglePlayerHungerBar(playerid, bool:toggle)
{
	if(toggle)
		ShowPlayerProgressBar(playerid, HungerBar[playerid]);
	else
		HidePlayerProgressBar(playerid, HungerBar[playerid]);
}

hook OnPlayerConnect(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerConnect] in /gamemodes/sss/core/char/food.pwn");

	//HungerBar[playerid] = CreatePlayerProgressBar(playerid, 548.000000, 36.000000, 62.000000, 3.200000, 536354815, 100.0000, 0);

	HungerBar[playerid] = CreatePlayerProgressBar(playerid, 626.0, 100.0, 10.0, 100.0, -2130771840, 100.0, BAR_DIRECTION_UP);
	HungerBarBackground[playerid]	=CreatePlayerTextDraw(playerid, 612.000000, 101.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarBackground[playerid], 0.500000, -10.200000);
	PlayerTextDrawColor				(playerid, HungerBarBackground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, HungerBarBackground[playerid], 618.000000, 10.000000);

	HungerBarForeground[playerid]	=CreatePlayerTextDraw(playerid, 613.000000, 100.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, HungerBarForeground[playerid], 255);
	PlayerTextDrawFont				(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, HungerBarForeground[playerid], 0.500000, -10.000000);
	PlayerTextDrawColor				(playerid, HungerBarForeground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, HungerBarForeground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, HungerBarForeground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, HungerBarForeground[playerid], -2130771840);
	PlayerTextDrawTextSize			(playerid, HungerBarForeground[playerid], 617.000000, 10.000000);
}
