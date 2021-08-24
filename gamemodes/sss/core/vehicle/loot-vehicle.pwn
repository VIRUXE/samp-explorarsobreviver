
stock CreateLootVehicle(type, Float:x, Float:y, Float:z, Float:r)
{
	new
		vehicleid,
		canModelHaveColour = CanVehicleHaveColour(GetVehicleTypeModel(type)),
		colour1 = canModelHaveColour ? GetRandomVehicleColour() : -1,
		colour2 = canModelHaveColour ? GetRandomVehicleColour() : -1;
	
	vehicleid = CreateWorldVehicle(type, x, y, z, r, colour1, colour2);
	SetVehicleEngine(vehicleid, 0);

	if(vehicleid >= MAX_VEHICLES)
	{
		err(true, false, "Vehicle limit reached.");
		DestroyVehicle(vehicleid);
		return 0;
	}
	
	SetVehicleColours(vehicleid, colour1, colour2);

	GenerateVehicleData(vehicleid);
	SetVehicleSpawnPoint(vehicleid, x, y, z, r);

	return vehicleid;
}

stock GenerateVehicleData(vehicleid)
{
	new
		type			 = GetVehicleType(vehicleid),
		category		 = GetVehicleTypeCategory(type),
		Float:maxfuel	 = GetVehicleTypeMaxFuel(type),
		lootindexname[32],
		lootindex,
		trunksize		 = GetVehicleTypeTrunkSize(type);

	GetVehicleTypeLootIndex(type, lootindexname);
	lootindex = GetLootIndexFromName(lootindexname);

	// Health
	SetVehicleHP(vehicleid, 300 + random(400));

	// Fuel
	SetVehicleFuel(vehicleid, frandom(10.0) );

	// Visual Damage
	if(category < VEHICLE_CATEGORY_MOTORBIKE)
	{
		new
			panels = encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
			doors = encode_doors(random(5), random(5), random(5), random(5));

		SetVehicleDamageData(vehicleid,
			panels,
			doors,
			encode_lights(random(2), random(2), random(2), random(2)),
			encode_tires(random(2), random(2), random(2), random(2)) );

		// Locks
		if(maxfuel == 0.0) // ??????????
			SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
		else
		{
			new locked;

			if(doors)
				locked = random(2);

			if(panels)
				SetVehicleTrunkLock(vehicleid, random(2));

			SetVehicleParamsEx(vehicleid, 0, random(2), !random(100), locked, random(2), random(2), 0);

			if(locked)
				SetVehicleExternalLock(vehicleid, E_LOCK_STATE_DEFAULT);
			else
				SetVehicleTrunkLock(vehicleid, 0);
		}
	}

	// Putting loot in trunks
	if(lootindex != -1 && 0 < trunksize <= MAX_CONTAINER_SLOTS)
		FillContainerWithLoot(GetVehicleContainer(vehicleid), random(trunksize / 3), lootindex);

	// Number plate
	SetVehicleNumberPlate(vehicleid, RandomNumberPlateString());
}