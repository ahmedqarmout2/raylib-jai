#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

SHADOWMAP_RESOLUTION :: 1024;

cam: Camera;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    // Shadows are a HUGE topic, and this example shows an extremely simple implementation of the shadowmapping algorithm,
    // which is the industry standard for shadows. This algorithm can be extended in a ridiculous number of ways to improve
    // realism and also adapt it for different scenes. This is pretty much the simplest possible implementation.
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shadowmap");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    cam.position   = Vector3.{10.0, 10.0, 10.0};    // Camera position
    cam.target     = Vector3Zero();                 // Camera looking at point
    cam.up         = Vector3.{0.0, 1.0, 0.0};       // Camera up vector (rotation towards target)
    cam.fovy       = 45.0;                          // Camera field-of-view Y
    cam.projection = .CAMERA_PERSPECTIVE;           // Camera projection type

    shadowShader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/shadowmap.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/shadowmap.fs", GLSL_VERSION));
    defer UnloadShader(shadowShader);

    shadowShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shadowShader, "viewPos");
    lightDir: Vector3 = Vector3Normalize(Vector3.{0.35, -1.0, -0.35});
    lightColor: Color = WHITE;
    lightColorNormalized: Vector4 = ColorNormalize(lightColor);
    lightDirLoc: s32 = GetShaderLocation(shadowShader, "lightDir");
    lightColLoc: s32 = GetShaderLocation(shadowShader, "lightColor");
    SetShaderValue(shadowShader, lightDirLoc, *lightDir, .SHADER_UNIFORM_VEC3);
    SetShaderValue(shadowShader, lightColLoc, *lightColorNormalized, .SHADER_UNIFORM_VEC4);
    ambientLoc: s32 = GetShaderLocation(shadowShader, "ambient");
    ambient: [4]float = .[0.1, 0.1, 0.1, 1.0];
    SetShaderValue(shadowShader, ambientLoc, *ambient, .SHADER_UNIFORM_VEC4);
    lightVPLoc: s32 = GetShaderLocation(shadowShader, "lightVP");
    shadowMapLoc: s32 = GetShaderLocation(shadowShader, "shadowMap");
    shadowMapResolution: s32 = SHADOWMAP_RESOLUTION;
    SetShaderValue(shadowShader, GetShaderLocation(shadowShader, "shadowMapResolution"), *shadowMapResolution, .SHADER_UNIFORM_INT);

    cube: Model = LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
    defer UnloadModel(cube);

    cube.materials[0].shader = shadowShader;
    robot: Model = LoadModel("resources/models/robot.glb");
    defer UnloadModel(robot);

    for i: 0..robot.materialCount-1 {
        robot.materials[i].shader = shadowShader;
    }
    animCount: s32 = 0;
    robotAnimations: *ModelAnimation = LoadModelAnimations("resources/models/robot.glb", *animCount);
    defer UnloadModelAnimations(robotAnimations, animCount);

    shadowMap: RenderTexture2D = LoadShadowmapRenderTexture(SHADOWMAP_RESOLUTION, SHADOWMAP_RESOLUTION);
    defer UnloadShadowmapRenderTexture(shadowMap);

    // For the shadowmapping algorithm, we will be rendering everything from the light's point of view
    lightCam: Camera3D;
    lightCam.position = Vector3Scale(lightDir, -15.0);
    lightCam.target = Vector3Zero();
    // Use an orthographic projection for directional lights
    lightCam.projection = .CAMERA_ORTHOGRAPHIC;
    lightCam.up = Vector3.{0.0, 1.0, 0.0};
    lightCam.fovy = 20.0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------
    fc: s32 = 0;

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        dt: float = GetFrameTime();

        cameraPos: Vector3 = cam.position;
        SetShaderValue(shadowShader, shadowShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);
        UpdateCamera(*cam, .CAMERA_ORBITAL);

        fc += 1;
        fc %= (robotAnimations[0].frameCount);
        UpdateModelAnimation(robot, robotAnimations[0], fc);

        cameraSpeed: float = 0.05;
        if (IsKeyDown(.KEY_LEFT)) {
            if (lightDir.x < 0.6) lightDir.x += cameraSpeed * 60.0 * dt;
        }
        if (IsKeyDown(.KEY_RIGHT)) {
            if (lightDir.x > -0.6) lightDir.x -= cameraSpeed * 60.0 * dt;
        }
        if (IsKeyDown(.KEY_UP)) {
            if (lightDir.z < 0.6) lightDir.z += cameraSpeed * 60.0 * dt;
        }
        if (IsKeyDown(.KEY_DOWN)) {
            if (lightDir.z > -0.6) lightDir.z -= cameraSpeed * 60.0 * dt;
        }
        lightDir = Vector3Normalize(lightDir);
        lightCam.position = Vector3Scale(lightDir, -15.0);
        SetShaderValue(shadowShader, lightDirLoc, *lightDir, .SHADER_UNIFORM_VEC3);

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        // First, render all objects into the shadowmap
        // The idea is, we record all the objects' depths (as rendered from the light source's point of view) in a buffer
        // Anything that is "visible" to the light is in light, anything that isn't is in shadow
        // We can later use the depth buffer when rendering everything from the player's point of view
        // to determine whether a given point is "visible" to the light

        // Record the light matrices for future use!
        lightView: Matrix4;
        lightProj: Matrix4;
        BeginTextureMode(shadowMap);
        ClearBackground(WHITE);
        BeginMode3D(lightCam);
            lightView = rlGetMatrixModelview();
            lightProj = rlGetMatrixProjection();
            DrawScene(cube, robot);
        EndMode3D();
        EndTextureMode();
        lightViewProj: Matrix4 = MatrixMultiply(lightView, lightProj);

        ClearBackground(RAYWHITE);

        SetShaderValueMatrix(shadowShader, lightVPLoc, lightViewProj);

        rlEnableShader(shadowShader.id);
        slot: s32 = 10; // Can be anything 0 to 15, but 0 will probably be taken up
        rlActiveTextureSlot(10);
        rlEnableTexture(shadowMap.depth.id);
        rlSetUniform(shadowMapLoc, *slot, .SHADER_UNIFORM_INT, 1);

        BeginMode3D(cam);

            // Draw the same exact things as we drew in the shadowmap!
            DrawScene(cube, robot);
        
        EndMode3D();

        DrawText("Shadows in raylib using the shadowmapping algorithm!", screenWidth - 320, screenHeight - 20, 10, GRAY);
        DrawText("Use the arrow keys to rotate the light!", 10, 10, 30, RED);

        EndDrawing();

        if (IsKeyPressed(.KEY_F)) {
            TakeScreenshot("shaders_shadowmap.png");
        }
        //----------------------------------------------------------------------------------
    }
}

