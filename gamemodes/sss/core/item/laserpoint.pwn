
#include <YSI_Coding\y_hooks>


hook OnPlayerUseItemWithItem(playerid, Item:itemid, Item:withitemid){
	if(GetItemType(withitemid) == item_LaserPointR || GetItemType(withitemid) == item_LaserPointB ||
		GetItemType(withitemid) == item_LaserPointY || GetItemType(withitemid) == item_LaserPointG ||
		GetItemType(withitemid) == item_LaserPointP){
		
		if(!GetItemWeaponMods(GetPlayerItem(playerid))){
			new model = GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(GetPlayerItem(playerid))));

			if(model == WEAPON_SILENCED || model == WEAPON_SHOTGSPA || model == WEAPON_AK47 ||
				model == WEAPON_M4 || model == WEAPON_SNIPER || model == WEAPON_MP5){
				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450, 1);
				SetItemWeaponMods(GetPlayerItem(playerid), _:GetItemType(withitemid));
				DestroyItem(withitemid);
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, Item:itemid){
	if(GetItemWeaponMods(GetPlayerItem(playerid)) > 300){
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450, 1);
		CreateItem(ItemType:GetItemWeaponMods(GetPlayerItem(playerid)), x, y, z - 0.96, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
		SetItemWeaponMods(GetPlayerItem(playerid), 0);
		RemovePlayerAttachedObject(playerid, 8);
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUpdate(playerid){
	if(GetItemWeaponMods(GetPlayerItem(playerid)) > 300) {
		new model;
		GetItemTypeModel(ItemType:GetItemWeaponMods(GetPlayerItem(playerid)), model);
		switch (GetItemWeaponBaseWeapon(GetItemTypeWeapon(GetItemType(GetPlayerItem(playerid))))){

			case WEAPON_SILENCED: {
				if(IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SP standing aiming
							0.108249, 0.030232, 0.118051, 1.468254, 350.512573, 364.284240);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SP crouched aiming
							0.108249, 0.030232, 0.118051, 1.468254, 349.862579, 364.784240);
					}
				} 
				else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SP standing not aiming
							0.078248, 0.027239, 0.113051, -11.131746, 350.602722, 362.384216);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SP crouched not aiming
							0.078248, 0.027239, 0.113051, -11.131746, 350.602722, 362.384216);
					}       
				}       
			}

			case WEAPON_SHOTGSPA: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SPAS standing aiming
							0.588246, -0.022766, 0.138052, -11.531745, 347.712585, 352.784271);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SPAS crouched aiming
							0.588246, -0.022766, 0.138052, 1.468254, 350.712585, 352.784271);
					}
				} else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SPAS standing not aiming
							0.563249, -0.01976, 0.134051, -11.131746, 351.602722, 351.384216);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // SPAS crouched not aiming
							0.563249, -0.01976, 0.134051, -11.131746, 351.602722, 351.384216);
					}
		       	}
			}

			case WEAPON_AK47: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // AK standing aiming
							0.628249, -0.027766, 0.078052, -6.621746, 352.552642, 355.084289);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // AK crouched aiming
							0.628249, -0.027766, 0.078052, -1.621746, 356.202667, 355.084289);
					}
				} else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // AK standing not aiming
							0.663249, -0.02976, 0.080051, -11.131746, 358.302734, 353.384216);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // AK crouched not aiming
							0.663249, -0.02976, 0.080051, -11.131746, 358.302734, 353.384216);
					}
				}
			}

			case WEAPON_M4: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // M4 standing aiming
							0.528249, -0.020266, 0.068052, -6.621746, 352.552642, 355.084289);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // M4 crouched aiming
							0.528249, -0.020266, 0.068052, -1.621746, 356.202667, 355.084289);
					}
				} else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // M4 standing not aiming
							0.503249, -0.02376, 0.065051, -11.131746, 357.302734, 354.484222);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // M4 crouched not aiming
							0.503249, -0.02376, 0.065051, -11.131746, 357.302734, 354.484222);
					}
				}
			}

			case WEAPON_SNIPER: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
						SetPlayerAttachedObject(playerid, 8, model, 6, // Sniper standing aiming
						0.528249, -0.020266, 0.068052, -6.621746, 352.552642, 355.084289);
					} else {
						SetPlayerAttachedObject(playerid, 8, model, 6, // Sniper crouched aiming
						0.528249, -0.020266, 0.068052, -1.621746, 356.202667, 355.084289);
					}
				} else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
						SetPlayerAttachedObject(playerid, 8, model, 6, // Sniper standing not aiming
						0.658248, -0.03276, 0.133051, -11.631746, 355.302673, 353.584259);
					} else {
						SetPlayerAttachedObject(playerid, 8, model, 6, // Sniper crouched not aiming
						0.658248, -0.03276, 0.133051, -11.631746, 355.302673, 353.584259);
					}
				}
			}

			case WEAPON_MP5: {
				if (IsPlayerAiming(playerid)) {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // MP5 standing aiming
							0.298249, -0.02776, 0.158052, -11.631746, 359.302673, 357.584259);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // MP5 crouched aiming
							0.298249, -0.02776, 0.158052, 8.368253, 358.302673, 352.584259);
					}
				} else {
					if (GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK) {
							SetPlayerAttachedObject(playerid, 8, model, 6, // MP5 standing not aiming
							0.293249, -0.027759, 0.195051, -12.131746, 354.302734, 352.484222);
					} else {
							SetPlayerAttachedObject(playerid, 8, model, 6, // MP5 crouched not aiming
							0.293249, -0.027759, 0.195051, -12.131746, 354.302734, 352.484222);
					}
				}
			}
			//////
		}
	}
	else if(IsPlayerAttachedObjectSlotUsed(playerid, 8)) RemovePlayerAttachedObject(playerid, 8);

	return 1;
}

stock IsPlayerAiming(playerid){
	new anim = GetPlayerAnimationIndex(playerid);
	if (((anim >= 1160) && (anim <= 1163)) || (anim == 1167) || (anim == 1365) ||
	(anim == 1643) || (anim == 1453) || (anim == 220)) return 1;
 	return 0;
}