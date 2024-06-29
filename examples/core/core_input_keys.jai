#import "raylib";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    ballPosition : Vector2 = .{ cast(float)screenWidth/2, cast(float)screenHeight/2 };

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_RIGHT)) ballPosition.x += 2.0;
        if (IsKeyDown(.KEY_LEFT))  ballPosition.x -= 2.0;
        if (IsKeyDown(.KEY_UP))    ballPosition.y -= 2.0;
        if (IsKeyDown(.KEY_DOWN))  ballPosition.y += 2.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("move the ball with arrow keys", 10, 10, 20, DARKGRAY);

        DrawCircleV(ballPosition, 50, MAROON);
        //----------------------------------------------------------------------------------
    }
}