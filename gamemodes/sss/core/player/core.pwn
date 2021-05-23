#include <YSI\y_hooks>

#define DEFAULT_POS_X				(10000.0)
#define DEFAULT_POS_Y				(10000.0)
#define DEFAULT_POS_Z				(1.0)

enum E_PLAYER_DATA
{
			// Database Account Data
			ply_Password[MAX_PASSWORD_LEN],
			ply_IP,
			ply_RegisterTimestamp,
			ply_LastLogin,
			ply_TotalSpawns,
			ply_Warnings,

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
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA],
Text:		WebsiteAddress = Text:INVALID_TEXT_DRAW;


forward OnPlayerScriptUpdate(playerid);
forward OnPlayerDisconnected(playerid);
forward OnDeath(playerid, killerid, reason);


public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;
	
	if(BanCheck(playerid))
	{
		log(DISCORD_CHANNEL_ADMINEVENTS, "[JOIN] `%p` tried joining while being banned. @everyone", playerid);
		return 0;
	}
	
	log(DISCORD_CHANNEL_GLOBAL, "[JOIN] `%p` has joined (Players Online: %d)", playerid, Iter_Count(Player));
	
	ChatMsg(playerid, ORANGE, "Scavenge and Survive "C_BLUE"(Copyright (C) 2016 Barnaby \"Southclaw\" Keene)");

	ply_Data[playerid][ply_ShowHUD] = true;

	WebsiteAddress				=TextDrawCreate(320.000000, 435.000000, "VIRUXE's Scavenge and Survive (ss.viruxe.party:7777)");
	TextDrawAlignment			(WebsiteAddress, 2);
	TextDrawBackgroundColor		(WebsiteAddress, 255);
	TextDrawFont				(WebsiteAddress, 1);
	TextDrawLetterSize			(WebsiteAddress, 0.240000, 1.000000);
	TextDrawColor				(WebsiteAddress, -1);
	TextDrawSetOutline			(WebsiteAddress, 1);
	TextDrawSetProportional		(WebsiteAddress, 1);

	TextDrawShowForPlayer(playerid, WebsiteAddress);

	TogglePlayerControllable(playerid, false);
	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerBrightness(playerid, 255);

	ResetVariables(playerid);

	ply_Data[playerid][ply_JoinTick] = GetTickCount();

	new
		ipstring[16],
		ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	ShowLanguageMenu(playerid);

	switch(LoadAccount(playerid))
	{
		case -1:
		{// LoadAccount aborted, kick player. (Happens when server can't query database)
			KickPlayer(playerid, "Account load failed");
			log(DISCORD_CHANNEL_DEV, "Account load failed for `%p`.", playerid);
			return 0;
		}
		case 0:
		{// Account does not exist. If not using AC show tutorial and tell or enable register
			if(!IsPlayerUsingAnticheat(playerid))
			{
				//ShowWelcomeMessage(playerid, 10);
				// Enter Tutorial
				ChatMsg(playerid, RED, "You need to install SA-MP 0.3.7 R1 and SAMPCAC first");
				ChatMsg(playerid, RED, "");
				ChatMsg(playerid, RED, "http://files.sa-mp.com/sa-mp-0.3.7-install.exe");
				ChatMsg(playerid, RED, "https://sampcac.xyz/files/sampcac-v0.10.0-installer.exe");
				ChatMsg(playerid, RED, "");
				ChatMsg(playerid, YELLOW, "Join http://chat.viruxe.party if you need any help.");
				KickPlayer(playerid, "Not having SAMPCAC installed", false);
				return 0;
			}
			else
				DisplayRegisterPrompt(playerid);
		}
		case 1:
		{// Account exists, prompt login or kick if not using AC
			if(!IsPlayerUsingAnticheat(playerid))
			{
				ChatMsg(playerid, RED, "You need to install SA-MP 0.3.7 R1 and SAMPCAC first");
				ChatMsg(playerid, RED, "");
				ChatMsg(playerid, RED, "http://files.sa-mp.com/sa-mp-0.3.7-install.exe");
				ChatMsg(playerid, RED, "https://sampcac.xyz/files/sampcac-v0.10.0-installer.exe");
				ChatMsg(playerid, RED, "");
				ChatMsg(playerid, YELLOW, "Join http://chat.viruxe.party if you need any help.");
				KickPlayer(playerid, "Not having SAMPCAC installed", false);
				return 0;
			}
			else
				DisplayLoginPrompt(playerid);
		}
	}

	Streamer_ToggleIdleUpdate(playerid, true);
	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);
	EnablePlayerCameraTarget(playerid, true);

	ChatMsg(playerid, YELLOW, " >  MoTD: "C_BLUE"%s", gMessageOfTheDay);
	foreach(new i : Player)
	{
		if(i != playerid)
			ChatMsg(i, WHITE, " >  %P (%d)"C_WHITE" has joined", playerid, playerid);
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;
	
	//SetTimerEx("OnPlayerDisconnected", 100, false, "dd", playerid, reason);

	switch(reason)
	{
		case 0:
		{
			ChatMsgAll(GREY, " >  %p lost connection.", playerid);
			log(DISCORD_CHANNEL_GLOBAL, "[PART] `%p` has lost connection. (Ping: %d, Tick: %d, PktLoss: %.2f) (Players Online: %d)", playerid, GetPlayerPing(playerid), GetServerTickRate(), NetStats_PacketLossPercent(playerid), Iter_Count(Player)-1);
			if(GetPlayerAdminLevel(playerid))
				DiscordMessage(DISCORD_CHANNEL_ADMIN, "`%p` has lost connection.", playerid);
		}
		case 1:
		{
			ChatMsgAll(GREY, " >  %p left the server.", playerid);
			log(DISCORD_CHANNEL_GLOBAL, "[PART] `%p` has left. (Players Online: %d)", playerid, Iter_Count(Player)-1);
			if(GetPlayerAdminLevel(playerid))
				DiscordMessage(DISCORD_CHANNEL_ADMIN, "`%p` has left.", playerid);
		}
	}
	Logout(playerid);
	ResetVariables(playerid);

	return 1;
}

