//-------------------------------------------------------
//
// GRAND LARCENY Property creation and management script
//
// by damospiderman 2008
//
//-------------------------------------------------------

#include <YSI_Coding\y_hooks>

//----------------------------------------------------------
// Tokenise by a delimiter
// Return string and index of the end determined by the
// provided delimiter in delim

stock token_by_delim(const string[], return_str[], delim, start_index)
{
	new x=0;
	while(string[start_index] != EOS && string[start_index] != delim) {
	    return_str[x] = string[start_index];
	    x++;
	    start_index++;
	}
	return_str[x] = EOS;
	if(string[start_index] == EOS) start_index = (-1);
	return start_index;
}

//----------------------------------------------------------

//#define PROP_VW    		(1000)
#define MAX_INTERIORS	(146)
#define MAX_PROPERTIES  (1000)

#define PROPERTY_FOLDER	"properties" // Location of properties file
#define PROPERTY_UNIQID_FILE    "properties/uniqId.txt" // Location of Uniq Interior Info
#define DB_PROPERTIES   "properties/dbProperties.db" // Location of the properties Database

#define MAX_TYPES       (5)
#define TYPE_EMPTY      (0)
#define TYPE_HOUSE 		(1)
#define TYPE_BUSINESS	(2)
#define TYPE_BANK   	(3)
#define TYPE_COP        (4)

enum // Property Type Enum
	E_P_TYPES {
		tIcon,
		tName[32]
	}

enum // Uniq Interiors Enum
	E_INTERIORS {
		inIntID,
		Float:inExitX,
		Float:inExitY,
		Float:inExitZ,
		Float:inExitA,
		inName[64]
	};

enum // Properties Enum
	E_PROPERTIES {
		eInterior,
		eType,
		Float:eEntX,
		Float:eEntY,
		Float:eEntZ,
		Float:eEntA,
		eUniqIntId,
		eOwner,
		ePrice,
		ePname[64]
	};

//  [ uniq property id ]
new	unid;

//	[ Array of all the property interior info ]
new interiorInfo[MAX_INTERIORS][E_INTERIORS];

//	[ Pickup array with property id assigned via array slot ( pickupid ) ]
new propPickups[MAX_PROPERTIES] = {-1};

// 	[ Mass array of all the properties and info about them ]
new properties[MAX_PROPERTIES][E_PROPERTIES];

//	[ The last pickup the player went through so they can do /enter command ]
new lastPickup[MAX_PLAYERS] = {-1};

//	[ Current property Unique Interior the player is in.. defaults to -1 when not in any property ]
new currentInt[MAX_PLAYERS] = {-1};

//  [ Array of property type iconid's and strings for property type ]
new propIcons[MAX_TYPES][E_P_TYPES] =	{
											{ 0, "" }, 					// TYPE_EMPTY ( not used )
											{ 19133, "House" }, 			// TYPE_HOUSE green house icon
											{ 19133, "Business" }, 		// TYPE_BUSINESS blue house icon
											{ 19133, "Bank" }, 			// TYPE_BANK dollar sign icon
											{ 19133, "Police Station" }	// TYPE_COP Bribe Star 1247
										};
										
new	propFile[MAX_TYPES][64] =   {
									{ "blank" },
		                            { "properties/houses.txt" },
		                            { "properties/businesses.txt" },
		                            { "properties/banks.txt" },
		                            { "properties/police.txt" }
							 	};
							 	
//  Keep track of what properties we've sent an /enter notification for
new gLastPropertyEnterNotification[MAX_PLAYERS];


/********************************
*   Interior Info Functions     *
********************************/
stock Float:GetInteriorExit( id, &Float:x, &Float:y, &Float:z ){
	if( id > MAX_INTERIORS ) return 0.0;
	else {
	    x = interiorInfo[id][inExitX];
	    y = interiorInfo[id][inExitY];
	    z = interiorInfo[id][inExitZ];
		return interiorInfo[id][inExitA];
	}
}

// Gets interior exit info from uniq Interior Id. Returns InteriorId or -1 if interior doesn't exist
stock GetInteriorExitInfo( uniqIntId, &Float:exitX, &Float:exitY, &Float:exitZ, &Float:exitA ){
	if( uniqIntId < MAX_INTERIORS ){
	    exitX = interiorInfo[uniqIntId][inExitX];
	    exitY = interiorInfo[uniqIntId][inExitY];
	    exitZ = interiorInfo[uniqIntId][inExitZ];
	    exitA = interiorInfo[uniqIntId][inExitA];
		return interiorInfo[uniqIntId][inIntID];
	}
	return -1;
}


