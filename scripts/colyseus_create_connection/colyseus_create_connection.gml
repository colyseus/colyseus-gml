var endpoint = argument0;
var port = argument1;

show_debug_message("colyseus_create_connection: " + global.colyseus_endpoint + ":" + string(global.colyseus_port));

var socket = network_create_socket(network_socket_tcp);
network_set_config(network_config_use_non_blocking_socket, 1);
network_connect_raw(socket, endpoint, port);

return socket;