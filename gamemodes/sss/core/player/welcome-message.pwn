#include <YSI\y_hooks>


static
Timer:	WelcomeMessageTimer[MAX_PLAYERS],
		WelcomeMessageCount[MAX_PLAYERS],
		CanLeaveWelcomeMessage[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dbg("global", LOG_CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/welcome-message.pwn");

	CanLeaveWelcomeMessage[playerid] = true;

	return 1;
}

timer ShowWelcomeMessage[1000](playerid, count)
{
	new
		str[509],
		button[7];

	strcat(str,
		"\n\n\n"C_WHITE"You have to fight to survive in an apocalyptic wasteland.\n\n\
		You will have a better chance in a group, but be careful who you trust.\n\n\
		Supplies can be found scattered around, weapons are rare though.\n\n");

	strcat(str,
		"Avoid attacking unarmed players, they frighten easily but will return, and in greater numbers...\n\n\n\n\n\
		"C_WHITE"Please take some time to look at the "C_BLUE"/help "C_WHITE"before diving into the game.\n\n\n\
		Visit "C_YELLOW"http://chat.viruxe.party "C_WHITE"for more information.\n\n\n");

	if(count == 0)
	{
		button = "Accept";

		CanLeaveWelcomeMessage[playerid] = true;
	}
	else
	{
		valstr(button, count);
		count--;

		stop WelcomeMessageTimer[playerid];
		WelcomeMessageTimer[playerid] = defer ShowWelcomeMessage(playerid, count);

		CanLeaveWelcomeMessage[playerid] = false;
	}

	WelcomeMessageCount[playerid] = count;

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, response, dialogid, listitem, inputtext

		if(!CanLeaveWelcomeMessage[playerid])
			ShowWelcomeMessage(playerid, WelcomeMessageCount[playerid] + 1);
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Welcome to Scavenge and Survive!", str, button, "");

	return 1;
}

stock CanPlayerLeaveWelcomeMessage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return CanLeaveWelcomeMessage[playerid];
}
