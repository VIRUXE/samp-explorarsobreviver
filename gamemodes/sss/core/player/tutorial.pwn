#include <YSI_Coding\y_hooks>

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...},
Item:		PlayerTutorial_Item     [MAX_TUTORIAL_ITEMS][MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawAlignment			(playerid, ClassButtonTutorial[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonTutorial[playerid], 0.45, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonTutorial[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonTutorial[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 34.000000, 155.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
	PlayerInTutorial[playerid] = false;
}

hook OnPlayerSpawnChar(playerid)
{
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerCreateChar(playerid)
{
	PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(playertextid == ClassButtonTutorial[playerid])
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

		FreezePlayer(playerid, gLoginFreezeTime * 1000);
		PrepareForSpawn(playerid);

		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

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
		//PlayerTutorial_Item[0][playerid] = CreateItem(item_CorPanel, 975.1069,2071.6677,9.8603, .rz = frandom(360.0), .world = playerid + 1);
		//PlayerTutorial_Item[1][playerid] = CreateItem(item_MetalGate, 973.7677,2075.0117,9.8603, .rz = frandom(360.0), .world = playerid + 1);
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
		//PlayerTutorial_Item[13][playerid] = CreateItem(item_Keypad, 971.9176,2069.2117,9.8603, .rz = frandom(360.0), .world = playerid + 1);
        //PlayerTutorial_Item[14][playerid] = CreateItem(item_Motor, 971.4994,2072.1038,9.8603, .rz = frandom(360.0), .world = playerid + 1);
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

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORINTROD"));
		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTOREXITCM"));
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

hook OnPlayerDeath(playerid)
{
	ExitTutorial(playerid);
}

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
		defer ExitTutor(playerid);
}

timer ExitTutor[3000](playerid)
	ExitTutorial(playerid);
	
ExitTutorial(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!PlayerInTutorial[playerid])
		return 0;
		
	for(new i = MAX_INVENTORY_SLOTS - 1; i >= 0; i--)
		RemoveItemFromInventory(playerid, i);
	
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

	ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORIEXIT"));
	return 1;
}

hook OnPlayerWearBag(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
  		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");
		
		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));
	}

	return 0;
}

hook OnPlayerOpenInventory(playerid)
{
	if(PlayerInTutorial[playerid])
	{
  		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");
			
		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORINTINV"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	if(PlayerInTutorial[playerid])
	{
		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			new Container:bagcontainer, Error:e;
			
			e = GetItemArrayDataAtCell(GetPlayerBagItem(playerid), _:bagcontainer, 1);
			
			if(!IsError(e)) 
			{
				if(containerid == bagcontainer)
				{
					for(new i = 0; i < 20; i++)
						SendClientMessage(playerid, GREEN, "");
					
					ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORINTBAG"));
				}
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

			ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
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

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORDROITM"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, Item:itemid, slot)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORINVADD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
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
				new Container:bagcontainer, Error:e;

				e = GetItemArrayDataAtCell(GetPlayerBagItem(playerid), _:bagcontainer, 1);
				
				if(!IsError(e)) {
					if(containerid == bagcontainer)
					{
						for(new i = 0; i < 20; i++)
							SendClientMessage(playerid, GREEN, "");

						ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORADDBAG"));
					}
				}
			}
			else
			{
				for(new i = 0; i < 20; i++)
					SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORADDCNT"));
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

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORITMHOL"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORITMUSE"));
	}
}

hook OnItemTweakFinish(playerid, Item:itemid)
{
	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, GREEN, " » "C_WHITE" %s", ls(playerid, "TUTORIDEF"));
	}
}

CMD:sair(playerid, params[])
{
	ExitTutorial(playerid);
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