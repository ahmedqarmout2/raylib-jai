#import "raylib";
#import "Basic";
#import "Math";

exponent: float = 1.0;       // Audio exponentiation value
averageVolume: [400]float;   // Average volume history

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - processing mixed output");
    //--------------------------------------------------------------------------------------

    InitAudioDevice();              // Initialize audio device

    AttachAudioMixedProcessor(ProcessAudio);

    set_working_directory(#filepath);
    music: Music = LoadMusicStream("resources/country.mp3");
    sound: Sound = LoadSound("resources/coin.wav");

    PlayMusicStream(music);

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateMusicStream(music);   // Update music buffer with new stream data

        // Modify processing variables
        if (IsKeyPressed(.KEY_LEFT))  exponent -= 0.05;
        if (IsKeyPressed(.KEY_RIGHT)) exponent += 0.05;

        if (exponent <= 0.5) exponent = 0.5;
        if (exponent >= 3.0) exponent = 3.0;

        if (IsKeyPressed(.KEY_SPACE)) PlaySound(sound);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY);

        DrawText(TextFormat("EXPONENT = %.2f", exponent), 215, 180, 20, LIGHTGRAY);

        DrawRectangle(199, 199, 402, 34, LIGHTGRAY);
        
        i: s32 = 0;
        while (i < 400) {
            defer i += 1;
            DrawLine(201 + i, 232 - cast(s32)averageVolume[i] * 32, 201 + i, 232, MAROON);
        }
        DrawRectangleLines(199, 199, 402, 34, GRAY);

        DrawText("PRESS SPACE TO PLAY OTHER SOUND", 200, 250, 20, LIGHTGRAY);
        DrawText("USE LEFT AND RIGHT ARROWS TO ALTER DISTORTION", 140, 280, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadMusicStream(music);   // Unload music stream buffers from RAM

    DetachAudioMixedProcessor(ProcessAudio);  // Disconnect audio processor

    CloseAudioDevice();         // Close audio device (music streaming is automatically stopped)

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

ProcessAudio :: (buffer: *void, frames: u32) #c_call {
    new_context: Context;
    push_context new_context {
        samples: *float = cast(*float)buffer;   // Samples internally stored as <float>s
        average: float = 0.0;                   // Temporary average volume

        for frame: 0..frames-1 {
            left  : *float = *samples[frame * 2 + 0];
            right : *float = *samples[frame * 2 + 1];

            << left  = pow(abs(<< left), exponent)  * ( ifx (<< left < 0.0)  then -1.0 else 1.0 );
            << right = pow(abs(<< right), exponent) * ( ifx (<< right < 0.0) then -1.0 else 1.0 );

            average += abs(<< left)  / frames;   // accumulating average volume
            average += abs(<< right) / frames;
        }

        // Moving history to the left
        for i: 0..398 {
            averageVolume[i] = averageVolume[i + 1];
        }

        averageVolume[399] = average;         // Adding last average value
    }
}
