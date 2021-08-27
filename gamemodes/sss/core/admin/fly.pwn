#include <YSI_Coding\y_hooks>

#define VELOCITY_MULT	3.0
#define VELOCITY_NORM	1.0
#define HEIGHT_GAIN		0.5

static bool:isFlying[MAX_PLAYERS];

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP && newkeys & 16 && IsPlayerOnAdminDuty(playerid)) // JUMP and ENTER/F
	{
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
	if(!IsAdminFlying(playerid))
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
	else
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
    isFlying[playerid] = false;

stock bool:IsAdminFlying(playerid)
    return isFlying[playerid];