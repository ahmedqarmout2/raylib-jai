#import "raylib";
#import "Basic";
#import "Math";

GESTURE_LOG_SIZE :: 20;
MAX_TOUCH_COUNT :: 32;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input gestures testbed");

    messagePosition: Vector2 = .{ 160, 7 };

    // Last gesture variables definitions
    lastGesture: Gesture = .GESTURE_NONE;
    lastGesturePosition: Vector2  = .{ 165, 130 };

    // Gesture log variables definitions
    // NOTE: The gesture log uses an array (as an inverted circular queue) to store the performed gestures
    gestureLog: [GESTURE_LOG_SIZE][12]u8;
    // NOTE: The index for the inverted circular queue (moving from last to first direction, then looping around)
    gestureLogIndex: s32 = GESTURE_LOG_SIZE;
    previousGesture: Gesture = .GESTURE_NONE;

    // Log mode values:
    // - 0 shows repeated events
    // - 1 hides repeated events
    // - 2 shows repeated events but hide hold events
    // - 3 hides repeated events and hide hold events
    logMode: s32 = 1;

    gestureColor: Color = .{ 0, 0, 0, 255 };
    logButton1: Rectangle = .{ 53, 7, 48, 26 };
    logButton2: Rectangle = .{ 108, 7, 36, 26 };
    gestureLogPosition: Vector2 = .{ 10, 10 };

    // Protractor variables definitions
    angleLength: float = 90.0;
    currentAngleDegrees: float = 0.0;
    finalVector: Vector2 = .{ 0.0, 0.0 };
    protractorPosition: Vector2 = .{ 266.0, 315.0 };

    SetTargetFPS(60);   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //--------------------------------------------------------------------------------------
        // Handle common gestures data
        i: s32; ii: s32; // Iterators that will be reused by all for loops
        currentGesture: Gesture = GetGestureDetected();
        currentDragDegrees: float = GetGestureDragAngle();
        currentPitchDegrees: float = GetGesturePinchAngle();
        touchCount: s32 = GetTouchPointCount();

        // Handle last gesture
        if ((currentGesture != 0) && (currentGesture != 4) && (currentGesture != previousGesture))
            lastGesture = currentGesture; // Filter the meaningful gestures (1, 2, 8 to 512) for the display

        // Handle gesture log
        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT))
        {
            if (CheckCollisionPointRec(GetMousePosition(), logButton1))
            {
                if logMode ==
                {
                    case 3; logMode = 2;
                    case 2; logMode = 3;
                    case 1; logMode = 0;
                    case; logMode = 1;
                }
            }
            else if (CheckCollisionPointRec(GetMousePosition(), logButton2))
            {
                if logMode ==
                {
                    case 3; logMode = 1;
                    case 2; logMode = 0;
                    case 1; logMode = 3;
                    case; logMode = 2;
                }
            }
        }

        fillLog: bool = false; // Gate variable to be used to allow or not the gesture log to be filled
        if (currentGesture != .GESTURE_NONE)
        {
            if (logMode == 3) // 3 hides repeated events and hide hold events
            {
                if (((currentGesture != .GESTURE_HOLD) && (currentGesture != previousGesture)) || (cast(s32)currentGesture < 3)) fillLog = true;
            }
            else if (logMode == 2) // 2 shows repeated events but hide hold events
            {
                if (currentGesture != .GESTURE_HOLD) fillLog = true;
            }
            else if (logMode == 1) // 1 hides repeated events
            {
                if (currentGesture != previousGesture) fillLog = true;
            }
            else  // 0 shows repeated events
            {
                fillLog = true;
            }
        }

        if (fillLog) // If one of the conditions from logMode was met, fill the gesture log
        {
            previousGesture = currentGesture;
            gestureColor = GetGestureColor(currentGesture);
            if (gestureLogIndex <= 0) gestureLogIndex = GESTURE_LOG_SIZE;
            gestureLogIndex -= 1;

            // Copy the gesture respective name to the gesture log array
            TextCopy(gestureLog[gestureLogIndex].data, GetGestureName(currentGesture));
        }

        // Handle protractor
        if (currentGesture > 255) currentAngleDegrees = currentPitchDegrees; // Pinch In and Pinch Out
        else if (currentGesture > 15) currentAngleDegrees = currentDragDegrees; // Swipe Right, Swipe Left, Swipe Up and Swipe Down
        else if (currentGesture > 0) currentAngleDegrees = 0.0; // Tap, Doubletap, Hold and Grab

        currentAngleRadians: float = ((currentAngleDegrees + 90.0)*PI/180); // Convert the current angle to Radians
        // Calculate the final vector for display
        finalVector = Vector2.{ (angleLength*sin(currentAngleRadians)) + protractorPosition.x,
            (angleLength*cos(currentAngleRadians)) + protractorPosition.y };

        // Handle touch and mouse pointer points
        touchPosition: [MAX_TOUCH_COUNT]Vector2;
        mousePosition: Vector2;
        if (currentGesture != .GESTURE_NONE)
        {
            if (touchCount != 0)
            {
                for i: 0..touchCount-1 touchPosition[i] = GetTouchPosition(i); // Fill the touch positions
            }
            else mousePosition = GetMousePosition();
        }
        //--------------------------------------------------------------------------------------

        // Draw
        //--------------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw common elements
            DrawText("*", cast(s32)messagePosition.x + 5, cast(s32)messagePosition.y + 5, 10, BLACK);
            DrawText("Example optimized for Web/HTML5\non Smartphones with Touch Screen.", cast(s32)messagePosition.x + 15, cast(s32)messagePosition.y + 5, 10, BLACK);
            DrawText("*", cast(s32)messagePosition.x + 5, cast(s32)messagePosition.y + 35, 10, BLACK);
            DrawText("While running on Desktop Web Browsers,\ninspect and turn on Touch Emulation.", cast(s32)messagePosition.x + 15, cast(s32)messagePosition.y + 35, 10, BLACK);

            // Draw last gesture
            DrawText("Last gesture", cast(s32)lastGesturePosition.x + 33, cast(s32)lastGesturePosition.y - 47, 20, BLACK);
            DrawText("Swipe         Tap       Pinch  Touch", cast(s32)lastGesturePosition.x + 17, cast(s32)lastGesturePosition.y - 18, 10, BLACK);
            DrawRectangle(cast(s32)lastGesturePosition.x + 20, cast(s32)lastGesturePosition.y, 20, 20, ifx lastGesture == .GESTURE_SWIPE_UP then RED else LIGHTGRAY);
            DrawRectangle(cast(s32)lastGesturePosition.x, cast(s32)lastGesturePosition.y + 20, 20, 20, ifx lastGesture == .GESTURE_SWIPE_LEFT then RED else LIGHTGRAY);
            DrawRectangle(cast(s32)lastGesturePosition.x + 40, cast(s32)lastGesturePosition.y + 20, 20, 20, ifx lastGesture == .GESTURE_SWIPE_RIGHT then RED else LIGHTGRAY);
            DrawRectangle(cast(s32)lastGesturePosition.x + 20, cast(s32)lastGesturePosition.y + 40, 20, 20, ifx lastGesture == .GESTURE_SWIPE_DOWN then RED else LIGHTGRAY);
            DrawCircle(cast(s32)lastGesturePosition.x + 80, cast(s32)lastGesturePosition.y + 16, 10, ifx lastGesture == .GESTURE_TAP then BLUE else LIGHTGRAY);
            DrawRing( Vector2.{lastGesturePosition.x + 103, lastGesturePosition.y + 16}, 6.0, 11.0, 0.0, 360.0, 0, ifx lastGesture == .GESTURE_DRAG then LIME else LIGHTGRAY);
            DrawCircle(cast(s32)lastGesturePosition.x + 80, cast(s32)lastGesturePosition.y + 43, 10, ifx lastGesture == .GESTURE_DOUBLETAP then SKYBLUE else LIGHTGRAY);
            DrawCircle(cast(s32)lastGesturePosition.x + 103, cast(s32)lastGesturePosition.y + 43, 10, ifx lastGesture == .GESTURE_DOUBLETAP then SKYBLUE else LIGHTGRAY);
            DrawTriangle(Vector2.{ lastGesturePosition.x + 122, lastGesturePosition.y + 16 }, Vector2.{ lastGesturePosition.x + 137, lastGesturePosition.y + 26 }, Vector2.{lastGesturePosition.x + 137, lastGesturePosition.y + 6 }, ifx lastGesture == .GESTURE_PINCH_OUT then ORANGE else LIGHTGRAY);
            DrawTriangle(Vector2.{ lastGesturePosition.x + 147, lastGesturePosition.y + 6 }, Vector2.{ lastGesturePosition.x + 147, lastGesturePosition.y + 26 }, Vector2.{ lastGesturePosition.x + 162, lastGesturePosition.y + 16 }, ifx lastGesture == .GESTURE_PINCH_OUT then ORANGE else LIGHTGRAY);
            DrawTriangle(Vector2.{ lastGesturePosition.x + 125, lastGesturePosition.y + 33 }, Vector2.{ lastGesturePosition.x + 125, lastGesturePosition.y + 53 }, Vector2.{ lastGesturePosition.x + 140, lastGesturePosition.y + 43 }, ifx lastGesture == .GESTURE_PINCH_IN then VIOLET else LIGHTGRAY);
            DrawTriangle(Vector2.{ lastGesturePosition.x + 144, lastGesturePosition.y + 43 }, Vector2.{ lastGesturePosition.x + 159, lastGesturePosition.y + 53 }, Vector2.{ lastGesturePosition.x + 159, lastGesturePosition.y + 33 }, ifx lastGesture == .GESTURE_PINCH_IN then VIOLET else LIGHTGRAY);
            for i: 0..3 DrawCircle(cast(s32)lastGesturePosition.x + 180, cast(s32)lastGesturePosition.y + 7 + cast(s32)i*15, 5, ifx touchCount <= i then LIGHTGRAY else gestureColor);

            // Draw gesture log
            DrawText("Log", cast(s32)gestureLogPosition.x, cast(s32)gestureLogPosition.y, 20, BLACK);

            // Loop in both directions to print the gesture log array in the inverted order (and looping around if the index started somewhere in the middle)
            i = 0; ii = gestureLogIndex;
            while (i < GESTURE_LOG_SIZE) {
                ii = (ii + 1)%GESTURE_LOG_SIZE;
                DrawText(gestureLog[ii].data, cast(s32)gestureLogPosition.x, cast(s32)gestureLogPosition.y + 410 - i*20, 20, ifx i == 0 then gestureColor else LIGHTGRAY);
                i += 1;
            }
            logButton1Color: Color; logButton2Color: Color;
            if logMode ==
            {
                case 3;  logButton1Color=MAROON; logButton2Color=MAROON;
                case 2;  logButton1Color=GRAY;   logButton2Color=MAROON;
                case 1;  logButton1Color=MAROON; logButton2Color=GRAY;
                case; logButton1Color=GRAY;   logButton2Color=GRAY;
            }
            DrawRectangleRec(logButton1, logButton1Color);
            DrawText("Hide", cast(s32)logButton1.x + 7, cast(s32)logButton1.y + 3, 10, WHITE);
            DrawText("Repeat", cast(s32)logButton1.x + 7, cast(s32)logButton1.y + 13, 10, WHITE);
            DrawRectangleRec(logButton2, logButton2Color);
            DrawText("Hide", cast(s32)logButton1.x + 62, cast(s32)logButton1.y + 3, 10, WHITE);
            DrawText("Hold", cast(s32)logButton1.x + 62, cast(s32)logButton1.y + 13, 10, WHITE);

            // Draw protractor
            DrawText("Angle", cast(s32)protractorPosition.x + 55, cast(s32)protractorPosition.y + 76, 10, BLACK);
            angleString: *u8 = TextFormat("%f", currentAngleDegrees);
            angleStringDot: s32 = TextFindIndex(angleString, ".");
            angleStringTrim: *u8 = TextSubtext(angleString, 0, angleStringDot + 3);
            DrawText(angleStringTrim, cast(s32)protractorPosition.x + 55, cast(s32)protractorPosition.y + 92, 20, gestureColor);
            DrawCircleV(protractorPosition, 80.0, WHITE);
            DrawLineEx(Vector2.{ protractorPosition.x - 90, protractorPosition.y }, Vector2.{ protractorPosition.x + 90, protractorPosition.y }, 3.0, LIGHTGRAY);
            DrawLineEx(Vector2.{ protractorPosition.x, protractorPosition.y - 90 }, Vector2.{ protractorPosition.x, protractorPosition.y + 90 }, 3.0, LIGHTGRAY);
            DrawLineEx(Vector2.{ protractorPosition.x - 80, protractorPosition.y - 45 }, Vector2.{ protractorPosition.x + 80, protractorPosition.y + 45 }, 3.0, GREEN);
            DrawLineEx(Vector2.{ protractorPosition.x - 80, protractorPosition.y + 45 }, Vector2.{ protractorPosition.x + 80, protractorPosition.y - 45 }, 3.0, GREEN);
            DrawText("0", cast(s32)protractorPosition.x + 96, cast(s32)protractorPosition.y - 9, 20, BLACK);
            DrawText("30", cast(s32)protractorPosition.x + 74, cast(s32)protractorPosition.y - 68, 20, BLACK);
            DrawText("90", cast(s32)protractorPosition.x - 11, cast(s32)protractorPosition.y - 110, 20, BLACK);
            DrawText("150", cast(s32)protractorPosition.x - 100, cast(s32)protractorPosition.y - 68, 20, BLACK);
            DrawText("180", cast(s32)protractorPosition.x - 124, cast(s32)protractorPosition.y - 9, 20, BLACK);
            DrawText("210", cast(s32)protractorPosition.x - 100, cast(s32)protractorPosition.y + 50, 20, BLACK);
            DrawText("270", cast(s32)protractorPosition.x - 18, cast(s32)protractorPosition.y + 92, 20, BLACK);
            DrawText("330", cast(s32)protractorPosition.x + 72, cast(s32)protractorPosition.y + 50, 20, BLACK);
            if (currentAngleDegrees != 0.0) DrawLineEx(protractorPosition, finalVector, 3.0, gestureColor);

            // Draw touch and mouse pointer points
            if (currentGesture != .GESTURE_NONE)
            {
                if (touchCount != 0)
                {
                    for i: 0..touchCount-1
                    {
                        DrawCircleV(touchPosition[i], 50.0, Fade(gestureColor, 0.5));
                        DrawCircleV(touchPosition[i], 5.0, gestureColor);
                    }

                    if (touchCount == 2) DrawLineEx(touchPosition[0], touchPosition[1], ifx (currentGesture == 512) then 8.0 else 12.0, gestureColor);
                }
                else
                {
                    DrawCircleV(mousePosition, 35.0, Fade(gestureColor, 0.5));
                    DrawCircleV(mousePosition, 5.0, gestureColor);
                }
            }

        EndDrawing();
        //--------------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Get text string for gesture value
