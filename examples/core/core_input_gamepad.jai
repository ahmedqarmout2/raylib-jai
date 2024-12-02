#import "raylib";
#import "Basic";
#import "Math";

XBOX_ALIAS_1 :: "xbox";
XBOX_ALIAS_2 :: "x-box";
PS_ALIAS     :: "playstation";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Set MSAA 4X hs32 before windows creation

    InitWindow(screenWidth, screenHeight, "raylib [core] example - gamepad input");
    defer CloseWindow(); // Close window and OpenGL context

    texPs3Pad : Texture2D = LoadTexture("resources/ps3.png");
    defer UnloadTexture(texPs3Pad);

    texXboxPad: Texture2D = LoadTexture("resources/xbox.png");
    defer UnloadTexture(texXboxPad);

    // Set axis deadzones
    leftStickDeadzoneX   ::  0.1;
    leftStickDeadzoneY   ::  0.1;
    rightStickDeadzoneX  ::  0.1;
    rightStickDeadzoneY  ::  0.1;
    leftTriggerDeadzone  :: -0.9;
    rightTriggerDeadzone :: -0.9;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    gamepad: s32 = 0; // which gamepad to display

    // Main game loop
    while (!WindowShouldClose()) {   // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // ...
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        if (IsKeyPressed(.KEY_LEFT) && gamepad > 0) gamepad -= 1;
        if (IsKeyPressed(.KEY_RIGHT)) gamepad += 1;

        if (IsGamepadAvailable(gamepad)) {
            DrawText(TextFormat("GP%d: %s", gamepad, GetGamepadName(gamepad)), 10, 10, 10, BLACK);

            // Get axis values
            leftStickX  : float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_LEFT_X);
            leftStickY  : float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_LEFT_Y);
            rightStickX : float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_RIGHT_X);
            rightStickY : float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_RIGHT_Y);
            leftTrigger : float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_LEFT_TRIGGER);
            rightTrigger: float = GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_RIGHT_TRIGGER);

            // Calculate deadzones
            if (leftStickX > -leftStickDeadzoneX && leftStickX < leftStickDeadzoneX)     leftStickX   =  0.0;
            if (leftStickY > -leftStickDeadzoneY && leftStickY < leftStickDeadzoneY)     leftStickY   =  0.0;
            if (rightStickX > -rightStickDeadzoneX && rightStickX < rightStickDeadzoneX) rightStickX  =  0.0;
            if (rightStickY > -rightStickDeadzoneY && rightStickY < rightStickDeadzoneY) rightStickY  =  0.0;
            if (leftTrigger < leftTriggerDeadzone)                                       leftTrigger  = -1.0;
            if (rightTrigger < rightTriggerDeadzone)                                     rightTrigger = -1.0;

            if (TextFindIndex(TextToLower(GetGamepadName(gamepad)), XBOX_ALIAS_1) > -1 || TextFindIndex(TextToLower(GetGamepadName(gamepad)), XBOX_ALIAS_2) > -1) {
                DrawTexture(texXboxPad, 0, 0, DARKGRAY);

                // Draw buttons: xbox home
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE)) DrawCircle(394, 89, 19, RED);

                // Draw buttons: basic
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_RIGHT))     DrawCircle(436, 150, 9, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_LEFT))      DrawCircle(352, 150, 9, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_LEFT))  DrawCircle(501, 151, 15, BLUE);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN))  DrawCircle(536, 187, 15, LIME);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) DrawCircle(572, 151, 15, MAROON);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_UP))    DrawCircle(536, 115, 15, GOLD);

                // Draw buttons: d-pad
                DrawRectangle(317, 202, 19, 71, BLACK);
                DrawRectangle(293, 228, 69, 19, BLACK);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_UP))    DrawRectangle(317, 202, 19, 26, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_DOWN))  DrawRectangle(317, 202 + 45, 19, 26, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_LEFT))  DrawRectangle(292, 228, 25, 19, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) DrawRectangle(292 + 44, 228, 26, 19, RED);

                // Draw buttons: left-right back
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_TRIGGER_1))  DrawCircle(259, 61, 20, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) DrawCircle(536, 61, 20, RED);

                // Draw axis: left joystick
                leftGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_THUMB)) leftGamepadColor = RED;
                DrawCircle(259, 152, 39, BLACK);
                DrawCircle(259, 152, 34, LIGHTGRAY);
                DrawCircle(259 + cast(s32)(leftStickX*20), 152 + cast(s32)(leftStickY*20), 25, leftGamepadColor);

                // Draw axis: right joystick
                rightGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_THUMB)) rightGamepadColor = RED;
                DrawCircle(461, 237, 38, BLACK);
                DrawCircle(461, 237, 33, LIGHTGRAY);
                DrawCircle(461 + cast(s32)(rightStickX*20), 237 + cast(s32)(rightStickY*20), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                DrawRectangle(170, 30, 15, 70, GRAY);
                DrawRectangle(604, 30, 15, 70, GRAY);
                DrawRectangle(170, 30, 15, cast(s32)(((1 + leftTrigger)/2)*70), RED);
                DrawRectangle(604, 30, 15, cast(s32)(((1 + rightTrigger)/2)*70), RED);

                //DrawText(TextFormat("Xbox axis LT: %02.02f", GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_LEFT_TRIGGER)), 10, 40, 10, BLACK);
                //DrawText(TextFormat("Xbox axis RT: %02.02f", GetGamepadAxisMovement(gamepad, .GAMEPAD_AXIS_RIGHT_TRIGGER)), 10, 60, 10, BLACK);
            } else if (TextFindIndex(TextToLower(GetGamepadName(gamepad)), PS_ALIAS) > -1) {
                DrawTexture(texPs3Pad, 0, 0, DARKGRAY);

                // Draw buttons: ps
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE)) DrawCircle(396, 222, 13, RED);

                // Draw buttons: basic
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_LEFT))      DrawRectangle(328, 170, 32, 13, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_RIGHT))     DrawTriangle(Vector2.{436, 168}, Vector2.{436, 185}, Vector2.{464, 177}, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_UP))    DrawCircle(557, 144, 13, LIME);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) DrawCircle(586, 173, 13, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN))  DrawCircle(557, 203, 13, VIOLET);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_LEFT))  DrawCircle(527, 173, 13, PINK);

                // Draw buttons: d-pad
                DrawRectangle(225, 132, 24, 84, BLACK);
                DrawRectangle(195, 161, 84, 25, BLACK);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_UP))    DrawRectangle(225, 132, 24, 29, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_DOWN))  DrawRectangle(225, 132 + 54, 24, 30, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_LEFT))  DrawRectangle(195, 161, 30, 25, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) DrawRectangle(195 + 54, 161, 30, 25, RED);

                // Draw buttons: left-right back buttons
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_TRIGGER_1)) DrawCircle(239, 82, 20, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) DrawCircle(557, 82, 20, RED);

                // Draw axis: left joystick
                leftGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_THUMB)) leftGamepadColor = RED;
                DrawCircle(319, 255, 35, BLACK);
                DrawCircle(319, 255, 31, LIGHTGRAY);
                DrawCircle(319 + cast(s32)(leftStickX*20), 255 + cast(s32)(leftStickY*20), 25, leftGamepadColor);

                // Draw axis: right joystick
                rightGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_THUMB)) rightGamepadColor = RED;
                DrawCircle(475, 255, 35, BLACK);
                DrawCircle(475, 255, 31, LIGHTGRAY);
                DrawCircle(475 + cast(s32)(rightStickX*20), 255 + cast(s32)(rightStickY*20), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                DrawRectangle(169, 48, 15, 70, GRAY);
                DrawRectangle(611, 48, 15, 70, GRAY);
                DrawRectangle(169, 48, 15, cast(s32)(((1 + leftTrigger)/2)*70), RED);
                DrawRectangle(611, 48, 15, cast(s32)(((1 + rightTrigger)/2)*70), RED);
            } else {

                // Draw background: generic
                DrawRectangleRounded(Rectangle.{175, 110, 460, 220}, 0.3, 16, DARKGRAY);

                // Draw buttons: basic
                DrawCircle(365, 170, 12, RAYWHITE);
                DrawCircle(405, 170, 12, RAYWHITE);
                DrawCircle(445, 170, 12, RAYWHITE);
                DrawCircle(516, 191, 17, RAYWHITE);
                DrawCircle(551, 227, 17, RAYWHITE);
                DrawCircle(587, 191, 17, RAYWHITE);
                DrawCircle(551, 155, 17, RAYWHITE);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_LEFT))      DrawCircle(365, 170, 10, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE))           DrawCircle(405, 170, 10, GREEN);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_MIDDLE_RIGHT))     DrawCircle(445, 170, 10, BLUE);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_LEFT))  DrawCircle(516, 191, 15, GOLD);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN))  DrawCircle(551, 227, 15, BLUE);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) DrawCircle(587, 191, 15, GREEN);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_FACE_UP))    DrawCircle(551, 155, 15, RED);

                // Draw buttons: d-pad
                DrawRectangle(245, 145, 28, 88, RAYWHITE);
                DrawRectangle(215, 174, 88, 29, RAYWHITE);
                DrawRectangle(247, 147, 24, 84, BLACK);
                DrawRectangle(217, 176, 84, 25, BLACK);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_UP))    DrawRectangle(247, 147, 24, 29, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_DOWN))  DrawRectangle(247, 147 + 54, 24, 30, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_LEFT))  DrawRectangle(217, 176, 30, 25, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) DrawRectangle(217 + 54, 176, 30, 25, RED);

                // Draw buttons: left-right back
                DrawRectangleRounded(Rectangle.{215, 98, 100, 10}, 0.5, 16, DARKGRAY);
                DrawRectangleRounded(Rectangle.{495, 98, 100, 10}, 0.5, 16, DARKGRAY);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_TRIGGER_1)) DrawRectangleRounded(Rectangle.{215, 98, 100, 10}, 0.5, 16, RED);
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) DrawRectangleRounded(Rectangle.{495, 98, 100, 10}, 0.5, 16, RED);

                // Draw axis: left joystick
                leftGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_LEFT_THUMB)) leftGamepadColor = RED;
                DrawCircle(345, 260, 40, BLACK);
                DrawCircle(345, 260, 35, LIGHTGRAY);
                DrawCircle(345 + cast(s32)(leftStickX*20), 260 + cast(s32)(leftStickY*20), 25, leftGamepadColor);

                // Draw axis: right joystick
                rightGamepadColor: Color = BLACK;
                if (IsGamepadButtonDown(gamepad, .GAMEPAD_BUTTON_RIGHT_THUMB)) rightGamepadColor = RED;
                DrawCircle(465, 260, 40, BLACK);
                DrawCircle(465, 260, 35, LIGHTGRAY);
                DrawCircle(465 + cast(s32)(rightStickX*20), 260 + cast(s32)(rightStickY*20), 25, rightGamepadColor);

                // Draw axis: left-right triggers
                DrawRectangle(151, 110, 15, 70, GRAY);
                DrawRectangle(644, 110, 15, 70, GRAY);
                DrawRectangle(151, 110, 15, cast(s32)(((1 + leftTrigger)/2)*70), RED);
                DrawRectangle(644, 110, 15, cast(s32)(((1 + rightTrigger)/2)*70), RED);

            }

            DrawText(TextFormat("DETECTED AXIS [%i]:", GetGamepadAxisCount(0)), 10, 50, 10, MAROON);

            for i: 0..GetGamepadAxisCount(0)-1 {
                DrawText(TextFormat("AXIS %i: %.02f", i, GetGamepadAxisMovement(0, get_gamepad_axis(i))), 20, 70 + 20*i, 10, DARKGRAY);
            }

            if (GetGamepadButtonPressed() != .GAMEPAD_BUTTON_UNKNOWN) DrawText(TextFormat("DETECTED BUTTON: %i", GetGamepadButtonPressed()), 10, 430, 10, RED);
            else DrawText("DETECTED BUTTON: NONE", 10, 430, 10, GRAY);
        } else {
            DrawText(TextFormat("GP%d: NOT DETECTED", gamepad), 10, 10, 10, GRAY);

            DrawTexture(texXboxPad, 0, 0, LIGHTGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}

get_gamepad_axis :: (i: int) -> GamepadAxis {
    if i == {
        case 0; return .GAMEPAD_AXIS_LEFT_X;           // Gamepad left stick X axis
        case 1; return .GAMEPAD_AXIS_LEFT_Y;           // Gamepad left stick Y axis
        case 2; return .GAMEPAD_AXIS_RIGHT_X;          // Gamepad right stick X axis
        case 3; return .GAMEPAD_AXIS_RIGHT_Y;          // Gamepad right stick Y axis
        case 4; return .GAMEPAD_AXIS_LEFT_TRIGGER;     // Gamepad back trigger left, pressure level: [1..-1]
        case 5; return .GAMEPAD_AXIS_RIGHT_TRIGGER;    // Gamepad back trigger right, pressure level: [1..-1]
    }
    return .GAMEPAD_AXIS_LEFT_X;
}
