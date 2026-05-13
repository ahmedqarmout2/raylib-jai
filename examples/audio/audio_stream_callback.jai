#import "raylib";
#import "Basic";
#import "Math";

BUFFER_SIZE :: 4096;
SAMPLE_RATE :: 44100;

// Wave type
WaveType :: enum {
    SINE;
    SQUARE;
    TRIANGLE;
    SAWTOOTH;
};

waveFrequency    : s32 = 440;
newWaveFrequency : s32 = 440;
waveIndex        : s32 = 0;

// Buffer to keep the last second of uploaded audio,
// part of which will be drawn on the screen
buffer            : [SAMPLE_RATE]float;
waveCallbacks     : []AudioCallback = .[ SineCallback, SquareCallback, TriangleCallback, SawtoothCallback ];
waveTypesAsString : []string = .[ "sine", "square", "triangle", "sawtooth" ];

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

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - stream callback");

    InitAudioDevice();

    // Set the number of samples the stream will keep in memory at a time to BUFFER_SIZE
    SetAudioStreamBufferSizeDefault(BUFFER_SIZE);

    // Init raw audio stream (sample rate: 44100, sample size: 32bit-float, channels: 1-mono)
    stream: AudioStream = LoadAudioStream(SAMPLE_RATE, 32, 1);
    PlayAudioStream(stream);

    // Configure it so that waveCallbacks[waveType] is called whenever stream is out of samples
    waveType: WaveType = .SINE;
    SetAudioStreamCallback(stream, waveCallbacks[waveType]);

    SetTargetFPS(30);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_UP))
        {
            newWaveFrequency += 10;
            if (newWaveFrequency > 12500) newWaveFrequency = 12500;
        }

        if (IsKeyDown(.KEY_DOWN))
        {
            newWaveFrequency -= 10;
            if (newWaveFrequency < 20) newWaveFrequency = 20;
        }

        if (IsKeyPressed(.KEY_LEFT))
        {
            if (waveType == .SINE) waveType = .SAWTOOTH;
            else if (waveType == .SQUARE) waveType = .SINE;
            else if (waveType == .TRIANGLE) waveType = .SQUARE;
            else waveType = .TRIANGLE;

            SetAudioStreamCallback(stream, waveCallbacks[waveType]);
        }

        if (IsKeyPressed(.KEY_RIGHT))
        {
            if (waveType == .SINE) waveType = .SQUARE;
            else if (waveType == .SQUARE) waveType = .TRIANGLE;
            else if (waveType == .TRIANGLE) waveType = .SAWTOOTH;
            else waveType = .SINE;

            SetAudioStreamCallback(stream, waveCallbacks[waveType]);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);
            DrawText(TextFormat("frequency: %i", newWaveFrequency), screenWidth - 220, 10, 20, RED);
            DrawText(TextFormat("wave type: %s", get_c_string(waveTypesAsString[waveType])), screenWidth - 220, 30, 20, RED);
            DrawText("Up/down to change frequency", 10, 10, 20, DARKGRAY);
            DrawText("Left/right to change wave type", 10, 30, 20, DARKGRAY);

            // Draw the last 10 ms of uploaded audio
            for i: 0..screenWidth-1
            {
                startIdx : s32 = cast(s32) Clamp(SAMPLE_RATE - SAMPLE_RATE/100.0 + i*SAMPLE_RATE/100/screenWidth, 0.0, SAMPLE_RATE-1.0);
                endIdx   : s32 = cast(s32) Clamp(SAMPLE_RATE - SAMPLE_RATE/100.0 + (i + 1)*SAMPLE_RATE/100/screenWidth, 0.0, SAMPLE_RATE-1.0);

                startPos := Vector2.{ i * 1.0, 250 - 50*buffer[startIdx] };
                endPos   := Vector2.{ i + 1.0, 250 - 50*buffer[endIdx] };
                DrawLineV(startPos, endPos, RED);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadAudioStream(stream);  // Close raw audio stream and delete buffers from RAM
    CloseAudioDevice();         // Close audio device (music streaming is automatically stopped)

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
SineCallback :: (framesOut: *void, frameCount: u32) #c_call
{
    new_context: #Context;
    push_context new_context {
        wavelength: s32 = SAMPLE_RATE/waveFrequency;

        // Synthesize the sine wave
        for i: 0..frameCount-1
        {
            (cast(*float)framesOut)[i] = sin(2*PI*waveIndex/wavelength);

            waveIndex += 1;

            if (waveIndex >= wavelength)
            {
                waveFrequency = newWaveFrequency;
                waveIndex = 0;
            }
        }

        // Save the synthesized samples for later drawing
        for i: 0..(SAMPLE_RATE - frameCount)-1 buffer[i] = buffer[i + frameCount];
        for i: 0..frameCount-1 buffer[SAMPLE_RATE - frameCount + i] = (cast(*float)framesOut)[i];
    }
}

SquareCallback :: (framesOut: *void, frameCount: u32) #c_call
{
    new_context: #Context;
    push_context new_context {
        wavelength: s32 = SAMPLE_RATE/waveFrequency;

        // Synthesize the square wave
        for i: 0..frameCount-1
        {
            (cast(*float)framesOut)[i] = ifx (waveIndex < wavelength/2) then 1.0 else -1.0;
            waveIndex += 1;

            if (waveIndex >= wavelength)
            {
                waveFrequency = newWaveFrequency;
                waveIndex = 0;
            }
        }

        // Save the synthesized samples for later drawing
        for i: 0..(SAMPLE_RATE - frameCount)-1 buffer[i] = buffer[i + frameCount];
        for i: 0..frameCount-1 buffer[SAMPLE_RATE - frameCount + i] = (cast(*float)framesOut)[i];
    }
}

TriangleCallback :: (framesOut: *void, frameCount: u32) #c_call
{
    new_context: #Context;
    push_context new_context {
        wavelength: s32 = SAMPLE_RATE/waveFrequency;

        // Synthesize the triangle wave
        for i: 0..frameCount-1
        {
            (cast(*float)framesOut)[i] = ifx (waveIndex < wavelength/2) then (-1 + 2.0*waveIndex/(wavelength/2)) else (1 - 2.0*(waveIndex - wavelength/2)/(wavelength/2));
            waveIndex += 1;

            if (waveIndex >= wavelength)
            {
                waveFrequency = newWaveFrequency;
                waveIndex = 0;
            }
        }

        // Save the synthesized samples for later drawing
        for i: 0..(SAMPLE_RATE - frameCount)-1 buffer[i] = buffer[i + frameCount];
        for i: 0..frameCount-1 buffer[SAMPLE_RATE - frameCount + i] = (cast(*float)framesOut)[i];
    }
}

SawtoothCallback :: (framesOut: *void, frameCount: u32) #c_call
{
    new_context: #Context;
    push_context new_context {
        wavelength: s32 = SAMPLE_RATE/waveFrequency;

        // Synthesize the sawtooth wave
        for i: 0..frameCount-1
        {
            (cast(*float)framesOut)[i] = -1 + 2.0*waveIndex/wavelength;
            waveIndex += 1;

            if (waveIndex >= wavelength)
            {
                waveFrequency = newWaveFrequency;
                waveIndex = 0;
            }
        }

        // Save the synthesized samples for later drawing
        for i: 0..(SAMPLE_RATE - frameCount)-1 buffer[i] = buffer[i + frameCount];
        for i: 0..frameCount-1 buffer[SAMPLE_RATE - frameCount + i] = (cast(*float)framesOut)[i];
    }
}
