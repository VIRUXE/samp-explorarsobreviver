
#include <YSI_Coding\y_hooks>


#define DEFAULT_POS_X				(-2861.0)
#define DEFAULT_POS_Y				(-2845.0)
#define DEFAULT_POS_Z				(50.0)


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
bool:	ply_Alive,
Float:	ply_HitPoints,
Float:	ply_ArmourPoints,
Float:	ply_FoodPoints,
		ply_Clothes,
		ply_Gender,
Float:	ply_Velocity,
		ply_CreationTimestamp,

		// Internal Data
		ply_ShowHUD,
		ply_stance,
		ply_JoinTick,
		ply_SpawnTick,
bool:	ply_GodMode,
bool:	ply_Mobile
}

static
		ply_Data[MAX_PLAYERS][E_PLAYER_DATA],
Timer:	LoadDelay[MAX_PLAYERS],
		LoadCount;


forward OnPlayerScriptUpdate(playerid);
forward OnPlayerDisconnected(playerid);
forward OnDeath(playerid, killerid, reason);

forward Float:GetPlayerTotalVelocity(playerid);

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	ply_Data[playerid][ply_Mobile] = IsPlayerMobile(playerid); // SA-MP Mobile native

	log(true, "[JOIN] %p(%d) %sconnected.", playerid, playerid, IsPlayerUsingMobile(playerid) ? "(Mobile) " : "");

	SetPlayerColor(playerid, COLOR_PLAYER_NORMAL);

	TogglePlayerClock(playerid, false);
	
	SetPlayerVirtualWorld(playerid, playerid + 1);

	ResetVariables(playerid); // wtf why?

	ply_Data[playerid][ply_JoinTick] = GetTickCount();

	new
		ipstring[16],
		ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
		return 0;

	stop LoadDelay[playerid];
	LoadDelay[playerid] = defer LoadAccountDelay(playerid, 5000 + (LoadCount * 2000) );
	LoadCount ++;

	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);
	SetSpawnInfo(playerid, 0, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	if(!isnull(gMessageOfTheDay))
		ChatMsg(playerid, BLUE, ""C_YELLOW" » Mensagem do Dia: "C_BLUE"%s", gMessageOfTheDay);

	if(gServerRestarting)
		ChatMsg(playerid, YELLOW, " » Servidor ainda a reiniciar. Aguarde um pouco..."C_BLUE"%s", gMessageOfTheDay);

	ply_Data[playerid][ply_ShowHUD] = true;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	if(IsPlayerLoggedIn(playerid))
		ChatMsgAll(GREY, " » %P(%d) "C_GREY"%s.", playerid, playerid, reason ? "saiu" : IsPlayerUsingMobile(playerid) ? "saiu" : "perdeu a conexao");

	log(true, "[PART] %p(%d) left the server. (Reason: %s, Logged In: %d)", playerid, playerid, reason ? "quit" : "lost connection", IsPlayerLoggedIn(playerid));

	Logout(playerid);

	SetTimerEx("OnPlayerDisconnected", 100, false, "dd", playerid, reason);

	return 1;
}

