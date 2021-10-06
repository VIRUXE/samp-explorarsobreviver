#include <YSI_Coding\y_hooks>


/*==============================================================================

	Anti Infinity Run

==============================================================================*/

new Timer:IsPlayerRunning[MAX_PLAYERS], sprintcount[MAX_PLAYERS];

hook OnPlayerDeath(playerid, killerid, reason)
{
	stop IsPlayerRunning[playerid];
	sprintcount[playerid] = 0;
}

hook OnPlayerUpdate(playerid)
{
	if(GetPlayerAnimationIndex(playerid) == 1266)
	{
		stop IsPlayerRunning[playerid];
		sprintcount[playerid] = 0;
		IsPlayerRunning[playerid] = defer CheckPlayerRun(playerid);
	}
	if(GetPlayerAnimationIndex(playerid) == 471)
	{
		stop IsPlayerRunning[playerid];
		sprintcount[playerid] = 0;
	}

	if(GetPlayerTotalVelocity(playerid) == 0 && sprintcount[playerid] > 0)
		sprintcount[playerid]--;

	return 1;
}

timer CheckPlayerRun[1000](playerid)
{
	if(!IsPlayerConnected(playerid))
		return;

	sprintcount[playerid] ++;

	if(sprintcount[playerid] == 70)
	{
		new
			name[MAX_PLAYER_NAME],
			Float:px,
			Float:py,
			Float:pz;

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		GetPlayerPos(playerid, px, py, pz);

		ReportPlayer(name, "Infinity Run Test", -1, "InfinityRun", px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");

		ChatMsgAdmins(3, RED, "[Anti-Infinity Run Test] %p(%d) detected with infinity run mod. Velocity: %0.1f", playerid, playerid, GetPlayerTotalVelocity(playerid));
	}
}

/*==============================================================================

	Anti Wallhack

==============================================================================*/

// WorldPlayerAdd
/*ORPC:32(playerid, BitStream:bs)
{
	new streamid;
    BS_ReadValue(bs, PR_UINT16, streamid);

	defer CheckPlayersStream(playerid, streamid);
	

	return 1;
}

timer CheckPlayersStream[100](playerid, streamid)
{
	if(!IsPlayerStreamedIn(playerid, streamid))
		return;

	new BitStream:bsn = BS_New();
	BS_WriteValue(bsn, PR_UINT16, streamid, PR_UINT8, 14, PR_STRING, "Digite_Lock2", PR_UINT8, 1);
	PR_SendRPC(bsn, playerid, 11); //SetPlayerName
	BS_Delete(bsn);
	return;
}

// WorldPlayerRemove
ORPC:163(playerid, BitStream:bs)
{
	new streamid;
    BS_ReadValue(bs, PR_UINT16, streamid);
    
	new BitStream:bsn = BS_New(), name[MAX_PLAYER_NAME];
	GetPlayerName(streamid, name, MAX_PLAYER_NAME);
	BS_WriteValue(bsn, PR_UINT16, streamid, PR_UINT8, sizeof(name), PR_STRING, name, PR_UINT8, 1);
	PR_SendRPC(bsn, playerid, 11); //SetPlayerName
	BS_Delete(bsn);
	return 1;
}


// UpdateScoresAndPings
IRPC:155(playerid, BitStream:bs)
{
	new wPlayerID, score, PlayerTarget;
	BS_ReadValue(bs,
		PR_UINT16, wPlayerID,
		PR_UINT32, score,
		PR_UINT32, PlayerTarget
	);

	new BitStream:bsu = BS_New();
	BS_WriteValue(bsu,
		PR_UINT16, wPlayerID,
		PR_UINT32, score,
		PR_UINT32, PlayerTarget
	);

	PR_SendRPC(bsu, playerid, 155);
	BS_Delete(bsu);

	return 0;
}

CMD:lock2(playerid, params[])
{
	new name[24], Float:Pos[3];

	GetPlayerName(playerid, name, 24);
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

	ReportPlayer(name, "WallHack", -1, "WallHack", Pos[0], Pos[1], Pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), sprintf("%.1f, %.1f, %.1f", Pos[0], Pos[1], Pos[2]) );
	
	return 0;
}*/

/*==============================================================================

	Test

==============================================================================*/

/*
public OnIncomingRawPacket(playerid, packetid, BitStream:bs)
{
	if(IsPlayerConnected(playerid))
	{
		static const valid_packets[] = {
			6, 14, 19, 23, 28, 30, 31, 36, 55, 207, 208, 209,
			210,211, 212, 203, 200, 201, 202, 204, 205, 206
		};

		new bool:isvalidpacket;

		for(new i = 0; i < sizeof(valid_packets); i++)
			if(packetid == valid_packets[i])
				isvalidpacket = true;

		if(!isvalidpacket)
		{
			//return 0;
		}
	}
	return 1;
}*/

hook OnPlayerSpawn(playerid)
{
	stop IsPlayerRunning[playerid];
	sprintcount[playerid] = 0;
}

IPacket:206(playerid, BitStream:bs)
{
	new bulletData[PR_BulletSync];
	BS_IgnoreBits(bs, 8);
	BS_ReadBulletSync(bs, bulletData);

	if(!IsPlayerAdmin(playerid) && bulletData[PR_weaponId] == WEAPON_MINIGUN && GetPlayerWeapon(playerid) != WEAPON_MINIGUN)
	{
	    KickPlayer(playerid, "Invisible Weapon Minigun");
		return 0;
	}
	return 1;
}


/*==============================================================================
	Entering locked vehicles
==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(GetPlayerAdminLevel(playerid) != 0)
		return 1;
		
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleId = GetPlayerVehicleID(playerid),
			E_LOCK_STATE:vehicleLock = GetVehicleLockState(vehicleId);

		if(vehicleLock != E_LOCK_STATE_OPEN && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleId)) > SEC(3.5))
		{
			new
				playerName[MAX_PLAYER_NAME],
				Float:px, Float:py, Float:pz,
				bool:isUsingMobile = IsPlayerUsingMobile(playerid);

			GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

			RemovePlayerFromVehicle(playerid);

			defer StillInVeh(playerid, vehicleId, _:vehicleLock);

			ReportPlayer(playerName, sprintf("Entered locked vehicle (%d) as %s (Mobile: %d)", vehicleId, newstate == PLAYER_STATE_DRIVER ? "driver" : "passenger", isUsingMobile), -1, REPORT_TYPE_LOCKEDCAR, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, sprintf("Entered locked vehicle (%d) as %s (Mobile: %d)", vehicleId, newstate == PLAYER_STATE_DRIVER ? "driver" : "passenger", isUsingMobile));

			return -1;
		}
	}

	return 1;
}

timer StillInVeh[1000](playerid, vehicleid, ls)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(IsPlayerInVehicle(playerid, vehicleid))
		TimeoutPlayer(playerid, "Staying in a locked vehicle");

	SetVehicleExternalLock(vehicleid, E_LOCK_STATE:ls);
}

/*==============================================================================
	Infinite Ammo and Shooting Animations
==============================================================================*/

#define	NUM_SHOT_CHECK					(10)
#define	EXCESS_AMOUNT					(7)

static
	ammo_LastShot[MAX_PLAYERS],
	ammo_ShotCounter[MAX_PLAYERS],
	// Excess Accuracy
	ea_PlayerShots		[MAX_PLAYERS],
	ea_PlayerHits		[MAX_PLAYERS],
	ea_LastShots		[MAX_PLAYERS][NUM_SHOT_CHECK],
	ea_Currshot			[MAX_PLAYERS],
	ea_TotalChecks		[MAX_PLAYERS];

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(GetTickCountDifference(GetTickCount(), ammo_LastShot[playerid]) < GetWeaponShotInterval(weaponid) + 10)
	{
		ammo_ShotCounter[playerid]++;

		if(ammo_ShotCounter[playerid] > GetWeaponMagSize(weaponid))
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, sprintf("fired %d bullets from a %w without reloading", ammo_ShotCounter[playerid], weaponid), -1, REPORT_TYPE_AMMO, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, sprintf("fired %d bullets from a %w without reloading", ammo_ShotCounter[playerid], weaponid));
		}
	}
	else
		ammo_ShotCounter[playerid] = 1;

	ammo_LastShot[playerid] = GetTickCount();

	switch(weaponid)
	{
		case 27:
		{
			if(GetPlayerAnimationIndex(playerid) == 222)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 222 while shooting weapon 27", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 222 while shooting weapon 27");

				return 0;
			}
		}
		case 23:
		{
			if(GetPlayerAnimationIndex(playerid) == 1454)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1454 while shooting weapon 23", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1454 while shooting weapon 23");

				return 0;
			}
		}
		case 25:
		{
			if(GetPlayerAnimationIndex(playerid) == 1450)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1450 while shooting weapon 25", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1450 while shooting weapon 25");

				return 0;
			}
		}
		case 29:
		{
			if(GetPlayerAnimationIndex(playerid) == 1645)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1645 while shooting weapon 29", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1645 while shooting weapon 29");

				return 0;
			}
		}
		case 30, 31, 33:
		{
			if(GetPlayerAnimationIndex(playerid) == 1367)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1367 while shooting weapon 30/31/33", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1367 while shooting weapon 30/31/33");

				return 0;
			}
		}
		case 24:
		{
			if(GetPlayerAnimationIndex(playerid) == 1333)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, "Used animation 1333 while shooting weapon 24", -1, REPORT_TYPE_SHOTANIM, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				TimeoutPlayer(playerid, "Used animation 1333 while shooting weapon 24");

				return 0;
			}
		}
		case 22, 26, 28, 32, 34, 38:
		{
			// Do nothing
		}
		default:
		{
			if(hittype == BULLET_HIT_TYPE_PLAYER)
			{
				new
					name[MAX_PLAYER_NAME],
					Float:x,
					Float:y,
					Float:z;

				GetPlayerName(playerid, name, MAX_PLAYER_NAME);
				GetPlayerPos(playerid, x, y, z);

				ReportPlayer(name, sprintf("Shot invalid weapon ID (%d)", weaponid), -1, REPORT_TYPE_BAD_SHOT_WEAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
				Kick(playerid);

				return 0;
			}
		}
	}

	// by IstuntmanI, thanks!
	if(hittype == BULLET_HIT_TYPE_PLAYER)
	{
		if(!(-20.0 <= fX <= 20.0) || !(-20.0 <= fY <= 20.0) || !(-20.0 <= fZ <= 20.0))
		{
			new
				name[MAX_PLAYER_NAME],
				Float:x,
				Float:y,
				Float:z;

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);
			GetPlayerPos(playerid, x, y, z);

			ReportPlayer(name, "Bad bullet hit offset, attempted crash", -1, REPORT_TYPE_BADHITOFFSET, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			TimeoutPlayer(playerid, "Bad bullet hit offset, attempted crash");

			return 0;
		}


/*==============================================================================
	Excess accuracy checks
==============================================================================*/


		if(GetPlayerTargetPlayer(playerid) != INVALID_PLAYER_ID)
		{
			if(!IsPlayerNPC(hitid))
			{
				// Check if player shot is standing still
				new
					Float:vx,
					Float:vy,
					Float:vz;

				GetPlayerVelocity(hitid, vx, vy, vz);

				if(vx != 0.0 || vy != 0.0 || vz != 0.0)
				{
					ea_PlayerShots[playerid]++;
					ea_PlayerHits[playerid]++;
					ea_LastShots[playerid][ea_Currshot[playerid]] = 1;

					new total = CheckLastShots(playerid);

					if(total > 0)
					{
						ea_TotalChecks[playerid]++;
						AccuracyWarning(playerid, total);
					}

					ea_Currshot[playerid]++;

					if(ea_Currshot[playerid] == NUM_SHOT_CHECK)
					{
						ea_Currshot[playerid] = 0;

						for(new i = 0; i < NUM_SHOT_CHECK; i++)
							ea_LastShots[playerid][i] = -1;
					}
				}
			}
		}
		else
		{
			ea_PlayerShots[playerid]++;
			ea_LastShots[playerid][ea_Currshot[playerid]] = 0;

			new total = CheckLastShots(playerid);

			if(total > 0)
			{
				ea_TotalChecks[playerid]++;
				AccuracyWarning(playerid, total);
			}

			ea_Currshot[playerid]++;

			if(ea_Currshot[playerid] == NUM_SHOT_CHECK)
			{
				ea_Currshot[playerid] = 0;

				for(new i = 0; i < NUM_SHOT_CHECK; i++)
					ea_LastShots[playerid][i] = -1;
			}
		}
	}

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	ea_PlayerShots[playerid] 	= 0;
	ea_PlayerHits[playerid] 	= 0;
	ea_Currshot[playerid] 		= 0;
	ea_TotalChecks[playerid] 	= 0;

	for(new i = 0; i < NUM_SHOT_CHECK; i++)
		ea_LastShots[playerid][i] = -1;

	return 1;
}

