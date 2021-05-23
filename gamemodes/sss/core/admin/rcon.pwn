//#include <YSI\y_timers>

public OnRconCommand(cmd[])
{
	new
		command[32],
		params[32];

	sscanf(cmd, "s[32]s[32]", command, params);

	if(!strcmp(command, "rr"))
	{
		if(params[0] == EOS)
		{
			console("\tUsage: 'restart <seconds>' enter '0' to restart instantly.");
			console("\tIt is not advised to restart instantly.");
			console("\tEntering a time will display a countdown to all players");
			console("\tallowing them to prepare for the restart.\n");
		}
		else
			SetRestart(strval(params));

		return 1;
	}

	return 0;
}
