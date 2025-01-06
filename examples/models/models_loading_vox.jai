#import "raylib";
#import "Basic";
#import "Math";

#load "shared/rlights.jai";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_VOX_FILES :: 4;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    voxFileNames: []*u8 = .[
        "resources/models/vox/chr_knight.vox",
        "resources/models/vox/chr_sword.vox",
        "resources/models/vox/monu9.vox",
        "resources/models/vox/fez.vox"
    ];

    InitWindow(screenWidth, screenHeight, "raylib [models] example - magicavoxel loading");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 10.0, 10.0, 10.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    //--------------------------------------------------------------------------------------
    // Load MagicaVoxel files
    models: [MAX_VOX_FILES]Model;

    for i: 0..MAX_VOX_FILES-1
    {
        // Load VOX file and measure time
        t0: float64 = GetTime() * 1000.0;
        models[i] = LoadModel(voxFileNames[i]);
        t1: float64 = GetTime() * 1000.0;

        TraceLog(.LOG_WARNING, TextFormat("[%s] File loaded in %.3f ms", voxFileNames[i], t1 - t0));

        // Compute model translation matrix to center model on draw position (0, 0 , 0)
        bb: BoundingBox = GetModelBoundingBox(models[i]);
        center: Vector3;
        center.x = bb.min.x + (((bb.max.x - bb.min.x) / 2));
        center.z = bb.min.z + (((bb.max.z - bb.min.z) / 2));

        matTranslate: Matrix4 = MatrixTranslate(-center.x, 0, -center.z);
        models[i].transform = matTranslate;
    }

    currentModel: s32 = 0;

    //--------------------------------------------------------------------------------------
    // Load voxel shader
    shader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/voxel_lighting.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/voxel_lighting.fs", GLSL_VERSION));

    // Get some required shader locations
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    // NOTE: "matModel" location name is automatically assigned on shader loading, 
    // no need to get the location again if using that uniform name
    //shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");

    // Ambient light level (some basic lighting)
    ambientLoc: s32 = GetShaderLocation(shader, "ambient");
    value: [4]float = .[0.1, 0.1, 0.1, 1.0];
    SetShaderValue(shader, ambientLoc, *value, .SHADER_UNIFORM_VEC4);

    // Assign out lighting shader to model
    for i: 0..MAX_VOX_FILES-1 {
        m: Model = models[i];
        for j: 0..m.materialCount-1 {
            m.materials[j].shader = shader;
        }
    }

    // Create lights
    lights: [MAX_LIGHTS]Light;
    lights[0] = CreateLight(.LIGHT_POINT, Vector3.{ -20, 20, -20 }, Vector3Zero(), GRAY, shader);
    lights[1] = CreateLight(.LIGHT_POINT, Vector3.{ 20, -20, 20 }, Vector3Zero(), GRAY, shader);
    lights[2] = CreateLight(.LIGHT_POINT, Vector3.{ -20, 20, 20 }, Vector3Zero(), GRAY, shader);
    lights[3] = CreateLight(.LIGHT_POINT, Vector3.{ 20, -20, -20 }, Vector3Zero(), GRAY, shader);


    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    //--------------------------------------------------------------------------------------
    modelpos: Vector3;
    camerarot: Vector3;

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonDown(.MOUSE_BUTTON_MIDDLE))
        {
            mouseDelta: Vector2 = GetMouseDelta();
            camerarot.x = mouseDelta.x * 0.05;
            camerarot.y = mouseDelta.y * 0.05;
        }
        else
        {
            camerarot.x = 0;
            camerarot.y = 0;
        }

        UpdateCameraPro(*camera,
            Vector3.{
                (ifx (IsKeyDown(.KEY_W) || IsKeyDown(.KEY_UP)) then 0.1 else 0) -      // Move forward-backward
                (ifx (IsKeyDown(.KEY_S) || IsKeyDown(.KEY_DOWN)) then 0.1 else 0),
                (ifx (IsKeyDown(.KEY_D) || IsKeyDown(.KEY_RIGHT)) then 0.1 else 0)-   // Move right-left
                (ifx (IsKeyDown(.KEY_A) || IsKeyDown(.KEY_LEFT)) then 0.1 else 0),
                0.0                                                // Move up-down
        },
            camerarot,
            GetMouseWheelMove() * -2.0);                              // Move to target (zoom)

        // Cycle between models on mouse click
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) currentModel = (currentModel + 1) % MAX_VOX_FILES;

        // Update the shader with the camera view vector (points towards { 0.0, 0.0, 0.0 })
        cameraPos: [3]float = .[ camera.position.x, camera.position.y, camera.position.z ];
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);

        // Update light values (actually, only enable/disable them)
        for i: 0..MAX_LIGHTS-1 UpdateLightValues(shader, lights[i]);

        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        // Draw 3D model
        BeginMode3D(camera);

        DrawModel(models[currentModel], modelpos, 1.0, WHITE);
        DrawGrid(10, 1.0);

        // Draw spheres to show where the lights are
        for i: 0..MAX_LIGHTS-1
        {
            if (lights[i].enabled) DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
            else DrawSphereWires(lights[i].position, 0.2, 8, 8, ColorAlpha(lights[i].color, 0.3));
        }

        EndMode3D();

        // Display info
        DrawRectangle(10, 400, 340, 60, Fade(SKYBLUE, 0.5));
        DrawRectangleLines(10, 400, 340, 60, Fade(DARKBLUE, 0.5));
        DrawText("MOUSE LEFT BUTTON to CYCLE VOX MODELS", 40, 410, 10, BLUE);
        DrawText("MOUSE MIDDLE BUTTON to ZOOM OR ROTATE CAMERA", 40, 420, 10, BLUE);
        DrawText("UP-DOWN-LEFT-RIGHT KEYS to MOVE CAMERA", 40, 430, 10, BLUE);
        DrawText(TextFormat("File: %s", GetFileName(voxFileNames[currentModel])), 10, 10, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload models data (GPU VRAM)
    for i: 0..MAX_VOX_FILES-1 UnloadModel(models[i]);

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}