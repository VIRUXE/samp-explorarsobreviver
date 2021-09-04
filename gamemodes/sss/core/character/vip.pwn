#include <YSI_Coding\y_hooks>

static
        vip_Level[MAX_PLAYERS],
        vip_InventoryOption[MAX_PLAYERS],
bool:   vip_ViewingMenu[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    vip_Level[playerid] = 0;
}

hook OnPlayerDisconnect(playerid, reason)
{
    vip_ViewingMenu[playerid] = false;
}

hook OnPlayerOpenContainer(playerid, Container:containerid)
{
	vip_ViewingMenu[playerid] = false;
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Menu do vip através do inventário/bolso
    
==============================================================================*/

hook OnPlayerOpenInventory(playerid)
{
    if((GetPlayerVIP(playerid) - gettime()) > 1)
    {
	    vip_InventoryOption[playerid] = AddInventoryListItem(playerid, "Menu VIP >");
    }
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	if(item == vip_InventoryOption[playerid])
    {
        ShowVipMenu(playerid);
        ClosePlayerInventory(playerid);
        return Y_HOOKS_BREAK_RETURN_1;
    }
	return Y_HOOKS_CONTINUE_RETURN_0;
}

ShowVipMenu(playerid)
{
    gBigString[playerid][0] = EOS;

    strcat(gBigString[playerid], "Tempo de Vip restante\n");
    strcat(gBigString[playerid], "Anuncio\n");
    strcat(gBigString[playerid], "Trocar Roupa\n");
    strcat(gBigString[playerid], "Mudar estilo de Luta\n");
    strcat(gBigString[playerid], "Cometer suicidio\n");

    if(vip_Level[playerid] >= 2)
    {
        //strcat(gBigString[playerid], "Function\n");
    }


    if(vip_Level[playerid] >= 3)
    {
        //strcat(gBigString[playerid], "Function\n");
    }

    inline Response(pid, dialogid, response, listitem, string:inputtext[])
    {
        #pragma unused pid, dialogid, inputtext

        if(response)
        {
            /*=================================================================

                Verificar tempo restante de VIP
                
            =================================================================*/

            if(listitem == 0)
            {
                new str[128];
                DurationFormat(Seconds:(GetPlayerVIP(playerid) - gettime()), str);

                inline Response2(pid2, dialogid2, response2, listitem2, string:inputtext2[])
                {
                    #pragma unused pid2, dialogid2, response2, listitem2, inputtext2

                    ShowVipMenu(playerid);
                }
                Dialog_ShowCallback(playerid, using inline Response2, DIALOG_STYLE_MSGBOX,
                    sprintf("Menu VIP "C_GREEN"(Nivel %d)", vip_Level[playerid]),
                    sprintf("\n"C_BLUE"Seu tempo restante de vip:\n\n\
                    "C_YELLOW"%s\n\n\
                    "C_BLUE"Aproveite seus beneficios e indique para amigos :)", str),
                    "Visto", "");
            }

            /*=================================================================

                Enviar um anuncio destacado no chat
                
            =================================================================*/

            if(listitem == 1)
            {
                inline Response2(pid2, dialogid2, response2, listitem2, string:inputtext2[])
                {
                    #pragma unused pid2, dialogid2, listitem2

                    if(response2)
                    {
                        ChatMsgAll(COLOR_PLAYER_VIP, "[Anuncio-VIP] %P(%d): "C_WHITE"%s",
                            playerid, playerid, TagScan(inputtext2));

                        ShowActionText(playerid, "Anuncio enviado para todos", 3000);

                        vip_ViewingMenu[playerid] = false;
                    }
                    else
                    {
                        ShowVipMenu(playerid);
                    }
                }
                Dialog_ShowCallback(playerid, using inline Response2, DIALOG_STYLE_INPUT,
                    sprintf("Menu VIP "C_GREEN"(Nivel %d)", vip_Level[playerid]),
                    "Insira uma mensagem no campo abaixo:",
                    "Enviar", "Sair");
            }

            /*=================================================================

                Mostrar menu de seleção de roupas
                
            =================================================================*/

            if(listitem == 2)
            {
                new
                    list[MAX_CLOTHES * (64)],
                    c_name[MAX_CLOTHES_NAME];

                for(new i; i < MAX_CLOTHES; i++)
		        {
                    if(!IsValidClothes(i))
                        break;

                    GetClothesName(i, c_name);

                    format(list, sizeof(list), "%s%d(0.0, 0.0, -32.0, 0.90)\t%s\n",
                        list, GetClothesModel(i), c_name);
                }

                ShowPlayerDialog(playerid, 66, DIALOG_STYLE_PREVIEW_MODEL,
                    "~Y~Roupas VIP", list, "Enter", "Voltar");
            }

            /*=================================================================

                Mudar estilo de Luta
                
            =================================================================*/

            if(listitem == 3)
            {
                inline Response2(pid2, dialogid2, response2, listitem2, string:inputtext2[])
                {
                    #pragma unused pid2, dialogid2, inputtext2

                    if(response2)
                    {
                        switch(listitem2)
                        {
                            case 0: SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
                            case 1: SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
                            case 2: SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
                            case 3: SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
                        }

                        // Informar tecla de uso
                        ShowActionText(playerid, "Estilo de luta mudado~n~~y~~k~~PED_LOCK_TARGET~ ~w~+ ~y~~k~~VEHICLE_ENTER_EXIT~", 7000);

                        vip_ViewingMenu[playerid] = false;
                    }
                    else
                    {
                        ShowVipMenu(playerid);
                    }
                }
                Dialog_ShowCallback(playerid, using inline Response2, DIALOG_STYLE_LIST,
                    sprintf("Menu VIP "C_GREEN"(Nivel %d)", vip_Level[playerid]),
                    "Kung Fu\nKnee Head\nEl bow\nGrab Kick",
                    "Enter", "Voltar");
            }

            /*=================================================================

                Cometer suicídio
                
            =================================================================*/

            if(listitem == 4)
            {
                new
                    lastattacker,
                    lastweapon;

                if(!IsPlayerCombatLogging(playerid, lastattacker, Item:lastweapon))
                {
                    DestroyPlayerItems(playerid);
                    SetPlayerBrightness(playerid,   255);
                    SetPlayerScore(playerid,        0);
                    SetPlayerWantedLevel(playerid,  0);
                    SetPlayerFP(playerid,           90.0);
                    SetPlayerBleedRate(playerid,    0.0);
                    RemovePlayerWounds(playerid,    MAX_WOUNDS);
                    SetPlayerHP(playerid,           100.0);
                    SetVipSpawn(playerid);                    
                }
                else
                {
                    ShowActionText(playerid, "Voce foi atacado recentemente, aguarde.", 5000);
                }

                vip_ViewingMenu[playerid] = false;
            }
        }
        else
        {
            vip_ViewingMenu[playerid] = false;
            DisplayPlayerInventory(playerid);
        }
    }
    Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, sprintf("Menu VIP "C_GREEN"(Nivel %d)", vip_Level[playerid]), gBigString[playerid], "Selecionar", "Sair");

    vip_ViewingMenu[playerid] = true;
}


