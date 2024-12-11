// Additional functionality
get_c_string :: (text: string) -> *u8 #expand {
    c_str: *u8;
    #if is_constant(text) {
        c_str = text.data;
    } else {
        c_str = _to_temp_c_string(text);
    }
    return c_str;
}

_to_temp_c_string :: (s: string) -> *u8 {
    result : *u8 = talloc(s.count + 1);
    memcpy(result, s.data, s.count);
    result[s.count] = 0;
    return result;
}

copy_string_to_array :: (dst: *u8, src: string) {
    for src dst[it_index] = it;
}

copy_string_to_array :: (dst: *[..]u8, src: string) {
    for src array_add(dst, it);
}

strlen :: (s: *u8) -> s64 {
    count: s64 = 0;
    while <<s {
        count += 1;
        s += 1;
    }
    return count;
}