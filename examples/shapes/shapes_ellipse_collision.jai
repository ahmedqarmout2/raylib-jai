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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - collision ellipses");
    SetTargetFPS(60);

    ellipseACenter: Vector2 = .{ cast(float)screenWidth/4, cast(float)screenHeight/2 };
    ellipseARx: float = 120.0;
    ellipseARy: float = 70.0;

    ellipseBCenter: Vector2 = .{ cast(float)screenWidth*3/4, cast(float)screenHeight/2 };
    ellipseBRx: float = 90.0;
    ellipseBRy: float = 140.0;

    // 0 = controlling A, 1 = controlling B
    controlled: s32 = 0;

    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_A)) controlled = 0;
        if (IsKeyPressed(.KEY_B)) controlled = 1;

        if (controlled == 0) ellipseACenter = GetMousePosition();
        else ellipseBCenter = GetMousePosition();

        ellipsesCollide: bool = CheckCollisionEllipses(
            ellipseACenter, ellipseARx, ellipseARy,
            ellipseBCenter, ellipseBRx, ellipseBRy
        );

        mouseInA: bool = CheckCollisionPointEllipse(GetMousePosition(), ellipseACenter, ellipseARx, ellipseARy);
        mouseInB: bool = CheckCollisionPointEllipse(GetMousePosition(), ellipseBCenter, ellipseBRx, ellipseBRy);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawEllipse(cast(s32)ellipseACenter.x, cast(s32)ellipseACenter.y, ellipseARx, ellipseARy, ifx ellipsesCollide then RED else BLUE);

            DrawEllipse(cast(s32)ellipseBCenter.x, cast(s32)ellipseBCenter.y, ellipseBRx, ellipseBRy, ifx ellipsesCollide then RED else GREEN);

            DrawEllipseLines(cast(s32)ellipseACenter.x, cast(s32)ellipseACenter.y, ellipseARx, ellipseARy, WHITE);

            DrawEllipseLines(cast(s32)ellipseBCenter.x, cast(s32)ellipseBCenter.y, ellipseBRx, ellipseBRy, WHITE);

            DrawCircleV(ellipseACenter, 4, WHITE);
            DrawCircleV(ellipseBCenter, 4, WHITE);

            if (ellipsesCollide) DrawText("ELLIPSES COLLIDE", screenWidth/2 - 120, 40, 28, RED);
            else DrawText("NO COLLISION", screenWidth/2 - 80, 40, 28, DARKGRAY);

            DrawText(temp_c_string(ifx controlled == 0 then "Controlling: A" else "Controlling: B"), 20, screenHeight - 40, 20, YELLOW);

            if (mouseInA && controlled != 0) DrawText("Mouse inside ellipse A", 20, screenHeight - 70, 20, BLUE);
            if (mouseInB && controlled != 1) DrawText("Mouse inside ellipse B", 20, screenHeight - 70, 20, GREEN);

            DrawText("Press [A] or [B] to switch control", 20, 20, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    CloseWindow();
}

// Check if point is inside ellipse
CheckCollisionPointEllipse :: (point: Vector2, center: Vector2, rx: float, ry: float) -> bool
{
    dx: float = (point.x - center.x)/rx;
    dy: float = (point.y - center.y)/ry;
    return (dx*dx + dy*dy) <= 1.0;
}

// Check if two ellipses collide
// Uses radial boundary distance in the direction between centers — scales correctly with radii
CheckCollisionEllipses :: (c1: Vector2, rx1: float, ry1: float, c2: Vector2, rx2: float, ry2: float) -> bool
{
    dx: float = c2.x - c1.x;
    dy: float = c2.y - c1.y;
    dist: float = sqrt(dx*dx + dy*dy);

    // Ellipses are on top of each other
    if (dist == 0.0) return true;

    theta: float = atan2(dy, dx);
    cosT: float = cos(theta);
    sinT: float = sin(theta);

    // Radial distance from center to ellipse boundary in direction theta
    // r(theta) = (rx * ry) / sqrt((ry*cos)^2 + (rx*sin)^2)
    r1: float = (rx1*ry1)/sqrt((ry1*cosT)*(ry1*cosT) + (rx1*sinT)*(rx1*sinT));
    r2: float = (rx2*ry2)/sqrt((ry2*cosT)*(ry2*cosT) + (rx2*sinT)*(rx2*sinT));

    return dist <= (r1 + r2);
}