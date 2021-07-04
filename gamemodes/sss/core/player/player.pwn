
#include <YSI_Coding\y_hooks>


#define DEFAULT_POS_X				(3000.0)
#define DEFAULT_POS_Y				(0.0)
#define DEFAULT_POS_Z				(3.0)


enum E_PLAYER_DATA
{
			// Database Account Data
			ply_Password[MAX_PASSWORD_LEN],
			ply_IP,
			ply_RegisterTimestamp,
			ply_LastLogin,
			ply_TotalSpawns,
			ply_VIP,

			// Character Data
bool:		ply_Alive,
Float:		ply_HitPoints,
Float:		ply_ArmourPoints,
Float:		ply_FoodPoints,
			ply_Clothes,
			ply_Gender,
Float:		ply_Velocity,
			ply_CreationTimestamp,

			// Internal Data
			ply_ShowHUD,
			ply_PingLimitStrikes,
			ply_stance,
			ply_JoinTick,
			ply_SpawnTick
}

static
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA];


forward OnPlayerScriptUpdate(playerid);
forward OnPlayerDisconnected(playerid);
forward OnDeath(playerid, killerid, reason);

forward Float:GetPlayerTotalVelocity(playerid);


public OnPlayerConnect(playerid)
{
	Logger_Log("player connected", Logger_P(playerid));

	SetPlayerColor(playerid, 0xB8B8B800);
	TogglePlayerClock(playerid, 1);
	
	if(IsPlayerNPC(playerid))
		return 1;

	ResetVariables(playerid);

	ply_Data[playerid][ply_JoinTick] = GetTickCount();

	new
		ipstring[16],
		ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
		return 0;

	defer LoadAccountDelay(playerid);

	SetPlayerBrightness(playerid, 255);

	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);
	SetSpawnInfo(playerid, 0, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	foreach(new i : Player)
		if(i != playerid)
			ChatMsg(i, WHITE, " » %P (%d)"C_WHITE" entrou no servidor.", playerid, playerid);

	if(!isnull(gMessageOfTheDay))
		ChatMsg(playerid, YELLOW, " » MdD: "C_BLUE"%s", gMessageOfTheDay);

	ply_Data[playerid][ply_ShowHUD] = true;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	Logout(playerid);

	switch(reason)
	{
		case 0:
		{
			ChatMsgAll(GREY, " » %p perdeu a conexão.", playerid);
			Logger_Log("player lost connection", Logger_P(playerid));
		}
		case 1:
		{
			ChatMsgAll(GREY, " » %p saiu do servidor.", playerid);
			Logger_Log("player quit", Logger_P(playerid));
		}
	}

	SetTimerEx("OnPlayerDisconnected", 100, false, "dd", playerid, reason);

	return 1;
}

timer LoadAccountDelay[5000](playerid)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(gServerInitialising || GetTickCountDifference(GetTickCount(), gServerInitialiseTick) < 5000)
	{
		ChatMsg(playerid, YELLOW, " » Aguardando 5s enquanto o servidor inicía...");
		defer LoadAccountDelay(playerid);
		return;
	}

	if(IsWhitelistActive() && !IsWhitelistAuto())
	{
		if(!IsPlayerInWhitelist(playerid))
		{
			WhitelistWarn(playerid);
			defer LoadAccountDelay(playerid);
			return;
		}
	}

	new Error:e = LoadAccount(playerid);
	if(IsError(e)) // LoadAccount aborted, kick player.
	{
		new cause[128];
		GetLastErrorCause(cause);
		Logger_Err("failed to load account",
			Logger_P(playerid),
			Logger_S("cause", cause));
		KickPlayer(playerid, "Problema ao carregar a sua conta...");
		Handled();
		return;
	}

	if(e == Error:0) // Account does not exist
	{
		Logger_Log("account does not exist, prompting registration",
			Logger_P(playerid),
			Logger_I("result", _:e)
		);
		DisplayRegisterPrompt(playerid);
	}

	if(e == Error:1) // Account does exist, prompt login
	{
		Logger_Log("account loaded, prompting login",
			Logger_P(playerid),
			Logger_I("result", _:e)
		);
		DisplayLoginPrompt(playerid);
	}

	if(e == Error:2) // Account does exist, auto login
	{
		Logger_Log("LoadAccount: auto login",
			Logger_P(playerid)
		);
		Login(playerid);
	}

	if(e == Error:4) // Account does exists, but is disabled
	{
		Logger_Log("LoadAccount: account inactive",
			Logger_P(playerid)
		);
		KickPlayer(playerid, "Conta inativa!");
	}

	return;
}

