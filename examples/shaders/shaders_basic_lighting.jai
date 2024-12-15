#import "raylib";
#import "Basic";
#import "Math";

#load "shared/rlights.jai";

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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic lighting");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{2.0, 4.0, 6.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.5, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load basic lighting shader
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/lighting.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/lighting.fs", GLSL_VERSION));
    defer UnloadShader(shader);   // Unload shader

    // Get some required shader locations
    shader.locs[cast(s32) ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    // NOTE: "matModel" location name is automatically assigned on shader loading, 
    // no need to get the location again if using that uniform name
    //shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");
    
    // Ambient light level (some basic lighting)
    ambientLoc: s32 = GetShaderLocation(shader, "ambient");
    values: [4] float = .[0.1, 0.1, 0.1, 1.0];
    SetShaderValue(shader, ambientLoc, *values, .SHADER_UNIFORM_VEC4);

    // Create lights
    lights: [MAX_LIGHTS]Light;
    lights[0] = CreateLight(.LIGHT_POINT, Vector3.{-2, 1, -2}, Vector3Zero(), YELLOW, shader);
    lights[1] = CreateLight(.LIGHT_POINT, Vector3.{ 2, 1,  2}, Vector3Zero(), RED   , shader);
    lights[2] = CreateLight(.LIGHT_POINT, Vector3.{-2, 1,  2}, Vector3Zero(), GREEN , shader);
    lights[3] = CreateLight(.LIGHT_POINT, Vector3.{ 2, 1, -2}, Vector3Zero(), BLUE  , shader);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
        cameraPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);
        
        // Check key inputs to enable/disable lights
        if (IsKeyPressed(.KEY_Y)) { lights[0].enabled = !lights[0].enabled; }
        if (IsKeyPressed(.KEY_R)) { lights[1].enabled = !lights[1].enabled; }
        if (IsKeyPressed(.KEY_G)) { lights[2].enabled = !lights[2].enabled; }
        if (IsKeyPressed(.KEY_B)) { lights[3].enabled = !lights[3].enabled; }
        
        // Update light values (actually, only enable/disable them)
        for i: 0..MAX_LIGHTS-1 UpdateLightValues(shader, lights[i]);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginMode3D(camera);
            defer EndMode3D();

            {
                BeginShaderMode(shader);
                defer EndShaderMode();

                DrawPlane(Vector3Zero(), Vector2.{10.0, 10.0}, WHITE);
                DrawCube(Vector3Zero(), 2.0, 4.0, 2.0, WHITE);
            }

            // Draw spheres to show where the lights are
            for i: 0..MAX_LIGHTS-1 {
                if (lights[i].enabled) DrawSphereEx(lights[i].position, 0.2, 8, 8, lights[i].color);
                else DrawSphereWires(lights[i].position, 0.2, 8, 8, ColorAlpha(lights[i].color, 0.3));
            }

            DrawGrid(10, 1.0);
        }
        DrawFPS(10, 10);
        DrawText("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, DARKGRAY);
        //----------------------------------------------------------------------------------
    }
}