#include <YSI_Coding\y_hooks>

#define VELOCITY_MULT	3.0
#define VELOCITY_NORM	1.0
#define HEIGHT_GAIN		0.5

new
    Text:flyTextdraw,
	bool:isFlying[MAX_PLAYERS],
	bool:flyActive[MAX_PLAYERS];

ACMD:fly[2](playerid, params[])
{
    if(flyActive[playerid]) // If disabled while flying
    {
        if(isFlying[playerid])
        {
            isFlying[playerid] = false;

            TogglePlayerAdminDuty(playerid, false, true);
            ClearAnimations(playerid);
            LowerPlayerToGround(playerid);
        }
        TextDrawHideForPlayer(playerid, flyTextdraw);
    }
    else
        TextDrawShowForPlayer(playerid, flyTextdraw);

    flyActive[playerid] = !flyActive[playerid];

    ChatMsg(playerid, flyActive[playerid] ? GREEN : YELLOW, " » Fly %s", flyActive[playerid] ? "Ativado" : "Desativado");

    return 1;
}

hook OnGameModeInit(playerid)
{
    flyTextdraw = TextDrawCreate(5.0, 300.0, "FLY");
    TextDrawAlignment(flyTextdraw, 3);
    TextDrawFont(flyTextdraw, 2);
    // TextDrawLetterSize(flyTextdraw, 3.2, 5.1);
}

hook OnGameModeExit()
    TextDrawDestroy(flyTextdraw);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP && newkeys & 16 && flyActive[playerid]) // JUMP and ENTER/F
	{
        TogglePlayerAdminDuty(playerid, !isFlying[playerid], false);
        ClearAnimations(playerid);

        if(!isFlying[playerid])
            ApplyAnimation(playerid, "PARACHUTE", "FALL_SKYDIVE", 4.0, 1, 0, 0, 0, 0, 1);
        else
            LowerPlayerToGround(playerid);

        isFlying[playerid] = !isFlying[playerid];
	}
}

hook OnPlayerUpdate(playerid)
{
	if(!isFlying[playerid])
        return 1;

    new
		k, ud, lr,
        Float:heightMult = 0.01,
		Float:angle,
		Float:velocityMult;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerFacingAngle(playerid, angle);

	if(ud == KEY_UP)        
        velocityMult = VELOCITY_NORM;
	else if(ud == KEY_DOWN) 
        velocityMult =-VELOCITY_NORM;
	
	if(k & KEY_JUMP)
        velocityMult *= VELOCITY_MULT;
	if(k & KEY_SPRINT)
        heightMult = HEIGHT_GAIN * 10;
	if(k & KEY_SPRINT && k & KEY_JUMP) 
        heightMult = HEIGHT_GAIN * 10;
	if(k & KEY_CROUCH)
        heightMult =-HEIGHT_GAIN;

	if(k & KEY_FIRE) // Botão ESQ - Mover em axis
	{
		if(lr == KEY_LEFT)		
            velocityMult = VELOCITY_NORM, angle += 90.0;
		else if(lr == KEY_RIGHT)
            velocityMult = VELOCITY_NORM, angle -= 90.0;
	}
	else // Botão DIR - Rodar apenas o angulo de direção
	{
		if(lr == KEY_LEFT)		
            angle += 6.0;
		else if(lr == KEY_RIGHT)
            angle -= 6.0;

		SetPlayerFacingAngle(playerid, angle);
	}
	SetPlayerVelocity(playerid, velocityMult*floatsin(-angle, degrees), velocityMult*floatcos(-angle, degrees), heightMult);

	return 1;
}

hook OnPlayerDisconnect(playerid)
{
    flyActive[playerid] = false;
    isFlying[playerid] = false;
}