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

    SetConfigFlags(.FLAG_WINDOW_HIGHDPI | .FLAG_WINDOW_RESIZABLE);
    InitWindow(screenWidth, screenHeight, "raylib [core] example - highdpi demo");
    SetWindowMinSize(450, 450);

    logicalGridDescY: s32 = 120;
    logicalGridLabelY: s32 = logicalGridDescY + 30;
    logicalGridTop: s32 = logicalGridLabelY + 30;
    logicalGridBottom: s32 = logicalGridTop + 80;
    pixelGridTop: s32 = logicalGridBottom - 20;
    pixelGridBottom: s32 = pixelGridTop + 80;
    pixelGridLabelY: s32 = pixelGridBottom + 30;
    pixelGridDescY: s32 = pixelGridLabelY + 30;
    cellSize: s32 = 50;
    cellSizePx: float = cast(float)cellSize;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        monitorCount: s32 = GetMonitorCount();

        if ((monitorCount > 1) && IsKeyPressed(.KEY_N))
        {
            SetWindowMonitor((GetCurrentMonitor() + 1)%monitorCount);
        }

        currentMonitor: s32 = GetCurrentMonitor();
        dpiScale: Vector2 = GetWindowScaleDPI();
        cellSizePx = (cast(float)cellSize)/dpiScale.x;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            windowCenter: s32 = GetScreenWidth()/2;
            DrawTextCenter(TextFormat("Dpi Scale: %f", dpiScale.x), windowCenter, 30, 40, DARKGRAY);
            DrawTextCenter(TextFormat("Monitor: %d/%d ([N] next monitor)", currentMonitor+1, monitorCount), windowCenter, 70, 20, LIGHTGRAY);
            DrawTextCenter(TextFormat("Window is %d \"logical points\" wide", GetScreenWidth()), windowCenter, logicalGridDescY, 20, ORANGE);

            odd: bool = true;
            i: s32 = cellSize;
            while (i < GetScreenWidth())
            {
                defer i += cellSize;
                defer odd = !odd;

                if (odd) DrawRectangle(i, logicalGridTop, cellSize, logicalGridBottom-logicalGridTop, ORANGE);

                DrawTextCenter(TextFormat("%d", i), i, logicalGridLabelY, 10, LIGHTGRAY);
                DrawLine(i, logicalGridLabelY + 10, i, logicalGridBottom, GRAY);
            }

            odd = true;
            minTextSpace: s32 = 30;
            lastTextX: s32 = -minTextSpace;
            i = cellSize;
            while (i < GetScreenWidth())
            {
                defer i += cellSize;
                defer odd = !odd;
                x: s32 = cast(s32)((cast(float)i)/dpiScale.x);
                if (odd) DrawRectangle(x, pixelGridTop, cast(s32)cellSizePx, pixelGridBottom - pixelGridTop, Color.{ 0, 121, 241, 100 });

                DrawLine(x, pixelGridTop, cast(s32)((cast(float)i)/dpiScale.x), pixelGridLabelY - 10, GRAY);

                if ((x - lastTextX) >= minTextSpace)
                {
                    DrawTextCenter(TextFormat("%d", i), x, pixelGridLabelY, 10, LIGHTGRAY);
                    lastTextX = x;
                }
            }

            DrawTextCenter(TextFormat("Window is %d \"physical pixels\" wide", GetRenderWidth()), windowCenter, pixelGridDescY, 20, BLUE);

            text: *u8 = "Can you see this?";
            size: Vector2 = MeasureTextEx(GetFontDefault(), text, 20, 3);
            pos: Vector2 = Vector2.{ GetScreenWidth() - size.x - 5, GetScreenHeight() - size.y - 5 };
            DrawTextEx(GetFontDefault(), text, pos, 20, 3, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
DrawTextCenter :: (text: *u8, x: s32, y: s32, fontSize: s32, color: Color)
{
    size: Vector2 = MeasureTextEx(GetFontDefault(), text, cast(float)fontSize, 3);
    pos: Vector2 = Vector2.{ x - size.x/2, y - size.y/2 };
    DrawTextEx(GetFontDefault(), text, pos, cast(float)fontSize, 3, color);
}
