
enum
{
	VEHICLE_TYPE_CAR,
	VEHICLE_TYPE_HEAVY,
	VEHICLE_TYPE_MONSTER,
	VEHICLE_TYPE_QUAD,
	VEHICLE_TYPE_MOTORBIKE,
	VEHICLE_TYPE_BICYCLE,
	VEHICLE_TYPE_HELI,
	VEHICLE_TYPE_PLANE,
	VEHICLE_TYPE_SEA,
	VEHICLE_TYPE_TRAILER,
	VEHICLE_TYPE_TRAIN
}

stock bool:CanVehicleHaveColour(model)
{
	switch(model)
	{
		case 416, 433, 523, 427, 490, 528, 407, 544, 596, 597, 598, 599, 432, 601:
			return false;
	}

	return true;
}

stock GetVehicleModelType(model)
{
	new type;

	switch(model)
	{
	// CARS
		case
		416,   //ambulan  -  car
		445,   //admiral  -  car
		602,   //alpha  -  car
		485,   //baggage  -  car
		568,   //bandito  -  car
		429,   //banshee  -  car
		499,   //benson  -  car
		424,   //bfinject,   //car
		536,   //blade  -  car
		496,   //blistac  -  car
		504,   //bloodra  -  car
		422,   //bobcat  -  car
		609,   //boxburg  -  car
		498,   //boxville,   //car
		401,   //bravura  -  car
		575,   //broadway,   //car
		518,   //buccanee,   //car
		402,   //buffalo  -  car
		541,   //bullet  -  car
		482,   //burrito  -  car
		431,   //bus  -  car
		438,   //cabbie  -  car
		457,   //caddy  -  car
		527,   //cadrona  -  car
		483,   //camper  -  car
		524,   //cement  -  car
		415,   //cheetah  -  car
		542,   //clover  -  car
		589,   //club  -  car
		480,   //comet  -  car
		596,   //copcarla,   //car
		599,   //copcarru,   //car
		597,   //copcarsf,   //car
		598,   //copcarvg,   //car
		578,   //dft30  -  car
		486,   //dozer  -  car
		507,   //elegant  -  car
		562,   //elegy  -  car
		585,   //emperor  -  car
		427,   //enforcer,   //car
		419,   //esperant,   //car
		587,   //euros  -  car
		490,   //fbiranch,   //car
		528,   //fbitruck,   //car
		533,   //feltzer  -  car
		544,   //firela  -  car
		407,   //firetruk,   //car
		565,   //flash  -  car
		455,   //flatbed  -  car
		530,   //forklift,   //car
		526,   //fortune  -  car
		466,   //glendale,   //car
		604,   //glenshit,   //car
		492,   //greenwoo,   //car
		474,   //hermes  -  car
		434,   //hotknife,   //car
		502,   //hotrina  -  car
		503,   //hotrinb  -  car
		494,   //hotring  -  car
		579,   //huntley  -  car
		545,   //hustler  -  car
		411,   //infernus,   //car
		546,   //intruder,   //car
		559,   //jester  -  car
		508,   //journey  -  car
		571,   //kart  -  car
		400,   //landstal,   //car
		403,   //linerun  -  car
		517,   //majestic,   //car
		410,   //manana  -  car
		551,   //merit  -  car
		500,   //mesa  -  car
		418,   //moonbeam,   //car
		572,   //mower  -  car
		423,   //mrwhoop  -  car
		516,   //nebula  -  car
		582,   //newsvan  -  car
		467,   //oceanic  -  car
		404,   //peren  -  car
		514,   //petro  -  car
		603,   //phoenix  -  car
		600,   //picador  -  car
		413,   //pony  -  car
		426,   //premier  -  car
		436,   //previon  -  car
		547,   //primo  -  car
		489,   //rancher  -  car
		441,   //rcbandit,   //car
		594,   //rccam  -  car
		564,   //rctiger  -  car
		515,   //rdtrain  -  car
		479,   //regina  -  car
		534,   //remingtn,   //car
		505,   //rnchlure,   //car
		442,   //romero  -  car
		440,   //rumpo  -  car
		475,   //sabre  -  car
		543,   //sadler  -  car
		605,   //sadlshit,   //car
		495,   //sandking,   //car
		567,   //savanna  -  car
		428,   //securica,   //car
		405,   //sentinel,   //car
		535,   //slamvan  -  car
		458,   //solair  -  car
		580,   //stafford,   //car
		439,   //stallion,   //car
		561,   //stratum  -  car
		409,   //stretch  -  car
		560,   //sultan  -  car
		550,   //sunrise  -  car
		506,   //supergt  -  car
		601,   //swatvan  -  car
		574,   //sweeper  -  car
		566,   //tahoma  -  car
		549,   //tampa  -  car
		420,   //taxi  -  car
		459,   //topfun  -  car
		576,   //tornado  -  car
		583,   //tug  -  car
		451,   //turismo  -  car
		558,   //uranus  -  car
		552,   //utility  -  car
		540,   //vincent  -  car
		491,   //virgo  -  car
		412,   //voodoo  -  car
		478,   //walton  -  car
		421,   //washing  -  car
		529,   //willard  -  car
		555,   //windsor  -  car
		456,   //yankee  -  car
		554,   //yosemite -  car
		477   //zr350  -  car
		: type = VEHICLE_TYPE_CAR;

	// BIKES
		case
		581,   //bf400  -  bike
		523,   //copbike  -  bike
		462,   //faggio  -  bike
		521,   //fcr900  -  bike
		463,   //freeway  -  bike
		522,   //nrg500  -  bike
		461,   //pcj600  -  bike
		448,   //pizzaboy,   //bike
		468,   //sanchez  -  bike
		586   //wayfarer,   //bike
		: type = VEHICLE_TYPE_MOTORBIKE;

	// BMX
		case
		509,   //bike  -  bmx
		481,   //bmx  -  bmx
		510   //mtbike  -  bmx
		: type = VEHICLE_TYPE_BICYCLE;

	// QUADS
		case
		471   //quad  -  quad
		: type = VEHICLE_TYPE_QUAD;

	// SEA
		case
		472,   //coastg  -  boat
		473,   //dinghy  -  boat
		493,   //jetmax  -  boat
		595,   //launch  -  boat
		484,   //marquis  -  boat
		430,   //predator,   //boat
		453,   //reefer  -  boat
		452,   //speeder  -  boat
		446,   //squalo  -  boat
		454   //tropic  -  boat
		: type = VEHICLE_TYPE_SEA;

	// HELI
		case
		548,   //cargobob,   //heli
		425,   //hunter  -  heli
		417,   //leviathn,   //heli
		487,   //maverick,   //heli
		497,   //polmav  -  heli
		563,   //raindanc,   //heli
		501,   //rcgoblin,   //heli
		465,   //rcraider,   //heli
		447,   //seaspar  -  heli
		469,   //sparrow  -  heli
		488   //vcnmav  -  heli
		: type = VEHICLE_TYPE_HELI;

	// PLANE
		case
		592,   //androm  -  plane
		577,   //at	400  -  plane
		511,   //beagle  -  plane
		512,   //cropdust,   //plane
		593,   //dodo  -  plane
		520,   //hydra  -  plane
		553,   //nevada  -  plane
		464,   //rcbaron  -  plane
		476,   //rustler  -  plane
		519,   //shamal  -  plane
		460,   //skimmer  -  plane
		513,   //stunt  -  plane
		539   //vortex  -  plane
		: type = VEHICLE_TYPE_PLANE;

	// HEAVY
		case
		588,   //hotdog  -  car
		437,   //coach  -  car
		532,   //combine  -  car
		433,   //barracks,   //car
		414,   //mule  -  car
		443,   //packer  -  car
		470,   //patriot  -  car
		432,   //rhino  -  car
		525,   //towtruck,   //car
		531,   //tractor  -  car
		408   //trash  -  car
		: type = VEHICLE_TYPE_HEAVY;

	// MONSTER
		case
		406,   //dumper  -  mtruck
		573,   //duneride,   //mtruck
		444,   //monster  -  mtruck
		556,   //monstera,   //mtruck
		557   //monsterb,   //mtruck
		: type = VEHICLE_TYPE_MONSTER;

	// TRAILER
		case
		435,   //artict1  -  trailer
		450,   //artict2  -  trailer
		591,   //artict3  -  trailer
		606,   //bagboxa  -  trailer
		607,   //bagboxb  -  trailer
		610,   //farmtr1  -  trailer
		584,   //petrotr  -  trailer
		608,   //tugstair -  trailer
		611   //utiltr1  -  trailer
		: type = VEHICLE_TYPE_TRAILER;

	// TRAIN
		case
		590,   //freibox  -  train
		569,   //freiflat,   //train
		537,   //freight  -  train
		538,   //streak  -  train
		570,   //streakc  -  train
		449   //tram  -  train
		: type = VEHICLE_TYPE_TRAIN;
	}
	return type;
}

stock GetRandomVehicleColour()
{
	new VehicleColoursTableRGBA[256] = {
		// The existing colours from San Andreas
		0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
		0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
		0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
		0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
		0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
		0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
		0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
		0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
		0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
		0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
		0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
		0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
		0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
		// SA-MP extended colours (0.3x)
		0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
		0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
		0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
		0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
		0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
		0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
		0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
		0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
		0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
		0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
		0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
		0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
		0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
	};

	return VehicleColoursTableRGBA[random(sizeof(VehicleColoursTableRGBA))];
}