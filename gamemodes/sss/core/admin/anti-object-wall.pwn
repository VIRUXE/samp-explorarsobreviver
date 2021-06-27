#include <YSI_Coding\y_hooks>

new Timer:pCheckViewObj[MAX_PLAYERS][MAX_OBJECTS];

ORPC:44(playerid, BitStream:bs){
	new
		objectid,
		ModelID,
		Float:X,
		Float:Y,
		Float:Z,
		Float:RX,
		Float:RY,
		Float:RZ,
		Float:d,
		NoCamera,
		attobj,
		attve;
		
    BS_ReadValue(bs,
		PR_UINT16, objectid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, RX,
		PR_FLOAT, RY,
		PR_FLOAT, RZ,
		PR_FLOAT, d,
		PR_UINT8, NoCamera,
        PR_UINT16, attobj,
        PR_UINT16, attve
	);
	    
	// Only detect tents and safeboxes.
	// If necessary, define more models in the future
	if(ModelID == 1279 || ModelID == 19477 || ModelID == 19087 ||
		ModelID == 3014 || ModelID == 2969 || ModelID == 1271) {
		stop pCheckViewObj[playerid][objectid];

		if(!IsPlayerViewingObject(playerid, X, Y, Z)) {
	    	pCheckViewObj[playerid][objectid] = repeat CheckViewObj(playerid, objectid,\
		    	ModelID, X, Y, Z, RX, RY, RZ, d, NoCamera, attobj, attve);
			
			return 0;
		}
	}

	return 1;
}

timer CheckViewObj[200](playerid, objectid, ModelID, \
Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ, Float:d, NoCamera, attobj, attve){
	if(IsPlayerViewingObject(playerid, X, Y, Z)){
		stop pCheckViewObj[playerid][objectid];
    	ShowObjectForPlayer(objectid, playerid, ModelID, X, Y, Z, RX, RY, RZ, d, NoCamera, attobj, attve);
	}
}

ORPC:47(playerid, BitStream:bs){
	new objectid;
    BS_ReadValue(bs, PR_UINT16, objectid);
    stop pCheckViewObj[playerid][objectid];
	return 1;
}

IsPlayerViewingObject(playerid, Float:X, Float:Y, Float:Z){
	new
	    Float:px,
	    Float:py,
	    Float:pz,
		Float:tmp,
		rayid;

	GetPlayerPos(playerid, px, py, pz);

	rayid = CA_RayCastLine(X, Y, Z, px, py, pz, tmp, tmp, tmp);

	return (rayid != WATER_OBJECT || rayid != 0);
}

ShowObjectForPlayer(objectid, toplayerid, ModelID, \
Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ, Float:d, NoCamera, attobj, attve){
    new BitStream:bs = BS_New();
    BS_WriteValue(bs,
		PR_UINT16, objectid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, RX,
		PR_FLOAT, RY,
		PR_FLOAT, RZ,
		PR_FLOAT, d,
		PR_UINT8, NoCamera,
        PR_UINT16, attobj,
        PR_UINT16, attve);
	
    PR_SendRPC(bs, toplayerid, 44);
    BS_Delete(bs);
}