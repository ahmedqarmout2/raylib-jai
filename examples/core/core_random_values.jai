#import "raylib";
#import "Basic";

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - generate random values");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    randValue     : s32 = GetRandomValue(-8, 5);   // Get a random integer number between -8 and 5 (both included)
    framesCounter : u32 = 0; // Variable used to count frames

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        framesCounter += 1;

        // Every two seconds (120 frames) a new random value is generated
        if (((framesCounter/120)%2) == 1)
        {
            randValue     = GetRandomValue(-8, 5);
            framesCounter = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("Every 2 seconds a new random value is generated:", 130, 100, 20, MAROON);

        DrawText(TextFormat("%i", randValue), 360, 180, 80, LIGHTGRAY);
        //----------------------------------------------------------------------------------
    }
}