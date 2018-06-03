var buff = argument0
var scratch = argument1
var ext_function = argument2

// CONFIG
var DECODE_BIN = true;

var cmd_ext = undefined;
var cmd_size = undefined;
var cmd = buffer_read(buff, buffer_u8);

// Positive int class
if(cmd & 0x80 == 0x00) {
	return cmd;
}

// Negative small number class
if(cmd & 0xe0 == 0xe0) {
	return -((~cmd) & 0x1f) - 1; // execute two's complement conversion
}

// fixstr type
if(cmd & 0xe0 == 0xa0) {
	cmd_size = cmd & 0x1f;
	cmd = 0xdb; // shunt decoding into str32 type for string decoding
	// return msgpack_decode_array(buff, scratch, cmd & 0x0f);
}
else if(cmd & 0xf0 == 0x90) { // fixarray type
	// cmd_size = cmd & 0x0f;
	// cmd = 0xdd; // shunt decoding into array 32 type for array decoding
	return msgpack_decode_array(buff, scratch, cmd & 0x0f);
}
else if(cmd & 0xf0 == 0x80) { // fixmap type
	cmd_size = cmd & 0x0f;
	cmd = 0xdf;
}


switch(cmd) {
	// Nil family
	case 0xc0:
		return undefined;

	// Boolean family
	case 0xc2:
		return false;

	case 0xc3:
		return true;

	// Int family
	case 0xcc: // uint8
		return buffer_read(buff, buffer_u8);

	case 0xcd: // uint16, flip endianness
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_u16);
		
	case 0xce: // uint32,  flip endianness
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_u32);

	case 0xcf: // uint64, flip endianness
		buffer_poke(scratch, 7, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 6, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 5, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 4, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_u64);

	case 0xe0: // int8
		return buffer_read(buff, buffer_s8);

	case 0xd1: // int16, flip endianness
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_s16);

	case 0xd2: // int32, flip endianness
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_s32);

	case 0xd3: // int64, there's no s64 datatype, so we stack two s32s
		buffer_poke(scratch, 7, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 6, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 5, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 4, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		var low = buffer_read(scratch, buffer_u32);
		var high = buffer_read(scratch, buffer_s32);
		return (high << 32) | low;

	// Float family
	case 0xca: // 32-bit float, flip endianness
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_f32);

	case 0xcb: // 64-bit double, flip endianness
		buffer_poke(scratch, 7, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 6, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 5, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 4, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
		buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
		return buffer_read(scratch, buffer_f64);

	// String family
	case 0xd9: // string with 8-bit size
		cmd_size = buffer_read(buff, buffer_u8);
		// fallthrough
	case 0xda: // string with 16-bit size
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u16);
		}
		// fallthrough
	case 0xdb: // string with 32-bit size
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u32);
		}

		var str_buff = buffer_create(cmd_size, buffer_fixed, 1);
		buffer_copy(buff, buffer_tell(buff), cmd_size, str_buff, 0);
		buffer_seek(buff, buffer_seek_relative, cmd_size); // advance the read pointer since copy doesn't do it
		var str = buffer_read(str_buff, buffer_text);
		buffer_delete(str_buff);
		return str;

	// Array family
	case 0xdc: // array with 16-bit objects
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u16);
		}
		// fallthrough
	case 0xdd: // array with 32-bit objects
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u32);
		}

		//var ret_list = ds_list_create();
		//for(var i=0; i<cmd_size; i++) {
			// var peek_command = buffer_peek(buff, buffer_tell(buff), buffer_u8); // grab next command for marking
			var retval = msgpack_decode_sys(buff, scratch, ext_function)
			//ds_list_add(ret_list, retval);
			//if(peek_command & 0xf0 == 0x90 or peek_command == 0xdc or peek_command == 0xdd) { // command was a list
			//	ds_list_mark_as_list(ret_list, i);
			//}
			//else if(peek_command & 0xf0 == 0x80 or peek_command = 0xde or peek_command == 0xdf) { // command was a map
			//	ds_list_mark_as_map(ret_list, i);
			//}
		//}
		return retval;

	// Map family
	case 0xde: // map with 16-bit objects
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u16);
		}
		// fallthrough
	case 0xdf: // map with 32-bit objects
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u32);
		}
		var ret_map = ds_map_create();
		for(var i=0; i<cmd_size; i++) {
			var ret_key = msgpack_decode_sys(buff, scratch, ext_function);
			if(typeof(ret_key) == "number" or typeof(ret_key) == "int32" or typeof(ret_key) == "int64") {
				ret_key = string(ret_key); // numbers cast to strings
			}
			var peek_command = buffer_peek(buff, buffer_tell(buff), buffer_u8); // grab next command for marking
			var ret_val = msgpack_decode_sys(buff, scratch, ext_function);
			if(is_string(ret_key)) {
				if(peek_command & 0xf0 == 0x90 or peek_command == 0xdc or peek_command == 0xdd) { // command was a list
					ds_map_add_list(ret_map, ret_key, ret_val);
				}
				else if(peek_command & 0xf0 == 0x80 or peek_command = 0xde or peek_command == 0xdf) { // command was a map
					ds_map_add_map(ret_map, ret_key, ret_val);
				}
				else {
					ds_map_add(ret_map, ret_key, ret_val);
				}
			}
			else {
				show_debug_message("WARNING: msgpack_decode() encountered a non-string map key");
			}
		}
		return ret_map;

	// Bin family
	case 0xc4: // binary with 8-bit size
		cmd_size = buffer_read(buff, buffer_u8);
		// fallthrough
	case 0xc5: // binary with 16-bit size
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u16);
		}
		// fallthrough
	case 0xc6: // binary with 32-bit size
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u32);
		}
		if(DECODE_BIN) {
			var ret_buff = buffer_create(cmd_size, buffer_fixed, 1);
			buffer_copy(buff, buffer_tell(buff), cmd_size, ret_buff, 0);
			buffer_seek(buff, buffer_seek_relative, cmd_size); // advance the read pointer since copy doesn't do it
			return ret_buff;
		}
		show_debug_message("WARNING: msgpack_decode() encountered a binary type, but DECODE_BIN is turned off");
		return undefined;

	case 0xd4:
		cmd_size = 1;
	case 0xd5:
		if(is_undefined(cmd_size)) {
			cmd_size = 2;
		}
	case 0xd6:
		if(is_undefined(cmd_size)) {
			cmd_size = 4;
		}
	case 0xd7:
		if(is_undefined(cmd_size)) {
			cmd_size = 8;
		}
	case 0xd8:
		if(is_undefined(cmd_size)) {
			cmd_size = 16;
		}
	case 0xc7:
		if(is_undefined(cmd_size)) {
			cmd_size = buffer_read(buff, buffer_u8);
		}
	case 0xc8:
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u16);
		}
	case 0xc9:
		if(is_undefined(cmd_size)) {
			buffer_poke(scratch, 3, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 2, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 1, buffer_u8, buffer_read(buff, buffer_u8));
			buffer_poke(scratch, 0, buffer_u8, buffer_read(buff, buffer_u8));
			cmd_size = buffer_read(scratch, buffer_u32);
		}
		cmd_ext = buffer_read(buff, buffer_u8);
		if(not is_undefined(ext_function)) {
			var ext_buff = buffer_create(cmd_size, buffer_fixed, 1);
			buffer_copy(buff, buffer_tell(buff), cmd_size, ext_buff, 0);
			buffer_seek(buff, buffer_seek_relative, cmd_size); // advance the read pointer since copy doesn't do it
			var retval = script_execute(ext_function, cmd_ext, cmd_size, ext_buff);
			buffer_delete(ext_buff)
			return retval;
		}

		show_debug_message("WARNING: msgpack_decode() encountered an ext type, but no decode function is defined for it");
		return undefined;

	default:
		show_debug_message("WARNING: msgpack_decode() encountered unrecognized command: " + string(cmd));
}

return undefined;
