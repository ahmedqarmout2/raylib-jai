#import "raylib";
#import "Basic";
#import "Math";

// Define the maximum number of positions to store in the trail
MAX_TRAIL_LENGTH :: 30;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - mouse trail");

    // Array to store the history of mouse positions (our fixed-size queue)
    trailPositions: [MAX_TRAIL_LENGTH]Vector2;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePosition: Vector2 = GetMousePosition();

        // Shift all existing positions backward by one slot in the array
        // The last element (the oldest position) is dropped
        for < i: 1..MAX_TRAIL_LENGTH - 1
        {
            trailPositions[i] = trailPositions[i - 1];
        }

        // Store the new, current mouse position at the start of the array (Index 0)
        trailPositions[0] = mousePosition;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(BLACK);

            // Draw the trail by looping through the history array
            for i: 0..MAX_TRAIL_LENGTH-1
            {
                // Ensure we skip drawing if the array hasn't been fully filled on startup
                if ((trailPositions[i].x != 0.0) || (trailPositions[i].y != 0.0))
                {
                    // Calculate relative trail strength (ratio is near 1.0 for new, near 0.0 for old)
                    ratio: float = cast(float)(MAX_TRAIL_LENGTH - i)/MAX_TRAIL_LENGTH;

                    // Fade effect: oldest positions are more transparent
                    // Fade (color, alpha) - alpha is 0.5 to 1.0 based on ratio
                    trailColor: Color = Fade(SKYBLUE, ratio*0.5 + 0.5);

                    // Size effect: oldest positions are smaller
                    trailRadius: float = 15.0*ratio;

                    DrawCircleV(trailPositions[i], trailRadius, trailColor);
                }
            }

            // Draw a distinct white circle for the current mouse position (Index 0)
            DrawCircleV(mousePosition, 15.0, WHITE);

            DrawText("Move the mouse to see the trail effect!", 10, screenHeight - 30, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();         // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}