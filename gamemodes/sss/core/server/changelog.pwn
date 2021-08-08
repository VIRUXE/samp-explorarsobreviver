#include <YSI_Coding\y_hooks>

hook OnPlayerLogin(playerid)
{
	if(IsPlayerWhitelisted(playerid)) // meh
		ChatMsg(playerid, GREEN, " » Veja todas as novidades em "C_WHITE"/novidades!");
}

forward OnChangelogLoaded(playerid);
public OnChangelogLoaded(playerid)
{
	new changelogBuffer[4000];

	for(new row; row < cache_num_rows(); row++)
	{
		new
			rowBuffer[256],
			datediff,
			date[64],
			type[7],
			title[32],
			description[128];

		cache_get_value_int(row, "datediff", datediff);
		cache_get_value(row, "date", date);
		cache_get_value(row, "type", type);
		cache_get_value(row, "title", title);
		cache_get_value(row, "description", description);

		format(rowBuffer, sizeof(rowBuffer), "%s%s"C_GREY"\t%s\t"C_WHITE"%s"C_GREY":%s"C_WHITE"%s\n", datediff <= 7 ? C_GOLD : C_GREY, date, type, title, strlen(title) < 7 ? "\t\t" : "\t", !isequal(description, "NULL", true) ? description : "Sem descrição.");
	
		strcat(changelogBuffer, rowBuffer);
	}
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Registro de Alterações", changelogBuffer, "OK");

	log(false, "[CHANGELOG] Change log shown to player %p", playerid);
}

CMD:novidades(playerid)
{
	// Query the database for the latest changelogs
	if(!mysql_tquery(gDatabase, "SELECT DATEDIFF(NOW(), date) AS datediff, DATE_FORMAT(date, '%d/%m') AS date, type, title, description FROM changelog c ORDER BY c.date DESC LIMIT 35;", "OnChangelogLoaded", "d", playerid))
		err(false, true, "Couldn't download changelog.");

	return 1;
}