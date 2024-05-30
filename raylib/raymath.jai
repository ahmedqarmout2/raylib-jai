float3 :: struct {
    v: float;
}

float16 :: struct {
    v: float;
}



float16 :: struct { v: [16]float; }

// TODO: parse rlgl.h and generate rlgl.jai separately
MatrixToFloatV  :: (mat: Matrix4) -> float16 #foreign raylib_native;
MatrixToFloat   :: (mat: Matrix4) -> *float { return MatrixToFloatV(mat).v.data; };
MatrixTranslate :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;
MatrixRotate    :: (axis: Vector3, angle_radians: float) -> Matrix4 #foreign raylib_native;
MatrixScale     :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;
MatrixMultiply  :: (a: Matrix4, b: Matrix4) -> Matrix4 #foreign raylib_native;

DrawText :: inline ($$text: string, posX: s32, posY: s32, fontSize: s32, color: Color) {
    DrawText(constant_or_temp_cstring(text), posX, posY, fontSize, color);
}

make_Rectangle :: (x: $A, y: $B, width: $C, height: $D) -> Rectangle {
    r: Rectangle;
    r.x      = cast(float)x;
    r.y      = cast(float)y;
    r.width  = cast(float)width;
    r.height = cast(float)height;
    return r;
}

make_Color :: (r: $A, g: $B, b: $C, a: $D) -> Color {
    color: Color;
    color.r = cast(u8)r;
    color.g = cast(u8)g;
    color.b = cast(u8)b;
    color.a = cast(u8)a;
    return color;
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