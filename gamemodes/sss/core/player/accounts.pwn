#include <YSI_Coding\y_hooks>

enum // All the account steps
{
	ACCOUNT_STATE_INVALID, // When an error occurs
	ACCOUNT_STATE_NOTREGISTERED,
	ACCOUNT_STATE_REGISTERED, // Registered but not linked with discord
	ACCOUNT_STATE_REGISTERING,
	ACCOUNT_STATE_LINKED, // Linked on Discord
	ACCOUNT_STATE_BANNED,
	ACCOUNT_STATE_LOGGINGIN,
	ACCOUNT_STATE_LOGGEDIN
}

static
				acc_State[MAX_PLAYERS],
bool:			acc_LoggedIn[MAX_PLAYERS],
				acc_LoginAttempts[MAX_PLAYERS],

DBStatement:	stmt_AccountRegistered,
DBStatement:	stmt_AccountCreate,
DBStatement:	stmt_AccountLoad,
DBStatement:	stmt_AccountUpdate,

DBStatement:	stmt_AccountGetPassword,
DBStatement:	stmt_AccountSetPassword,

DBStatement:	stmt_AccountGetIpv4,
DBStatement:	stmt_AccountSetIpv4,

DBStatement:	stmt_AccountGetAliveState,
DBStatement:	stmt_AccountSetAliveState,

DBStatement:	stmt_AccountGetRegdate,
DBStatement:	stmt_AccountSetRegdate,

DBStatement:	stmt_AccountGetLastLog,
DBStatement:	stmt_AccountSetLastLog,

DBStatement:	stmt_AccountGetSpawnTime,
DBStatement:	stmt_AccountSetSpawnTime,

DBStatement:	stmt_AccountGetTotalSpawns,
DBStatement:	stmt_AccountSetTotalSpawns,

DBStatement:	stmt_AccountGetVIP,
DBStatement:	stmt_AccountSetVIP,

DBStatement:	stmt_AccountGetDiscordId,
DBStatement:	stmt_AccountSetDiscordId,
DBStatement:	stmt_AccountHaveDiscord,

DBStatement:	stmt_AccountGetGpci,
DBStatement:	stmt_AccountSetGpci,

DBStatement:	stmt_AccountGetActiveState,
DBStatement:	stmt_AccountSetActiveState,

DBStatement:	stmt_AccountGetAliasData;
	
forward OnPlayerAccountCheck(playerid, accountState);
forward OnPlayerAccountLoaded(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);

