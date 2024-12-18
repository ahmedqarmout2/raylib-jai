#import "raylib";
#import "Basic";

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture drawing");

    imBlank: Image = GenImageColor(1024, 1024, BLANK);
    texture: Texture2D = LoadTextureFromImage(imBlank);  // Load blank texture to fill on shader
    UnloadImage(imBlank);

    // NOTE: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/cubes_panning.fs", GLSL_VERSION));

    time: float = 0.0;
    timeLoc: s32 = GetShaderLocation(shader, "uTime");
    SetShaderValue(shader, timeLoc, *time, .SHADER_UNIFORM_FLOAT);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    // -------------------------------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {   // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        time = cast(float)GetTime();
        SetShaderValue(shader, timeLoc, *time, .SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginShaderMode(shader);    // Enable our custom shader for next shapes/textures drawings
                DrawTexture(texture, 0, 0, WHITE);  // Drawing BLANK texture, all magic happens on shader
            EndShaderMode();            // Disable our custom shader, return to default shader

            DrawText("BACKGROUND is PAINTED and ANIMATED on SHADER!", 10, 10, 20, MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);
    UnloadTexture(texture);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}