hook OnPlayerDisconnected(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerDisconnected] in /gamemodes/sss/core/player/core.pwn");

	//ResetVariables(playerid);
}

ResetVariables(playerid)
{
	ply_Data[playerid][ply_Password][0]			= EOS;
	ply_Data[playerid][ply_IP]					= 0;
	ply_Data[playerid][ply_Warnings]			= 0;

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
				KickPlayer(playerid, sprintf("Having a ping of: %d limit: %d.", GetPlayerPing(playerid), pinglimit));

				ply_Data[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else
		ply_Data[playerid][ply_PingLimitStrikes] = 0;

	if(NetStats_MessagesRecvPerSecond(playerid) > 200)
	{
		ChatMsgAdmins(3, YELLOW, " >  %p sending %d messages per second.", playerid, NetStats_MessagesRecvPerSecond(playerid));
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

	return;
}

ptask PlayerUpdateSlow[1000](playerid)
{
	CallLocalFunction("OnPlayerScriptUpdate", "d", playerid);
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsPlayerDead(playerid))
			SelectTextDraw(playerid, 0xFFFFFF88);
		else
			ShowWatch(playerid);
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

	ply_Data[playerid][ply_SpawnTick] = GetTickCount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);
	SetAllWeaponSkills(playerid, 500);
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
			ply_Data[playerid][ply_HitPoints] = 250.0;

		SetPlayerHealth(playerid, ply_Data[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, ply_Data[playerid][ply_ArmourPoints]);
	}
	else
		SetPlayerHealth(playerid, 100.0);		

	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	dbg("global", LOG_CORE, "[OnPlayerStateChange] in /gamemodes/sss/core/player/core.pwn");

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
		HidePlayerGear(playerid);
	}

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	dbg("global", LOG_CORE, "[OnPlayerEnterVehicle] in /gamemodes/sss/core/player/core.pwn");

	if(IsPlayerKnockedOut(playerid))
		return 0;

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

	if(!IsPlayerInAnyVehicle(playerid))
	{
		new weaponid = GetItemTypeWeaponBaseWeapon(GetItemType(GetPlayerItem(playerid)));

		if(weaponid == 34 || weaponid == 35 || weaponid == 43)
		{
			if(newkeys & 128)
			{
				TogglePlayerHatItemVisibility(playerid, false);
				TogglePlayerMaskItemVisibility(playerid, false);
			}
			if(oldkeys & 128)
			{
				TogglePlayerHatItemVisibility(playerid, true);
				TogglePlayerMaskItemVisibility(playerid, true);
			}
		}
	}

	return 1;
}

KillPlayer(playerid, killerid, deathreason)
{
	CallLocalFunction("OnDeath", "ddd", playerid, killerid, deathreason);
}

// ply_Password
stock GetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsValidPlayerID(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_Password]);

	return 1;
}

stock SetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Password] = string;

	return 1;
}

// ply_IP
stock GetPlayerIpAsInt(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_IP];
}

// ply_RegisterTimestamp
stock GetPlayerRegTimestamp(playerid)
{
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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

// ply_Warnings
stock GetPlayerWarnings(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Warnings];
}

stock SetPlayerWarnings(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Warnings] = timestamp;

	return 1;
}

// ply_Alive
stock IsPlayerAlive(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Alive];
}

stock SetPlayerAliveState(playerid, bool:st)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	ply_Data[playerid][ply_Alive] = st;

	return 1;
}

// ply_ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_ShowHUD];
}

stock TogglePlayerHUD(playerid, bool:st)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	ply_Data[playerid][ply_ShowHUD] = st;

	return 1;
}

// ply_HitPoints
forward Float:GetPlayerHP(playerid);
stock Float:GetPlayerHP(playerid)
{
	if(!IsValidPlayerID(playerid))
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

	return 1;
}

// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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

forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_Velocity];
}

stock GetPlayerCreationTimestamp(playerid)
{
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
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
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_SpawnTick];
}