hook OnGameModeInit()
{
	db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS Player (name TEXT, pass TEXT, ipv4 INTEGER, alive INTEGER, regdate INTEGER, lastlog INTEGER, spawntime INTEGER, totalspawns INTEGER, vip INTEGER, discord_id TEXT, gpci TEXT, active)");
	db_query(gAccountsDatabase, "CREATE INDEX IF NOT EXISTS Player_index ON Player(name)");

	DatabaseTableCheck(gAccountsDatabase, "Player", 12);

	stmt_AccountRegistered		= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountCreate			= db_prepare(gAccountsDatabase, "INSERT INTO Player (name, pass, ipv4, alive, regdate, lastlog, spawntime, spawns, VIP, gpci, active) VALUES(?,?,?,1,?,?,0,0,0,?,1)");
	stmt_AccountLoad			= db_prepare(gAccountsDatabase, "SELECT * FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountUpdate			= db_prepare(gAccountsDatabase, "UPDATE Player SET alive=?, vip=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetPassword		= db_prepare(gAccountsDatabase, "SELECT pass FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetPassword		= db_prepare(gAccountsDatabase, "UPDATE Player SET pass=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetIpv4			= db_prepare(gAccountsDatabase, "SELECT ipv4 FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetIpv4			= db_prepare(gAccountsDatabase, "UPDATE Player SET ipv4=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetAliveState	= db_prepare(gAccountsDatabase, "SELECT alive FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetAliveState	= db_prepare(gAccountsDatabase, "UPDATE Player SET alive=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetRegdate		= db_prepare(gAccountsDatabase, "SELECT regdate FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetRegdate		= db_prepare(gAccountsDatabase, "UPDATE Player SET regdate=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetLastLog		= db_prepare(gAccountsDatabase, "SELECT lastlog FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetLastLog		= db_prepare(gAccountsDatabase, "UPDATE Player SET lastlog=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetSpawnTime	= db_prepare(gAccountsDatabase, "SELECT spawntime FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetSpawnTime	= db_prepare(gAccountsDatabase, "UPDATE Player SET spawntime=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetTotalSpawns	= db_prepare(gAccountsDatabase, "SELECT totalspawns FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetTotalSpawns	= db_prepare(gAccountsDatabase, "UPDATE Player SET totalspawns=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetVIP			= db_prepare(gAccountsDatabase, "SELECT vip FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetVIP			= db_prepare(gAccountsDatabase, "UPDATE Player SET vip=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetDiscordId	= db_prepare(gAccountsDatabase, "SELECT discord_id FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetDiscordId	= db_prepare(gAccountsDatabase, "UPDATE Player SET discord_id=? WHERE name=? COLLATE NOCASE");
	stmt_AccountHaveDiscord		= db_prepare(gAccountsDatabase, "SELECT count(*) FROM Player WHERE name=? AND discord_id NOTNULL COLLATE NOCASE;");

	stmt_AccountGetGpci			= db_prepare(gAccountsDatabase, "SELECT gpci FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetGpci			= db_prepare(gAccountsDatabase, "UPDATE Player SET gpci=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetActiveState	= db_prepare(gAccountsDatabase, "SELECT active FROM Player WHERE name=? COLLATE NOCASE");
	stmt_AccountSetActiveState	= db_prepare(gAccountsDatabase, "UPDATE Player SET active=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetAliasData	= db_prepare(gAccountsDatabase, "SELECT ipv4, pass, gpci FROM Player WHERE name=? AND active COLLATE NOCASE");
}

hook OnPlayerConnect(playerid) // Check the player's account state
{
	new playerName[MAX_PLAYER_NAME];

	GetPlayerName(playerid, playerName);

	if(DoesPlayerAccountExist(playerName))
	{
		new isAccountActive;

		GetAccountActiveState(playerName, isAccountActive);

		if(isAccountActive || !IsPlayerBanned(playerName))
			acc_State[playerid] = !DoesAccountHaveDiscord(playerName) ? ACCOUNT_STATE_REGISTERED : ACCOUNT_STATE_LINKED;
		else
			acc_State[playerid] = ACCOUNT_STATE_BANNED;
	}
	else
		acc_State[playerid] = ACCOUNT_STATE_NOTREGISTERED;

	CallLocalFunction("OnPlayerAccountCheck", "dd", playerid, acc_State[playerid]);
}

hook OnPlayerDisconnect(playerid)
{
	acc_State[playerid] = ACCOUNT_STATE_INVALID;
	acc_LoggedIn[playerid] = false;
	acc_LoginAttempts[playerid] = 0;
}

public OnPlayerAccountCheck(playerid, accountState)
{
	if(accountState == ACCOUNT_STATE_LINKED)
		LoginPlayer(playerid);
}

stock bool:IsPlayerRegistering(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_State[playerid] == ACCOUNT_STATE_REGISTERING ? true : false;
}

stock bool:IsPlayerLoggingIn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_State[playerid] == ACCOUNT_STATE_LOGGINGIN ? true : false;
}

stock bool:IsPlayerLoggedIn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_State[playerid] == ACCOUNT_STATE_LOGGEDIN ? true : false;
}

stock IsPlayerAccountLinked(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_State[playerid] == ACCOUNT_STATE_LINKED ? true : false;
}

stock GetPlayerAccountState(playerid)
{
	if(IsPlayerConnected(playerid))
		return 0;

	return acc_State[playerid];
}

stock SetPlayerAccountState(playerid, newState)
{
	if(IsPlayerConnected(playerid))
		return;
	
	acc_State[playerid] = newState;
}


/*==============================================================================

	Loads database data into memory and applies it to the player.

==============================================================================*/
stock Error:LoadPlayerAccount(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		password[MAX_PASSWORD_LEN],
		ipv4,
		bool:alive,
		regdate,
		lastlog,
		spawntime,
		spawns,
		VIP,
		active;

	stmt_bind_value(stmt_AccountLoad, 0, 		DB::TYPE_STRING, 	name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, 1, DB::TYPE_STRING, 	password, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, 2, DB::TYPE_INTEGER, 	ipv4);
	stmt_bind_result_field(stmt_AccountLoad, 3, DB::TYPE_INTEGER, 	alive);
	stmt_bind_result_field(stmt_AccountLoad, 4, DB::TYPE_INTEGER, 	regdate);
	stmt_bind_result_field(stmt_AccountLoad, 5, DB::TYPE_INTEGER, 	lastlog);
	stmt_bind_result_field(stmt_AccountLoad, 6, DB::TYPE_INTEGER, 	spawntime);
	stmt_bind_result_field(stmt_AccountLoad, 7,	DB::TYPE_INTEGER, 	spawns);
	stmt_bind_result_field(stmt_AccountLoad, 8, DB::TYPE_INTEGER, 	VIP);
	stmt_bind_result_field(stmt_AccountLoad, 9, DB::TYPE_INTEGER, 	active);

	if(!stmt_execute(stmt_AccountLoad))
		return Error(-1, "failed to execute statement stmt_AccountLoad");

	if(!stmt_fetch_row(stmt_AccountLoad))
		return Error(-1, "failed to fetch statement result stmt_AccountLoad");

	if(!active)
		return NoError(4);

	SetPlayerAliveState(playerid, alive);

	SetPlayerPassHash(playerid, password);
	SetPlayerRegTimestamp(playerid, regdate);
	SetPlayerLastLogin(playerid, lastlog);
	SetPlayerCreationTimestamp(playerid, spawntime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerVIP(playerid, VIP);

	if(gAutoLoginWithIP && GetPlayerIpAsInt(playerid) == ipv4)
		return NoError(2);

	CallLocalFunction("OnPlayerAccountLoaded", "d", playerid);

	return NoError(1);
}

Error:CreatePlayerAccount(playerid, const password[MAX_PASSWORD_LEN])
{
	new
		name[MAX_PLAYER_NAME],
		serial[MAX_GPCI_LEN];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, serial, MAX_GPCI_LEN);

	stmt_bind_value(stmt_AccountCreate, 0, DB::TYPE_STRING,		name, MAX_PLAYER_NAME); 
	stmt_bind_value(stmt_AccountCreate, 1, DB::TYPE_STRING,		password, MAX_PASSWORD_LEN); 
	stmt_bind_value(stmt_AccountCreate, 2, DB::TYPE_INTEGER,	GetPlayerIpAsInt(playerid)); 
	stmt_bind_value(stmt_AccountCreate, 3, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(stmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime()); 
	stmt_bind_value(stmt_AccountCreate, 5, DB::TYPE_STRING,		serial, MAX_GPCI_LEN); 

	if(!stmt_execute(stmt_AccountCreate))
	{
		KickPlayer(playerid, "An error occurred while executing statement 'stmt_AccountCreate'.");
		return Error(1, "failed to execute statement stmt_AccountCreate");
	}

	SetPlayerAimShoutText(playerid, "Largue sua Arma!");
	SetPlayerToolTips(playerid, true);
	SetPlayerRadioFrequency(playerid, 1.0); // Global chat by default
	
	PlayerCreateNewCharacter(playerid);
	DisplayLoginPrompt(playerid);

	CallLocalFunction("OnPlayerRegister", "d", playerid);

	return NoError(1);
}

stock DisplayRegisterPrompt(playerid)
{
	new str[150];
	format(str, 150, ls(playerid, "ACCREGIBODY"), playerid);

	Logger_Log("player is registering", Logger_P(playerid));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			if(!(4 <= strlen(inputtext) <= 32))
			{
				ChatMsgLang(playerid, YELLOW, "PASSWORDREQ");
				DisplayRegisterPrompt(playerid);
				return 0;
			}

			new passwordHash[MAX_PASSWORD_LEN];

			WP_Hash(passwordHash, MAX_PASSWORD_LEN, inputtext);

			CreatePlayerAccount(playerid, passwordHash);
			PromptPlayerToLinkAccount(playerid);
		}
		else
		{
			ChatMsgAll(GREY, " » %p saiu sem se registrar.", playerid);
			Kick(playerid);
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCREGITITL"), str, "Registrar", "Sair");

	return 1;
}

stock DisplayLoginPrompt(playerid, badpass = false)
{
	Logger_Log("player is logging in", Logger_P(playerid));
	CallLocalFunction("OnPlayerLoggingIn", "d", playerid);

	SetPlayerAccountState(playerid, ACCOUNT_STATE_LOGGINGIN);

	new dialogText[150];

	if(badpass)
		format(dialogText, 150, ls(playerid, "ACCLOGWROPW"), acc_LoginAttempts[playerid]);
	else
		format(dialogText, 150, ls(playerid, "ACCLOGIBODY"), playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			if(IsValidPassword(inputtext))
			{	
				new
					inputhash[MAX_PASSWORD_LEN],
					storedhash[MAX_PASSWORD_LEN];

				WP_Hash(inputhash, MAX_PASSWORD_LEN, inputtext);
				GetPlayerPassHash(playerid, storedhash);

				if(isequal(inputhash, storedhash)) // Password matches
					LoginPlayer(playerid);
				else
				{
					acc_LoginAttempts[playerid]++;

					if(acc_LoginAttempts[playerid] < 5)
						DisplayLoginPrompt(playerid, 1);
					else
					{
						ChatMsgAll(GREY, " » %p saiu sem fazer login.", playerid);
						Kick(playerid);
					}
				}
			}
			else
				DisplayLoginPrompt(playerid, true);
		}
		else
		{
			ChatMsgAll(GREY, " » %p saiu sem fazer login.", playerid);
			DisconnectPlayer(playerid);
		}

		return 1;
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCLOGITITL"), dialogText, "Entrar", "Sair");

	return 1;
}

stock bool:IsValidPassword(const password[])
{
	return true;
}

stock LoginPlayer(playerid)
{
	new serial[MAX_GPCI_LEN];
	gpci(playerid, serial, MAX_GPCI_LEN);

	Logger_Log("player logged in",
		Logger_P(playerid),
		Logger_S("gpci", serial),
		Logger_B("alive", IsPlayerAlive(playerid))
	);

	// TODO: move to a single query
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetIpv4);

	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, serial);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetGpci);

	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid))
	{
		new
			reports = GetUnreadReports(),
			issues = GetBugReports();

		ChatMsg(playerid, BLUE, " » Nível de Admin: %d", GetPlayerAdminLevel(playerid));

		if(reports)
			ChatMsg(playerid, YELLOW, " » %d relatórios por ler. Digite "C_BLUE"/reports", reports);

		if(issues)
			ChatMsg(playerid, YELLOW, " » %d Bugs reportados. Digite "C_BLUE"/bugs", issues);
	}

	acc_LoggedIn[playerid] = true;
	acc_LoginAttempts[playerid] = 0;

	SetPlayerRadioFrequency(playerid, 1.0); // Global chat by default
	SetPlayerBrightness(playerid, 255);

	SpawnLoggedInPlayer(playerid);

	CallLocalFunction("OnPlayerLogin", "d", playerid);
}


/*==============================================================================

	Logs the player out, saving their data and deleting their items.

==============================================================================*/

stock Logout(playerid, docombatlogcheck = 1)
{
	if(!acc_LoggedIn[playerid])
	{
		Logger_Log("player logged out",
			Logger_P(playerid),
			Logger_B("logged_in", false)
		);
		return 0;
	}
	
	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	Logger_Log("player logged out",
		Logger_P(playerid),
		Logger_F("x", x),
		Logger_F("y", y),
		Logger_F("z", z),
		Logger_F("r", r),
		Logger_B("logged_in", acc_LoggedIn[playerid]),
		Logger_B("alive", IsPlayerAlive(playerid)),
		Logger_B("knocked_out", IsPlayerKnockedOut(playerid))
	);

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("accounts", 1, "[LOGOUT] ERROR: Player on admin duty, aborting save.");
		return 0;
	}

	if(docombatlogcheck)
	{
		if(gServerMaxUptime - gServerUptime > 30)
		{
			new
				lastattacker,
				lastweapon;

			if(IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
			{
				Logger_Log("player combat-logged",
					Logger_P(playerid));

				ChatMsgAll(YELLOW, " » %p Deslogou em Combate esse Viado!", playerid);

				// TODO: make this correct, lastweapon is an item ID but
				// OnPlayerDeath takes a GTA weapon ID.
				CallLocalFunction("OnPlayerDeath", "ddd", playerid, lastattacker, lastweapon);
			}
		}
	}

	new
		Item:itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype))
	{
		new Container:containerid;
		GetItemExtraData(itemid, _:containerid);
		if(!IsContainerEmpty(containerid))
		{
			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - ITEM_FLOOR_OFFSET);
			itemid = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;
		}
	}

	if(IsItemTypeBag(itemtype))
	{
		if(!IsContainerEmpty(GetBagItemContainerID(itemid)))
		{
			if(IsValidItem(GetPlayerBagItem(playerid)))
			{
				CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - ITEM_FLOOR_OFFSET);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
			else
			{
				GivePlayerBag(playerid, itemid);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
		}
	}

	SavePlayerData(playerid);

	if(IsPlayerAlive(playerid))
	{
		DestroyItem(itemid);
		DestroyItem(GetPlayerHolsterItem(playerid));
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < MAX_INVENTORY_SLOTS; i++)
		{
			new Item:subitemid;
			GetInventorySlotItem(playerid, 0, subitemid);
			DestroyItem(subitemid);
		}

		if(IsValidItem(GetPlayerHatItem(playerid)))
			RemovePlayerHatItem(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid)))
			RemovePlayerMaskItem(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new
				vehicleid = GetPlayerLastVehicle(playerid),
				Float:health;

			GetVehicleHealth(vehicleid, health);

			if(IsVehicleUpsideDown(vehicleid) || health < 300.0)
				DestroyVehicle(vehicleid);
			else
			{
				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
					SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
			}

			UpdatePlayerVehicle(playerid, vehicleid);
		}
	}

	return 1;
}


/*==============================================================================

	Updates the database and calls the binary save functions if required.

==============================================================================*/

stock SavePlayerData(playerid)
{
	dbg("accounts", 1, "[SavePlayerData] Saving '%p'", playerid);

	if(!acc_LoggedIn[playerid])
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: Player isn't logged in");
		return 0;
	}

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: On admin duty");
		return 0;
	}

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	if(IsAtConnectionPos(x, y, z))
	{
		dbg("accounts", 1, "[SavePlayerData] ERROR: At connection pos");
		return 0;
	}

	SaveBlockAreaCheck(x, y, z);

	if(IsPlayerInAnyVehicle(playerid))
		x += 1.5;

	if(IsPlayerAlive(playerid) && !IsPlayerInTutorial(playerid))
	{
		dbg("accounts", 2, "[SavePlayerData] Player is alive");
		if(IsAtConnectionPos(x, y, z))
		{
			dbg("accounts", 2, "[SavePlayerData] ERROR: Player at default position");
			return 0;
		}

		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			dbg("accounts", 2, "[SavePlayerData] Player is spectating");
			if(!gServerRestarting)
			{
				dbg("accounts", 2, "[SavePlayerData] Server is not restarting, aborting save");
				return 0;
			}
		}

		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerVIP(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate))
			err(true, true, "Statement 'stmt_AccountUpdate' failed to execute.");

		dbg("accounts", 2, "[SavePlayerData] Saving character data");
		SavePlayerChar(playerid);
	}
	else
	{
		dbg("accounts", 2, "[SavePlayerData] Player is dead");
		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerVIP(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate))
			err(true, true, "Statement 'stmt_AccountUpdate' failed to execute.");
	}

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock GetAccountData(name[], pass[], &ipv4, &alive, &regdate, &lastlog, &spawntime, &totalspawns, &VIP, gpci[], &active)
{
	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, 1, 	DB::TYPE_STRING, 	pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, 2, 	DB::TYPE_INTEGER, 	ipv4);
	stmt_bind_result_field(stmt_AccountLoad, 3, 	DB::TYPE_INTEGER, 	alive);
	stmt_bind_result_field(stmt_AccountLoad, 4, 	DB::TYPE_INTEGER, 	regdate);
	stmt_bind_result_field(stmt_AccountLoad, 5, 	DB::TYPE_INTEGER, 	lastlog);
	stmt_bind_result_field(stmt_AccountLoad, 6, 	DB::TYPE_INTEGER, 	spawntime);
	stmt_bind_result_field(stmt_AccountLoad, 7, 	DB::TYPE_INTEGER, 	totalspawns);
	stmt_bind_result_field(stmt_AccountLoad, 8, 	DB::TYPE_INTEGER, 	VIP);
	stmt_bind_result_field(stmt_AccountLoad, 9, 	DB::TYPE_STRING, 	gpci, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_AccountLoad, 10, 	DB::TYPE_INTEGER, 	active);

	if(!stmt_execute(stmt_AccountLoad))
	{
		err(true, true, "[GetAccountData] executing statement 'stmt_AccountLoad'.");
		return 0;
	}

	stmt_fetch_row(stmt_AccountLoad);

	return 1;
}