hook OnPlayerDisconnected(playerid)
{
	ResetVariables(playerid);
}

ResetVariables(playerid)
{
	ply_Data[playerid][ply_Password][0]			= EOS;
	ply_Data[playerid][ply_IP]					= 0;
	ply_Data[playerid][ply_VIP]					= 0;

	ply_Data[playerid][ply_Alive]				= false;
	ply_Data[playerid][ply_HitPoints]			= 100.0;
	ply_Data[playerid][ply_ArmourPoints]		= 0.0;
	ply_Data[playerid][ply_FoodPoints]			= 80.0;
	ply_Data[playerid][ply_Clothes]				= 0;
	ply_Data[playerid][ply_Gender]				= 0;
	ply_Data[playerid][ply_Velocity]			= 0.0;

	ply_Data[playerid][ply_PingLimitStrikes]	= 0;
	ply_Data[playerid][ply_stance]				= 0;
	ply_Data[playerid][ply_JoinTick]			= 0;
	ply_Data[playerid][ply_SpawnTick]			= 0;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}

ptask PlayerUpdateFast[100](playerid)
{
	new pinglimit = (Iter_Count(Player) > 10) ? (gPingLimit) : (gPingLimit + 100);

	if(GetPlayerPing(playerid) > pinglimit)
	{
		if(GetTickCountDifference(GetTickCount(), ply_Data[playerid][ply_JoinTick]) > 10000)
		{
			ply_Data[playerid][ply_PingLimitStrikes]++;

			if(ply_Data[playerid][ply_PingLimitStrikes] == 30)
			{
				KickPlayer(playerid, sprintf("Ping muito alto! (%d/%d)", GetPlayerPing(playerid), pinglimit));

				ply_Data[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else
	{
		ply_Data[playerid][ply_PingLimitStrikes] = 0;
	}

	if(NetStats_MessagesRecvPerSecond(playerid) > 200)
	{
		ChatMsgAdmins(3, YELLOW, " » %p sending %d messages per second.", playerid, NetStats_MessagesRecvPerSecond(playerid));
		return;
	}

	if(!IsPlayerSpawned(playerid))
		return;

	if(IsPlayerInAnyVehicle(playerid))
		PlayerVehicleUpdate(playerid);
	else
	{
		if(!gVehicleSurfing)
			VehicleSurfingCheck(playerid);
	}

	PlayerBagUpdate(playerid);

	new
		hour,
		minute;

	// Get player's own time data
	GetTimeForPlayer(playerid, hour, minute);

	// If it's -1, just use the default instead.
	if(hour == -1 || minute == -1)
		gettime(hour, minute);

	SetPlayerTime(playerid, hour, minute);

	return;
}

ptask PlayerUpdateSlow[1000](playerid)
{
	CallLocalFunction("OnPlayerScriptUpdate", "d", playerid);
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	SetSpawnInfo(playerid, 0, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	SetSpawnInfo(playerid, 0, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsPlayerDead(playerid))
			SelectTextDraw(playerid, 0xFFFFFF88);
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	if(IsPlayerOnAdminDuty(playerid))
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		return 1;
	}

	SetPlayerColor(playerid, 0xB8B8B800);
	
	if(IsPlayerMobile(playerid))
	{
		EnableAntiCheatForPlayer(playerid, 52, false);
		SetPlayerColor(playerid, 0x59595900);
	}

	SetPlayerPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	
	ply_Data[playerid][ply_SpawnTick] = GetTickCount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);

	Streamer_Update(playerid);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(GetPlayerLastVehicle(playerid), vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", ply_Data[playerid][ply_Velocity]);
		SetPlayerVehicleSpeedUI(playerid, str);
	}
	else
	{
		static
			Float:vx,
			Float:vy,
			Float:vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	}

	if(ply_Data[playerid][ply_Alive])
	{
		if(IsPlayerOnAdminDuty(playerid))
			SetPlayerHealth(playerid, 99999);

		SetPlayerArmour(playerid, ply_Data[playerid][ply_ArmourPoints]);
	}	

	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		//ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
		CancelSelectTextDraw(playerid);
		HidePlayerGear(playerid);
	}

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(IsPlayerKnockedOut(playerid)) {
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
		CancelPlayerMovement(playerid);
		return 0;
	}

	if(GetPlayerSurfingVehicleID(playerid) == vehicleid)
		CancelPlayerMovement(playerid);

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
					driverid = i;
			}
		}

		if(driverid == -1)
			CancelPlayerMovement(playerid);
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	return 1;
}

