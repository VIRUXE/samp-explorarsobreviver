#include <YSI_Coding\y_hooks>

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	TutorialDraw		[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialProgress	[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...},
Item:		PlayerTutorial_Item     [MAX_TUTORIAL_ITEMS][MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	TutorialDraw[playerid] = CreatePlayerTextDraw(playerid, 4.000000, 325.000000, ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawFont(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TutorialDraw[playerid], 0.375000, 1.600000);
	PlayerTextDrawTextSize(playerid, TutorialDraw[playerid], 187.000000, 17.000000);
	PlayerTextDrawSetOutline(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawSetShadow(playerid, TutorialDraw[playerid], 0);
	PlayerTextDrawAlignment(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawColor(playerid, TutorialDraw[playerid], -1);
	PlayerTextDrawBackgroundColor(playerid, TutorialDraw[playerid], 255);
	PlayerTextDrawBoxColor(playerid, TutorialDraw[playerid], 255);
	PlayerTextDrawUseBox(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, TutorialDraw[playerid], true);

	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
	PlayerInTutorial[playerid] = false;
	PlayerTutorialProgress[playerid] = 0;
}

hook OnPlayerSpawnChar(playerid)
{
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
}

hook OnPlayerCreateChar(playerid)
{
	PlayerTextDrawBoxColor(playerid, TutorialDraw[playerid], 255);
	PlayerTextDrawSetString(playerid, TutorialDraw[playerid], ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawShow(playerid, TutorialDraw[playerid]);
}

hook OnHoldActionUpdate(playerid, progess)
	defer UpdateTutorialProgress(playerid);

timer UpdateTutorialProgress[500](playerid)
{
	if(!PlayerInTutorial[playerid]) 
		return 0;

	new 
		str[300] = "____~y~Tarefas do Tutorial:~n~",
		Float:health,
		tentid,
		bool:active,
		progress;


	if(IsValidItem(GetPlayerBagItem(playerid)))
		strcat(str, "~g~V Vestir Mochila~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Vestir Mochila~n~");


	GetVehicleHealth(PlayerTutorialVehicle[playerid], health);

	if(health > 800.0)
		strcat(str, "~g~V Reparar Veiculo~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Reparar Veiculo~n~");


	GetItemExtraData(PlayerTutorial_Item[9][playerid], tentid);

	if(IsValidTent(tentid))
		strcat(str, "~g~V Montar Tenda~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Montar Tenda~n~");
	

	GetItemArrayDataAtCell(PlayerTutorial_Item[0][playerid], active, 0);
	if(active)
		strcat(str, "~g~V Montar Entrada~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Montar Entrada~n~");

	active = false;


	GetItemArrayDataAtCell(PlayerTutorial_Item[1][playerid], active, 0);
	if(active)
		strcat(str, "~g~V Montar Porta~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Montar Porta~n~");


	if(IsValidItem(GetPlayerHolsterItem(playerid)))
		strcat(str, "~g~V Colocar arma no Coldre"), progress ++;
	else
		strcat(str, "~r~X~w~ Colocar arma no Coldre");

	PlayerTextDrawBackgroundColor(playerid, TutorialDraw[playerid], 255);
	PlayerTextDrawBoxColor(playerid, TutorialDraw[playerid], 842150655);
	
	if(progress == 6) 
		PlayerTextDrawSetString(playerid, TutorialDraw[playerid],
			"~g~Tarefas concluidas, parabens!~n~Para sair do tutorial use ~w~/sair~n~\
			~g~Caso tenha alguma duvida, envie um ~w~/relatorio~g~ que tentaremos responder o mais rapido possivel!");	
	else
		PlayerTextDrawSetString(playerid, TutorialDraw[playerid], str);

	PlayerTutorialProgress[playerid] = progress;

	PlayerTextDrawShow(playerid, TutorialDraw[playerid]);
	return 0;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == TutorialDraw[playerid])
	{
		EnterTutorial(playerid);
	}
}

hook OnVehicleSave(vehicleid)
{
	foreach(new i : Player)
	{
		if(vehicleid == PlayerTutorialVehicle[i])
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSpawn(playerid)
{
	if(PlayerInTutorial[playerid])
		EnterTutorial(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
	ExitTutorial(playerid);

hook OnPlayerRegister(playerid)
	ExitTutorial(playerid);

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = PlayerInTutorial[playerid];

	modio_push(filename, _T<T,U,T,R>, 1, _:data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];

	modio_read(filename, _T<T,U,T,R>, 1, _:data);

	PlayerInTutorial[playerid] = bool:data[0];
	if(PlayerInTutorial[playerid])
		EnterTutorial(playerid);
}
	
stock EnterTutorial(playerid)
{
	SetPlayerPos(playerid, 928.8049,2072.3174,10.8203);
	SetPlayerFacingAngle(playerid, 269.3244);
	SetPlayerVirtualWorld(playerid, playerid + 1);

	switch(random(14))
	{
		case 0: SetPlayerClothesID(playerid, skin_Civ0M);
		case 1: SetPlayerClothesID(playerid, skin_Civ1M);
		case 2: SetPlayerClothesID(playerid, skin_Civ2M);
		case 3: SetPlayerClothesID(playerid, skin_Civ3M);
		case 4: SetPlayerClothesID(playerid, skin_Civ4M);
		case 5: SetPlayerClothesID(playerid, skin_MechM);
		case 6: SetPlayerClothesID(playerid, skin_BikeM);
		case 7: SetPlayerClothesID(playerid, skin_Civ0F);
		case 8: SetPlayerClothesID(playerid, skin_Civ1F);
		case 9: SetPlayerClothesID(playerid, skin_Civ2F);
		case 10: SetPlayerClothesID(playerid, skin_Civ3F);
		case 11: SetPlayerClothesID(playerid, skin_Civ4F);
		case 12: SetPlayerClothesID(playerid, skin_ArmyF);
		case 13: SetPlayerClothesID(playerid, skin_IndiF);
	}

	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid)));
	
	SetPlayerHP(playerid, 100.0);
	SetPlayerAP(playerid, 0.0);
	SetPlayerFP(playerid, 80.0);
	SetPlayerBleedRate(playerid, 0.0);

	SetPlayerAliveState(playerid, false);
	SetPlayerSpawnedState(playerid, false);

	FreezePlayer(playerid, SEC(gLoginFreezeTime));
	PrepareForSpawn(playerid);

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);

	SetPlayerBrightness(playerid, 255);

	PlayerInTutorial[playerid] = true;

	if(PlayerTutorialVehicle[playerid] != INVALID_VEHICLE_ID)
		DestroyWorldVehicle(PlayerTutorialVehicle[playerid], true);

	//	Vehicle
	PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 949.1641,2060.3074,10.8203, 272.1444, random(100), random(100), .world = playerid + 1);
	SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
	SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
	FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, GetLootIndexFromName("world_civilian"));
	SetVehicleDamageData(PlayerTutorialVehicle[playerid],
		encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
		encode_doors(random(5), random(5), random(5), random(5)),
		encode_lights(random(2), random(2), random(2), random(2)),
		encode_tires(1, 1, 1, 0) );

	//	Items
	PlayerTutorial_Item[0][playerid] = CreateItem(item_InsulDoor, 975.1069,2071.6677,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	SetItemLabel(PlayerTutorial_Item[0][playerid], "Entrada Isolada - Monte com Chave de Fenda", .range = 15.0);
	PlayerTutorial_Item[1][playerid] = CreateItem(item_WoodDoor, 974.1069,2070.6677,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	SetItemLabel(PlayerTutorial_Item[1][playerid], "Porta de Madeira - Monte com Chave de Fenda", .range = 15.0);
	PlayerTutorial_Item[2][playerid] = CreateItem(item_Spanner, 945.02, 2069.25,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[3][playerid] = CreateItem(item_Wheel, 951.7727,2068.0540,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[4][playerid] = CreateItem(item_Wheel, 954.4612,2068.2312,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[5][playerid] = CreateItem(item_Wheel, 952.7346,2070.6902,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[6][playerid] = CreateItem(item_Wrench, 948.3666,2069.8452,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[7][playerid] = CreateItem(item_Screwdriver, 946.4836,2069.7207,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[8][playerid] = CreateItem(item_Hammer, 944.1250,2067.6262,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[9][playerid] = CreateItem(item_TentPack, 944.1473,2083.2739,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[10][playerid] = CreateItem(item_Hammer, 949.4579,2082.9829,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[11][playerid] = CreateItem(item_Crowbar, 947.3903,2080.4143,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[12][playerid] = CreateItem(item_Crowbar, 951.6076,2067.8994,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[13][playerid] = CreateItem(item_Keypad, 971.9176,2069.2117,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[14][playerid] = CreateItem(item_Motor, 971.4994,2072.1038,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[15][playerid] = CreateItem(item_Rucksack, 931.9263,2081.7053,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[16][playerid] = CreateItem(item_LargeBox, 927.8030,2058.6838,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[17][playerid] = CreateItem(item_MediumBox, 929.4532,2058.3926,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[18][playerid] = CreateItem(item_SmallBox, 932.5464,2058.3267,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[19][playerid] = CreateItem(item_PumpShotgun, 959.1787,2082.9680,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	PlayerTutorial_Item[20][playerid] = CreateItem(item_AmmoBuck, 961.2108,2083.3938,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	
	SetItemExtraData(PlayerTutorial_Item[20][playerid], 12);

	PlayerTutorial_Item[21][playerid] = CreateItem(item_GasCan, 938.4733,2063.2769,9.8603, .rz = frandom(360.0), .world = playerid + 1);
	SetLiquidItemLiquidType(PlayerTutorial_Item[21][playerid], liquid_Petrol);
	SetLiquidItemLiquidAmount(PlayerTutorial_Item[21][playerid], 15);

	// Message
	for(new i = 0; i < 20; i++)
		SendClientMessage(playerid, GREEN, "");

	ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINTROD"));
	ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTOREXITCM"));

	defer UpdateTutorialProgress(playerid);
}

stock ExitTutorial(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!PlayerInTutorial[playerid])
		return 0;
		
	for(new i = MAX_INVENTORY_SLOTS - 1; i >= 0; i--)
		RemoveItemFromInventory(playerid, i);

	ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORIEXIT"));
	log(true, "[TUTORIAL] %p saiu do tutorial.", playerid);
	
	RemovePlayerBag(playerid);
	RemovePlayerHolsterItem(playerid);
	
	SetPlayerPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	PlayerInTutorial[playerid] = false;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);
	SetPlayerVirtualWorld(playerid, 0);
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 255);

	for(new i = 0; i < MAX_TUTORIAL_ITEMS; i++)
		if(IsValidItem(PlayerTutorial_Item[i][playerid]))
			DestroyItem(PlayerTutorial_Item[i][playerid]);

	for(new i = 0; i < 20; i++)
		SendClientMessage(playerid, GREEN, "");

	return 1;
}

hook OnPlayerWearBag(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
  		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");
		
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));

		defer UpdateTutorialProgress(playerid);
	}

	return 0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(PlayerInTutorial[playerid])
	{
  		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");
			
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINTINV"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	if(PlayerInTutorial[playerid])
	{
		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
			{
				for(new i = 0; i < 20; i++)
					SendClientMessage(playerid, GREEN, "");
				
				ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINTBAG"));
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	if(PlayerInTutorial[playerid])
	{
		new Item:itemid, slot;

		GetPlayerContainerSlot(playerid, slot);
		GetContainerSlotItem(containerid, slot, itemid);

		if(GetItemType(itemid) == item_Wrench)
		{
  			for(new i = 0; i < 20; i++)
				SendClientMessage(playerid, GREEN, "");

			ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORDROITM"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, Item:itemid, slot)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINVADD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(IsPlayerConnected(playerid))
	{
		if(PlayerInTutorial[playerid])
		{
			if(IsValidItem(GetPlayerBagItem(playerid)))
			{
				if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
				{
					for(new i = 0; i < 20; i++)
						SendClientMessage(playerid, GREEN, "");

					ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORADDBAG"));
				}
			}
			else
			{
				for(new i = 0; i < 20; i++)
					SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORADDCNT"));
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMHOL"));

		defer UpdateTutorialProgress(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMUSE"));
	}
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
		if(IsItemTypeDefence(GetItemType(itemid)))
		{
			for(new i = 0; i < 20; i++)
				SendClientMessage(playerid, GREEN, "");

			ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORIDEF"));
		}
		
		defer UpdateTutorialProgress(playerid);
	}
}

CMD:sair(playerid, params[])
{
	if(PlayerTutorialProgress[playerid] == 6)
	{
		ExitTutorial(playerid);
		DisplayRegisterPrompt(playerid);
	}
	else ShowActionText(playerid, "~R~Voce precisa fazer as tarefas para sair");
	
	return 1;
}
CMD:exit(playerid, params[]) return cmd_sair(playerid, params);

stock IsPlayerInTutorial(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;
		
	if(PlayerInTutorial[playerid])
		return 1;

	return 0;
}