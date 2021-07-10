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
        nickname[MAX_PLAYER_NAME],
        user_id[DCC_ID_SIZE],
        user_name[DCC_USERNAME_SIZE],
        bool:is_bot;

    DCC_GetMessageId(DCC_Message:message, dest);
    DCC_GetMessageChannel(DCC_Message:message, channel);
    DCC_GetMessageAuthor(DCC_Message:message, author);
    DCC_GetMessageContent(DCC_Message:message, nickname);

    DCC_GetUserId(author, user_id);
    DCC_GetUserName(author, user_name);

    DCC_IsUserBot(author, is_bot);
    
    if(is_bot)
        return 0;

    if(channel == whitelist)
    {
        new result[84+MAX_PLAYER_NAME];

        if(strlen(nickname) > MAX_PLAYER_NAME - 1)
            format(result, sizeof(result),      "> Esse nick `%s` é muito grande.", nickname);
        else if(!strfind(nickname, "."))
            result =                            "> Seu nick não pode ter ponto (.) no inicio."; 
        else if(IsNameInWhitelist(nickname))
            format(result, sizeof(result),      "> Esse nick `%s` ja foi aceito.", nickname); 
        else if(!IsValidUsername(nickname))
            format(result, sizeof(result),      "> Esse nick `%s` é inválido.", nickname); 
        else if(IsNameInWhitelist(user_id))
            format(result, sizeof(result),      "> Você já vinculou essa conta de Jogo com uma conta de Discord.");
        else
        {
            new DCC_Guild:guild;
            
            AddNameToWhitelist(nickname, true);
            AddNameToWhitelist(user_id);

            DCC_GetChannelGuild(channel, guild);
            DCC_SetGuildMemberNickname(guild, author, nickname);

            ChatMsgAll(BLUE, " » '%s' vinculou sua conta de Discord!", nickname);

            format(result, sizeof(result), "> Sua conta de Jogo `%s` foi vinculada com sua conta de Discord com Sucesso. Bom jogo!", nickname);
        }

        DCC_SendChannelMessage(DCC_Channel:channel, result);
    }

    return 1;
}