stock GetInteriorIntID( id ){ // Gets the interior id of a uniq Interior Id :S
	if( id > MAX_INTERIORS ) return -1;
	else return interiorInfo[id][inIntID];
}

stock GetInteriorName( id )
{
	new tmp[64];
	if( id > MAX_PROPERTIES ) return tmp;

	else {
  		format( tmp, 64, "%s", interiorInfo[id][inName] );
		return tmp;
	}
}

/********************************************************
********************************************************/


/********************************
*  	 Property Functions  		*
********************************/

stock Float:GetPropertyEntrance( id, &Float:x, &Float:y, &Float:z ){
	if( id > MAX_PROPERTIES ) return 0.0;
	x = properties[id][eEntX];
	y = properties[id][eEntY];
	z = properties[id][eEntZ];
	return properties[id][eEntA];
}

stock Float:GetPropertyExit( id, &Float:x, &Float:y, &Float:z ){
	if( id > MAX_PROPERTIES ) return 0.0;
	return GetInteriorExit( properties[id][eUniqIntId], x, y, z );
}

stock GetPropertyInteriorFileId( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return properties[id][eUniqIntId];
}

stock GetPropertyInteriorId( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return GetInteriorIntID( properties[id][eUniqIntId] );
}

stock GetPropertyType( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return properties[id][eType];
}

stock GetPropertyOwner( id ){
	if( id > MAX_PROPERTIES ) return -1;
	else return properties[id][eOwner];
}

stock GetPropertyPrice( id ){
	if( id > MAX_PROPERTIES ) return -1;
	else return properties[id][ePrice];
}

stock GetPropertyName( id ){
	new tmp[64];
	if( id > MAX_PROPERTIES ) return tmp;
	else {
  		format( tmp, 64, "%s", properties[id][ePname] );
		return tmp;
	}
}

/********************************************************
********************************************************/

/********************************
*   	Database Functions	    *
********************************/

stock Float:dbGetPropertyEntrance( database[], uniqId, &Float:x, &Float:y, &Float:z ){
	new
	    DB:prop,
	    DBResult:query_result,
	    query[128],
		num;

	prop = db_open( database );
	format( query, 128,"SELECT entX, entY, enZ, entA FROM properties WHERE id = %d LIMIT 1", uniqId );

	query_result = db_query( prop, query );
	num = db_num_rows(query_result);
	if(!num) return -1.0;

	else {
		db_get_field_assoc( query_result, "entX", query, 128 );
		x = floatstr( query );
		db_get_field_assoc( query_result, "entY", query, 128 );
		y = floatstr( query );
		db_get_field_assoc( query_result, "entZ", query, 128 );
		z = floatstr( query );
		db_get_field_assoc( query_result, "entA", query, 128 );
		return floatstr( query );
	}
}

stock dbSetPropertyOwner( database[], uniqId, ownerId ){
}

stock dbSetPropertyPrice( database[], uniqId, price ){
}

stock dbDeleteProperty( database[], uniqId ){
}

stock dbCreateProperty( database[], uniqId, Float:entX, Float:entY, Float:entZ, Float:entA ){ // remember to add rest of params
}

stock dbLoadProperties( database[] )
{
	new
		    DB:prop,
		    DBResult:query_result,
		    query[128],
			num,
			i;

	prop = db_open( database );
	format( query, 128,"SELECT * FROM properties", uniqId );

	query_result = db_query( prop, query );
	num = db_num_rows(query_result);
	if(!num) return 0;
	else {
		while( i < num ){
		    db_get_field_assoc( query_result, "entX", query, 128 );
			x = floatstr( query );
			db_get_field_assoc( query_result, "entX", query, 128 );
			x = floatstr( query );
			db_get_field_assoc( query_result, "entY", query, 128 );
			y = floatstr( query );
			db_get_field_assoc( query_result, "entZ", query, 128 );
			z = floatstr( query );
			db_get_field_assoc( query_result, "entA", query, 128 );
			i++;
		}
	}

}
/********************************************************
********************************************************/

