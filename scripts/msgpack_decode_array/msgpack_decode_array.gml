var buff = argument0;
var scratch = argument1;
var length = argument2;

var list = ds_list_create();

for (var i = 0; i < length; i++) {
	ds_list_add(list, msgpack_decode_sys(buff, scratch, undefined));
}

return list;
