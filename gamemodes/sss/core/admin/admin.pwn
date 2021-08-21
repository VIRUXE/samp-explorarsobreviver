#include <YSI_Coding\y_hooks>


#define MAX_ADMIN_LEVELS			(7)

enum
{
	STAFF_LEVEL_NONE,
	STAFF_LEVEL_GAME_MASTER,
	STAFF_LEVEL_MODERATOR,
	STAFF_LEVEL_ADMINISTRATOR,
	STAFF_LEVEL_LEAD,
	STAFF_LEVEL_DEVELOPER,
	STAFF_LEVEL_SECRET
}

enum e_admin_data
{
	admin_Name[MAX_PLAYER_NAME],
	admin_Rank
}


static
				admin_Data[MAX_ADMIN][e_admin_data],
				admin_Total,
				admin_Names[MAX_ADMIN_LEVELS][15] =
				{
					"Jogador",			// 0 (Unused)
					"Ajudante",			// 1
					"Moderador",		// 2
					"Administrador",	// 3
					"Gerente",			// 4
					"Programador",		// 5
					""					// 6
				},
				admin_Colours[MAX_ADMIN_LEVELS] =
				{
					0xFFFFFFFF,			// 0 (Unused)
					0x5DFC0AFF,			// 1
					0x33CCFFFF,			// 2
					0x6600FFFF,			// 3
					0xFF0000FF,			// 4
					0xFF3200FF,			// 5
					0x00000000			// 6
				},
				admin_Commands[4][512],
DBStatement:	stmt_AdminLoadAll,
DBStatement:	stmt_AdminExists,
DBStatement:	stmt_AdminInsert,
DBStatement:	stmt_AdminUpdate,
DBStatement:	stmt_AdminDelete,
DBStatement:	stmt_AdminGetLevel;

static
				admin_Level[MAX_PLAYERS],
				admin_OnDuty[MAX_PLAYERS],
				admin_DutyTick[MAX_PLAYERS],
				admin_PlayerKicked[MAX_PLAYERS];


hook OnScriptInit()
{
	db_free_result(db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS Admins (name TEXT, level INTEGER)"));

	DatabaseTableCheck(gAccountsDatabase, "Admins", 2);

	stmt_AdminLoadAll	= db_prepare(gAccountsDatabase, "SELECT * FROM Admins ORDER BY level DESC");
	stmt_AdminExists	= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Admins WHERE name = ?");
	stmt_AdminInsert	= db_prepare(gAccountsDatabase, "INSERT INTO Admins VALUES(?, ?)");
	stmt_AdminUpdate	= db_prepare(gAccountsDatabase, "UPDATE Admins SET level = ? WHERE name = ?");
	stmt_AdminDelete	= db_prepare(gAccountsDatabase, "DELETE FROM Admins WHERE name = ?");
	stmt_AdminGetLevel	= db_prepare(gAccountsDatabase, "SELECT * FROM Admins WHERE name = ?");

	LoadAdminData();
}

hook OnPlayerConnect(playerid)
{
	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;
	return 1;
}

hook OnPlayerDisconnected(playerid)
{
	admin_Level[playerid] = 0;
	admin_OnDuty[playerid] = 0;
	admin_PlayerKicked[playerid] = 0;
}

hook OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(GetPlayerAdminLevel(playerid) >= STAFF_LEVEL_MODERATOR && playerid != clickedplayerid)
	{	
		if(GetPlayerState(clickedplayerid) == PLAYER_STATE_SPECTATING && IsPlayerOnAdminDuty(clickedplayerid))
			return 0;

		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
			ExitSpectateMode(playerid);

		if(TogglePlayerAdminDuty(playerid, true))
		{
			TeleportPlayerToPlayer(playerid, clickedplayerid);

			SetPlayerChatMode(playerid, 0);
			ChatMsg(playerid, YELLOW, " » Você teleportou para %P", clickedplayerid);
			ChatMsgLang(clickedplayerid, YELLOW, "TELEPORTEDT", playerid);
		}
		else
			ChatMsg(playerid, RED, " » Aguarde para teleportar novamente.");
	}

    return 0;
}

/*==============================================================================

	Core

==============================================================================*/


LoadAdminData()
{
	new
		name[MAX_PLAYER_NAME],
		level;

	stmt_bind_result_field(stmt_AdminLoadAll, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AdminLoadAll, 1, DB::TYPE_INTEGER, level);

	if(stmt_execute(stmt_AdminLoadAll))
	{
		while(stmt_fetch_row(stmt_AdminLoadAll))
		{
			if(level > 0 && !isnull(name))
			{
				admin_Data[admin_Total][admin_Name] = name;
				admin_Data[admin_Total][admin_Rank] = level;

				admin_Total++;
			}
			else
				RemoveAdminFromDatabase(name);
		}
	}

	SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);
}

