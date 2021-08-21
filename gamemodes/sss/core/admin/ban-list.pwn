#include <YSI_Coding\y_hooks>


#define MAX_BANS_PER_PAGE (20)


static
	banlist_ViewingList[MAX_PLAYERS],
	banlist_CurrentIndex[MAX_PLAYERS],
	banlist_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME];


ShowListOfBans(playerid, index = 0)
{
	new
		list[MAX_BANS_PER_PAGE][MAX_PLAYER_NAME],
		totalbans,
		listitems;

	totalbans = GetTotalBans();

	if(index > totalbans)
		index = 0;

	if(index < 0)
		index = totalbans - (totalbans % MAX_BANS_PER_PAGE);

	listitems = GetBanList(list, MAX_BANS_PER_PAGE, index);

	if(listitems == 0)
		return 0;

	if(listitems == -1)
		return -1;

	new
		idx,
		string[((MAX_PLAYER_NAME + 1) * MAX_BANS_PER_PAGE)],
		title[22];

	while(idx < listitems )
	{
		strcat(string, list[idx]);
		strcat(string, "\n");
		idx++;
	}

	format(title, sizeof(title), "Bans (%d-%d de %d)", index, index + listitems, totalbans);

	banlist_ViewingList[playerid] = true;
	banlist_CurrentIndex[playerid] = index;

	ShowPlayerPageButtons(playerid);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new name[MAX_PLAYER_NAME];
			strmid(name, inputtext, 0, MAX_PLAYER_NAME);
			ShowBanInfo(playerid, name);
		}

		banlist_ViewingList[playerid] = false;
		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, title, string, "Abrir", "Sair");

	return 1;
}

ShowBanInfo(playerid, const name[MAX_PLAYER_NAME])
{
	new
		timestamp,
		reason[MAX_BAN_REASON],
		bannedby[MAX_PLAYER_NAME],
		duration;

	if(!GetBanInfo(name, timestamp, reason, bannedby, duration))
		return 0;

	new str[256];

	format(str, 256, "\
		"C_YELLOW"Data:\n\t\t"C_BLUE"%s - %s\n\n\n\
		"C_YELLOW"Por:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Motivo:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		duration ? TimestampToDateTime(timestamp + duration) : "Nunca",
		bannedby,
		reason);

	banlist_CurrentName[playerid] = name;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
			ShowBanOptions(playerid);
		else
			ShowListOfBans(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, name, str, "Opções", "Sair");

	return 1;
}

ShowBanOptions(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0: // Edit reason
					ShowBanReasonEdit(playerid);
				case 1: // Edit duration
					ShowBanDurationEdit(playerid);
				case 2: // Edit set unban
					ShowBanDateEdit(playerid);
				case 3: // Unban
					ShowUnbanPrompt(playerid);
			}
		}
		else
			ShowBanInfo(playerid, banlist_CurrentName[playerid]);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, banlist_CurrentName[playerid], "Editar Motivo\nEditar duração\nSet unban\nUnban\n", "Select", "Sair");

	return 1;
}

ShowBanReasonEdit(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
			SetBanReason(banlist_CurrentName[playerid], inputtext);

		ShowBanOptions(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Edit ban reason", "Enter the new ban reason below.", "OK", "Cancelar");

	return 1;
}

ShowBanDurationEdit(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new duration = !strcmp(inputtext, "forever", true) ? 0 : GetDurationFromString(inputtext);

			if(duration == -1)
			{
				ChatMsg(playerid, YELLOW, " » Invalid input. Please use <number> <days/weeks/months>.");
				ShowBanDurationEdit(playerid);
			}
			else
			{
				SetBanDuration(banlist_CurrentName[playerid], duration);
				ShowBanOptions(playerid);
			}
		}

		ShowBanOptions(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Edit ban reason", "Enter the new ban duration below in format <number> <days/weeks/months>", "Enter", "Cancel");

	return 1;
}

ShowBanDateEdit(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
			ChatMsg(playerid, YELLOW, " » Por acabar.");

		ShowBanOptions(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Edit unban date", "Please enter a date in format: dd/mm/yy", "Enter", "Cancel");

	return 1;
}

ShowUnbanPrompt(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
			UnbanAccount(banlist_CurrentName[playerid]);

		ShowBanOptions(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Desbanir", "Tem a certeza que quer Desbanir?", "Sim", "Não");

	return 1;
}

hook OnPlayerDialogPage(playerid, direction)
{
	if(banlist_ViewingList[playerid])
	{
		if(direction == 0)
			banlist_CurrentIndex[playerid] -= MAX_BANS_PER_PAGE;
		else
			banlist_CurrentIndex[playerid] += MAX_BANS_PER_PAGE;

		ShowListOfBans(playerid, banlist_CurrentIndex[playerid]);
	}
}