/// @function colyseus_connect(endpoint: string, port: int)
/// @param endpoint:string
/// @param port:int

//
// connection
//
global.colyseus_endpoint = argument0;
global.colyseus_port = argument1;

global.colyseus_id = "";
global.colyseus_request_id = 0;

global.colyseus_rooms = ds_map_create();
global.colyseus_connecting_rooms = ds_map_create();

//
// Protocol
//
enum COLYSEUS_PROTOCOL {
	// User-related (0~10)
	USER_ID = 1,

	// Room-related (10~20)
	JOIN_ROOM = 10,
	JOIN_ERROR = 11,
	LEAVE_ROOM = 12,
	ROOM_DATA = 13,
	ROOM_STATE = 14,
	ROOM_STATE_PATCH = 15,

	// Match-making related (20~29)
	ROOM_LIST = 20,

	// Generic messages (50~60)
	BAD_REQUEST = 50,	
}

global.colyseus_client = colyseus_create_connection(global.colyseus_endpoint, global.colyseus_port);
