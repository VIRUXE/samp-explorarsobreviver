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
        bool:is_bot,
        color = RED;

    DCC_GetMessageId(DCC_Message:message, dest);
    DCC_GetMessageChannel(DCC_Message:message, channel);
    DCC_GetMessageAuthor(DCC_Message:message, author);
    DCC_GetMessageContent(DCC_Message:message, msg);

    DCC_GetUserId(author, user_id);
    DCC_GetUserName(author, user_name);
    DCC_IsUserBot(author, is_bot);
    
    if(is_bot)
        return 1;


    if(!strcmp(msg, "/status ", false))
    {
        strdel(msg, 0, 8);
        
        new id = strval(msg);

        if(!IsPlayerConnected(id))
            return 1;
            
        new sName[MAX_PLAYER_NAME];
        GetPlayerName(id, sName, MAX_PLAYER_NAME);

        new DCC_Embed:emb = DCC_CreateEmbed(sName,
            sprintf("%p - ID: %d  -  Score: %d", id, id, GetPlayerScore(id)),
           "", "", YELLOW, "", "", sprintf("https://assets.open.mp/assets/images/skins/%d.png", GetPlayerSkin(id)));

        DCC_SendChannelEmbedMessage(channel, emb, "Player Status");
    }
    else if(channel == whitelist)
    {
        if(strlen(msg) > MAX_PLAYER_NAME - 1)
        { 
            format(str, sizeof(str), "O nome [%s] esta muito grande.", msg);
        }
        else if(IsNameInWhitelist(msg))
        {
            format(str, sizeof(str), "O nome [%s] ja foi aceito.", msg); 
        }
        else if(IsNameInWhitelist(user_id))
        {
            format(str, sizeof(str), "Voce ja tem uma conta registrada nesse discord."); 
        }
        else
        {
            new 
                bool:IsWConnected,
                pName[MAX_PLAYER_NAME];

            foreach(new i : Player)
            {   
                GetPlayerName(i, pName, MAX_PLAYER_NAME);

                if(!strcmp(pName, msg, false))
                    IsWConnected = true;
            }

            if(!IsWConnected)
            {
                format(str, sizeof(str), "Voce precisa estar conectado no Servidor.");
            }
            else
            {
                color = GREEN;
                AddNameToWhitelist(msg, true);
                AddNameToWhitelist(user_id);

                ChatMsgAll(BLUE, "[Discord] "C_WHITE"Conta '%s' registrada na WhiteList!", msg);

                format(str, sizeof(str), "Sua conta [%s] foi aceita com Sucesso. Bom jogo!", msg);
            }
        }

        DCC_SendChannelEmbedMessage(DCC_Channel:channel,
            DCC_CreateEmbed(user_name, str, "", "", color), "[WhiteList]");

        DCC_DeleteMessage(DCC_Message:message);
        return 0;
    }
    return 1;
}