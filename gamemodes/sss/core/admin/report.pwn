
#include <YSI_Coding\y_hooks>


#define MAX_REPORT_REASON_LENGTH	128
#define MAX_REPORT_TYPE_LENGTH		10
#define MAX_REPORT_INFO_LENGTH		128
#define MAX_REPORTS_PER_PAGE		32
#define MAX_REPORT_TYPES			5

// Report types
#define REPORT_TYPE_PLAYER_ID		"PLY ID"
#define REPORT_TYPE_PLAYER_NAME		"PLY NAME"
#define REPORT_TYPE_PLAYER_CLOSE	"PLY CLOSE"
#define REPORT_TYPE_PLAYER_KILLER	"PLY KILL"
#define REPORT_TYPE_TELEPORT		"TELE"
#define REPORT_TYPE_SWIMFLY			"FLY"
#define REPORT_TYPE_VHEALTH			"VHP"
#define REPORT_TYPE_CAMDIST			"CAM"
#define REPORT_TYPE_CARNITRO		"NOS"
#define REPORT_TYPE_CARHYDRO		"HYDRO"
#define REPORT_TYPE_CARTELE			"VTP"
#define REPORT_TYPE_HACKTRAP		"TRAP"
#define REPORT_TYPE_LOCKEDCAR		"LCAR"
#define REPORT_TYPE_AMMO			"AMMO"
#define REPORT_TYPE_SHOTANIM		"ANIM"
#define REPORT_TYPE_BADHITOFFSET	"BHIT"
#define REPORT_TYPE_BAD_SHOT_WEAP	"BSHT"

enum e_report_list_struct
{
	report_name[MAX_PLAYER_NAME],
	report_type[MAX_REPORT_TYPE_LENGTH],
	report_read,
	report_rowid
}

static
DBStatement:	stmt_ReportInsert,
DBStatement:	stmt_ReportDelete,
DBStatement:	stmt_ReportDeleteName,
DBStatement:	stmt_ReportDeleteRead,
DBStatement:	stmt_ReportNameExists,
DBStatement:	stmt_ReportList,
DBStatement:	stmt_ReportInfo,
DBStatement:	stmt_ReportSetRead,
DBStatement:	stmt_ReportGetUnread;


/*==============================================================================

	Initialisation

==============================================================================*/


hook OnGameModeInit()
{
	db_query(gAccountsDatabase, "CREATE TABLE IF NOT EXISTS Reports (name TEXT, reason TEXT, date INTEGER, read INTEGER, type TEXT, posx REAL, posy REAL, posz REAL, world INTEGER, interior INTEGER, info TEXT, by TEXT, active INTEGER)");

	DatabaseTableCheck(gAccountsDatabase, "Reports", 13);

	stmt_ReportInsert		= db_prepare(gAccountsDatabase, "INSERT INTO Reports VALUES(?, ?, ?, '0', ?, ?, ?, ?, ?, ?, ?, ?, 1)");
	stmt_ReportDelete		= db_prepare(gAccountsDatabase, "UPDATE Reports SET active=0, read=1 WHERE rowid = ?");
	stmt_ReportDeleteName	= db_prepare(gAccountsDatabase, "UPDATE Reports SET active=0, read=1 WHERE name = ?");
	stmt_ReportDeleteRead	= db_prepare(gAccountsDatabase, "UPDATE Reports SET active=0, read=1 WHERE read = 1");
	stmt_ReportNameExists	= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Reports WHERE name = ?");
	stmt_ReportList			= db_prepare(gAccountsDatabase, "SELECT name, read, type, rowid FROM Reports WHERE active=1");
	stmt_ReportInfo			= db_prepare(gAccountsDatabase, "SELECT * FROM Reports WHERE rowid = ?");
	stmt_ReportSetRead		= db_prepare(gAccountsDatabase, "UPDATE Reports SET read = ? WHERE rowid = ?");
	stmt_ReportGetUnread	= db_prepare(gAccountsDatabase, "SELECT COUNT(*) FROM Reports WHERE read = 0");
}


/*==============================================================================

	Core

==============================================================================*/


