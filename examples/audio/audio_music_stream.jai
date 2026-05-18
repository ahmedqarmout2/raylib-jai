#import "raylib";
#import "Basic";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - music stream");

    InitAudioDevice();              // Initialize audio device

    music: Music = LoadMusicStream("resources/country.mp3");

    PlayMusicStream(music);

    timePlayed: float = 0.0;        // Time played normalized [0.0f..1.0f]
    pause: bool = false;             // Music playing paused

    pan: float = 0.0;               // Default audio pan center [-1.0f..1.0f]
    SetMusicPan(music, pan);

    volume: float = 0.8;            // Default audio volume [0.0f..1.0f]
    SetMusicVolume(music, volume);

    SetTargetFPS(30);               // Set our game to run at 30 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateMusicStream(music);   // Update music buffer with new stream data

        // Restart music playing (stop and play)
        if (IsKeyPressed(.KEY_SPACE))
        {
            StopMusicStream(music);
            PlayMusicStream(music);
        }

        // Pause/Resume music playing
        if (IsKeyPressed(.KEY_P))
        {
            pause = !pause;

            if (pause) PauseMusicStream(music);
            else ResumeMusicStream(music);
        }

        // Set audio pan
        if (IsKeyDown(.KEY_LEFT))
        {
            pan -= 0.05;
            if (pan < -1.0) pan = -1.0;
            SetMusicPan(music, pan);
        }
        else if (IsKeyDown(.KEY_RIGHT))
        {
            pan += 0.05;
            if (pan > 1.0) pan = 1.0;
            SetMusicPan(music, pan);
        }

        // Set audio volume
        if (IsKeyDown(.KEY_DOWN))
        {
            volume -= 0.05;
            if (volume < 0.0) volume = 0.0;
            SetMusicVolume(music, volume);
        }
        else if (IsKeyDown(.KEY_UP))
        {
            volume += 0.05;
            if (volume > 1.0) volume = 1.0;
            SetMusicVolume(music, volume);
        }

        // Get normalized time played for current music stream
        timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music);

        if (timePlayed > 1.0) timePlayed = 1.0;   // Make sure time played is no longer than music
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY);

            DrawText("LEFT-RIGHT for PAN CONTROL", 320, 74, 10, DARKBLUE);
            DrawRectangle(300, 100, 200, 12, LIGHTGRAY);
            DrawRectangleLines(300, 100, 200, 12, GRAY);
            DrawRectangle(cast(s32)(300 + (pan + 1.0)/2.0*200 - 5), 92, 10, 28, DARKGRAY);

            DrawRectangle(200, 200, 400, 12, LIGHTGRAY);
            DrawRectangle(200, 200, cast(s32)(timePlayed*400.0), 12, MAROON);
            DrawRectangleLines(200, 200, 400, 12, GRAY);

            DrawText("PRESS SPACE TO RESTART MUSIC", 215, 250, 20, LIGHTGRAY);
            DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, LIGHTGRAY);

            DrawText("UP-DOWN for VOLUME CONTROL", 320, 334, 10, DARKGREEN);
            DrawRectangle(300, 360, 200, 12, LIGHTGRAY);
            DrawRectangleLines(300, 360, 200, 12, GRAY);
            DrawRectangle(cast(s32)(300 + volume*200 - 5), 352, 10, 28, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadMusicStream(music);   // Unload music stream buffers from RAM

    CloseAudioDevice();         // Close audio device (music streaming is automatically stopped)

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}