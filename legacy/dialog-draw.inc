//Dialog draw created by kolor4do. Version 1.0
#if defined dialog_draw_included
	#endinput
#endif
#define dialog_draw_included

/*
	Functions:

		AddDialogDrawItem(playerid, const item[]);
		ShowDialogDraw(playerid, ddialogid, title[]);
		HideDialogDraw(playerid);

  	Callback:

		OnDialogDrawResponse(playerid, ddialogid, response, listitem)
*/

#include <a_samp>

#if !defined DD_CENTER_ITEMS
	#define DD_CENTER_ITEMS			true
#endif

#if !defined DD_MAX_PAGES
	#define DD_MAX_PAGES			10
#endif

#if !defined DD_MAX_PAGE_ITEMS
	#define DD_MAX_PAGE_ITEMS		6
#endif

#if !defined DD_BOX_TEXT_COLOR
	#define DD_BOX_TEXT_COLOR		-1446714113
#endif

#if !defined DD_BOX_COLOR
	#define DD_BOX_COLOR			1296911871
#endif

#if !defined DD_ITEM_BOX_COLOR
	#define DD_ITEM_BOX_COLOR		205
#endif

#if !defined DD_SELECT_COLOR
	#define DD_SELECT_COLOR			0xFFFF00FF
#endif

#define DD_MAX_ITEM_LENGTH			40

static
			dd_Text[MAX_PLAYERS][DD_MAX_PAGES * DD_MAX_PAGE_ITEMS][DD_MAX_ITEM_LENGTH char],
			dd_ShowItems[MAX_PLAYERS] = {-1, ...},
			dd_Page[MAX_PLAYERS],
			dd_DialogID[MAX_PLAYERS],

Text:		dd_Box 				= Text:INVALID_TEXT_DRAW,
Text:		dd_CloseButton 		= Text:INVALID_TEXT_DRAW,
Text:		dd_PrevPageButton 	= Text:INVALID_TEXT_DRAW,
Text:		dd_NextPageButton	= Text:INVALID_TEXT_DRAW,

PlayerText:	dd_Title		[MAX_PLAYERS] = {PlayerText:INVALID_PLAYER_TEXT_DRAW, ...},
PlayerText:	dd_Items		[MAX_PLAYERS][DD_MAX_PAGE_ITEMS],
PlayerText:	dd_PageSize		[MAX_PLAYERS] = {PlayerText:INVALID_PLAYER_TEXT_DRAW, ...};

forward OnDialogDrawResponse(playerid, ddialogid, response, listitem);

stock AddDialogDrawItem(playerid, const item[])
{
	new itemid = ++dd_ShowItems[playerid];

	strcat(dd_Text[playerid][itemid], item);
	
	if(strlen(dd_Text[playerid][itemid]) >= DD_MAX_ITEM_LENGTH)
	{
		dd_Text[playerid][itemid]{DD_MAX_ITEM_LENGTH - 1} =
		dd_Text[playerid][itemid]{DD_MAX_ITEM_LENGTH - 2} =
		dd_Text[playerid][itemid]{DD_MAX_ITEM_LENGTH - 3} = '.';
		dd_Text[playerid][itemid]{DD_MAX_ITEM_LENGTH} = EOS;
	}

	return itemid;
}

stock ShowDialogDraw(playerid, ddialogid, title[])
{
	// Show dialog box
	TextDrawShowForPlayer(playerid, dd_Box);

	// Show close button
	TextDrawShowForPlayer(playerid, dd_CloseButton);

	// Show page change button
	TextDrawShowForPlayer(playerid, dd_PrevPageButton);
	TextDrawShowForPlayer(playerid, dd_NextPageButton);

	//Show title
	if(strlen(title) >= 32)
	{
		title[31] = title[30] = title[29] = '.';
		title[32] = EOS;
	}
	PlayerTextDrawSetString(playerid, dd_Title[playerid], title);
	PlayerTextDrawShow(playerid, dd_Title[playerid]);

	dd_DialogID[playerid] = ddialogid;

	// Clear until item text list
	for(i = (DD_MAX_PAGES * DD_MAX_PAGE_ITEMS) - 1; i >= dd_ShowItems[playerid]; --i)
	{
		dd_Text[playerid][i]{0} = EOS;
	}
	#undef DD_MAX_PAGES

	SetDialogDrawPage(playerid, dd_Page[playerid]);

	// Select textdraw
	return SelectTextDraw(playerid, DD_SELECT_COLOR);
	#undef DD_SELECT_COLOR
}

