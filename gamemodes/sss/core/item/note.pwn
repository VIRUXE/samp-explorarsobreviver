#include <YSI\y_hooks>


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Note"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Note"), 256);
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", LOG_CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/note.pwn");

	if(GetItemType(itemid) == item_Note)
		_ShowNoteDialog(playerid, itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ShowNoteDialog(playerid, itemid)
{
	new string[256];

	GetItemArrayData(itemid, string);

	if(strlen(string) == 0)
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem

			if(response)
			{
				SetItemArrayData(itemid, inputtext, strlen(inputtext));
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Note", "Write a message onto the note:", "Done", "Cancel");
	}
	else
	{
		inline Response(pid, dialogid, response, listitem, string:inputtext[])
		{
			#pragma unused pid, dialogid, listitem, inputtext

			if(!response)
			{
				DestroyItem(itemid);
			}
		}
		Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, "Note", string, "Close", "Tear");
	}

	return 1;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	dbg("global", LOG_CORE, "[OnItemNameRender] in /gamemodes/sss/core/item/note.pwn");

	if(itemtype == item_Note)
	{
		new
			string[256],
			len;

		GetItemArrayData(itemid, string);
		len = strlen(string);

		if(len == 0)
		{
			SetItemNameExtra(itemid, "Blank");
		}
		else if(len > 8)
		{
			strins(string, "(...)", 8);
			string[13] = EOS;
			SetItemNameExtra(itemid, string);
		}
	}
}
