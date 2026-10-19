#import "raylib";
#import "Basic";
#import "Math";

MAX_DRAW_LINES ::  8192;

// Line data type
Line :: struct {
    start: Vector2;
    end: Vector2;
};

// Lines array as a global static variable to be stored
// in heap and avoid potential stack overflow (on Web platform)
lines: [..]Line;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - kaleidoscope");

    array_resize(*lines, MAX_DRAW_LINES);

    // Line drawing properties
    symmetry: s32 = 6;
    angle: float = 360.0/cast(float)symmetry;
    thickness: float = 3.0;
    resetButtonRec: Rectangle = .{ screenWidth - 55.0, 5.0, 50, 25 };
    backButtonRec: Rectangle = .{ screenWidth - 55.0, screenHeight - 30.0, 25, 25 };
    nextButtonRec: Rectangle = .{ screenWidth - 30.0, screenHeight - 30.0, 25, 25 };
    mousePos: Vector2;
    prevMousePos: Vector2;
    scaleVector: Vector2 = .{ 1.0, -1.0 };
    offset: Vector2 = .{ GetRenderWidth()/2.0, GetRenderHeight()/2.0 };

    camera: Camera2D;
    camera.target = Vector2.{0, 0};
    camera.offset = offset;
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    currentLineCounter: s32 = 0;
    totalLineCounter: s32 = 0;
    resetButtonClicked: bool = false;
    backButtonClicked: bool = false;
    nextButtonClicked: bool = false;

    SetTargetFPS(20);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        prevMousePos = mousePos;
        mousePos = GetMousePosition();

        lineStart: Vector2 = Vector2Subtract(mousePos, offset);
        lineEnd: Vector2 = Vector2Subtract(prevMousePos, offset);

        if (
            IsMouseButtonDown(MOUSE_LEFT_BUTTON)
            && (!CheckCollisionPointRec(mousePos, resetButtonRec))
            && (!CheckCollisionPointRec(mousePos, backButtonRec))
            && (!CheckCollisionPointRec(mousePos, nextButtonRec))
        )
        {
            s: s32 = 0;
            while ((s < symmetry) && (totalLineCounter < (MAX_DRAW_LINES - 1)))
            {
                defer s += 1;

                lineStart = Vector2Rotate(lineStart, angle*DEG2RAD);
                lineEnd = Vector2Rotate(lineEnd, angle*DEG2RAD);

                // Store mouse line
                lines[totalLineCounter].start = lineStart;
                lines[totalLineCounter].end = lineEnd;

                // Store reflective line
                lines[totalLineCounter + 1].start = Vector2Multiply(lineStart, scaleVector);
                lines[totalLineCounter + 1].end = Vector2Multiply(lineEnd, scaleVector);

                totalLineCounter += 2;
                currentLineCounter = totalLineCounter;
            }
        }

        if (resetButtonClicked)
        {
            array_reset(*lines);
            currentLineCounter = 0;
            totalLineCounter = 0;
        }

        if (backButtonClicked && (currentLineCounter > 0))
        {
            currentLineCounter -= 1;
        }

        if (nextButtonClicked && (currentLineCounter < MAX_DRAW_LINES) && ((currentLineCounter + 1) <= totalLineCounter))
        {
            currentLineCounter += 1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);
            BeginMode2D(camera);

                s: s32 = 0;
                while (s < symmetry)
                {
                    defer s += 1;

                    i: s32 = 0;
                    while (i < currentLineCounter)
                    {
                        defer i += 2;

                        DrawLineEx(lines[i].start, lines[i].end, thickness, BLACK);
                        DrawLineEx(lines[i + 1].start, lines[i + 1].end, thickness, BLACK);
                    }
                }

            EndMode2D();

            if ((currentLineCounter - 1) < 0) GuiDisable();

            backButtonClicked = GuiButton(backButtonRec, "<") == .RESULT_PRESSED;
            GuiEnable();

            if ((currentLineCounter + 1) > totalLineCounter) GuiDisable();

            nextButtonClicked = GuiButton(nextButtonRec, ">") == .RESULT_PRESSED;
            GuiEnable();
            resetButtonClicked = GuiButton(resetButtonRec, "Reset") == .RESULT_PRESSED;

            DrawText(TextFormat("LINES: %i/%i", currentLineCounter, MAX_DRAW_LINES), 10, screenHeight - 30, 20, MAROON);
            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
