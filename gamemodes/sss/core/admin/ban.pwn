#include <YSI_Coding\y_hooks>

#define MAX_BAN_REASON (128)

static
DBStatement:	stmt_BanInsert,
DBStatement:	stmt_BanUnban,
DBStatement:	stmt_BanGetFromNameIp,
DBStatement:	stmt_BanNameCheck,
DBStatement:	stmt_BanGetList,
DBStatement:	stmt_BanGetTotal,
DBStatement:	stmt_BanGetInfo,
DBStatement:	stmt_BanUpdateInfo,
DBStatement:	stmt_BanSetIpv4,
DBStatement:	stmt_BanSetReason,
DBStatement:	stmt_BanSetDuration;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS Player (name TEXT, ipv4 INTEGER, date INTEGER, reason TEXT, by TEXT, duration INTEGER, active INTEGER)"));

	DatabaseTableCheck(gAccountsDatabase, "Bans", 7);

	stmt_BanInsert				= db_prepare(gAccountsDatabase, "INSERT INTO Player VALUES(?, ?, ?, ?, ?, ?, 1)");
	stmt_BanUnban				= db_prepare(gAccountsDatabase, "UPDATE Player SET active=0 WHERE name = ? COLLATE NOCASE");
	stmt_BanGetFromNameIp		= db_prepare(gAccountsDatabase, "SELECT COUNT(*), date, reason, duration FROM Player WHERE (name = ? COLLATE NOCASE OR ipv4 = ?) AND active=1 ORDER BY date DESC");
	stmt_BanNameCheck			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Player WHERE active=1 AND name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_BanGetList				= db_prepare(gAccountsDatabase, "SELECT * FROM Player WHERE active=1 ORDER BY date DESC LIMIT ?, ? COLLATE NOCASE");
	stmt_BanGetTotal			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Player WHERE active=1");
	stmt_BanGetInfo				= db_prepare(gAccountsDatabase, "SELECT * FROM Player WHERE name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_BanUpdateInfo			= db_prepare(gAccountsDatabase, "UPDATE Player SET reason = ?, duration = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetIpv4				= db_prepare(gAccountsDatabase, "UPDATE Player SET ipv4 = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetReason			= db_prepare(gAccountsDatabase, "UPDATE Player SET reason = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetDuration			= db_prepare(gAccountsDatabase, "UPDATE Player SET duration = ? WHERE name = ? COLLATE NOCASE");
}

BanPlayer(playerid, const reason[MAX_BAN_REASON], byid, duration)
{
	new name[MAX_PLAYER_NAME];

	if(byid == -1)
		name = "Sistema";
	else
		GetPlayerName(byid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanInsert))
	{
		new formattedReason[16+MAX_BAN_REASON];

		format(formattedReason, sizeof(formattedReason), "Banido. Razão: %s", reason);
		ChatMsgLang(playerid, YELLOW, "BANNEDMESSG", reason);
		KickPlayer(playerid, formattedReason);

		return 1;
	}

	return 0;
}

BanPlayerByName(const name[], const reason[], byid, duration)
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

	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_STRING, byname, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_BanInsert))
		return 0;

	return 1;
}

UpdateBanInfo(const name[], const reason[], duration)
{
	stmt_bind_value(stmt_BanUpdateInfo, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanUpdateInfo, 1, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanUpdateInfo, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUpdateInfo))
		return 1;
	
	return 0;
}

UnBanPlayer(const name[])
{
	if(!IsPlayerBanned(name))
		return 0;

	stmt_bind_value(stmt_BanUnban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUnban))
		return 1;

	return 0;
}

BanCheck(playerid)
{
	new
		banned,
		timestamp,
		reason[MAX_BAN_REASON],
		duration;

	stmt_bind_value(stmt_BanGetFromNameIp, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));

	stmt_bind_result_field(stmt_BanGetFromNameIp, 0, DB::TYPE_INTEGER, banned);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 3, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanGetFromNameIp))
	{
		stmt_fetch_row(stmt_BanGetFromNameIp);

		if(banned)
		{
			if(duration > 0)
			{
				if(gettime() > (timestamp + duration))
				{
					new name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, name, MAX_PLAYER_NAME);
					UnBanPlayer(name);

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

			stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
			stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
			stmt_execute(stmt_BanSetIpv4);

			KickPlayer(playerid, reason);

			return 1;
		}
	}

	return 0;
}


/*==============================================================================

	Interface functions

==============================================================================*/


forward external_BanPlayer(name[], reason[], duration);
public external_BanPlayer(name[], reason[], duration)
{
	BanPlayerByName(name, reason, -1, duration);
}

stock IsPlayerBanned(const name[])
{
	new count;

	stmt_bind_value(stmt_BanNameCheck, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanNameCheck, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_BanNameCheck))
	{
		stmt_fetch_row(stmt_BanNameCheck);

		if(count > 0)
			return 1;
	}

	return 0;
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset)
{
	new name[MAX_PLAYER_NAME];

	stmt_bind_value(stmt_BanGetList, 0, DB::TYPE_INTEGER, offset);
	stmt_bind_value(stmt_BanGetList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_result_field(stmt_BanGetList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_BanGetList))
		return -1;

	new idx;

	while(stmt_fetch_row(stmt_BanGetList))
	{
		string[idx] = name;
		idx++;
	}

	return idx;
}

stock GetTotalBans()
{
	new total;

	stmt_bind_result_field(stmt_BanGetTotal, 0, DB::TYPE_INTEGER, total);
	stmt_execute(stmt_BanGetTotal);
	stmt_fetch_row(stmt_BanGetTotal);

	return total;
}

stock GetBanInfo(const name[], &timestamp, reason[], bannedby[], &duration)
{
	stmt_bind_value(stmt_BanGetInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanGetInfo, 1, DB::TYPE_INTEGER, 	timestamp);
	stmt_bind_result_field(stmt_BanGetInfo, 2, DB::TYPE_STRING, 	reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetInfo, 3, DB::TYPE_STRING, 	bannedby, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanGetInfo, 4, DB::TYPE_INTEGER, 	duration);

	if(!stmt_execute(stmt_BanGetInfo))
		return 0;

	stmt_fetch_row(stmt_BanGetInfo);

	return 1;
}

stock SetBanIpv4(const name[], ipv4)
{
	stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, ipv4);
	stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetIpv4);
}

stock SetBanReason(const name[], reason[])
{
	stmt_bind_value(stmt_BanSetReason, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanSetReason, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetReason);
}

stock SetBanDuration(const name[], duration)
{
	stmt_bind_value(stmt_BanSetDuration, 0, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanSetDuration, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetDuration);
}