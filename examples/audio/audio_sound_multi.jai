#import "raylib";
#import "Basic";

MAX_SOUNDS : s32 : 10;

soundArray   : [MAX_SOUNDS]Sound;
currentSound : s32;

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - playing sound multiple times");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    InitAudioDevice();            // Initialize audio device
    defer CloseAudioDevice();     // Close audio device

    set_working_directory(#filepath);

    // load the sound list
    soundArray[0] = LoadSound("resources/sound.wav");         // Load WAV audio file into the first slot as the 'source' sound
                                                              // this sound owns the sample data

    for i: 1..MAX_SOUNDS-1 {
        soundArray[i] = LoadSoundAlias(soundArray[0]);        // Load an alias of the sound into slots 1-9. These do not own the sound data, but can be played
    }
    currentSound = 0;   

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) {
            PlaySound(soundArray[currentSound]);            // play the next open sound slot
            currentSound += 1;                              // increment the sound slot
            if (currentSound >= MAX_SOUNDS)                 // if the sound slot is out of bounds, go back to 0
                currentSound = 0;

            // Note: a better way would be to look at the list for the first sound that is not playing and use that slot
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Press SPACE to PLAY a WAV sound!", 200, 180, 20, LIGHTGRAY);
        }
        //----------------------------------------------------------------------------------
    }

    for i: 1..MAX_SOUNDS-1 {
        UnloadSoundAlias(soundArray[i]);     // Unload sound aliases
    }
    UnloadSound(soundArray[0]);              // Unload source sound data
}