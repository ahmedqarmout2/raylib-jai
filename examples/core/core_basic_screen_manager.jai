#import "raylib";
#import "Basic";

GameScreen :: enum {
    LOGO;
    TITLE;
    GAMEPLAY;
    ENDING;
}

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - basic screen manager");
    defer CloseWindow(); // Close window and OpenGL context

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    currentScreen: GameScreen = .LOGO;
    framesCounter: s32 = 0;
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if currentScreen == {
            case .LOGO;
            {
                framesCounter += 1;
                if (framesCounter > 120)
                {
                    currentScreen = .TITLE;
                }
            }
            case .TITLE;
            {
                // Draw TITLE screen here!
                if (IsKeyPressed(.KEY_ENTER) || IsGestureDetected(.GESTURE_TAP))
                {
                    currentScreen = .GAMEPLAY;
                }
            }
            case .GAMEPLAY;
            {
                // Draw GAMEPLAY screen here!
                if (IsKeyPressed(.KEY_ENTER) || IsGestureDetected(.GESTURE_TAP))
                {
                    currentScreen = .ENDING;
                }
            }
            case .ENDING;
            {
                // Draw ENDING screen here!
                if (IsKeyPressed(.KEY_ENTER) || IsGestureDetected(.GESTURE_TAP))
                {
                    currentScreen = .TITLE;
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            if currentScreen == {
                case .LOGO;
                {
                    // Draw LOGO screen here!
                    DrawText("LOGO SCREEN", 20, 20, 40, LIGHTGRAY);
                    DrawText("WAIT for 2 SECONDS...", 290, 220, 20, GRAY);

                }
                case .TITLE;
                {
                    // Draw TITLE screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, GREEN);
                    DrawText("TITLE SCREEN", 20, 20, 40, DARKGREEN);
                    DrawText("PRESS ENTER or TAP to JUMP to GAMEPLAY SCREEN", 120, 220, 20, DARKGREEN);

                }
                case .GAMEPLAY;
                {
                    // Draw GAMEPLAY screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, PURPLE);
                    DrawText("GAMEPLAY SCREEN", 20, 20, 40, MAROON);
                    DrawText("PRESS ENTER or TAP to JUMP to ENDING SCREEN", 130, 220, 20, MAROON);

                }
                case .ENDING;
                {
                    // Draw ENDING screen here!
                    DrawRectangle(0, 0, screenWidth, screenHeight, BLUE);
                    DrawText("ENDING SCREEN", 20, 20, 40, DARKBLUE);
                    DrawText("PRESS ENTER or TAP to RETURN to TITLE SCREEN", 120, 220, 20, DARKBLUE);

                }
            }
        }
        //----------------------------------------------------------------------------------
    }
}