ReportPlayer(const name[], const reason[], reporter, const type[], Float:posx, Float:posy, Float:posz, world, interior, const infostring[])
{
	new reportername[MAX_PLAYER_NAME];

	if(reporter == -1)
	{
		ChatMsgAdmins(1, YELLOW, " » Server reported %s, reason: %s", name, reason);
		reportername = "Server";
	}
	else
	{
		ChatMsgAdmins(1, YELLOW, " » %p reported %s, reason: %s", reporter, name, reason);
		GetPlayerName(reporter, reportername, MAX_PLAYER_NAME);
	}

	stmt_bind_value(stmt_ReportInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_ReportInsert, 1, DB::TYPE_STRING, reason, MAX_REPORT_REASON_LENGTH);
	stmt_bind_value(stmt_ReportInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_ReportInsert, 3, DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH);
	stmt_bind_value(stmt_ReportInsert, 4, DB::TYPE_FLOAT, posx);
	stmt_bind_value(stmt_ReportInsert, 5, DB::TYPE_FLOAT, posy);
	stmt_bind_value(stmt_ReportInsert, 6, DB::TYPE_FLOAT, posz);
	stmt_bind_value(stmt_ReportInsert, 7, DB::TYPE_INTEGER, world);
	stmt_bind_value(stmt_ReportInsert, 8, DB::TYPE_INTEGER, interior);
	stmt_bind_value(stmt_ReportInsert, 9, DB::TYPE_STRING, infostring, MAX_REPORT_INFO_LENGTH);
	stmt_bind_value(stmt_ReportInsert, 10, DB::TYPE_STRING, reportername, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_ReportInsert))
	{
		return 1;
	}

	return 0;
}

DeleteReport(rowid)
{
	stmt_bind_value(stmt_ReportDelete, 0, DB::TYPE_INTEGER, rowid);

	return stmt_execute(stmt_ReportDelete);
}

DeleteReportsOfPlayer(name[])
{
	stmt_bind_value(stmt_ReportDeleteName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_ReportDeleteName);
}

DeleteReadReports()
{
	return stmt_execute(stmt_ReportDeleteRead);
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetReportList(list[][e_report_list_struct])
{
	new
		name[MAX_PLAYER_NAME],
		type[MAX_REPORT_TYPE_LENGTH],
		read,
		rowid,
		idx;

	stmt_bind_result_field(stmt_ReportList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_ReportList, 1, DB::TYPE_INTEGER, read);
	stmt_bind_result_field(stmt_ReportList, 2, DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH);
	stmt_bind_result_field(stmt_ReportList, 3, DB::TYPE_INTEGER, rowid);

	if(!stmt_execute(stmt_ReportList))
		return 0;

	while(stmt_fetch_row(stmt_ReportList))
	{
		list[idx][report_name] = name;
		list[idx][report_type] = type;
		list[idx][report_read] = read;
		list[idx][report_rowid] = rowid;
		idx++;
	}

	return idx;
}

stock GetReportInfo(rowid, reason[], &date, type[], &Float:posx, &Float:posy, &Float:posz, &world, &interior, info[], reporter[])
{
	stmt_bind_value(stmt_ReportInfo, 		0, 	DB::TYPE_INTEGER, rowid);
	stmt_bind_result_field(stmt_ReportInfo, 1, 	DB::TYPE_STRING, reason, MAX_REPORT_REASON_LENGTH);
	stmt_bind_result_field(stmt_ReportInfo, 2, 	DB::TYPE_INTEGER, date);
	stmt_bind_result_field(stmt_ReportInfo, 3, 	DB::TYPE_STRING, type, MAX_REPORT_TYPE_LENGTH);
	stmt_bind_result_field(stmt_ReportInfo, 4, 	DB::TYPE_FLOAT, posx);
	stmt_bind_result_field(stmt_ReportInfo, 5, 	DB::TYPE_FLOAT, posy);
	stmt_bind_result_field(stmt_ReportInfo, 6, 	DB::TYPE_FLOAT, posz);
	stmt_bind_result_field(stmt_ReportInfo, 7, 	DB::TYPE_INTEGER, world);
	stmt_bind_result_field(stmt_ReportInfo, 8, 	DB::TYPE_INTEGER, interior);
	stmt_bind_result_field(stmt_ReportInfo, 9, 	DB::TYPE_STRING, info, MAX_REPORT_INFO_LENGTH);
	stmt_bind_result_field(stmt_ReportInfo, 10, DB::TYPE_STRING, reporter, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_ReportInfo))
		return 0;

	stmt_fetch_row(stmt_ReportInfo);

	return 1;
}

stock SetReportRead(rowid, read)
{
	stmt_bind_value(stmt_ReportSetRead, 0, DB::TYPE_INTEGER, read);
	stmt_bind_value(stmt_ReportSetRead, 1, DB::TYPE_INTEGER, rowid);

	return stmt_execute(stmt_ReportSetRead);
}

stock GetUnreadReports()
{
	new count;

	stmt_bind_result_field(stmt_ReportGetUnread, 0, DB::TYPE_INTEGER, count);	
	stmt_execute(stmt_ReportGetUnread);
	stmt_fetch_row(stmt_ReportGetUnread);

	return count;
}

stock IsPlayerReported(name[])
{
	new count;

	stmt_bind_value(stmt_ReportNameExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_ReportNameExists, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(stmt_ReportNameExists))
		return 0;

	stmt_fetch_row(stmt_ReportNameExists);

	if(count > 0)
		return 1;

	return 0;
}
