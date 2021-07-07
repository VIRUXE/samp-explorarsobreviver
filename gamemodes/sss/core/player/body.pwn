#include <YSI_Coding\y_hooks>

#define MAX_BODY			(2048)

// Directory for storing player-saved body
#define DIRECTORY_BODY			DIRECTORY_MAIN"body/"


enum
{
		SAVED_BODY_POSX,
		SAVED_BODY_POSY,
		SAVED_BODY_POSZ,
		SAVED_BODY_ANGLE,
		SAVED_BODY_WORLD,
		SAVED_BODY_INTERIOR,
		SAVED_BODY_SKINID,
		SAVED_BODY_END
}

static
	body_PlayerName[MAX_BODY][MAX_PLAYER_NAME],
	Text3D:body_NameTag[MAX_BODY] = {Text3D:INVALID_3DTEXT_ID, ...};
	
new
   Iterator:body_Count<MAX_BODY>;

forward OnBodySave(bodyid);

hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_BODY);
}

hook OnGameModeInit()
{
	LoadPlayerBodys();
}

/*==============================================================================

	Loading

==============================================================================*/


LoadPlayerBodys()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_BODY);

	new
		path[128] = DIRECTORY_SCRIPTFILES DIRECTORY_BODY,
		Directory:direc,
		entry[128],
		ENTRY_TYPE:type,
		trimlength = strlen("./scriptfiles/");

	direc = OpenDir(path);
	if(direc == Directory:-1)
	{
		err("failed to open bodys directory '%s': %d", path, _:direc);
		return 1;
	}

	while(DirNext(direc, type, entry))
	{
		if(type == E_REGULAR)
		{
			if(strfind(entry, ".dat", false, 3) == -1)
			{
				err("File with invalid extension: '%s'", entry);
				continue;
			}

			LoadPlayerBody(entry[trimlength]);
		}
	}

	CloseDir(direc);

	Logger_Log("loaded player bodys", Logger_I("count", Iter_Count(body_Count)));

	return 1;
}


/*==============================================================================

	Load body (individual)

==============================================================================*/


