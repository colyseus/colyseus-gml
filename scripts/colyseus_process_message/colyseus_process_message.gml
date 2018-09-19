var message = argument0;
var processed = false;

if (ds_exists(message, ds_type_list))
{
	var length = ds_list_size(message);
	var code = ds_list_find_value(message, 0);

	show_debug_message("code: " + string(code));

	switch (code) {
		case COLYSEUS_PROTOCOL.USER_ID:
			global.colyseus_id = ds_list_find_value(message, 1);
			processed = true;
			break;

		case COLYSEUS_PROTOCOL.JOIN_ROOM:
			var room_id = ds_list_find_value(message, 1);
			var request_id = ds_list_find_value(message, 2);

			if (request_id != undefined)
			{
				var socket_id = colyseus_create_connection(global.colyseus_endpoint, global.colyseus_port);

				// transfer options on "request_id" to "socket_id"
				var join_options = global.colyseus_connecting_rooms[?request_id];
				ds_map_add(global.colyseus_connecting_rooms, socket_id, join_options);
				ds_map_delete(global.colyseus_connecting_rooms, request_id);

				global.colyseus_room = socket_id;
				ds_map_add(global.colyseus_rooms, socket_id, room_id);

			} else
			{
				global.colyseus_session_id = room_id;
				show_debug_message("JOIN_ROOM CONFIRMED");
			}

			processed = true;
			break;

		case COLYSEUS_PROTOCOL.JOIN_ERROR:
			show_debug_message("JOIN_ERROR!");
			processed = true;
			break;

		case COLYSEUS_PROTOCOL.LEAVE_ROOM:
			show_debug_message("LEAVE_ROOM!");
			processed = true;
			break;

		case COLYSEUS_PROTOCOL.ROOM_DATA:
			show_debug_message("ROOM_DATA!");
			processed = true;
			break;

		case COLYSEUS_PROTOCOL.ROOM_STATE:
			var socket_id = async_load[?"id"];

			var encoded_state = ds_list_find_value(message, 1);
			ds_map_add(global.colyseus_rooms_encoded_state, socket_id, encoded_state);

			var state = msgpack_decode(encoded_state);
			ds_map_add_map(global.colyseus_rooms_state, socket_id, state);

			processed = true;
			break;

		case COLYSEUS_PROTOCOL.ROOM_STATE_PATCH:
			show_debug_message("ROOM_STATE_PATCH!");
			processed = true;
			break;

		case COLYSEUS_PROTOCOL.ROOM_LIST:
			show_debug_message("ROOM_LIST!");
			processed = true;
			break;
	}

}

return processed;