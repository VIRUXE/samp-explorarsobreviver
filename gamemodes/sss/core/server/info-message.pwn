
#include <YSI_Coding\y_hooks>


#define MAX_INFO_MESSAGE			(32)
#define MAX_INFO_MESSAGE_LEN		(256)


static
		ifm_Messages[MAX_INFO_MESSAGE][MAX_INFO_MESSAGE_LEN],
		ifm_Total,
		ifm_Interval,
		ifm_Current;


hook OnScriptInit()
{
	GetSettingStringArray(
		"infomessage/messages",
		"Please update the 'server/infomsgs' array in '"SETTINGS_FILE"'.",
		MAX_INFO_MESSAGE,
		ifm_Messages,
		ifm_Total,
		MAX_INFO_MESSAGE_LEN);

	GetSettingInt("infomessage/interval", 5, ifm_Interval);

	defer InfoMessage();
}

timer InfoMessage[ifm_Interval * 60000]()
{
	if(ifm_Current >= ifm_Total)
		ifm_Current = 0;

	ChatMsgAll(YELLOW, " » "C_BLUE"%s", ifm_Messages[ifm_Current]);

	ifm_Current++;

	defer InfoMessage();
}