LoadPlayerBody(const filepath[])
{
	new
		filename[32],
		data[SAVED_BODY_END],
		length;

	PathBase(filepath, filename);
	if(!(6 < strlen(filename) < MAX_PLAYER_NAME + 4))
	{
		err("File with a bad filename length: '%s' len: %d", filename, strlen(filename));
		return 0;
	}

	length = modio_read(filepath, _T<D,A,T,A>, sizeof(data), data, false, false);

	if(length == 0)
	{
		modio_finalise_read(modio_getsession_read(filepath));
		err("modio_read returned length of 0.");
		return 0;
	}

	new
		name[MAX_PLAYER_NAME];

	strmid(name, filename, 0, strlen(filename) - 4);

	CreateBody(name,
		Float:data[SAVED_BODY_POSX],
		Float:data[SAVED_BODY_POSY],
		Float:data[SAVED_BODY_POSZ],
		Float:data[SAVED_BODY_ANGLE],
		data[SAVED_BODY_WORLD],
		data[SAVED_BODY_INTERIOR],
		data[SAVED_BODY_SKINID]);

	//modio_finalise_read(modio_getsession_read(filepath));
	
	Logger_Log("loaded player body",
		Logger_S("name", name),
		Logger_F("x", data[SAVED_BODY_POSX]),
		Logger_F("y", data[SAVED_BODY_POSY]),
		Logger_F("z", data[SAVED_BODY_POSZ]),
		Logger_F("a", data[SAVED_BODY_ANGLE]),
		Logger_I("World", data[SAVED_BODY_WORLD]),
		Logger_I("Interior", data[SAVED_BODY_INTERIOR]),
		Logger_I("Skin", data[SAVED_BODY_SKINID])
	);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	new
		lastattacker,
		lastweapon;

	if(!IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon) && !IsPlayerOnAdminDuty(playerid) && IsPlayerLoggedIn(playerid))
	{
		new Float:x, Float:y, Float:z, Float:a, name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		new
			filename[MAX_PLAYER_NAME + 22],
			session,
			data[SAVED_BODY_END],
			Item:itemid,
			Item:items[19],
			itemcount;

		format(filename, sizeof(filename), DIRECTORY_BODY"%s.dat", name);

		session = modio_getsession_write(filename);

		if(session != -1)
			modio_close_session_write(session);

		data[SAVED_BODY_POSX] = _:x;
		data[SAVED_BODY_POSY] = _:y;
		data[SAVED_BODY_POSZ] = _:z;
		data[SAVED_BODY_ANGLE] = _:a;
		data[SAVED_BODY_WORLD] = GetPlayerVirtualWorld(playerid);
		data[SAVED_BODY_INTERIOR] = GetPlayerInterior(playerid);
		data[SAVED_BODY_SKINID] = GetPlayerSkin(playerid);

		modio_push(filename, _T<D,A,T,A>, SAVED_BODY_END, data);

	/*
		Held item
	*/

		itemid = GetPlayerItem(playerid);

		if(IsValidItem(itemid))
		{
			new held_data[ITM_ARR_MAX_ARRAY_DATA];
			held_data[0] = _:GetItemType(itemid);
			GetItemArrayDataSize(itemid, held_data[1]);
			GetItemArrayData(itemid, held_data[2], held_data[1]);
			modio_push(filename, _T<H,E,L,D>, 2 + held_data[1], held_data);
		}
		else
		{
			new held_data[1] = { -1 };
			modio_push(filename, _T<H,E,L,D>, 1, held_data);
		}

	/*
		Holstered item
	*/

		itemid = GetPlayerHolsterItem(playerid);

		if(IsValidItem(itemid))
		{
			new hols_data[ITM_ARR_MAX_ARRAY_DATA];
			hols_data[0] = _:GetItemType(itemid);
			GetItemArrayDataSize(itemid, hols_data[1]);
			GetItemArrayData(itemid, hols_data[2], hols_data[1]);
			modio_push(filename, _T<H,O,L,S>, 2 + hols_data[1], hols_data);
		}
		else
		{
			new hols_data[1] = { -1 };
			modio_push(filename, _T<H,O,L,S>, 1, hols_data);
		}

	/*
		Inventory
	*/

		for(new i; i < MAX_INVENTORY_SLOTS; i++)
		{
			GetInventorySlotItem(playerid, i, items[i]);

			if(!IsValidItem(items[i]))
				break;

			itemcount++;
		}

		new ret = SerialiseItems(items, itemcount);
		if(!ret)
		{
			modio_push(filename, _T<I,N,V,0>, GetSerialisedSize(), itm_arr_Serialized);
			ClearSerializer();
		}

	/*
		Hat item
	*/
		itemid = GetPlayerHatItem(playerid);

		if(IsValidItem(itemid))
		{
			new hat_data[ITM_ARR_MAX_ARRAY_DATA];
			hat_data[0] = _:GetItemType(itemid);
			GetItemArrayDataSize(itemid, hat_data[1]);
			GetItemArrayData(itemid, hat_data[2], hat_data[1]);
			modio_push(filename, _T<H,A,T,I>, 2 + hat_data[1], hat_data);
		}
		else
		{
			new hat_data[1] = { -1 };
			modio_push(filename, _T<H,A,T,I>, 1, hat_data);
		}

	/*
		Mask item
	*/
		itemid = GetPlayerMaskItem(playerid);

		if(IsValidItem(itemid))
		{
			new mask_data[ITM_ARR_MAX_ARRAY_DATA];
			mask_data[0] = _:GetItemType(itemid);
			GetItemArrayDataSize(itemid, mask_data[1]);
			GetItemArrayData(itemid, mask_data[2], mask_data[1]);
			modio_push(filename, _T<M,A,S,K>, 2 + mask_data[1], mask_data);
		}
		else
		{
			new hat_data[1] = { -1 };
			modio_push(filename, _T<M,A,S,K>, 1, hat_data);
		}

	/*
		Bag item
	*/

		itemid = GetPlayerBagItem(playerid);

		if(IsValidItem(itemid))
		{
			new bag_data[ITM_ARR_MAX_ARRAY_DATA];
			bag_data[0] = _:GetItemType(itemid);
			//GetItemArrayDataSize(itemid, bag_data[1]);
			//GetItemArrayData(itemid, bag_data[2], bag_data[1]);
			modio_push(filename, _T<B,A,G,I>, 2 + bag_data[1], bag_data);
		}
		else
		{
			new bag_data[1] = { -1 };
			modio_push(filename, _T<B,A,G,I>, 1, bag_data);
		}

	/*
		Bag
	*/
		itemcount = 0;

		if(IsValidItem(GetPlayerBagItem(playerid)))
		{
			new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));
			new size;
			GetContainerSize(containerid, size);

			for(new i; i < size && i < 19; i++)
			{
				GetContainerSlotItem(containerid, i, items[i]);

				if(!IsValidItem(items[i]))
					break;

				itemcount++;
			}

			ret = SerialiseItems(items, itemcount);
			if(!ret)
			{
				modio_push(filename, _T<B,A,G,0>, GetSerialisedSize(), itm_arr_Serialized);
				ClearSerializer();
			}
		} 

		modio_finalise_write(modio_getsession_write(filename));
			
		if(gServerRestarting)
			return 1;

		CreateBody(name, x, y, z, a, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), GetPlayerSkin(playerid));
	}
	return 1;
}

