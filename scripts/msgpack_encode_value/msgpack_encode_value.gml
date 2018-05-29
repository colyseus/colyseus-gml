var buff = argument0;
var value = argument1;
var scratch = argument2;

// TODO: ext functions?
buffer_seek(scratch, buffer_seek_start, 0);

var type = typeof(value)
switch(type) {
	case "undefined":
	case "null": // (just in case)
		buffer_write(buff, buffer_u8, 0xc0);
		return true;
	case "bool":
		if(bool(value)) buffer_write(buff, buffer_u8, 0xc3);
		else buffer_write(buff, buffer_u8, 0xc2);
		return true;
	case "int32":
	case "int64":
	case "number":
		// TODO: replace with binary checks instead
		if(value == floor(value)) {
			if(value > 0) {
				if(value < 128) { // positive fixnum
					buffer_write(buff, buffer_u8, value & 0x7f);
				}
				else if(value < 256) { // uint8
					buffer_write(buff, buffer_u8, 0xcc);
					buffer_write(buff, buffer_u8, value);
				}
				else if(value < 65536) { // uint16
					buffer_write(scratch, buffer_u16, value);
					buffer_write(buff, buffer_u8, 0xcd);
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
				}
				else if(value < 4294967296) { // uint32
					buffer_write(scratch, buffer_u32, value);
					buffer_write(buff, buffer_u8, 0xce);
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
				}
				else { // uint64
					buffer_write(scratch, buffer_u64, value);
					buffer_write(buff, buffer_u8, 0xcf);
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 7, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 6, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 5, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 4, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
				}
			}
			else {
				if(value >= -32) { // negative fixnum
					buffer_write(buff, buffer_u8, 0xe0 | (value & 0x1f));
				}
				else if(value >= -128) { // int8
					buffer_write(buff, buffer_u8, 0xd0);
					buffer_write(buff, buffer_u8, value);
				}
				else if(value >= -32768) { // int16
					buffer_write(scratch, buffer_s16, value);
					buffer_write(buff, buffer_u8, 0xd1);
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
				}
				else if(value >= -2147483648) { // int32
					buffer_write(scratch, buffer_s32, value);
					buffer_write(buff, buffer_u8, 0xd2);
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
					buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
				}
				else { //int64
					// GMS doesn't support buffer s64 type, so we have to do this the old-fashioned way
					buffer_write(buff, buffer_u8, 0xd3);
					buffer_write(buff, buffer_u8, value >> 56);
					buffer_write(buff, buffer_u8, value >> 48);
					buffer_write(buff, buffer_u8, value >> 40);
					buffer_write(buff, buffer_u8, value >> 32);
					buffer_write(buff, buffer_u8, value >> 24);
					buffer_write(buff, buffer_u8, value >> 16);
					buffer_write(buff, buffer_u8, value >> 8);
					buffer_write(buff, buffer_u8, value);
				}
			
			}
		}
		else {
			/*buffer_write(scratch, buffer_f64, value);
			buffer_write(buff, buffer_u8, 0xcb);
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 7, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 6, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 5, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 4, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));*/
			buffer_write(scratch, buffer_f32, value);
			buffer_write(buff, buffer_u8, 0xca);
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
		}
		return true;
	case "string":
		var cmd_size = string_byte_length(value);
		if(cmd_size < 32) {
			buffer_write(buff, buffer_u8, 0xa0 | (cmd_size & 0x1f));
		}
		else if(cmd_size < 256) {
			buffer_write(buff, buffer_u8, 0xd9);
			buffer_write(buff, buffer_u8, cmd_size);
		}
		else if(cmd_size < 65536) {
			buffer_write(scratch, buffer_u16, cmd_size);
			buffer_write(buff, buffer_u8, 0xda);
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
		}
		else if(cmd_size < 4294967296) {
			buffer_write(scratch, buffer_u32, cmd_size);
			buffer_write(buff, buffer_u8, 0xdb);
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 3, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 2, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 1, buffer_u8));
			buffer_write(buff, buffer_u8, buffer_peek(scratch, 0, buffer_u8));
		}
		else {
			show_debug_message("WARNING: msgpack_encode() encountered a string larger than 4294967295 bytes");
			return false;
		}
		
		var str_buff = buffer_create(cmd_size, buffer_fixed, 1);
		buffer_write(str_buff, buffer_text, value);
		buffer_copy(str_buff, 0, cmd_size, buff, buffer_tell(buff));
		buffer_seek(buff, buffer_seek_relative, cmd_size); // advance the read pointer since copy doesn't do it
		buffer_delete(str_buff);
		return true;
	
	case "array":
		// TODO?
	case "ptr":
		// TODO?
	case "vec3":
		// TODO?
	case "vec4":
		// TODO?
	case "unknown":
	default:
		show_error("Unsupported messagepack type " + string(type), true);
		return false;
}