
#include <YSI_Coding\y_hooks>


static
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


forward OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance);


hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(IsAdminOnDuty(damagedid))
		return 0;

	if(IsAdminOnDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(damagedid))
		return 1;
		
	// Anti knife bug
	if(GetPlayerAnimationIndex(playerid) == 747){
		SetPlayerHP(damagedid, 0.0);
		return 1;
	}
	
	_HandleFirearmDamage(playerid, damagedid, bodypart);

	return 1;
}

_HandleFirearmDamage(playerid, targetid, bodypart)
{
	if(IsAdminOnDuty(playerid) || IsAdminOnDuty(targetid))
		return 0;

	new
		Item:itemid,
		ItemType:itemtype,
		weapontype,
		baseweapon;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);
	weapontype = GetItemTypeWeapon(itemtype);
	baseweapon = GetItemWeaponBaseWeapon(weapontype);

	if(!IsBaseWeaponClipBased(baseweapon))
		return 0;

	if(GetItemWeaponBaseWeapon(weapontype) == WEAPON_DEAGLE)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 790)
			return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerDeltDamageTick(playerid)) < 100)
			return 0;
	}

	return _DoFirearmDamage(playerid, targetid, itemid, itemtype, bodypart);
}

_DoFirearmDamage(playerid, targetid, Item:itemid, ItemType:itemtype, bodypart)
{
	dbg("damage-firearm", 1, "[_DoFirearmDamage] playerid: %d targetid: %d itemtype: %d bodypart: %d ", playerid, targetid, _:itemtype, bodypart);

	new
		calibre,
		Float:bleedrate,
		Float:knockmult = 1.0,
		Float:bulletvelocity,
		Float:distance,
		Float:velocitydegredationrate;

	calibre = GetItemTypeWeaponCalibre(itemtype);
	bleedrate = GetCalibreBleedRate(calibre);
	bulletvelocity = GetItemTypeWeaponMuzzVelocity(itemtype);
	distance = GetDistanceBetweenPlayers(playerid, targetid);

	dbg("damage-firearm", 2, "[_DoFirearmDamage] bleedrate: %.4f muzzlevel: %.4f distance: %.4f", bleedrate, bulletvelocity, distance);

	// Turns the muzzle velocity (initial velocity) into a factor that affects
	// the bullet velocity depending on the distance it has travelled.
	// To put it simply, if the weapon has a high muzzle velocity, the round
	// isn't affected by the distance as much as a weapon with a low muzzle
	// velocity.
	velocitydegredationrate = 1.0 - (bulletvelocity / 11300);
	dbg("damage-firearm", 2, "[_DoFirearmDamage] velocitydegredationrate: %.4f", velocitydegredationrate);

	// Now a graph function, the distance is the 'x' and the degradation rate is
	// the power. This gives a curved line which gradually lowers the velocity
	// as the distance increases.
	bulletvelocity -= floatpower(distance, velocitydegredationrate);
	dbg("damage-firearm", 2, "[_DoFirearmDamage] bulletvelocity: %.4f", bulletvelocity);

	// Now to combine the bullet velocity with the initial bleed rate of the
	// bullet calibre which results in the final bleed rate for the player.
	bleedrate *= bulletvelocity / 1000.0;
	dbg("damage-firearm", 2, "[_DoFirearmDamage] bleedrate: %.4f", bleedrate);

	knockmult *= bulletvelocity / 50.0;

	// Apply bleedrate and knockout multiplier from ammotype
	if(IsValidItem(itemid))
	{
		bleedrate *= GetAmmoTypeBleedrateMultiplier(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)));
		knockmult *= GetAmmoTypeKnockoutMultiplier(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)));
	}

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerShootPlayer", "dddffff", playerid, targetid, bodypart, bleedrate, knockmult, bulletvelocity, distance))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_FIREARM, bleedrate, knockmult, calibre, bodypart, "Firearm");
	ShowHitMarker(playerid, GetItemTypeWeaponBaseWeapon(itemtype));

	return 1;
}

stock DMG_FIREARM_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_FIREARM_SetKnockMult(targetid, Float:knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