UpdateAdmin(const name[MAX_PLAYER_NAME], level)
{
	if(level == 0)
		return RemoveAdminFromDatabase(name);

	new count;

	stmt_bind_value(stmt_AdminExists, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_AdminExists);
	stmt_fetch_row(stmt_AdminExists);

	if(count == 0)
	{
		stmt_bind_value(stmt_AdminInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_AdminInsert, 1, DB::TYPE_INTEGER, level);

		if(stmt_execute(stmt_AdminInsert))
		{
			admin_Data[admin_Total][admin_Name] = name;
			admin_Data[admin_Total][admin_Rank] = level;
			admin_Total++;

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}
	else
	{
		stmt_bind_value(stmt_AdminUpdate, 0, DB::TYPE_INTEGER, level);
		stmt_bind_value(stmt_AdminUpdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

		if(stmt_execute(stmt_AdminUpdate))
		{
			for(new i; i < admin_Total; i++)
			{
				if(!strcmp(name, admin_Data[i][admin_Name]))
				{
					admin_Data[i][admin_Rank] = level;

					break;
				}
			}

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}

	return 1;
}

RemoveAdminFromDatabase(const name[])
{
	stmt_bind_value(stmt_AdminDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AdminDelete))
	{
		new bool:found = false;

		for(new i; i < admin_Total; i++)
		{
			if(!strcmp(name, admin_Data[i][admin_Name]))
				found = true;

			if(found && i < MAX_ADMIN-1)
			{
				format(admin_Data[i][admin_Name], 24, admin_Data[i+1][admin_Name]);
				admin_Data[i][admin_Rank] = admin_Data[i+1][admin_Rank];
			}
		}

		admin_Total--;

		return 1;
	}

	return 0;
}

CheckAdminLevel(playerid)
{
	new name[MAX_PLAYER_NAME];

	for(new i; i < admin_Total; i++)
	{
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		if(!strcmp(name, admin_Data[i][admin_Name]))
		{
			admin_Level[playerid] = admin_Data[i][admin_Rank];
			break;
		}
	}
}

TimeoutPlayer(playerid, const reason[])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(admin_PlayerKicked[playerid])
		return 0;

	new ip[16];

	GetPlayerIp(playerid, ip, sizeof(ip));

	BlockIpAddress(ip, 11500);
	admin_PlayerKicked[playerid] = true;

	log(true, "[PART] %p (timeout: %s)",playerid, reason);

	ChatMsgAdmins(1, GREY, " » %P"C_GREY" foi timeout. Motivo: "C_BLUE"%s", playerid, reason);

	return 1;
}

KickPlayer(playerid, const reason[], bool:tellplayer = true)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(admin_PlayerKicked[playerid])
		return 0;

	SetPlayerBrightness(playerid, 255);
	
	defer KickPlayerDelay(playerid);
	admin_PlayerKicked[playerid] = true;

	log(true, "[PART] %p (kick: %s)",playerid, reason);

	ChatMsgAdmins(1, GREY, " » %P"C_GREY" foi Kickado. Motivo: "C_BLUE"%s", playerid, reason);

	if(tellplayer)
		ChatMsgLang(playerid, GREY, "KICKMESSAGE", reason);
		
	return 1;
}

timer KickPlayerDelay[1000](playerid)
{
	Kick(playerid);
	admin_PlayerKicked[playerid] = false;
}

ChatMsgAdminsFlat(level, colour, const message[])
{
	if(level == 0)
	{
		err(false, false, "MsgAdmins parameter 'level' cannot be 0");
		return 0;
	}

	if(strlen(message) > 127)
	{
		new
			string1[128],
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(message[c] == ' ' || message[c] ==  ',' || message[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string1, message, splitpos);
		strcat(string2, message[splitpos]);

		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, string1);
			SendClientMessage(i, colour, string2);
		}
	}
	else
	{
		foreach(new i : Player)
		{
			if(admin_Level[i] < level)
				continue;

			SendClientMessage(i, colour, message);
		}
	}

	return 1;
}