hook OnPlayerLoadAccount(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	foreach(new i : body_Count){
		if(!strcmp(body_PlayerName[i], name) && !isnull(body_PlayerName[i]))
		{
			if(GetDynamicActorVirtualWorld(i) == 33)
			{
				ChatMsg(playerid, RED, " » Você foi morto enquanto esteve ausente. :(");
				SetAccountAliveState(name, 0);
			}
			break;
		}
	}
}

hook OnPlayerLogin(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	foreach(new i : body_Count){
		if(!strcmp(body_PlayerName[i], name) && !isnull(body_PlayerName[i]))
		{
			DestroyBody(i);
			break;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

CreateBody(const name[], Float:x, Float:y, Float:z, Float:a, w, i, s)
{
	new id = Iter_Free(body_Count);

	if(id == ITER_NONE)
		return -1;

	id = CreateDynamicActor(s, x, y, z + 0.15, a, false, 100.0, w, i); 

	if(!IsValidDynamicActor(id))
		return 0;

	body_PlayerName[id][0] = EOS;
	strcat(body_PlayerName[id], name);
	
	if(IsValidDynamic3DTextLabel(body_NameTag[id])){
		DestroyDynamic3DTextLabel(body_NameTag[id]);
		body_NameTag[id] = Text3D:INVALID_3DTEXT_ID;
	}

	body_NameTag[id] = CreateDynamic3DTextLabel(sprintf("%s{FFFFFF}(Corpo)", body_PlayerName[id]), 0xB8B8B8FF, x, y, z, 15.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, w, i);

	ApplyDynamicActorAnimation(id, "SUNBATHE", "PARKSIT_M_IN", 4.1, 0, 0, 0, 1, 0);

	Iter_Add(body_Count, id);

	return id;
}

stock DestroyBody(bodyid)
{
	if(!Iter_Contains(body_Count, bodyid))
		return 0;

	if(!IsValidDynamicActor(bodyid))
		return 0;

	new
		filename[MAX_PLAYER_NAME + 22];
		//session;

	format(filename, sizeof(filename), DIRECTORY_BODY"%s.dat", body_PlayerName[bodyid]);
	//session = modio_getsession_write(filename);
	//modio_close_session_write(session);
	fremove(filename);

	Iter_Remove(body_Count, bodyid);

	body_PlayerName[bodyid][0] = EOS;
	DestroyDynamicActor(bodyid);

	if(IsValidDynamic3DTextLabel(body_NameTag[bodyid])){
		DestroyDynamic3DTextLabel(body_NameTag[bodyid]);
		body_NameTag[bodyid] = Text3D:INVALID_3DTEXT_ID;
	}

	return 1;
}

//OnCameraTarget 
/*IRPC:168(playerid, BitStream:bs)
{
	new ObjectTarget, VehicleTarget, PlayerTarget, ActorTarget;
	BS_ReadValue(bs,
		PR_UINT16, ObjectTarget,
		PR_UINT16, VehicleTarget,
		PR_UINT16, PlayerTarget,
		PR_UINT16, ActorTarget
	);

	ChatMsg(playerid, -1,
		"ObjectTarget:%d, VehicleTarget:%d, PlayerTarget:%d, ActorTarget:%d",
			ObjectTarget, VehicleTarget, PlayerTarget, ActorTarget);

	return 1;
}*/

// GiveTakeDamage
const GIVEDAM = 115;

IRPC:GIVEDAM(playerid, BitStream:bs){
	/*new bool:bGiveOrTake, wPlayerID, Float:damage_amount, dWeaponID, dBodypart;
	BS_ReadValue(bs,
		PR_BOOL, bGiveOrTake,
		PR_UINT16, wPlayerID,
		PR_FLOAT, damage_amount,
		PR_UINT32, dWeaponID,
		PR_UINT32, dBodypart
	);

	ChatMsg(playerid, -1,
		"bGiveOrTake:%d, wPlayerID:%d, damage_amount:%0.2f, dWeaponID:%d, dBodypart:%d",
			bGiveOrTake, wPlayerID, damage_amount, dWeaponID, dBodypart);
	
	if(wPlayerID > 999) // Is Body
	{
		SetPlayerHealth(wPlayerID, -damage_amount);
		CallLocalFunction("OnPlayerGiveDamageDynamicActor", "ddfdd",
			playerid, wPlayerID - 1000, damage_amount, dWeaponID, dBodypart);
		return 0;
	}*/
		

	if(IsPlayerMobile(playerid))
	{
		new 
			Float:x,
			Float:y,
			Float:z,
			Float:cx,
			Float:cy,
			Float:cz;

		GetPlayerPos(playerid, cx, cy, cz);

		foreach(new i : body_Count)
		{
			GetDynamicActorPos(i, x, y, z);
			
			if(Distance(cx, cy, cz, x, y, z) < 5.0)
			{
				if(!CA_RayCastLine(x, y, z, cx, cy, cz,  cx, cy, cz))
				{
					ShowActionText(playerid,
						sprintf("~w~Digite ~g~/mc %d~n~~w~para matar o corpo de ~w~~h~%s", i, body_PlayerName[i]),
						3000);
				}
			}
		}
	}

	return 1;
}

CMD:mc(playerid, params[])
{
	if(IsPlayerMobile(playerid))
	{
		new STREAMER_TAG_ACTOR:actorid;

		if(sscanf(params, "d", STREAMER_TAG_ACTOR:actorid))
		{
			ChatMsg(playerid, RED, "[Mobile] > Digite /mv [id do corpo]");
			return 1;
		}

		new 
			Float:x,
			Float:y,
			Float:z,
			Float:cx,
			Float:cy,
			Float:cz;

		GetDynamicActorPos(actorid, x, y, z);
		GetPlayerPos(playerid, cx, cy, cz);

		if(Distance(cx, cy, cz, x, y, z) < 5.0)
		{
			if(!CA_RayCastLine(x, y, z, cx, cy, cz,  cx, cy, cz))
				CallLocalFunction("OnPlayerGiveDamageDynamicActor", "ddfdd", playerid, actorid, 100.0, 0, 1);
			else 
				ChatMsg(playerid, RED, "[Mobile] > Você não pode matar por que há algum objeto entre você e o corpo.");
		}
		else ChatMsg(playerid, RED, "[Mobile] > Você está muito longe do corpo.");
	}
	return 1;
}

public OnPlayerGiveDamageDynamicActor(playerid, actorid, Float:amount, weaponid, bodypart)
{
	new 
		Float:x, Float:y, Float:z,
		Float:px, Float:py, Float:pz,
		Float:health, Float:tmp;

	GetDynamicActorPos(actorid, x, y, z);
	GetPlayerPos(playerid, px, py, pz);

	if(CA_RayCastLine(x, y, z, px, py, pz, tmp, tmp, tmp))
		return 1;

	SetDynamicActorPos(actorid, x, y, z);
	ClearDynamicActorAnimations(actorid);
	
	GetDynamicActorHealth(actorid, health);

	if(IsPlayerRaidBlock(playerid)){
		Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Anti-Raid Protection", ls(playerid, "ANTRAIDP"), "Sair", "");
		return 1;
	}
	
	if((health- amount) < 1.0)
	{
		new forname[MAX_PLAYER_NAME];
		foreach(new i : Player)
		{
			GetPlayerName(i, forname, MAX_PLAYER_NAME);

			if(!strcmp(forname, body_PlayerName[actorid]))
			{
				Kick(i);
				return 1;
			}
		}

		new
			ItemType:itemtype,
			Item:itemid,
			length,
			Container:containerid;

		new Float:cx, Float:cy, Float:cz;

		CA_RayCastLine(x, y, z, x, y, z - 600.0, cx, cy, cz);

		itemid = CreateItem(ItemType:item_Torso, cx, cy, cz + 0.2, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

		defer DestroyTorso(_:itemid);
		
		GetItemArrayDataAtCell(itemid, _:containerid, 0);

		new name[MAX_PLAYER_NAME + 8];
		format(name, sizeof(name), "Corpo de %s", body_PlayerName[actorid]);
		SetContainerName(containerid, name);
		SetItemLabel(itemid, name);

		new
			filename[MAX_PLAYER_NAME + 22],
//			session,
			data[SAVED_BODY_END];

		format(filename, sizeof(filename), DIRECTORY_BODY"%s.dat", body_PlayerName[actorid]);

	/*
		Held item
	*/
		new held_data[ITM_ARR_MAX_ARRAY_DATA];

		length = modio_read(filename, _T<H,E,L,D>, sizeof(held_data), held_data);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<H,E,L,D>",
				Logger_I("error", length));

		}
		else if(IsValidItemType(ItemType:held_data[0]) && length > 0)
		{
			itemid = AllocNextItemID(ItemType:held_data[0]);
			SetItemNoResetArrayData(itemid, true);
			SetItemArrayData(itemid, held_data[2], held_data[1]);
			AddItemToContainer(containerid, itemid);
			CreateItem_ExplicitID(itemid);
		}

	/*
		Holstered item
	*/
		new hols_data[ITM_ARR_MAX_ARRAY_DATA];

		length = modio_read(filename, _T<H,O,L,S>, sizeof(hols_data), hols_data);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<H,O,L,S>",
				Logger_I("error", length));
		}
		else if(IsValidItemType(ItemType:hols_data[0]) && length > 0)
		{
			itemid = AllocNextItemID(ItemType:hols_data[0]);
			SetItemNoResetArrayData(itemid, true);
			SetItemArrayData(itemid, hols_data[2], hols_data[1]);
			AddItemToContainer(containerid, itemid);
			CreateItem_ExplicitID(itemid);
		}

	/*
		Inventory
	*/

		length = modio_read(filename, _T<I,N,V,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<I,N,V,0>",
				Logger_I("error", length));
		}
		else if(!DeserialiseItems(itm_arr_Serialized, length, false))
		{
			for(new i, j = GetStoredItemCount(); i < j; i++)
			{
				itemtype = GetStoredItemType(i);

				if(length == 0)
					break;

				if(itemtype == INVALID_ITEM_TYPE)
					break;

				if(itemtype == ItemType:0)
					break;

				itemid = CreateItem(itemtype, .virtual = 1);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
					SetItemArrayDataFromStored(itemid, i);
			
				AddItemToContainer(containerid, itemid);
			}
			ClearSerializer();
		}

	/*
		Hat Item
	*/
		new hat_data[ITM_ARR_MAX_ARRAY_DATA];

		length = modio_read(filename, _T<H,A,T,I>, sizeof(hat_data), hat_data);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<H,A,T,I>",
				Logger_I("error", length));

		}
		else if(IsValidItemType(ItemType:hat_data[0]) && length > 0)
		{
			itemid = AllocNextItemID(ItemType:hat_data[0]);
			SetItemNoResetArrayData(itemid, true);
			SetItemArrayData(itemid, hat_data[2], hat_data[1]);
			AddItemToContainer(containerid, itemid);
			CreateItem_ExplicitID(itemid);
		}

	/*
		Mask Item
	*/
		new mask_data[ITM_ARR_MAX_ARRAY_DATA];

		length = modio_read(filename, _T<M,A,S,K>, sizeof(mask_data), mask_data);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<M,A,S,K>",
				Logger_I("error", length));

		}
		else if(IsValidItemType(ItemType:mask_data[0]) && length > 0)
		{
			itemid = AllocNextItemID(ItemType:mask_data[0]);
			SetItemNoResetArrayData(itemid, true);
			SetItemArrayData(itemid, mask_data[2], mask_data[1]);
			AddItemToContainer(containerid, itemid);
			CreateItem_ExplicitID(itemid);
		}

	/*
		Bag item
	*/
		itemid = INVALID_ITEM_ID;
		
		new bag_data[ITM_ARR_MAX_ARRAY_DATA];

		length = modio_read(filename, _T<B,A,G,I>, sizeof(bag_data), bag_data);
		if(length < 0)
		{
			Logger_Err("modio read failed _T<B,A,G,I>",
				Logger_I("error", length));

		}
		else if(IsValidItemType(ItemType:bag_data[0]) && length > 0)
		{
			itemid = CreateItem(ItemType:bag_data[0]);
			//SetItemNoResetArrayData(itemid, true);
			//SetItemArrayData(itemid, bag_data[2], bag_data[1]);
		}
	/*
		Bag - Itemid = ^
	*/
		if(IsValidItem(itemid)){
			if(IsValidContainer(GetBagItemContainerID(Item:itemid)))
			{
				length = modio_read(filename, _T<B,A,G,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);
				if(length < 0)
				{
					Logger_Err("modio read failed _T<B,A,G,0>",
						Logger_I("error", length));
				}
				else if(!DeserialiseItems(itm_arr_Serialized, length, false))
				{
					new Item:itemid2;
					for(new i, j = GetStoredItemCount(); i < j; i++)
					{
						itemtype = GetStoredItemType(i);
						itemid2 = CreateItem(itemtype, .virtual = 1);

						if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
							SetItemArrayDataFromStored(itemid2, i);

						AddItemToContainer(GetBagItemContainerID(Item:itemid), itemid2);
					}
					ClearSerializer();
				}

				AddItemToContainer(containerid, itemid);
			}
		}
		
		data[SAVED_BODY_WORLD] = 33;
		modio_push(filename, _T<D,A,T,A>, SAVED_BODY_END, data);

		if(IsValidDynamic3DTextLabel(body_NameTag[actorid])){
			DestroyDynamic3DTextLabel(body_NameTag[actorid]);
			body_NameTag[actorid] = Text3D:INVALID_3DTEXT_ID;
		}

		SetDynamicActorVirtualWorld(actorid, 33);
		//CreateBody(body_PlayerName[actorid], 0.0, 0.0, 0.0, 0.0, 33, 0, 0);
	}
	else 
	{
		SetDynamicActorHealth(actorid, health - amount);

		new
			Item:itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);
		ShowHitMarker(playerid, GetItemTypeWeaponBaseWeapon(itemtype));
	}

	//ChatMsg(playerid, -1, "Actorid: %d, Amount: %0.2f, Weaponid: %d, bodypart: %d", actorid, Float:amount, weaponid, bodypart);
	return 1;
}

