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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - simple shader mask");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{0.0, 1.0, 2.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Define our three models to show the shader on
    torus: Mesh   = GenMeshTorus(0.3, 1, 16, 32);
    model1: Model = LoadModelFromMesh(torus);

    cube: Mesh    = GenMeshCube(0.8,0.8,0.8);
    model2: Model = LoadModelFromMesh(cube);

    // Generate model to be shaded just to see the gaps in the other two
    sphere: Mesh  = GenMeshSphere(1, 16, 16);
    model3: Model = LoadModelFromMesh(sphere);

    // Load the shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/mask.fs", GLSL_VERSION));

    // Load and apply the diffuse texture (colour map)
    texDiffuse: Texture = LoadTexture("resources/plasma.png");
    model1.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texDiffuse;
    model2.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texDiffuse;

    // Using MATERIAL_MAP_EMISSION as a spare slot to use for 2nd texture
    // NOTE: Don't use MATERIAL_MAP_IRRADIANCE, MATERIAL_MAP_PREFILTER or  MATERIAL_MAP_CUBEMAP as they are bound as cube maps
    texMask: Texture = LoadTexture("resources/mask.png");
    model1.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].texture = texMask;
    model2.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].texture = texMask;
    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_EMISSION] = GetShaderLocation(shader, "mask");

    // Frame is incremented each frame to animate the shader
    shaderFrame: s32 = GetShaderLocation(shader, "frame");

    // Apply the shader to the two models
    model1.materials[0].shader = shader;
    model2.materials[0].shader = shader;

    framesCounter: s32 = 0;
    rotation: Vector3;           // Model rotation angles

    DisableCursor();                    // Limit cursor to relative movement inside the window
    SetTargetFPS(60);                   // Set  to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);
        
        framesCounter += 1;
        rotation.x += 0.01;
        rotation.y += 0.005;
        rotation.z -= 0.0025;

        // Send frames counter to shader for animation
        SetShaderValue(shader, shaderFrame, *framesCounter, .SHADER_UNIFORM_INT);

        // Rotate one of the models
        model1.transform = MatrixRotateXYZ(rotation);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(DARKBLUE);

            BeginMode3D(camera);

                DrawModel(model1, Vector3.{0.5, 0.0, 0.0 }, 1, WHITE);
                DrawModelEx(model2, Vector3.{-0.5, 0.0, 0.0 }, Vector3.{1.0, 1.0, 0.0}, 50, Vector3.{1.0, 1.0, 1.0}, WHITE);
                DrawModel(model3,Vector3.{0.0, 0.0, -1.5}, 1, WHITE);
                DrawGrid(10, 1.0);        // Draw a grid

            EndMode3D();

            DrawRectangle(16, 698, MeasureText(TextFormat("Frame: %i", framesCounter), 20) + 8, 42, BLUE);
            DrawText(TextFormat("Frame: %i", framesCounter), 20, 700, 20, WHITE);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model1);
    UnloadModel(model2);
    UnloadModel(model3);

    UnloadTexture(texDiffuse);  // Unload default diffuse texture
    UnloadTexture(texMask);     // Unload texture mask

    UnloadShader(shader);       // Unload shader

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
