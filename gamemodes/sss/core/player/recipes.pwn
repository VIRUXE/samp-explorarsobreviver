#define CRAFT_DIALOG 	(90)

CMD:recipes(playerid, params[])
{
	Dialog_ShowCraftTypes(playerid);
	return 1;
}
CMD:receitas(playerid, params[]) return cmd_recipes(playerid, params);
CMD:craft(playerid, params[]) return cmd_recipes(playerid, params);
CMD:crafts(playerid, params[]) return cmd_recipes(playerid, params);

Dialog_ShowCraftTypes(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		
		if(response)
		{
			switch(listitem)
			{
				case 0:
					Dialog_ShowCraftList(playerid, 1);
				case 1:
					Dialog_ShowCraftList(playerid, 2);
				case 2:
					Dialog_ShowCraftList(playerid, 3);
				case 3:
					Dialog_ShowCraftHelp(playerid);
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Receitas", "Receitas de Combinação\nReceitas de Construção\nReceitas de Mesa de Trabalho\n"C_GREEN"Ajuda", "Enter", "Esc");
}

new CraftSet:PlayerListCraft[MAX_PLAYERS][MAX_CONSTRUCT_SET];

Dialog_ShowCraftList(playerid, type)
{
	// 0 All
	// 1 Combine
	// 2 Consset
	// 3 Workbench

	new
		itemname[MAX_ITEM_NAME],
		LCraft[270],
		model,
		items;

	for(new CraftSet:i; i < CraftSet:GetCraftSetTotal(); i++)
	{
		if(IsValidCraftSet(i))
		{
			new 
				consSet = GetCraftSetConstructSet(i),
				isValidConsSet = IsValidWorkbenchConstructionSet(consSet);

			switch(type)
			{
				case 1:
				{
					if(consSet != -1)
						continue;
				}
				case 2:
				{
					if(consSet == -1)
						continue;

					if(isValidConsSet)
						continue;
				}
				case 3:
				{
					if(consSet == -1)
						continue;

					if(!isValidConsSet)
						continue;
				}
			}
			
			new ItemType:resulttype;
			GetCraftSetResult(i, resulttype);
			GetItemTypeName(resulttype, itemname);
			GetItemTypeModel(resulttype, model);
		}
		else
			itemname = "INVALID CRAFT SET";

		PlayerListCraft[playerid][items++] = i;
		format(LCraft, sizeof(LCraft), "%s%d\t%s\n", LCraft, model, itemname);
	}

	ShowPlayerDialog(playerid, CRAFT_DIALOG, DIALOG_STYLE_PREVIEW_MODEL, "Receitas", LCraft, "Enter", "Esc");
}

hook OnDialogModelResponse(playerid, dialogid, response, listitem){
	if(dialogid == CRAFT_DIALOG){
		if(response)
			Dialog_ShowIngredients(playerid, CraftSet:PlayerListCraft[playerid][listitem]);
		else
			Dialog_ShowCraftTypes(playerid);
	}
}

Dialog_ShowIngredients(playerid, CraftSet:craftset)
{
	if(!IsValidCraftSet(craftset))
		return 1;

	gBigString[playerid][0] = EOS;

	new
		itemcount,
		ItemType:itemType,
		itemname[MAX_ITEM_NAME],
		toolname[MAX_ITEM_NAME],
		consset = GetCraftSetConstructSet(craftset),
		ItemType:resulttype;

	GetCraftSetItemCount(craftset, itemcount);
	GetCraftSetResult(craftset, resulttype);

	for(new i; i < itemcount; i++)
	{
		GetCraftSetItemType(craftset, i, itemType);
		GetItemTypeName(itemType, itemname);
		format(gBigString[playerid], sizeof(gBigString[]), "%s\t\t\t%s\n", gBigString[playerid], itemname);
	}

	if(consset != -1)
	{
		GetItemTypeName(GetConstructionSetTool(consset), toolname);
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ferramenta: 			"C_YELLOW"%s\n\
			"C_WHITE"Ingredientes:	"C_YELLOW"\n%s", toolname, gBigString[playerid]);
	}
	else
	{
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ingredientes:	"C_YELLOW"\n%s", gBigString[playerid]);
	}

	GetItemTypeName(resulttype, itemname);

	new itemtipkey[12];

	if(strlen(itemname) > 9)
		itemname[9] = EOS;

	format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
	itemtipkey[11] = EOS;

	strcat(gBigString[playerid], "\n");
	strcat(gBigString[playerid], ls(playerid, itemtipkey));

	GetItemTypeName(resulttype, itemname);
	
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		if(!response)
			Dialog_ShowCraftTypes(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, itemname, gBigString[playerid], "Sair", "Voltar");

	return 1;
}

Dialog_ShowCraftHelp(playerid)
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "Crafting é uma forma de criar novos itens apartir de itens existentes.\n");
	strcat(gBigString[playerid], "Existem três formas de combinar itens no nosso modo de jogo:\n\n");

	strcat(gBigString[playerid], C_YELLOW"Nas opções de dialogos de utilização de Item (Aka: Craftar ou Combinar):\n\n");
	strcat(gBigString[playerid], C_WHITE"Enquanto visualiza o inventário ou container (porta-malas, caixas, mochila, etc)\n");
	strcat(gBigString[playerid], C_WHITE"Seleciona 'Combinar' da lista de opções do item selecionado\n");
	strcat(gBigString[playerid], C_WHITE"Volta atrás e abre as Opções para outro Item\n");
	strcat(gBigString[playerid], C_WHITE"Seleciona 'Combinar com...' para combinar os Itens juntos.\n");
	strcat(gBigString[playerid], C_WHITE"Se uma receita necessitar de mais do que dois itens, então repita o processo.\n\n");

	strcat(gBigString[playerid], C_GREEN"No chão (Aka: Construir):\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloca todos os Itens no chão\n");
	strcat(gBigString[playerid], C_WHITE"Equipa a Ferramenta especificada na receita\n");
	strcat(gBigString[playerid], C_WHITE"Aperta a tecla de Interação estando perto dos Itens\n\n");

	strcat(gBigString[playerid], C_BLUE"Numa Mesa de Trabalho:\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloca todos os Itens dentro da Mesa de Trabalho (Ela funciona como uma caixa)\n");
	strcat(gBigString[playerid], C_WHITE"Equipa a Ferramenta especificada na receita\n");
	strcat(gBigString[playerid], C_WHITE"Aperta a tecla de Interação enquanto está junto da Mesa de Trabalho");

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext
		if(response)
			Dialog_ShowCraftTypes(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Ajuda com Craft", gBigString[playerid], "Voltar", "Sair");
}