hook OnDialogModelResponse(playerid, dialogid, response, listitem)
{
	if(dialogid == 66)
    {
		if(response)
        {
			SetPlayerClothes(playerid, listitem);
            SetPlayerGender(playerid, GetClothesGender(listitem));
            ShowActionText(playerid, "Roupa trocada", 3000);
        }
		else
        {
			ShowVipMenu(playerid);
        }
	}
}

/*==============================================================================

	Save vip info
    
==============================================================================*/

hook OnPlayerSave(playerid, filename[])
{
	new data[1];
	data[0] = vip_Level[playerid];
	modio_push(filename, _T<V,I,P,I>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[1];
	modio_read(filename, _T<V,I,P,I>, 1, data);
	vip_Level[playerid] = data[0];
    return Y_HOOKS_CONTINUE_RETURN_1;
}

/*==============================================================================

	Setar vip do jogador. PENDENTE: Setar automaticamente via site/discord
    
==============================================================================*/

ACMD:setvip[4](playerid, params[])
{
	new
		id,
		nome[MAX_PLAYER_NAME],
		nivel,
        dias,
        horas,
        minutos,
        segundos;

	if(!sscanf(params, "dddddd", id, nivel, dias, horas, minutos, segundos))
	{
		if(!IsPlayerConnected(id))
			ChatMsg(playerid, RED, " » Jogador nao conectado.");
        else
        {
            GetPlayerName(id, nome);

            SetVip(nome, nivel, dias, horas, minutos, segundos);

            ChatMsg(playerid, YELLOW, 
            " » Voce setou o vip de %s para nivel %d. Dias: %d, Horas: %d, Minutos: %d, Segundos %d",
                nome, nivel, dias, horas, minutos, segundos);

            ChatMsg(id, GREEN, " » %P Setou seu vip para nivel %d. Dias: %d, Horas: %d, Segundos %d",
                playerid, nivel, dias, horas, segundos);
        }
	}
	else if(!sscanf(params, "s[24]ddddd", nome, nivel, dias, horas, minutos, segundos))
	{
        SetVip(nome, nivel, dias, horas, minutos, segundos);

		ChatMsg(playerid, YELLOW, 
            " » Voce setou o vip de %s para nivel %d. Dias: %d, Horas: %d, Minutos: %d, Segundos %d",
               nome, nivel, dias, horas, minutos, segundos);
	}
	else
		ChatMsg(playerid, RED,
            " » Use: /setvip [playerid/name] [level] [dias] [horas] [minutos] [segundos]");

	return 1;
}

stock SetVip(const name[MAX_PLAYER_NAME], level = 1, days = 30, hours = 0, minutes = 0, seconds = 0)
{ 
    new 
        timestamp = gettime() + ( seconds + (minutes * 60) + (hours * 3600) + (days * (24 * 3600))),
        playerId = GetPlayerIdByName(name);

    SetAccountVIP(name, timestamp);

    if(IsPlayerConnected(playerId))
    {
        SetPlayerVIP(playerId, timestamp);

        if(vip_Level[playerId] != level)
            ChatMsgAll(COLOR_PLAYER_VIP, " » %P"C_ORANGE" É o mais novo VIP do servidor. Parabens!", playerId);

        vip_Level[playerId] = level;

        SetPlayerColor(playerId, COLOR_PLAYER_VIP);

        ShowActionText(playerId,
            sprintf("Parabens! Voce agora possui VIP nivel %d~n~Abra o menu do VIP atraves do bolso", level),
            5000, 200);
    }

    return 1;
}

/*==============================================================================

	Carregar ações mais rápido de acordo com o nivel vip
    
==============================================================================*/

hook OnHoldActionUpdate(playerid, progress)
{
	if((GetPlayerVIP(playerid) - gettime()) > 1)
    {
        SetPlayerHoldActionProgress(playerid, progress + (vip_Level[playerid] * 25) );
    }
	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Nascer com itens adicionais
    
==============================================================================*/

hook OnPlayerSpawnNewChar(playerid)
{
    if((GetPlayerVIP(playerid) - gettime()) > 1)
    {
        // Nivel 1 nascer com uma Mochila;
        GivePlayerBag(playerid, CreateItem(item_Satchel));
        AddItemToPlayer(playerid, CreateItem(item_AntiSepBandage));
        AddItemToPlayer(playerid, CreateItem(item_Wrench));

        new Container:containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));

        if(vip_Level[playerid] >= 2) // Nivel 2 nascer com Ferramentas;
        {
            AddItemToContainer(containerid, CreateItem(item_Screwdriver));
            AddItemToContainer(containerid, CreateItem(item_Hammer));
            AddItemToContainer(containerid, CreateItem(item_Spanner));
        }
        if(vip_Level[playerid] >= 3) // Nivel 3 nascer com Maleta de Doutor;
        {
            new Item:itemid = CreateItem(item_M9Pistol);

            SetItemWeaponItemMagAmmo(itemid, 10);
			SetItemWeaponItemAmmoItem(itemid, item_Ammo9mm);

            AddItemToContainer(containerid, itemid);
        }

        /*======================================================================

            Nascer nas cidades
            
        ======================================================================*/

        SetVipSpawn(playerid);
    }
}

SetVipSpawn(playerid)
{
    switch(random(6))
    {
        case 0: SetPlayerPos(playerid, -162.708709,     2764.035888,    62.619419); // BC
        case 1: SetPlayerPos(playerid, -2404.725585,    -2176.453125,   32.99999);  // FC
        case 2: SetPlayerPos(playerid, 2241.932128,     -1258.510009,   23.936239); // LS
        case 3: SetPlayerPos(playerid, 2048.162353,     1015.961303,    10.711874); // LV
        case 4: SetPlayerPos(playerid, -535.624877,     -102.932212,    63.287090); // RC
        case 5: SetPlayerPos(playerid, -2716.43823,     382.60507,      4.34639);   // SF
        case 6: SetPlayerPos(playerid, -2560.33521,     2256.71069,     5.03032);   // TR
    }
}

/*==============================================================================

	Cor vip ao nascer
    
==============================================================================*/

hook OnPlayerSpawnChar(playerid)
{
    if((GetPlayerVIP(playerid) - gettime()) > 1)
    {
        SetPlayerColor(playerid, COLOR_PLAYER_VIP);
    }
}
