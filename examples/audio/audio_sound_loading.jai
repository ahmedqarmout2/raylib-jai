#import "raylib";
#import "Basic";

main :: () {
    screenWidth  :: 800;
    screenHeight :: 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound loading and playing");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    InitAudioDevice();            // Initialize audio device
    defer CloseAudioDevice();     // Close audio device

    set_working_directory(#filepath);

    fxWav := LoadSound("resources/sound.wav");         // Load WAV audio file
    defer UnloadSound(fxWav);                          // Unload sound data

    fxOgg := LoadSound("resources/target.ogg");        // Load OGG audio file
    defer UnloadSound(fxOgg);                          // Unload sound data

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) PlaySound(fxWav);      // Play WAV sound
        if (IsKeyPressed(.KEY_ENTER)) PlaySound(fxOgg);      // Play OGG sound
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Press SPACE to PLAY the WAV sound!", 200, 180, 20, LIGHTGRAY);
            DrawText("Press ENTER to PLAY the OGG sound!", 200, 220, 20, LIGHTGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}