#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - draw rectangle rounded");

    roundness : float = 0.2;
    width     : float = 200.0;
    height    : float = 100.0;
    segments  : float = 0.0;
    lineThick : float = 1.0;

    drawRect         : bool = false;
    drawRoundedRect  : bool = true;
    drawRoundedLines : bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rec: Rectangle = .{ (cast(float)GetScreenWidth() - width - 250)/2, (GetScreenHeight() - height)/2.0, cast(float)width, cast(float)height };
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawLine(560, 0, 560, GetScreenHeight(), Fade(LIGHTGRAY, 0.6));
            DrawRectangle(560, 0, GetScreenWidth() - 500, GetScreenHeight(), Fade(LIGHTGRAY, 0.3));

            if (drawRect) DrawRectangleRec(rec, Fade(GOLD, 0.6));
            if (drawRoundedRect) DrawRectangleRounded(rec, roundness, cast(s32)segments, Fade(MAROON, 0.2));
            if (drawRoundedLines) DrawRectangleRoundedLinesEx(rec, roundness, cast(s32)segments, lineThick, Fade(MAROON, 0.4));

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSliderBar(Rectangle.{ 640, 40, 105, 20 }, "Width", null, *width, 0, cast(float)GetScreenWidth() - 300);
            GuiSliderBar(Rectangle.{ 640, 70, 105, 20 }, "Height", null, *height, 0, cast(float)GetScreenHeight() - 50);
            GuiSliderBar(Rectangle.{ 640, 140, 105, 20 }, "Roundness", null, *roundness, 0.0, 1.0);
            GuiSliderBar(Rectangle.{ 640, 170, 105, 20 }, "Thickness", null, *lineThick, 0, 20);
            GuiSliderBar(Rectangle.{ 640, 240, 105, 20}, "Segments", null, *segments, 0, 60);

            GuiCheckBox(Rectangle.{ 640, 320, 20, 20 }, "DrawRoundedRect", *drawRoundedRect);
            GuiCheckBox(Rectangle.{ 640, 350, 20, 20 }, "DrawRoundedLines", *drawRoundedLines);
            GuiCheckBox(Rectangle.{ 640, 380, 20, 20}, "DrawRect", *drawRect);
            //------------------------------------------------------------------------------

            DrawText(TextFormat("MODE: %s", get_c_string(ifx (segments >= 4) then "MANUAL" else "AUTO")), 640, 280, 10, ifx (segments >= 4) then MAROON else DARKGRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
