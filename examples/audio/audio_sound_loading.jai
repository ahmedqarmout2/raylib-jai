#import "raylib";
#import "Basic";

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound loading and playing");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    InitAudioDevice();            // Initialize audio device
    defer CloseAudioDevice();     // Close audio device

    fxWav : Sound = LoadSound("resources/sound.wav");         // Load WAV audio file
    defer UnloadSound(fxWav);                          // Unload sound data

    fxOgg : Sound = LoadSound("resources/target.ogg");        // Load OGG audio file
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