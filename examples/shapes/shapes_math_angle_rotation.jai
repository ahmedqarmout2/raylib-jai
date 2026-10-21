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
    screenWidth  : s32 : 720;
    screenHeight : s32 : 400;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - math angle rotation");
    SetTargetFPS(60);

    center: Vector2 = .{ screenWidth/2.0, screenHeight/2.0 };
    lineLength: float = 150.0;

    // Predefined angles for fixed lines
    angles: [4]s32 = .[ 0, 30, 60, 90 ];
    numAngles: s32 = angles.count;

    totalAngle: float = 0.0; // Animated rotation angle
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        totalAngle += 1.0; // degrees per frame
        if (totalAngle >= 360.0) totalAngle -= 360.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(WHITE);

            DrawText("Fixed angles + rotating line", 10, 10, 20, LIGHTGRAY);

            // Draw fixed-angle lines with colorful gradient
            for i: 0..numAngles-1
            {
                rad: float = angles[i]*DEG2RAD;
                end: Vector2 = .{ center.x + cos(rad)*lineLength,
                                center.y + sin(rad)*lineLength };

                // Gradient color from green → cyan → blue → magenta
                col: Color;
                if i ==
                {
                    case 0; col = GREEN;
                    case 1; col = ORANGE;
                    case 2; col = BLUE;
                    case 3; col = MAGENTA;
                    case; col = WHITE;
                }

                DrawLineEx(center, end, 5.0, col);

                // Draw angle label slightly offset along the line
                textPos: Vector2 = .{ center.x + cos(rad)*(lineLength + 20),
                                    center.y + sin(rad)*(lineLength + 20) };
                DrawText(TextFormat("%d°", angles[i]), cast(s32)textPos.x, cast(s32)textPos.y, 20, col);
            }

            // Draw animated rotating line with changing color
            animRad: float = totalAngle*DEG2RAD;
            animEnd: Vector2 = .{ center.x + cos(animRad)*lineLength,
                                center.y + sin(animRad)*lineLength };

            // Cycle through HSV colors for animated line
            animCol: Color = ColorFromHSV(fmod_cycling(totalAngle, 360.0), 0.8, 0.9);
            DrawLineEx(center, animEnd, 5.0, animCol);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();
    //--------------------------------------------------------------------------------------
}
