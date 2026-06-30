#import "raylib";
#import "Basic";

MAX_SOUNDS : s32 : 10;

soundArray   : [MAX_SOUNDS]Sound;
currentSound : s32;

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

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound multi");

    InitAudioDevice();      // Initialize audio device

    // Load audio file into the first slot as the 'source' sound,
    // this sound owns the sample data
    soundArray[0] = LoadSound("resources/sound.wav");

    // Load an alias of the sound into slots 1-9. These do not own the sound data, but can be played
    for i: 1..MAX_SOUNDS-1 soundArray[i] = LoadSoundAlias(soundArray[0]);

    currentSound = 0;               // Set the sound list to the start

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE))
        {
            PlaySound(soundArray[currentSound]);    // Play the next open sound slot
            currentSound += 1;                      // Increment the sound slot

            // If the sound slot is out of bounds, go back to 0
            if (currentSound >= MAX_SOUNDS) currentSound = 0;

            // NOTE: Another approach would be to look at the list for the first sound
            // that is not playing and use that slot
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Press SPACE to PLAY a WAV sound!", 200, 180, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 1..MAX_SOUNDS-1 UnloadSoundAlias(soundArray[i]); // Unload sound aliases
    UnloadSound(soundArray[0]); // Unload source sound data

    CloseAudioDevice();     // Close audio device

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}