#import "raylib";
#import "Math";

main :: () {
    screenWidth  :: 800;
    screenHeight :: 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - mouse input");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    ballPosition := Vector2.{ -100.0, -100.0 };
    ballColor    := DARKBLUE;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
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
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawCircleV(ballPosition, 40, ballColor);

        DrawText("move ball with mouse and click mouse button to change color", 10, 10, 20, DARKGRAY);
        //----------------------------------------------------------------------------------
    }
}