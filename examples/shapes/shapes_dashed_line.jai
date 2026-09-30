#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - dashed line");

    // Line Properties
    lineStartPosition: Vector2 = .{ 20.0, 50.0 };
    lineEndPosition: Vector2 = .{ 780.0, 400.0 };
    dashLength: float = 25.0;
    blankLength: float = 15.0;

    // Color selection
    lineColors: [8]Color = .[ RED, ORANGE, GOLD, GREEN, BLUE, VIOLET, PINK, BLACK ];
    colorIndex: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        lineEndPosition = GetMousePosition(); // Line endpoint follows the mouse

        // Change Dash Length (UP/DOWN arrows)
        if (IsKeyDown(.KEY_UP)) dashLength += 1.0;
        if (IsKeyDown(.KEY_DOWN) && dashLength > 1.0) dashLength -= 1.0;

        // Change Space Length (LEFT/RIGHT arrows)
        if (IsKeyDown(.KEY_RIGHT)) blankLength += 1.0;
        if (IsKeyDown(.KEY_LEFT) && blankLength > 1.0) blankLength -= 1.0;

        // Cycle through colors ('C' key)
        if (IsKeyPressed(.KEY_C)) colorIndex = (colorIndex + 1)%(lineColors.count);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw the dashed line with the current properties
            DrawLineDashed(lineStartPosition, lineEndPosition, cast(s32)dashLength, cast(s32)blankLength, lineColors[colorIndex]);

            // Draw UI and Instructions
            DrawRectangle(5, 5, 265, 95, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(5, 5, 265, 95, BLUE);

            DrawText("CONTROLS:", 15, 15, 10, BLACK);
            DrawText("UP/DOWN: Change Dash Length", 15, 35, 10, BLACK);
            DrawText("LEFT/RIGHT: Change Space Length", 15, 55, 10, BLACK);
            DrawText("C: Cycle Color", 15, 75, 10, BLACK);

            DrawText(TextFormat("Dash: %.0 | Space: %.0", dashLength, blankLength), 15, 115, 10, DARKGRAY);

            DrawFPS(screenWidth - 80, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}