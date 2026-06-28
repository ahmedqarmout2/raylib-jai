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

    SetConfigFlags(.FLAG_WINDOW_RESIZABLE);      // Enable Multi Sampling Anti Aliasing 4x (if available)
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - raymarching rendering");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{2.5, 2.5, 3.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.7};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 65.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load raymarching shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/raymarching.fs", GLSL_VERSION));

    // Get shader locations for required uniforms
    viewEyeLoc    : s32 = GetShaderLocation(shader, "viewEye");
    viewCenterLoc : s32 = GetShaderLocation(shader, "viewCenter");
    runTimeLoc    : s32 = GetShaderLocation(shader, "runTime");
    resolutionLoc : s32 = GetShaderLocation(shader, "resolution");

    resolution: [2]float = .[cast(float)screenWidth, cast(float)screenHeight];
    SetShaderValue(shader, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);

    runTime: float = 0.0;

    DisableCursor();                    // Limit cursor to relative movement inside the window
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        cameraPos    : [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        cameraTarget : [3]float = .[camera.target.x, camera.target.y, camera.target.z];

        deltaTime: float = GetFrameTime();
        runTime += deltaTime;

        // Set shader required uniform values
        SetShaderValue(shader, viewEyeLoc   , *cameraPos   , .SHADER_UNIFORM_VEC3);
        SetShaderValue(shader, viewCenterLoc, *cameraTarget, .SHADER_UNIFORM_VEC3);
        SetShaderValue(shader, runTimeLoc   , *runTime     , .SHADER_UNIFORM_FLOAT);

        // Check if screen is resized
        if (IsWindowResized())
        {
            resolution[0] = cast(float)GetScreenWidth();
            resolution[1] = cast(float)GetScreenHeight();
            SetShaderValue(shader, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // We only draw a white full-screen rectangle,
            // frame is generated in shader using raymarching
            BeginShaderMode(shader);
                DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), WHITE);
            EndShaderMode();

            DrawText("(c) Raymarching shader by Iñigo Quilez. MIT License.", GetScreenWidth() - 280, GetScreenHeight() - 20, 10, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);           // Unload shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}