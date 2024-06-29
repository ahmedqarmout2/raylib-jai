#import "raylib";
#import "Basic";

delayBuffer: *float;
delayBufferSize : u32 = 0;
delayReadIndex  : u32 = 2;
delayWriteIndex : u32 = 0;

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - stream effects");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    InitAudioDevice();             // Initialize audio device

    set_working_directory(#filepath);
    music : Music = LoadMusicStream("resources/country.mp3");

    // Allocate buffer for the delay effect
    delayBufferSize = 48000*2;     // 1 second delay (device sampleRate*channels)
    delayBuffer = cast(*float)alloc(delayBufferSize * size_of(float));

    PlayMusicStream(music);

    timePlayed : float = 0.0;          // Time played normalized [0.0f..1.0f]
    pause      : bool  = false;             // Music playing paused
    
    enableEffectLPF   : bool = false; // Enable effect low-pass-filter
    enableEffectDelay : bool = false; // Enable effect delay (1 second)

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

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

        // Add/Remove effect: lowpass filter
        if (IsKeyPressed(.KEY_F)) {
            enableEffectLPF = !enableEffectLPF;
            if (enableEffectLPF) AttachAudioStreamProcessor(music.stream, AudioProcessEffectLPF);
            else DetachAudioStreamProcessor(music.stream, AudioProcessEffectLPF);
        }

        // Add/Remove effect: delay
        if (IsKeyPressed(.KEY_D)) {
            enableEffectDelay = !enableEffectDelay;
            if (enableEffectDelay) AttachAudioStreamProcessor(music.stream, AudioProcessEffectDelay);
            else DetachAudioStreamProcessor(music.stream, AudioProcessEffectDelay);
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

            DrawText("MUSIC SHOULD BE PLAYING!", 245, 150, 20, LIGHTGRAY);

            DrawRectangle(200, 180, 400, 12, LIGHTGRAY);
            DrawRectangle(200, 180, cast(s32)(timePlayed*400.0), 12, MAROON);
            DrawRectangleLines(200, 180, 400, 12, GRAY);

            DrawText("PRESS SPACE TO RESTART MUSIC", 215, 230, 20, LIGHTGRAY);
            DrawText("PRESS P TO PAUSE/RESUME MUSIC", 208, 260, 20, LIGHTGRAY);
            
            t1 : *u8 = to_c_string(ifx enableEffectLPF then "ON" else "OFF");
            defer free(t1);
            DrawText(TextFormat("PRESS F TO TOGGLE LPF EFFECT: %s", t1), 200, 320, 20, GRAY);

            t2 : *u8 = to_c_string(ifx enableEffectDelay then "ON" else "OFF");
            defer free(t2);
            DrawText(TextFormat("PRESS D TO TOGGLE DELAY EFFECT: %s", t2), 180, 350, 20, GRAY);
        }
        //----------------------------------------------------------------------------------
    }
}


//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
// Audio effect: lowpass filter
AudioProcessEffectLPF :: (buffer: *void, frames: u32) #c_call {
    low: [2]float = .[ 0.0, 0.0 ];
    
    cutoff : float : 70.0 / 44100.0; // 70 Hz lowpass filter
    k      : float : cast(float)(cutoff / (cutoff + 0.1591549431)); // RC filter formula

    _buffer: *float = cast(*float)buffer;

    i : u32 = 0;
    while (i < frames*2) {
        defer i += 2;

        l: float = _buffer[i];
        r: float = _buffer[i + 1];
        low[0] += k * (l - low[0]);
        low[1] += k * (r - low[1]);
        _buffer[i]     = low[0];
        _buffer[i + 1] = low[1];
    }
}

// Audio effect: delay
AudioProcessEffectDelay :: (buffer: *void, frames: u32) #c_call {
    _buffer: *float = cast(*float)buffer;

    i : u32 = 0;
    while (i < frames*2) {
        defer i += 2;

        leftDelay : float = delayBuffer[delayReadIndex];    // ERROR: Reading buffer -> WHY??? Maybe thread related???
        delayReadIndex += 1;

        rightDelay : float = delayBuffer[delayReadIndex];
        delayReadIndex += 1;

        if (delayReadIndex == delayBufferSize) delayReadIndex = 0;

        _buffer[i]     = 0.5*_buffer[i]     + 0.5*leftDelay;
        _buffer[i + 1] = 0.5*_buffer[i + 1] + 0.5*rightDelay;

        delayBuffer[delayWriteIndex] = _buffer[i];
        delayWriteIndex += 1;

        delayBuffer[delayWriteIndex] = _buffer[i + 1];
        delayWriteIndex += 1;

        if (delayWriteIndex == delayBufferSize) delayWriteIndex = 0;
    }
}