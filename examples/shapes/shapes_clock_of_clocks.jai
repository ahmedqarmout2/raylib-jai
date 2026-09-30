#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - clock of clocks");

    bgColor: Color = ColorLerp(DARKBLUE, BLACK, 0.75);
    handsColor: Color = ColorLerp(YELLOW, RAYWHITE, .25);

    clockFaceSize: float = 24;
    clockFaceSpacing: float = 8.0;
    sectionSpacing: float = 16.0;

    TL: Vector2 = Vector2.{   0.0,  90.0 }; // Top-left corner
    TR: Vector2 = Vector2.{  90.0, 180.0 }; // Top-right corner
    BR: Vector2 = Vector2.{ 180.0, 270.0 }; // Bottom-right corner
    BL: Vector2 = Vector2.{   0.0, 270.0 }; // Bottom-left corner
    HH: Vector2 = Vector2.{   0.0, 180.0 }; // Horizontal line
    VV: Vector2 = Vector2.{  90.0, 270.0 }; // Vertical line
    ZZ: Vector2 = Vector2.{ 135.0, 135.0 }; // Not relevant

    digitAngles: [10][24]Vector2 = .[
        /* 0 */ .[ TL,HH,HH,TR, /* */ VV,TL,TR,VV,/* */ VV,VV,VV,VV,/* */ VV,VV,VV,VV,/* */ VV,BL,BR,VV,/* */ BL,HH,HH,BR ],
        /* 1 */ .[ TL,HH,TR,ZZ, /* */ BL,TR,VV,ZZ,/* */ ZZ,VV,VV,ZZ,/* */ ZZ,VV,VV,ZZ,/* */ TL,BR,BL,TR,/* */ BL,HH,HH,BR ],
        /* 2 */ .[ TL,HH,HH,TR, /* */ BL,HH,TR,VV,/* */ TL,HH,BR,VV,/* */ VV,TL,HH,BR,/* */ VV,BL,HH,TR,/* */ BL,HH,HH,BR ],
        /* 3 */ .[ TL,HH,HH,TR, /* */ BL,HH,TR,VV,/* */ TL,HH,BR,VV,/* */ BL,HH,TR,VV,/* */ TL,HH,BR,VV,/* */ BL,HH,HH,BR ],
        /* 4 */ .[ TL,TR,TL,TR, /* */ VV,VV,VV,VV,/* */ VV,BL,BR,VV,/* */ BL,HH,TR,VV,/* */ ZZ,ZZ,VV,VV,/* */ ZZ,ZZ,BL,BR ],
        /* 5 */ .[ TL,HH,HH,TR, /* */ VV,TL,HH,BR,/* */ VV,BL,HH,TR,/* */ BL,HH,TR,VV,/* */ TL,HH,BR,VV,/* */ BL,HH,HH,BR ],
        /* 6 */ .[ TL,HH,HH,TR, /* */ VV,TL,HH,BR,/* */ VV,BL,HH,TR,/* */ VV,TL,TR,VV,/* */ VV,BL,BR,VV,/* */ BL,HH,HH,BR ],
        /* 7 */ .[ TL,HH,HH,TR, /* */ BL,HH,TR,VV,/* */ ZZ,ZZ,VV,VV,/* */ ZZ,ZZ,VV,VV,/* */ ZZ,ZZ,VV,VV,/* */ ZZ,ZZ,BL,BR ],
        /* 8 */ .[ TL,HH,HH,TR, /* */ VV,TL,TR,VV,/* */ VV,BL,BR,VV,/* */ VV,TL,TR,VV,/* */ VV,BL,BR,VV,/* */ BL,HH,HH,BR ],
        /* 9 */ .[ TL,HH,HH,TR, /* */ VV,TL,TR,VV,/* */ VV,BL,BR,VV,/* */ BL,HH,TR,VV,/* */ TL,HH,BR,VV,/* */ BL,HH,HH,BR ],
    ];

    // Time for the hands to move to the new position (in seconds); this must be <1s
    handsMoveDuration: float = 0.5;

    prevSeconds: s32 = -1;
    currentAngles: [6][24]Vector2;
    srcAngles: [6][24]Vector2;
    dstAngles: [6][24]Vector2;

    handsMoveTimer: float = 0.0;
    hourMode: s32 = 24;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Get the current time
        timeinfo := to_calendar(current_time_consensus(), .LOCAL);

        if (timeinfo.second != prevSeconds)
        {
            // The time has changed, so we need to move the hands to the new positions
            prevSeconds = timeinfo.second;

            // Format the current time so we can access the individual digits
            clockDigits: *u8 = TextFormat("%02d%02d%02d", timeinfo.hour%hourMode, timeinfo.minute, timeinfo.second);

            // Fetch where we want all the hands to be
            for digit: 0..5
            {
                for cell: 0..23
                {
                    srcAngles[digit][cell] = currentAngles[digit][cell];
                    dstAngles[digit][cell] = digitAngles[clockDigits[digit] - #char"0"][cell];

                    // Quick exception for 12h mode
                    if ((digit == 0) && (hourMode == 12) && (clockDigits[0] == #char"0")) dstAngles[digit][cell] = ZZ;
                    if (srcAngles[digit][cell].x > dstAngles[digit][cell].x) srcAngles[digit][cell].x -= 360.0;
                    if (srcAngles[digit][cell].y > dstAngles[digit][cell].y) srcAngles[digit][cell].y -= 360.0;
                }
            }

            // Reset the timer
            handsMoveTimer = -GetFrameTime();
        }

        // Now let's animate all the hands if we need to
        if (handsMoveTimer < handsMoveDuration)
        {
            // Increase the timer but don't go above the maximum
            handsMoveTimer = Clamp(handsMoveTimer + GetFrameTime(), 0, handsMoveDuration);

            // Calculate the%completion of the animation
            t: float = handsMoveTimer/handsMoveDuration;

            // A little cheeky smoothstep
            t = t*t*(3.0 - 2.0*t);

            for digit: 0..5
            {
                for cell: 0..23
                {
                    currentAngles[digit][cell].x = Lerp(srcAngles[digit][cell].x, dstAngles[digit][cell].x, t);
                    currentAngles[digit][cell].y = Lerp(srcAngles[digit][cell].y, dstAngles[digit][cell].y, t);
                }
            }
        }

        // Handle input
        if (IsKeyPressed(.KEY_SPACE)) hourMode = 36 - hourMode; // Toggle between 12 and 24 hour mode with space
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(bgColor);

            DrawText(TextFormat("%d-h mode, space to change", hourMode), 10, 30, 20, RAYWHITE);

            xOffset: float = 4.0;

            for digit: 0..5
            {
                for row: 0..5
                {
                    for col: 0..3
                    {
                        centre: Vector2 = Vector2.{
                            xOffset + col*(clockFaceSize+clockFaceSpacing) + clockFaceSize*0.5,
                            100 + row*(clockFaceSize+clockFaceSpacing) + clockFaceSize*0.5
                        };

                        DrawRing(centre, clockFaceSize*0.5 - 2.0, clockFaceSize*0.5, 0, 360, 24, DARKGRAY);

                        // Big hand
                        DrawRectanglePro(
                            Rectangle.{centre.x, centre.y, clockFaceSize*0.5+4.0, 4.0},
                            Vector2.{ 2.0, 2.0 },
                            currentAngles[digit][row*4+col].x,
                            handsColor
                        );

                        // Little hand
                        DrawRectanglePro(
                            Rectangle.{centre.x, centre.y, clockFaceSize*0.5+2.0, 4.0},
                            Vector2.{ 2.0, 2.0 },
                            currentAngles[digit][row*4+col].y,
                            handsColor
                        );
                    }
                }

                xOffset += (clockFaceSize+clockFaceSpacing)*4;
                if (digit%2 == 1)
                {
                    DrawRing(Vector2.{xOffset + 4.0, 160.0}, 6.0, 8.0, 0.0, 360.0, 24, handsColor);
                    DrawRing(Vector2.{xOffset + 4.0, 225.0}, 6.0, 8.0, 0.0, 360.0, 24, handsColor);
                    xOffset += sectionSpacing;
                }
            }

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}