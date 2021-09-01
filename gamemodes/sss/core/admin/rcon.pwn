
public OnRconCommand(cmd[])
{
	new
		command[32],
		params[32];

	sscanf(cmd, "s[32]s[32]", command, params);

	if(!strcmp(command, "restart"))
	{
		SetRestart(isnull(params) ? 0 : strval(params));
		return 1;
	}

	return 0;
}