stock GetPlayerShotStats(playerid, &shots, &hits, &Float:accuracy)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	shots 		= ea_PlayerShots[playerid];
	hits 		= ea_PlayerHits[playerid];
	accuracy 	= floatdiv(float(ea_PlayerHits[playerid]), float(ea_PlayerShots[playerid]));

	return 1;
}

stock CheckLastShots(playerid)
{
	new count;

	for(new i = 0; i < NUM_SHOT_CHECK; i++)
	{
		if(ea_LastShots[playerid][i] == -1)
			return 0;

		if(ea_LastShots[playerid][i])
			count++;
	}

	if(count >= EXCESS_AMOUNT)
		return count;

	return 0;
}

AccuracyWarning(playerid, total)
{
	new
		shots,
		hits,
		Float:accuracy;

	GetPlayerShotStats(playerid, shots, hits, accuracy);

	ChatMsgAdmins(2, YELLOW,
		"Accuracy Warning: %P (%d) Shots: %d Hits: %d Accuracy: %.2f (%d/10) Checks: %d",
		playerid, playerid, shots, hits, accuracy, total, ea_TotalChecks[playerid]);
}

/*==============================================================================

 	Health Hack - Onfoot and vehicle

==============================================================================*/


ptask HealthHackCheck[1000](playerid)
{
	if(IsPlayerStaff(playerid))
		return;

	new Float:playerHealth;

	GetPlayerHealth(playerid, playerHealth);

	if(IsPlayerSpawned(playerid) && !IsPlayerGod(playerid) && playerHealth > 99.9)
	{
		new
			Float:x, Float:y, Float:z,
			playerName[MAX_PLAYER_NAME];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

		ReportPlayer(playerName, "Hack de Vida", -1, "HP", x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
		KickPlayer(playerid, "Hack de Vida");
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		new
			Float:vehicleHP,
			vehicleId = GetPlayerVehicleID(playerid);

		GetVehicleHealth(vehicleId, vehicleHP);

		if(vehicleHP > 990.0 && GetPlayerVehicleSeat(playerid) == 0) // Only check the driver - Checking passengers causes a false ban
		{
			new
				Float:playerX, Float:playerY, Float:playerZ,
				playerName[MAX_PLAYER_NAME];

			GetPlayerPos(playerid, playerX, playerY, playerZ);
			GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

			ReportPlayer(playerName, "Hack de Vida no Veículo", -1, REPORT_TYPE_VHEALTH, playerX, playerY, playerZ, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
			KickPlayer(playerid, "Hack de Vida no Veículo");

			SetVehicleHealth(vehicleId, 300.0); // Reset vehicle health so others don't get banned
		}
	}

	return;
}