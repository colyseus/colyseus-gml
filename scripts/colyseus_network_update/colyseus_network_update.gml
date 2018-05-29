switch (async_load[?"type"]) {
	case network_type_non_blocking_connect:
		show_debug_message("NON BLOCKING CONNECTED into the TCP server.");
		break;
	case network_type_connect:
		show_debug_message("CONNECTED into the TCP server.");
		break;
	case network_type_disconnect:
		show_debug_message("DISCONNECTED from the TCP server.");
		break;
	case network_type_data:
		show_debug_message("!! network_type_data !!");
		var data = msgpack_decode(async_load[?"buffer"]);
		show_debug_message(json_encode(data));
		break;
}