stock DoesPlayerAccountExist(const accountName[])
{
	new exists;

	stmt_bind_value(stmt_AccountRegistered, 0, DB::TYPE_STRING, accountName, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountRegistered, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(stmt_AccountRegistered))
		stmt_fetch_row(stmt_AccountRegistered);

	return exists;
}

stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_result_field(stmt_AccountGetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountGetPassword, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetPassword))
		return 0;

	stmt_fetch_row(stmt_AccountGetPassword);

	return 1;
}

stock SetAccountPassword(const name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_value(stmt_AccountSetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountSetPassword, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetPassword);
}

stock GetAccountIP(const name[], &ip)
{
	stmt_bind_result_field(stmt_AccountGetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountGetIpv4, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetIpv4))
		return 0;

	stmt_fetch_row(stmt_AccountGetIpv4);

	return 1;
}

stock SetAccountIP(const name[], ip)
{
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetIpv4);
}

stock GetAccountAliveState(const name[], &alivestate)
{
	stmt_bind_result_field(stmt_AccountGetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountGetAliveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetAliveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliveState);

	return 1;
}

stock SetAccountAliveState(const name[], alivestate)
{
	stmt_bind_value(stmt_AccountSetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountSetAliveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetAliveState);
}

stock GetAccountRegistrationDate(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetRegdate, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetRegdate))
		return 0;

	stmt_fetch_row(stmt_AccountGetRegdate);

	return 1;
}

