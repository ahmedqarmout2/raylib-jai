#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - raylib logo animation");

    logoPositionX: s32 = screenWidth/2 - 128;
    logoPositionY: s32 = screenHeight/2 - 128;

    framesCounter: s32 = 0;
    lettersCount: s32 = 0;

    topSideRecWidth: s32 = 16;
    leftSideRecHeight: s32 = 16;

    bottomSideRecWidth: s32 = 16;
    rightSideRecHeight: s32 = 16;

    state: s32 = 0;                  // Tracking animation states (State Machine)
    alpha: float = 1.0;             // Useful for fading

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (state == 0)                 // State 0: Small box blinking
        {
            framesCounter += 1;

            if (framesCounter == 120)
            {
                state = 1;
                framesCounter = 0;      // Reset counter... will be used later...
            }
        }
        else if (state == 1)            // State 1: Top and left bars growing
        {
            topSideRecWidth += 4;
            leftSideRecHeight += 4;

            if (topSideRecWidth == 256) state = 2;
        }
        else if (state == 2)            // State 2: Bottom and right bars growing
        {
            bottomSideRecWidth += 4;
            rightSideRecHeight += 4;

            if (bottomSideRecWidth == 256) state = 3;
        }
        else if (state == 3)            // State 3: Letters appearing (one by one)
        {
            framesCounter += 1;

            if (framesCounter/12)       // Every 12 frames, one more letter!
            {
                lettersCount += 1;
                framesCounter = 0;
            }

            if (lettersCount >= 10)     // When all letters have appeared, just fade out everything
            {
                alpha -= 0.02;

                if (alpha <= 0.0)
                {
                    alpha = 0.0;
                    state = 4;
                }
            }
        }
        else if (state == 4)            // State 4: Reset and Replay
        {
            if (IsKeyPressed(.KEY_R))
            {
                framesCounter = 0;
                lettersCount = 0;

                topSideRecWidth = 16;
                leftSideRecHeight = 16;

                bottomSideRecWidth = 16;
                rightSideRecHeight = 16;

                alpha = 1.0;
                state = 0;          // Return to State 0
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (state == 0)
            {
                if ((framesCounter/15)%2) DrawRectangle(logoPositionX, logoPositionY, 16, 16, BLACK);
            }
            else if (state == 1)
            {
                DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK);
                DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK);
            }
            else if (state == 2)
            {
                DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, BLACK);
                DrawRectangle(logoPositionX, logoPositionY, 16, leftSideRecHeight, BLACK);

                DrawRectangle(logoPositionX + 240, logoPositionY, 16, rightSideRecHeight, BLACK);
                DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, BLACK);
            }
            else if (state == 3)
            {
                DrawRectangle(logoPositionX, logoPositionY, topSideRecWidth, 16, Fade(BLACK, alpha));
                DrawRectangle(logoPositionX, logoPositionY + 16, 16, leftSideRecHeight - 32, Fade(BLACK, alpha));

                DrawRectangle(logoPositionX + 240, logoPositionY + 16, 16, rightSideRecHeight - 32, Fade(BLACK, alpha));
                DrawRectangle(logoPositionX, logoPositionY + 240, bottomSideRecWidth, 16, Fade(BLACK, alpha));

                DrawRectangle(GetScreenWidth()/2 - 112, GetScreenHeight()/2 - 112, 224, 224, Fade(RAYWHITE, alpha));

                DrawText(TextSubtext("raylib", 0, lettersCount), GetScreenWidth()/2 - 44, GetScreenHeight()/2 + 48, 50, Fade(BLACK, alpha));
            }
            else if (state == 4)
            {
                DrawText("[R] REPLAY", 340, 200, 20, GRAY);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
