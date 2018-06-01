var buff = argument0;
var size = buffer_get_size(buff);
buffer_seek(buff, buffer_seek_start, 0);

var scratch = buffer_create(8, buffer_fixed, 1);
buffer_seek(scratch, buffer_seek_start, 0);

var i = 0;
var batches = [];
while (buffer_tell(buff) < size) {
	batches[i] = msgpack_decode_sys(buff, scratch, undefined);
	i++;
}

buffer_delete(scratch);

return batches;