stock SetAccountRegistrationDate(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetRegdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetRegdate);
}

stock GetAccountLastLogin(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetLastLog, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetLastLog))
		return 0;

	stmt_fetch_row(stmt_AccountGetLastLog);

	return 1;
}

stock SetAccountLastLogin(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetLastLog);
}

stock GetAccountLastSpawnTimestamp(const name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetSpawnTime, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetSpawnTime))
		return 0;

	stmt_fetch_row(stmt_AccountGetSpawnTime);

	return 1;
}

stock SetAccountLastSpawnTimestamp(const name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetSpawnTime, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetSpawnTime);
}

stock GetAccountTotalSpawns(const name[], &spawns)
{
	stmt_bind_result_field(stmt_AccountGetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountGetTotalSpawns, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetTotalSpawns))
		return 0;

	stmt_fetch_row(stmt_AccountGetTotalSpawns);

	return 1;
}

stock SetAccountTotalSpawns(const name[], spawns)
{
	stmt_bind_value(stmt_AccountSetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountSetTotalSpawns, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetTotalSpawns);
}

stock GetAccountVIP(const name[], &VIP)
{
	stmt_bind_result_field(stmt_AccountGetVIP, 0, DB::TYPE_INTEGER, VIP);
	stmt_bind_value(stmt_AccountGetVIP, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetVIP))
		return 0;

	stmt_fetch_row(stmt_AccountGetVIP);

	return 1;
}

