#import "raylib";
#import "Basic";
#import "Math";

MOUSE_SCALE_MARK_SIZE :: 12;

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rectangle scaling mouse");

    rec: Rectangle = .{ 100, 100, 200, 80 };

    mousePosition: Vector2;

    mouseScaleReady : bool = false;
    mouseScaleMode  : bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePosition = GetMousePosition();

        if (CheckCollisionPointRec(mousePosition, Rectangle.{ rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE, MOUSE_SCALE_MARK_SIZE }))
        {
            mouseScaleReady = true;
            if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) mouseScaleMode = true;
        }
        else mouseScaleReady = false;

        if (mouseScaleMode)
        {
            mouseScaleReady = true;

            rec.width = (mousePosition.x - rec.x);
            rec.height = (mousePosition.y - rec.y);

            // Check minimum rec size
            if (rec.width < MOUSE_SCALE_MARK_SIZE) rec.width = MOUSE_SCALE_MARK_SIZE;
            if (rec.height < MOUSE_SCALE_MARK_SIZE) rec.height = MOUSE_SCALE_MARK_SIZE;
            
            // Check maximum rec size
            if (rec.width > (GetScreenWidth() - rec.x)) rec.width = GetScreenWidth() - rec.x;
            if (rec.height > (GetScreenHeight() - rec.y)) rec.height = GetScreenHeight() - rec.y;

            if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) mouseScaleMode = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Scale rectangle dragging from bottom-right corner!", 10, 10, 20, GRAY);

            DrawRectangleRec(rec, Fade(GREEN, 0.5));

            if (mouseScaleReady)
            {
                DrawRectangleLinesEx(rec, 1, RED);
                DrawTriangle(Vector2.{ rec.x + rec.width - MOUSE_SCALE_MARK_SIZE, rec.y + rec.height },
                             Vector2.{ rec.x + rec.width, rec.y + rec.height },
                             Vector2.{ rec.x + rec.width, rec.y + rec.height - MOUSE_SCALE_MARK_SIZE }, RED);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
