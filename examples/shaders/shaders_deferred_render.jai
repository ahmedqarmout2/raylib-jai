#import "raylib";
#import "Basic";
#import "Math";
#import "Random";

#load "shared/rlights.jai";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_CUBES :: 30;

GBuffer :: struct {
    framebuffer: u32;

    positionTexture   : u32;
    normalTexture     : u32;
    albedoSpecTexture : u32;
    
    depthRenderbuffer: u32;
};

DeferredMode :: enum {
   DEFERRED_POSITION;
   DEFERRED_NORMAL;
   DEFERRED_ALBEDO;
   DEFERRED_SHADING;
};

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - deferred render");
    defer CloseWindow(); // Close window and OpenGL context

    camera: Camera;
    camera.position   = Vector3.{5.0, 4.0, 5.0};    // Camera position
    camera.target     = Vector3.{0.0, 1.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 60.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load plane model from a generated mesh
    model: Model = LoadModelFromMesh(GenMeshPlane(10.0, 10.0, 3, 3));
    defer UnloadModel(model);     // Unload the models

    cube : Model = LoadModelFromMesh(GenMeshCube(2.0, 2.0, 2.0));
    defer UnloadModel(cube);

    // Load geometry buffer (G-buffer) shader and deferred shader
    gbufferShader: Shader = LoadShader(
        "resources/shaders/glsl330/gbuffer.vs",
        "resources/shaders/glsl330/gbuffer.fs");
    defer UnloadShader(gbufferShader);

    deferredShader: Shader = LoadShader(
        "resources/shaders/glsl330/deferred_shading.vs",
        "resources/shaders/glsl330/deferred_shading.fs");
    defer UnloadShader(deferredShader); // Unload shaders

    deferredShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(deferredShader, "viewPosition");

    // Initialize the G-buffer
    gBuffer: GBuffer;
    gBuffer.framebuffer = rlLoadFramebuffer();
    defer rlUnloadFramebuffer(gBuffer.framebuffer);

    if (!gBuffer.framebuffer) {
        TraceLog(.LOG_WARNING, "Failed to create framebuffer");
        exit(1);
    }

    rlEnableFramebuffer(gBuffer.framebuffer);

    // Since we are storing position and normal data in these textures, 
    // we need to use a floating point format.
    gBuffer.positionTexture = rlLoadTexture(null, screenWidth, screenHeight, .PIXELFORMAT_UNCOMPRESSED_R32G32B32, 1);
    defer rlUnloadTexture(gBuffer.positionTexture);

    gBuffer.normalTexture = rlLoadTexture(null, screenWidth, screenHeight, .PIXELFORMAT_UNCOMPRESSED_R32G32B32, 1);
    defer rlUnloadTexture(gBuffer.normalTexture);

    // Albedo (diffuse color) and specular strength can be combined into one texture.
    // The color in RGB, and the specular strength in the alpha channel.
    gBuffer.albedoSpecTexture = rlLoadTexture(null, screenWidth, screenHeight, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
    defer rlUnloadTexture(gBuffer.albedoSpecTexture);

    // Activate the draw buffers for our framebuffer
    rlActiveDrawBuffers(3);

    // Now we attach our textures to the framebuffer.
    rlFramebufferAttach(gBuffer.framebuffer, gBuffer.positionTexture, .RL_ATTACHMENT_COLOR_CHANNEL0, .RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(gBuffer.framebuffer, gBuffer.normalTexture, .RL_ATTACHMENT_COLOR_CHANNEL1, .RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(gBuffer.framebuffer, gBuffer.albedoSpecTexture, .RL_ATTACHMENT_COLOR_CHANNEL2, .RL_ATTACHMENT_TEXTURE2D, 0);

    // Finally we attach the depth buffer.
    gBuffer.depthRenderbuffer = rlLoadTextureDepth(screenWidth, screenHeight, true);
    defer rlUnloadTexture(gBuffer.depthRenderbuffer);

    rlFramebufferAttach(gBuffer.framebuffer, gBuffer.depthRenderbuffer, .RL_ATTACHMENT_DEPTH, .RL_ATTACHMENT_RENDERBUFFER, 0);

    // Make sure our framebuffer is complete.
    // NOTE: rlFramebufferComplete() automatically unbinds the framebuffer, so we don't have
    // to rlDisableFramebuffer() here.
    if (!rlFramebufferComplete(gBuffer.framebuffer)) {
        TraceLog(.LOG_WARNING, "Framebuffer is not complete");
        exit(1);
    }

    {
        // Now we initialize the sampler2D uniform's in the deferred shader.
        // We do this by setting the uniform's value to the color channel slot we earlier
        // bound our textures to.
        rlEnableShader(deferredShader.id);
        defer rlDisableShader();

        rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gPosition"), 0);
        rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gNormal"), 1);
        rlSetUniformSampler(rlGetLocationUniform(deferredShader.id, "gAlbedoSpec"), 2);
    }

    // Assign out lighting shader to model
    model.materials[0].shader = gbufferShader;
    cube.materials[0].shader  = gbufferShader;

    // Create lights
    //--------------------------------------------------------------------------------------
    lights: [MAX_LIGHTS]Light;
    lights[0] = CreateLight(.LIGHT_POINT, Vector3.{-2, 1, -2}, Vector3Zero(), YELLOW, deferredShader);
    lights[1] = CreateLight(.LIGHT_POINT, Vector3.{ 2, 1,  2}, Vector3Zero(), RED   , deferredShader);
    lights[2] = CreateLight(.LIGHT_POINT, Vector3.{-2, 1,  2}, Vector3Zero(), GREEN , deferredShader);
    lights[3] = CreateLight(.LIGHT_POINT, Vector3.{ 2, 1, -2}, Vector3Zero(), BLUE  , deferredShader);

    CUBE_SCALE   : float = 0.25;
    cubePositions: [MAX_CUBES]Vector3;
    cubeRotations: [MAX_CUBES]float;
    
    for i: 0..MAX_CUBES-1 {
        cubePositions[i] = Vector3.{
            cast(float)(random_get()%10) - 5,
            cast(float)(random_get()%5),
            cast(float)(random_get()%10) - 5,
        };
        
        cubeRotations[i] = cast(float)(random_get()%360);
    }

    mode: DeferredMode = .DEFERRED_SHADING;

    rlEnableDepthTest();

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
        cameraPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(deferredShader, deferredShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);
        
        // Check key inputs to enable/disable lights
        if (IsKeyPressed(.KEY_Y)) { lights[0].enabled = !lights[0].enabled; }
        if (IsKeyPressed(.KEY_R)) { lights[1].enabled = !lights[1].enabled; }
        if (IsKeyPressed(.KEY_G)) { lights[2].enabled = !lights[2].enabled; }
        if (IsKeyPressed(.KEY_B)) { lights[3].enabled = !lights[3].enabled; }

        // Check key inputs to switch between G-buffer textures
        if (IsKeyPressed(.KEY_ONE))   mode = .DEFERRED_POSITION;
        if (IsKeyPressed(.KEY_TWO))   mode = .DEFERRED_NORMAL;
        if (IsKeyPressed(.KEY_THREE)) mode = .DEFERRED_ALBEDO;
        if (IsKeyPressed(.KEY_FOUR))  mode = .DEFERRED_SHADING;

        // Update light values (actually, only enable/disable them)
        for i: 0..MAX_LIGHTS-1 UpdateLightValues(deferredShader, lights[i]);
        //----------------------------------------------------------------------------------

        // Draw
        // ---------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        // Draw to the geometry buffer by first activating it
        rlEnableFramebuffer(gBuffer.framebuffer);
        rlClearScreenBuffers();  // Clear color and depth buffer

        rlDisableColorBlend();

        {
            BeginMode3D(camera);
            defer EndMode3D();

            // NOTE: We have to use rlEnableShader here. `BeginShaderMode` or thus `rlSetShader`
            // will not work, as they won't immediately load the shader program.
            rlEnableShader(gbufferShader.id);
            defer rlDisableShader();

            // When drawing a model here, make sure that the material's shaders
            // are set to the gbuffer shader!
            DrawModel(model, Vector3Zero(), 1.0, WHITE);
            DrawModel(cube, Vector3.{0.0, 1.0, 0.0}, 1.0, WHITE);

            for i: 0..MAX_CUBES-1 {
                position: Vector3 = cubePositions[i];
                DrawModelEx(cube, position, Vector3.{1, 1, 1}, cubeRotations[i], Vector3.{CUBE_SCALE, CUBE_SCALE, CUBE_SCALE}, WHITE);
            }
        }

        rlEnableColorBlend();

        // Go back to the default framebuffer (0) and draw our deferred shading.
        rlDisableFramebuffer();
        rlClearScreenBuffers(); // Clear color & depth buffer

        if mode == {
            case .DEFERRED_SHADING;
                {
                    rlDisableColorBlend();
                    defer rlEnableColorBlend();

                    BeginMode3D(camera);
                    defer EndMode3D();

                    rlEnableShader(deferredShader.id);
                    defer rlDisableShader();

                    // Activate our g-buffer textures
                    // These will now be bound to the sampler2D uniforms `gPosition`, `gNormal`,
                    // and `gAlbedoSpec`
                    rlActiveTextureSlot(0);
                    rlEnableTexture(gBuffer.positionTexture);
                    rlActiveTextureSlot(1);
                    rlEnableTexture(gBuffer.normalTexture);
                    rlActiveTextureSlot(2);
                    rlEnableTexture(gBuffer.albedoSpecTexture);

                    // Finally, we draw a fullscreen quad to our default framebuffer
                    // This will now be shaded using our deferred shader
                    rlLoadDrawQuad();
                }

                // As a last step, we now copy over the depth buffer from our g-buffer to the default framebuffer.
                rlBindFramebuffer(RL_READ_FRAMEBUFFER, gBuffer.framebuffer);
                rlBindFramebuffer(RL_DRAW_FRAMEBUFFER, 0);
                rlBlitFramebuffer(0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight, 0x00000100);    // GL_DEPTH_BUFFER_BIT
                rlDisableFramebuffer();

                {
                    // Since our shader is now done and disabled, we can draw our lights in default
                    // forward rendering
                    BeginMode3D(camera);
                    defer EndMode3D();

                    rlEnableShader(rlGetShaderIdDefault());
                    defer rlDisableShader();

                    for i: 0..MAX_LIGHTS-1 {
                        if (lights[i].enabled) DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
                        else DrawSphereWires(lights[i].position, 0.2, 8, 8, ColorAlpha(lights[i].color, 0.3));
                    }
                }
                DrawText("FINAL RESULT", 10, screenHeight - 30, 20, DARKGREEN);
            case .DEFERRED_POSITION;
                DrawTextureRec(Texture2D.{
                    id     = gBuffer.positionTexture,
                    width  = screenWidth,
                    height = screenHeight,
                }, Rectangle.{0, 0, cast(float)screenWidth, cast(float)-screenHeight}, Vector2Zero(), RAYWHITE);
                
                DrawText("POSITION TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
            case .DEFERRED_NORMAL;
                DrawTextureRec(Texture2D.{
                    id     = gBuffer.normalTexture,
                    width  = screenWidth,
                    height = screenHeight,
                }, Rectangle.{0, 0, cast(float)screenWidth, cast(float)-screenHeight}, Vector2Zero(), RAYWHITE);
                
                DrawText("NORMAL TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
            case .DEFERRED_ALBEDO;
                DrawTextureRec(Texture2D.{
                    id     = gBuffer.albedoSpecTexture,
                    width  = screenWidth,
                    height = screenHeight,
                }, Rectangle.{0, 0, cast(float)screenWidth, cast(float)-screenHeight}, Vector2Zero(), RAYWHITE);
                
                DrawText("ALBEDO TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
        }

        DrawText("Toggle lights keys: [Y][R][G][B]", 10, 40, 20, DARKGRAY);
        DrawText("Switch G-buffer textures: [1][2][3][4]", 10, 70, 20, DARKGRAY);

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}