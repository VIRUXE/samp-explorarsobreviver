#include <YSI_Coding\y_hooks>

hook OnPlayerSpawn(playerid)
{
	// Query the database for the latest changelogs
	if(!mysql_tquery(gDatabase, "SELECT DAY(date) as date, type, title, description FROM changelog WHERE date >= date(NOW())-7;", "OnChangelogLoaded", "d", playerid))
		err(false, true, "Couldn't download changelog.");
}

forward OnChangelogLoaded(playerid);
public OnChangelogLoaded(playerid)
{
	new changelogBuffer[2000];

	for(new row; row < cache_num_rows(); row++)
	{
		new
			rowBuffer[256],
			date[64],
			type[7],
			title[32],
			description[128];

		cache_get_value(row, "date", date);
		cache_get_value(row, "type", type);
		cache_get_value(row, "title", title);
		cache_get_value(row, "description", description);

		format(rowBuffer, sizeof(rowBuffer), "Dia %s - %s(%s)\t %s\n", date, type, title, !isequal(description, "NULL", true) ? description : "Sem descrição.");
	
		strcat(changelogBuffer, rowBuffer);
	}
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Registro de Alterações", changelogBuffer, "OK");
}