LoadShadowmapRenderTexture :: (width: s32, height: s32) -> RenderTexture2D {
    target: RenderTexture2D;

    target.id = rlLoadFramebuffer(); // Load an empty framebuffer
    target.texture.width = width;
    target.texture.height = height;

    if (target.id > 0) {
        rlEnableFramebuffer(target.id);

        // Create depth texture
        // We don't need a color texture for the shadowmap
        target.depth.id = rlLoadTextureDepth(width, height, false);
        target.depth.width = width;
        target.depth.height = height;
        target.depth.format = 19;       //DEPTH_COMPONENT_24BIT?
        target.depth.mipmaps = 1;

        // Attach depth texture to FBO
        rlFramebufferAttach(target.id, target.depth.id, .RL_ATTACHMENT_DEPTH, .RL_ATTACHMENT_TEXTURE2D, 0);

        // Check if fbo is complete with attachments (valid)
        if (rlFramebufferComplete(target.id)) TraceLog(.LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", target.id);

        rlDisableFramebuffer();
    }
    else TraceLog(.LOG_WARNING, "FBO: Framebuffer object can not be created");

    return target;
}

// Unload shadowmap render texture from GPU memory (VRAM)
UnloadShadowmapRenderTexture :: (target: RenderTexture2D) {
    if (target.id > 0) {
        // NOTE: Depth texture/renderbuffer is automatically
        // queried and deleted before deleting framebuffer
        rlUnloadFramebuffer(target.id);
    }
}

DrawScene :: (cube: Model, robot: Model) {
    DrawModelEx(cube, Vector3Zero(), Vector3.{0.0, 1.0, 0.0}, 0.0, Vector3.{10.0, 1.0, 10.0}, BLUE);
    DrawModelEx(cube, Vector3.{1.5, 1.0, -1.5}, Vector3.{0.0, 1.0, 0.0}, 0.0, Vector3One(), WHITE);
    DrawModelEx(robot, Vector3.{0.0, 0.5, 0.0}, Vector3.{0.0, 1.0, 0.0}, 0.0, Vector3.{1.0, 1.0, 1.0}, RED);
}
