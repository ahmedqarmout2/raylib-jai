#import "raylib";
#import "Basic";
#import "Math";

MAX_MONITORS :: 10;

// Monitor info
MonitorInfo :: struct {
    position: Vector2;
    name: *u8;
    width: s32;
    height: s32;
    physicalWidth: s32;
    physicalHeight: s32;
    refreshRate: s32;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - monitor detector");

    monitors: [MAX_MONITORS]MonitorInfo;
    currentMonitorIndex: s32 = GetCurrentMonitor();
    monitorCount: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Variables to find the max x and Y to calculate the scale
        maxWidth: s32 = 1;
        maxHeight: s32 = 1;

        // Monitor offset is to fix when monitor position x is negative
        monitorOffsetX: s32 = 0;

        // Rebuild monitors array every frame
        monitorCount = GetMonitorCount();
        for i: 0..monitorCount-1
        {
            monitors[i] = MonitorInfo.{
                GetMonitorPosition(i),
                GetMonitorName(i),
                GetMonitorWidth(i),
                GetMonitorHeight(i),
                GetMonitorPhysicalWidth(i),
                GetMonitorPhysicalHeight(i),
                GetMonitorRefreshRate(i)
            };

            if (monitors[i].position.x < monitorOffsetX*1.0) monitorOffsetX = -cast(s32)monitors[i].position.x;

            width: s32 = cast(s32)monitors[i].position.x + monitors[i].width;
            height: s32 = cast(s32)monitors[i].position.y + monitors[i].height;

            if (maxWidth < width) maxWidth = width;
            if (maxHeight < height) maxHeight = height;
        }

        if (IsKeyPressed(.KEY_ENTER) && (monitorCount > 1))
        {
            currentMonitorIndex += 1;

            // Set index to 0 if the last one
            if (currentMonitorIndex == monitorCount) currentMonitorIndex = 0;

            SetWindowMonitor(currentMonitorIndex); // Move window to currentMonitorIndex
        }
        else currentMonitorIndex = GetCurrentMonitor(); // Get currentMonitorIndex if manually moved

        monitorScale: float = 0.6;

        if (maxHeight > (maxWidth + monitorOffsetX)) monitorScale *= (cast(float)screenHeight/cast(float)maxHeight);
        else monitorScale *= (cast(float)screenWidth/cast(float)(maxWidth + monitorOffsetX));
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("Press [Enter] to move window to next monitor available", 20, 20, 20, DARKGRAY);

            DrawRectangleLines(20, 60, screenWidth - 40, screenHeight - 100, DARKGRAY);

            // Draw Monitor Rectangles with information inside
            for i: 0..monitorCount-1
            {
                // Calculate retangle position and size using monitorScale
                rec: Rectangle = .{
                    (monitors[i].position.x + monitorOffsetX)*monitorScale + 140,
                    monitors[i].position.y*monitorScale + 80,
                    monitors[i].width*monitorScale,
                    monitors[i].height*monitorScale
                };

                // Draw monitor name and information inside the rectangle
                DrawText(TextFormat("[%i] %s", i, monitors[i].name), cast(s32)rec.x + 10, cast(s32)rec.y + cast(s32)(100*monitorScale), cast(s32)(120*monitorScale), BLUE);
                DrawText(
                    TextFormat("Resolution: [%ipx x %ipx]\nRefreshRate: [%ihz]\nPhysical Size: [%imm x %imm]\nPosition: %3.0f x %3.0f",
                        monitors[i].width,
                        monitors[i].height,
                        monitors[i].refreshRate,
                        monitors[i].physicalWidth,
                        monitors[i].physicalHeight,
                        monitors[i].position.x,
                        monitors[i].position.y
                    ), cast(s32)rec.x + 10, cast(s32)rec.y + cast(s32)(200*monitorScale), cast(s32)(120*monitorScale), DARKGRAY);

                // Highlight current monitor
                if (i == currentMonitorIndex)
                {
                    DrawRectangleLinesEx(rec, 5, RED);
                    windowPosition: Vector2 = .{ (GetWindowPosition().x + monitorOffsetX)*monitorScale  + 140, GetWindowPosition().y*monitorScale + 80 };

                    // Draw window position based on monitors
                    DrawRectangleV(windowPosition, Vector2.{screenWidth*monitorScale, screenHeight*monitorScale}, Fade(GREEN, 0.5));
                }
                else DrawRectangleLinesEx(rec, 5, GRAY);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}