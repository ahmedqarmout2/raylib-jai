#import "raylib";
#import "Basic";
#import "Math";

short :: s16;

MAX_SAMPLES            : s32 : 512;
MAX_SAMPLES_PER_UPDATE : s32 : 4096;

// Cycles per second (hz)
frequency: float = 440.0;

// Audio frequency, for smoothing
audioFrequency: float = 440.0;

// Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
oldFrequency: float = 1.0;

// Index for audio rendering
sineIdx: float = 0.0;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - raw audio streaming");
    defer CloseWindow(); // Close window and OpenGL context

    InitAudioDevice();              // Initialize audio device
    defer CloseAudioDevice();         // Close audio device (music streaming is automatically stopped)

    SetAudioStreamBufferSizeDefault(MAX_SAMPLES_PER_UPDATE);

    // Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
    stream : AudioStream = LoadAudioStream(44100, 16, 1);
    defer UnloadAudioStream(stream);  // Close raw audio stream and delete buffers from RAM

    SetAudioStreamCallback(stream, AudioInputCallback);

    // Buffer for the single cycle waveform we are synthesizing
    data: *short = cast(*short)alloc(size_of(short)*MAX_SAMPLES);
    defer free(data);                 // Unload sine wave data

    // Frame buffer, describing the waveform when repeated over the course of a frame
    writeBuf: *short = cast(*short)alloc(size_of(short)*MAX_SAMPLES_PER_UPDATE);
    defer free(writeBuf);             // Unload write buffer

    PlayAudioStream(stream);        // Start processing stream buffer (no data loaded currently)

    // Position read in to determine next frequency
    mousePosition : Vector2 = .{ -100.0, -100.0 };

    /*
    // Cycles per second (hz)
    float frequency = 440.0f;

    // Previous value, used to test if sine needs to be rewritten, and to smoothly modulate frequency
    float oldFrequency = 1.0f;

    // Cursor to read and copy the samples of the sine wave buffer
    int readCursor = 0;
    */

    // Computed size in samples of the sine wave
    waveLength: s32 = 1;

    position : Vector2 = .{ 0.0, 0.0 };

    SetTargetFPS(30);              // Set our game to run at 30 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Sample mouse input.
        mousePosition = GetMousePosition();

        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
            fp: float = cast(float)(mousePosition.y);
            frequency = 40.0 + cast(float)(fp);

            pan: float = cast(float)(mousePosition.x) / cast(float)screenWidth;
            SetAudioStreamPan(stream, pan);
        }

        // Rewrite the sine wave
        // Compute two cycles to allow the buffer padding, simplifying any modulation, resampling, etc.
        if (frequency != oldFrequency) {
            // Compute wavelength. Limit size in both directions.
            //int oldWavelength = waveLength;
            waveLength = cast(s32)(22050/frequency);
            if (waveLength > MAX_SAMPLES/2) waveLength = MAX_SAMPLES/2;
            if (waveLength < 1) waveLength = 1;

            // Write sine wave
            for 0..waveLength*2-1 {
                data[it] = cast(short)(sin(((2 * PI * cast(float)it/waveLength)))*32000);
            }

            // Make sure the rest of the line is flat
            for waveLength*2..MAX_SAMPLES-1 {
                data[it] = cast(short)0;
            }

            // Scale read cursor's position to minimize transition artifacts
            //readCursor = (int)(readCursor * ((float)waveLength / (float)oldWavelength));
            oldFrequency = frequency;
        }

        /*
        // Refill audio stream if required
        if (IsAudioStreamProcessed(stream))
        {
            // Synthesize a buffer that is exactly the requested size
            int writeCursor = 0;

            while (writeCursor < MAX_SAMPLES_PER_UPDATE)
            {
                // Start by trying to write the whole chunk at once
                int writeLength = MAX_SAMPLES_PER_UPDATE-writeCursor;

                // Limit to the maximum readable size
                int readLength = waveLength-readCursor;

                if (writeLength > readLength) writeLength = readLength;

                // Write the slice
                memcpy(writeBuf + writeCursor, data + readCursor, writeLength*sizeof(short));

                // Update cursors and loop audio
                readCursor = (readCursor + writeLength) % waveLength;

                writeCursor += writeLength;
            }

            // Copy finished frame to audio stream
            UpdateAudioStream(stream, writeBuf, MAX_SAMPLES_PER_UPDATE);
        }
        */
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            DrawText(TextFormat("sine frequency: %i", cast(s32)frequency), GetScreenWidth() - 220, 10, 20, RED);
            DrawText("click mouse button to change frequency or pan", 10, 10, 20, DARKGRAY);

            // Draw the current buffer state proportionate to the screen
            for 0..screenWidth-1 {
                position.x = cast(float)it;
                position.y = 250.0 + 50.0*data[it*MAX_SAMPLES/screenWidth]/32000.0;

                DrawPixelV(position, RED);
            }
        }
        //----------------------------------------------------------------------------------
    }
}

// Audio input processing callback
AudioInputCallback :: (buffer: *void, frames: u32) #c_call {
    new_context: #Context;
    push_context new_context {
        audioFrequency = frequency + (audioFrequency - frequency)*0.95;

        incr : float = audioFrequency/44100.0;
        d: *short = cast(*short)buffer;

        i: u32 = 0;
        while (i < frames) {
            defer i += 1;

            d[i] = cast(short)(32000.0*sin(2*PI*sineIdx));
            sineIdx += incr;
            if (sineIdx > 1.0) sineIdx -= 1.0;
        }
    }
}