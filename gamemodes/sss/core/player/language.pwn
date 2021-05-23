#define ls(%0,%1) GetLanguageString(GetPlayerLanguage(%0), %1)

static
	lang_PlayerLanguage[MAX_PLAYERS];

stock GetPlayerLanguage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return lang_PlayerLanguage[playerid];
}

ShowLanguageMenu(playerid)
{
	new
		languages[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
		langlist[MAX_LANGUAGE * (MAX_LANGUAGE_NAME + 1)],
		langcount;

	langcount = GetLanguageList(languages);

	for(new i; i < langcount; i++)
		format(langlist, sizeof(langlist), "%s%s\n", langlist, languages[i]);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			lang_PlayerLanguage[playerid] = listitem;
			ChatMsgLang(playerid, YELLOW, "LANGCHANGE");
			log(DISCORD_CHANNEL_EVENTS, "[LANG] `%p` has changed his/her language to `%s`", playerid, languages[listitem]);
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Choose your Language:", langlist, "Select", "Cancel");
}

hook OnPlayerSave(playerid, filename[])
{
	dbg("global", LOG_CORE, "[OnPlayerSave] in /gamemodes/sss/core/player/language.pwn");

	new data[1];
	data[0] = lang_PlayerLanguage[playerid];

	modio_push(filename, _T<L,A,N,G>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	dbg("global", LOG_CORE, "[OnPlayerLoad] in /gamemodes/sss/core/player/language.pwn");

	new data[1];

	modio_read(filename, _T<L,A,N,G>, 1, data);

	lang_PlayerLanguage[playerid] = data[0];
}

CMD:language(playerid, params[])
{
	ShowLanguageMenu(playerid);
	return 1;
}
