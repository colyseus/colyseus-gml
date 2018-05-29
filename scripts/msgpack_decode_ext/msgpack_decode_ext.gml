var buff = argument0
var ext_function = argument1

buffer_seek(buff, buffer_seek_start, 0);
var scratch = buffer_create(8, buffer_fixed, 1);
var retval = msgpack_decode_sys(buff, scratch, ext_function);
buffer_delete(scratch);
return retval;