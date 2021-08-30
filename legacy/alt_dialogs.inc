//Alternative Dialogs by Nexius v6.5 edited by Kolor4dO

#if defined _alt_dialogs_included
	#endinput
#endif
#define _alt_dialogs_included

#include <a_samp>

#define AD_VERSION						"1.0"

#define AD_STYLE_LIST					2
#define AD_INVALID_ID					-1


#if !defined AD_MAX_CLICK_INTERVAL
	#define AD_MAX_CLICK_INTERVAL		200
#endif

#if !defined AD_MAX_DIALOG_PAGES
	#define AD_MAX_DIALOG_PAGES			13	//Change if you want
#endif

#if !defined AD_MAX_CAPTION_LENGTH
	#define AD_MAX_CAPTION_LENGTH		38
#endif

#if !defined AD_MAX_ITEM_LENGTH
	#define AD_MAX_ITEM_LENGTH			45
#endif

#if !defined AD_MAX_BUTTONS_LENGTH
	#define AD_MAX_BUTTONS_LENGTH		9
#endif


// Dialog Color
#if !defined AD_TITLE_COLOR
	#define AD_TITLE_COLOR					-75
#endif

#if !defined AD_TITLE_BOX_COLOR
	#define AD_TITLE_BOX_COLOR				200
#endif

#if !defined AD_BUTTONS_COLOR
	#define AD_BUTTONS_COLOR				-75
#endif

#if !defined AD_BUTTONS_BOX_COLOR
	#define AD_BUTTONS_BOX_COLOR			200
#endif

#if !defined AD_ITEMS_COLOR
	#define AD_ITEMS_COLOR					-75
#endif

#if !defined AD_ITEMS_BOX_COLOR
	#define AD_ITEMS_BOX_COLOR				0x302d2d55
#endif

#if !defined AD_ITEMS_BOX_COLOR2
	#define AD_ITEMS_BOX_COLOR2				0x3d3a3a55
#endif

#if !defined AD_SELECTED_ITEM_BOX_COLOR
	#define AD_SELECTED_ITEM_BOX_COLOR		-16777180
#endif

#if !defined AD_PANEL_BOX_COLOR
	#define AD_PANEL_BOX_COLOR				50
#endif

#if !defined AD_SELECTION_COLOR
	#define AD_SELECTION_COLOR				-10
#endif

#if !defined AD_UP_DOWN_BUTTONS_COLOR
	#define AD_UP_DOWN_BUTTONS_COLOR		-75
#endif

#if !defined AD_SCROLL_BOX_COLOR
	#define AD_SCROLL_BOX_COLOR				-16777170
#endif


static
	adItemID[MAX_PLAYERS],
	adPageID[MAX_PLAYERS],
	adDialogID[MAX_PLAYERS],
	adMaxItems[MAX_PLAYERS],
	bool:adIgnoreEsc[MAX_PLAYERS],
	adLastClicked[MAX_PLAYERS],
	Text:adArrayTDs[3] = {Text:INVALID_TEXT_DRAW, ...},
	PlayerText:adArrayPTDs[MAX_PLAYERS][13],
	adItems[MAX_PLAYERS][AD_MAX_DIALOG_PAGES * 8][AD_MAX_ITEM_LENGTH char];

forward OnAltDialogResponse(playerid, dialogid, response, listitem);

