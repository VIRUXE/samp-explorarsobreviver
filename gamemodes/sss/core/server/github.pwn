#include <YSI\y_hooks>
/*
    Retrieves the amount of total commits from the repository. Making it the gamemode's version
*/

forward GitHubResponse(index, response_code, data[]);
 
hook OnGameModeInit()
{
        HTTP(9999, HTTP_GET, "www.sa-mp.com/service_agreement.txt", "", "GitHubResponse");
}
 
public GitHubResponse(index, response_code, data[])
{
    #pragma unused index

    //new buffer[ 128 ];

    if(response_code == 200) // Success
    {
        //format(buffer, sizeof(buffer), "The URL replied: %s", data);
        log(DISCORD_CHANNEL_DEV, "[GITHUB] %s", data);
    }
    else
        log(DISCORD_CHANNEL_DEV, "[GITHUB] Failed. Response code: %d", response_code);
}