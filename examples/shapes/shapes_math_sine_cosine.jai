#import "raylib";
#import "Basic";
#import "Math";

// Wave points for sine/cosine visualization
WAVE_POINTS :: 36;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - math sine cosine");

    sinePoints: [WAVE_POINTS]Vector2;
    cosPoints: [WAVE_POINTS]Vector2;
    center: Vector2 = .{ (screenWidth/2.0) - 30.0, screenHeight/2.0 };
    start: Rectangle = .{ 20.0, screenHeight - 120.0 , 200.0, 100.0};
    radius: float = 130.0;
    angle: float = 0.0;
    pause: bool = false;

    for i: 0..WAVE_POINTS-1
    {
        t: float = i/cast(float)(WAVE_POINTS - 1);
        currentAngle: float = t*360.0*DEG2RAD;
        sinePoints[i] = Vector2.{ start.x + t*start.width, start.y + start.height/2.0 - sin(currentAngle)*(start.height/2.0) };
        cosPoints[i] = Vector2.{ start.x + t*start.width, start.y + start.height/2.0 - cos(currentAngle)*(start.height/2.0) };
    }

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        angleRad: float = angle*DEG2RAD;
        cosRad: float = cos(angleRad);
        sinRad: float = sin(angleRad);

        point: Vector2 = .{ center.x + cosRad*radius, center.y - sinRad*radius };
        limitMin: Vector2 = .{ center.x - radius, center.y - radius };
        limitMax: Vector2 = .{ center.x + radius, center.y + radius };

        complementary: float = 90.0 - angle;
        supplementary: float = 180.0 - angle;
        explementary: float = 360.0 - angle;

        tangent: float = Clamp(tan(angleRad), -10.0, 10.0);
        cotangent: float = ifx (abs(tangent) > 0.001) then Clamp(1.0/tangent, -radius, radius) else 0.0;
        tangentPoint: Vector2 = .{ center.x + radius, center.y - tangent*radius };
        cotangentPoint: Vector2 = .{ center.x + cotangent*radius, center.y - radius };

        angle = Wrap(angle + (ifx !pause then 1.0 else 0.0), 0.0, 360.0);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Cotangent (orange)
            DrawLineEx(Vector2.{ center.x , limitMin.y }, Vector2.{ cotangentPoint.x, limitMin.y }, 2.0, ORANGE);
            DrawLineDashed(center, cotangentPoint, 10, 4, ORANGE);

            // Side background
            DrawLine(580, 0, 580, GetScreenHeight(), Color.{ 218, 218, 218, 255 });
            DrawRectangle(580, 0, GetScreenWidth(), GetScreenHeight(), Color.{ 232, 232, 232, 255 });

            // Base circle and axes
            DrawCircleLinesV(center, radius, GRAY);
            DrawLineEx(Vector2.{ center.x, limitMin.y }, Vector2.{ center.x, limitMax.y }, 1.0, GRAY);
            DrawLineEx(Vector2.{ limitMin.x, center.y }, Vector2.{ limitMax.x, center.y }, 1.0, GRAY);

            // Wave graph axes
            DrawLineEx(Vector2.{ start.x , start.y }, Vector2.{ start.x , start.y + start.height }, 2.0, GRAY);
            DrawLineEx(Vector2.{ start.x + start.width, start.y }, Vector2.{ start.x + start.width, start.y + start.height }, 2.0, GRAY);
            DrawLineEx(Vector2.{ start.x, start.y + start.height/2 }, Vector2.{ start.x + start.width, start.y + start.height/2 }, 2.0, GRAY);

            // Wave graph axis labels
            DrawText("1", cast(s32)start.x - 8, cast(s32)start.y, 6, GRAY);
            DrawText("0", cast(s32)start.x - 8, cast(s32)start.y + cast(s32)start.height/2 - 6, 6, GRAY);
            DrawText("-1", cast(s32)start.x - 12, cast(s32)start.y + cast(s32)start.height - 8, 6, GRAY);
            DrawText("0", cast(s32)start.x - 2, cast(s32)start.y + cast(s32)start.height + 4, 6, GRAY);
            DrawText("360", cast(s32)start.x + cast(s32)start.width - 8, cast(s32)start.y + cast(s32)start.height + 4, 6, GRAY);

            // Sine (red - vertical)
            DrawLineEx(Vector2.{ center.x, center.y }, Vector2.{ center.x, point.y }, 2.0, RED);
            DrawLineDashed(Vector2.{ point.x, center.y }, Vector2.{ point.x, point.y }, 10, 4, RED);
            DrawText(TextFormat("Sine %.2f", sinRad), 640, 190, 6, RED);
            DrawCircleV(Vector2.{ start.x + (angle/360.0)*start.width, start.y + ((-sinRad + 1)*start.height/2.0) }, 4.0, RED);
            DrawSplineLinear(sinePoints.data, WAVE_POINTS, 1.0, RED);

            // Cosine (blue - horizontal)
            DrawLineEx(Vector2.{ center.x, center.y }, Vector2.{ point.x, center.y }, 2.0, BLUE);
            DrawLineDashed(Vector2.{ center.x , point.y }, Vector2.{ point.x, point.y }, 10, 4, BLUE);
            DrawText(TextFormat("Cosine %.2f", cosRad), 640, 210, 6, BLUE);
            DrawCircleV(Vector2.{ start.x + (angle/360.0)*start.width, start.y + ((-cosRad + 1)*start.height/2.0) }, 4.0, BLUE);
            DrawSplineLinear(cosPoints.data, WAVE_POINTS, 1.0, BLUE);

            // Tangent (purple)
            DrawLineEx(Vector2.{ limitMax.x , center.y }, Vector2.{ limitMax.x, tangentPoint.y }, 2.0, PURPLE);
            DrawLineDashed(center, tangentPoint, 10, 4, PURPLE);
            DrawText(TextFormat("Tangent %.2f", tangent), 640, 230, 6, PURPLE);

            // Cotangent (orange)
            DrawText(TextFormat("Cotangent %.2f", cotangent), 640, 250, 6, ORANGE);

            // Complementary angle (beige)
            DrawCircleSectorLines(center, radius*0.6, -angle, -90.0 , 36, BEIGE);
            DrawText(TextFormat("Complementary  %0.f°",complementary), 640, 150, 6, BEIGE);

            // Supplementary angle (darkblue)
            DrawCircleSectorLines(center, radius*0.5, -angle, -180.0 , 36, DARKBLUE);
            DrawText(TextFormat("Supplementary  %0.f°",supplementary), 640, 130, 6, DARKBLUE);

            // Explementary angle (pink)
            DrawCircleSectorLines(center, radius*0.4, -angle, -360.0 , 36, PINK);
            DrawText(TextFormat("Explementary  %0.f°",explementary), 640, 170, 6, PINK);

            // Current angle - arc (lime), radius (black), endpoint (black)
            DrawCircleSectorLines(center, radius*0.7, -angle, 0.0, 36, LIME);
            DrawLineEx(Vector2.{ center.x , center.y }, point, 2.0, BLACK);
            DrawCircleV(point, 4.0, BLACK);

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSetStyle(.LABEL, cast(s32)GuiControlProperty.TEXT_COLOR_NORMAL, ColorToInt(GRAY));
            GuiToggle(Rectangle.{ 640, 70, 120, 20}, TextFormat("Pause"), *pause);
            GuiSetStyle(.LABEL, cast(s32)GuiControlProperty.TEXT_COLOR_NORMAL, ColorToInt(LIME));
            GuiSliderBar(Rectangle.{ 640, 40, 120, 20}, "Angle", TextFormat("%.0f°", angle), *angle, 0.0, 360.0);

            // Angle values panel
            GuiGroupBox(Rectangle.{ 620, 110, 140, 170}, "Angle Values");
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