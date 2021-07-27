
#include <YSI_Coding\y_hooks>


#define MAX_GPCI_LOG_RESULTS	(32)

enum e_gpci_list_output_structure
{
	gpci_name[MAX_PLAYER_NAME],
	gpci_gpci[MAX_GPCI_LEN],
	gpci_date
}

static
DBStatement:	stmt_GpciInsert,
DBStatement:	stmt_GpciCheckName,
DBStatement:	stmt_GpciGetRecordsFromGpci,
DBStatement:	stmt_GpciGetRecordsFromName;


hook OnGameModeInit()
{
	db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS gpci_log (name TEXT, hash TEXT, date INTEGER)");

	DatabaseTableCheck(gAccountsDatabase, "gpci_log", 3);

	stmt_GpciInsert				= db_prepare(gAccountsDatabase, "INSERT INTO gpci_log VALUES(?,?,?)");
	stmt_GpciCheckName			= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM gpci_log WHERE name=? AND hash=?");
	stmt_GpciGetRecordsFromGpci	= db_prepare(gAccountsDatabase, "SELECT * FROM gpci_log WHERE hash=? ORDER BY date DESC");
	stmt_GpciGetRecordsFromName	= db_prepare(gAccountsDatabase, "SELECT * FROM gpci_log WHERE name=? COLLATE NOCASE ORDER BY date DESC");
}

hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		count;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	gpci(playerid, hash, MAX_GPCI_LEN);

	stmt_bind_result_field(stmt_GpciCheckName, 0, DB::TYPE_INTEGER, count);
	stmt_bind_value(stmt_GpciCheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_GpciCheckName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

	stmt_execute(stmt_GpciCheckName);

	stmt_fetch_row(stmt_GpciCheckName);

	if(!count)
	{
		stmt_bind_value(stmt_GpciInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_GpciInsert, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
		stmt_bind_value(stmt_GpciInsert, 2, DB::TYPE_INTEGER, gettime());

		if(!stmt_execute(stmt_GpciInsert))
			err(true, true, "Failed to execute statement 'stmt_GpciInsert'.");
	}

	return 1;
}

stock GetAccountGpciHistoryFromGpci(inputgpci[MAX_GPCI_LEN], output[][e_gpci_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_STRING, inputgpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_GpciGetRecordsFromGpci))
		return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromGpci) && count < max)
	{
		strcat(output[count][gpci_name], name, MAX_PLAYER_NAME);
		strcat(output[count][gpci_gpci], hash, MAX_GPCI_LEN);
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountGpciHistoryFromName(inputname[], output[][e_gpci_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_GpciGetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromName) && count < max)
	{
		strcat(output[count][gpci_name], name, MAX_PLAYER_NAME);
		strcat(output[count][gpci_gpci], hash, MAX_GPCI_LEN);
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

ShowAccountGpciHistoryFromGpci(playerid, hash[MAX_GPCI_LEN])
{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromGpci(hash, list, MAX_GPCI_LOG_RESULTS, count))
		return ChatMsg(playerid, YELLOW, " » Failed");

	if(!count)
		return ChatMsg(playerid, YELLOW, " » No results");

	for(new i; i < count; i++)
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

ShowAccountGpciHistoryFromName(playerid, name[])
{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromName(name, list, MAX_GPCI_LOG_RESULTS, count))
		return ChatMsg(playerid, YELLOW, " » Failed");

	if(!count)
		return ChatMsg(playerid, YELLOW, " » No results");

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}