public OnGameModeInit()
{
	adArrayTDs[0] = TextDrawCreate(469.0, 194.0, "_"); //Panel box
	TextDrawTextSize(adArrayTDs[0], 174.0, 0.0);
	TextDrawLetterSize(adArrayTDs[0], 0.0, 17.1);
	TextDrawUseBox(adArrayTDs[0], 1);
	TextDrawBoxColor(adArrayTDs[0], AD_PANEL_BOX_COLOR);
	#undef AD_PANEL_BOX_COLOR

	adArrayTDs[1] = TextDrawCreate(454.0, 210.0, "v"); //Up button
	TextDrawFont(adArrayTDs[1], 2);
	TextDrawTextSize(adArrayTDs[1], 4.0, 8.0);
	TextDrawLetterSize(adArrayTDs[1], 0.4, -1.6);
	TextDrawColor(adArrayTDs[1], AD_UP_DOWN_BUTTONS_COLOR);
	TextDrawSetShadow(adArrayTDs[1], 0);
	TextDrawSetSelectable(adArrayTDs[1], 1);

	adArrayTDs[2] = TextDrawCreate(454.0, 322.0, "v"); //Down button
	TextDrawFont(adArrayTDs[2], 2);
	TextDrawTextSize(adArrayTDs[2], 12.0, 20.0);
	TextDrawLetterSize(adArrayTDs[2], 0.4, 1.6);
	TextDrawColor(adArrayTDs[2], AD_UP_DOWN_BUTTONS_COLOR);
	#undef AD_UP_DOWN_BUTTONS_COLOR
	TextDrawSetShadow(adArrayTDs[2], 0);
	TextDrawSetSelectable(adArrayTDs[2], 1);

	printf("Alternative Dialogs v%s by Nexius loaded!\n", AD_VERSION);
	#if defined ad_OnGameModeInit
		return ad_OnGameModeInit();
	#else
		return 1;
	#endif
}

#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit ad_OnGameModeInit
#if defined ad_OnGameModeInit
	forward ad_OnGameModeInit();
#endif

public OnGameModeExit()
{
	for(new i = sizeof(adArrayTDs) - 1; i >= 0; --i) TextDrawDestroy(adArrayTDs[i]);
	#if defined ad_OnGameModeExit
		return ad_OnGameModeExit();
	#else
		return 1;
	#endif
}

#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit ad_OnGameModeExit
#if defined ad_OnGameModeExit
	forward ad_OnGameModeExit();
#endif

public OnPlayerConnect(playerid)
{
	adIgnoreEsc[playerid] = false;
	adDialogID[playerid] = AD_INVALID_ID;
	for(new i = sizeof(adArrayPTDs[]) - 1; i >= 0; --i) adArrayPTDs[playerid][i] = PlayerText:65535;
	#if defined ad_OnPlayerConnect
		return ad_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}

#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect ad_OnPlayerConnect
#if defined ad_OnPlayerConnect
	forward ad_OnPlayerConnect(playerid);
