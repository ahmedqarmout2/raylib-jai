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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Apply an outline to a texture");

    texture: Texture2D = LoadTexture("resources/fudesumi.png");

    shdrOutline: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/outline.fs", GLSL_VERSION));

    outlineSize: float = 2.0;
    outlineColor: [4]float = .[1.0, 0.0, 0.0, 1.0];     // Normalized RED color
    textureSize: [2]float = .[cast(float)texture.width, cast(float)texture.height];

    // Get shader locations
    outlineSizeLoc  : s32 = GetShaderLocation(shdrOutline, "outlineSize");
    outlineColorLoc : s32 = GetShaderLocation(shdrOutline, "outlineColor");
    textureSizeLoc  : s32 = GetShaderLocation(shdrOutline, "textureSize");

    // Set shader values (they can be changed later)
    SetShaderValue(shdrOutline, outlineSizeLoc, *outlineSize, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shdrOutline, outlineColorLoc, *outlineColor, .SHADER_UNIFORM_VEC4);
    SetShaderValue(shdrOutline, textureSizeLoc, *textureSize, .SHADER_UNIFORM_VEC2);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {   // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        outlineSize += GetMouseWheelMove();
        if (outlineSize < 1.0) outlineSize = 1.0;

        SetShaderValue(shdrOutline, outlineSizeLoc, *outlineSize, .SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginShaderMode(shdrOutline);

                DrawTexture(texture, GetScreenWidth()/2 - texture.width/2, -30, WHITE);

            EndShaderMode();

            DrawText("Shader-based\ntexture\noutline", 10, 10, 20, GRAY);
            DrawText("Scroll mouse wheel to\nchange outline size", 10, 72, 20, GRAY);
            DrawText(TextFormat("Outline size: %i px", cast(s32)outlineSize), 10, 120, 20, MAROON);

            DrawFPS(710, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);
    UnloadShader(shdrOutline);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}