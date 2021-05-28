#include <YSI_Coding\y_hooks>

#define CHAT_ID (TGChatId:"-1001250414194")

new TGBot:g_bot;

hook OnGameModeInit() {
	g_bot = TGConnect("1674320979:AAFubItMBmjz-74pvZZ3pdhNQ0I4C3U2W7I");
	if(g_bot != INVALID_BOT_ID) {
		printf("bot connected successfully!");
        TGSendMessage(g_bot, CHAT_ID, "⚠️ Carregando Whitelist...");
	} else {
		printf("Error: bot couldn't connect");
	}
}

public OnTGMessage(TGBot:bot,TGUser:fromid,TGMessage:messageid) {

	if(g_bot != bot){
		return 1;
	}

	new
		message[MAX_PLAYER_NAME + 3],
		username[24],
        str[150];

	TGCacheGetMessage(message);
	TGCacheGetUserName(username);

    if(strfind(message, "/w ", true) == 0)
	{
        strdel(message, 0, 3);

        if(strlen(message) > MAX_PLAYER_NAME - 1)
        { 
            format(str, sizeof(str), "@%s, O nome '%s' é muito grande.", username, message);
        }
        else if(IsNameInWhitelist(message))
        {
            format(str, sizeof(str), "@%s, O nome '%s' já foi aceito.", username, message); 
        }
        else if(IsNameInWhitelist(sprintf("%d", _:fromid)))
        {
            format(str, sizeof(str), "@%s, você já tem uma conta registrada.", username); 
        }
        else
        {
            AddNameToWhitelist(message, true);
            AddNameToWhitelist(sprintf("%d", _:fromid));

            ChatMsgAll(BLUE, "[Telegram] "C_WHITE"Conta '%s' registrada na WhiteList!", message);
            format(str, sizeof(str), "@%s, Sua conta '%s' foi aceita com Sucesso.", username, message); 
        }

        TGSendMessage(g_bot, CHAT_ID, str, messageid);
        return 1;
    }
	return 1;
}