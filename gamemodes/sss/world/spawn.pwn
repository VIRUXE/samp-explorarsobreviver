#include <YSI\y_timers>

static
	Float:spawn_List[][4] =
	{
		{-2923.4396,	-70.4305,		0.7973,		269.0305},
		{-2914.9213,	-902.9458,		0.5190,		339.3433},
		{-2804.5021,	-2296.2153,		0.7071,		249.8544},
		{-228.7865,		-1719.8090,		1.1083,		34.9733},
		{13.9133,		-1112.0993,		1.2848,		110.2575},
		{-325.7897,		-467.2996,		1.9922,		48.1126},
		{-71.3649,		-577.1849,		1.3816,		351.6495},
		{161.5016,		157.5428,		1.1178,		187.3177},
		{2012.8952,		-38.5986,		1.2391,		4.8748},
		{2117.7065,		183.7778,		1.0822,		74.3911},
		{-1886.1279,	2160.1945,		1.4039,		335.7922},
		{-764.4365,		654.4160,		1.7907,		1.7156},
		{-434.6048,		867.6434,		1.4236,		318.3918},
		{-638.7510,		1286.1458,		1.4520,		110.0257}
	},
	spawn_Last[MAX_PLAYERS];



stock GenerateSpawnPoint(playerid, &Float:x, &Float:y, &Float:z, &Float:r)
{
	new index = random(sizeof(spawn_List));

	while(index == spawn_Last[playerid])
		index = random(sizeof(spawn_List));

	x = spawn_List[index][0];
	y = spawn_List[index][1];
	z = spawn_List[index][2];
	r = spawn_List[index][3];

	spawn_Last[playerid] = index;
}

_GenerateRandomSpawnPoint(&Float:x, &Float:y, &Float:z)
{
	new
		Float:randomX = frandom(3000.0, -3000.0),
		Float:randomY = frandom(3000.0, -3000.0),
		Float:depth, Float:posDepth;

	x = randomX;
	y = randomY;

	CA_FindZ_For2DCoord(randomX, randomY, z);

	while(IsPosInWater(x,y,z, depth, posDepth))
		_GenerateRandomSpawnPoint(x,y,z);

	while(IsPosNearWater(x,y,z))
		_GenerateRandomSpawnPoint(x,y,z);

	z +=1.0;
}

stock SpawnPlayerAtRandomPoint(playerid, &Float:x, &Float:y, &Float:z)
{
	new parachute = IsPlayerVIP(playerid) || random(100) < 40 ? true : false;

	_GenerateRandomSpawnPoint(x,y,z);

	if(parachute)
	{
		z = IsPlayerVIP(playerid) ? frandom(1000.0, 500.0) : 500.0;
		GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 1);
	}

	SetPlayerPos(playerid, x,y,z);
		
	if(!parachute && CA_IsPlayerBlocked(playerid, 3.0, 1.0))
	{
		printf("CA_IsPlayerBlocked - %0.4f %0.4f %0.4f", x,y,z);

		_GenerateRandomSpawnPoint(x,y,z);
		SetPlayerPos(playerid, x,y,z);
	}

	log(false, "[SPAWN] %p spawned at %0.1f %0.1f %0.1f - %s", playerid, x,y,z, GetPlayerZoneName(playerid, true));
}

CMD:testspawn(playerid)
{
	new Float:x, Float:y, Float:z;

	SpawnPlayerAtRandomPoint(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, "Spawn Coords: X:%0.4f, Y:%0.4f, Z:%0.4f", x, y, z);

	return 1;
}