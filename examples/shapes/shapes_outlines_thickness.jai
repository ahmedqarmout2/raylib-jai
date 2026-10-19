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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - outlines thickness");

    thick: float = 5.0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update variables / Implement example logic at this point
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            GuiSliderBar(Rectangle.{ 290, 50, 220, 24 }, "Thickness", TextFormat("%.2f", thick), *thick, -30.0, 30.0);

            DrawRectangle(35, 180, 220, 220, LIGHTGRAY);
            DrawRectangleLinesEx(Rectangle.{ 35, 180, 220, 220 }, thick, BLUE);
            DrawText("DrawRectangleLinesEx()", 35, 160, 10, BLACK);

            DrawRectangleRounded(Rectangle.{ 290, 180, 220, 220 }, 0.2, 9, LIGHTGRAY);
            DrawRectangleRoundedLinesEx(Rectangle.{ 290, 180, 220, 220 }, 0.2, 9, thick, BLUE);
            DrawText("DrawRectangleRoundedLinesEx()", 290, 160, 10, BLACK);

            DrawCircle(655, 290, 110, LIGHTGRAY);
            DrawCircleLinesEx(Vector2.{ 655, 290 }, 110, thick, BLUE);
            DrawText("DrawCircleLinesEx()", 545, 160, 10, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
