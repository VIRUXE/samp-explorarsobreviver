#include <YSI\y_va>

static stock gs_Buffer[256];

stock ChatMsg(playerid, colour, fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	ChatMsgFlat(playerid, colour, gs_Buffer);

	return 1;
}

stock ChatMsgAll(colour, fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<2>);
	ChatMsgAllFlat(colour, gs_Buffer);

	return 1;
}

stock ChatMsgLang(playerid, colour, key[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), GetLanguageString(GetPlayerLanguage(playerid), key), va_start<3>);
	ChatMsgFlat(playerid, colour, gs_Buffer);

	return 1;
}

stock ChatMsgAdmins(level, colour, fmat[], va_args<>)
{
	formatex(gs_Buffer, sizeof(gs_Buffer), fmat, va_start<3>);
	ChatMsgAdminsFlat(level, colour, gs_Buffer);

	return 1;
}


stock ChatMsgFlat(playerid, colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	}
	else
		SendClientMessage(playerid, colour, string);
	
	return 1;
}

stock ChatMsgAllFlat(colour, string[])
{
	if(strlen(string) > 127)
	{
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--)
		{
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.')
			{
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	}
	else
		SendClientMessageToAll(colour, string);

	return 1;
}

stock ChatMsgLangFlat(playerid, colour, key[])
{
	ChatMsgFlat(playerid, colour, GetLanguageString(GetPlayerLanguage(playerid), key));

	return 1;
}
