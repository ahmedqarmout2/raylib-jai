#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings box anim");

    // Box variables to be animated with easings
    rec: Rectangle = .{ GetScreenWidth()/2.0, -100, 100, 100 };
    rotation: float = 0.0;
    alpha: float = 1.0;

    state: s32 = 0;
    framesCounter: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if state == {
            case 0;     // Move box down to center of screen
            {
                framesCounter += 1;

                // NOTE: Remember that 3rd parameter of easing function refers to
                // desired value variation, do not confuse it with expected final value!
                rec.y = EaseElasticOut(cast(float)framesCounter, -100, GetScreenHeight()/2.0 + 100, 120);

                if (framesCounter >= 120)
                {
                    framesCounter = 0;
                    state = 1;
                }
            }
            case 1;     // Scale box to an horizontal bar
            {
                framesCounter += 1;
                rec.height = EaseBounceOut(cast(float)framesCounter, 100, -90, 120);
                rec.width = EaseBounceOut(cast(float)framesCounter, 100, cast(float)GetScreenWidth(), 120);

                if (framesCounter >= 120)
                {
                    framesCounter = 0;
                    state = 2;
                }
            }
            case 2;     // Rotate horizontal bar rectangle
            {
                framesCounter += 1;
                rotation = EaseQuadOut(cast(float)framesCounter, 0.0, 270.0, 240);

                if (framesCounter >= 240)
                {
                    framesCounter = 0;
                    state = 3;
                }
            }
            case 3;     // Increase bar size to fill all screen
            {
                framesCounter += 1;
                rec.height = EaseCircOut(cast(float)framesCounter, 10, cast(float)GetScreenWidth(), 120);

                if (framesCounter >= 120)
                {
                    framesCounter = 0;
                    state = 4;
                }
            }
            case 4;     // Fade out animation
            {
                framesCounter += 1;
                alpha = EaseSineOut(cast(float)framesCounter, 1.0, -1.0, 160);

                if (framesCounter >= 160)
                {
                    framesCounter = 0;
                    state = 5;
                }
            }
        }

        // Reset animation at any moment
        if (IsKeyPressed(.KEY_SPACE))
        {
            rec = Rectangle.{ GetScreenWidth()/2.0, -100, 100, 100 };
            rotation = 0.0;
            alpha = 1.0;
            state = 0;
            framesCounter = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawRectanglePro(rec, Vector2.{ rec.width/2, rec.height/2 }, rotation, Fade(BLACK, alpha));

            DrawText("PRESS [SPACE] TO RESET BOX ANIMATION!", 10, GetScreenHeight() - 25, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
