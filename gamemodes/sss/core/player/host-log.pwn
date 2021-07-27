#include <YSI_Coding\y_hooks>


enum e_host_list_output_structure
{
	host_name[MAX_PLAYER_NAME],
	host_host[MAX_HOST_LEN],
	host_date
}


static
				JoinResolve[MAX_PLAYERS],
				SendingRequest[MAX_PLAYERS],

DBStatement:	stmt_HostInsert,
DBStatement:	stmt_HostCheckName,
DBStatement:	stmt_HostGetRecordsFromHost,
DBStatement:	stmt_HostGetRecordsFromName;


hook OnGameModeInit()
{
	db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS host_log (name TEXT, host TEXT, date INTEGER)");

	DatabaseTableCheck(gAccountsDatabase, "host_log", 3);

	stmt_HostInsert				= db_prepare(gAccountsDatabase, "INSERT INTO host_log VALUES(?,?,?)");
	stmt_HostCheckName			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM host_log WHERE name=? AND host=?");
	stmt_HostGetRecordsFromHost	= db_prepare(gAccountsDatabase, "SELECT * FROM host_log WHERE host=?");
	stmt_HostGetRecordsFromName	= db_prepare(gAccountsDatabase, "SELECT * FROM host_log WHERE name=? COLLATE NOCASE");
}

hook OnPlayerConnect(playerid)
{
	JoinResolve[playerid] = true;
	GetPlayerHost(playerid);
}

stock GetAccountHostHistoryFromHost(inputhost[], output[][e_host_list_output_structure], &count)
{
	new
		name[MAX_PLAYER_NAME],
		host,
		date;

	stmt_bind_result_field(stmt_HostGetRecordsFromHost, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_HostGetRecordsFromHost, 1, DB::TYPE_STRING, host, MAX_HOST_LEN);
	stmt_bind_result_field(stmt_HostGetRecordsFromHost, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_HostGetRecordsFromHost, 0, DB::TYPE_STRING, inputhost, MAX_HOST_LEN);

	if(!stmt_execute(stmt_HostGetRecordsFromHost))
		return 0;

	while(stmt_fetch_row(stmt_HostGetRecordsFromHost))
	{
		output[count][host_name] = name;
		output[count][host_host] = host;
		output[count][host_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountHostHistoryFromName(inputname[], output[][e_host_list_output_structure], &count)
{
	new
		name[MAX_PLAYER_NAME],
		host[MAX_HOST_LEN],
		date;

	stmt_bind_result_field(stmt_HostGetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_HostGetRecordsFromName, 1, DB::TYPE_STRING, host, MAX_HOST_LEN);
	stmt_bind_result_field(stmt_HostGetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_HostGetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_HostGetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_HostGetRecordsFromName))
	{
		output[count][host_name] = name;
		output[count][host_host] = host;
		output[count][host_date] = date;

		count++;
	}

	return 1;
}

ACMD:hhh[4](playerid, params[])
{
	if(SendingRequest[playerid])
	{
		Msg(playerid, YELLOW, " » Still waiting on active request.");
		return 1;
	}

	new ip;

	GetAccountIP(params, ip);

	MsgF(playerid, YELLOW, " » Running DNS resolve for '%s'", IpIntToStr(ip));

	rdns(IpIntToStr(ip), playerid);

	SendingRequest[playerid] = true;

	return 1;	
}

ACMD:hhname[4](playerid, params[])
{
	if(SendingRequest[playerid])
	{
		Msg(playerid, YELLOW, " » Still waiting on active request.");
		return 1;
	}

	new
		list[48][e_host_list_output_structure],
		count;

	if(!GetAccountHostHistoryFromName(params, list, count))
	{
		Msg(playerid, YELLOW, " » Failed");
		return 1;
	}

	if(!count)
	{
		Msg(playerid, YELLOW, " » No results");
		return 1;
	}

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
	{
		format(gBigString[playerid], sizeof(gBigString[]), "%s%s: %s (%s)\n",
			gBigString[playerid],
			list[i][host_name],
			list[i][host_host],
			TimestampToDateTime(list[i][host_date], "%x"));
	}

	ShowPlayerDialog(playerid, 0, DIALOG_STYLE_LIST, params, gBigString[playerid], "Sair", "");

	return 1;	
}

public OnReverseDNS(ip[], host[], extra)
{
	if(!IsPlayerConnected(extra))
		return 0;

	if(JoinResolve[extra])
	{
		JoinResolve[extra] = false;

		new
			name[MAX_PLAYER_NAME],
			count;

		GetPlayerName(extra, name, MAX_PLAYER_NAME);

		stmt_bind_result_field(stmt_HostCheckName, 0, DB::TYPE_INTEGER, count);
		stmt_bind_value(stmt_HostCheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_HostCheckName, 1, DB::TYPE_STRING, host, MAX_HOST_LEN);

		stmt_execute(stmt_HostCheckName);

		stmt_fetch_row(stmt_HostCheckName);

		if(!count)
		{
			stmt_bind_value(stmt_HostInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
			stmt_bind_value(stmt_HostInsert, 1, DB::TYPE_STRING, host, MAX_HOST_LEN);
			stmt_bind_value(stmt_HostInsert, 2, DB::TYPE_INTEGER, gettime());

			if(!stmt_execute(stmt_HostInsert))
				err(false, false, "Failed to execute statement 'stmt_HostInsert'.");
		}
	}

	if(SendingRequest[extra])
	{
		SendingRequest[extra] = false;

		new
			list[48][e_host_list_output_structure],
			count;

		if(!GetAccountHostHistoryFromHost(host, list, count))
		{
			Msg(extra, YELLOW, " » Failed");
			return 1;
		}

		if(!count)
		{
			Msg(extra, YELLOW, " » No results");
			return 1;
		}

		gBigString[extra][0] = EOS;

		for(new i; i < count; i++)
		{
			format(gBigString[extra], sizeof(gBigString[]), "%s%s: %s (%s)\n",
				gBigString[extra],
				list[i][host_name],
				list[i][host_host],
				TimestampToDateTime(list[i][host_date], "%x"));
		}

		ShowPlayerDialog(extra, 0, DIALOG_STYLE_LIST, host, gBigString[extra], "Sair", "");
	}

	return 1;
}