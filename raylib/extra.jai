// Additional functionality
copy_string_to_array :: (dst: *[..]u8, src: string) {
    for src array_add(dst, it);
}

array_len :: (s: *$T) -> s64 {
    if !s return 0;

    count: s64 = 0;
    while s.* {
        count += 1;
        s     += 1;
    }
    return count;
}

array_len :: (s: *$T, maxlen: s64) -> s64 {
    if !s return 0;

    count: s64 = 0;
    while count < maxlen && s.* {
        count += 1;
        s     += 1;
    }
    return count;
}

strstr :: (haystack: *u8, needle: *u8) -> *u8 {
    if needle == null   return haystack;
    if haystack == null return null;

    h := haystack;
    while h[0] != 0 {
        h_curr := h;
        n_curr := needle;

        while h_curr[0] != 0 && n_curr[0] != 0 && h_curr[0] == n_curr[0] {
            h_curr += 1;
            n_curr += 1;
        }

        if n_curr[0] == 0 {
            return h;
        }

        h += 1;
    }

    return null;
}

strncat :: (dest: *u8, src: *u8, n: s64) -> *u8 {
    if !dest return dest;
    if !src  return dest;

    // 1. Find the null terminator of the destination string
    dest_idx: s64 = 0;
    while dest[dest_idx] != 0 {
        dest_idx += 1;
    }

    // 2. Append up to 'n' characters from the source string
    src_idx: s64 = 0;
    while src_idx < n && src[src_idx] != 0 {
        dest[dest_idx] = src[src_idx];
        dest_idx += 1;
        src_idx  += 1;
    }

    // 3. Always explicitly null-terminate the result
    dest[dest_idx] = 0;

    return dest;
}

strncpy :: (dest: *u8, src: *u8, n: s64) -> *u8 {
    if !dest return dest;
    if !src  return dest;

    i: s64 = 0;

    // 1. Copy characters from src to dest until a null terminator or 'n' limit is reached
    while i < n && src[i] != 0 {
        dest[i] = src[i];
        i += 1;
    }

    // 2. Pad the remaining space with null bytes if src was shorter than 'n'
    while i < n {
        dest[i] = 0;
        i += 1;
    }

    return dest;
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
