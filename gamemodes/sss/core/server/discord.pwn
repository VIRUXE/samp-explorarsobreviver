
#include <YSI_Coding\y_va>

static stock msgBuffer[4000]; // O Limite de texto no Discord é de 4000 caractéres.

stock SendDiscordMessage(DCC_Channel:channel, const fmat[], va_args<>)
{
	formatex(msgBuffer, sizeof(msgBuffer), fmat, va_start<2>);
	DCC_SendChannelMessage(channel, msgBuffer);

	return 1;
}

stock bool:DoesDiscordIdExist(const discordId[DCC_ID_SIZE])
{
	new
		DBStatement:stmt_IdExists = db_prepare(gAccounts, "SELECT COUNT(*) FROM Player WHERE discord_id=? COLLATE NOCASE"),
		count;

	log(true, "DoesDiscordIdExist - DiscordId: %s", discordId);

	stmt_bind_value(stmt_IdExists, 0, DB::TYPE_STRING, discordId, DCC_ID_SIZE);
	stmt_bind_result_field(stmt_IdExists, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_IdExists))
		stmt_fetch_row(stmt_IdExists);
	else
		err(false, true, "Não foi possível executar stmt_IdExists");

	return count > 0 ? true : false;
}