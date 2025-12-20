#import "raylib";
#import "Basic";
#import "Math";

MAX_SPLINE_POINTS :: 32;

// Cubic Bezier spline control points
// NOTE: Every segment has two control points 
ControlPoint :: struct {
    start: Vector2;
    end: Vector2;
};

// Spline types
SplineType :: enum s32 {
    SPLINE_LINEAR :: 0;      // Linear
    SPLINE_BASIS;           // B-Spline
    SPLINE_CATMULLROM;      // Catmull-Rom
    SPLINE_BEZIER;           // Cubic Bezier
};

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - splines drawing");

    points: [MAX_SPLINE_POINTS]Vector2;
    points[0] = .{  50.0, 400.0 };
    points[1] = .{ 160.0, 220.0 };
    points[2] = .{ 340.0, 380.0 };
    points[3] = .{ 520.0, 60.0 };
    points[4] = .{ 710.0, 260.0 };
    
    // Array required for spline bezier-cubic, 
    // including control points interleaved with start-end segment points
    pointsInterleaved: [3*(MAX_SPLINE_POINTS - 1) + 1] Vector2;
    
    pointCount: s32 = 5;
    selectedPoint: s32 = -1;
    focusedPoint: s32 = -1;
    selectedControlPoint: *Vector2 = null;
    focusedControlPoint: *Vector2 = null;
    
    // Cubic Bezier control points initialization
    control: [MAX_SPLINE_POINTS-1]ControlPoint;
    for i: 0..pointCount - 2
    {
        control[i].start = Vector2.{ points[i].x + 50, points[i].y };
        control[i].end = Vector2.{ points[i + 1].x - 50, points[i + 1].y };
    }

    // Spline config variables
    splineThickness: float = 8.0;
    splineTypeActive: s32 = cast(s32) SplineType.SPLINE_LINEAR; // 0-Linear, 1-BSpline, 2-CatmullRom, 3-Bezier
    splineTypeEditMode: bool = false; 
    splineHelpersActive: bool  = true;
    
    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Spline points creation logic (at the end of spline)
        if (IsMouseButtonPressed(MOUSE_RIGHT_BUTTON) && (pointCount < MAX_SPLINE_POINTS))
        {
            points[pointCount] = GetMousePosition();
            i: s32 = pointCount - 1;
            control[i].start = Vector2.{ points[i].x + 50, points[i].y };
            control[i].end = Vector2.{ points[i + 1].x - 50, points[i + 1].y };
            pointCount += 1;
        }

        // Spline point focus and selection logic
        for i: 0..pointCount - 1
        {
            if (CheckCollisionPointCircle(GetMousePosition(), points[i], 8.0))
            {
                focusedPoint = i;
                if (IsMouseButtonDown(MOUSE_LEFT_BUTTON)) selectedPoint = i; 
                break;
            }
            else focusedPoint = -1;
        }
        
        // Spline point movement logic
        if (selectedPoint >= 0)
        {
            points[selectedPoint] = GetMousePosition();
            if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON)) selectedPoint = -1;
        }
        
        // Cubic Bezier spline control points logic
        if ((splineTypeActive == cast(s32) SplineType.SPLINE_BEZIER) && (focusedPoint == -1))
        {
            // Spline control point focus and selection logic
            for i: 0..pointCount - 2
            {
                if (CheckCollisionPointCircle(GetMousePosition(), control[i].start, 6.0))
                {
                    focusedControlPoint = *control[i].start;
                    if (IsMouseButtonDown(MOUSE_LEFT_BUTTON)) selectedControlPoint = *control[i].start; 
                    break;
                }
                else if (CheckCollisionPointCircle(GetMousePosition(), control[i].end, 6.0))
                {
                    focusedControlPoint = *control[i].end;
                    if (IsMouseButtonDown(MOUSE_LEFT_BUTTON)) selectedControlPoint = *control[i].end; 
                    break;
                }
                else focusedControlPoint = null;
            }
            
            // Spline control point movement logic
            if (selectedControlPoint != null)
            {
                selectedControlPoint.* = GetMousePosition();
                if (IsMouseButtonReleased(MOUSE_LEFT_BUTTON)) selectedControlPoint = null;
            }
        }

        // Spline selection logic
        if (IsKeyPressed(.KEY_ONE)) splineTypeActive = cast(s32) SplineType.SPLINE_LINEAR;
        else if (IsKeyPressed(.KEY_TWO)) splineTypeActive = cast(s32) SplineType.SPLINE_BASIS;
        else if (IsKeyPressed(.KEY_THREE)) splineTypeActive = cast(s32) SplineType.SPLINE_CATMULLROM;
        else if (IsKeyPressed(.KEY_FOUR)) splineTypeActive = cast(s32) SplineType.SPLINE_BEZIER;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);
        
            if (splineTypeActive == cast(s32) SplineType.SPLINE_LINEAR)
            {
                // Draw spline: linear
                DrawSplineLinear(points.data, pointCount, splineThickness, RED);
            }
            else if (splineTypeActive == cast(s32) SplineType.SPLINE_BASIS)
            {
                // Draw spline: basis
                DrawSplineBasis(points.data, pointCount, splineThickness, RED);  // Provide connected points array

                /*
                for (int i = 0; i < (pointCount - 3); i++)
                {
                    // Drawing individual segments, not considering thickness connection compensation
                    DrawSplineSegmentBasis(points[i], points[i + 1], points[i + 2], points[i + 3], splineThickness, MAROON);
                }
                */
            }
            else if (splineTypeActive == cast(s32) SplineType.SPLINE_CATMULLROM)
            {
                // Draw spline: catmull-rom
                DrawSplineCatmullRom(points.data, pointCount, splineThickness, RED); // Provide connected points array
                
                /*
                for (int i = 0; i < (pointCount - 3); i++)
                {
                    // Drawing individual segments, not considering thickness connection compensation
                    DrawSplineSegmentCatmullRom(points[i], points[i + 1], points[i + 2], points[i + 3], splineThickness, MAROON);
                }
                */
            }
            else if (splineTypeActive == cast(s32) SplineType.SPLINE_BEZIER)
            {
                // NOTE: Cubic-bezier spline requires the 2 control points of each segnment to be 
                // provided interleaved with the start and end point of every segment
                for i: 0..pointCount - 2
                {
                    pointsInterleaved[3*i] = points[i];
                    pointsInterleaved[3*i + 1] = control[i].start;
                    pointsInterleaved[3*i + 2] = control[i].end;
                }
                
                pointsInterleaved[3*(pointCount - 1)] = points[pointCount - 1];

                // Draw spline: cubic-bezier (with control points)
                DrawSplineBezierCubic(pointsInterleaved.data, 3*(pointCount - 1) + 1, splineThickness, RED);
                
                /*
                for (int i = 0; i < 3*(pointCount - 1); i += 3)
                {
                    // Drawing individual segments, not considering thickness connection compensation
                    DrawSplineSegmentBezierCubic(pointsInterleaved[i], pointsInterleaved[i + 1], pointsInterleaved[i + 2], pointsInterleaved[i + 3], splineThickness, MAROON);
                }
                */

                // Draw spline control points
                for i: 0..pointCount - 2
                {
                    // Every cubic bezier point have two control points
                    DrawCircleV(control[i].start, 6, GOLD);
                    DrawCircleV(control[i].end, 6, GOLD);
                    if (focusedControlPoint == *control[i].start) DrawCircleV(control[i].start, 8, GREEN);
                    else if (focusedControlPoint == *control[i].end) DrawCircleV(control[i].end, 8, GREEN);
                    DrawLineEx(points[i], control[i].start, 1.0, LIGHTGRAY);
                    DrawLineEx(points[i + 1], control[i].end, 1.0, LIGHTGRAY);
                
                    // Draw spline control lines
                    DrawLineV(points[i], control[i].start, GRAY);
                    //DrawLineV(control[i].start, control[i].end, LIGHTGRAY);
                    DrawLineV(control[i].end, points[i + 1], GRAY);
                }
            }

            if (splineHelpersActive)
            {
                // Draw spline point helpers
                for i: 0..pointCount - 1
                {
                    DrawCircleLinesV(points[i], ifx (focusedPoint == i) then 12.0 else 8.0, ifx (focusedPoint == i) then BLUE else DARKBLUE);
                    if ((splineTypeActive != cast(s32) SplineType.SPLINE_LINEAR) &&
                        (splineTypeActive != cast(s32) SplineType.SPLINE_BEZIER) &&
                        (i < pointCount - 1)) DrawLineV(points[i], points[i + 1], GRAY);

                    DrawText(TextFormat("[%.0f, %.0f]", points[i].x, points[i].y), cast(s32)points[i].x, cast(s32)points[i].y + 10, 10, BLACK);
                }
            }

            // Check all possible UI states that require controls lock
            if (splineTypeEditMode) GuiLock();
            
            // Draw spline config
            GuiLabel(Rectangle.{ 12, 62, 140, 24 }, TextFormat("Spline thickness: %i", cast(s32)splineThickness));
            GuiSliderBar(Rectangle.{ 12, 60 + 24, 140, 16 }, null, null, *splineThickness, 1.0, 40.0);

            GuiCheckBox(Rectangle.{ 12, 110, 20, 20 }, "Show point helpers", *splineHelpersActive);

            GuiUnlock();

            GuiLabel(Rectangle.{ 12, 10, 140, 24 }, "Spline type:");
            if (GuiDropdownBox(Rectangle.{ 12, 8 + 24, 140, 28 }, "LINEAR;BSPLINE;CATMULLROM;BEZIER", *splineTypeActive, splineTypeEditMode)) splineTypeEditMode = !splineTypeEditMode;

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
