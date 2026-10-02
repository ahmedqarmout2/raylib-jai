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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - vector angle");

    v0: Vector2 = .{ screenWidth/2.0, screenHeight/2.0 };
    v1: Vector2 = Vector2Add(v0, Vector2.{ 100.0, 80.0 });
    v2: Vector2;             // Updated with mouse position

    angle: float = 0.0;             // Angle in degrees
    angleMode: bool = false;              // 0-Vector2Angle(), 1-Vector2LineAngle()

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        startangle: float = 0.0;

        if (!angleMode) startangle = -Vector2LineAngle(v0, v1)*RAD2DEG;
        if (angleMode) startangle = 0.0;

        v2 = GetMousePosition();

        if (IsKeyPressed(.KEY_SPACE)) angleMode = !angleMode;

        if ((!angleMode) && IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) v1 = GetMousePosition();

        if (!angleMode)
        {
            // Calculate angle between two vectors, considering a common origin (v0)
            v1Normal: Vector2 = Vector2Normalize(Vector2Subtract(v1, v0));
            v2Normal: Vector2 = Vector2Normalize(Vector2Subtract(v2, v0));

            angle = Vector2Angle(v1Normal, v2Normal)*RAD2DEG;
        }
        else
        {
            // Calculate angle defined by a two vectors line, in reference to horizontal line
            angle = Vector2LineAngle(v0, v2)*RAD2DEG;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (!angleMode)
            {
                DrawText("MODE 0: Angle between V1 and V2", 10, 10, 20, BLACK);
                DrawText("Right Click to Move V2", 10, 30, 20, DARKGRAY);

                DrawLineEx(v0, v1, 2.0, BLACK);
                DrawLineEx(v0, v2, 2.0, RED);

                DrawCircleSector(v0, 40.0, startangle, startangle + angle, 32, Fade(GREEN, 0.6));
            }
            else
            {
                DrawText("MODE 1: Angle formed by line V1 to V2", 10, 10, 20, BLACK);

                DrawLine(0, screenHeight/2, screenWidth, screenHeight/2, LIGHTGRAY);
                DrawLineEx(v0, v2, 2.0, RED);

                DrawCircleSector(v0, 40.0, startangle, startangle - angle, 32, Fade(GREEN, 0.6));
            }

            DrawText("v0", cast(s32)v0.x, cast(s32)v0.y, 10, DARKGRAY);

            // If the line from v0 to v1 would overlap the text, move it's position up 10
            if (!angleMode && Vector2Subtract(v0, v1).y > 0.0) DrawText("v1", cast(s32)v1.x, cast(s32)v1.y-10, 10, DARKGRAY);
            if (!angleMode && Vector2Subtract(v0, v1).y < 0.0) DrawText("v1", cast(s32)v1.x, cast(s32)v1.y, 10, DARKGRAY);

            // If angle mode 1, use v1 to emphasize the horizontal line
            if (angleMode) DrawText("v1", cast(s32)v0.x + 40, cast(s32)v0.y, 10, DARKGRAY);

            // position adjusted by -10 so it isn't hidden by cursor
            DrawText("v2", cast(s32)v2.x-10, cast(s32)v2.y-10, 10, DARKGRAY);

            DrawText("Press SPACE to change MODE", 460, 10, 20, DARKGRAY);
            DrawText(TextFormat("ANGLE: %2.2f", angle), 10, 70, 20, LIME);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
