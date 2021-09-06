static
		send_TargetName				[MAX_PLAYERS][MAX_PLAYER_NAME],
		send_TargetType				[MAX_PLAYERS],
Float:	send_TargetPos				[MAX_PLAYERS][3],
		send_TargetWorld			[MAX_PLAYERS],
		send_TargetInterior			[MAX_PLAYERS],

		report_CurrentReportList	[MAX_PLAYERS][MAX_REPORTS_PER_PAGE][e_report_list_struct],

		report_CurrentReason		[MAX_PLAYERS][MAX_REPORT_REASON_LENGTH],
		report_CurrentType			[MAX_PLAYERS][MAX_REPORT_TYPE_LENGTH],
Float:	report_CurrentPos			[MAX_PLAYERS][3],
		report_CurrentWorld			[MAX_PLAYERS],
		report_CurrentInterior		[MAX_PLAYERS],
		report_CurrentInfo			[MAX_PLAYERS][MAX_REPORT_INFO_LENGTH],
		report_CurrentItem			[MAX_PLAYERS];


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:report(playerid, params[])
{
	ShowReportMenu(playerid);

	return 1;
}
CMD:reportar(playerid, params[]) return cmd_report(playerid, params);

ShowReportMenu(playerid)
{	
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0: // Specific player ID (who is online now)
				{
					ShowReportOnlinePlayer(playerid);
					send_TargetType[playerid] = 1;
				}
				case 1: // Specific Player Name (Who isn't online now)
				{
					ShowReportOfflinePlayer(playerid);
					send_TargetType[playerid] = 2;
				}
				case 2: // Player that last killed me
				{
					new name[MAX_PLAYER_NAME];

					GetLastKilledBy(playerid, name);

					if(!isnull(name))
					{
						send_TargetName[playerid][0] = EOS;
						send_TargetName[playerid] = name;
					}
					else
					{
						GetLastHitBy(playerid, name);

						if(!isnull(name))
						{
							send_TargetName[playerid][0] = EOS;
							send_TargetName[playerid] = name;
						}
						else
						{
							ChatMsgLang(playerid, RED, "REPNOPFOUND");
							return 1;
						}
					}

					GetPlayerDeathPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
					send_TargetWorld[playerid] = -1;
					send_TargetInterior[playerid] = -1;

					ShowReportReasonInput(playerid);
					send_TargetType[playerid] = 3;
				}
				case 3: // Player closest to me
				{
					new
						Float:distance = 100.0,
						targetid;

					targetid = GetClosestPlayerFromPlayer(playerid, distance);

					if(!IsPlayerConnected(targetid) || IsAdminOnDuty(targetid))
					{
						ChatMsgLang(playerid, RED, "REPNOPF100M");
						return 1;
					}

					GetPlayerName(targetid, send_TargetName[playerid], MAX_PLAYER_NAME);
					GetPlayerPos(targetid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
					send_TargetWorld[playerid] = GetPlayerVirtualWorld(targetid);
					send_TargetInterior[playerid] = GetPlayerInterior(targetid);
		
					ShowReportReasonInput(playerid);
					send_TargetType[playerid] = 4;
				}
			}
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Reportar um Jogador", "ID de Jogador (que esteja Online de momento)\nNick do Jogador (que esteja Online de momento)\nJogador que me Matou por último\nJogador mias Próximo de mim", "Enviar", "Cancelar");

	return 1;
}

