#include <YSI_Coding\y_hooks>

#define MAX_BAN_REASON (128)

static
DBStatement:	stmt_Ban,
DBStatement:	stmt_Unban,
DBStatement:	stmt_CheckBan,
DBStatement:	stmt_CheckBanByName,
DBStatement:	stmt_GetBanList,
DBStatement:	stmt_GetTotalBans,
DBStatement:	stmt_GetBanInfo,
DBStatement:	stmt_SetBanUpdate,
DBStatement:	stmt_SetBanIP,
DBStatement:	stmt_SetBanReason,
DBStatement:	stmt_SetBanDuration;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS Player (name TEXT, ipv4 INTEGER, date INTEGER, reason TEXT, by TEXT, duration INTEGER, active INTEGER)"));

	DatabaseTableCheck(gAccountsDatabase, "Bans", 7);

	stmt_Ban					= db_prepare(gAccountsDatabase, "INSERT INTO Bans VALUES(?, ?, ?, ?, ?, ?, 1)");
	stmt_Unban					= db_prepare(gAccountsDatabase, "UPDATE Bans SET active=0 WHERE name = ? COLLATE NOCASE");
	stmt_CheckBan				= db_prepare(gAccountsDatabase, "SELECT COUNT(*), date, reason, duration FROM Bans WHERE (name = ? COLLATE NOCASE OR ipv4 = ?) AND active=1 ORDER BY date DESC");
	stmt_CheckBanByName			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Bans WHERE active=1 AND name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_GetBanList				= db_prepare(gAccountsDatabase, "SELECT * FROM Bans WHERE active=1 ORDER BY date DESC LIMIT ?, ? COLLATE NOCASE");
	stmt_GetTotalBans			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Bans WHERE active=1");
	stmt_GetBanInfo				= db_prepare(gAccountsDatabase, "SELECT * FROM Bans WHERE name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_SetBanUpdate			= db_prepare(gAccountsDatabase, "UPDATE Bans SET reason = ?, duration = ? WHERE name = ? COLLATE NOCASE");
	stmt_SetBanIP				= db_prepare(gAccountsDatabase, "UPDATE Bans SET ipv4 = ? WHERE name = ? COLLATE NOCASE");
	stmt_SetBanReason			= db_prepare(gAccountsDatabase, "UPDATE Bans SET reason = ? WHERE name = ? COLLATE NOCASE");
	stmt_SetBanDuration			= db_prepare(gAccountsDatabase, "UPDATE Bans SET duration = ? WHERE name = ? COLLATE NOCASE");
}

stock BanPlayer(playerid, const reason[MAX_BAN_REASON], byid, duration)
{
	new name[MAX_PLAYER_NAME];

	if(byid == -1)
		name = "Sistema";
	else
		GetPlayerName(byid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_Ban, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_Ban, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_Ban, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_Ban, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_Ban, 4, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_Ban, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_Ban))
	{
		new formattedReason[16+MAX_BAN_REASON];

		ChatMsgLang(playerid, YELLOW, "BANNEDMESSG", reason);
		format(formattedReason, sizeof(formattedReason), "Banido. Razão: %s", reason);
		KickPlayer(playerid, formattedReason);

		return 1;
	}

	return 0;
}

stock BanAccount(const name[], const reason[], byid, duration)
{
	new
		forname[MAX_PLAYER_NAME],
		id = INVALID_PLAYER_ID,
		ip,
		byname[MAX_PLAYER_NAME];

	if(byid == -1)
		byname = "Sistema";
	else
		GetPlayerName(byid, byname, MAX_PLAYER_NAME);

	foreach(new i : Player)
	{
		GetPlayerName(i, forname, MAX_PLAYER_NAME);

		if(!strcmp(forname, name))
			id = i;
	}

	if(id == INVALID_PLAYER_ID)
		GetAccountIP(name, ip);
	else
	{
		new formattedReason[16+MAX_BAN_REASON];

		ip = GetPlayerIpAsInt(id);
		format(formattedReason, sizeof(formattedReason), "Banido. Razão: %s", reason);
		KickPlayer(id, formattedReason);
	}

	stmt_bind_value(stmt_Ban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_Ban, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_Ban, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_Ban, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_Ban, 4, DB::TYPE_STRING, byname, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_Ban, 5, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_Ban))
		return 0;

	return 1;
}

UpdateBanInfo(const name[], const reason[], duration)
{
	stmt_bind_value(stmt_SetBanUpdate, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_SetBanUpdate, 1, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_SetBanUpdate, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_SetBanUpdate))
		return 1;
	
	return 0;
}

