
#include <YSI_Coding\y_hooks>


#define MAX_BODY_LABEL (15)

static
PlayerText:	bod_LabelDraw	[MAX_PLAYERS][MAX_BODY_LABEL] = {PlayerText:INVALID_TEXT_DRAW, ...},
			bod_LabelIndex	[MAX_PLAYERS];

/*==============================================================================

	Functions

==============================================================================*/

ShowPlayerHealthInfo(playerid)
{
	new
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate,
		Float:hunger = GetPlayerFP(playerid),
		infected1 = GetPlayerInfectionIntensity(playerid, 0),
		infected2 = GetPlayerInfectionIntensity(playerid, 1),
		boxcolor = 164;

	drugs = GetPlayerDrugsList(playerid, drugslist);
	GetPlayerBleedRate(playerid, bleedrate);

	if(bod_LabelIndex[playerid] != 0)
		HideBodyPreviewUI(playerid);
		
	if(GetPlayerWounds(playerid) < 2)
		boxcolor = 164;
	else if(GetPlayerWounds(playerid) < 3)
		boxcolor = 0xd6cb0055;
	else 
		boxcolor = 0xb3000055;

	SetBodyPreviewLabel(playerid, sprintf("Feridas: %d", GetPlayerWounds(playerid)), 0xFFFFFFFF, boxcolor);

	if(bleedrate * 3200.0 > 10.0)
		boxcolor = 0xb3000055;
	else if(bleedrate * 3200.0 < 3.0)
		boxcolor = 164;
	else 
		boxcolor = 0xd6cb0055;

	if(bleedrate > 0)
		SetBodyPreviewLabel(playerid, sprintf("Sangramento: %0.1f%", bleedrate * 3200.0),
			0xFFFFFFFF, boxcolor);


	if(hunger >= 40.0)
		boxcolor = 164;
	else if(hunger < 30.0)
		boxcolor = 0xb3000055;
	else 
		boxcolor = 0xd6cb0055;

	if(hunger < 90.0)
		SetBodyPreviewLabel(playerid, sprintf("Fome: %0.1f%", hunger), 0xFFFFFFFF, boxcolor);

	if(infected1)
		SetBodyPreviewLabel(playerid, "Infecao alimentar", 0xFF0000FF, 0xd6cb0055);

	if(infected2)
		SetBodyPreviewLabel(playerid, "Infecao de Ferida", 0xFF0000FF, 0xd6cb0055);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, drugname, 0xFFFFFFFF, 0xd6cb0055);
	}

	SetBodyPreviewLabel(playerid, sprintf("Chance de Desmaio: %d%", floatround((GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6) / 2)) ), 0xFFFFFFFF);
}

HideBodyPreviewUI(playerid)
{
	for(new i; i <= bod_LabelIndex[playerid]; i++)
	{
		PlayerTextDrawHide(playerid, bod_LabelDraw[playerid][i]);
	}

	bod_LabelIndex[playerid] = 0;
}

SetBodyPreviewLabel(playerid, const string[], textcolour, boxcolor = 164)
{
	if(bod_LabelIndex[playerid] >= MAX_BODY_LABEL - 1)
		return 0;
		
	PlayerTextDrawSetString(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], string);
	PlayerTextDrawColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], textcolour);
	PlayerTextDrawBoxColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], boxcolor);
	PlayerTextDrawShow(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]]);

	return ++ bod_LabelIndex[playerid];
}

/*==============================================================================

	Show

==============================================================================*/

hook OnPlayerConnect(playerid)
{
	bod_LabelIndex[playerid] = 0;

	for(new i; i < MAX_BODY_LABEL; i++)
	{
		bod_LabelDraw[playerid][i] = CreatePlayerTextDraw(playerid, 3.000000, 183 + (i * 22.0), "Text");
		PlayerTextDrawFont(playerid, bod_LabelDraw[playerid][i], 2);
		PlayerTextDrawLetterSize(playerid, bod_LabelDraw[playerid][i], 0.229100, 1.049999);
		PlayerTextDrawTextSize(playerid, bod_LabelDraw[playerid][i], 133.500000, 17.000000);
		PlayerTextDrawSetOutline(playerid, bod_LabelDraw[playerid][i], 1);
		PlayerTextDrawAlignment(playerid, bod_LabelDraw[playerid][i], 1);
		PlayerTextDrawColor(playerid, bod_LabelDraw[playerid][i], -1);
		PlayerTextDrawBackgroundColor(playerid, bod_LabelDraw[playerid][i], 255);
		PlayerTextDrawBoxColor(playerid, bod_LabelDraw[playerid][i], 0);
		PlayerTextDrawUseBox(playerid, bod_LabelDraw[playerid][i], 1);
		PlayerTextDrawSetProportional(playerid, bod_LabelDraw[playerid][i], 1);
	}
}

hook OnPlayerOpenInventory(playerid)
{
	ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Hide

==============================================================================*/

hook OnPlayerCloseInventory(playerid)
{
	HideBodyPreviewUI(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDeath(playerid, killerid, reason)
{
	HideBodyPreviewUI(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, Container:containerid)
{
	HideBodyPreviewUI(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDisconnect(playerid)
{
	for(new i; i <= MAX_BODY_LABEL; i++)
	{
		if(bod_LabelDraw[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, bod_LabelDraw[playerid][i]);
			bod_LabelDraw[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
		}
	}
}
