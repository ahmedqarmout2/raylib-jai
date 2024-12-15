#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

RayLocs :: struct {
    camPos       : s32;
    camDir       : s32;
    screenCenter : s32;
};

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - write depth buffer");
    defer CloseWindow(); // Close window and OpenGL context

    // This Shader calculates pixel depth and color using raymarch
    shdrRaymarch: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/hybrid_raymarch.fs", GLSL_VERSION));

    // This Shader is a standard rasterization fragment shader with the addition of depth writing
    // You are required to write depth for all shaders if one shader does it
    shdrRaster: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/hybrid_raster.fs", GLSL_VERSION));

    // Declare Struct used to store camera locs.
    marchLocs: RayLocs;

    // Fill the struct with shader locs.
    marchLocs.camPos       = GetShaderLocation(shdrRaymarch, "camPos");
    marchLocs.camDir       = GetShaderLocation(shdrRaymarch, "camDir");
    marchLocs.screenCenter = GetShaderLocation(shdrRaymarch, "screenCenter");

    // Transfer screenCenter position to shader. Which is used to calculate ray direction. 
    screenCenter: Vector2 = .{x = screenWidth/2.0, y = screenHeight/2.0};
    SetShaderValue(shdrRaymarch, marchLocs.screenCenter, *screenCenter, .SHADER_UNIFORM_VEC2);

    // Use Customized function to create writable depth texture buffer
    target: RenderTexture2D = LoadRenderTextureDepthTex(screenWidth, screenHeight);

    // Define the camera to look into our 3d world
    camera: Camera = .{
        position   = Vector3.{0.5, 1.0, 1.5},    // Camera position
        target     = Vector3.{0.0, 0.5, 0.0},    // Camera looking at point
        up         = Vector3.{0.0, 1.0, 0.0},    // Camera up vector (rotation towards target)
        fovy       = 45.0,                       // Camera field-of-view Y
        projection = .CAMERA_PERSPECTIVE         // Camera projection type
    };
    
    // Camera FOV is pre-calculated in the camera Distance.
    camDist: float = 1.0/(tan(camera.fovy*0.5*DEG2RAD));
    
    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update Camera Postion in the ray march shader.
        SetShaderValue(shdrRaymarch, marchLocs.camPos, *(camera.position), .SHADER_UNIFORM_VEC3);
        
        // Update Camera Looking Vector. Vector length determines FOV.
        camDir: Vector3 = Vector3Scale(Vector3Normalize(Vector3Subtract(camera.target, camera.position)) , camDist);
        SetShaderValue(shdrRaymarch, marchLocs.camDir, *(camDir), .SHADER_UNIFORM_VEC3);
        //----------------------------------------------------------------------------------
        
        // Draw
        //----------------------------------------------------------------------------------
        {
            // Draw into our custom render texture (framebuffer)
            BeginTextureMode(target);
            defer EndTextureMode();

            ClearBackground(WHITE);

            // Raymarch Scene
            rlEnableDepthTest(); //Manually enable Depth Test to handle multiple rendering methods.

            {
            BeginShaderMode(shdrRaymarch);
            defer EndShaderMode();

            DrawRectangleRec(Rectangle.{0, 0, cast(float)screenWidth, cast(float)screenHeight}, WHITE);
            }

            // Rasterize Scene
            BeginMode3D(camera);
            defer EndMode3D();

            BeginShaderMode(shdrRaster);
            defer EndShaderMode();

            DrawCubeWiresV(Vector3.{0.0, 0.5, 1.0}, Vector3.{1.0, 1.0, 1.0}, RED);
            DrawCubeV(Vector3.{0.0, 0.5, 1.0}, Vector3.{1.0, 1.0, 1.0}, PURPLE);
            DrawCubeWiresV(Vector3.{0.0, 0.5, -1.0}, Vector3.{1.0, 1.0, 1.0}, DARKGREEN);
            DrawCubeV(Vector3.{0.0, 0.5, -1.0}, Vector3.{1.0, 1.0, 1.0}, YELLOW);
            DrawGrid(10, 1.0);
        }

        // Draw into screen our custom render texture 
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTextureRec(target.texture, Rectangle.{0, 0, cast(float)screenWidth, cast(float)-screenHeight}, Vector2.{0, 0}, WHITE);
        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}

//------------------------------------------------------------------------------------
// Define custom functions required for the example
//------------------------------------------------------------------------------------
// Load custom render texture, create a writable depth texture buffer
LoadRenderTextureDepthTex :: (width: s32, height: s32) -> RenderTexture2D {
    target: RenderTexture2D;

    target.id = rlLoadFramebuffer(); // Load an empty framebuffer

    if (target.id > 0) {
        rlEnableFramebuffer(target.id);

        // Create color texture (default to RGBA)
        target.texture.id     = rlLoadTexture(null, width, height, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
        target.texture.width   = width;
        target.texture.height  = height;
        target.texture.format  = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
        target.texture.mipmaps = 1;

        // Create depth texture buffer (instead of raylib default renderbuffer)
        target.depth.id      = rlLoadTextureDepth(width, height, false);
        target.depth.width   = width;
        target.depth.height  = height;
        target.depth.format  = 19;       //DEPTH_COMPONENT_24BIT?
        target.depth.mipmaps = 1;

        // Attach color texture and depth texture to FBO
        rlFramebufferAttach(target.id, target.texture.id, .RL_ATTACHMENT_COLOR_CHANNEL0, .RL_ATTACHMENT_TEXTURE2D, 0);
        rlFramebufferAttach(target.id, target.depth.id, .RL_ATTACHMENT_DEPTH, .RL_ATTACHMENT_TEXTURE2D, 0);

        // Check if fbo is complete with attachments (valid)
        if (rlFramebufferComplete(target.id)) TraceLog(.LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", target.id);

        rlDisableFramebuffer();
    }
    else TraceLog(.LOG_WARNING, "FBO: Framebuffer object can not be created");

    return target;
}

// Unload render texture from GPU memory (VRAM)
UnloadRenderTextureDepthTex :: (target: RenderTexture2D) {
    if (target.id > 0) {
        // Color texture attached to FBO is deleted
        rlUnloadTexture(target.texture.id);
        rlUnloadTexture(target.depth.id);

        // NOTE: Depth texture is automatically
        // queried and deleted before deleting framebuffer
        rlUnloadFramebuffer(target.id);
    }
}