UnbanAccount(const name[])
{
	if(!IsAccountBanned(name))
		return 0;

	stmt_bind_value(stmt_Unban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_Unban))
		return 1;

	return 0;
}

UnbanPlayer(playerid)
{
	new playerName[MAX_PLAYER_NAME];

	GetPlayerName(playerid, playerName);

	return UnbanAccount(playerName);
}

BanCheck(playerid)
{
	new
		banned,
		timestamp,
		reason[MAX_BAN_REASON],
		duration;

	stmt_bind_value(stmt_CheckBan, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_CheckBan, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));

	stmt_bind_result_field(stmt_CheckBan, 0, DB::TYPE_INTEGER, banned);
	stmt_bind_result_field(stmt_CheckBan, 1, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_CheckBan, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_CheckBan, 3, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_CheckBan))
	{
		stmt_fetch_row(stmt_CheckBan);

		if(banned)
		{
			if(duration > 0)
			{
				if(gettime() > (timestamp + duration))
				{
					new name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, name, MAX_PLAYER_NAME);
					UnbanAccount(name);

					ChatMsgLang(playerid, YELLOW, "BANLIFMESSG", TimestampToDateTime(timestamp));
					log(true, "[UNBAN] Ban lifted automatically for %s", name);

					return 0;
				}
			}

			new string[256];

			format(string, 256, "\
				"C_YELLOW"Data:\n\t\t"C_BLUE"%s\n\n\
				"C_YELLOW"Motivo:\n\t\t"C_BLUE"%s\n\n\
				"C_YELLOW"Data de Desban:\n\t\t"C_BLUE"%s",
				TimestampToDateTime(timestamp),
				reason,
				duration ? (TimestampToDateTime(timestamp + duration)) : "Nunca!");

			Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Banido", string, "Sair", "");

			stmt_bind_value(stmt_SetBanIP, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
			stmt_bind_value(stmt_SetBanIP, 1, DB::TYPE_PLAYER_NAME, playerid);
			stmt_execute(stmt_SetBanIP);

			KickPlayer(playerid, reason);

			return 1;
		}
	}

	return 0;
}

stock bool:IsAccountBanned(const accountName[MAX_PLAYER_NAME])
{
	new banned;

	stmt_bind_value(stmt_CheckBanByName, 0, DB::TYPE_STRING, accountName, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_CheckBanByName, 0, DB::TYPE_INTEGER, banned);

	if(stmt_execute(stmt_CheckBanByName))
		stmt_fetch_row(stmt_CheckBanByName);

	return banned ? true : false;
}

stock bool:IsPlayerBanned(playerid)
{
	new playerName[MAX_PLAYER_NAME];

	GetPlayerName(playerid, playerName);

	return IsAccountBanned(playerName);
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset)
{
	new name[MAX_PLAYER_NAME];

	stmt_bind_value(stmt_GetBanList, 0, DB::TYPE_INTEGER, offset);
	stmt_bind_value(stmt_GetBanList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_result_field(stmt_GetBanList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_GetBanList))
		return -1;

	new idx;

	while(stmt_fetch_row(stmt_GetBanList))
	{
		string[idx] = name;
		idx++;
	}

	return idx;
}

stock GetTotalBans()
{
	new total;

	stmt_bind_result_field(stmt_GetTotalBans, 0, DB::TYPE_INTEGER, total);
	stmt_execute(stmt_GetTotalBans);
	stmt_fetch_row(stmt_GetTotalBans);

	return total;
}

stock GetBanInfo(const name[], &timestamp, reason[], bannedby[], &duration)
{
	stmt_bind_value(stmt_GetBanInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GetBanInfo, 1, DB::TYPE_INTEGER, 	timestamp);
	stmt_bind_result_field(stmt_GetBanInfo, 2, DB::TYPE_STRING, 	reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_GetBanInfo, 3, DB::TYPE_STRING, 	bannedby, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GetBanInfo, 4, DB::TYPE_INTEGER, 	duration);

	if(!stmt_execute(stmt_GetBanInfo))
		return 0;

	stmt_fetch_row(stmt_GetBanInfo);

	return 1;
}

stock SetBanIpv4(const name[], ipv4)
{
	stmt_bind_value(stmt_SetBanIP, 0, DB::TYPE_INTEGER, ipv4);
	stmt_bind_value(stmt_SetBanIP, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_SetBanIP);
}

stock SetBanReason(const name[], reason[])
{
	stmt_bind_value(stmt_SetBanReason, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_SetBanReason, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_SetBanReason);
}

stock SetBanDuration(const name[], duration)
{
	stmt_bind_value(stmt_SetBanDuration, 0, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_SetBanDuration, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_SetBanDuration);
}