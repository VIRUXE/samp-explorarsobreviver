/* 
	The tutorial only can only be executed if you don't have an account.

	No need to do it ever again, since you're already forced to do it before registering.

	VIRUXE
 */

#include <YSI_Coding\y_hooks>

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	tut_TaskBoard[MAX_PLAYERS],
bool:		tut_Active[MAX_PLAYERS],
			tut_Progress[MAX_PLAYERS],
			tut_Vehicle[MAX_PLAYERS],
Item:		tut_Items[MAX_PLAYERS][MAX_TUTORIAL_ITEMS];

forward OnPlayerEnterTutorial(playerid);
forward OnPlayerExitTutorial(playerid);

hook OnAccountCheck(playerid, result)
{
	if(result == ACCOUNT_STATE_UNREGISTERED) // If account checks out as unregistered, then put the player in the tutorial
	{
		// Create Tasks Board Textdraw for the Player
		tut_TaskBoard[playerid] = CreatePlayerTextDraw(playerid, 4.000000, 327.000000, "Tarefas do Tutorial");
		PlayerTextDrawFont(playerid, tut_TaskBoard[playerid], 1);
		PlayerTextDrawLetterSize(playerid, tut_TaskBoard[playerid], 0.375000, 1.600000);
		PlayerTextDrawTextSize(playerid, tut_TaskBoard[playerid], 187.000000, 17.000000);
		PlayerTextDrawSetOutline(playerid, tut_TaskBoard[playerid], 1);
		PlayerTextDrawSetShadow(playerid, tut_TaskBoard[playerid], 0);
		PlayerTextDrawAlignment(playerid, tut_TaskBoard[playerid], 1);
		PlayerTextDrawColor(playerid, tut_TaskBoard[playerid], -1);
		PlayerTextDrawBackgroundColor(playerid, tut_TaskBoard[playerid], 255);
		PlayerTextDrawBoxColor(playerid, tut_TaskBoard[playerid], 255);
		PlayerTextDrawUseBox(playerid, tut_TaskBoard[playerid], 1);
		PlayerTextDrawSetProportional(playerid, tut_TaskBoard[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, tut_TaskBoard[playerid], true);

		PlayerTextDrawShow(playerid, tut_TaskBoard[playerid]); // Creio que não fica logo visivel quando inicializa?

		ToggleTutorialForPlayer(playerid, true);
	}
}

hook OnPlayerDisconnect(playerid, reason) // Garbage disposal
{
	if(tut_Active[playerid])
		DestroyTutorialForPlayer(playerid);
}

/* hook OnPlayerCreateChar(playerid)
{
	PlayerTextDrawBoxColor(playerid, tut_TaskBoard[playerid], 255);
	PlayerTextDrawSetString(playerid, tut_TaskBoard[playerid], ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawShow(playerid, tut_TaskBoard[playerid]);
} */

hook OnHoldActionUpdate(playerid, progess)
	defer UpdateTutorialProgress(playerid);

timer UpdateTutorialProgress[500](playerid)
{
	if(!tut_Active[playerid]) 
		return 0;

	new 
		str[300] = "____~y~Tarefas do Tutorial:~n~",
		Float:health,
		tentid,
		bool:active,
		progress;

	if(IsValidItem(GetPlayerBagItem(playerid)))
		strcat(str, "~g~V Vestir Mochila~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Vestir Mochila~n~");

	GetVehicleHealth(tut_Vehicle[playerid], health);

	if(health > 800.0)
		strcat(str, "~g~V Reparar Veiculo~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Reparar Veiculo~n~");

	GetItemExtraData(tut_Items[9][playerid], tentid);

	if(IsValidTent(tentid))
		strcat(str, "~g~V Montar Tenda~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Montar Tenda~n~");
	
	GetItemArrayDataAtCell(tut_Items[1][playerid], active, 0);
	if(active)
		strcat(str, "~g~V Montar Porta com Chave~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Montar Porta com Chave~n~");

	if(IsValidItem(GetPlayerHolsterItem(playerid)))
		strcat(str, "~g~V Colocar arma no Coldre"), progress++;
	else
		strcat(str, "~r~X~w~ Colocar arma no Coldre");

	PlayerTextDrawBackgroundColor(playerid, tut_TaskBoard[playerid], 255);
	PlayerTextDrawBoxColor(playerid, tut_TaskBoard[playerid], 842150655);
	
	if(progress == 5) 
		PlayerTextDrawSetString(playerid, tut_TaskBoard[playerid],
			"~g~Tarefas concluidas, parabens!~n~Para sair do tutorial use ~w~/sair~n~\
			~g~Caso tenha alguma duvida, envie um ~w~/relatorio~g~ que tentaremos responder o mais rapido possivel!");	
	else
		PlayerTextDrawSetString(playerid, tut_TaskBoard[playerid], str);

	tut_Progress[playerid] = progress;

	PlayerTextDrawShow(playerid, tut_TaskBoard[playerid]);
	return 0;
}

hook OnVehicleSave(vehicleid) // Don't let the tutorial vehicle be saved
{
	if(vehicleid == tut_Vehicle[i])
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock DestroyTutorialForPlayer(playerid)
{
	// Delete Vehicle
	DestroyWorldVehicle(tut_Vehicle[playerid], true);

	// Delete Items
	for(new itemIdx; itemIdx > MAX_TUTORIAL_ITEMS; itemIdx++)
		DestroyItem(tut_Items[playerid][itemIdx]);

	// Reset the variables
	tut_TaskBoard[playerid] = INVALID_TEXT_DRAW;
	tut_Active[playerid] = false;
	tut_Progress[playerid] = 0;
	tut_Vehicle[playerid] = INVALID_VEHICLE_ID;

	// Não sei se necessita depois do DestroyItem, mas mais vale prevenir
	for(new itemIdx; itemIdx > MAX_TUTORIAL_ITEMS; itemIdx++)
		tut_Items[playerid][itemIdx] = INVALID_ITEM_ID;
}

stock ToggleTutorialForPlayer(playerid, toggle)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(toggle == tut_Active[playerid])
		return;
	else
		tut_Active[playerid] = toggle;

	if(tut_Active[playerid]) // Tutorial set to active, so let's create it
	{
		new 
			tutorialVirtualWorld = playerid+1,
			tutorialClothes;

		// ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTOREXITCM")); // Tutorial exit text

		// Spawn player in the tutorial warehouse and set the virtual world
		SetPlayerPos(playerid, 928.8049, 2072.3174, 10.8203); // Some warehouse in Las Venturas
		SetPlayerFacingAngle(playerid, 269.3244);
		SetPlayerVirtualWorld(playerid, tutorialVirtualWorld);

		// Apply a random skin to the player
		switch(random(14))
		{
			case 0: 	tutorialClothes = skin_Civ0M;
			case 1: 	tutorialClothes = skin_Civ1M;
			case 2: 	tutorialClothes = skin_Civ2M;
			case 3: 	tutorialClothes = skin_Civ3M;
			case 4: 	tutorialClothes = skin_Civ4M;
			case 5: 	tutorialClothes = skin_MechM;
			case 6: 	tutorialClothes = skin_BikeM;
			case 7: 	tutorialClothes = skin_Civ0F;
			case 8: 	tutorialClothes = skin_Civ1F;
			case 9: 	tutorialClothes = skin_Civ2F;
			case 10: 	tutorialClothes = skin_Civ3F;
			case 11: 	tutorialClothes = skin_Civ4F;
			case 12: 	tutorialClothes = skin_ArmyF;
			case 13: 	tutorialClothes = skin_IndiF;
		}
		SetPlayerClothesID(playerid, tutorialClothes);
		SetPlayerClothes(playerid, GetPlayerClothesID(playerid)); // TODO: Tornar mais eficiente? Ver como funciona mesma?
		SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid))); // TODO: Tornar mais eficiente? Ver como funciona mesma?

		// Create tutorial vehicle
		tut_Vehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 945.0064,2060.8013,10.7444,358.8053, random(100), random(100), .world = tutorialVirtualWorld);
		SetVehiclePos(tut_Vehicle[playerid], 945.0064,2060.8013,10.7444);
		SetVehicleZAngle(tut_Vehicle[playerid], 358.8053);
		SetVehicleHealth(tut_Vehicle[playerid], 321.9);
		SetVehicleFuel(tut_Vehicle[playerid], frandom(1.0));
		FillContainerWithLoot(GetVehicleContainer(tut_Vehicle[playerid]), 5, GetLootIndexFromName("world_civilian"));
		SetVehicleDamageData(tut_Vehicle[playerid],
			encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			encode_doors(random(5), random(5), random(5), random(5)),
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(1, 1, 1, 0)
		);

		//	Create tutorial items
		tut_Items[playerid][0] = 	CreateItem(item_Screwdriver, 	975.1069,2071.6677,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][1] = 	CreateItem(item_WoodDoor, 		974.1069,2070.6677,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][2] = 	CreateItem(item_Spanner, 		945.02, 2069.25,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][3] = 	CreateItem(item_Wheel, 			951.7727,2068.0540,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][4] = 	CreateItem(item_Wheel, 			954.4612,2068.2312,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][5] = 	CreateItem(item_Wheel, 			952.7346,2070.6902,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][6] = 	CreateItem(item_Wrench, 		948.3666,2069.8452,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][7] = 	CreateItem(item_Screwdriver, 	946.4836,2069.7207,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][8] = 	CreateItem(item_Hammer, 		944.1250,2067.6262,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][9] = 	CreateItem(item_TentPack, 		944.1473,2083.2739,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][10] = 	CreateItem(item_Hammer, 		949.4579,2082.9829,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][11] = 	CreateItem(item_Crowbar, 		947.3903,2080.4143,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][12] = 	CreateItem(item_Crowbar, 		951.6076,2067.8994,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][13] = 	CreateItem(item_Keypad, 		971.9176,2069.2117,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][14] = 	CreateItem(item_Motor, 			971.4994,2072.1038,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][15] = 	CreateItem(item_Rucksack, 		931.9263,2081.7053,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][16] = 	CreateItem(item_LargeBox, 		927.8030,2058.6838,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][17] = 	CreateItem(item_MediumBox, 		929.4532,2058.3926,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][18] = 	CreateItem(item_SmallBox, 		932.5464,2058.3267,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][19] = 	CreateItem(item_PumpShotgun, 	959.1787,2082.9680,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][20] = 	CreateItem(item_AmmoBuck, 		961.2108,2083.3938,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		SetItemExtraData(tut_Items[20][playerid], 12);
		tut_Items[playerid][21] = 	CreateItem(item_GasCan, 		938.4733,2063.2769,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		SetLiquidItemLiquidType(tut_Items[21][playerid], liquid_Petrol);
		SetLiquidItemLiquidAmount(tut_Items[21][playerid], 15);

		defer UpdateTutorialProgress(playerid); // Activate progress timer to track the player's progress
	}
	else // Tutorial set to inactive, so let's reset everything
	{
		DestroyTutorialForPlayer(playerid);

		// Remove stuff from player
		for(new i = MAX_INVENTORY_SLOTS - 1; i >= 0; i--)
			RemoveItemFromInventory(playerid, i);
		
		// Remove Bag and Holstered Item, if any
		// RemovePlayerBag(playerid);
		// RemovePlayerHolsterItem(playerid);
		
		SetPlayerVirtualWorld(playerid, 0); // Set player in the normal world to do something else
	}

	ClearChatForPlayer(playerid, 20);
	ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, tut_Active ? "TUTORINTROD" : "TUTORIEXIT"));
	log(true, "[TUTORIAL] %p %s the tutorial.", playerid, tut_Active ? : "entered" : "exited");
}

