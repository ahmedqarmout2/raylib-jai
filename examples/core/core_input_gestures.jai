#import "raylib";
#import "Basic";
#import "Math";

MAX_GESTURE_STRINGS :: 20;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures");

    touchPosition: Vector2 = .{ 0, 0 };
    touchArea: Rectangle = .{ 220, 10, screenWidth - 230.0, screenHeight - 20.0 };

    gesturesCount: s32 = 0;
    gestureStrings: [MAX_GESTURE_STRINGS][32]u8;

    currentGesture: Gesture = .GESTURE_NONE;
    lastGesture: Gesture = .GESTURE_NONE;

    //SetGesturesEnabled(0b0000000000001001);   // Enable only some gestures to be detected

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        lastGesture = currentGesture;
        currentGesture = GetGestureDetected();
        touchPosition = GetTouchPosition(0);

        if (CheckCollisionPointRec(touchPosition, touchArea) && (currentGesture != .GESTURE_NONE))
        {
            if (currentGesture != lastGesture)
            {
                // Store gesture string
                if currentGesture ==
                {
                    case .GESTURE_TAP; TextCopy(gestureStrings[gesturesCount].data, "GESTURE TAP");
                    case .GESTURE_DOUBLETAP; TextCopy(gestureStrings[gesturesCount].data, "GESTURE DOUBLETAP");
                    case .GESTURE_HOLD; TextCopy(gestureStrings[gesturesCount].data, "GESTURE HOLD");
                    case .GESTURE_DRAG; TextCopy(gestureStrings[gesturesCount].data, "GESTURE DRAG");
                    case .GESTURE_SWIPE_RIGHT; TextCopy(gestureStrings[gesturesCount].data, "GESTURE SWIPE RIGHT");
                    case .GESTURE_SWIPE_LEFT; TextCopy(gestureStrings[gesturesCount].data, "GESTURE SWIPE LEFT");
                    case .GESTURE_SWIPE_UP; TextCopy(gestureStrings[gesturesCount].data, "GESTURE SWIPE UP");
                    case .GESTURE_SWIPE_DOWN; TextCopy(gestureStrings[gesturesCount].data, "GESTURE SWIPE DOWN");
                    case .GESTURE_PINCH_IN; TextCopy(gestureStrings[gesturesCount].data, "GESTURE PINCH IN");
                    case .GESTURE_PINCH_OUT; TextCopy(gestureStrings[gesturesCount].data, "GESTURE PINCH OUT");
                }

                gesturesCount += 1;

                // Reset gestures strings
                if (gesturesCount >= MAX_GESTURE_STRINGS)
                {
                    for i: 0..MAX_GESTURE_STRINGS-1 TextCopy(gestureStrings[i].data, "\0");

                    gesturesCount = 0;
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawRectangleRec(touchArea, GRAY);
            DrawRectangle(225, 15, screenWidth - 240, screenHeight - 30, RAYWHITE);

            DrawText("GESTURES TEST AREA", screenWidth - 270, screenHeight - 40, 20, Fade(GRAY, 0.5));

            for i: 0..gesturesCount-1
            {
                if (i%2 == 0) DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.5));
                else DrawRectangle(10, 30 + 20*i, 200, 20, Fade(LIGHTGRAY, 0.3));

                if (i < gesturesCount - 1) DrawText(gestureStrings[i].data, 35, 36 + 20*i, 10, DARKGRAY);
                else DrawText(gestureStrings[i].data, 35, 36 + 20*i, 10, MAROON);
            }

            DrawRectangleLines(10, 29, 200, screenHeight - 50, GRAY);
            DrawText("DETECTED GESTURES", 50, 15, 10, GRAY);

            if (currentGesture != .GESTURE_NONE) DrawCircleV(touchPosition, 30, MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}