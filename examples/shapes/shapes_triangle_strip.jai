#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - triangle strip");

    points: [122]Vector2;
    center: Vector2 = .{ (screenWidth/2.0) - 125.0, screenHeight/2.0 };
    segments: float = 6.0;
    insideRadius: float = 100.0;
    outsideRadius: float = 150.0;
    outline: bool = true;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        pointCount: s32 = cast(s32)(segments);
        angleStep: float = (360.0/pointCount)*DEG2RAD;

        i: s32 = 0; i2: s32 = 0;
        while (i < pointCount)
        {
            defer i += 1;
            defer i2 += 2;

            angle1: float = i*angleStep;
            points[i2] = Vector2.{ center.x + cos(angle1)*insideRadius, center.y + sin(angle1)*insideRadius };
            angle2: float = angle1 + angleStep/2.0;
            points[i2 + 1] = Vector2.{ center.x + cos(angle2)*outsideRadius, center.y + sin(angle2)*outsideRadius };
        }

        points[pointCount*2] = points[0];
        points[pointCount*2 + 1] = points[1];
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            for i: 0..pointCount-1
            {
                a: Vector2 = points[i*2];
                b: Vector2 = points[i*2 + 1];
                c: Vector2 = points[i*2 + 2];
                d: Vector2 = points[i*2 + 3];

                angle1: float = i*angleStep;
                DrawTriangle(c, b, a, ColorFromHSV(angle1*RAD2DEG, 1.0, 1.0));
                DrawTriangle(d, b, c, ColorFromHSV((angle1 + angleStep/2)*RAD2DEG, 1.0, 1.0));

                if (outline)
                {
                    DrawTriangleLines(a, b, c, BLACK);
                    DrawTriangleLines(c, b, d, BLACK);
                }
            }

            DrawLine(580, 0, 580, GetScreenHeight(), Color.{ 218, 218, 218, 255 });
            DrawRectangle(580, 0, GetScreenWidth(), GetScreenHeight(), Color.{ 232, 232, 232, 255 });

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSliderBar(Rectangle.{ 640, 40, 120, 20}, "Segments", TextFormat("%.0", segments), *segments, 6.0, 60.0);
            GuiCheckBox(Rectangle.{ 640, 70, 20, 20 }, "Outline", *outline);
            //------------------------------------------------------------------------------

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}