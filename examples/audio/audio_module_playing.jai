#import "raylib";
#import "Basic";
#import "Math";

MAX_CIRCLES : s32 : 64;

CircleWave :: struct {
    position : Vector2;
    radius   : float;
    alpha    : float;
    speed    : float;
    color    : Color;
};

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // NOTE: Try to enable MSAA 4X

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [audio] example - module playing (streaming)");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    InitAudioDevice();            // Initialize audio device
    defer CloseAudioDevice();     // Close audio device (music streaming is automatically stopped)

    colors: [14]Color = Color.[ ORANGE, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW, GREEN, SKYBLUE, PURPLE, BEIGE ];

    // Creates some circles for visual effect
    circles: [MAX_CIRCLES]CircleWave;

    for < i: MAX_CIRCLES - 1..0 {
        r: s32 = GetRandomValue(10, 40);
        circles[i].alpha      = 0.0;
        circles[i].radius     = cast(float)r;
        circles[i].position.x = cast(float)GetRandomValue(r, screenWidth  - r);
        circles[i].position.y = cast(float)GetRandomValue(r, screenHeight - r);
        circles[i].speed      = GetRandomValue(1, 100)/2000.0;
        circles[i].color      = colors[GetRandomValue(0, 13)];
    }

    set_working_directory(#filepath);
    music: Music = LoadMusicStream("resources/mini1111.xm");
    defer UnloadMusicStream(music);          // Unload music stream buffers from RAM

    music.looping = false; 
    pitch : float = 1.0;

    PlayMusicStream(music);

    timePlayed : float = 0.0;
    pause      : bool  = false;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateMusicStream(music);      // Update music buffer with new stream data

        // Restart music playing (stop and play)
        if (IsKeyPressed(.KEY_SPACE)) {
            StopMusicStream(music);
            PlayMusicStream(music);
            pause = false;
        }

        // Pause/Resume music playing
        if (IsKeyPressed(.KEY_P)) {
            pause = !pause;

            if (pause) PauseMusicStream(music);
            else ResumeMusicStream(music);
        }

        if (IsKeyDown(.KEY_DOWN))    pitch -= 0.01;
        else if (IsKeyDown(.KEY_UP)) pitch += 0.01;

        SetMusicPitch(music, pitch);

        // Get timePlayed scaled to bar dimensions
        timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music)*(screenWidth - 40);

        // Color circles animation
        i: = MAX_CIRCLES - 1;
        while ((i >= 0) && !pause) {
            defer i -= 1;
            circles[i].alpha += circles[i].speed;
            circles[i].radius += circles[i].speed*10.0;

            if (circles[i].alpha > 1.0) circles[i].speed *= -1;

            if (circles[i].alpha <= 0.0) {
                r: s32 = GetRandomValue(10, 40);
                circles[i].alpha      = 0.0;
                circles[i].radius     = cast(float)r;
                circles[i].position.x = cast(float)GetRandomValue(r, screenWidth  - r);
                circles[i].position.y = cast(float)GetRandomValue(r, screenHeight - r);
                circles[i].speed      = GetRandomValue(1, 100)/2000.0;
                circles[i].color      = colors[GetRandomValue(0, 13)];
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            for < i: MAX_CIRCLES - 1..0 {
                DrawCircleV(circles[i].position, circles[i].radius, Fade(circles[i].color, circles[i].alpha));
            }

            // Draw time bar
            DrawRectangle(20, screenHeight - 20 - 12, screenWidth - 40, 12, LIGHTGRAY);
            DrawRectangle(20, screenHeight - 20 - 12, cast(s32)timePlayed, 12, MAROON);
            DrawRectangleLines(20, screenHeight - 20 - 12, screenWidth - 40, 12, GRAY);

            // Draw help instructions
            DrawRectangle(20, 20, 425, 145, WHITE);
            DrawRectangleLines(20, 20, 425, 145, GRAY);
            DrawText("PRESS SPACE TO RESTART MUSIC", 40, 40, 20, BLACK);
            DrawText("PRESS P TO PAUSE/RESUME", 40, 70, 20, BLACK);
            DrawText("PRESS UP/DOWN TO CHANGE SPEED", 40, 100, 20, BLACK);
            DrawText(TextFormat("SPEED: %f", pitch), 40, 130, 20, MAROON);
        }
        //----------------------------------------------------------------------------------
    }
}