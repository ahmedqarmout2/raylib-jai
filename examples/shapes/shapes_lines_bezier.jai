#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - cubic-bezier lines");

    startPoint: Vector2 = .{ 30, 30 };
    endPoint: Vector2 = .{ cast(float)screenWidth - 30, cast(float)screenHeight - 30 };
    moveStartPoint: bool = false;
    moveEndPoint: bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mouse: Vector2 = GetMousePosition();

        if (CheckCollisionPointCircle(mouse, startPoint, 10.0) && IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) moveStartPoint = true;
        else if (CheckCollisionPointCircle(mouse, endPoint, 10.0) && IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) moveEndPoint = true;

        if (moveStartPoint)
        {
            startPoint = mouse;
            if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) moveStartPoint = false;
        }

        if (moveEndPoint)
        {
            endPoint = mouse;
            if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) moveEndPoint = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("MOVE START-END POINTS WITH MOUSE", 15, 20, 20, GRAY);

            // Draw line Cubic Bezier, in-out interpolation (easing), no control points
            DrawLineBezier(startPoint, endPoint, 4.0, BLUE);
            
            // Draw start-end spline circles with some details
            DrawCircleV(startPoint, ifx CheckCollisionPointCircle(mouse, startPoint, 10.0) then 14.0 else 8.0, ifx moveStartPoint then RED else BLUE);
            DrawCircleV(endPoint, ifx CheckCollisionPointCircle(mouse, endPoint, 10.0) then 14.0 else 8.0, ifx moveEndPoint then RED else BLUE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
