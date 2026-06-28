#import "raylib";
#import "Basic";
#import "Math";
#import "Random";

#load "shared/rlights.jai";

MAX_CUBES :: 30;

GBuffer :: struct {
    framebufferId: u32;

    positionTextureId   : u32;
    normalTextureId     : u32;
    albedoSpecTextureId : u32;
    
    depthRenderbufferId: u32;
};

DeferredMode :: enum {
   DEFERRED_POSITION;
   DEFERRED_NORMAL;
   DEFERRED_ALBEDO;
   DEFERRED_SHADING;
};

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - deferred rendering");

    camera: Camera;
    camera.position   = Vector3.{5.0, 4.0, 5.0};    // Camera position
    camera.target     = Vector3.{0.0, 1.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 60.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load plane model from a generated mesh
    model: Model = LoadModelFromMesh(GenMeshPlane(10.0, 10.0, 3, 3));
    cube : Model = LoadModelFromMesh(GenMeshCube(2.0, 2.0, 2.0));

    // Load geometry buffer (G-buffer) shader and deferred shader
    gbufferShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/gbuffer.vs", GLSL_VERSION),
                               TextFormat("resources/shaders/glsl%i/gbuffer.fs", GLSL_VERSION));

    deferredShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/deferred_shading.vs", GLSL_VERSION),
                               TextFormat("resources/shaders/glsl%i/deferred_shading.fs", GLSL_VERSION));
    deferredShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(deferredShader, "viewPosition");

    // Initialize the G-buffer
    gBuffer: GBuffer;
    gBuffer.framebufferId = rlLoadFramebuffer();
    if (gBuffer.framebufferId == 0) TraceLog(.LOG_WARNING, "Failed to create framebufferId");

    rlEnableFramebuffer(gBuffer.framebufferId);

    // NOTE: Vertex positions are stored in a texture for simplicity. A better approach would use a depth texture
    // (instead of a detph renderbuffer) to reconstruct world positions in the final render shader via clip-space position,
    // depth, and the inverse view/projection matrices

    // 16-bit precision ensures OpenGL ES 3 compatibility, though it may lack precision for real scenarios
    // But as mentioned above, the positions could be reconstructed instead of stored. If not targeting OpenGL ES
    // and you wish to maintain this approach, consider using `RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32`
    gBuffer.positionTextureId = rlLoadTexture(null, screenWidth, screenHeight, .RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16, 1);

    // Similarly, 16-bit precision is used for normals ensures OpenGL ES 3 compatibility
    // This is generally sufficient, but a 16-bit fixed-point format offer a better uniform precision in all orientations
    gBuffer.normalTextureId = rlLoadTexture(null, screenWidth, screenHeight, .RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16, 1);

    // Albedo (diffuse color) and specular strength can be combined into one texture
    // The color in RGB, and the specular strength in the alpha channel
    gBuffer.albedoSpecTextureId = rlLoadTexture(null, screenWidth, screenHeight, .RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);

    // Activate the draw buffers for our framebuffer
    rlActiveDrawBuffers(3);

    // Now we attach our textures to the framebuffer.
    rlFramebufferAttach(gBuffer.framebufferId, gBuffer.positionTextureId, .RL_ATTACHMENT_COLOR_CHANNEL0, .RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(gBuffer.framebufferId, gBuffer.normalTextureId, .RL_ATTACHMENT_COLOR_CHANNEL1, .RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(gBuffer.framebufferId, gBuffer.albedoSpecTextureId, .RL_ATTACHMENT_COLOR_CHANNEL2, .RL_ATTACHMENT_TEXTURE2D, 0);

    // Finally we attach the depth buffer.
    gBuffer.depthRenderbufferId = rlLoadTextureDepth(screenWidth, screenHeight, true);
    rlFramebufferAttach(gBuffer.framebufferId, gBuffer.depthRenderbufferId, .RL_ATTACHMENT_DEPTH, .RL_ATTACHMENT_RENDERBUFFER, 0);

    // Make sure our framebufferId is complete
    // NOTE: rlFramebufferComplete() automatically unbinds the framebufferId, so we don't have to rlDisableFramebuffer() here
    if (!rlFramebufferComplete(gBuffer.framebufferId)) TraceLog(.LOG_WARNING, "Framebuffer is not complete");

    // Now we initialize the sampler2D uniform's in the deferred shader
    // We do this by setting the uniform's values to the texture units that
    // we later bind our g-buffer textures to
    rlEnableShader(deferredShader.id);
    texUnitPosition: s32 = 0;
    texUnitNormal: s32 = 1;
    texUnitAlbedoSpec: s32 = 2;
    SetShaderValue(deferredShader, rlGetLocationUniform(deferredShader.id, "gPosition"), *texUnitPosition, .SHADER_UNIFORM_SAMPLER2D);
    SetShaderValue(deferredShader, rlGetLocationUniform(deferredShader.id, "gNormal"), *texUnitNormal, .SHADER_UNIFORM_SAMPLER2D);
    SetShaderValue(deferredShader, rlGetLocationUniform(deferredShader.id, "gAlbedoSpec"), *texUnitAlbedoSpec, .SHADER_UNIFORM_SAMPLER2D);
    rlDisableShader();

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

    // Main game loop
    while (!WindowShouldClose())
    {
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

            // Draw to the geometry buffer by first activating it
            rlEnableFramebuffer(gBuffer.framebufferId);
            rlClearColor(0, 0, 0, 0);
            rlClearScreenBuffers();  // Clear color and depth buffer
            rlDisableColorBlend();

            BeginMode3D(camera);
                // NOTE: We have to use rlEnableShader here. `BeginShaderMode` or thus `rlSetShader`
                // will not work, as they won't immediately load the shader program
                rlEnableShader(gbufferShader.id);
                    // When drawing a model here, make sure that the material's shaders are set to the gbuffer shader!
                    DrawModel(model, Vector3Zero(), 1.0, WHITE);
                    DrawModel(cube, Vector3.{ 0.0, 1.0, 0.0 }, 1.0, WHITE);

                    for i: 0..MAX_CUBES-1
                    {
                        position: Vector3 = cubePositions[i];
                        DrawModelEx(cube, position, Vector3.{ 1, 1, 1 }, cubeRotations[i], Vector3.{ CUBE_SCALE, CUBE_SCALE, CUBE_SCALE }, WHITE);
                    }
                rlDisableShader();
            EndMode3D();

            rlEnableColorBlend();

            // Go back to the default framebufferId (0) and draw our deferred shading
            rlDisableFramebuffer();
            rlClearScreenBuffers(); // Clear color & depth buffer

            ifx mode ==
            {
                case .DEFERRED_SHADING;
                {
                    BeginMode3D(camera);
                        rlDisableColorBlend();
                        rlEnableShader(deferredShader.id);
                            // Bind our g-buffer textures
                            // We are binding them to locations that we earlier set in sampler2D uniforms `gPosition`, `gNormal`,
                            // and `gAlbedoSpec`
                            rlActiveTextureSlot(texUnitPosition);
                            rlEnableTexture(gBuffer.positionTextureId);
                            rlActiveTextureSlot(texUnitNormal);
                            rlEnableTexture(gBuffer.normalTextureId);
                            rlActiveTextureSlot(texUnitAlbedoSpec);
                            rlEnableTexture(gBuffer.albedoSpecTextureId);

                            // Finally, we draw a fullscreen quad to our default framebufferId
                            // This will now be shaded using our deferred shader
                            rlLoadDrawQuad();
                        rlDisableShader();
                        rlEnableColorBlend();
                    EndMode3D();

                    // As a last step, we now copy over the depth buffer from our g-buffer to the default framebufferId
                    rlBindFramebuffer(RL_READ_FRAMEBUFFER, gBuffer.framebufferId);
                    rlBindFramebuffer(RL_DRAW_FRAMEBUFFER, 0);
                    rlBlitFramebuffer(0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight, 0x00000100); // GL_DEPTH_BUFFER_BIT
                    rlDisableFramebuffer();

                    // Since our shader is now done and disabled, we can draw spheres
                    // that represent light positions in default forward rendering
                    BeginMode3D(camera);
                        rlEnableShader(rlGetShaderIdDefault());
                            for i: 0..MAX_LIGHTS-1
                            {
                                if (lights[i].enabled) DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
                                else DrawSphereWires(lights[i].position, 0.2, 8, 8, ColorAlpha(lights[i].color, 0.3));
                            }
                        rlDisableShader();
                    EndMode3D();

                    DrawText("FINAL RESULT", 10, screenHeight - 30, 20, DARKGREEN);
                }
                case .DEFERRED_POSITION;
                {
                    DrawTextureRec(Texture2D.{
                        id = gBuffer.positionTextureId,
                        width = screenWidth,
                        height = screenHeight,
                    }, Rectangle.{ 0, 0, cast(float)screenWidth, cast(float)-screenHeight }, Vector2Zero(), RAYWHITE);

                    DrawText("POSITION TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
                }
                case .DEFERRED_NORMAL;
                {
                    DrawTextureRec(Texture2D.{
                        id = gBuffer.normalTextureId,
                        width = screenWidth,
                        height = screenHeight,
                    }, Rectangle.{ 0, 0, cast(float)screenWidth, cast(float)-screenHeight }, Vector2Zero(), RAYWHITE);

                    DrawText("NORMAL TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
                }
                case .DEFERRED_ALBEDO;
                {
                    DrawTextureRec(Texture2D.{
                        id = gBuffer.albedoSpecTextureId,
                        width = screenWidth,
                        height = screenHeight,
                    }, Rectangle.{ 0, 0, cast(float)screenWidth, cast(float)-screenHeight }, Vector2Zero(), RAYWHITE);

                    DrawText("ALBEDO TEXTURE", 10, screenHeight - 30, 20, DARKGREEN);
                }
            }

            DrawText("Toggle lights keys: [Y][R][G][B]", 10, 40, 20, DARKGRAY);
            DrawText("Switch G-buffer textures: [1][2][3][4]", 10, 70, 20, DARKGRAY);

            DrawFPS(10, 10);

        EndDrawing();
        // -----------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload the models
    UnloadModel(model);
    UnloadModel(cube);

    // Unload shaders
    UnloadShader(deferredShader);
    UnloadShader(gbufferShader);

    // Unload geometry buffer and all attached textures
    rlUnloadFramebuffer(gBuffer.framebufferId);
    rlUnloadTexture(gBuffer.positionTextureId);
    rlUnloadTexture(gBuffer.normalTextureId);
    rlUnloadTexture(gBuffer.albedoSpecTextureId);
    rlUnloadTexture(gBuffer.depthRenderbufferId);

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}