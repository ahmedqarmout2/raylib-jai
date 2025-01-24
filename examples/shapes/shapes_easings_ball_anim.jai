#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings ball anim");

    // Ball variable value to be animated with easings
    ballPositionX: s32 = -100;
    ballRadius: s32 = 20;
    ballAlpha: float = 0.0;

    state: s32 = 0;
    framesCounter: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (state == 0)             // Move ball position X with easing
        {
            framesCounter += 1;
            ballPositionX = cast(s32)EaseElasticOut(cast(float)framesCounter, -100, screenWidth/2.0 + 100, 120);

            if (framesCounter >= 120)
            {
                framesCounter = 0;
                state = 1;
            }
        }
        else if (state == 1)        // Increase ball radius with easing
        {
            framesCounter += 1;
            ballRadius = cast(s32)EaseElasticIn(cast(float)framesCounter, 20, 500, 200);

            if (framesCounter >= 200)
            {
                framesCounter = 0;
                state = 2;
            }
        }
        else if (state == 2)        // Change ball alpha with easing (background color blending)
        {
            framesCounter += 1;
            ballAlpha = EaseCubicOut(cast(float)framesCounter, 0.0, 1.0, 200);

            if (framesCounter >= 200)
            {
                framesCounter = 0;
                state = 3;
            }
        }
        else if (state == 3)        // Reset state to play again
        {
            if (IsKeyPressed(.KEY_ENTER))
            {
                // Reset required variables to play again
                ballPositionX = -100;
                ballRadius = 20;
                ballAlpha = 0.0;
                state = 0;
            }
        }

        if (IsKeyPressed(.KEY_R)) framesCounter = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (state >= 2) DrawRectangle(0, 0, screenWidth, screenHeight, GREEN);
            DrawCircle(ballPositionX, 200, cast(float)ballRadius, Fade(RED, 1.0 - ballAlpha));

            if (state == 3) DrawText("PRESS [ENTER] TO PLAY AGAIN!", 240, 200, 20, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
