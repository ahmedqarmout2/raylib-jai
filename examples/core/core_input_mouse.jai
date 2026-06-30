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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse");

    ballPosition : Vector2 = .{ -100.0, -100.0 };
    ballColor    : Color   = DARKBLUE;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_H))
        {
            if (IsCursorHidden()) ShowCursor();
            else HideCursor();
        }

        ballPosition = GetMousePosition();

        if      (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))    ballColor = MAROON;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_MIDDLE))  ballColor = LIME;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT))   ballColor = DARKBLUE;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_SIDE))    ballColor = PURPLE;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_EXTRA))   ballColor = YELLOW;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_FORWARD)) ballColor = ORANGE;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_BACK))    ballColor = BEIGE;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawCircleV(ballPosition, 40, ballColor);

            DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, DARKGRAY);
            DrawText("Press 'H' to toggle cursor visibility", 10, 30, 20, DARKGRAY);

            if (IsCursorHidden()) DrawText("CURSOR HIDDEN", 20, 60, 20, RED);
            else DrawText("CURSOR VISIBLE", 20, 60, 20, LIME);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}