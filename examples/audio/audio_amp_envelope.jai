#import "raylib";
#import "Basic";
#import "Math";

BUFFER_SIZE :: 4096;
SAMPLE_RATE :: 44100;

// Wave state
ADSRState :: enum {
    IDLE;
    ATTACK;
    DECAY;
    SUSTAIN;
    RELEASE;
};

// Grouping all ADSR parameters and state into a struct
Envelope :: struct {
    attackTime   : float;
    decayTime    : float;
    sustainLevel : float;
    releaseTime  : float;
    currentValue : float;
    state        : ADSRState;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - amp envelope");

    InitAudioDevice();

    // Set the number of samples the stream will keep in memory at a time to BUFFER_SIZE
    SetAudioStreamBufferSizeDefault(BUFFER_SIZE);
    buffer : [BUFFER_SIZE]float;

    // Init raw audio stream (sample rate: 44100, sample size: 32bit-float, channels: 1-mono)
    stream: AudioStream = LoadAudioStream(SAMPLE_RATE, 32, 1);

    // Init Phase
    audioTime: float = 0.0;

    // Initialize the struct
    env: Envelope = {
        attackTime = 1.0,
        decayTime = 1.0,
        sustainLevel = 0.5,
        releaseTime = 1.0,
        currentValue = 0.0,
        state = .IDLE
    };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) env.state = .ATTACK;

        if (IsKeyReleased(.KEY_SPACE) && (env.state != .IDLE)) env.state = .RELEASE;

        if (IsAudioStreamProcessed(stream))
        {
            if ((env.state != .IDLE) || (env.currentValue > 0.0))
            {
                for i:0..BUFFER_SIZE-1
                {
                    UpdateEnvelope(*env);
                    FillAudioBuffer(i, buffer, env.currentValue, *audioTime);
                }
            }
            else
            {
                // Clear buffer if silent to avoid looping noise
                for i:0..BUFFER_SIZE-1 buffer[i] = 0;
                audioTime = 0.0;
            }

            UpdateAudioStream(stream, *buffer, BUFFER_SIZE);
        }

        if (!IsAudioStreamPlaying(stream)) PlayAudioStream(stream);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            GuiSliderBar(Rectangle.{ 100, 60, 400, 30 }, "Attack (s)", TextFormat("%2.2fs", env.attackTime), *env.attackTime, 0.1, 3.0);
            GuiSliderBar(Rectangle.{ 100, 100, 400, 30 }, "Decay (s)", TextFormat("%2.2fs", env.decayTime), *env.decayTime, 0.1, 3.0);
            GuiSliderBar(Rectangle.{ 100, 140, 400, 30 }, "Sustain", TextFormat("%2.2f", env.sustainLevel), *env.sustainLevel, 0.0, 1.0);
            GuiSliderBar(Rectangle.{ 100, 180, 400, 30 }, "Release (s)", TextFormat("%2.2fs", env.releaseTime), *env.releaseTime, 0.1, 3.0);

            DrawADSRGraph(*env, Rectangle.{ 100, 250, 400, 100 });

            DrawCircleV(Vector2.{ 520, 350 - (env.currentValue * 100) }, 5, MAROON);
            DrawText(TextFormat("Current Gain: %2.2f", env.currentValue), 535, cast(s32)(345 - (env.currentValue * 100)), 10, MAROON);

            DrawText("Press SPACE to PLAY the sound!", 200, 400, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadAudioStream(stream);
    CloseAudioDevice();

    CloseWindow();
    //--------------------------------------------------------------------------------------

    return;
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
FillAudioBuffer :: (i: int, buffer: []float, envelopeValue: float, audioTime: *float)
{
    frequency: int = 440;
    buffer[i] = envelopeValue*sin(2.0*PI*frequency*((.*)audioTime));
    (.*)audioTime += (1.0/SAMPLE_RATE);
}

UpdateEnvelope :: (env: *Envelope)
{
    // Calculate the time delta for ONE sample (1/44100)
    sampleTime: float = 1.0/SAMPLE_RATE;

    if env.state ==
    {
        case .ATTACK;
        {
            env.currentValue += (1.0/env.attackTime)*sampleTime;
            if (env.currentValue >= 1.0)
            {
                env.currentValue = 1.0;
                env.state = .DECAY;
            }

        }
        case .DECAY;
        {
            env.currentValue -= ((1.0 - env.sustainLevel)/env.decayTime)*sampleTime;
            if (env.currentValue <= env.sustainLevel)
            {
                env.currentValue = env.sustainLevel;
                env.state = .SUSTAIN;
            }

        }
        case .SUSTAIN;
        {
            env.currentValue = env.sustainLevel;

        }
        case .RELEASE;
        {
            env.currentValue -= (env.sustainLevel/env.releaseTime)*sampleTime;
            if (env.currentValue <= 0.001) // Use a small threshold to avoid infinite tail
            {
                env.currentValue = 0.0;
                env.state = .IDLE;
            }

        }
    }
}

DrawADSRGraph :: (env: *Envelope, bounds: Rectangle)
{
    DrawRectangleRec(bounds, Fade(LIGHTGRAY, 0.3));
    DrawRectangleLinesEx(bounds, 1, GRAY);

    // Fixed visual width for sustain stage since it's an amplitude not a time value
    sustainWidth: float = 1.0;

    // Total time to visualize (sum of A, D, R + a padding for Sustain)
    totalTime: float = env.attackTime + env.decayTime + sustainWidth + env.releaseTime;

    scaleX: float = bounds.width/totalTime;
    scaleY: float = bounds.height;

    start := Vector2.{ bounds.x, bounds.y + bounds.height };
    peak := Vector2.{ start.x + (env.attackTime*scaleX), bounds.y };
    sustain := Vector2.{ peak.x + (env.decayTime*scaleX), bounds.y + (1.0 - env.sustainLevel)*scaleY };
    rel := Vector2.{ sustain.x + (sustainWidth*scaleX), sustain.y };
    end := Vector2.{ rel.x + (env.releaseTime*scaleX), bounds.y + bounds.height };

    DrawLineV(start, peak, SKYBLUE);
    DrawLineV(peak, sustain, BLUE);
    DrawLineV(sustain, rel, DARKBLUE);
    DrawLineV(rel, end, ORANGE);

    DrawText("ADSR Visualizer", cast(s32)bounds.x, cast(s32)bounds.y - 20, 10, DARKGRAY);
}
