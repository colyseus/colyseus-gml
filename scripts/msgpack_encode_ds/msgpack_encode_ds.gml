var buff = argument0;
var datastructure = argument1;
var ds_type = argument2;
var scratch = argument3;

buffer_seek(scratch, buffer_seek_start, 0);

// get string representation of datastructure (the only way currently in GML to get datatype of nested datastructures
switch(ds_type) {
	case MSGPACK_DS.map:
		var ds_str = ds_map_write(datastructure);
		break;
	case MSGPACK_DS.list:
		var ds_str = ds_list_write(datastructure);
		break;
	default:
		show_debug_message("ERROR: msgpack_encode() invalid type: " + string(ds_type));
		return false;
}

var str_ptr = 1; // fucking GML strings starting at 1, smh
var str_size = string_byte_length(ds_str);


// header check
var chunk = string_copy(ds_str, str_ptr, 8);
str_ptr += 8;
if(ds_type == MSGPACK_DS.map and chunk != "92010000") {
	show_debug_message("WARNING: msgpack_encode() did not find a valid map");
	return false;
}
else if(ds_type == MSGPACK_DS.list and chunk != "2E010000") {
	show_debug_message("WARNING: msgpack_encode() did not find a valid list");
	return false;
}


// length check
chunk = string_copy(ds_str, str_ptr, 8);
str_ptr += 8;
var ds_items = msgpack_hex32_to_int(chunk);

if(ds_items < 16) { // fixmap
	if(ds_type == MSGPACK_DS.map) buffer_write(buff, buffer_u8, 0x80 | (ds_items & 0x0f));
	else if(ds_type == MSGPACK_DS.list) buffer_write(buff, buffer_u8, 0x90 | (ds_items & 0x0f));
}
else if(ds_items < 65536) { // map 16
	if(ds_type == MSGPACK_DS.map) buffer_write(buff, buffer_u8, 0xde);
	else if(ds_type == MSGPACK_DS.list) buffer_write(buff, buffer_u8, 0xdc);
	
	buffer_write(scratch, buffer_u16, ds_items);
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
}
else if(ds_items < 4294967296) { // map 32
	if(ds_type == MSGPACK_DS.map) buffer_write(buff, buffer_u8, 0xdf);
	else if(ds_type == MSGPACK_DS.list) buffer_write(buff, buffer_u8, 0xdd);
	
	buffer_write(scratch, buffer_u32, ds_items);
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
	buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
}
else {
	show_debug_message("WARNING: msgpack_encode() cannot encode this size of map: " + string(ds_items));
	return false;
}

for(var i=0; i<ds_items; i++) {
	if(ds_type == MSGPACK_DS.map) {
		// key type
		chunk = string_copy(ds_str, str_ptr, 8);
		str_ptr += 8;
		var key_type = msgpack_hex32_to_int(chunk);
		if(key_type != 1) {
			show_debug_message("WARNING: key_type not understood: " + string(key_type));
			return false;
		}
	
		// key length
		chunk = string_copy(ds_str, str_ptr, 8);
		str_ptr += 8;
		var key_length = msgpack_hex32_to_int(chunk);
	
		// key
		chunk = string_copy(ds_str, str_ptr, 2*key_length);
		str_ptr += 2*key_length;
		var key = msgpack_hex_to_str(chunk);
	
		msgpack_encode_value(buff, key, scratch);
		
		// actual value
		var value_actual = ds_map_find_value(datastructure, key);
	}
	else {
		var value_actual = ds_list_find_value(datastructure, i);	
	}
	
	// value type
	var type_str = string_copy(ds_str, str_ptr, 8);
	str_ptr += 8;
	
	switch(type_str) {
		case "0A000000": // int64
		case "00000000": // real
			str_ptr += 16;
			msgpack_encode_value(buff, value_actual, scratch);
			break;
		case "01000000": // string
			chunk = string_copy(ds_str, str_ptr, 8);
			str_ptr += 8;
			var value_length = msgpack_hex32_to_int(chunk);
			str_ptr += 2*value_length;
			msgpack_encode_value(buff, value_actual, scratch);
			break;
		case "02000000": // array - not supported!
			show_debug_message("WARNING: msgpack_encode() does not support embedded arrays, use ds_lists instead");
			return false;
			// TODO
			
			/*chunk = string_copy(ds_str, str_ptr, 8);
			str_ptr += 8;
			var sub_arrays = msgpack_hex32_to_int(chunk);
			
			for(var j=0; j<sub_arrays; j++) {
				chunk = string_copy(ds_str, str_ptr, 8);
				str_ptr += 8;
				var sub_array_len = msgpack_hex32_to_int(chunk);
				
				for(var k=0; k<sub_array_len; k++) {
					// go deeper
				}
			}*/
			break;
		case "00000040": // list
			msgpack_encode_ds(buff, value_actual, MSGPACK_DS.list, scratch);
			break;
		case "00000080": // map
			msgpack_encode_ds(buff, value_actual, MSGPACK_DS.map, scratch);
			break;
		case "05000000": // undef
			msgpack_encode_value(buff, value_actual, scratch);
			break;
		case "07000000": // int32
			msgpack_encode_value(buff, value_actual, scratch);
			str_ptr += 8;
			break;
		default:
			show_debug_message("WARNING: value_type not understood: " + string(type_str));
			return false;
		
	}
}

return true;