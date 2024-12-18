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

    InitWindow(screenWidth, screenHeight, "raylib - multiple sample2D");
    defer CloseWindow(); // Close window and OpenGL context

    imRed: Image = GenImageColor(800, 450, Color.{255, 0, 0, 255});
    texRed: Texture = LoadTextureFromImage(imRed);
    defer UnloadTexture(texRed);      // Unload texture
    UnloadImage(imRed);

    imBlue: Image = GenImageColor(800, 450, Color.{0, 0, 255, 255});
    texBlue: Texture = LoadTextureFromImage(imBlue);
    defer UnloadTexture(texBlue);     // Unload texture
    UnloadImage(imBlue);

    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/color_mix.fs", GLSL_VERSION));
    defer UnloadShader(shader);       // Unload shader

    // Get an additional sampler2D location to be enabled on drawing
    texBlueLoc: s32 = GetShaderLocation(shader, "texture1");

    // Get shader uniform for divider
    dividerLoc: s32 = GetShaderLocation(shader, "divider");
    dividerValue: float = 0.5;

    SetTargetFPS(60);                           // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
             if (IsKeyDown(.KEY_RIGHT)) dividerValue += 0.01;
        else if (IsKeyDown(.KEY_LEFT))  dividerValue -= 0.01;

             if (dividerValue < 0.0) dividerValue = 0.0;
        else if (dividerValue > 1.0) dividerValue = 1.0;

        SetShaderValue(shader, dividerLoc, *dividerValue, .SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginShaderMode(shader);
            defer EndShaderMode();

            // WARNING: Additional samplers are enabled for all draw calls in the batch,
            // EndShaderMode() forces batch drawing and consequently resets active textures
            // to let other sampler2D to be activated on consequent drawings (if required)
            SetShaderValueTexture(shader, texBlueLoc, texBlue);

            // We are drawing texRed using default sampler2D texture0 but
            // an additional texture units is enabled for texBlue (sampler2D texture1)
            DrawTexture(texRed, 0, 0, WHITE);
        }

        DrawText("Use KEY_LEFT/KEY_RIGHT to move texture mixing in shader!", 80, GetScreenHeight() - 40, 20, RAYWHITE);
        //----------------------------------------------------------------------------------
    }
}