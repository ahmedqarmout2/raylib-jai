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
        s     += 1;
    }
    return count;
}

// Macros for Begin/End pairs where the EndXXX Function is called automatically
// at the end of the scope.
PushDrawing :: () #expand {
    BeginDrawing();
    `defer EndDrawing();
}

PushMode2D :: (camera: Camera2D) #expand {
    BeginMode2D(camera);
    `defer EndMode2D();
}

PushMode3D :: (camera: Camera3D) #expand {
    BeginMode3D(camera);
    `defer EndMode3D();
}

PushTextureMode :: (target: RenderTexture2D) #expand {
    BeginTextureMode(target);
    `defer EndTextureMode();
}

PushScissorMode :: (x: s32, y: s32, width: s32, height: s32) #expand {
    BeginScissorMode(x, y, width, height);
    `defer EndScissorMode();
}

PushShaderMode :: (shader: Shader) #expand {
    BeginShaderMode(shader);
    `defer EndShaderMode();
}

PushBlendMode :: (mode: s32) #expand {
    BeginBlendMode(mode);
    `defer EndBlendMode();
}
