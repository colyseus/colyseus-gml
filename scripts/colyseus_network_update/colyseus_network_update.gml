var socket_id = async_load[?"id"];

switch (async_load[?"type"]) {
	case network_type_non_blocking_connect:
		show_debug_message("NON BLOCKING CONNECTED into the TCP server.");
		show_debug_message("SOCKET_ID: " + string(socket_id));

		if (socket_id == 0)
		{
			colyseus_join_room("chat");
			
		} else if (ds_map_exists(global.colyseus_rooms, socket_id)) {
			show_debug_message("LETS EFFECTIVELY JOIN ON socket_id " + string(socket_id));

			// confirm JOIN_ROOM on the connection.
			var join_packet = ds_map_find_value(global.colyseus_connecting_rooms, socket_id);
			ds_list_add(join_packet, 1);

			var buffer = buffer_create(1, buffer_grow, 1);
			msgpack_encode(buffer, join_packet);
			network_send_raw(socket_id, buffer, buffer_tell(buffer));
		}
		
		break;
	case network_type_connect:
		show_debug_message("CONNECTED into the TCP server.");
		break;
	case network_type_disconnect:
		show_debug_message("DISCONNECTED from the TCP server.");
		break;
	case network_type_data:
		show_debug_message("RECEIVED network_type_data: (size: " + string(async_load[?"size"]) + ")");

		var buff = async_load[?"buffer"];
		var data = msgpack_decode(buff);

		if (!colyseus_process_message(data))
		{
		}
		break;
}