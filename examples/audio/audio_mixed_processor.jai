#import "raylib";
#import "Basic";
#import "Math";

exponent: float = 1.0;       // Audio exponentiation value
averageVolume: [400]float;   // Average volume history

main :: () {
    set_working_directory(#filepath);

    // Initialization and De-Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - processing mixed output");
    defer CloseWindow(); // Close window and OpenGL context

    InitAudioDevice();         // Initialize audio device
    defer CloseAudioDevice();  // Close audio device (music streaming is automatically stopped)

    AttachAudioMixedProcessor(ProcessAudio);
    defer DetachAudioMixedProcessor(ProcessAudio);  // Disconnect audio processor

    music: Music = LoadMusicStream("resources/country.mp3");
    defer UnloadMusicStream(music);   // Unload music stream buffers from RAM

    sound: Sound = LoadSound("resources/coin.wav");
    defer UnloadSound(sound);

    PlayMusicStream(music);

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

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
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("MUSIC SHOULD BE PLAYING!", 255, 150, 20, LIGHTGRAY);

        DrawText(TextFormat("EXPONENT = %.2f", exponent), 215, 180, 20, LIGHTGRAY);

        DrawRectangle(199, 199, 402, 34, LIGHTGRAY);
        for 0..399 {
            i := cast(s32)it;
            DrawLine(201 + i, 232 - cast(s32)(averageVolume[i] * 32), 201 + i, 232, MAROON);
        }
        DrawRectangleLines(199, 199, 402, 34, GRAY);

        DrawText("PRESS SPACE TO PLAY OTHER SOUND", 200, 250, 20, LIGHTGRAY);
        DrawText("USE LEFT AND RIGHT ARROWS TO ALTER DISTORTION", 140, 280, 20, LIGHTGRAY);
        //----------------------------------------------------------------------------------
    }
}

ProcessAudio :: (buffer: *void, frames: u32) #c_call {
    new_context: #Context;
    push_context new_context {
        samples: *float = cast(*float)buffer;   // Samples internally stored as <float>s
        average: float = 0.0;                   // Temporary average volume

        for i: 0..frames-1 {
            frame := cast(u32) i;
            left  : *float = *samples[frame * 2 + 0];
            right : *float = *samples[frame * 2 + 1];

            << left  = pow(abs(<< left), exponent)  * (ifx (<< left < 0.0)  then -1.0 else 1.0);
            << right = pow(abs(<< right), exponent) * (ifx (<< right < 0.0) then -1.0 else 1.0);

            average += abs(<< left)  / frames;   // accumulating average volume
            average += abs(<< right) / frames;
        }

        // Moving history to the left
        for i: 0..398 averageVolume[i] = averageVolume[i + 1];

        averageVolume[399] = average;         // Adding last average value
    }
}
