CMD:ajuda(playerid, params[])
{
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Ajuda Geral", ls(playerid, "GENCOMDHELP"), "OK", "");

	return 1;
}

CMD:regras(playerid, params[])
{
	ChatMsg(playerid, YELLOW, " » Regras (total: %d)", gTotalRules);

	for(new i; i < gTotalRules; i++)
		ChatMsg(playerid, BLUE, sprintf(" » "C_ORANGE"%s", gRuleList[i]));
	
	return 1;
}

CMD:admins(playerid, params[])
{
	ChatMsg(playerid, YELLOW, " » Equipe de Admin (total: %d)", gTotalStaff);

	for(new i; i < gTotalStaff; i++)
		ChatMsg(playerid, BLUE, sprintf(" » "C_ORANGE"%s", gStaffList[i]));
	
	return 1;
}

CMD:creditos(playerid, params[])
{
	ChatMsg(playerid, YELLOW, " » Scavenge and Survive is developed by Southclaws (www.southcla.ws) and the following contributors:");
	ChatMsg(playerid, BLUE, " » Y_Less - Tons of useful code, libraries and conversations");
	ChatMsg(playerid, BLUE, " » Viruxe - Lots of anti-cheat work");
	ChatMsg(playerid, BLUE, " » Kadaradam - Fishing, Trees and lots of bug fixes");
	ChatMsg(playerid, BLUE, " » Hiddos - Better water detection code");

	return 1;
}

CMD:mdd(playerid, params[])
{
	ChatMsg(playerid, YELLOW, " » Mensagem do Dia: "C_BLUE"%s", gMessageOfTheDay);
	return 1;
}

CMD:motd(playerid, params[])
	return cmd_mdd(playerid, params);

CMD:chat(playerid, params[])
{
	Dialog_Show(playerid, DIALOG_STYLE_MSGBOX, "Informação acerca do "C_BLUE"Sistema de ChatChat", ls(playerid, "GENCOMDCHAT"), "OK", "");
	return 1;
}
CMD:chatinfo(playerid, params[])
	return cmd_chat(playerid, params);

CMD:dicas(playerid, params[])
{
	if(IsPlayerToolTipsOn(playerid)) ChatMsgLang(playerid, YELLOW, "TOOLTIPSOFF"); else ChatMsgLang(playerid, YELLOW, "TOOLTIPSON");
	SetPlayerToolTips(playerid, !IsPlayerToolTipsOn(playerid));
	return 1;
}

CMD:tools(playerid, params[])
	return cmd_dicas(playerid, params);

/*CMD:die(playerid, params[])
{
	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 60000)
		return 2;

	SetPlayerWeapon(playerid, 4, 1);
	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 1.0, 0, 0, 0, 0, 0);
	defer Suicide(playerid);

	return 1;
}
timer Suicide[3000](playerid)
{
	RemovePlayerWeapon(playerid);
	SetPlayerHP(playerid, -100.0);
}
*/

CMD:som(playerid, params[])
{
	new sound;
	if(!sscanf(params, "d", sound))
	{
		PlayerPlaySound(playerid, sound, 0.0, 0.0, 0.0);
		return 1;
	}
	return 1;
}

CMD:mudarsenha(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		ChatMsgLang(playerid, YELLOW, "CHANGEPASSW");
		return 1;
	}
	else
	{
		new storedhash[MAX_PASSWORD_LEN];

		GetPlayerPassHash(playerid, storedhash);
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);
		
		if(!strcmp(buffer, storedhash))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);
			
			if(SetAccountPassword(name, buffer))
			{
				SetPlayerPassHash(playerid, buffer);
				ChatMsgLang(playerid, YELLOW, "PASSCHANGED", newpass);
			}
			else
				ChatMsgLang(playerid, RED, "PASSCHERROR");
		}
		else
			ChatMsgLang(playerid, RED, "PASSCHNOMAT");
	}
	return 1;
}

CMD:changepass(playerid, params[])
	return cmd_mudarsenha(playerid, params);

CMD:changepassword(playerid, params[])
	return cmd_mudarsenha(playerid, params);

CMD:pos(playerid, params[])
{
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, " » Posição: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}