TogglePlayerAdminDuty(playerid, toggle, goback = true)
{
	if(GetTickCountDifference(GetTickCount(), admin_DutyTick[playerid]) < 1500)
		return 0;

	if(toggle && !admin_OnDuty[playerid])
	{
		new
			Item:itemid,
			ItemType:itemtype,
			Float:x, Float:y, Float:z;
		
		GetPlayerPos(playerid, x, y, z);
		SetPlayerSpawnPos(playerid, x, y, z);

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		// Pousar Item no chão se for uma Caixa ou Mochila
		if(IsItemTypeSafebox(itemtype) || IsItemTypeBag(itemtype))
			CreateItemInWorld(itemid, x, y, z - ITEM_FLOOR_OFFSET);

		Logout(playerid, (GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER) ); // docombatlogcheck for admins level < 5

		RemovePlayerArmourItem(playerid);

		RemoveAllDrugs(playerid);

		SetPlayerSkin(playerid, GetPlayerGender(playerid) == GENDER_MALE ? 217 : 211);

		// Mostrar a todos os Jogadores que o Admin está em serviço
		SetPlayerScore(playerid, 0);
		SetPlayerColor(playerid, COLOR_PLAYER_ADMIN); // 

		admin_OnDuty[playerid] = true;
	}
	else if(!toggle && admin_OnDuty[playerid])
	{
		admin_OnDuty[playerid] = false;

		if(goback)
		{
			new Float:x, Float:y, Float:z;

			GetPlayerSpawnPos(playerid, x, y, z);
			SetPlayerPos(playerid, x, y, z);
		}

		ToggleNameTagsForPlayer(playerid, false);

		LoadPlayerChar(playerid);

		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));

		SetPlayerColor(playerid, !IsPlayerMobile(playerid) ? COLOR_PLAYER_NORMAL : COLOR_PLAYER_MOBILE); // 
	}

	admin_DutyTick[playerid] = GetTickCount();
	
	return 1;
}


/*==============================================================================

	Interface

==============================================================================*/


stock SetPlayerAdminLevel(playerid, level)
{
	if(!(0 <= level < MAX_ADMIN_LEVELS))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	admin_Level[playerid] = level;

	UpdateAdmin(name, level);

	return 1;
}

stock GetPlayerAdminLevel(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return admin_Level[playerid];
}

stock GetAdminLevelByName(const name[MAX_PLAYER_NAME])
{
	new level;

	stmt_bind_value(stmt_AdminGetLevel, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminGetLevel, 1, DB::TYPE_INTEGER, level);
	stmt_execute(stmt_AdminGetLevel);
	stmt_fetch_row(stmt_AdminGetLevel);

	return level;
}

stock GetAdminTotal()
{
	return admin_Total;
}

stock GetAdminsOnline(from = 1, to = 5)
{
	new count;

	foreach(new i : Player)
	{
		if(from <= admin_Level[i] <= to)
			count++;
	}

	return count;
}

stock GetAdminRankName(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Names[0];

	return admin_Names[rank];
}

stock GetAdminRankColour(rank)
{
	if(!(0 < rank < MAX_ADMIN_LEVELS))
		return admin_Colours[0];

	return admin_Colours[rank];
}

stock IsPlayerOnAdminDuty(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return admin_OnDuty[playerid];
}

stock RegisterAdminCommand(level, const string[])
{
	if(!(STAFF_LEVEL_GAME_MASTER <= level <= STAFF_LEVEL_LEAD))
	{
		err(false, false, "Cannot register admin command for level %d", level);
		return 0;
	}

	strcat(admin_Commands[level - 1], string);

	return 1;
}


/*==============================================================================

	Commands

==============================================================================*/


ACMD:acmds[1](playerid, params[])
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "/a [mensagem] - Chat de Administração");

	if(admin_Level[playerid] >= 4)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Gerente (Nível 4)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[3]);
	}
	if(admin_Level[playerid] >= 3)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Administrador (Nível 3)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[2]);
	}
	if(admin_Level[playerid] >= 2)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Moderador (Nível 2)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[1]);
	}
	if(admin_Level[playerid] >= 1)
	{
		strcat(gBigString[playerid], "\n\n"C_YELLOW"Ajudante (Nível 1)"C_BLUE"\n");
		strcat(gBigString[playerid], admin_Commands[0]);
	}
	
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Comandos de Administração", gBigString[playerid], "Sair", "");

	return 1;
}

ACMD:adminlist[3](playerid, params[])
{
	new
		title[20],
		line[52];

	gBigString[playerid][0] = EOS;

	format(title, 20, "Equipe Admin (%d)", admin_Total);

	for(new i; i < admin_Total; i++)
	{
		if(admin_Data[i][admin_Rank] == STAFF_LEVEL_SECRET)
			continue;

		format(line, sizeof(line), "%s %C(%d-%s)\n",
			admin_Data[i][admin_Name],
			admin_Colours[admin_Data[i][admin_Rank]],
			admin_Data[i][admin_Rank],
			admin_Names[admin_Data[i][admin_Rank]]);

		if(GetPlayerIdByName(admin_Data[i][admin_Name]) != INVALID_PLAYER_ID)
			strcat(gBigString[playerid], " » ");

		strcat(gBigString[playerid], line);
	}

	Dialog_Show(playerid, DIALOG_STYLE_LIST, title, gBigString[playerid], "Sair", "");

	return 1;
}