#include <YSI_Coding\y_hooks>


#define MAX_SIGN_TEXT (128)

static Item:CurrentSignItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Sign"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Sign"), MAX_SIGN_TEXT);
}

hook OnItemCreateInWorld(Item:itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		new data[MAX_SIGN_TEXT], Button:buttonid;
		GetItemArrayData(itemid, data);
		_sign_UpdateText(itemid, data);

		GetItemButtonID(itemid, buttonid);

		SetButtonText(buttonid, "Aperta "KEYTEXT_INTERACT" para editar~n~Aguenta "KEYTEXT_INTERACT" para apanhar");
	}
}

hook OnItemArrayDataChanged(Item:itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		new data[MAX_SIGN_TEXT];
		GetItemArrayData(itemid, data);
		_sign_UpdateText(itemid, data);
	}
}

_sign_UpdateText(Item:itemid, text[])
{
	new objectid;
	GetItemObjectID(itemid, objectid);

	strreplace(text, "\\", "\n", .maxlength = MAX_SIGN_TEXT);
	strcat(text, "\n\n\n", MAX_SIGN_TEXT);

	SetDynamicObjectMaterialText(objectid, 0, text, OBJECT_MATERIAL_SIZE_512x512, "Arial", 72, 1, -16777216, -1, 1);
}

hook OnPlayerUseItem(playerid, Item:itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		if(IsItemInWorld(itemid))
		{
			CancelPlayerMovement(playerid);
			CurrentSignItem[playerid] = itemid;

			inline Response(pid, dialogid, response, listitem, string:inputtext[])
			{
				#pragma unused pid, dialogid, listitem
				if(response)
				{
					if(!isnull(inputtext) && IsValidItem(CurrentSignItem[playerid]))
						SetItemArrayData(CurrentSignItem[playerid], inputtext, strlen(inputtext));
				}
			}
			Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Sinal", "Introduz uma mensagem abaixo, para mostrar no sinal\nDigitando '\\' começará uma nova linha.", "Aceitar", "Sair");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}