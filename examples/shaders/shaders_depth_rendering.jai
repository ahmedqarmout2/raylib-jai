#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - depth rendering");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 4.0, 1.0, 5.0 };
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Load render texture with a depth texture attached
    target: RenderTexture2D = LoadRenderTextureDepthTex(screenWidth, screenHeight);

    // Load depth shader and get depth texture shader location
    depthShader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/depth_render.fs", GLSL_VERSION));
    depthLoc: s32 = GetShaderLocation(depthShader, "depthTexture");
    flipTextureLoc: s32 = GetShaderLocation(depthShader, "flipY");
    SetShaderValue(depthShader, flipTextureLoc, *(s32.[1]), .SHADER_UNIFORM_INT); // Flip Y texture

    // Load scene models
    cube: Model = LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
    floor: Model = LoadModelFromMesh(GenMeshPlane(20.0, 20.0, 1, 1));

    DisableCursor();  // Limit cursor to relative movement inside the window

    SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
            ClearBackground(WHITE);

            BeginMode3D(camera);
                DrawModel(cube, Vector3.{ 0.0, 0.0, 0.0 }, 3.0, YELLOW);
                DrawModel(floor, Vector3.{ 10.0, 0.0, 2.0 }, 2.0, RED);
            EndMode3D();
        EndTextureMode();

        // Draw into screen (main framebuffer)
        BeginDrawing();
            ClearBackground(RAYWHITE);

            BeginShaderMode(depthShader);
                SetShaderValueTexture(depthShader, depthLoc, target.depth);
                DrawTexture(target.depth, 0, 0, WHITE);
            EndShaderMode();

            DrawRectangle( 10, 10, 320, 93, Fade(SKYBLUE, 0.5));
            DrawRectangleLines( 10, 10, 320, 93, BLUE);

            DrawText("Camera Controls:", 20, 20, 10, BLACK);
            DrawText("- WASD to move", 40, 40, 10, DARKGRAY);
            DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, DARKGRAY);
            DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(cube);              // Unload model
    UnloadModel(floor);             // Unload model
    UnloadRenderTextureDepthTex(target);
    UnloadShader(depthShader);      // Unload shader

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//--------------------------------------------------------------------------------------
// Module Functions Definition
//--------------------------------------------------------------------------------------
// Load custom render texture, create a writable depth texture buffer
LoadRenderTextureDepthTex :: (width: s32, height: s32) -> RenderTexture2D
{
    target: RenderTexture2D;

    target.id = rlLoadFramebuffer(); // Load an empty framebuffer

    if (target.id > 0)
    {
        rlEnableFramebuffer(target.id);

        // Create color texture (default to RGBA)
        target.texture.id = rlLoadTexture(null, width, height, .RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
        target.texture.width = width;
        target.texture.height = height;
        target.texture.format = .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
        target.texture.mipmaps = 1;

        // Create depth texture buffer (instead of raylib default renderbuffer)
        target.depth.id = rlLoadTextureDepth(width, height, false);
        target.depth.width = width;
        target.depth.height = height;
        target.depth.format = 19;       // DEPTH_COMPONENT_24BIT: Not defined in raylib
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
UnloadRenderTextureDepthTex :: (target: RenderTexture2D)
{
    if (target.id > 0)
    {
        // Color texture attached to FBO is deleted
        rlUnloadTexture(target.texture.id);
        rlUnloadTexture(target.depth.id);

        // NOTE: Depth texture is automatically
        // queried and deleted before deleting framebuffer
        rlUnloadFramebuffer(target.id);
    }
}