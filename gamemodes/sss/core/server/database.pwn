#include <YSI_Coding\y_hooks>

new MySQL: gDatabase;

hook OnGameModeInit()
{
	new MySQLOpt: option_id = mysql_init_options();

	mysql_set_option(option_id, AUTO_RECONNECT, true); // it automatically reconnects when loosing connection to mysql server

	gDatabase = mysql_connect(MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE, option_id); // AUTO_RECONNECT is enabled for this connection handle only
	if (gDatabase == MYSQL_INVALID_HANDLE || mysql_errno(gDatabase) != 0)
	{
		log(true, "[DATABASE] MySQL connection failed. Server is shutting down.");
		SendRconCommand("exit"); // close the server if there is no connection
	}
    else
	    log(true, "[DATABASE] MySQL connection is successful.");
}

hook OnGameModeExit()
{
    log(true, "[DATABASE] Closing MySQL connection..."); 
	mysql_close(gDatabase);
    log(true, "[DATABASE] MySQL connection closed.");
	return 1;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
    log(true, "[DATABASE] Erro.");
}