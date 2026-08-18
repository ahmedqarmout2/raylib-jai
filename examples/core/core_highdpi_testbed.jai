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

    SetConfigFlags(.FLAG_WINDOW_RESIZABLE | .FLAG_WINDOW_HIGHDPI);
    InitWindow(screenWidth, screenHeight, "raylib [core] example - highdpi testbed");

    scaleDpi: Vector2 = GetWindowScaleDPI();
    mousePos: Vector2 = GetMousePosition();
    currentMonitor: s32 = GetCurrentMonitor();
    windowPos: Vector2  = GetWindowPosition();

    gridSpacing: s32 = 40;   // Grid spacing in pixels

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePos = GetMousePosition();
        currentMonitor = GetCurrentMonitor();
        scaleDpi = GetWindowScaleDPI();
        windowPos = GetWindowPosition();

        if (IsKeyPressed(.KEY_SPACE)) ToggleBorderlessWindowed();
        if (IsKeyPressed(.KEY_F)) ToggleFullscreen();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw grid
            for h: 0..GetScreenHeight()/gridSpacing
            {
                DrawText(TextFormat("%02i", h*gridSpacing), 4, h*gridSpacing - 4, 10, GRAY);
                DrawLine(24, h*gridSpacing, GetScreenWidth(), h*gridSpacing, LIGHTGRAY);
            }
            for v: 0..GetScreenWidth()/gridSpacing
            {
                DrawText(TextFormat("%02i", v*gridSpacing), v*gridSpacing - 10, 4, 10, GRAY);
                DrawLine(v*gridSpacing, 20, v*gridSpacing, GetScreenHeight(), LIGHTGRAY);
            }

            // Draw UI info
            DrawText(TextFormat("CURRENT MONITOR: %i/%i (%ix%i)", currentMonitor + 1, GetMonitorCount(),
                GetMonitorWidth(currentMonitor), GetMonitorHeight(currentMonitor)), 50, 50, 20, DARKGRAY);
            DrawText(TextFormat("WINDOW POSITION: %ix%i", cast(s32)windowPos.x, cast(s32)windowPos.y), 50, 90, 20, DARKGRAY);
            DrawText(TextFormat("SCREEN SIZE: %ix%i", GetScreenWidth(), GetScreenHeight()), 50, 130, 20, DARKGRAY);
            DrawText(TextFormat("RENDER SIZE: %ix%i", GetRenderWidth(), GetRenderHeight()), 50, 170, 20, DARKGRAY);
            DrawText(TextFormat("SCALE FACTOR: %.2fx%.2f", scaleDpi.x, scaleDpi.y), 50, 210, 20, GRAY);

            // Draw reference rectangles, top-left and bottom-right corners
            DrawRectangle(0, 0, 30, 60, RED);
            DrawRectangle(GetScreenWidth() - 30, GetScreenHeight() - 60, 30, 60, BLUE);

            // Draw mouse position
            DrawCircleV(GetMousePosition(), 20, MAROON);
            DrawRectangleRec(Rectangle.{ mousePos.x - 25, mousePos.y, 50, 2 }, BLACK);
            DrawRectangleRec(Rectangle.{ mousePos.x, mousePos.y - 25, 2, 50 }, BLACK);
            DrawText(TextFormat("[%i,%i]", GetMouseX(), GetMouseY()), cast(s32)mousePos.x - 44,
                ifx (mousePos.y > GetScreenHeight() - 60.0) then cast(s32)mousePos.y - 46 else cast(s32)mousePos.y + 30, 20, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    // TODO: Unload all loaded resources at this point

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
