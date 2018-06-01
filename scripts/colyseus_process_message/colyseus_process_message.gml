var message = argument0;
var processed = false;

show_debug_message("ID? " + string(async_load[?"id"]));

if (ds_exists(message, ds_type_list))
{
	show_debug_message("TYPE: DS_LIST");

	var length = ds_list_size(message);
	var code = ds_list_find_value(message, 0);
	
	switch (code) {
		case COLYSEUS_PROTOCOL.USER_ID:
			global.colyseus_id = ds_list_find_value(message, 1);
			show_debug_message("COLYSEUS_ID: " + global.colyseus_id);
			break;

		case COLYSEUS_PROTOCOL.JOIN_ROOM:
			show_debug_message("JOIN ROOM!");

			var room_id = ds_list_find_value(message, 1);
			var request_id = ds_list_find_value(message, 2);

			var socket_id = colyseus_create_connection(global.colyseus_endpoint, global.colyseus_port);
			show_debug_message("LETS CREATE CONNECTION with room, socket_id " + string(socket_id));
			
			// transfer options on "request_id" to "socket_id"
			
			var join_options = global.colyseus_connecting_rooms[?request_id];
			ds_map_add(global.colyseus_connecting_rooms, socket_id, join_options);
			ds_map_delete(global.colyseus_connecting_rooms, request_id);

			global.colyseus_room = socket_id;
			ds_map_add(global.colyseus_rooms, socket_id, room_id);

			break;
			
		case COLYSEUS_PROTOCOL.JOIN_ERROR:
			break;
		
		case COLYSEUS_PROTOCOL.LEAVE_ROOM:
			break;

		case COLYSEUS_PROTOCOL.ROOM_DATA:
			break;
			
		case COLYSEUS_PROTOCOL.ROOM_STATE:
			break;
			
		case COLYSEUS_PROTOCOL.ROOM_STATE_PATCH:
			break;
			
		case COLYSEUS_PROTOCOL.ROOM_LIST:
			break;
	}
			
}

return processed;