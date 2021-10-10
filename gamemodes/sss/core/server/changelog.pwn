#include <YSI_Coding\y_hooks>

static bool:hasNewStuff;

hook OnPlayerLogin(playerid)
{
	if(IsPlayerWhitelisted(playerid)) // meh
	{
		if(hasNewStuff)
			cmd_novidades(playerid);
		else
			ChatMsg(playerid, GREEN, " » Veja todas as novidades em "C_WHITE"/novidades!");
	}
}

forward OnChangelogLoaded(playerid);
public OnChangelogLoaded(playerid)
{
	new changelogBuffer[8000] = "Dia\tTipo\tTítulo\t\tDescrição\n";

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

		new charCount = strlen(date) + strlen(type) + strlen(title),
			weekOld = datediff <= 7;

		if(!hasNewStuff && weekOld)
			hasNewStuff = true;

		format(rowBuffer, sizeof(rowBuffer), "%s%s"C_GREY"\t%s%s\t"C_WHITE"%s"C_GREY"%s"C_WHITE"%s\n", weekOld ? C_GOLD : C_GREY, date, GetColourByType(type), type, title, charCount <= 18 ? "\t\t" : "\t", !isequal(description, "NULL", true) ? description : "Sem descrição.");
		strcat(changelogBuffer, rowBuffer);
	}
	strcat(changelogBuffer, "\n"C_GREY"Legenda:\n"C_RED"bugfix"C_GREY": bug resolvido - "C_YELLOW"tweak"C_GREY": ajuste - "C_GREEN"feat"C_GREY": novidade");

	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Registro de Alterações", changelogBuffer, "OK");

	log(true, "[CHANGELOG] %p viewed the change log.", playerid);
}

GetColourByType(type[])
{
	new colour[9] = C_GREY;

	if(isequal(type, "feat", true))
		colour = C_GREEN;
	else if(isequal(type, "tweak", true))
		colour = C_YELLOW;
	else if(isequal(type, "bugfix", true))
		colour = C_RED;

	return colour;
}

CMD:novidades(playerid)
{
	// Query the database for the latest changelogs
	if(!mysql_tquery(gDatabase, "SELECT DATEDIFF(NOW(), date) AS datediff, DATE_FORMAT(date, '%d/%m') AS date, type, title, description FROM changelog c ORDER BY c.date DESC LIMIT 30;", "OnChangelogLoaded", "d", playerid))
		err(false, true, "Couldn't download changelog.");

	return 1;
}