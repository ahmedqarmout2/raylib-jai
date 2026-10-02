#import "raylib";
#import "Basic";
#import "Math";

FONT_SIZE ::         20;

D_STEP ::        20.0;
D_STEP_FINE ::    2.0;
D_MIN ::          1.0;
D_MAX ::       10000.0;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Easing types
EasingTypes :: enum s32 {
    EASE_LINEAR_NONE :: 0;
    EASE_LINEAR_IN;
    EASE_LINEAR_OUT;
    EASE_LINEAR_IN_OUT;
    EASE_SINE_IN;
    EASE_SINE_OUT;
    EASE_SINE_IN_OUT;
    EASE_CIRC_IN;
    EASE_CIRC_OUT;
    EASE_CIRC_IN_OUT;
    EASE_CUBIC_IN;
    EASE_CUBIC_OUT;
    EASE_CUBIC_IN_OUT;
    EASE_QUAD_IN;
    EASE_QUAD_OUT;
    EASE_QUAD_IN_OUT;
    EASE_EXPO_IN;
    EASE_EXPO_OUT;
    EASE_EXPO_IN_OUT;
    EASE_BACK_IN;
    EASE_BACK_OUT;
    EASE_BACK_IN_OUT;
    EASE_BOUNCE_OUT;
    EASE_BOUNCE_IN;
    EASE_BOUNCE_IN_OUT;
    EASE_ELASTIC_IN;
    EASE_ELASTIC_OUT;
    EASE_ELASTIC_IN_OUT;
    EASING_NONE;
    NUM_EASING_TYPES;
};

EasingFuncs :: struct {
    name: *u8;
    func: (t: float, b: float, c: float, d: float) -> float;
};