KillPlayer(playerid, killerid, deathreason)
{
	CallLocalFunction("OnDeath", "ddd", playerid, killerid, deathreason);
}

// ply_Password
stock GetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_Password]);

	return 1;
}

stock SetPlayerPassHash(playerid, const string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Password] = string;

	return 1;
}

// ply_IP
stock GetPlayerIpAsInt(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_IP];
}

// ply_RegisterTimestamp
stock GetPlayerRegTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_RegisterTimestamp];
}

stock SetPlayerRegTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_RegisterTimestamp] = timestamp;

	return 1;
}

// ply_LastLogin
stock GetPlayerLastLogin(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_LastLogin];
}

stock SetPlayerLastLogin(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_LastLogin] = timestamp;

	return 1;
}

// ply_TotalSpawns
stock GetPlayerTotalSpawns(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_TotalSpawns];
}

stock SetPlayerTotalSpawns(playerid, amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_TotalSpawns] = amount;

	return 1;
}

// ply_VIP
stock GetPlayerVIP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_VIP];
}

stock SetPlayerVIP(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_VIP] = timestamp;

	return 1;
}

// ply_Alive
stock IsPlayerAlive(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Alive];
}

stock SetPlayerAliveState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Alive] = st;

	return 1;
}

// ply_ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_ShowHUD];
}

stock TogglePlayerHUD(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_ShowHUD] = st;

	return 1;
}

// ply_HitPoints
forward Float:GetPlayerHP(playerid);
stock Float:GetPlayerHP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_HitPoints];
}

stock SetPlayerHP(playerid, Float:hp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(hp > 100.0)
		hp = 100.0;

	ply_Data[playerid][ply_HitPoints] = hp;

	SetPlayerHealth(playerid, hp);

	return 1;
}

// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_ArmourPoints];
}

stock SetPlayerAP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_ArmourPoints] = amount;

	return 1;
}

// ply_FoodPoints
forward Float:GetPlayerFP(playerid);
stock Float:GetPlayerFP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_FoodPoints];
}

stock SetPlayerFP(playerid, Float:food)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_FoodPoints] = food;

	return 1;
}

// ply_Clothes
stock GetPlayerClothesID(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Clothes];
}

stock SetPlayerClothesID(playerid, id)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Clothes] = id;

	return 1;
}

// ply_Gender
stock GetPlayerGender(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Gender];
}

stock SetPlayerGender(playerid, gender)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Gender] = gender;

	return 1;
}

// ply_Velocity
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_Velocity];
}

// ply_CreationTimestamp
stock GetPlayerCreationTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_CreationTimestamp];
}

stock SetPlayerCreationTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_CreationTimestamp] = timestamp;

	return 1;
}

// ply_PingLimitStrikes
// ply_stance
stock GetPlayerStance(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_stance];
}

stock SetPlayerStance(playerid, stance)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_stance] = stance;

	return 1;
}

// ply_JoinTick
stock GetPlayerServerJoinTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_SpawnTick];
}
