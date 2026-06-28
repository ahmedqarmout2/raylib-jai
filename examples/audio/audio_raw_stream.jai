#import "raylib";
#import "Basic";
#import "Math";

BUFFER_SIZE :: 4096;
SAMPLE_RATE :: 44100;

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

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - raw stream");

    InitAudioDevice();

    // Set the number of samples the stream will keep in memory at a time to BUFFER_SIZE
    SetAudioStreamBufferSizeDefault(BUFFER_SIZE);
    buffer: [BUFFER_SIZE]float;

    // Init raw audio stream (sample rate: 44100, sample size: 32bit-float, channels: 1-mono)
    stream: AudioStream = LoadAudioStream(SAMPLE_RATE, 32, 1);
    pan: float = 0.0;
    SetAudioStreamPan(stream, pan);
    PlayAudioStream(stream);

    sineFrequency: s32 = 440;
    newSineFrequency: s32 = 440;
    sineIndex: s32 = 0;
    sineStartTime: float64 = 0.0;

    SetTargetFPS(30);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        if (IsKeyDown(.KEY_UP))
        {
            newSineFrequency += 10;
            if (newSineFrequency > 12500) newSineFrequency = 12500;
        }

        if (IsKeyDown(.KEY_DOWN))
        {
            newSineFrequency -= 10;
            if (newSineFrequency < 20) newSineFrequency = 20;
        }

        if (IsKeyDown(.KEY_LEFT))
        {
            pan -= 0.01;
            if (pan < -1.0) pan = -1.0;
            SetAudioStreamPan(stream, pan);
        }

        if (IsKeyDown(.KEY_RIGHT))
        {
            pan += 0.01;
            if (pan > 1.0) pan = 1.0;
            SetAudioStreamPan(stream, pan);
        }

        if (IsAudioStreamProcessed(stream))
        {
            for i: 0..BUFFER_SIZE-1
            {
                wavelength: s32 = SAMPLE_RATE/sineFrequency;
                buffer[i] = sin(2*PI*sineIndex/wavelength);
                sineIndex += 1;

                if (sineIndex >= wavelength)
                {
                    sineFrequency = newSineFrequency;
                    sineIndex = 0;
                    sineStartTime = GetTime();
                }
            }

            UpdateAudioStream(stream, buffer.data, BUFFER_SIZE);
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            DrawText(TextFormat("sine frequency: %i", sineFrequency), screenWidth - 220, 10, 20, RED);
            DrawText(TextFormat("pan: %.2f", pan), screenWidth - 220, 30, 20, RED);
            DrawText("Up/down to change frequency", 10, 10, 20, DARKGRAY);
            DrawText("Left/right to pan", 10, 30, 20, DARKGRAY);

            windowStart: s32 = cast(s32)((GetTime() - sineStartTime)*SAMPLE_RATE);
            windowSize: s32 = cast(s32)(0.1*SAMPLE_RATE);
            wavelength: s32 = SAMPLE_RATE/sineFrequency;

            // Draw a sine wave with the same frequency as the one being sent to the audio stream
            for i: 0..screenWidth-1
            {
                t0: s32 = windowStart + i*windowSize/screenWidth;
                t1: s32 = windowStart + (i + 1)*windowSize/screenWidth;
                startPos := Vector2.{ i * 1.0, 250 + 50*sin(2*PI*t0/wavelength) };
                endPos   := Vector2.{ i + 1.0, 250 + 50*sin(2*PI*t1/wavelength) };
                DrawLineV(startPos, endPos, RED);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadAudioStream(stream);   // Close raw audio stream and delete buffers from RAM
    CloseAudioDevice();         // Close audio device (music streaming is automatically stopped)

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