hook OnPlayerWearBag(playerid, Item:itemid)
{
	if(tut_Active[playerid])
	{
  		ClearChatForPlayer(playerid, 20);		
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));

		defer UpdateTutorialProgress(playerid);
	}

	return 0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(tut_Active[playerid])
	{
  		ClearChatForPlayer(playerid, 20);			
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINTINV"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	if(tut_Active[playerid])
	{
		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
			{
				ClearChatForPlayer(playerid, 20);
				
				ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINTBAG"));
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, Container:containerid)
{
	if(tut_Active[playerid])
	{
		new Item:itemid, slot;

		GetPlayerContainerSlot(playerid, slot);
		GetContainerSlotItem(containerid, slot, itemid);

		if(GetItemType(itemid) == item_Wrench)
		{
  			ClearChatForPlayer(playerid, 20);
			ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, Item:itemid)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORDROITM"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, Item:itemid, slot)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORINVADD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(Container:containerid, Item:itemid, playerid)
{
	if(tut_Active[playerid])
	{
		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
			{
				ClearChatForPlayer(playerid, 20);
				ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORADDBAG"));
			}
		}
		else
		{
			ClearChatForPlayer(playerid, 20);
			ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORADDCNT"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, Item:itemid)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMHOL"));

		defer UpdateTutorialProgress(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORITMUSE"));
	}
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(tut_Active[playerid])
	{
		if(IsItemTypeDefence(GetItemType(itemid)))
		{
			ClearChatForPlayer(playerid, 20);
			ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORIDEF"));
		}
		
		defer UpdateTutorialProgress(playerid);
	}
}

stock IsPlayerInTutorial(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;
		
	// log(true, "[TUTORIAL] IsPlayerInTutorial - %p: %d", playerid, tut_Active[playerid]);

	// PrintBacktrace();

	return tut_Active[playerid];
}

CMD:sair(playerid, params[])
{
	if(IsPlayerAdmin(playerid) || GetPlayerAdminLevel(playerid) || tut_Progress[playerid] == 5)
	{
		ToggleTutorialForPlayer(playerid, false);

		DisplayRegisterPrompt(playerid);
	}
	else
		ShowActionText(playerid, "~R~Voce precisa fazer as tarefas para sair");
	
	return 1;
}
CMD:exit(playerid, params[]) return cmd_sair(playerid, params);