#include <YSI_Coding\y_hooks>

#define VELOCITY_NORM	1.0
#define HEIGHT_GAIN		0.5

static
		bool:isFlying[MAX_PLAYERS],
		Float:velocityMult[MAX_PLAYERS] = 0.1;

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys & KEY_JUMP && newkeys & 16 && IsPlayerOnAdminDuty(playerid)) // JUMP and ENTER/F
	{
        CancelPlayerMovement(playerid);

        if(!isFlying[playerid])
            ApplyAnimation(playerid, "PARACHUTE", "FALL_SKYDIVE", 4.0, 1, 0, 0, 0, 0, 1);
        else
            LowerPlayerToGround(playerid);

        isFlying[playerid] = !isFlying[playerid];

		CallLocalFunction("OnAdminToggleFly", "db", playerid, isFlying[playerid]);
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
		Float:velocityFactor;

	GetPlayerKeys(playerid, k, ud, lr);
	GetPlayerFacingAngle(playerid, angle);

	if(ud == KEY_UP)        
        velocityFactor = VELOCITY_NORM;
	else if(ud == KEY_DOWN) 
        velocityFactor =-VELOCITY_NORM;
	
	if(k & KEY_JUMP)
        velocityFactor *= velocityMult[playerid];
	if(k & KEY_SPRINT)
        heightMult = HEIGHT_GAIN * 10;
	if(k & KEY_SPRINT && k & KEY_JUMP) 
        heightMult = HEIGHT_GAIN * 10;
	if(k & KEY_CROUCH)
        heightMult =-HEIGHT_GAIN;

	if(k & KEY_FIRE) // Botão ESQ - Mover em axis
	{
		if(lr == KEY_LEFT)		
            velocityFactor = VELOCITY_NORM, angle += 90.0;
		else if(lr == KEY_RIGHT)
            velocityFactor = VELOCITY_NORM, angle -= 90.0;
	}
	else
	{
		if(k & KEY_JUMP && k & KEY_AIM)
		{	
			if(velocityMult[playerid] < 10.0)
				velocityMult[playerid] += 0.05;
			else
				velocityMult[playerid] = 1.0;

			// TODO: Trocar por textdraw talvez? Para não spammar o chat.
			// ChatMsg(playerid, YELLOW, " » Velocidade de Fly: %0.2f", velocityMult[playerid]);
		}

		if(lr == KEY_LEFT)		
            angle += 6.0;
		else if(lr == KEY_RIGHT)
            angle -= 6.0;

		SetPlayerFacingAngle(playerid, angle);
	}
	SetPlayerVelocity(playerid, velocityFactor*floatsin(-angle, degrees), velocityFactor*floatcos(-angle, degrees), heightMult);

	return 1;
}

hook OnPlayerDisconnect(playerid)
    isFlying[playerid] = false;

hook OnAdminToggleDuty(playerid, bool:duty)
{
	if(duty == false && isFlying[playerid])
	{
		isFlying[playerid] = false;
		LowerPlayerToGround(playerid);

		log(false, "[FLY] ADM off enquanto estava em fly");
	}
}

stock bool:IsAdminFlying(playerid)
    return isFlying[playerid];