//------------------------------------------------------------------------------------
// Global Variables Definition
//------------------------------------------------------------------------------------
// Easing functions reference data
easings: [cast(s32)EasingTypes.NUM_EASING_TYPES]EasingFuncs = .[
    .{ name = "EaseLinearNone", func = EaseLinearNone },
    .{ name = "EaseLinearIn", func = EaseLinearIn },
    .{ name = "EaseLinearOut", func = EaseLinearOut },
    .{ name = "EaseLinearInOut", func = EaseLinearInOut },
    .{ name = "EaseSineIn", func = EaseSineIn },
    .{ name = "EaseSineOut", func = EaseSineOut },
    .{ name = "EaseSineInOut", func = EaseSineInOut },
    .{ name = "EaseCircIn", func = EaseCircIn },
    .{ name = "EaseCircOut", func = EaseCircOut },
    .{ name = "EaseCircInOut", func = EaseCircInOut },
    .{ name = "EaseCubicIn", func = EaseCubicIn },
    .{ name = "EaseCubicOut", func = EaseCubicOut },
    .{ name = "EaseCubicInOut", func = EaseCubicInOut },
    .{ name = "EaseQuadIn", func = EaseQuadIn },
    .{ name = "EaseQuadOut", func = EaseQuadOut },
    .{ name = "EaseQuadInOut", func = EaseQuadInOut },
    .{ name = "EaseExpoIn", func = EaseExpoIn },
    .{ name = "EaseExpoOut", func = EaseExpoOut },
    .{ name = "EaseExpoInOut", func = EaseExpoInOut },
    .{ name = "EaseBackIn", func = EaseBackIn },
    .{ name = "EaseBackOut", func = EaseBackOut },
    .{ name = "EaseBackInOut", func = EaseBackInOut },
    .{ name = "EaseBounceOut", func = EaseBounceOut },
    .{ name = "EaseBounceIn", func = EaseBounceIn },
    .{ name = "EaseBounceInOut", func = EaseBounceInOut },
    .{ name = "EaseElasticIn", func = EaseElasticIn },
    .{ name = "EaseElasticOut", func = EaseElasticOut },
    .{ name = "EaseElasticInOut", func = EaseElasticInOut },
    .{ name = "None", func = NoEase },
];

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings testbed");

    ballPosition: Vector2 = .{ 100.0, 100.0 };

    t: float = 0.0;             // Current time (in any unit measure, but same unit as duration)
    d: float = 300.0;           // Total time it should take to complete (duration)
    paused: bool = true;
    boundedT: bool = true;       // If true, t will stop when d >= td, otherwise t will keep adding td to its value every loop

    easingX: s32 = cast(s32)EasingTypes.EASING_NONE;  // Easing selected for x axis
    easingY: s32 = cast(s32)EasingTypes.EASING_NONE;  // Easing selected for y axis

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_T)) boundedT = !boundedT;

        // Choose easing for the X axis
        if (IsKeyPressed(.KEY_RIGHT))
        {
            easingX += 1;

            if (easingX > cast(s32)EasingTypes.EASING_NONE) easingX = 0;
        }
        else if (IsKeyPressed(.KEY_LEFT))
        {
            if (easingX == 0) easingX = cast(s32)EasingTypes.EASING_NONE;
            else easingX -= 1;
        }

        // Choose easing for the Y axis
        if (IsKeyPressed(.KEY_DOWN))
        {
            easingY += 1;

            if (easingY > cast(s32)EasingTypes.EASING_NONE) easingY = 0;
        }
        else if (IsKeyPressed(.KEY_UP))
        {
            if (easingY == 0) easingY = cast(s32)EasingTypes.EASING_NONE;
            else easingY -= 1;
        }

        // Change d (duration) value
        if (IsKeyPressed(.KEY_W) && (d < D_MAX - D_STEP)) d += D_STEP;
        else if (IsKeyPressed(.KEY_Q) && (d > D_MIN + D_STEP)) d -= D_STEP;

        if (IsKeyDown(.KEY_S) && (d < D_MAX - D_STEP_FINE)) d += D_STEP_FINE;
        else if (IsKeyDown(.KEY_A) && (d > D_MIN + D_STEP_FINE)) d -= D_STEP_FINE;

        // Play, pause and restart controls
        if (IsKeyPressed(.KEY_SPACE) || IsKeyPressed(.KEY_T) ||
            IsKeyPressed(.KEY_RIGHT) || IsKeyPressed(.KEY_LEFT) ||
            IsKeyPressed(.KEY_DOWN) || IsKeyPressed(.KEY_UP) ||
            IsKeyPressed(.KEY_W) || IsKeyPressed(.KEY_Q) ||
            IsKeyDown(.KEY_S)  || IsKeyDown(.KEY_A) ||
            (IsKeyPressed(.KEY_ENTER) && (boundedT == true) && (t >= d)))
        {
            t = 0.0;
            ballPosition.x = 100.0;
            ballPosition.y = 100.0;
            paused = true;
        }

        if (IsKeyPressed(.KEY_ENTER)) paused = !paused;

        // Movement computation
        if (!paused && ((boundedT && t < d) || !boundedT))
        {
            ballPosition.x = easings[easingX].func(t, 100.0, 700.0 - 170.0, d);
            ballPosition.y = easings[easingY].func(t, 100.0, 400.0 - 170.0, d);
            t += 1.0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw information text
            DrawText(TextFormat("Easing x: %s", easings[easingX].name), 20, FONT_SIZE, FONT_SIZE, LIGHTGRAY);
            DrawText(TextFormat("Easing y: %s", easings[easingY].name), 20, FONT_SIZE*2, FONT_SIZE, LIGHTGRAY);
            DrawText(TextFormat("t (%c) = %.2f d = %.2f", ifx (boundedT == true) then #char "b" else #char "u", t, d), 20, FONT_SIZE*3, FONT_SIZE, LIGHTGRAY);

            // Draw instructions text
            DrawText("Use ENTER to play or pause movement, use SPACE to restart", 20, GetScreenHeight() - FONT_SIZE*2, FONT_SIZE, LIGHTGRAY);
            DrawText("Use Q and W or A and S keys to change duration", 20, GetScreenHeight() - FONT_SIZE*3, FONT_SIZE, LIGHTGRAY);
            DrawText("Use LEFT or RIGHT keys to choose easing for the x axis", 20, GetScreenHeight() - FONT_SIZE*4, FONT_SIZE, LIGHTGRAY);
            DrawText("Use UP or DOWN keys to choose easing for the y axis", 20, GetScreenHeight() - FONT_SIZE*5, FONT_SIZE, LIGHTGRAY);

            // Draw ball
            DrawCircleV(ballPosition, 16.0, MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Declaration
//------------------------------------------------------------------------------------
// NoEase function, used when "no easing" is selected for any axis
// It just ignores all parameters besides b
NoEase :: (t: float, b: float, c: float, d: float) -> float
{
    // Hack to avoid compiler warning (about unused variables)
    burn: float = t + b + c + d;
    d += burn;

    return b;
}
