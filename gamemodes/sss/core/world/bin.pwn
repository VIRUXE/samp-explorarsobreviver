
#include <YSI_Coding\y_hooks>

#define MAX_BIN   (106)

static Float:Bin_Pos[MAX_BIN][3] =
{
// 1372
	{776.828002, 	1866.160034, 	3.890630},
	{1336.339965, 	-1842.849975, 	12.664097},
	{1336.790039, 	-1816.300048, 	12.664097},
	{1466.949951, 	-1847.839965, 	12.664097},
	{1419.729980, 	-1846.550048, 	12.664097},
	{1419.699951, 	-1844.199951, 	12.664097},
	{1486.209960, 	-1848.130004, 	12.664097},
	{1468.060058, 	-1847.790039, 	12.664097},
	{1516.689941, 	-1850.050048, 	12.664097},
	{1337.699951, 	-1774.729980, 	12.664097},
	{1461.430053, 	-1489.219970, 	12.679697},
	{1538.949951, 	-1849.270019, 	12.664097},
	{1534.930053, 	-1480.989990, 	8.609377},
	{1537.930053, 	-1480.609985, 	8.609377},
	{1920.050048, 	-2122.409912, 	12.687500},
	{1920.479980, 	-2088.169921, 	12.687500},
	{-827.265991, 	498.195007, 	1357.770019},
	{-829.031005, 	498.195007, 	1357.589965},
	{1427.180053, 	1905.260009, 	9.945307},
	{1446.099975,	1917.589965, 	9.945307},
	{1666.579956, 	2034.530029, 	9.945307},
	{1666.579956, 	2056.000000, 	9.945307},
	{1659.099975, 	2084.479980, 	9.945307},
	{1666.579956, 	2109.219970, 	9.945307},
	{1659.099975, 	2124.229980, 	9.945307},
	{1659.099975, 	2159.110107, 	9.945307},
	{1659.099975, 	2161.600097, 	9.945307},
	{1066.660034, 	1997.050048, 	9.945307},
	{1577.589965, 	2161.149902, 	10.210900},
	{1577.589965, 	2119.100097, 	10.210900},
	{1577.589965, 	2091.540039, 	10.210900},
// 1334
	{-2174.860107, 	-2365.270019, 	30.796899},
	{-2136.500000, 	-2263.899902, 	30.726600},
	{ -2138.659912, -2262.199951, 	30.726600},
	{-2107.209960, 	-2423.889892, 	30.796899},
	{-2087.199951, 	-2343.100097, 	30.796899},
	{1346.270019, 	1064.079956, 	10.929697},
	{1341.349975, 	1064.079956, 	10.929697},
	{1338.800048, 	1164.160034, 	10.929697},
	{1632.020019, 	663.984008, 	10.929697},
	{1634.680053, 	663.984008, 	10.929697},
	{1635.979980, 	892.210998, 	10.929697},
	{1756.579956, 	691.164001, 	10.929697},
	{1756.579956, 	688.625000, 	10.929697},
	{1518.250000, 	971.460998, 	10.929697},
	{1518.250000, 	979.765991, 	10.929697},
	{1557.739990, 	968.312988, 	10.929697},
	{1598.630004, 	1060.660034, 	10.929697},
	{1603.010009, 	1060.660034, 	10.929697},
	{1668.050048, 	911.796997, 	10.929697},
	{1732.739990, 	967.835998, 	10.929697},
	{1745.359985, 	1049.390014, 	10.929697},
	{1680.050048, 	1168.270019, 	10.929697},
	{1680.050048, 	1164.160034, 	10.929697},
	{1734.260009, 	1249.050048, 	10.929697},
//1331
	{-2136.550048, 	-2450.590087, 	30.554700},
	{1004.809997, 	1068.069946, 	10.625000},
    {1002.559997, 	1068.069946, 	10.625000},
    {1339.079956, 	1064.079956, 	10.625000},
    {1303.219970, 	1102.719970, 	10.625000},
    {1478.130004, 	963.562988, 	10.625000},
    {1478.130004, 	967.070007, 	10.625000},
    {1557.660034, 	970.562988, 	10.625000},
    {1464.219970, 	1081.739990, 	10.625000},
//1333
	{ -2146.73, -2462.48, 30.5547 },
	{ -2105.94, -2458.16, 30.5547 },
	{ -2108.49, -2456.17, 30.5547 },
	{ -2103.77, -2479.73, 30.5547 },
	{ -2218.88, -2336.21, 30.4844 },
	{ -2213.96, -2339.30, 30.4844 },
	{ -2176.34, -2424.58, 30.5547 },
// 1415
	{ -77.22, -1188.37, 0.8359 },
	{ -68.35, -1104.99, 0.2188 },
	{ -63.81, -1106.42, 0.2188 },
	{ -541.43, -561.23, 24.5859 },
	{ -513.76, -561.01, 24.5859 },
	{ -502.61, -528.65, 24.5859 },
	{ -620.41, -490.51, 24.5859 },
	{ -619.63, -473.45, 24.5859 },
	{ 2382.02, -1941.04, 12.6641 },
	{ 569.51, -1765.03, 13.5312 },
	{ 732.85, -1332.90, 12.6875 },
	{ 387.15, -1751.51, 7.9453 },
	{ 1694.41, 1160.86, 9.8125 },
	{ 1680.27, 1251.86, 9.9063 },
//1358
	{ 1356.38, 485.19, 20.3750 },
	{ -2462.15, 2512.74, 16.9922 },
	{ -2401.62, 2357.53, 5.1250 },
	{ 2671.60, 867.85, 11.1250 },
	{ 2808.80, 857.20, 10.9297 },
	{ 2863.79, 857.20, 10.9297 },
	{ 2796.84, 977.70, 10.8047 },
	{ 2212.94, 2790.92, 11.0078 },
	{ 2233.80, 2814.15, 11.0078 },
	{ 2332.62, 2785.86, 11.0078 },
	{ 2388.81, 2758.67, 11.0078 },
	{ 1379.03, 980.77, 11.0703 },
	{ 1679.70, 767.43, 11.0078 },
	{ 1689.16, 889.28, 11.0078 },
	{ 1756.03, 771.64, 10.9844 },
	{ 1752.90, 980.40, 10.9844 },
	{ 1653.02, 1076.97, 11.0078 },
	{ 1683.88, 1112.98, 10.9453 },
	{ 1699.51, 1263.01, 11.0000 },
	{ 1740.67, 1217.26, 11.0000 },
	{ 1370.98, 1916.29, 11.0156 }
},

	Button:BIN_Button	[MAX_BIN] = {INVALID_BUTTON_ID, ...},
	disable_BIN		[MAX_BIN],
	Player_BIN		[MAX_PLAYERS];

