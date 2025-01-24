#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw circle sector");

    center: Vector2 = .{(GetScreenWidth() - 300)/2.0, GetScreenHeight()/2.0 };

    outerRadius : float = 180.0;
    startAngle  : float = 0.0;
    endAngle    : float = 180.0;
    segments    : float = 10.0;
    minSegments : float = 4;

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

            DrawCircleSector(center, outerRadius, startAngle, endAngle, cast(s32)segments, Fade(MAROON, 0.3));
            DrawCircleSectorLines(center, outerRadius, startAngle, endAngle, cast(s32)segments, Fade(MAROON, 0.6));

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSliderBar(Rectangle.{ 600, 40, 120, 20}, "StartAngle", null, *startAngle, 0, 720);
            GuiSliderBar(Rectangle.{ 600, 70, 120, 20}, "EndAngle", null, *endAngle, 0, 720);

            GuiSliderBar(Rectangle.{ 600, 140, 120, 20}, "Radius", null, *outerRadius, 0, 200);
            GuiSliderBar(Rectangle.{ 600, 170, 120, 20}, "Segments", null, *segments, 0, 100);
            //------------------------------------------------------------------------------

            minSegments = cast,trunc(float)(ceil((endAngle - startAngle) / 90));
            DrawText(TextFormat("MODE: %s", get_c_string(ifx (segments >= minSegments) then "MANUAL" else "AUTO")), 600, 200, 10, ifx(segments >= minSegments) then MAROON else DARKGRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