#endif

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(adIgnoreEsc[playerid] && _:clickedid == 65535) adIgnoreEsc[playerid] = false;
	else if(adDialogID[playerid] != AD_INVALID_ID)
	{
		if(_:clickedid == 65535)
		{
			new tmp_dialogid = adDialogID[playerid], tmp_itemid = adItemID[playerid];
			ShowPlayerAltDialog(playerid, AD_INVALID_ID, -1, "", "", "");
			CallRemoteFunction("OnAltDialogResponse", "iiii", playerid, tmp_dialogid, 0, tmp_itemid);
		}
		else if(clickedid == adArrayTDs[1])
		{
			if(adPageID[playerid] > 0)
			{
				new i, Float:s_size, Float:s_pos;
				adPageID[playerid]--;
				adItemID[playerid] = adPageID[playerid] * 8;
				for(i = 11; i >= 5; --i)
				{
					PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][i],
						(i == 4 || i == 6 || i == 8 || i == 10 || i == 12) ? AD_ITEMS_BOX_COLOR : AD_ITEMS_BOX_COLOR2);

					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][i]);
				}
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][4], AD_SELECTED_ITEM_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4]);

				i = adPageID[playerid] * 8;

				for(new j = i + 8, c; i < j; i++)
				{
					PlayerTextDrawSetString(playerid, adArrayPTDs[playerid][4 + c], adItems[playerid][i]);
					if(!adItems[playerid][i]{0}) PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 0);
					else PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 1);
					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4 + c]);
					c++;
				}

				PlayerTextDrawDestroy(playerid, adArrayPTDs[playerid][12]);

				s_size = 9.8 / (floatround(adMaxItems[playerid] / 8, floatround_tozero) + 1);
				s_pos = (s_size * 9) * adPageID[playerid];

				adArrayPTDs[playerid][12] = CreatePlayerTextDraw(playerid, 455.0, 212.0 + s_pos, "_"); //Scroll box
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][12], 465.0, 3.5);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][12], 0.0, s_size);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][12], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][12], AD_SCROLL_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][12]);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][12], 1);
			}
		}
		else if(clickedid == adArrayTDs[2])
		{
			if(adPageID[playerid] < floatround(adMaxItems[playerid] / 8, floatround_tozero))
			{
				new i, Float:s_size, Float:s_pos;

				adPageID[playerid]++;
				adItemID[playerid] = adPageID[playerid] * 8;

				for(i = 11; i >= 5; --i)
				{
					PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][i], 
						(i == 4 || i == 6 || i == 8 || i == 10 || i == 12) ? AD_ITEMS_BOX_COLOR : AD_ITEMS_BOX_COLOR2);

					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][i]);
				}
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][4], AD_SELECTED_ITEM_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4]);
				i = adPageID[playerid] * 8;
				for(new j = i + 8, c; i < j; i++)
				{
					PlayerTextDrawSetString(playerid, adArrayPTDs[playerid][4 + c], adItems[playerid][i]);
					if(!adItems[playerid][i]{0}) PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 0);
					else PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 1);
					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4 + c]);
					c++;
				}
				PlayerTextDrawDestroy(playerid, adArrayPTDs[playerid][12]);
				s_size = 9.8 / (floatround(adMaxItems[playerid] / 8, floatround_tozero) + 1);
				s_pos = (s_size * 9) * adPageID[playerid];
				adArrayPTDs[playerid][12] = CreatePlayerTextDraw(playerid, 455.0, 212.0 + s_pos, "_"); //Scroll box
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][12], 465.0, 3.5);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][12], 0.0, s_size);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][12], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][12], AD_SCROLL_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][12]);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][12], 1);
			}
		}
	}
	#if defined ad_OnPlayerClickTextDraw
		return ad_OnPlayerClickTextDraw(playerid, clickedid);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw ad_OnPlayerClickTextDraw