/*********************************
*   Property System Functions    *
*********************************/

ReadInteriorInfo( const fileName[] )
{
	new
	    File:file_ptr,
	    buf[256],
	    tmp[64],
	    idx,
		uniqId;


	file_ptr = fopen( fileName, io_read );
	if( file_ptr ){
		while( fread( file_ptr, buf, 256 ) > 0){
		    idx = 0;

     		idx = token_by_delim( buf, tmp, ' ', idx );
			if(idx == (-1)) continue;
			uniqId = strval( tmp );

			if( uniqId >= MAX_INTERIORS ) return 0;

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
		 	interiorInfo[uniqId][inIntID] = strval( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitX] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitY] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1);
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitZ] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitA] = floatstr( tmp );

			idx = token_by_delim( buf, interiorInfo[uniqId][inName], ';', idx+1 );
		    if(idx == (-1)) continue;

			CreateDynamicPickup( 19133 , 1, 
					interiorInfo[uniqId][inExitX],
					interiorInfo[uniqId][inExitY],
					interiorInfo[uniqId][inExitZ] );

			/*CreateDynamic3DTextLabel("Press F to exit", 
				WHITE, interiorInfo[uniqId][inExitX],
					interiorInfo[uniqId][inExitY],
					interiorInfo[uniqId][inExitZ], 20.0);*

			
			printf( "ReadInteriorInfo(%d, %d, %f, %f, %f, %f ( %s ))",
					uniqId,
					interiorInfo[uniqId][inIntID],
					interiorInfo[uniqId][inExitX],
					interiorInfo[uniqId][inExitY],
					interiorInfo[uniqId][inExitZ],
					interiorInfo[uniqId][inExitA],
					interiorInfo[uniqId][inName] );
			*/

		}
		//printf( "Interiors File read successfully" );
		fclose( file_ptr );
		return 1;
	}
	printf( "Could Not Read Interiors file ( %s )", fileName );
	return 0;
}

ReadPropertyFile( fileName[] )
{
	new  File:file_ptr,
	    tmp[128],
		buf[256],
		idx,
		Float:enX,
		Float:enY,
		Float:enZ,
		Float:enA,
		uniqIntId,
		p_type,
		pIcon;

	printf("Reading File: %s",fileName);

	file_ptr = fopen( fileName, io_read );

	if(!file_ptr )return 0;

 	while( fread( file_ptr, buf, 256 ) > 0){
 	    idx = 0;

 	    idx = token_by_delim( buf, tmp, ',', idx );
		if(idx == (-1)) continue;
		pIcon = strval( tmp );

 	    idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enX = floatstr( tmp );

  		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enY = floatstr( tmp );

		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enZ = floatstr( tmp );

 		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enA = floatstr( tmp );

		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		uniqIntId = strval( tmp );

		idx = token_by_delim( buf, tmp, ';', idx+1 );
		if(idx == (-1)) continue;
		p_type = strval( tmp );

		CreateProperty( uniqIntId, pIcon, enX, enY, enZ, enA, p_type  );
	}
	fclose( file_ptr );
	return 1;
}

PutPlayerInProperty( playerid, propId)
{
	new Float:x, Float:y, Float:z, Float:a;
	//new intFileId;
	
    a = GetPropertyExit( propId, x, y, z );
	SetPlayerInterior( playerid, GetPropertyInteriorId( propId ));
	SetPlayerPos( playerid, x, y, z );
	SetPlayerFacingAngle( playerid, a );
	
	//intFileId = GetPropertyInteriorFileId(propId);
	SetPlayerVirtualWorld(playerid, 10 + propId);
	currentInt[playerid] = propId;
	
	GameTextForPlayer(playerid, propIcons[properties[propId][eType]][tName], 3000, 3);
}