ShowReportOnlinePlayer(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

	foreach(new i : Player)
	{
		GetPlayerName(i, name, MAX_PLAYER_NAME);
		strcat(list, name);
		strcat(list, "\n");
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			GetPlayerPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
			send_TargetWorld[playerid] = -1;
			send_TargetInterior[playerid] = -1;
			strmid(send_TargetName[playerid], inputtext, 0, strlen(inputtext));

			ShowReportReasonInput(playerid);
		}
		else
			ShowReportMenu(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Reportar Jogador Online", list, "Reportar", "Voltar");

	return 1;
}

ShowReportOfflinePlayer(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			send_TargetName[playerid][0] = EOS;
			strcat(send_TargetName[playerid], inputtext);

			send_TargetPos[playerid][0] = 0.0;
			send_TargetPos[playerid][1] = 0.0;
			send_TargetPos[playerid][2] = 0.0;
			send_TargetWorld[playerid] = -1;
			send_TargetInterior[playerid] = -1;

			ShowReportReasonInput(playerid);
		}
		else
			ShowReportMenu(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Reportar Jogador Offline", "Introduza o Nome do Jogador", "Reportar", "Voltar");

	return 1;
}

ShowReportReasonInput(playerid)
{
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem

		if(response)
		{
			new reporttype[MAX_REPORT_TYPE_LENGTH];

			switch(send_TargetType[playerid])
			{
				case 1: reporttype = REPORT_TYPE_PLAYER_ID;
				case 2: reporttype = REPORT_TYPE_PLAYER_NAME;
				case 3: reporttype = REPORT_TYPE_PLAYER_KILLER;
				case 4: reporttype = REPORT_TYPE_PLAYER_CLOSE;
			}
			ReportPlayer(send_TargetName[playerid], inputtext, playerid, reporttype, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2], send_TargetWorld[playerid], send_TargetInterior[playerid], "");
		}
		else
			ShowReportMenu(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Motivo do Relatório", "Introduza a Motivo para o Relatório.", "Reportar", "Voltar");
}


/*==============================================================================

	Reading reports

==============================================================================*/


ACMD:reports[1](playerid, params[])
{
	if(!ShowListOfReports(playerid))
		ChatMsg(playerid, YELLOW, " » Não existem relatórios para mostrar.");

	log(true, "[COMMAND] %p[%d] (%d) executed /reports", playerid, GetPlayerAdminLevel(playerid), playerid);

	return 1;
}

ACMD:deletereports[4](playerid, params[])
{
	DeleteReadReports();

	for(new i = 0; i < 100; i++)
		DeleteReport(i);

	ChatMsg(playerid, YELLOW, " » Todos os relatórios foram eliminados.");

	return 1;
}

ACMD:deletereadreports[2](playerid, params[])
{
	DeleteReadReports();
	
	ChatMsg(playerid, YELLOW, " » Todos os relatórios lidos foram eliminados.");

	return 1;
}

ShowListOfReports(playerid)
{
	new totalreports = GetReportList(report_CurrentReportList[playerid]);

	if(totalreports == 0)
		return 0;

	new
		colour[9],
		string[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
		idx;

	while(idx < totalreports && idx < MAX_REPORTS_PER_PAGE)
	{
		if(IsPlayerBanned(report_CurrentReportList[playerid][idx][report_name]))
			colour = "{FF0000}";
		else if(!report_CurrentReportList[playerid][idx][report_read])
			colour = "{FFFF00}";
		else
			colour = "{FFFFFF}";

		format(string, sizeof(string), "%s%s%s (%s)\n", string, colour, report_CurrentReportList[playerid][idx][report_name], report_CurrentReportList[playerid][idx][report_type]);

		idx++;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			ShowReport(playerid, listitem);
			report_CurrentItem[playerid] = listitem;
		}
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Relatórios", string, "Abrir", "Sair");

	return 1;
}

ShowReport(playerid, reportlistitem)
{
	new
		ret,
		timestamp,
		reporter[MAX_PLAYER_NAME];

	ret = GetReportInfo(report_CurrentReportList[playerid][reportlistitem][report_rowid],
		report_CurrentReason[playerid],
		timestamp, report_CurrentType[playerid],
		report_CurrentPos[playerid][0],
		report_CurrentPos[playerid][1],
		report_CurrentPos[playerid][2],
		report_CurrentWorld[playerid],
		report_CurrentInterior[playerid],
		report_CurrentInfo[playerid],
		reporter);

	if(!ret)
		return 0;

	new message[512];

	format(message, sizeof(message), "\
		"C_YELLOW"Date:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Reason:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"By:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		report_CurrentReason[playerid],
		reporter);

	SetReportRead(report_CurrentReportList[playerid][reportlistitem][report_rowid], 1);

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
			ShowReportOptions(playerid);
		else
			ShowListOfReports(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_MSGBOX, report_CurrentReportList[playerid][reportlistitem][report_name], message, "Opções", "Voltar");

	return 1;
}

ShowReportOptions(playerid)
{
	new options[128];

	options = "Banir\nEliminar\nEliminar todos os relatórios desse Jogador\nMarcar como não lido\n";

	if(IsAdminOnDuty(playerid))
	{
		strcat(options, "Ir para a posição do relatório\n");

		if(!strcmp(report_CurrentType[playerid], "TELE"))
		{
			strcat(options, "Ir para a posição do Teleport\n");
		}

		if(!strcmp(report_CurrentType[playerid], "CAM"))
		{
			strcat(options, "Ir para a posição da Cãmara\n");
			strcat(options, "Ver Cãmara\n");
		}

		if(!strcmp(report_CurrentType[playerid], "VTP"))
		{
			strcat(options, "Ir para a posição do Veículo\n");
		}
	}
	else
	{
		strcat(options, "(Entre em Modo de Admin para ver mais opções)");	
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext

		if(response)
		{
			switch(listitem)
			{
				case 0:
					ShowReportBanPrompt(playerid);
				case 1:
				{
					DeleteReport(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid]);
					ShowListOfReports(playerid);
				}
				case 2:
				{
					DeleteReportsOfPlayer(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name]);
					ShowListOfReports(playerid);
				}
				case 3:
				{
					SetReportRead(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid], 0);
					ShowListOfReports(playerid);
				}
				case 4:
				{
					if(IsAdminOnDuty(playerid))
					{
						SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}
				case 5:
				{
					if(!strcmp(report_CurrentType[playerid], "TELE"))
					{
						if(IsAdminOnDuty(playerid))
						{
							new Float:x, Float:y, Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}

					if(!strcmp(report_CurrentType[playerid], "CAM"))
					{
						if(IsAdminOnDuty(playerid))
						{
							new Float:x, Float:y, Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff{fff}", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}

					if(!strcmp(report_CurrentType[playerid], "VTP"))
					{
						if(IsAdminOnDuty(playerid))
						{
							new Float:x, Float:y, Float:z;

							sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
							SetPlayerPos(playerid, x, y, z);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						}
					}
				}
				case 6:
				{
					if(!strcmp(report_CurrentType[playerid], "CAM"))
					{
						if(IsAdminOnDuty(playerid))
						{
							new Float:x, Float:y, Float:z, Float:vx, Float:vy, Float:vz;

							sscanf(report_CurrentInfo[playerid], "p<,>ffffff", x, y, z, vx, vy, vz);

							SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
							SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
							SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
							SetPlayerCameraPos(playerid, x, y, z);
							SetPlayerCameraLookAt(playerid, x + vx, y + vy, z + vz);

							ChatMsg(playerid, YELLOW, " » Digite /recam para resetar sua camera");
						}
					}
				}
			}
		}
		else
			ShowReport(playerid, report_CurrentItem[playerid]);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], options, "Selecionar", "Voltar");
}

ShowReportBanPrompt(playerid)
{
	if(GetPlayerAdminLevel(playerid) < 2)
	{
		ChatMsg(playerid, RED, "Não tem permissão para banir Jogadores.");
		ShowReportOptions(playerid);

		return 0;
	}

	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, listitem, inputtext

		if(response)
		{
			new duration = !strcmp(inputtext, "sempre", true) ? 0 : GetDurationFromString(inputtext);

			if(duration == -1)
			{
				ShowReportBanPrompt(playerid);
				return 0;
			}

			BanPlayerByName(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], report_CurrentReason[playerid], playerid, duration);
			ShowListOfReports(playerid);
		}
		else
			ShowReportOptions(playerid);
	}

	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_INPUT, "Introduza o tempo de Banimento", "Introduza o tempo de banimento abaixo. Pode digitar um número, seguido de uma das seguintes opções: 'days', 'weeks' or 'months'. Digite 'sempre' para um ban permamente.", "Continuar", "Cancelar");

	return 1;
}