#if defined ad_OnPlayerClickTextDraw
	forward ad_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(adDialogID[playerid] != AD_INVALID_ID)
	{
		if(playertextid == adArrayPTDs[playerid][12])
		{
			if(adPageID[playerid] < floatround(adMaxItems[playerid] / 8, floatround_tozero))
			{
				new i, Float:s_size, Float:s_pos;

				adPageID[playerid]++;
				adItemID[playerid] = adPageID[playerid] * 8;

				for(i = 11; i >= 5; --i)
				{
					PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][i], 
						(i == 4 || i == 6 || i == 8 || i == 10 || i == 12) ? AD_ITEMS_BOX_COLOR : AD_ITEMS_BOX_COLOR2);

					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][i]);
				}
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][4], AD_SELECTED_ITEM_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4]);
				i = adPageID[playerid] * 8;
				for(new j = i + 8, c; i < j; i++)
				{
					PlayerTextDrawSetString(playerid, adArrayPTDs[playerid][4 + c], adItems[playerid][i]);
					if(!adItems[playerid][i]{0}) PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 0);
					else PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + c], 1);
					PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4 + c]);
					c++;
				}
				PlayerTextDrawDestroy(playerid, adArrayPTDs[playerid][12]);
				s_size = 9.8 / (floatround(adMaxItems[playerid] / 8, floatround_tozero) + 1);
				s_pos = (s_size * 9) * adPageID[playerid];
				adArrayPTDs[playerid][12] = CreatePlayerTextDraw(playerid, 455.0, 212.0 + s_pos, "_"); //Scroll box
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][12], 465.0, 3.5);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][12], 0.0, s_size);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][12], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][12], AD_SCROLL_BOX_COLOR);
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][12]);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][12], 1);
			}
		}
		if(playertextid == adArrayPTDs[playerid][1] || playertextid == adArrayPTDs[playerid][2])
		{
			new tmp_dialogid = adDialogID[playerid], tmp_itemid = adItemID[playerid];
			ShowPlayerAltDialog(playerid, AD_INVALID_ID, -1, "", "", "");
			CallRemoteFunction("OnAltDialogResponse", "iiii", playerid, tmp_dialogid, 1, tmp_itemid);
		}
		else if(playertextid == adArrayPTDs[playerid][3])
		{
			new tmp_dialogid = adDialogID[playerid], tmp_itemid = adItemID[playerid];
			ShowPlayerAltDialog(playerid, AD_INVALID_ID, -1, "", "", "");
			CallRemoteFunction("OnAltDialogResponse", "iiii", playerid, tmp_dialogid, 0, tmp_itemid);
		}
		else
		{
			for(new i; i < 8; i++)
			{
				if(playertextid == adArrayPTDs[playerid][4 + i])
				{
					new gtc = GetTickCount();

					if(adItemID[playerid] == i + (adPageID[playerid] * 8) )
					{
						if(gtc - adLastClicked[playerid] <= AD_MAX_CLICK_INTERVAL)
						{
							adLastClicked[playerid] = 0;
							new tmp_dialogid = adDialogID[playerid], tmp_itemid = adItemID[playerid];
							ShowPlayerAltDialog(playerid, AD_INVALID_ID, -1, "", "", "");
							CallRemoteFunction("OnAltDialogResponse", "iiii", playerid, tmp_dialogid, 1, tmp_itemid);
						}
						else adLastClicked[playerid] = gtc;
					}
					else
					{
						// new selected
						PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][4 + i], AD_SELECTED_ITEM_BOX_COLOR);
						PlayerTextDrawShow(playerid, adArrayPTDs[playerid][4 + i]);

						// old selected
						PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][adItemID[playerid] + 4], 
							(i == 0 || i == 2 || i == 4 || i == 6 || i == 8) ? AD_ITEMS_BOX_COLOR : AD_ITEMS_BOX_COLOR2);

						PlayerTextDrawShow(playerid, adArrayPTDs[playerid][adItemID[playerid] + 4]);

						adItemID[playerid] = i + (adPageID[playerid] * 8);
						adLastClicked[playerid] = gtc;
					}
					break; 
				}
			}
		}
	}
	#if defined ad_OnPlayerClickPlayerTextDraw
		return ad_OnPlayerClickPlayerTextDraw(playerid, playertextid);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnPlayerClickPlayerTextDra\
	|| defined _ALS_OnPlayerClickPlayerTD
	#undef OnPlayerClickPlayerTextDraw
#else
	#define _ALS_OnPlayerClickPlayerTextDra
	#define _ALS_OnPlayerClickPlayerTD
#endif
#define OnPlayerClickPlayerTextDraw ad_OnPlayerClickPlayerTextDraw
#if defined ad_OnPlayerClickPlayerTextDraw
	forward ad_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
#endif

#undef AD_MAX_CLICK_INTERVAL

