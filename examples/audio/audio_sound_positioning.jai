#import "raylib";
#import "Basic";
#import "Math";

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

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - sound positioning");

    InitAudioDevice();

    sound: Sound = LoadSound("resources/coin.wav");

    camera := Camera.{
        position = Vector3.{ 0, 5, 5 },
        target = Vector3.{ 0, 0, 0 },
        up = Vector3.{ 0, 1, 0 },
        fovy = 60,
        projection = .CAMERA_PERSPECTIVE
    };

    DisableCursor();

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE);

        th := cast(float)GetTime();

        spherePos := Vector3.{
            x = 5.0*cos(th),
            y = 0.0,
            z = 5.0*sin(th)
        };

        SetSoundPosition(camera, sound, spherePos, 1.0);

        if (!IsSoundPlaying(sound)) PlaySound(sound);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                DrawGrid(10, 2);
                DrawSphere(spherePos, 0.5, RED);
            EndMode3D();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadSound(sound);
    CloseAudioDevice();     // Close audio device

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
// Set sound 3d position
SetSoundPosition :: (listener: Camera, sound: Sound, position: Vector3, maxDist: float)
{
    // Calculate direction vector and distance between listener and sound source
    direction: Vector3 = Vector3Subtract(position, listener.position);
    distance: float = Vector3Length(direction);

    // Apply logarithmic distance attenuation and clamp between 0-1
    attenuation: float = 1.0/(1.0 + (distance/maxDist));
    attenuation = Clamp(attenuation, 0.0, 1.0);

    // Calculate normalized vectors for spatial positioning
    normalizedDirection: Vector3 = Vector3Normalize(direction);
    forward: Vector3 = Vector3Normalize(Vector3Subtract(listener.target, listener.position));
    right: Vector3 = Vector3Normalize(Vector3CrossProduct(listener.up, forward));

    // Reduce volume for sounds behind the listener
    dotProduct: float = Vector3DotProduct(forward, normalizedDirection);
    if (dotProduct < 0.0) attenuation *= (1.0 + dotProduct*0.5);

    // Set stereo panning based on sound position relative to listener
    pan: float = 0.5 + 0.5*Vector3DotProduct(normalizedDirection, right);

    // Apply final sound properties
    SetSoundVolume(sound, attenuation);
    SetSoundPan(sound, pan);
}
