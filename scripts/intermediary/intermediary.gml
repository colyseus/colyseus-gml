switch (async_load[?"type"]) {
	case network_type_non_blocking_connect:
		show_debug_message("NON BLOCKING CONNECTED into the TCP server.");
		colyseus_join_room("chat");
		
		break;
	case network_type_connect:
		show_debug_message("CONNECTED into the TCP server.");
		break;
	case network_type_disconnect:
		show_debug_message("DISCONNECTED from the TCP server.");
		break;
	case network_type_data:
		var buff = async_load[?"buffer"];
		// var size = async_load[?"size"];
		var data = msgpack_decode(buff);

		if (!colyseus_process_message(data))
		{
		}
		break;
}