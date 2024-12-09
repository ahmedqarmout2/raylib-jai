#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - sprite font loading");
    defer CloseWindow(); // Close window and OpenGL context

    msg1: [50]char;
    s := "THIS IS A custom SPRITE FONT...";
    for s msg1[it_index] = it;

    msg2: [50]char;
    s = "...and this is ANOTHER CUSTOM font...";
    for s msg2[it_index] = it;

    msg3: [50]char;
    s = "...and a THIRD one! GREAT! :D";
    for s msg3[it_index] = it;

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
    font1: Font = LoadFont("resources/custom_mecha.png");          // Font loading
    defer UnloadFont(font1);      // Font unloading

    font2: Font = LoadFont("resources/custom_alagard.png");        // Font loading
    defer UnloadFont(font2);      // Font unloading

    font3: Font = LoadFont("resources/custom_jupiter_crash.png");  // Font loading
    defer UnloadFont(font3);      // Font unloading

    fontPosition1: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font1, msg1.data, cast(float)font1.baseSize, -3).x/2,
                              screenHeight/2.0 - font1.baseSize/2.0 - 80.0 };

    fontPosition2: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font2, msg2.data, cast(float)font2.baseSize, -2.0).x/2.0,
                              screenHeight/2.0 - font2.baseSize/2.0 - 10.0 };

    fontPosition3: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font3, msg3.data, cast(float)font3.baseSize, 2.0).x/2.0,
                              screenHeight/2.0 - font3.baseSize/2.0 + 50.0 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update variables here...
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTextEx(font1, msg1.data, fontPosition1, cast(float)font1.baseSize, -3, WHITE);
        DrawTextEx(font2, msg2.data, fontPosition2, cast(float)font2.baseSize, -2, WHITE);
        DrawTextEx(font3, msg3.data, fontPosition3, cast(float)font3.baseSize, 2, WHITE);
        //----------------------------------------------------------------------------------
    }
}
