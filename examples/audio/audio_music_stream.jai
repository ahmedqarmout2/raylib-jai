#import "raylib";
#import "Basic";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - music playing (streaming)");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    InitAudioDevice();             // Initialize audio device
    defer CloseAudioDevice();      // Close audio device (music streaming is automatically stopped)

    set_working_directory(#filepath);
    music : Music = LoadMusicStream("resources/country.mp3");
    defer UnloadMusicStream(music);   // Unload music stream buffers from RAM

    PlayMusicStream(music);

    timePlayed : float = 0.0;             // Time played normalized [0.0..1.0]
    pause      : bool  = false;           // Music playing paused

    SetTargetFPS(30);              // Set our game to run at 30 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateMusicStream(music);   // Update music buffer with new stream data
        
        // Restart music playing (stop and play)
        if (IsKeyPressed(.KEY_SPACE)) {
            StopMusicStream(music);
            PlayMusicStream(music);
        }

        // Pause/Resume music playing
        if (IsKeyPressed(.KEY_P)) {
            pause = !pause;

            if (pause) PauseMusicStream(music);
            else ResumeMusicStream(music);
        }

        // Get normalized time played for current music stream
        timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music);

        if (timePlayed > 1.0) timePlayed = 1.0;   // Make sure time played is no longer than music
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY);

            DrawRectangle(200, 200, 400, 12, LIGHTGRAY);
            DrawRectangle(200, 200, cast(s32)(timePlayed*400.0), 12, MAROON);
            DrawRectangleLines(200, 200, 400, 12, GRAY);

            DrawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY);
            DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}