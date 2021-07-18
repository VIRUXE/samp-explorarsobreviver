
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
		infected2 = GetPlayerInfectionIntensity(playerid, 1);

	drugs = GetPlayerDrugsList(playerid, drugslist);
	GetPlayerBleedRate(playerid, bleedrate);

	SetBodyPreviewLabel(playerid, sprintf("Feridas: %d", GetPlayerWounds(playerid)),
		GetPlayerWounds(playerid) ? RGBAToHex(max(GetPlayerWounds(playerid) * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	if(bleedrate > 0)
		SetBodyPreviewLabel(playerid, sprintf("Sangramento: %0.1f%", bleedrate * 3200.0), RGBAToHex(truncateforbyte(floatround(bleedrate * 3200.0)), truncateforbyte(255 - floatround(bleedrate * 3200.0)), 0, 255));

	if(hunger < 90.0)
		SetBodyPreviewLabel(playerid, sprintf("Energia: %0.1f%", hunger), RGBAToHex(truncateforbyte(floatround((66.6 - hunger) * 4.8)), truncateforbyte(255 - floatround((66.6 - hunger) * 4.8)), 0, 255));

	if(infected1)
		SetBodyPreviewLabel(playerid, "Infecao alimentar", 0xFF0000FF);

	if(infected2)
		SetBodyPreviewLabel(playerid, "Infecao de Ferida", 0xFF0000FF);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, drugname, RED);
	}

	SetBodyPreviewLabel(playerid, sprintf("Chance de Desmaio: %.1f%%", (GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6) / 2) ), 0xFFFFFFFF);

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

stock SetBodyPreviewLabel(playerid, const string[], textcolour)
{
	if(bod_LabelIndex[playerid] >= MAX_BODY_LABEL - 1){
		err(true, true, "Numero de bodypreview excedido, index: %d/%d", bod_LabelIndex[playerid], MAX_BODY_LABEL);
		return bod_LabelIndex[playerid];
	}

	bod_LabelDraw[playerid][bod_LabelIndex[playerid]] = CreatePlayerTextDraw(playerid, 2.000000, GEAR_POS_Y + (bod_LabelIndex[playerid] * 22.0), string);
	PlayerTextDrawFont(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 2);
	PlayerTextDrawLetterSize(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 0.229166, 1.049999);
	PlayerTextDrawTextSize(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 131.500000, 17.000000);
	PlayerTextDrawSetOutline(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);
	PlayerTextDrawAlignment(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 1);
	PlayerTextDrawColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], textcolour);
	PlayerTextDrawBackgroundColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 255);
	PlayerTextDrawBoxColor(playerid, bod_LabelDraw[playerid][bod_LabelIndex[playerid]], 50);
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
