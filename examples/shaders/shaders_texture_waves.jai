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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves");
    defer CloseWindow(); // Close window and OpenGL context

    // Load texture texture to apply shaders
    texture: Texture2D = LoadTexture("resources/space.png");
    defer UnloadTexture(texture);       // Unload texture

    // Load shader and setup location points and values
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/wave.fs", GLSL_VERSION));
    defer UnloadShader(shader);         // Unload shader

    secondsLoc : s32 = GetShaderLocation(shader, "seconds");
    freqXLoc   : s32 = GetShaderLocation(shader, "freqX");
    freqYLoc   : s32 = GetShaderLocation(shader, "freqY");
    ampXLoc    : s32 = GetShaderLocation(shader, "ampX");
    ampYLoc    : s32 = GetShaderLocation(shader, "ampY");
    speedXLoc  : s32 = GetShaderLocation(shader, "speedX");
    speedYLoc  : s32 = GetShaderLocation(shader, "speedY");

    // Shader uniform values that can be updated at any time
    freqX  : float = 25.0;
    freqY  : float = 25.0;
    ampX   : float = 5.0;
    ampY   : float = 5.0;
    speedX : float = 8.0;
    speedY : float = 8.0;

    screenSize: [2]float = .[cast(float)GetScreenWidth(), cast(float)GetScreenHeight()];
    SetShaderValue(shader, GetShaderLocation(shader, "size"), *screenSize, .SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, freqXLoc, *freqX, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, freqYLoc, *freqY, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, ampXLoc, *ampX, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, ampYLoc, *ampY, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, speedXLoc, *speedX, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, speedYLoc, *speedY, .SHADER_UNIFORM_FLOAT);

    seconds: float = 0.0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        seconds += GetFrameTime();

        SetShaderValue(shader, secondsLoc, *seconds, .SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        BeginShaderMode(shader);
        defer EndShaderMode();

        DrawTexture(texture, 0, 0, WHITE);
        DrawTexture(texture, texture.width, 0, WHITE);
        //----------------------------------------------------------------------------------
    }
}