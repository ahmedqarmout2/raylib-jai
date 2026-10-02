#import "raylib";
#import "Basic";
#import "Math";

CLOCK_ANALOG  ::   0;
CLOCK_DIGITAL ::   1;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Clock hand type
ClockHand :: struct {
    value: s32;          // Time value

    // Visual elements
    angle: float;        // Hand angle
    length: s32;         // Hand length
    thickness: s32;      // Hand thickness
    color: Color;        // Hand color
};

// Clock hands
Clock :: struct {
    second: ClockHand;   // Clock hand for seconds
    minute: ClockHand;   // Clock hand for minutes
    hour: ClockHand;     // Clock hand for hours
};

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
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - digital clock");

    clockMode: s32 = CLOCK_DIGITAL;

    // Initialize clock
    // NOTE: Includes visual info for anlaog clock
    clock: Clock;
    clock.second.angle = 45;
    clock.second.length = 140;
    clock.second.thickness = 3;
    clock.second.color = MAROON;

    clock.minute.angle = 10;
    clock.minute.length = 130;
    clock.minute.thickness = 7;
    clock.minute.color = DARKGRAY;

    clock.hour.angle = 0;
    clock.hour.length = 100;
    clock.hour.thickness = 7;
    clock.hour.color = BLACK;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE))
        {
            // Toggle clock mode
            if (clockMode == CLOCK_DIGITAL) clockMode = CLOCK_ANALOG;
            else if (clockMode == CLOCK_ANALOG) clockMode = CLOCK_DIGITAL;
        }

        UpdateClock(*clock); // Update clock required data: value and angle
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw clock in selected mode
            if (clockMode == CLOCK_ANALOG) DrawClockAnalog(clock, Vector2.{ 400, 240 });
            else if (clockMode == CLOCK_DIGITAL)
            {
                DrawClockDigital(clock, Vector2.{ 30, 60 });

                // Draw clock using default raylib font
                // Get pointer to formated clock time string
                // WARNING: Pointing to an internal static string that is reused between TextFormat() calls
                clockTime: *u8 = TextFormat("%02i:%02i:%02i", clock.hour.value, clock.minute.value, clock.second.value);
                DrawText(clockTime, GetScreenWidth()/2 - MeasureText(clockTime, 150)/2, 300, 150, BLACK);
            }

            DrawText(TextFormat("Press [SPACE] to switch clock mode: %s",
                temp_c_string(ifx (clockMode == CLOCK_DIGITAL) then "DIGITAL CLOCK" else "ANALOGUE CLOCK")), 10, 10, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Update clock time
UpdateClock :: (clock: *Clock)
{
    timeinfo := to_calendar(current_time_consensus(), .LOCAL);

    // Updating time data
    clock.second.value = timeinfo.second;
    clock.minute.value = timeinfo.minute;
    clock.hour.value = timeinfo.hour;

    clock.hour.angle = (timeinfo.hour%12)*180.0/6.0;
    clock.hour.angle += (timeinfo.minute%60)*30/60.0;
    clock.hour.angle -= 90;

    clock.minute.angle = (timeinfo.minute%60)*6.0;
    clock.minute.angle += (timeinfo.second%60)*6/60.0;
    clock.minute.angle -= 90;

    clock.second.angle = (timeinfo.second%60)*6.0;
    clock.second.angle -= 90;
}

// Draw analog clock
// Parameter: position, refers to center position
DrawClockAnalog :: (clock: Clock, position: Vector2)
{
        // Draw clock base
        DrawCircleV(position, clock.second.length + 40.0, LIGHTGRAY);
        DrawCircleV(position, 12.0, GRAY);

        // Draw clock minutes/seconds lines
        for i: 0..59
        {
            DrawLineEx(Vector2.{ position.x + (clock.second.length + (ifx (i%5) then 10 else 6))*cos((6.0*i - 90.0)*DEG2RAD),
                position.y + (clock.second.length + (ifx (i%5) then 10 else 6))*sin((6.0*i - 90.0)*DEG2RAD) },
                Vector2.{ position.x + (clock.second.length + 20)*cos((6.0*i - 90.0)*DEG2RAD),
                position.y + (clock.second.length + 20)*sin((6.0*i - 90.0)*DEG2RAD) }, (ifx (i%5) then 1.0 else 3.0), DARKGRAY);

            // Draw seconds numbers
            //DrawText(TextFormat("%02i", i), centerPosition.x + (clock.second.length + 50)*cosf((6.0*i - 90.0)*DEG2RAD) - 10/2,
            //    centerPosition.y + (clock.second.length + 50)*sinf((6.0*i - 90.0)*DEG2RAD) - 10/2, 10, GRAY);
        }

        // Draw hand seconds
        DrawRectanglePro(Rectangle.{ position.x, position.y, cast(float)clock.second.length, cast(float)clock.second.thickness },
            Vector2.{ 0.0, clock.second.thickness/2.0 }, clock.second.angle, clock.second.color);

        // Draw hand minutes
        DrawRectanglePro(Rectangle.{ position.x, position.y, cast(float)clock.minute.length, cast(float)clock.minute.thickness },
            Vector2.{ 0.0, clock.minute.thickness/2.0 }, clock.minute.angle, clock.minute.color);

        // Draw hand hours
        DrawRectanglePro(Rectangle.{ position.x, position.y, cast(float)clock.hour.length, cast(float)clock.hour.thickness },
            Vector2.{ 0.0, clock.hour.thickness/2.0 }, clock.hour.angle, clock.hour.color);
}

// Draw digital clock
// PARAM: position, refers to top-left corner
DrawClockDigital :: (clock: Clock, position: Vector2)
{
    // Draw clock using custom 7-segments display (made of shapes)
    DrawDisplayValue(Vector2.{ position.x, position.y }, clock.hour.value/10, RED, Fade(LIGHTGRAY, 0.3));
    DrawDisplayValue(Vector2.{ position.x + 120, position.y }, clock.hour.value%10, RED, Fade(LIGHTGRAY, 0.3));

    DrawCircle(cast(s32)position.x + 240, cast(s32)position.y + 70, 12, ifx (clock.second.value%2) then RED else Fade(LIGHTGRAY, 0.3));
    DrawCircle(cast(s32)position.x + 240, cast(s32)position.y + 150, 12, ifx (clock.second.value%2) then RED else Fade(LIGHTGRAY, 0.3));

    DrawDisplayValue(Vector2.{ position.x + 260, position.y }, clock.minute.value/10, RED, Fade(LIGHTGRAY, 0.3));
    DrawDisplayValue(Vector2.{ position.x + 380, position.y }, clock.minute.value%10, RED, Fade(LIGHTGRAY, 0.3));

    DrawCircle(cast(s32)position.x + 500, cast(s32)position.y + 70, 12, ifx (clock.second.value%2) then RED else Fade(LIGHTGRAY, 0.3));
    DrawCircle(cast(s32)position.x + 500, cast(s32)position.y + 150, 12, ifx (clock.second.value%2) then RED else Fade(LIGHTGRAY, 0.3));

    DrawDisplayValue(Vector2.{ position.x + 520, position.y }, clock.second.value/10, RED, Fade(LIGHTGRAY, 0.3));
    DrawDisplayValue(Vector2.{ position.x + 640, position.y }, clock.second.value%10, RED, Fade(LIGHTGRAY, 0.3));
}

// Draw 7-segment display with value
DrawDisplayValue :: (position: Vector2, value: s32, colorOn: Color, colorOff: Color)
{
    if value ==
    {
        case 0; Draw7SDisplay(position, 0b00111111, colorOn, colorOff);
        case 1; Draw7SDisplay(position, 0b00000110, colorOn, colorOff);
        case 2; Draw7SDisplay(position, 0b01011011, colorOn, colorOff);
        case 3; Draw7SDisplay(position, 0b01001111, colorOn, colorOff);
        case 4; Draw7SDisplay(position, 0b01100110, colorOn, colorOff);
        case 5; Draw7SDisplay(position, 0b01101101, colorOn, colorOff);
        case 6; Draw7SDisplay(position, 0b01111101, colorOn, colorOff);
        case 7; Draw7SDisplay(position, 0b00000111, colorOn, colorOff);
        case 8; Draw7SDisplay(position, 0b01111111, colorOn, colorOff);
        case 9; Draw7SDisplay(position, 0b01101111, colorOn, colorOff);
    }
}

// Draw seven segments display
// Parameter: position, refers to top-left corner of display
// Parameter: segments, defines in binary the segments to be activated
Draw7SDisplay :: (position: Vector2, segments: u8, colorOn: Color, colorOff: Color)
{
    segmentLen: s32 = 60;
    segmentThick: s32 = 20;
    offsetYAdjust: float = segmentThick*0.3; // HACK: Adjust gap space between segment limits

    // Segment A
    DrawDisplaySegment(Vector2.{ position.x + segmentThick + segmentLen/2.0, position.y + segmentThick },
        segmentLen, segmentThick, false, ifx (segments & 0b00000001) then colorOn else colorOff);
    // Segment B
    DrawDisplaySegment(Vector2.{ position.x + segmentThick + segmentLen + segmentThick/2.0, position.y + 2*segmentThick + segmentLen/2.0 - offsetYAdjust },
        segmentLen, segmentThick, true, ifx (segments & 0b00000010) then colorOn else colorOff);
    // Segment C
    DrawDisplaySegment(Vector2.{ position.x + segmentThick + segmentLen + segmentThick/2.0, position.y + 4*segmentThick + segmentLen + segmentLen/2.0 - 3*offsetYAdjust },
        segmentLen, segmentThick, true, ifx (segments & 0b00000100) then colorOn else colorOff);
    // Segment D
    DrawDisplaySegment(Vector2.{ position.x + segmentThick + segmentLen/2.0, position.y + 5*segmentThick + 2*segmentLen - 4*offsetYAdjust },
        segmentLen, segmentThick, false, ifx (segments & 0b00001000) then colorOn else colorOff);
    // Segment E
    DrawDisplaySegment(Vector2.{ position.x + segmentThick/2.0, position.y + 4*segmentThick + segmentLen + segmentLen/2.0 - 3*offsetYAdjust },
        segmentLen, segmentThick, true, ifx (segments & 0b00010000) then colorOn else colorOff);
    // Segment F
    DrawDisplaySegment(Vector2.{ position.x + segmentThick/2.0, position.y + 2*segmentThick + segmentLen/2.0 - offsetYAdjust },
        segmentLen, segmentThick, true, ifx (segments & 0b00100000) then colorOn else colorOff);
    // Segment G
    DrawDisplaySegment(Vector2.{ position.x + segmentThick + segmentLen/2.0, position.y + 3*segmentThick + segmentLen - 2*offsetYAdjust },
        segmentLen, segmentThick, false, ifx (segments & 0b01000000) then colorOn else colorOff);
}

// Draw one 7-segment display segment, horizontal or vertical
DrawDisplaySegment :: (center: Vector2, length: s32, thick: s32, vertical: bool, color: Color)
{
    if (!vertical)
    {
        // Horizontal segment points
        /*
             3___________________________5
            /                             \
           /1             x               6\
           \                               /
            \2___________________________4/
        */
        segmentPointsH: [6]Vector2 = .[
            Vector2.{ center.x - length/2.0 - thick/2.0,  center.y },  // Point 1
            Vector2.{ center.x - length/2.0,  center.y + thick/2.0 },  // Point 2
            Vector2.{ center.x - length/2.0, center.y - thick/2.0 },   // Point 3
            Vector2.{ center.x + length/2.0,  center.y + thick/2.0 },  // Point 4
            Vector2.{ center.x + length/2.0,  center.y - thick/2.0 },  // Point 5
            Vector2.{ center.x + length/2.0 + thick/2.0,  center.y },  // Point 6
        ];

        DrawTriangleStrip(segmentPointsH.data, 6, color);
    }
    else
    {
        // Vertical segment points
        segmentPointsV: [6]Vector2 = .[
            Vector2.{ center.x,  center.y - length/2.0 - thick/2.0 },  // Point 1
            Vector2.{ center.x - thick/2.0,  center.y - length/2.0 },  // Point 2
            Vector2.{ center.x + thick/2.0, center.y - length/2.0 },   // Point 3
            Vector2.{ center.x - thick/2.0,  center.y + length/2.0 },  // Point 4
            Vector2.{ center.x + thick/2.0,  center.y + length/2.0 },  // Point 5
            Vector2.{ center.x,  center.y + cast(float)length/2 + thick/2.0 },     // Point 6
        ];

        DrawTriangleStrip(segmentPointsV.data, 6, color);
    }
}
