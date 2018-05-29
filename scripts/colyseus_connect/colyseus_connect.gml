global.colyseus_endpoint = argument0;
global.colyseus_port = argument1;

show_debug_message("colyseus_connect: " + global.colyseus_endpoint + ":" + string(global.colyseus_port));

global.colyseus_rooms = ds_map_create();
global.colyseus_client = network_create_socket(network_socket_tcp);
network_set_config(network_config_use_non_blocking_socket, 1);

network_connect_raw(global.colyseus_client, global.colyseus_endpoint, global.colyseus_port);