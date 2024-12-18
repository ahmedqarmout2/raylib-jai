#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - write depth buffer");

    // The shader inverts the depth buffer by writing into it by `gl_FragDepth = 1 - gl_FragCoord.z;`
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/write_depth.fs", GLSL_VERSION));

    // Use Customized function to create writable depth texture buffer
    target: RenderTexture2D = LoadRenderTextureDepthTex(screenWidth, screenHeight);

    // Define the camera to look into our 3d world
    camera: Camera = .{
        position   = Vector3.{2.0, 2.0, 3.0},    // Camera position
        target     = Vector3.{0.0, 0.5, 0.0},    // Camera looking at point
        up         = Vector3.{0.0, 1.0, 0.0},    // Camera up vector (rotation towards target)
        fovy       = 45.0,                       // Camera field-of-view Y
        projection = .CAMERA_PERSPECTIVE         // Camera projection type
    };
    
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);
        //----------------------------------------------------------------------------------
        
        // Draw
        //----------------------------------------------------------------------------------
        
        // Draw into our custom render texture (framebuffer)
        BeginTextureMode(target);
            ClearBackground(WHITE);
            
            BeginMode3D(camera);
                BeginShaderMode(shader);
                    DrawCubeWiresV(Vector3.{0.0, 0.5, 1.0}, Vector3.{1.0, 1.0, 1.0}, RED);
                    DrawCubeV(Vector3.{0.0, 0.5, 1.0}, Vector3.{1.0, 1.0, 1.0}, PURPLE);
                    DrawCubeWiresV(Vector3.{0.0, 0.5, -1.0}, Vector3.{1.0, 1.0, 1.0}, DARKGREEN);
                    DrawCubeV(Vector3.{ 0.0, 0.5, -1.0}, Vector3.{1.0, 1.0, 1.0}, YELLOW);
                    DrawGrid(10, 1.0);
                EndShaderMode();
            EndMode3D();
        EndTextureMode();

        // Draw into screen our custom render texture 
        BeginDrawing();
            ClearBackground(RAYWHITE);
        
            DrawTextureRec(target.texture, Rectangle.{0, 0, cast(float)screenWidth, cast(float)-screenHeight}, Vector2.{0, 0}, WHITE);
            DrawFPS(10, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTextureDepthTex(target);
    UnloadShader(shader);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
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
        target.texture.id = rlLoadTexture(null, width, height, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
        target.texture.width = width;
        target.texture.height = height;
        target.texture.format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
        target.texture.mipmaps = 1;

        // Create depth texture buffer (instead of raylib default renderbuffer)
        target.depth.id = rlLoadTextureDepth(width, height, false);
        target.depth.width = width;
        target.depth.height = height;
        target.depth.format = 19;       //DEPTH_COMPONENT_24BIT?
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