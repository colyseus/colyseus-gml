var message = argument0;
var processed = false;

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