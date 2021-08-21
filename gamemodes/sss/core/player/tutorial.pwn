/* 
	The tutorial only can only be executed if you don't have an account.

	No need to do it ever again, since you're already forced to do it before registering.

	Only RCON admins can skip it.

	VIRUXE
 */

#include <YSI_Coding\y_hooks>

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	tut_TaskBoard[MAX_PLAYERS],
bool:		tut_Active[MAX_PLAYERS],
			tut_Vehicle[MAX_PLAYERS],
Item:		tut_Items[MAX_PLAYERS][MAX_TUTORIAL_ITEMS];

forward OnPlayerStartTutorial(playerid);
forward OnPlayerFinishTutorial(playerid);

hook OnPlayerAccountCheck(playerid, accountState)
{
	if(accountState == ACCOUNT_STATE_NOTREGISTERED) // If account checks out as unregistered, then put the player in the tutorial
	{
		// Create Tasks Board Textdraw for the Player
		tut_TaskBoard[playerid] = CreatePlayerTextDraw(playerid, 4.000000, 327.000000, "____~y~Tarefas do Tutorial:~n~~r~X~w~ Vestir Mochila~n~~r~X~w~ Reparar Veiculo~n~~r~X~w~ Montar Tenda~n~~r~X~w~ Montar Porta com Chave~n~~r~X~w~ Colocar arma no Coldre");
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

hook OnHoldActionUpdate(playerid)
	UpdateTutorialProgressForPlayer(playerid);

hook OnVehicleSave(vehicleid) // Don't let the tutorial vehicle be saved
{
	foreach(new i : Player)
	{
		if(tut_Active[i] && tut_Vehicle[i] == vehicleid)
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(tut_Active[playerid])
	{
		ClearChatForPlayer(playerid, 20);
		ChatMsg(playerid, YELLOW, vehicleid == tut_Vehicle[playerid] ? "Esse é o único veículo existente no tutorial. Não vale a pena sair com ele." : "Onde encontrou esse veículo?!");
	}
}

hook OnPlayerWearBag(playerid, Item:itemid)
{
	if(tut_Active[playerid])
	{
  		ClearChatForPlayer(playerid, 20);		
		ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));

		UpdateTutorialProgressForPlayer(playerid);
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

hook OnPlayerOpenContainer(playerid, Container:containerid) // Opened Backpack
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

		UpdateTutorialProgressForPlayer(playerid);
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
		
		UpdateTutorialProgressForPlayer(playerid);
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

stock UpdateTutorialProgressForPlayer(playerid)
{
	#define TASK_NOTDONE "~r~X~w~"
	#define TASK_DONE	 "~g~V"

	if(!tut_Active[playerid]) 
		return;

	new 
		taskBoardText[168],
		tasksCompleted,

		isWearingBackpack = IsValidItem(GetPlayerBagItem(playerid)),
		Float:vehicleHealth,
		bool:isVehicleFixed,
		isDoorBuilt,
		tentId,
		isTentBuilt,
		isWeaponHolstered = IsValidItem(GetPlayerHolsterItem(playerid));
		
	GetVehicleHealth(tut_Vehicle[playerid], vehicleHealth);
	isVehicleFixed = vehicleHealth > 800.0 ? true : false;
	GetItemExtraData(tut_Items[playerid][9], tentId);
	isTentBuilt = IsValidTent(tentId);
	GetItemArrayDataAtCell(tut_Items[playerid][1], isDoorBuilt, 0);

	if(isWearingBackpack)
		tasksCompleted++;

	if(isVehicleFixed)
		tasksCompleted++;

	if(isTentBuilt)
		tasksCompleted++;

	if(isDoorBuilt)
		tasksCompleted++;

	if(isWeaponHolstered)
		tasksCompleted++;

	// PlayerTextDrawBackgroundColor(playerid, tut_TaskBoard[playerid], 255);
	// PlayerTextDrawBoxColor(playerid, tut_TaskBoard[playerid], 842150655);
	
	format(taskBoardText, sizeof(taskBoardText), "____~y~Tarefas do Tutorial:~n~%s Vestir Mochila~n~%s Reparar Veiculo~n~%s Montar Tenda~n~%s Montar Porta com Chave~n~%s Colocar arma no Coldre", 
		isWearingBackpack 	? TASK_DONE : TASK_NOTDONE, 
		isVehicleFixed 		? TASK_DONE : TASK_NOTDONE, 
		isTentBuilt 		? TASK_DONE : TASK_NOTDONE, 
		isDoorBuilt 		? TASK_DONE : TASK_NOTDONE, 
		isWeaponHolstered 	? TASK_DONE : TASK_NOTDONE
	);
	PlayerTextDrawSetString(playerid, tut_TaskBoard[playerid], taskBoardText);

	if(tasksCompleted == 5) // All tasks completed. Tutorial finished. Ask if player wants to register or not
	{
		CallLocalFunction("OnPlayerFinishTutorial", "d", playerid);

		SetPlayerBrightness(playerid, 0);

		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem, inputtext

			if(response)
				DisplayRegisterPrompt(playerid);
			else
				DisconnectPlayer(playerid);
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Explorar e Sobreviver", "Parabéns! Concluiu todas as tarefas!\n\nGostou do nosso modo de jogo e deseja registrar?", "Sim", "Não");
	}
}

stock DestroyTutorialForPlayer(playerid)
{
	// Delete Vehicle
	DestroyWorldVehicle(tut_Vehicle[playerid], true);

	// Delete Items
	for(new itemIdx; itemIdx > MAX_TUTORIAL_ITEMS; itemIdx++)
		DestroyItem(tut_Items[playerid][itemIdx]);

	// Reset the variables
	tut_TaskBoard[playerid] = PlayerText:INVALID_TEXT_DRAW;
	tut_Active[playerid] = false;
	tut_Vehicle[playerid] = INVALID_VEHICLE_ID;

	// Não sei se necessita depois do DestroyItem, mas mais vale prevenir
	for(new itemIdx; itemIdx > MAX_TUTORIAL_ITEMS; itemIdx++)
		tut_Items[playerid][itemIdx] = INVALID_ITEM_ID;
}

stock ToggleTutorialForPlayer(playerid, bool:toggle)
{
	if(!IsPlayerConnected(playerid))
		return;

	if(toggle == tut_Active[playerid])
		return;
	else
		tut_Active[playerid] = toggle;

	if(tut_Active[playerid]) // Tutorial set to active, so let's create it
	{
		CallLocalFunction("OnPlayerStartedTutorial", "d", playerid);

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
		tut_Items[playerid][0] = 	CreateItem(item_Screwdriver, 	975.1069, 2071.6677, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][1] = 	CreateItem(item_WoodDoor, 		974.1069, 2070.6677, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][2] = 	CreateItem(item_Spanner, 		945.02, 2069.25, 9.8603, 		.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][3] = 	CreateItem(item_Wheel, 			951.7727, 2068.0540, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][4] = 	CreateItem(item_Wheel, 			954.4612, 2068.2312, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][5] = 	CreateItem(item_Wheel, 			952.7346, 2070.6902, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][6] = 	CreateItem(item_Wrench, 		948.3666, 2069.8452, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][7] = 	CreateItem(item_Screwdriver, 	946.4836, 2069.7207, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][8] = 	CreateItem(item_Hammer, 		944.1250, 2067.6262, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][9] = 	CreateItem(item_TentPack, 		944.1473, 2083.2739, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][10] = 	CreateItem(item_Hammer, 		949.4579, 2082.9829, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][11] = 	CreateItem(item_Crowbar, 		947.3903, 2080.4143, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][12] = 	CreateItem(item_Crowbar, 		951.6076, 2067.8994, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][13] = 	CreateItem(item_Keypad, 		971.9176, 2069.2117, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][14] = 	CreateItem(item_Motor, 			971.4994, 2072.1038, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][15] = 	CreateItem(item_Rucksack, 		931.9263, 2081.7053, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][16] = 	CreateItem(item_LargeBox, 		927.8030, 2058.6838, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][17] = 	CreateItem(item_MediumBox, 		929.4532, 2058.3926, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][18] = 	CreateItem(item_SmallBox, 		932.5464, 2058.3267, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][19] = 	CreateItem(item_PumpShotgun, 	959.1787, 2082.9680, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		tut_Items[playerid][20] = 	CreateItem(item_AmmoBuck, 		961.2108, 2083.3938, 9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		SetItemExtraData(tut_Items[20][playerid], 12);
		tut_Items[playerid][21] = 	CreateItem(item_GasCan, 		938.4733,2063.2769,9.8603, 	.rz = frandom(360.0), .world = tutorialVirtualWorld);
		SetLiquidItemLiquidType(tut_Items[21][playerid], liquid_Petrol);
		SetLiquidItemLiquidAmount(tut_Items[21][playerid], 15);
	}
	else // Tutorial terminated, so let's reset everything
	{
		DestroyTutorialForPlayer(playerid);

		// Empty Players Inventory
		for(new i = MAX_INVENTORY_SLOTS - 1; i >= 0; i--)
			RemoveItemFromInventory(playerid, i);
		
		// Remove Bag and Holstered Item, if any
		// RemovePlayerBag(playerid);
		// RemovePlayerHolsterItem(playerid);
		
		CallLocalFunction("OnPlayerFinishTutorial", "d", playerid);
	}

	ClearChatForPlayer(playerid, 20);
	ChatMsg(playerid, WHITE, ""C_GREEN" » "C_WHITE" %s", ls(playerid, tut_Active[playerid] ? "TUTORINTROD" : "TUTORIEXIT"));
	// log(true, tut_Active[playerid] ? : "[TUTORIAL] %p entered the tutorial." : "[TUTORIAL] %p exited the tutorial.", playerid);
}

CMD:saltar(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		ToggleTutorialForPlayer(playerid, false);
		return 1;
	}
	
	return 1;
}
CMD:skip(playerid, params[]) return cmd_saltar(playerid, params);