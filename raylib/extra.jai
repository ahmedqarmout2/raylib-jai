// Additional functionality
copy_string_to_array :: (dst: *[..]u8, src: string) {
    for src array_add(dst, it);
}

strlen :: (s: *u8) -> s64 {
    count: s64 = 0;
    while s.* {
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