stock SetAccountVIP(const name[], VIP)
{
	stmt_bind_value(stmt_AccountSetVIP, 0, DB::TYPE_INTEGER, VIP);
	stmt_bind_value(stmt_AccountSetVIP, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetVIP);
}

// Get/Set Discord ID
stock GetAccountDiscordId(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new 
		playerName[MAX_PLAYER_NAME],
		discordId[DCC_ID_SIZE];

	GetPlayerName(playerid, playerName);

	stmt_bind_result_field(stmt_AccountGetDiscordId, 0, DB::TYPE_STRING, discordId, DCC_ID_SIZE);
	stmt_bind_value(stmt_AccountGetDiscordId, 0, DB::TYPE_STRING, playerName, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AccountGetDiscordId))
		stmt_fetch_row(stmt_AccountGetDiscordId);

	log(true, "GetAccountDiscordId - DiscordId: %s", discordId);

	return discordId;
}

stock SetPlayerAccountDiscordId(const name[], const discordid[DCC_ID_SIZE])
{
	stmt_bind_value(stmt_AccountSetDiscordId, 0, DB::TYPE_STRING, discordid, DCC_ID_SIZE);
	stmt_bind_value(stmt_AccountSetDiscordId, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AccountSetDiscordId))
		return 1;

	return 0;
}