CreateProperty( uniqIntId, iconId,  Float:entX, Float:entY, Float:entZ, Float:entA, p_type, name[64]="", owner=-1, price=0 )
{
	if( (unid+1) < MAX_PROPERTIES ){
		new Id = CreateDynamicPickup( iconId , 1, entX, entY, entZ);
		//printf( "CreateProperty(%d, %d, %f, %f, %f, %f, %d)", uniqIntId, iconId, entX, entY, entZ, entA, p_type );
		propPickups[Id] = unid;
		properties[unid][eEntX] 	= entX;
		properties[unid][eEntY] 	= entY;
		properties[unid][eEntZ] 	= entZ;
		properties[unid][eEntA] 	= entA;
		properties[unid][eUniqIntId] = uniqIntId;
		properties[unid][eOwner] 	= owner;
		properties[unid][ePrice] 	= price;
		properties[unid][eType] 	= p_type;

		format( properties[unid][ePname], 64, "%s", name );

		return unid++;
	}
	else print( "Property Limit Reached" );
	return -1;
}

LoadProperties()
{
	if( properties[0][eType] != TYPE_EMPTY ){
	    UnloadProperties();
	}
	unid = 0;
   	for( new i = 0; i < MAX_PROPERTIES; i++ ){
   	    properties[i][eType] = TYPE_EMPTY;
	}

	ReadInteriorInfo( "properties/interiors.txt" );

	for( new i = 0; i < MAX_TYPES; i++ ){
   		ReadPropertyFile( propFile[i] );
	}
	return 1;
}

UnloadProperties()
{
	new
	    p;
	for( new i = 0; i < MAX_PROPERTIES; i++ ){
		if( propPickups[i] != -1 ){
			DestroyDynamicPickup( i );
			p = propPickups[i];
			propPickups[i] = -1;
			properties[p][eInterior] = -1;
			properties[p][eType] = TYPE_EMPTY;
			properties[p][eOwner] = -1;
			properties[p][ePrice] = 0;
			properties[p][ePname][0] = '\0';
		}
	}
}

/********************************************************
********************************************************/


/************************************
*   		Callbacks			    *
************************************/


hook OnScriptExit()
{
	UnloadProperties();
	return 1;
}

hook OnGameModeInit()
{
	LoadProperties();
	return 1;
}

hook OnGameModeExit()
{
	UnloadProperties();
	return 1;
}

hook OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if( newinteriorid == 0 ){
		currentInt[playerid] = -1;
		SetPlayerVirtualWorld( playerid, 0 );
	}
	return 1;
}

hook OnPlayerSpawn( playerid )
{
	gLastPropertyEnterNotification[playerid] = -1;
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, STREAMER_TAG_PICKUP:pickupid)
{
	//printf( "DEBUG: Player %d pickedup Pickup %d Prop Id %d", playerid, pickupid );

	if( currentInt[playerid] > -1 && GetPlayerInterior(playerid) == GetPropertyInteriorId( currentInt[playerid] ))
	{
		new id = currentInt[playerid];
		new Float:x;
		new	Float:y;
		new	Float:z;
		new	Float:a;

		a = GetPropertyEntrance( id, x, y, z );

		SetPlayerInterior( playerid, 0 );
		SetPlayerPos( playerid, x, y, z );
		SetPlayerFacingAngle( playerid, a );
		
		SetPlayerVirtualWorld( playerid, 0 );
		
		//GameTextForPlayer(playerid, "_", 3000, 3);
		ChatMsg(playerid, YELLOW, " > Você entrou no interior id: %d", id);
		currentInt[playerid] = -1;
		defer ResetPickup(playerid);
		return 1;
	}

	lastPickup[playerid] = pickupid;
	
	new id = propPickups[pickupid];
	if( properties[id][eType] > 0 ){
	
	    if(gLastPropertyEnterNotification[playerid] != id){
	        gLastPropertyEnterNotification[playerid] = id;
	        PutPlayerInProperty( playerid, id );
			PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);
			
		}
	}

	return 1;
}

timer ResetPickup[3000](playerid)
	gLastPropertyEnterNotification[playerid] = -1;

hook OnPlayerSave(playerid, filename[])
{
	new data[2];
	data[0] = currentInt[playerid];
	data[1] = lastPickup[playerid];
	
	modio_push(filename, _T<P,I,N,T>, 1, data);
}

hook OnPlayerLoad(playerid, filename[])
{
	new data[2];

	modio_read(filename, _T<P,I,N,T>, 1, data);

	currentInt[playerid] = data[0];
	lastPickup[playerid] = data[1];
	gLastPropertyEnterNotification[playerid] = propPickups[lastPickup[playerid]];
}

stock GetPlayerCurrentInt(playerid)
	return currentInt[playerid];

/***********************************************************************
***********************************************************************/