GetGestureName :: (gesture: Gesture) -> *u8
{
    if gesture ==
    {
        case .GESTURE_NONE;        return "None";
        case .GESTURE_TAP;         return "Tap";
        case .GESTURE_DOUBLETAP;   return "Double Tap";
        case .GESTURE_HOLD;        return "Hold";
        case .GESTURE_DRAG;        return "Drag";
        case .GESTURE_SWIPE_RIGHT; return "Swipe Right";
        case .GESTURE_SWIPE_LEFT;  return "Swipe Left";
        case .GESTURE_SWIPE_UP;    return "Swipe Up";
        case .GESTURE_SWIPE_DOWN;  return "Swipe Down";
        case .GESTURE_PINCH_IN;    return "Pinch In";
        case .GESTURE_PINCH_OUT;   return "Pinch Out";
        case;                      return "Unknown";
    }
}

// Get color for gesture value
GetGestureColor :: (gesture: Gesture) -> Color
{
    if gesture ==
    {
        case .GESTURE_NONE;        return BLACK;
        case .GESTURE_TAP;         return BLUE;
        case .GESTURE_DOUBLETAP;   return SKYBLUE;
        case .GESTURE_HOLD;        return BLACK;
        case .GESTURE_DRAG;        return LIME;
        case .GESTURE_SWIPE_RIGHT; return RED;
        case .GESTURE_SWIPE_LEFT;  return RED;
        case .GESTURE_SWIPE_UP;    return RED;
        case .GESTURE_SWIPE_DOWN;  return RED;
        case .GESTURE_PINCH_IN;    return VIOLET;
        case .GESTURE_PINCH_OUT;   return ORANGE;
        case;                      return BLACK;
    }
}
