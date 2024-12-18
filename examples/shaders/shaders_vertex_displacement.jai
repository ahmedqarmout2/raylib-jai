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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - vertex displacement");

    // set up camera
    camera: Camera;
    camera.position   = Vector3.{20.0, 5.0, -20.0};
    camera.target     = Vector3.{0.0, 0.0, 0.0};
    camera.up         = Vector3.{0.0, 1.0, 0.0};
    camera.fovy       = 60.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Load vertex and fragment shaders
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/vertex_displacement.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/vertex_displacement.fs", GLSL_VERSION));
    
    // Load perlin noise texture
    perlinNoiseImage: Image = GenImagePerlinNoise(512, 512, 0, 0, 1.0);
    perlinNoiseMap: Texture = LoadTextureFromImage(perlinNoiseImage);
    UnloadImage(perlinNoiseImage);

    // Set shader uniform location
    perlinNoiseMapLoc: s32 = GetShaderLocation(shader, "perlinNoiseMap");
    rlEnableShader(shader.id);
    rlActiveTextureSlot(1);
    rlEnableTexture(perlinNoiseMap.id);
    rlSetUniformSampler(perlinNoiseMapLoc, 1);
    
    // Create a plane mesh and model
    planeMesh: Mesh = GenMeshPlane(50, 50, 50, 50);
    planeModel: Model = LoadModelFromMesh(planeMesh);
    // Set plane model material
    planeModel.materials[0].shader = shader;

    time: float = 0.0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {   // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE); // Update camera

        time += GetFrameTime(); // Update time variable
        SetShaderValue(shader, GetShaderLocation(shader, "time"), *time, .SHADER_UNIFORM_FLOAT); // Send time value to shader

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                BeginShaderMode(shader);
                    // Draw plane model
                    DrawModel(planeModel, Vector3.{0.0, 0.0, 0.0}, 1.0, Color.{255, 255, 255, 255});
                EndShaderMode();

            EndMode3D();

            DrawText("Vertex displacement", 10, 10, 20, DARKGRAY);
            DrawFPS(10, 40);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);
    UnloadModel(planeModel);
    UnloadTexture(perlinNoiseMap);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}