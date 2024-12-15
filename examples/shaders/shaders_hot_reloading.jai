#import "raylib";
#import "Basic";
#import "Math";
#import "File_Utilities";

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading");
    defer CloseWindow(); // Close window and OpenGL context

    fragShaderFileName: string = to_string(TextFormat("resources/shaders/glsl%i/reload.fs", GLSL_VERSION));
    fragShaderFileModTime, size, succ := file_modtime_and_size(fragShaderFileName);

    // Load raymarching shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, fragShaderFileName.data);
    defer UnloadShader(shader);           // Unload shader

    // Get shader locations for required uniforms
    resolutionLoc: s32 = GetShaderLocation(shader, "resolution");
    mouseLoc     : s32 = GetShaderLocation(shader, "mouse");
    timeLoc      : s32 = GetShaderLocation(shader, "time");

    resolution: [2]float = .[cast(float)screenWidth, cast(float)screenHeight];
    SetShaderValue(shader, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);

    totalTime: float = 0.0;
    shaderAutoReloading: bool = false;

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        totalTime += GetFrameTime();
        mouse: Vector2 = GetMousePosition();
        mousePos: [2]float = .[mouse.x, mouse.y];

        // Set shader required uniform values
        SetShaderValue(shader, timeLoc, *totalTime, .SHADER_UNIFORM_FLOAT);
        SetShaderValue(shader, mouseLoc, *mousePos, .SHADER_UNIFORM_VEC2);

        // Hot shader reloading
        if (shaderAutoReloading || (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))) {
            currentFragShaderModTime, size, succ := file_modtime_and_size(fragShaderFileName);

            // Check if shader file has been modified
            if (currentFragShaderModTime != fragShaderFileModTime) {
                // Try reloading updated shader
                updatedShader: Shader = LoadShader(null, fragShaderFileName.data);

                if (updatedShader.id != rlGetShaderIdDefault()) {
                    UnloadShader(shader);
                    shader = updatedShader;

                    // Get shader locations for required uniforms
                    resolutionLoc = GetShaderLocation(shader, "resolution");
                    mouseLoc      = GetShaderLocation(shader, "mouse");
                    timeLoc       = GetShaderLocation(shader, "time");

                    // Reset required uniforms
                    SetShaderValue(shader, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);
                }

                fragShaderFileModTime = currentFragShaderModTime;
            }
        }

        if (IsKeyPressed(.KEY_A)) shaderAutoReloading = !shaderAutoReloading;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            // We only draw a white full-screen rectangle, frame is generated in shader
            BeginShaderMode(shader);
            defer EndShaderMode();

            DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
        }

        t := get_c_string(ifx shaderAutoReloading then "AUTO" else "MANUAL");
        DrawText(TextFormat("PRESS [A] to TOGGLE SHADER AUTOLOADING: %s", t), 10, 10, 10, ifx shaderAutoReloading then RED else BLACK);
        if (!shaderAutoReloading) DrawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, BLACK);

        x := get_c_string(calendar_to_string(to_calendar(fragShaderFileModTime, .LOCAL)));
        DrawText(TextFormat("Shader last modification: %s", x), 10, 430, 10, BLACK);
        //----------------------------------------------------------------------------------
    }
}