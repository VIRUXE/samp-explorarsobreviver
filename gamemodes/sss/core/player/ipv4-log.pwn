
#include <YSI_Coding\y_hooks>


#define MAX_IPV4_LOG_RESULTS	(32)

enum e_ipv4_list_output_structure
{
	ipv4_name[MAX_PLAYER_NAME],
	ipv4_ipv4,
	ipv4_date
}


static
DBStatement:	stmt_Ipv4Insert,
DBStatement:	stmt_Ipv4CheckName,
DBStatement:	stmt_Ipv4GetRecordsFromIP,
DBStatement:	stmt_Ipv4GetRecordsFromName;


hook OnGameModeInit()
{
	db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS ipv4_log (name TEXT, ipv4 INTEGER, date INTEGER)");

	DatabaseTableCheck(gAccountsDatabase, "ipv4_log", 3);

	stmt_Ipv4Insert				= db_prepare(gAccountsDatabase, "INSERT INTO ipv4_log VALUES(?,?,?)");
	stmt_Ipv4CheckName			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM ipv4_log WHERE name=? AND ipv4=?");
	stmt_Ipv4GetRecordsFromIP	= db_prepare(gAccountsDatabase, "SELECT * FROM ipv4_log WHERE ipv4=? ORDER BY date DESC");
	stmt_Ipv4GetRecordsFromName	= db_prepare(gAccountsDatabase, "SELECT * FROM ipv4_log WHERE name=? COLLATE NOCASE ORDER BY date DESC");
}

hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		ipstring[16],
		ipbyte[4],
		ip,
		count;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ip = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	stmt_bind_result_field(stmt_Ipv4CheckName, 0, DB::TYPE_INTEGER, count);
	stmt_bind_value(stmt_Ipv4CheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_Ipv4CheckName, 1, DB::TYPE_INTEGER, ip);

	stmt_execute(stmt_Ipv4CheckName);

	stmt_fetch_row(stmt_Ipv4CheckName);

	if(!count)
	{
		stmt_bind_value(stmt_Ipv4Insert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_Ipv4Insert, 1, DB::TYPE_INTEGER, ip);
		stmt_bind_value(stmt_Ipv4Insert, 2, DB::TYPE_INTEGER, gettime());

		if(!stmt_execute(stmt_Ipv4Insert))
			err(false, false, "Failed to execute statement 'stmt_Ipv4Insert'.");
	}

	return 1;
}

stock GetAccountIPHistoryFromIP(inputipv4, output[][e_ipv4_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		ipv4,
		date;

	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 1, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromIP, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_Ipv4GetRecordsFromIP, 0, DB::TYPE_INTEGER, inputipv4);

	if(!stmt_execute(stmt_Ipv4GetRecordsFromIP))
		return 0;

	while(stmt_fetch_row(stmt_Ipv4GetRecordsFromIP) && count < max)
	{
		output[count][ipv4_name] = name;
		output[count][ipv4_ipv4] = ipv4;
		output[count][ipv4_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountIPHistoryFromName(inputname[], output[][e_ipv4_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		ipv4,
		date;

	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 1, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_Ipv4GetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_Ipv4GetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_Ipv4GetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_Ipv4GetRecordsFromName) && count < max)
	{
		output[count][ipv4_name] = name;
		output[count][ipv4_ipv4] = ipv4;
		output[count][ipv4_date] = date;

		count++;
	}

	return 1;
}

ShowAccountIPHistoryFromIP(playerid, ip)
{
	new
		list[MAX_IPV4_LOG_RESULTS][e_ipv4_list_output_structure],
		newlist[MAX_IPV4_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountIPHistoryFromIP(ip, list, MAX_IPV4_LOG_RESULTS, count))
		return ChatMsg(playerid, YELLOW, " » Failed");

	if(!count)
		return ChatMsg(playerid, YELLOW, " » No results");

	for(new i; i < count; i++)
		strcat(newlist[i], list[i][ipv4_name], MAX_PLAYER_NAME);

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

ShowAccountIPHistoryFromName(playerid, name[])
{
	new
		list[MAX_IPV4_LOG_RESULTS][e_ipv4_list_output_structure],
		newlist[MAX_IPV4_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountIPHistoryFromName(name, list, MAX_IPV4_LOG_RESULTS, count))
		return ChatMsg(playerid, YELLOW, " » Failed");

	if(!count)
		return ChatMsg(playerid, YELLOW, " » No results");

	for(new i; i < count; i++)
		strcat(newlist[i], list[i][ipv4_name], MAX_PLAYER_NAME);

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}