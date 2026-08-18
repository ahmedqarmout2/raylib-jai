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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - delta time");

    currentFps: s32 = 60;

    // Store the position for the both of the circles
    deltaCircle: Vector2 = .{ 0, cast(float)screenHeight/3.0 };
    frameCircle: Vector2 = .{ 0, cast(float)screenHeight*(2.0/3.0) };

    // The speed applied to both circles
    speed : float : 10.0;
    circleRadius : float : 32.0;

    SetTargetFPS(currentFps);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Adjust the FPS target based on the mouse wheel
        mouseWheel: float = GetMouseWheelMove();
        if (mouseWheel != 0)
        {
            currentFps += cast(s32)mouseWheel;
            if (currentFps < 0) currentFps = 0;
            SetTargetFPS(currentFps);
        }

        // GetFrameTime() returns the time it took to draw the last frame, in seconds (usually called delta time)
        // Uses the delta time to make the circle look like it's moving at a "consistent" speed regardless of FPS

        // Multiply by 6.0 (an arbitrary value) in order to make the speed
        // visually closer to the other circle (at 60 fps), for comparison
        deltaCircle.x += GetFrameTime()*6.0*speed;
        // This circle can move faster or slower visually depending on the FPS
        frameCircle.x += 0.1*speed;

        // If either circle is off the screen, reset it back to the start
        if (deltaCircle.x > screenWidth * 1.0) deltaCircle.x = 0;
        if (frameCircle.x > screenWidth * 1.0) frameCircle.x = 0;

        // Reset both circles positions
        if (IsKeyPressed(.KEY_R))
        {
            deltaCircle.x = 0;
            frameCircle.x = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw both circles to the screen
            DrawCircleV(deltaCircle, circleRadius, RED);
            DrawCircleV(frameCircle, circleRadius, BLUE);

            // Draw the help text
            // Determine what help text to show depending on the current FPS target
            fpsText: *u8;
            if (currentFps <= 0) fpsText = TextFormat("FPS: unlimited (%i)", GetFPS());
            else fpsText = TextFormat("FPS: %i (target: %i)", GetFPS(), currentFps);
            DrawText(fpsText, 10, 10, 20, DARKGRAY);
            DrawText(TextFormat("Frame time: %02.02f ms", GetFrameTime()), 10, 30, 20, DARKGRAY);
            DrawText("Use the scroll wheel to change the fps limit, r to reset", 10, 50, 20, DARKGRAY);

            // Draw the text above the circles
            DrawText("FUNC: x += GetFrameTime()*speed", 10, 90, 20, RED);
            DrawText("FUNC: x += speed", 10, 240, 20, BLUE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}