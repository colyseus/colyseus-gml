var buff = argument0
var value = argument1

enum MSGPACK_DS {
	map,
	list
}

var type = ds_exists(value, ds_type_list) ? MSGPACK_DS.list : MSGPACK_DS.map;

buffer_seek(buff, buffer_seek_start, 0);
var scratch = buffer_create(8, buffer_fixed, 1);
var retval = msgpack_encode_ds(buff, value, type, scratch);
buffer_delete(scratch);
return retval;