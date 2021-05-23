LoadSettings()
{
	if(!fexist(SETTINGS_FILE))
	{
		err("Settings file `"SETTINGS_FILE"` not found. Creating and using default values.");

		fclose(fopen(SETTINGS_FILE, io_write));
	}

	GetSettingString("server/motd", "Please update the 'server/motd' string in "SETTINGS_FILE"", gMessageOfTheDay);

	GetSettingInt("server/max-uptime", 18000, gServerMaxUptime);
	GetSettingInt("player/allow-pause-map", 0, gPauseMap);
	GetSettingInt("player/interior-entry", 0, gInteriorEntry);
	GetSettingInt("player/player-animations", 1, gPlayerAnimations);
	GetSettingInt("player/vehicle-surfing", 0, gVehicleSurfing);
	GetSettingFloat("player/nametag-distance", 3.0, gNameTagDistance);
	GetSettingInt("player/combat-log-window", 30, gCombatLogWindow);
	GetSettingInt("player/login-freeze-time", 8, gLoginFreezeTime);
	GetSettingInt("player/max-tab-out-time", 60, gMaxTaboutTime);
	GetSettingInt("player/ping-limit", 600, gPingLimit);
	GetSettingInt("discord/enabled", 0, gDiscord);

	SetGameModeText("Scavenge Survive by Southclaw");
}


stock GetSettingInt(path[], defaultvalue, &output, printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetVal(path, defaultvalue);
		output = defaultvalue;
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %d", path, output);
	}
	else
	{
		output = file_GetVal(path);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded `%s`: %d", path, output);
	}

	if(openfile)
		file_Close();
}

stock GetSettingFloat(path[], Float:defaultvalue, &Float:output, printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetFloat(path, defaultvalue);
		output = defaultvalue;
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %f", path, output);
	}
	else
	{
		output = file_GetFloat(path);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded `%s`: %f", path, output);
	}

	if(openfile)
		file_Close();
}

stock GetSettingString(path[], defaultvalue[], output[], maxsize = sizeof(output), printsetting = true, openfile = true)
{
	if(openfile)
		file_Open(SETTINGS_FILE);

	if(!file_IsKey(path))
	{
		file_SetStr(path, defaultvalue);
		output[0] = EOS;
		strcat(output, defaultvalue, maxsize);
		file_Save(SETTINGS_FILE);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %s", path, output);
	}
	else
	{
		file_GetStr(path, output, maxsize);

		if(printsetting)
			log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded `%s`: %s", path, output);
	}

	if(openfile)
		file_Close();
}


/*
	Arrays
*/

stock GetSettingIntArray(path[], defaultvalue, max, output[], &outputtotal, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetInt(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0] = defaultvalue;

				if(printsetting)
					log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %d", tmpkey, output[0]);
			}

			break;
		}

		GetSettingInt(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock GetSettingFloatArray(path[], Float:defaultvalue, max, Float:output[], &outputtotal, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetFloat(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0] = defaultvalue;

				if(printsetting)
					log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %f", tmpkey, output[0]);
			}

			break;
		}

		GetSettingFloat(tmpkey, defaultvalue, output[outputtotal], printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock GetSettingStringArray(path[], defaultvalue[], max, output[][], &outputtotal, outputmaxsize, printsetting = true)
{
	file_Open(SETTINGS_FILE);

	new tmpkey[MAX_KEY_LENGTH];

	while(outputtotal < max)
	{
		format(tmpkey, sizeof(tmpkey), "%s/%d", path, outputtotal);

		if(!file_IsKey(tmpkey))
		{
			if(outputtotal == 0)
			{
				file_SetStr(tmpkey, defaultvalue);
				file_Save(SETTINGS_FILE);
				output[0][0] = EOS;
				strcat(output[0], defaultvalue, outputmaxsize);

				if(printsetting)
					log(DISCORD_CHANNEL_INVALID, "[SETTING] Loaded default `%s`: %s", tmpkey, output[0]);
			}

			break;
		}

		GetSettingString(tmpkey, defaultvalue, output[outputtotal], outputmaxsize, printsetting, false);

		outputtotal++;
	}

	file_Close();
}

stock UpdateSettingInt(path[], value)
{
	file_Open(SETTINGS_FILE);
	file_SetVal(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}

stock UpdateSettingFloat(path[], Float:value)
{
	file_Open(SETTINGS_FILE);
	file_SetFloat(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}

stock UpdateSettingString(path[], value[])
{
	file_Open(SETTINGS_FILE);
	file_SetStr(path, value);
	file_Save(SETTINGS_FILE);
	file_Close();
}