stock HideDialogDraw(playerid)
{
	if(dd_ShowItems[playerid] == -1)
		return false;

	TextDrawHideForPlayer(playerid, dd_Box);
	TextDrawHideForPlayer(playerid, dd_CloseButton);
	TextDrawHideForPlayer(playerid, dd_PrevPageButton);
	TextDrawHideForPlayer(playerid, dd_NextPageButton);

	PlayerTextDrawHide(playerid, dd_Title[playerid]);

	for(new i = DD_MAX_PAGE_ITEMS - 1; i >= 0; --i)
		PlayerTextDrawHide	(playerid, dd_Items[playerid][i]);

	PlayerTextDrawHide(playerid, dd_PageSize[playerid]);
	
	CancelSelectTextDraw(playerid);
	dd_ShowItems[playerid] = -1;
	dd_Page[playerid] = 0;
	return true;
}

stock SetDialogDrawPage(playerid, page)
{
	if(page < 0)
	{
		CallRemoteFunction("OnDialogDrawResponse", "iiii", playerid, dd_DialogID[playerid], 0, 0);
		return false;
	}

	new max_page = floatround(dd_ShowItems[playerid] / DD_MAX_PAGE_ITEMS, floatround_tozero);

	if(page > max_page)
	{
		page = 0;
	}

	// update page items
	for(new i = DD_MAX_PAGE_ITEMS - 1; i >= 0; --i)
	{
		if(i + (page * DD_MAX_PAGE_ITEMS) <= dd_ShowItems[playerid])
		{
			PlayerTextDrawSetSelectable(playerid, dd_Items[playerid][i], 1);
			PlayerTextDrawSetString(playerid, dd_Items[playerid][i], dd_Text[playerid][i + (page * DD_MAX_PAGE_ITEMS)]);
		}
		else
		{
			PlayerTextDrawSetSelectable(playerid, dd_Items[playerid][i], 0);
			PlayerTextDrawSetString(playerid, dd_Items[playerid][i], "_");
		}
		PlayerTextDrawShow(playerid, dd_Items[playerid][i]);
	}

	// Update page number
	new str[9];
	format(str, 12, "%d/%d", page + 1, max_page + 1);
	PlayerTextDrawSetString(playerid, dd_PageSize[playerid], str);
	PlayerTextDrawShow(playerid, dd_PageSize[playerid]);

	dd_Page[playerid] = page;
	return true;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	// Close Dialog Draw pressing "X" or key ESC
	if(clickedid == INVALID_TEXT_DRAW || clickedid == dd_CloseButton)
	{
		CallRemoteFunction("OnDialogDrawResponse", "iiii", playerid, dd_DialogID[playerid], 0, 0);	
	}
	// Previous Page
	else if(clickedid == dd_PrevPageButton)
	{
		SetDialogDrawPage(playerid, dd_Page[playerid] - 1);
	}
	// Next page
	else if(clickedid == dd_NextPageButton)
	{
		SetDialogDrawPage(playerid, dd_Page[playerid] + 1);
	}

	#if defined dd_OnPlayerClickTextDraw
		return dd_OnPlayerClickTextDraw(playerid, clickedid);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnPlayerClickTextDraw
	#undef OnPlayerClickTextDraw
#else
	#define _ALS_OnPlayerClickTextDraw
#endif
#define OnPlayerClickTextDraw dd_OnPlayerClickTextDraw
#if defined dd_OnPlayerClickTextDraw
	forward dd_OnPlayerClickTextDraw(playerid, Text:clickedid);
#endif

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	for(new i = DD_MAX_PAGE_ITEMS - 1; i >= 0; --i)
	{
		if(playertextid == dd_Items[playerid][i])
		{
			CallRemoteFunction("OnDialogDrawResponse", "iiii", playerid, dd_DialogID[playerid], 1, i + (dd_Page[playerid] * DD_MAX_PAGE_ITEMS));
			break;
		}
	}
	#if defined dd_OnPlayerClickPlayerTextDraw
		return dd_OnPlayerClickPlayerTextDraw(playerid, playertextid);
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
#define OnPlayerClickPlayerTextDraw dd_OnPlayerClickPlayerTextDraw
#if defined dd_OnPlayerClickPlayerTextDraw
	forward dd_OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid);
