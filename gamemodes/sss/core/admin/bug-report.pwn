#include <YSI_Coding\y_hooks>

#define MAX_BUG_LENGTH				(128)
#define MAX_BUGS_PER_PAGE			(32)
#define ACCOUNTS_TABLE_BUGS			"Bugs"
#define FIELD_BUGS_NAME				"name"		// 00
#define FIELD_BUGS_REASON			"reason"	// 01
#define FIELD_BUGS_DATE				"date"		// 02

enum
{
	FIELD_ID_BUGS_NAME,
	FIELD_ID_BUGS_REASON,
	FIELD_ID_BUGS_DATE
}


static
DCC_Channel:	bug_DiscordChannel,
				bug_RowIndex[MAX_BUGS_PER_PAGE],

DBStatement:	stmt_BugInsert,
DBStatement:	stmt_BugDelete,
DBStatement:	stmt_BugList,
DBStatement:	stmt_BugTotal,
DBStatement:	stmt_BugInfo;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_BUGS" (\
		"FIELD_BUGS_NAME" TEXT,\
		"FIELD_BUGS_REASON" TEXT,\
		"FIELD_BUGS_DATE" INTEGER)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_BUGS, 3);

	stmt_BugInsert	= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_BUGS" VALUES(?, ?, ?)");
	stmt_BugDelete	= db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_BUGS" WHERE rowid = ?");
	stmt_BugList	= db_prepare(gAccounts, "SELECT "FIELD_BUGS_NAME", "FIELD_BUGS_REASON", rowid FROM "ACCOUNTS_TABLE_BUGS"");
	stmt_BugTotal	= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_BUGS"");
	stmt_BugInfo	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_BUGS" WHERE rowid = ? LIMIT 1");

	bug_DiscordChannel = DCC_FindChannelById("861041187233464340");
}


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:bug(playerid, params[])
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			ChatMsgLang(playerid, YELLOW, "BUGREPORTSU");
			ChatMsgAdmins(1, YELLOW, " » %P"C_YELLOW" reportou Bug: %s", playerid, inputtext);
			SendDiscordMessage(bug_DiscordChannel, "**%p** reportou:\n```%s```", playerid, inputtext);

			stmt_bind_value(stmt_BugInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
			stmt_bind_value(stmt_BugInsert, 1, DB::TYPE_STRING, inputtext, MAX_BUG_LENGTH);
			stmt_bind_value(stmt_BugInsert, 2, DB::TYPE_INTEGER, gettime());
			
			if(!stmt_execute(stmt_BugInsert))
				err("erro ao reportar bug: %p reportou %s", playerid, inputtext);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Relatório de Bug", ls(playerid, "BUGREPORTDI"), "Submeter", "Cancelar");

	return 1;
}


/*==============================================================================

	Listing reports

==============================================================================*/


CMD:bugs(playerid, params[])
{
	if(!ShowListOfBugs(playerid))
		ChatMsg(playerid, YELLOW, " » Não existem Bugs relatados.");

	return 1;
}

ShowListOfBugs(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[32],
		rowid;

	stmt_bind_result_field(stmt_BugList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BugList, 1, DB::TYPE_STRING, bug, 32);
	stmt_bind_result_field(stmt_BugList, 2, DB::TYPE_INTEGER, rowid);

	if(!stmt_execute(stmt_BugList))
		return 0;

	new
		list[(MAX_PLAYER_NAME + 2 + 32 + 1) * MAX_BUGS_PER_PAGE],
		idx;

	// Some bug in sqlite causes 'name' to appear empty sometimes.
	while(stmt_fetch_row(stmt_BugList) && idx < MAX_BUGS_PER_PAGE)
	{
		strcat(list, name);
		strcat(list, ": ");

		strcat(list, bug);

		if(bug[30] != EOS)
			strcat(list, "[...]");

		strcat(list, "\n");

		bug_RowIndex[idx++] = rowid;
	}

	if(idx == 0)
		return 0;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			if(!ShowBugReportInfo(playerid, bug_RowIndex[listitem]))
				ChatMsg(playerid, RED, " » An error occurred while trying to execute statement 'stmt_BugInfo'.");
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Bugs", list, "Abrir", "Fechar");

	return 1;
}

ShowBugReportInfo(playerid, rowid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[MAX_BUG_LENGTH],
		date,
		message[512];

	stmt_bind_value(stmt_BugInfo, 0, DB::TYPE_INTEGER, rowid);
	stmt_bind_result_field(stmt_BugInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BugInfo, 1, DB::TYPE_STRING, bug, MAX_BUG_LENGTH);
	stmt_bind_result_field(stmt_BugInfo, 2, DB::TYPE_INTEGER, date);

	if(!stmt_execute(stmt_BugInfo))
		return 0;

	stmt_fetch_row(stmt_BugInfo);

	format(message, sizeof(message),
		""C_YELLOW"Reporter:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Razão:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Data:\n\t\t"C_BLUE"%s",
		name, bug, TimestampToDateTime(date));

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			if(GetPlayerAdminLevel(playerid) > 1)
			{
				stmt_bind_value(stmt_BugDelete, 0, DB::TYPE_INTEGER, rowid);
				stmt_execute(stmt_BugDelete);
			}
		}
		ShowListOfBugs(playerid);
	}

	if(GetPlayerAdminLevel(playerid) > 1)
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Bugs", message, GetPlayerAdminLevel(playerid) > 1 ? "Eliminar" : "Para Trás", GetPlayerAdminLevel(playerid) > 1 ? "Para Trás" : "");

	return 1;
}

/*==============================================================================

	Interface

==============================================================================*/


stock GetBugReports()
{
	new count;

	stmt_bind_result_field(stmt_BugTotal, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_BugTotal);
	stmt_fetch_row(stmt_BugTotal);

	return count;
}
