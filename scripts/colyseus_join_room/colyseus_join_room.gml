var join_room_name = argument[0];
var options = json_decode( (argument_count > 1) ? argument[1] : "{}" );

// ds_map_add(global.colyseus_rooms, room_name, );

var endpoint = argument0;
var port = argument1;

show_debug_message("colyseus_connect" + endpoint + ":" + string(port));

global.colyseus_client = network_create_socket(network_socket_tcp);
network_set_config(network_config_use_non_blocking_socket, 1);

network_connect_raw(global.colyseus_client, endpoint, port);