hook OnGameModeInit(){
	for(new i = 0; i < MAX_BIN; i++){
        BIN_Button[i] = CreateButton(Bin_Pos[i][0], Bin_Pos[i][1], Bin_Pos[i][2] + 0.5,
			"Pressione F para vasculhar", 0, 0, 2.1, 1, "Lixeira", .testlos = false);

		SetButtonExtraData(BIN_Button[i], i + MAX_BIN);

        disable_BIN[i] = 0;
	}
}

hook OnPlayerConnect(playerid)
    Player_BIN[playerid] = -1;


hook OnButtonPress(playerid, Button:buttonid){
	if(Player_BIN[playerid] != -1){
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		Player_BIN[playerid] = -1;
		return Y_HOOKS_BREAK_RETURN_1;
	} else {
		
		if(IsValidItem(GetPlayerInteractingItem(playerid)))
			return Y_HOOKS_CONTINUE_RETURN_0;

		new binid;
		GetButtonExtraData(buttonid, binid);
		if(binid >= MAX_BIN){
			if(disable_BIN[binid - MAX_BIN]) {
				ShowActionText(playerid, "~r~Vazio.", 2000);
			} else {
				Player_BIN[playerid] = binid - MAX_BIN;

				new Float:x, Float:y, Float:z;
				GetPlayerPos(playerid, x, y, z);

				SetPlayerFacingAngle(playerid,
					GetAngleToPoint(x, y, Bin_Pos[binid - MAX_BIN][0], Bin_Pos[binid - MAX_BIN][1]));

				ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

				ShowActionText(playerid, "Revistando Lixo...", 6000);
				StartHoldAction(playerid, 6000);
			}
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress){
    if(Player_BIN[playerid] != -1){
		if(GetPlayerTotalVelocity(playerid) > 1.5){
			Player_BIN[playerid] = -1;
			StopHoldAction(playerid);
			ClearAnimations(playerid);
		}
		if(random(5) == 1)
	    	PlayerPlaySound(playerid, 1131, 0.0, 0.0, 0.0);

		return Y_HOOKS_BREAK_RETURN_0;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid){
	if(Player_BIN[playerid] != -1) {
	    if(random(5) == 2) {
	        ShowActionText(playerid, "~r~Nada encontrado.");
	    } else {
			new Float:x, Float:y, Float:z;
			GetPlayerPos(playerid, x, y, z);
			CreateLootItem(GetLootIndexFromName("world_survivor"), x, y, z - ITEM_FLOOR_OFFSET);
			defer RestartBIN(Player_BIN[playerid]);
	    }

	    ClearAnimations(playerid);
		disable_BIN[Player_BIN[playerid]] = 1;
	    Player_BIN[playerid] = -1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer RestartBIN[ITEM_RESPAWN_DELAY](binid)
	disable_BIN[binid] = 0;

