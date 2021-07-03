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
        bool:is_bot;//,
        //color = RED;

    DCC_GetMessageId(DCC_Message:message, dest);
    DCC_GetMessageChannel(DCC_Message:message, channel);
    DCC_GetMessageAuthor(DCC_Message:message, author);
    DCC_GetMessageContent(DCC_Message:message, msg);

    DCC_GetUserId(author, user_id);
    DCC_GetUserName(author, user_name);
    DCC_IsUserBot(author, is_bot);
    
    if(is_bot){
        //defer DelWhiteMsg(_:message);
        return 0;
    }

    if(strfind(msg, "/tab", true) == 0)
    {
        new DCC_Embed:embed = DCC_CreateEmbed();

        DCC_SetEmbedTitle(embed, "Jogadores online");

        foreach(new i : Player)
        {
            DCC_AddEmbedField(embed, "id",      sprintf("%d", i), true);
            DCC_AddEmbedField(embed, "name",    sprintf("%p", i), true);
            DCC_AddEmbedField(embed, "score",   sprintf("%d", GetPlayerScore(i)), true);
            DCC_AddEmbedField(embed, "ping",    sprintf("%d", GetPlayerPing(i)), true);
        }
            
        //DCC_SetEmbedColor(embed, GREEN);
        DCC_SendChannelEmbedMessage(channel, embed, "");
        //DCC_DeleteMessage(DCC_Message:message);
        return 1;
    }

    if(strfind(msg, "/status ", true) != -1)
    {
        strdel(msg, 0, 8);
        
        new id = strval(msg);

        if(!IsPlayerConnected(id))
            return 1;
 
        new DCC_Embed:embed = DCC_CreateEmbed();
        DCC_SetEmbedTitle(embed, sprintf("%p(id:%d)", id, id));
        DCC_SetEmbedThumbnail(embed, sprintf("https://assets.open.mp/assets/images/skins/%d.png", GetPlayerSkin(id)));
        DCC_AddEmbedField(embed, "Score", sprintf("%d", GetPlayerScore(id)), true);
        DCC_AddEmbedField(embed, "Ping", sprintf("%d", GetPlayerPing(id)), true);
        //DCC_SetEmbedColor(embed, YELLOW);
        DCC_SendChannelEmbedMessage(channel, embed, "", "OnPostPlayerStat", "i", id);
        //DCC_DeleteMessage(DCC_Message:message);
        return 1;
    }
    else if(channel == whitelist)
    {
        if(strlen(msg) > MAX_PLAYER_NAME - 1)
            format(str, sizeof(str), "O nome [%s] esta muito grande.", msg);
        else if(IsNameInWhitelist(msg))
            format(str, sizeof(str), "O nome [%s] ja foi aceito.", msg); 
        else if(IsNameInWhitelist(user_id))
            format(str, sizeof(str), "Voce ja tem uma conta registrada nesse discord."); 
        else{
            AddNameToWhitelist(msg, true);
            AddNameToWhitelist(user_id);

            ChatMsgAll(BLUE, "[Discord] "C_WHITE"Conta '%s' registrada na WhiteList!", msg);

            format(str, sizeof(str), "Sua conta [%s] foi aceita com Sucesso. Bom jogo!", msg);
        }

        DCC_SendChannelMessage(DCC_Channel:channel, str);

        //DCC_SendChannelEmbedMessage(DCC_Channel:channel,
            //DCC_CreateEmbed(user_name, str, "", "", color), "[WhiteList]");

        //DCC_DeleteMessage(DCC_Message:message);
        return 1;
    }
    return 1;
}

//timer DelWhiteMsg[60000](message)
    //DCC_DeleteMessage(DCC_Message:message);
    
forward OnPostPlayerStat(playerid);
public OnPostPlayerStat(playerid)
{
	/*new DCC_Message:message = DCC_GetCreatedMessage();
    DCC_CreateReaction(message, DCC_CreateEmoji(":ES:"));
    DCC_CreateReaction(message, DCC_CreateEmoji("🔨"));   
//	DCC_SetMessagePersistant(message, true);*/
}
