#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw ring");

    center: Vector2 = .{(GetScreenWidth() - 300)/2.0, GetScreenHeight()/2.0 };

    innerRadius : float = 80.0;
    outerRadius : float = 190.0;

    startAngle : float = 0.0;
    endAngle   : float = 360.0;
    segments   : float = 0.0;

    drawRing        : bool = true;
    drawRingLines   : bool = false;
    drawCircleLines : bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // NOTE: All variables update happens inside GUI control functions
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawLine(500, 0, 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.6));
            DrawRectangle(500, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.3));

            if (drawRing) DrawRing(center, innerRadius, outerRadius, startAngle, endAngle, cast(s32)segments, Fade(MAROON, 0.3));
            if (drawRingLines) DrawRingLines(center, innerRadius, outerRadius, startAngle, endAngle, cast(s32)segments, Fade(BLACK, 0.4));
            if (drawCircleLines) DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, cast(s32)segments, Fade(BLACK, 0.4));

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSliderBar(Rectangle.{ 600, 40, 120, 20 }, "StartAngle", TextFormat("%.2f", startAngle), *startAngle, -450, 450);
            GuiSliderBar(Rectangle.{ 600, 70, 120, 20 }, "EndAngle", TextFormat("%.2f", endAngle), *endAngle, -450, 450);

            GuiSliderBar(Rectangle.{ 600, 140, 120, 20 }, "InnerRadius", TextFormat("%.2f", innerRadius), *innerRadius, 0, 100);
            GuiSliderBar(Rectangle.{ 600, 170, 120, 20 }, "OuterRadius", TextFormat("%.2f", outerRadius), *outerRadius, 0, 200);

            GuiSliderBar(Rectangle.{ 600, 240, 120, 20 }, "Segments", TextFormat("%.2f", segments), *segments, 0, 100);

            GuiCheckBox(Rectangle.{ 600, 320, 20, 20 }, "Draw Ring", *drawRing);
            GuiCheckBox(Rectangle.{ 600, 350, 20, 20 }, "Draw RingLines", *drawRingLines);
            GuiCheckBox(Rectangle.{ 600, 380, 20, 20 }, "Draw CircleLines", *drawCircleLines);
            //------------------------------------------------------------------------------

            minSegments: s32 = cast(s32)ceil((endAngle - startAngle)/90);
            DrawText(TextFormat("MODE: %s", get_c_string(ifx (segments >= minSegments * 1.0) then "MANUAL" else "AUTO")), 600, 270, 10, ifx (segments >= minSegments * 1.0) then MAROON else DARKGRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
