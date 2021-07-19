
#include <YSI_Coding\y_hooks>


#define MAX_BODY_LABEL (15)

static
PlayerText:	bod_LabelDraw	[MAX_PLAYERS][MAX_BODY_LABEL] = { PlayerText:INVALID_TEXT_DRAW, ...},
			bod_LabelIndex	[MAX_PLAYERS];

/*==============================================================================

	Functions

==============================================================================*/

timer ShowPlayerHealthInfo[10](playerid)
{
	HideBodyPreviewUI(playerid);

	new Container:containerid;
	GetPlayerCurrentContainer(playerid, containerid);

	if(!IsValidContainer(containerid) && !IsPlayerViewingInventory(playerid))
		return;

	new
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate,
		Float:hunger = GetPlayerFP(playerid),
		infected1 = GetPlayerInfectionIntensity(playerid, 0),
		infected2 = GetPlayerInfectionIntensity(playerid, 1),
		boxcolor = 50;

	drugs = GetPlayerDrugsList(playerid, drugslist);
	GetPlayerBleedRate(playerid, bleedrate);

	if(GetPlayerWounds(playerid) < 2)
		boxcolor = 50;
	else if(GetPlayerWounds(playerid) < 3)
		boxcolor = 0xd6cb0055;
	else 
		boxcolor = 0xb3000055;

	SetBodyPreviewLabel(playerid, sprintf("Feridas: %d", GetPlayerWounds(playerid)), 0xFFFFFFFF, boxcolor);


	if(bleedrate * 3200.0 > 10.0)
		boxcolor = 0xb3000055;
	else if(bleedrate * 3200.0 < 3.0)
		boxcolor = 50;
	else 
		boxcolor = 0xd6cb0055;

	if(bleedrate > 0)
		SetBodyPreviewLabel(playerid, sprintf("Sangramento: %0.1f%", bleedrate * 3200.0),
			RGBAToHex(truncateforbyte(floatround(bleedrate * 3200.0)), truncateforbyte(255 - floatround(bleedrate * 3200.0)), 0, 255), boxcolor);


	if(hunger >= 40.0)
		boxcolor = 50;
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

	return;
}

stock HideBodyPreviewUI(playerid)
{
	for(new i; i <= bod_LabelIndex[playerid]; i++)
	{
		if(bod_LabelDraw[playerid][i] != PlayerText:INVALID_TEXT_DRAW)
		{
			PlayerTextDrawDestroy(playerid, bod_LabelDraw[playerid][i]);
			bod_LabelDraw[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
		}
	}

	bod_LabelIndex[playerid] = 0;
}

stock SetBodyPreviewLabel(playerid, const string[], textcolour, boxcolor = 50)
{
	if(bod_LabelIndex[playerid] >= MAX_BODY_LABEL - 1){
		err(true, true, "Numero de bodypreview excedido, index: %d/%d", bod_LabelIndex[playerid], MAX_BODY_LABEL);
		return bod_LabelIndex[playerid];
	}

	bod_LabelDraw[playerid][bod_LabelIndex[playerid]] = CreatePlayerTextDraw(playerid, 3.000000, GEAR_POS_Y + (bod_LabelIndex[playerid] * 22.0), string);
	PlayerTextDrawFont(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 2);
	PlayerTextDrawLetterSize(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 0.229100, 1.049999);
	PlayerTextDrawTextSize(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 133.500000, 17.000000);
	PlayerTextDrawSetOutline(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);
	PlayerTextDrawAlignment(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);
	PlayerTextDrawColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], textcolour);
	PlayerTextDrawBackgroundColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 255);
	PlayerTextDrawBoxColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], boxcolor);
	PlayerTextDrawUseBox(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);
	PlayerTextDrawSetProportional(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);

	PlayerTextDrawShow(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]]);

	bod_LabelIndex[playerid] ++;

	return bod_LabelIndex[playerid];
}

/*==============================================================================

	Callbacks

==============================================================================*/

hook OnPlayerConnect(playerid)
{
	bod_LabelIndex[playerid] = 0;

	for(new i; i < MAX_BODY_LABEL; i++)
	{
		bod_LabelDraw[playerid][i] = PlayerText:INVALID_TEXT_DRAW;
	}
}

hook OnPlayerOpenInventory(playerid)
{
	defer ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	defer ShowPlayerHealthInfo(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

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
