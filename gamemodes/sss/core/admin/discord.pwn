#include <YSI_Coding\y_hooks>

static DCC_Channel:whitelist;

hook OnScriptInit()
{
    whitelist = DCC_FindChannelByName("whitelist");
}

public DCC_OnMessageCreate(DCC_Message:message)
{
    new
        dest[DCC_ID_SIZE],
        DCC_Channel:channel,
        DCC_User:author,
        str[128],
        msg[24],
        user_id[DCC_ID_SIZE],
        user_name[DCC_USERNAME_SIZE],
        bool:is_bot;

    DCC_GetMessageId(DCC_Message:message, dest);
    DCC_GetMessageChannel(DCC_Message:message, channel);
    DCC_GetMessageAuthor(DCC_Message:message, author);
    DCC_GetMessageContent(DCC_Message:message, msg);

    DCC_GetUserId(author, user_id);
    DCC_GetUserName(author, user_name);

    DCC_IsUserBot(author, is_bot);
    
    if(is_bot)
        return 0;

    if(channel == whitelist)
    {
        if(strlen(msg) > MAX_PLAYER_NAME - 1)
            format(str, sizeof(str),    "> O nome (%s) esta muito grande.", msg);

        else if(!strfind(msg, "."))
            format(str, sizeof(str),    "> Seu nome nao pode ter ponto (.) no inicio.", msg); 

        else if(IsNameInWhitelist(msg))
            format(str, sizeof(str),    "> O nome (%s) ja foi aceito.", msg); 

        else if(!IsValidUsername(msg))
            format(str, sizeof(str),    "> O nome (%s) invalido.", msg); 

        else if(IsNameInWhitelist(user_id))
            format(str, sizeof(str),    "> Voce ja tem uma conta registrada nesse discord.");

        else {
            AddNameToWhitelist(msg, true);
            AddNameToWhitelist(user_id);

            ChatMsgAll(BLUE, " » Conta (%s) registrada na WhiteList!", msg);

            format(str, sizeof(str), "> Sua conta (%s) foi aceita com Sucesso. Bom jogo!", msg);
        }

        DCC_SendChannelMessage(DCC_Channel:channel, str);
    }

    return 1;
}