ShowPlayerAltDialog(playerid, dialogid, style, caption[], info[], button1[], button2[] = "")
{
	if(IsPlayerConnected(playerid))
	{
		new i;
		adDialogID[playerid] = AD_INVALID_ID;
		for(i = (AD_MAX_DIALOG_PAGES * 8) - 1; i >= 0; --i) adItems[playerid][i]{0} = EOS;
		#undef AD_MAX_DIALOG_PAGES
		for(i = sizeof(adArrayTDs) - 1; i >= 0; --i) TextDrawHideForPlayer(playerid, adArrayTDs[i]);
		for(i = sizeof(adArrayPTDs[]) - 1; i >= 0; --i)
		{
			PlayerTextDrawDestroy(playerid, adArrayPTDs[playerid][i]);
			adArrayPTDs[playerid][i] = PlayerText:65535;
		}
		if(dialogid <= AD_INVALID_ID)
		{
			adIgnoreEsc[playerid] = true;
			return CancelSelectTextDraw(playerid);
		}
		if(style == AD_STYLE_LIST)
		{
			adPageID[playerid] = 0;
			adItemID[playerid] = 0;
			adDialogID[playerid] = dialogid;

			if(strlen(caption) >= AD_MAX_CAPTION_LENGTH)
			{
				caption[AD_MAX_CAPTION_LENGTH - 3] = '.';
				caption[AD_MAX_CAPTION_LENGTH - 2] = '.';
				caption[AD_MAX_CAPTION_LENGTH - 1] = '.';
				caption[AD_MAX_CAPTION_LENGTH] = EOS;
				#undef AD_MAX_CAPTION_LENGTH
			}

			adArrayPTDs[playerid][0] = CreatePlayerTextDraw(playerid, 174.0, 182.0, caption); //Title
			PlayerTextDrawFont(playerid, adArrayPTDs[playerid][0], 2);
			PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][0], 470.0, 0.0);
			PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][0], 0.31, 1.24);
			PlayerTextDrawColor(playerid, adArrayPTDs[playerid][0], AD_TITLE_COLOR);
			#undef AD_TITLE_COLOR
			PlayerTextDrawSetShadow(playerid, adArrayPTDs[playerid][0], 0);
			PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][0], 1);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][0], AD_TITLE_BOX_COLOR);
			#undef AD_TITLE_BOX_COLOR

			if(strlen(button1) >= AD_MAX_BUTTONS_LENGTH) button1[AD_MAX_BUTTONS_LENGTH] = EOS;

			new b2_len = strlen(button2);

			if(b2_len > 0)
			{
				adArrayPTDs[playerid][1] = CreatePlayerTextDraw(playerid, 289.0, 334.0, button1); //Button 1
				PlayerTextDrawAlignment(playerid, adArrayPTDs[playerid][1], 2);
				PlayerTextDrawFont(playerid, adArrayPTDs[playerid][1], 2);
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][1], 12.0, 38.0);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][1], 0.31, 1.24);
				PlayerTextDrawColor(playerid, adArrayPTDs[playerid][1], AD_BUTTONS_COLOR);
				PlayerTextDrawSetShadow(playerid, adArrayPTDs[playerid][1], 0);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][1], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][1], AD_BUTTONS_BOX_COLOR);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][1], 1);

				if(b2_len >= AD_MAX_BUTTONS_LENGTH) button2[AD_MAX_BUTTONS_LENGTH] = EOS;
				#undef AD_MAX_BUTTONS_LENGTH

				adArrayPTDs[playerid][3] = CreatePlayerTextDraw(playerid, 350.5, 334.0, button2); //Button 2
				PlayerTextDrawAlignment(playerid, adArrayPTDs[playerid][3], 2);
				PlayerTextDrawFont(playerid, adArrayPTDs[playerid][3], 2);
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][3], 12.0, 38.0);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][3], 0.31, 1.24);
				PlayerTextDrawColor(playerid, adArrayPTDs[playerid][3], AD_BUTTONS_COLOR);
				PlayerTextDrawSetShadow(playerid, adArrayPTDs[playerid][3], 0);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][3], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][3], AD_BUTTONS_BOX_COLOR);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][3], 1);
			}
			else
			{
				adArrayPTDs[playerid][2] = CreatePlayerTextDraw(playerid, 321.0, 334.0, button1); //Button 1 only
				PlayerTextDrawAlignment(playerid, adArrayPTDs[playerid][2], 2);
				PlayerTextDrawFont(playerid, adArrayPTDs[playerid][2], 2);
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][2], 12.0, 38.0);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][2], 0.31, 1.24);
				PlayerTextDrawColor(playerid, adArrayPTDs[playerid][2], AD_BUTTONS_COLOR);
				#undef AD_BUTTONS_COLOR
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][2], 1);
				PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][2], AD_BUTTONS_BOX_COLOR);
				PlayerTextDrawSetShadow(playerid, adArrayPTDs[playerid][2], 0);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][2], 1);
			}
			#undef AD_BUTTONS_BOX_COLOR

			i = 0;
			new c = -1;
				
			for(new j, strtmp[AD_MAX_ITEM_LENGTH], s = strlen(info); i <= s; i++)
			{	
				if(info[i] == '\n' && i != s)
				{
					if(c + 1 >= sizeof adItems[])
						break;

					c++;

					strmid(strtmp, info, j, i);
					strpack(adItems[playerid][c], strtmp);

					if(i - j >= sizeof adItems[][] * (cellbits / charbits))
					{
						adItems[playerid][c]{(sizeof(adItems[][]) * (cellbits / charbits)) - 3} = '.';
						adItems[playerid][c]{(sizeof(adItems[][]) * (cellbits / charbits)) - 2} = '.';
						adItems[playerid][c]{(sizeof(adItems[][]) * (cellbits / charbits)) - 1} = '.';
					}

					j = i + 1;
				}
			}
			#undef AD_MAX_ITEM_LENGTH

			for(i = 0; i < 8; i++)
			{
				if(i >= c) adItems[playerid][i] = "_";
				
				adArrayPTDs[playerid][4 + i] = CreatePlayerTextDraw(playerid, 180.0, 199.0 + (i * 16.0), adItems[playerid][i]); //Item text
				PlayerTextDrawFont(playerid, adArrayPTDs[playerid][4 + i], 1);
				PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][4 + i], (c >= 8) ? 450.0 : 465.0, 13.6);
				PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][4 + i], 0.3, 1.2);
				PlayerTextDrawColor(playerid, adArrayPTDs[playerid][4 + i], AD_ITEMS_COLOR);
				PlayerTextDrawSetOutline(playerid, adArrayPTDs[playerid][4 + i], 1);
				PlayerTextDrawBackgroundColor(playerid, adArrayPTDs[playerid][4 + i], 100);
				PlayerTextDrawSetShadow(playerid, adArrayPTDs[playerid][4 + i], 0);
				PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][4 + i], 1);
				PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][4 + i], 1);
			}

			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][4], AD_SELECTED_ITEM_BOX_COLOR);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][5], AD_ITEMS_BOX_COLOR2);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][6], AD_ITEMS_BOX_COLOR);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][7], AD_ITEMS_BOX_COLOR2);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][8], AD_ITEMS_BOX_COLOR);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][9], AD_ITEMS_BOX_COLOR2);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][10], AD_ITEMS_BOX_COLOR);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][11], AD_ITEMS_BOX_COLOR2);

			#undef AD_SELECTED_ITEM_BOX_COLOR
			#undef AD_ITEMS_COLOR
			
			adMaxItems[playerid] = c;

			adArrayPTDs[playerid][12] = CreatePlayerTextDraw(playerid, 455.0, 212.0, "_"); //Scroll box

			PlayerTextDrawTextSize(playerid, adArrayPTDs[playerid][12], 465.0, 3.5);
			PlayerTextDrawLetterSize(playerid, adArrayPTDs[playerid][12], 0.0, 9.8 / (floatround(c / 8, floatround_tozero) + 1));
			PlayerTextDrawUseBox(playerid, adArrayPTDs[playerid][12], 1);
			PlayerTextDrawBoxColor(playerid, adArrayPTDs[playerid][12], AD_SCROLL_BOX_COLOR);
			PlayerTextDrawSetSelectable(playerid, adArrayPTDs[playerid][12], 1);

			#undef AD_SCROLL_BOX_COLOR

			for(i = sizeof(adArrayTDs) - 1; i >= 0; --i)
			{
				if(c < 8 && (i)) continue;
				TextDrawShowForPlayer(playerid, adArrayTDs[i]);
			}
			for(i = sizeof(adArrayPTDs[]) - 1; i >= 0; --i)
			{
				if(c < 8 && i == 12) continue;
				PlayerTextDrawShow(playerid, adArrayPTDs[playerid][i]);
			}


			return SelectTextDraw(playerid, AD_SELECTION_COLOR);
			#undef AD_SELECTION_COLOR
		}
	}
	return 0;
}

stock GetPlayerAltDialog(playerid)
{
	if(!IsPlayerConnected(playerid)) return AD_INVALID_ID;
	return adDialogID[playerid];
}
