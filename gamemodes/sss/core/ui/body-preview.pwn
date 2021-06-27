/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>


#define MAX_BODY_LABEL (16)


enum E_BODY_LABEL_DATA
{
bool:		bl_valid,
PlayerText:	bl_textdraw,
Float:		bl_posY
}


static
Float:		bod_UIPositionX	[MAX_PLAYERS] = {80.0, ...},
Float:		bod_UIPositionY	[MAX_PLAYERS] = {190.0, ...},
Float:		bod_UIFontSizeX	[MAX_PLAYERS] = {0.25, ...},
Float:		bod_UIFontSizeY	[MAX_PLAYERS] = {1.05, ...},
			bod_LabelData0	[MAX_PLAYERS][MAX_BODY_LABEL][E_BODY_LABEL_DATA],
			bod_LabelData1	[MAX_PLAYERS][MAX_BODY_LABEL][E_BODY_LABEL_DATA],
			bod_LabelIndex0	[MAX_PLAYERS],
			bod_LabelIndex1	[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	bod_LabelIndex0[playerid] = 0;
	bod_LabelIndex1[playerid] = 0;

	for(new i; i < MAX_BODY_LABEL; i++)
	{
		bod_LabelData0[playerid][i][bl_valid] = false;
		bod_LabelData1[playerid][i][bl_valid] = false;
		bod_LabelData0[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
		bod_LabelData1[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}
}

stock HideBodyPreviewUI(playerid)
{
	for(new i; i <= bod_LabelIndex0[playerid]; i++)
	{
		PlayerTextDrawDestroy(playerid, bod_LabelData0[playerid][i][bl_textdraw]);
		bod_LabelData0[playerid][i][bl_valid] = false;
		bod_LabelData0[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}

	for(new i; i <= bod_LabelIndex1[playerid]; i++)
	{
		PlayerTextDrawDestroy(playerid, bod_LabelData1[playerid][i][bl_textdraw]);
		bod_LabelData1[playerid][i][bl_valid] = false;
		bod_LabelData1[playerid][i][bl_textdraw] = PlayerText:INVALID_TEXT_DRAW;
	}

	bod_LabelIndex0[playerid] = 0;
	bod_LabelIndex1[playerid] = 0;
}

stock SetBodyPreviewLabel(playerid, side, index, Float:spacing, const string[], textcolour)
{
	new Float:ypos;

	// left
	if(!side)
	{
		if(bod_LabelData0[playerid][index][bl_valid])
		{
			PlayerTextDrawSetString(playerid, bod_LabelData0[playerid][index][bl_textdraw], string);
			PlayerTextDrawColor(playerid, bod_LabelData0[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawShow(playerid, bod_LabelData0[playerid][index][bl_textdraw]);
		}
		else
		{
			bod_LabelData0[playerid][index][bl_valid] = true;

			if(index > bod_LabelIndex0[playerid])
				bod_LabelIndex0[playerid] = index;

			if(index == 0)
				ypos = bod_UIPositionY[playerid] + spacing;

			else
				ypos = bod_LabelData0[playerid][index - 1][bl_posY] + spacing;

			bod_LabelData0[playerid][index][bl_posY] = ypos;

			bod_LabelData0[playerid][index][bl_textdraw]=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid] - 76.0, ypos, string);
			PlayerTextDrawAlignment			(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawBackgroundColor	(playerid, bod_LabelData0[playerid][index][bl_textdraw], 175);
			PlayerTextDrawFont				(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawLetterSize		(playerid, bod_LabelData0[playerid][index][bl_textdraw], bod_UIFontSizeX[playerid], bod_UIFontSizeY[playerid]);
			PlayerTextDrawColor				(playerid, bod_LabelData0[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawSetOutline		(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetProportional	(playerid, bod_LabelData0[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetShadow			(playerid, bod_LabelData0[playerid][index][bl_textdraw], 0);
			PlayerTextDrawTextSize			(playerid, bod_LabelData0[playerid][index][bl_textdraw], bod_UIPositionX[playerid], 10.0);
			PlayerTextDrawSetSelectable		(playerid, bod_LabelData0[playerid][index][bl_textdraw], true);

			PlayerTextDrawShow(playerid, bod_LabelData0[playerid][index][bl_textdraw]);
		}
	}
	// Right
	else
	{
		if(bod_LabelData1[playerid][index][bl_valid])
		{
			PlayerTextDrawSetString(playerid, bod_LabelData1[playerid][index][bl_textdraw], string);
			PlayerTextDrawColor(playerid, bod_LabelData1[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawShow(playerid, bod_LabelData1[playerid][index][bl_textdraw]);
		}
		else
		{
			bod_LabelData1[playerid][index][bl_valid] = true;

			if(index > bod_LabelIndex1[playerid])
				bod_LabelIndex1[playerid] = index;

			if(index == 0)
				ypos = bod_UIPositionY[playerid] + spacing;

			else
				ypos = bod_LabelData1[playerid][index - 1][bl_posY] + spacing;

			bod_LabelData1[playerid][index][bl_posY] = ypos;

			bod_LabelData1[playerid][index][bl_textdraw]=CreatePlayerTextDraw(playerid, bod_UIPositionX[playerid] + 45.0, ypos, string);
			PlayerTextDrawAlignment			(playerid, bod_LabelData1[playerid][index][bl_textdraw], 3);
			PlayerTextDrawBackgroundColor	(playerid, bod_LabelData1[playerid][index][bl_textdraw], 175);
			PlayerTextDrawFont				(playerid, bod_LabelData1[playerid][index][bl_textdraw], 1);
			PlayerTextDrawLetterSize		(playerid, bod_LabelData1[playerid][index][bl_textdraw], bod_UIFontSizeX[playerid], bod_UIFontSizeY[playerid]);
			PlayerTextDrawColor				(playerid, bod_LabelData1[playerid][index][bl_textdraw], textcolour);
			PlayerTextDrawSetOutline		(playerid, bod_LabelData1[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetProportional	(playerid, bod_LabelData1[playerid][index][bl_textdraw], 1);
			PlayerTextDrawSetShadow			(playerid, bod_LabelData1[playerid][index][bl_textdraw], 0);
			PlayerTextDrawTextSize			(playerid, bod_LabelData1[playerid][index][bl_textdraw], bod_UIPositionX[playerid], 10.0);
			PlayerTextDrawSetSelectable		(playerid, bod_LabelData1[playerid][index][bl_textdraw], true);

			PlayerTextDrawShow(playerid, bod_LabelData1[playerid][index][bl_textdraw]);
		}
	}

	return index;
}