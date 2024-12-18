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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture tiling");

    // Define the camera to look into our 3d world
    camera: Camera3D;
    camera.position   = Vector3.{4.0, 4.0, 4.0}; // Camera position
    camera.target     = Vector3.{0.0, 0.5, 0.0}; // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0}; // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                    // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;     // Camera projection type

    // Load a cube model
    cube : Mesh  = GenMeshCube(1.0, 1.0, 1.0);
    model: Model = LoadModelFromMesh(cube);
    
    // Load a texture and assign to cube model
    texture: Texture2D = LoadTexture("resources/cubicmap_atlas.png");
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;

    // Set the texture tiling using a shader
    tiling: [2]float = .[3.0, 3.0];
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/tiling.fs", GLSL_VERSION));
    SetShaderValue(shader, GetShaderLocation(shader, "tiling"), *tiling, .SHADER_UNIFORM_VEC2);
    model.materials[0].shader = shader;

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {       // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE);

        if (IsKeyPressed(#char "Z")) camera.target = Vector3.{0.0, 0.5, 0.0};
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        
            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
            
                BeginShaderMode(shader);
                    DrawModel(model, Vector3.{0.0, 0.0, 0.0}, 2.0, WHITE);
                EndShaderMode();

                DrawGrid(10, 1.0);
                
            EndMode3D();

            DrawText("Use mouse to rotate the camera", 10, 10, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);         // Unload model
    UnloadShader(shader);       // Unload shader
    UnloadTexture(texture);     // Unload texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}