timer LoadAccountDelay[timer](playerid, timer)
{
	#pragma unused timer

	if(!IsPlayerConnected(playerid)){
		LoadCount --;
		return;
	}

	if(gServerInitialising || GetTickCountDifference(GetTickCount(), gServerInitialiseTick) < 5000)
	{
		ChatMsg(playerid, YELLOW, " » Aguardando 5s enquanto o servidor inicía...");
		LoadDelay[playerid] = defer LoadAccountDelay(playerid, 5000 + (LoadCount * 2000) );
		return;
	}

	LoadCount --;

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

	if(e == Error:0) // Account does not exist, so load the player on the tutorial first
	{
		Logger_Log("account does not exist, prompting registration",
			Logger_P(playerid),
			Logger_I("result", _:e)
		);
		EnterTutorial(playerid);
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
	ResetVariables(playerid);

ResetVariables(playerid)
{
	ply_Data[playerid][ply_Password][0]			= EOS;
	ply_Data[playerid][ply_IP]					= 0;
	ply_Data[playerid][ply_VIP]					= 0;

	ply_Data[playerid][ply_Alive]				= false;
	ply_Data[playerid][ply_HitPoints]			= 99.0;
	ply_Data[playerid][ply_ArmourPoints]		= 0.0;
	ply_Data[playerid][ply_FoodPoints]			= 80.0;
	ply_Data[playerid][ply_Clothes]				= 0;
	ply_Data[playerid][ply_Gender]				= 0;
	ply_Data[playerid][ply_Velocity]			= 0.0;

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
		if(!gVehicleSurfing)
			VehicleSurfingCheck(playerid);

	//PlayerBagUpdate(playerid);

	new
		hour,
		minute;

	// Get player's own time data
	GetTimeForPlayer(playerid, hour, minute);

	// If it's -1, just use the default instead.
	if(hour == -1 || minute == -1)
		GetServerTime(hour, minute);

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

	SetPlayerHealth(playerid, 99.9);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	SetSpawnInfo(playerid, 0, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	SetPlayerHealth(playerid, 99.9);

	return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
		if(IsPlayerDead(playerid))
			SelectTextDraw(playerid, 0xFFFFFF88);

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	SetPlayerColor(playerid, !IsPlayerUsingMobile(playerid) ? COLOR_PLAYER_NORMAL : COLOR_PLAYER_MOBILE);

	ply_Data[playerid][ply_SpawnTick] = GetTickCount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);

	SetPlayerHealth(playerid, 99.9);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	new Float:velocityX, Float:velocityY, Float:velocityZ;

	// Vehicle Speed
	if(IsPlayerInAnyVehicle(playerid))
	{
		new	uiStr[8];

		GetVehicleVelocity(GetPlayerLastVehicle(playerid), velocityX, velocityY, velocityZ);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (velocityX*velocityX)+(velocityY*velocityY)+(velocityZ*velocityZ) ) * 150.0;
		format(uiStr, 32, "%.0fkm/h", ply_Data[playerid][ply_Velocity]);
		SetPlayerVehicleSpeedUI(playerid, uiStr);
	}
	else
	{
		GetPlayerVelocity(playerid, velocityX, velocityY, velocityZ);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (velocityX*velocityX)+(velocityY*velocityY)+(velocityZ*velocityZ) ) * 150.0;
	}

	// Player Health
	if(ply_Data[playerid][ply_Alive])
	{
		SetPlayerHealth(playerid, IsPlayerGod(playerid) ? (Float:0x7F800000) : ply_Data[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, IsPlayerGod(playerid) ? (Float:0x7F800000) : ply_Data[playerid][ply_ArmourPoints]);
	}
	else
		SetPlayerHealth(playerid, 99.9);

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
			if(IsPlayerInVehicle(i, vehicleid))
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
					driverid = i;

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

	if(hp > 99.9)
		hp = 99.9;

	ply_Data[playerid][ply_HitPoints] = hp;

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

stock bool:IsPlayerAtConnectionPos(playerid)
{
	new Float:playerX, Float:playerY, Float:playerZ;
	new const Float:posRadius = 7.0;

	GetPlayerPos(playerid, playerX, playerY, playerZ);

	if(Distance(playerX, playerY, playerZ, 1133.05, -2038.40, 69.09) < posRadius)
		return true;

	if(Distance(playerX, playerY, playerZ, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z) < posRadius)
		return true;

	if(Distance(playerX, playerY, playerZ, 0.0, 0.0, 0.0) < posRadius)
		return true;

	return false;
}

stock ToggleGodMode(playerid, bool:god)
{
	if(god != ply_Data[playerid][ply_GodMode])
		ply_Data[playerid][ply_GodMode] = god;
}

stock bool:IsPlayerGod(playerid)
	return ply_Data[playerid][ply_GodMode];

stock bool:IsPlayerUsingMobile(playerid)
	return ply_Data[playerid][ply_Mobile];