stock DoesAccountHaveDiscord(const name[MAX_PLAYER_NAME])
{
	new
		does = -1;

	stmt_bind_result_field(stmt_AccountHaveDiscord, 0, DB::TYPE_INTEGER, does);
	stmt_bind_value(stmt_AccountHaveDiscord, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AccountHaveDiscord))
		stmt_fetch_row(stmt_AccountHaveDiscord);
	else
		err(false, true, ("[ACCOUNTS] Impossível executar stmt_AccountHaveDiscord"));

	log(true, "[ACCOUNTS] DoesAccountHaveDiscord - Player %s: %d", name, does);

	return does;
}

stock GetAccountGPCI(const name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_result_field(stmt_AccountGetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountGetGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetGpci))
		return 0;

	stmt_fetch_row(stmt_AccountGetGpci);

	return 1;
}

stock SetAccountGPCI(const name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetGpci);
}

stock GetAccountActiveState(const name[], &active)
{
	stmt_bind_result_field(stmt_AccountGetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountGetActiveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetActiveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetActiveState);

	return 1;
}

stock SetAccountActiveState(const name[], active)
{
	stmt_bind_value(stmt_AccountSetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountSetActiveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetActiveState);
}

// Pass, IP and gpci
stock GetAccountAliasData(const name[], pass[129], &ip, gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountGetAliasData, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_result_field(stmt_AccountGetAliasData, 2, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_AccountGetAliasData))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliasData);

	return 1;
}
