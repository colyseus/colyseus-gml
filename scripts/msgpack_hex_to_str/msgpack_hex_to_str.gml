var hexstr = argument0;

var retval = "";
for(var i=0; i<string_length(hexstr); i+=2) {
	var nibble_low = string_byte_at(hexstr, i+2) - 0x30;
	if(nibble_low > 16) { // it's in the alpha range
		nibble_low -= 7 // bring it back down
	}
	/*else if(nibble_low > 9) { // it's after numeric range and before alpha range (i.e. invalid)
		nibble_low = -1; // set fail condition
	}
	if(nibble_low & ~0xf != 0) { // value not 0 through 15
		show_debug_message("ERROR: msgpack_hex32_to_int() encountered an invalid character in: " + string(hexstr));
		return undefined;	
	}*/
	 // this part is unrolled for performance
	var nibble_high = string_byte_at(hexstr, i+1) - 0x30;
	if(nibble_high > 16) { // it's in the alpha range
		nibble_high -= 7 // bring it back down
	}
	/*else if(nibble_high > 9) { // it's after numeric range and before alpha range (i.e. invalid)
		nibble_high = -1; // set fail condition
	}
	if(nibble_high & ~0xf != 0) { // value not 0 through 15
		show_debug_message("ERROR: msgpack_hex32_to_int() encountered an invalid character in: " + string(hexstr));
		return undefined;	
	}*/
	
	retval += chr(nibble_low | nibble_high << 4);
}

return retval;