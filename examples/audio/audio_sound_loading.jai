#import "raylib";
#import "Basic";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound loading");

    InitAudioDevice();      // Initialize audio device

    fxWav: Sound = LoadSound("resources/sound.wav");         // Load WAV audio file
    fxOgg: Sound = LoadSound("resources/target.ogg");        // Load OGG audio file

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) PlaySound(fxWav);      // Play WAV sound
        if (IsKeyPressed(.KEY_ENTER)) PlaySound(fxOgg);      // Play OGG sound
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Press SPACE to PLAY the WAV sound!", 200, 180, 20, LIGHTGRAY);
            DrawText("Press ENTER to PLAY the OGG sound!", 200, 220, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadSound(fxWav);     // Unload sound data
    UnloadSound(fxOgg);     // Unload sound data

    CloseAudioDevice();     // Close audio device

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}