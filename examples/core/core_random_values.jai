#import "raylib";
#import "Basic";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - random values");

    // SetRandomSeed(0xaabbccff);   // Set a custom random seed if desired, by default: "time(NULL)"

    randValue     : s32 = GetRandomValue(-8, 5);   // Get a random integer number between -8 and 5 (both included)
    framesCounter : u32 = 0; // Variable used to count frames

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
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

            ClearBackground(RAYWHITE);

            DrawText("Every 2 seconds a new random value is generated:", 130, 100, 20, MAROON);

            DrawText(TextFormat("%i", randValue), 360, 180, 80, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}