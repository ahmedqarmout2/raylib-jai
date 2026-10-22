#import "raylib";
#import "Basic";
#import "Math";

MAX_TEXT_LENGTH ::     64;
TEXT_SPACING ::         4;

// Animated text type
AnimatedText :: struct {
    str: *u8; // Text to animate
    position: Vector2;       // Text position on screen
    delta: float;            // Intensity of the effect (does not apply for flashing)
    offset: float;           // Time offset (in frames) between each char
    duration: float;         // Time duration (in frames) of the animation
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


    InitWindow(screenWidth, screenHeight, "raylib [text] example - animations");

    animations: [3]*u8 = .[ "Waving", "Flashing", "Shaking" ];
    animationsSize: s32 = animations.count;
    currentAnimation: s32 = 0;

    text: AnimatedText = .{ "This is an animated text!", .{ 200, 250 }, 24.0, 6, 60 };
    frameCount: s32 = 0;

    glyphPosition: [MAX_TEXT_LENGTH]Vector2;
    glyphAlpha: [MAX_TEXT_LENGTH]u8;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        frameCount += 1;

        if (IsKeyPressed(.KEY_S)) text.delta = Clamp(text.delta - 2.0, 10.0, 60.0);
        else if (IsKeyPressed(.KEY_W)) text.delta = Clamp(text.delta + 2.0, 10.0, 60.0);
        if (IsKeyPressed(.KEY_A)) text.duration = Clamp(text.duration - 5.0, 20.0, 120.0);
        else if (IsKeyPressed(.KEY_D)) text.duration = Clamp(text.duration + 5.0, 20.0, 120.0);
        if (IsKeyPressed(.KEY_Z)) text.offset = Clamp(text.offset - 1.0, 0.0, 15.0);
        else if (IsKeyPressed(.KEY_X)) text.offset = Clamp(text.offset + 1.0, 0.0, 15.0);
        if (IsKeyPressed(.KEY_Q)) currentAnimation = ifx currentAnimation then currentAnimation - 1 else animationsSize - 1;
        else if (IsKeyPressed(.KEY_E)) currentAnimation = (currentAnimation + 1)%animationsSize;

        i: u32 = 0;
        offsetX: s32 = 0;
        while (i < TextLength(text.str))
        {
            defer i += 1;

            // NOTE: Calculating every glyph position by its width
            glyphPosition[i] = Vector2.{ text.position.x + offsetX, text.position.y };
            glyphAlpha[i] = 255;

            offsetX += (MeasureText(TextSubtext(text.str, cast(s32)i, 1), 30) + TEXT_SPACING);
        }

        if currentAnimation ==
        {
            case 0; // Waving animation
            {
                for i: 0..TextLength(text.str)-1
                {
                    time: float = (cast(s32)(frameCount + i*text.offset)%cast(s32)text.duration) * 1.0;

                    if (time < text.duration/2) glyphPosition[i].y = EaseSineIn(time, text.position.y, text.delta, text.duration);
                    else glyphPosition[i].y = EaseSineOut(time, text.position.y + text.delta, -text.delta, text.duration);
                }
            }
            case 1; // Flashing animation
            {
                for i: 0..TextLength(text.str)-1
                {
                    time: float = (cast(s32) (frameCount + i*text.offset)%cast(s32)text.duration) * 1.0;
                    glyphAlpha[i] = cast(u8) EaseSineInOut(time, 255.0, -255.0, text.duration);
                }
            }
            case 2; // Shaking animation
            {
                for i: 0..TextLength(text.str)-1
                {
                    time: float = (cast(s32) (frameCount + i*text.offset)%cast(s32)text.duration) * 1.0;
                    deltaX: float = cast(float) GetRandomValue(-cast(s32)text.delta/10, cast(s32)text.delta/10);
                    deltaY: float = cast(float) GetRandomValue(-cast(s32)text.delta/10, cast(s32)text.delta/10);

                    if (time < (text.duration/2))
                    {
                        glyphPosition[i].x = EaseLinearNone(time, glyphPosition[i].x, deltaX, text.duration/2);
                        glyphPosition[i].y = EaseLinearNone(time, text.position.y, deltaY, text.duration/2);
                    }
                    else
                    {
                        glyphPosition[i].x = EaseLinearNone(time - text.duration/2, glyphPosition[i].x + deltaX, -deltaX, text.duration/2);
                        glyphPosition[i].y = EaseLinearNone(time - text.duration/2, text.position.y + deltaY, -deltaY, text.duration/2);
                    }
                }
            }
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawText(TextFormat("Duration (A | D): %d", cast(s32)text.duration), 20, 20, 20, GRAY);
        DrawText(TextFormat("Delta (W | S): %.1f", text.delta), 20, 50, 20, GRAY);
        DrawText(TextFormat("Offset (Z | X): %.1f", text.offset), 20, 80, 20, GRAY);
        DrawText(TextFormat("Curent Animation (Q | E): %s", animations[currentAnimation]), 20, 110, 20, GRAY);

        for i: 0..TextLength(text.str)-1
        {
            // NOTE: Drawing text glyph by glyph, so, spacing is actually not used
            DrawTextEx(GetFontDefault(), TextSubtext(text.str, cast(s32) i, 1), glyphPosition[i],
                GetFontDefault().baseSize*3.0, 0, Color.{ 200, 122, 255, glyphAlpha[i] });
        }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
