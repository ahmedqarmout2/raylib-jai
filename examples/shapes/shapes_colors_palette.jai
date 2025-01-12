#import "raylib";
#import "Basic";
#import "Math";

MAX_COLORS_COUNT :: 21;          // Number of colors available

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - colors palette");

    colors: [MAX_COLORS_COUNT]Color = .[
        DARKGRAY, MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, DARKBROWN,
        GRAY, RED, GOLD, LIME, BLUE, VIOLET, BROWN, LIGHTGRAY, PINK, YELLOW,
        GREEN, SKYBLUE, PURPLE, BEIGE ];

    colorNames: [MAX_COLORS_COUNT]*u8 = .[
        "DARKGRAY", "MAROON", "ORANGE", "DARKGREEN", "DARKBLUE", "DARKPURPLE",
        "DARKBROWN", "GRAY", "RED", "GOLD", "LIME", "BLUE", "VIOLET", "BROWN",
        "LIGHTGRAY", "PINK", "YELLOW", "GREEN", "SKYBLUE", "PURPLE", "BEIGE" ];

    colorsRecs: [MAX_COLORS_COUNT]Rectangle;     // Rectangles array

    // Fills colorsRecs data (for every rectangle)
    for i: 0..MAX_COLORS_COUNT-1
    {
        colorsRecs[i].x = 20.0 + 100.0 *(i%7) + 10.0 *(i%7);
        colorsRecs[i].y = 80.0 + 100.0 *(i/7) + 10.0 *(i/7);
        colorsRecs[i].width = 100.0;
        colorsRecs[i].height = 100.0;
    }

    colorState: [MAX_COLORS_COUNT]s32;           // Color state: 0-DEFAULT, 1-MOUSE_HOVER

    mousePoint: Vector2 = .{ 0.0, 0.0 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePoint = GetMousePosition();

        for i: 0..MAX_COLORS_COUNT-1
        {
            if (CheckCollisionPointRec(mousePoint, colorsRecs[i])) colorState[i] = 1;
            else colorState[i] = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("raylib colors palette", 28, 42, 20, BLACK);
            DrawText("press SPACE to see all colors", GetScreenWidth() - 180, GetScreenHeight() - 40, 10, GRAY);

            for i: 0..MAX_COLORS_COUNT-1    // Draw all rectangles
            {
                DrawRectangleRec(colorsRecs[i], Fade(colors[i], ifx colorState[i] then 0.6 else 1.0));

                if (IsKeyDown(.KEY_SPACE) || colorState[i])
                {
                    DrawRectangle(cast(s32)colorsRecs[i].x, cast(s32)(colorsRecs[i].y + colorsRecs[i].height - 26), cast(s32)colorsRecs[i].width, 20, BLACK);
                    DrawRectangleLinesEx(colorsRecs[i], 6, Fade(BLACK, 0.3));
                    DrawText(colorNames[i], cast(s32)(colorsRecs[i].x + colorsRecs[i].width - MeasureText(colorNames[i], 10) - 12),
                        cast(s32)(colorsRecs[i].y + colorsRecs[i].height - 20), 10, colors[i]);
                }
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
