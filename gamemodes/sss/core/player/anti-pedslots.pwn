#include <YSI_Coding\y_hooks>

/*==============================================================================

	Anti-PedSlotsUsed By Kolor4dO

==============================================================================*/

#define     MAX_PED_SLOTS_USED  (10)

new psu_View[MAX_PED_SLOTS_USED][MAX_PLAYERS];

ptask UpdatePlayerPSU[500](playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING || IsPlayerOnAdminDuty(playerid))
        return;
        
    for(new i = 0; i < MAX_PED_SLOTS_USED; i++)
    {
        if(!IsPlayerConnected(i))
            continue;
            
        if(!IsPlayerStreamedIn(i, playerid))
        {
			new BitStream:bs = BS_New();
			  
			if(random(2) == 1 && psu_View[i][playerid])
			{
			    BS_WriteValue(bs, PR_UINT16, i);
			    PR_SendRPC(bs, playerid, 163); // WorldPlayerRemove
				psu_View[i][playerid] = false; 
			}
			else if(!psu_View[i][playerid])
			{
			    BS_WriteValue(bs,
					PR_UINT16, i,
			        PR_UINT8, GetPlayerTeam(i),
			        PR_UINT32, GetPlayerSkin(i),
			        PR_FLOAT, 3000.0,
			        PR_FLOAT, 3000.0,
			        PR_FLOAT, 1000.0,
			        PR_FLOAT, 0.0,
			        PR_UINT32, GetPlayerColor(i),
			        PR_UINT8, GetPlayerFightingStyle(i));
			    
			    PR_SendRPC(bs, playerid, 32); // WorldPlayerAdd
				psu_View[i][playerid] = true;
			}
			BS_Delete(bs);
		}
	}
	return;
}