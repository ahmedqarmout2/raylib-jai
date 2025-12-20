#import "raylib";
#import "Basic";
#import "Math";

texRoad: Texture;

showCurve : bool = false;

curveWidth    : float = 50;
curveSegments : s32   = 24;

curveStartPosition        : Vector2;
curveStartPositionTangent : Vector2;

curveEndPosition        : Vector2;
curveEndPositionTangent : Vector2;

curveSelectedPoint: *Vector2;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_VSYNC_HINT | .FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [textures] examples - textured curve");
    defer CloseWindow(); // Close window and OpenGL context

    // Load the road texture
    texRoad = LoadTexture("resources/road.png");
    defer UnloadTexture(texRoad);

    SetTextureFilter(texRoad, .TEXTURE_FILTER_BILINEAR);

    // Setup the curve
    curveStartPosition = Vector2.{ 80, 100 };
    curveStartPositionTangent = Vector2.{ 100, 300 };

    curveEndPosition = Vector2.{ 700, 350 };
    curveEndPositionTangent = Vector2.{ 600, 100 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Curve config options
        if (IsKeyPressed(.KEY_SPACE)) showCurve = !showCurve;
        if (IsKeyPressed(.KEY_EQUAL)) curveWidth += 2;
        if (IsKeyPressed(.KEY_MINUS)) curveWidth -= 2;
        if (curveWidth < 2) curveWidth = 2;

        // Update segments
        if (IsKeyPressed(.KEY_LEFT)) curveSegments -= 2;
        if (IsKeyPressed(.KEY_RIGHT)) curveSegments += 2;

        if (curveSegments < 2) curveSegments = 2;

        // Update curve logic
        // If the mouse is not down, we are not editing the curve so clear the selection
        if (!IsMouseButtonDown(MOUSE_LEFT_BUTTON))  curveSelectedPoint = null;

        // If a point was selected, move it
        if (curveSelectedPoint) {
            curveSelectedPoint.* = Vector2Add(curveSelectedPoint.*, GetMouseDelta());
        }

        // The mouse is down, and nothing was selected, so see if anything was picked
        mouse: Vector2 = GetMousePosition();
        if (CheckCollisionPointCircle(mouse, curveStartPosition, 6)) curveSelectedPoint = *curveStartPosition;
        else if (CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6)) curveSelectedPoint = *curveStartPositionTangent;
        else if (CheckCollisionPointCircle(mouse, curveEndPosition, 6)) curveSelectedPoint = *curveEndPosition;
        else if (CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6)) curveSelectedPoint = *curveEndPositionTangent;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTexturedCurve();    // Draw a textured Spline Cubic Bezier
        
        // Draw spline for reference
        if (showCurve) DrawSplineSegmentBezierCubic(curveStartPosition, curveEndPosition, curveStartPositionTangent, curveEndPositionTangent, 2, BLUE);

        // Draw the various control points and highlight where the mouse is
        DrawLineV(curveStartPosition, curveStartPositionTangent, SKYBLUE);
        DrawLineV(curveStartPositionTangent, curveEndPositionTangent, Fade(LIGHTGRAY, 0.4));
        DrawLineV(curveEndPosition, curveEndPositionTangent, PURPLE);
        
        if (CheckCollisionPointCircle(mouse, curveStartPosition, 6)) DrawCircleV(curveStartPosition, 7, YELLOW);
        DrawCircleV(curveStartPosition, 5, RED);

        if (CheckCollisionPointCircle(mouse, curveStartPositionTangent, 6)) DrawCircleV(curveStartPositionTangent, 7, YELLOW);
        DrawCircleV(curveStartPositionTangent, 5, MAROON);

        if (CheckCollisionPointCircle(mouse, curveEndPosition, 6)) DrawCircleV(curveEndPosition, 7, YELLOW);
        DrawCircleV(curveEndPosition, 5, GREEN);

        if (CheckCollisionPointCircle(mouse, curveEndPositionTangent, 6)) DrawCircleV(curveEndPositionTangent, 7, YELLOW);
        DrawCircleV(curveEndPositionTangent, 5, DARKGREEN);

        // Draw usage info
        DrawText("Drag points to move curve, press SPACE to show/hide base curve", 10, 10, 10, DARKGRAY);
        DrawText(TextFormat("Curve width: %2.0f (Use + and - to adjust)", curveWidth), 10, 30, 10, DARKGRAY);
        DrawText(TextFormat("Curve segments: %d (Use LEFT and RIGHT to adjust)", curveSegments), 10, 50, 10, DARKGRAY);
        //----------------------------------------------------------------------------------
    }
}

// Draw textured curve using Spline Cubic Bezier
DrawTexturedCurve :: () {
    step: float = 1.0/curveSegments;

    previous: Vector2 = curveStartPosition;
    previousTangent : Vector2;
    previousV: float = 0;

    // We can't compute a tangent for the first point, so we need to reuse the tangent from the first segment
    tangentSet: bool = false;

    current: Vector2;
    t: float = 0.0;

    for i: 1..curveSegments {
        t = step*cast(float)i;

        a: float = pow(1.0 - t, 3);
        b: float = 3.0*pow(1.0 - t, 2)*t;
        c: float = 3.0*(1.0 - t)*pow(t, 2);
        d: float = pow(t, 3);

        // Compute the endpoint for this segment
        current.y = a*curveStartPosition.y + b*curveStartPositionTangent.y + c*curveEndPositionTangent.y + d*curveEndPosition.y;
        current.x = a*curveStartPosition.x + b*curveStartPositionTangent.x + c*curveEndPositionTangent.x + d*curveEndPosition.x;

        // Vector from previous to current
        delta: Vector2 = .{ current.x - previous.x, current.y - previous.y };

        // The right hand normal to the delta vector
        normal: Vector2 = Vector2Normalize(Vector2.{ -delta.y, delta.x });

        // The v texture coordinate of the segment (add up the length of all the segments so far)
        v: float = previousV + Vector2Length(delta);

        // Make sure the start point has a normal
        if (!tangentSet) {
            previousTangent = normal;
            tangentSet = true;
        }

        // Extend out the normals from the previous and current points to get the quad for this segment
        prevPosNormal: Vector2 = Vector2Add(previous, Vector2Scale(previousTangent, curveWidth));
        prevNegNormal: Vector2 = Vector2Add(previous, Vector2Scale(previousTangent, -curveWidth));

        currentPosNormal: Vector2 = Vector2Add(current, Vector2Scale(normal, curveWidth));
        currentNegNormal: Vector2 = Vector2Add(current, Vector2Scale(normal, -curveWidth));

        // Draw the segment as a quad
        rlSetTexture(texRoad.id);
        rlBegin(RL_QUADS);
            rlColor4ub(255,255,255,255);
            rlNormal3f(0.0, 0.0, 1.0);

            rlTexCoord2f(0, previousV);
            rlVertex2f(prevNegNormal.x, prevNegNormal.y);

            rlTexCoord2f(1, previousV);
            rlVertex2f(prevPosNormal.x, prevPosNormal.y);

            rlTexCoord2f(1, v);
            rlVertex2f(currentPosNormal.x, currentPosNormal.y);

            rlTexCoord2f(0, v);
            rlVertex2f(currentNegNormal.x, currentNegNormal.y);
        rlEnd();

        // The current step is the start of the next step
        previous = current;
        previousTangent = normal;
        previousV = v;
    }
}