/*
forward OnPlayerGiveDamageDynamicActor(playerid, STREAMER_TAG_ACTOR:actorid, Float:amount, weaponid, bodypart);
native STREAMER_TAG_ACTOR:CreateDynamicActor(modelid, Float:x, Float:y, Float:z, Float:r, invulnerable = true, Float:health = 100.0, worldid = -1, interiorid = -1, playerid = -1, Float:streamdistance = STREAMER_ACTOR_SD, STREAMER_TAG_AREA:areaid = STREAMER_TAG_AREA:-1, priority = 0);
native DestroyDynamicActor(STREAMER_TAG_ACTOR:actorid);
native IsValidDynamicActor(STREAMER_TAG_ACTOR:actorid);
native IsDynamicActorStreamedIn(STREAMER_TAG_ACTOR:actorid, forplayerid);
native GetDynamicActorVirtualWorld(STREAMER_TAG_ACTOR:actorid);
native SetDynamicActorVirtualWorld(STREAMER_TAG_ACTOR:actorid, vworld);
native GetDynamicActorAnimation(STREAMER_TAG_ACTOR:actorid, animlib[], animname[], &Float:fdelta, &loop, &lockx, &locky, &freeze, &time, maxanimlib = sizeof animlib, maxanimname = sizeof animname);
native ApplyDynamicActorAnimation(STREAMER_TAG_ACTOR:actorid, const animlib[], const animname[], Float:fdelta, loop, lockx, locky, freeze, time);
native ClearDynamicActorAnimations(STREAMER_TAG_ACTOR:actorid);
native GetDynamicActorFacingAngle(STREAMER_TAG_ACTOR:actorid, &Float:ang);
native SetDynamicActorFacingAngle(STREAMER_TAG_ACTOR:actorid, Float:ang);
native GetDynamicActorPos(STREAMER_TAG_ACTOR:actorid, &Float:x, &Float:y, &Float:z);
native SetDynamicActorPos(STREAMER_TAG_ACTOR:actorid, Float:x, Float:y, Float:z);
native GetDynamicActorHealth(STREAMER_TAG_ACTOR:actorid, &Float:health);
native SetDynamicActorHealth(STREAMER_TAG_ACTOR:actorid, Float:health);
native SetDynamicActorInvulnerable(STREAMER_TAG_ACTOR:actorid, invulnerable = true);
native IsDynamicActorInvulnerable(STREAMER_TAG_ACTOR:actorid);
native STREAMER_TAG_ACTOR:GetPlayerTargetDynamicActor(playerid);
native STREAMER_TAG_ACTOR:GetPlayerCameraTargetDynActor(playerid);
forward OnDynamicActorStreamIn(STREAMER_TAG_ACTOR:actorid, forplayerid);
forward OnDynamicActorStreamOut(STREAMER_TAG_ACTOR:actorid, forplayerid);
*/