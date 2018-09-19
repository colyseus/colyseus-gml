var bytes = [ 146, 15, 220, 0, 40, 84, 10, 84, 58, 204, 129, 204, 168, 109, 101, 115, 115, 97, 103, 101, 115, 204, 145, 204, 177, 54, 116, 71, 69, 71, 90, 111, 114, 103, 32, 106, 111, 105, 110, 101, 100, 46, 51, 77, 119, 69, 83, 55, 59 ];

var buff = buffer_create(1, buffer_grow, 1);

for (var i = 0; i < array_length_1d(bytes); i++;)
{
	buffer_write(buff, buffer_u8, bytes[i]);
}
buffer_seek(buff, buffer_seek_start, 0);


var decoded = msgpack_decode(buff);
show_debug_message("Decoded!");