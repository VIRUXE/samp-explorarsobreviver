/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2020 Barnaby "Southclaws" Keene

		This Source Code Form is subject to the terms of the Mozilla Public
		License, v. 2.0. If a copy of the MPL was not distributed with this
		file, You can obtain one at http://mozilla.org/MPL/2.0/.


==============================================================================*/


#include <YSI_Coding\y_hooks>

hook OnItemCreateInWorld(Item:itemid){
	if(GetItemType(itemid) == item_Barrel){
		SetItemArrayDataSize(itemid, 1);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(Item:itemid, ItemType:itemtype){
	if(itemtype == item_Barrel){
		new Float:value, Error:e;
		e = GetItemArrayDataAtCell(itemid, _:value, 0);
		if(!IsError(e)) {
			new str[8];
			format(str, 8, "%0.1f%", value);
			SetItemNameExtra(itemid, str);
		}
	}
}

hook OnPlayerPickUpItem(playerid, Item:itemid){
	if(GetItemType(itemid) == item_Barrel){
		new Float:value, Error:e;
		e = GetItemArrayDataAtCell(itemid, _:value, 0);
		if(!IsError(e)) {
			if(value > 50.0) {
				ShowActionText(playerid, ls(playerid, "BARRELHEAVY"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}
	return 1;
}

hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if(GetItemType(withitemid) == item_Barrel){
		new ItemType:type = GetItemType(itemid);
		
		if(type == item_GasCan){

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}