#endif

public OnPlayerConnect(playerid)
{
	dd_Title[playerid] = CreatePlayerTextDraw(playerid, 160.0, 160.0, "title");
	PlayerTextDrawFont					(playerid, dd_Title[playerid], 2);
	PlayerTextDrawLetterSize			(playerid, dd_Title[playerid], 0.400000, 1.600000);
	PlayerTextDrawTextSize				(playerid, dd_Title[playerid], 480.0, 15.0);
	PlayerTextDrawSetOutline			(playerid, dd_Title[playerid], 1);
	PlayerTextDrawSetShadow				(playerid, dd_Title[playerid], 1);
	PlayerTextDrawAlignment				(playerid, dd_Title[playerid], 1);
	PlayerTextDrawColor					(playerid, dd_Title[playerid], DD_BOX_TEXT_COLOR);
	PlayerTextDrawBackgroundColor		(playerid, dd_Title[playerid], 255);
	PlayerTextDrawBoxColor				(playerid, dd_Title[playerid], 0);
	PlayerTextDrawUseBox				(playerid, dd_Title[playerid], 0);
	PlayerTextDrawSetProportional		(playerid, dd_Title[playerid], 1);
	PlayerTextDrawSetSelectable			(playerid, dd_Title[playerid], 0);

	for(new i = DD_MAX_PAGE_ITEMS - 1; i >= 0; --i)
	{
		#if DD_CENTER_ITEMS
			dd_Items[playerid][i] = CreatePlayerTextDraw(playerid, 320.0, 180.0 + (i * 20.0), "__");
			PlayerTextDrawTextSize		(playerid, dd_Items[playerid][i], 15.0, 320.0);
			PlayerTextDrawAlignment		(playerid, dd_Items[playerid][i], 2);
		#else
			dd_Items[playerid][i] = CreatePlayerTextDraw(playerid, 160.0, 180.0 + (i * 20.0), "__");
			PlayerTextDrawTextSize		(playerid, dd_Items[playerid][i], 480.0, 15.0);
			PlayerTextDrawAlignment		(playerid, dd_Items[playerid][i], 1);
		#endif
		PlayerTextDrawFont				(playerid, dd_Items[playerid][i], 1);
		PlayerTextDrawLetterSize		(playerid, dd_Items[playerid][i], 0.400000, 1.600000);
		PlayerTextDrawSetOutline		(playerid, dd_Items[playerid][i], 0);
		PlayerTextDrawSetShadow			(playerid, dd_Items[playerid][i], 1);
		PlayerTextDrawColor				(playerid, dd_Items[playerid][i], -1);
		PlayerTextDrawBackgroundColor	(playerid, dd_Items[playerid][i], 255);
		PlayerTextDrawBoxColor			(playerid, dd_Items[playerid][i], DD_ITEM_BOX_COLOR);
		PlayerTextDrawUseBox			(playerid, dd_Items[playerid][i], 1);
		PlayerTextDrawSetProportional	(playerid, dd_Items[playerid][i], 1);
		PlayerTextDrawSetSelectable		(playerid, dd_Items[playerid][i], 1);
	}

	dd_PageSize[playerid] = CreatePlayerTextDraw(playerid, 320.000000, 180.0 + (DD_MAX_PAGE_ITEMS + 1 * 20.0), "32/64");
	PlayerTextDrawFont					(playerid, dd_PageSize[playerid], 2);
	PlayerTextDrawLetterSize			(playerid, dd_PageSize[playerid], 0.400000, 1.600000);
	PlayerTextDrawTextSize				(playerid, dd_PageSize[playerid], 0.000000, 320.000000);
	PlayerTextDrawSetOutline			(playerid, dd_PageSize[playerid], 1);
	PlayerTextDrawSetShadow				(playerid, dd_PageSize[playerid], 0);
	PlayerTextDrawAlignment				(playerid, dd_PageSize[playerid], 2);
	PlayerTextDrawColor					(playerid, dd_PageSize[playerid], DD_BOX_TEXT_COLOR);
	PlayerTextDrawBackgroundColor		(playerid, dd_PageSize[playerid], 255);
	PlayerTextDrawBoxColor				(playerid, dd_PageSize[playerid], 50);
	PlayerTextDrawUseBox				(playerid, dd_PageSize[playerid], 1);
	PlayerTextDrawSetProportional		(playerid, dd_PageSize[playerid], 1);
	PlayerTextDrawSetSelectable			(playerid, dd_PageSize[playerid], 0);

	#undef DD_CENTER_ITEMS
	#undef DD_ITEM_BOX_COLOR
	#if defined dd_OnPlayerConnect
		return dd_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerConnect
	#undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect dd_OnPlayerConnect
#if defined dd_OnPlayerConnect
	forward dd_OnPlayerConnect(playerid);
#endif

public OnPlayerDisconnect(playerid, reason)
{
	dd_ShowItems[playerid] = -1;
	dd_Page[playerid] = 0;
	PlayerTextDrawDestroy(playerid, dd_Title[playerid]);
	for(new i = DD_MAX_PAGE_ITEMS - 1; i >= 0; --i)
	{
		PlayerTextDrawDestroy(playerid, dd_Items[playerid][i]);
	}
	PlayerTextDrawDestroy(playerid, dd_PageSize[playerid]);
	
	#if defined dd_OnPlayerDisconnect
		return dd_OnPlayerDisconnect(playerid, reason);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnect
	#undef OnPlayerDisconnect
#else
	#define _ALS_OnPlayerDisconnect
#endif
#define OnPlayerDisconnect dd_OnPlayerDisconnect
#if defined dd_OnPlayerDisconnect
	forward dd_OnPlayerDisconnect(playerid, reason);
#endif


public OnGameModeInit()
{
	dd_Box = TextDrawCreate(160.000000, 160.000000, "~n~_~n~_~n~_~n~_~n~_~n~_~n~_~n~_~n~_~n~_");
	TextDrawFont			(dd_Box, 2);
	TextDrawLetterSize		(dd_Box, 0.400000, 1.600000);
	TextDrawTextSize		(dd_Box, 480.000000, 17.000000);
	TextDrawSetOutline		(dd_Box, 1);
	TextDrawSetShadow		(dd_Box, 1);
	TextDrawAlignment		(dd_Box, 1);
	TextDrawColor			(dd_Box, 0);
	TextDrawBackgroundColor	(dd_Box, 0);
	TextDrawBoxColor		(dd_Box, DD_BOX_COLOR);
	#undef DD_BOX_COLOR
	TextDrawUseBox			(dd_Box, 1);
	TextDrawSetProportional	(dd_Box, 1);
	TextDrawSetSelectable	(dd_Box, 0);

	dd_CloseButton = TextDrawCreate(469.0, 160.0, "X");
	TextDrawFont			(dd_CloseButton, 1);
	TextDrawLetterSize		(dd_CloseButton, 0.400000, 1.600000);
	TextDrawTextSize		(dd_CloseButton, 480.000000, 15.000000);
	TextDrawSetOutline		(dd_CloseButton, 1);
	TextDrawSetShadow		(dd_CloseButton, 1);
	TextDrawAlignment		(dd_CloseButton, 1);
	TextDrawColor			(dd_CloseButton, -16776961);
	TextDrawBackgroundColor	(dd_CloseButton, 255);
	TextDrawBoxColor		(dd_CloseButton, 0);
	TextDrawUseBox			(dd_CloseButton, 0);
	TextDrawSetProportional	(dd_CloseButton, 1);
	TextDrawSetSelectable	(dd_CloseButton, 1);

	dd_PrevPageButton = TextDrawCreate(160.000000, 180.0 + (DD_MAX_PAGE_ITEMS + 1 * 20.0), "__________<<");
	TextDrawFont			(dd_PrevPageButton, 3);
	TextDrawLetterSize		(dd_PrevPageButton, 0.400000, 1.600000);
	TextDrawTextSize		(dd_PrevPageButton, 320.000000, 20.000000);
	TextDrawSetOutline		(dd_PrevPageButton, 1);
	TextDrawSetShadow		(dd_PrevPageButton, 1);
	TextDrawAlignment		(dd_PrevPageButton, 1);
	TextDrawColor			(dd_PrevPageButton, DD_BOX_TEXT_COLOR);
	TextDrawBackgroundColor	(dd_PrevPageButton, 255);
	TextDrawBoxColor		(dd_PrevPageButton, 60);
	TextDrawUseBox			(dd_PrevPageButton, 0);
	TextDrawSetProportional	(dd_PrevPageButton, 1);
	TextDrawSetSelectable	(dd_PrevPageButton, 1);

	dd_NextPageButton = TextDrawCreate(320.000000, 180.0 + (DD_MAX_PAGE_ITEMS + 1 * 20.0), "__________>>");
	#undef DD_MAX_PAGE_ITEMS
	TextDrawFont			(dd_NextPageButton, 3);
	TextDrawLetterSize		(dd_NextPageButton, 0.400000, 1.600000);
	TextDrawTextSize		(dd_NextPageButton, 480.000000, 20.000000);
	TextDrawSetOutline		(dd_NextPageButton, 1);
	TextDrawSetShadow		(dd_NextPageButton, 1);
	TextDrawAlignment		(dd_NextPageButton, 1);
	TextDrawColor			(dd_NextPageButton, DD_BOX_TEXT_COLOR);
	#undef DD_BOX_TEXT_COLOR
	TextDrawBackgroundColor	(dd_NextPageButton, 255);
	TextDrawBoxColor		(dd_NextPageButton, 60);
	TextDrawUseBox			(dd_NextPageButton, 0);
	TextDrawSetProportional	(dd_NextPageButton, 1);
	TextDrawSetSelectable	(dd_NextPageButton, 1);

	print("Dialog Draw(v1.0) by kolor4do loaded.");
	#if defined dd_OnGameModeInit
		return dd_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit dd_OnGameModeInit
#if defined dd_OnGameModeInit
	forward dd_OnGameModeInit();
#endif

public OnGameModeExit()
{
	TextDrawDestroy(dd_Box);
	TextDrawDestroy(dd_CloseButton);
	TextDrawDestroy(dd_PrevPageButton);
	TextDrawDestroy(dd_NextPageButton);
	#if defined dd_OnGameModeExit
		return dd_OnGameModeExit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeExit
	#undef OnGameModeExit
#else
	#define _ALS_OnGameModeExit
#endif
#define OnGameModeExit dd_OnGameModeExit
#if defined dd_OnGameModeExit
	forward dd_OnGameModeExit();
#endif