var buff = argument0;
buffer_seek(buff, buffer_seek_start, 0);

var scratch = buffer_create(8, buffer_fixed, 1);
buffer_seek(scratch, buffer_seek_start, 0);

var retval = msgpack_decode_sys(buff, scratch, undefined);
buffer_delete(scratch);

return retval;