#import "raylib";
#import "Basic";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Set MSAA 4X hint before windows creation

    InitWindow(screenWidth, screenHeight, "raylib [core] example - gamepad information");
    defer CloseWindow(); // Close window and OpenGL context

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        i: s32 = 0;
        y: s32 = 5;
        while (i < 4) {     // MAX_GAMEPADS = 4
            defer i += 1;

            if (IsGamepadAvailable(i)) {
                DrawText(TextFormat("Gamepad name: %s", GetGamepadName(i)), 10, y, 10, BLACK);
                y += 11;
                DrawText(TextFormat("\tAxis count:   %d", GetGamepadAxisCount(i)), 10, y, 10, BLACK);
                y += 11;

                for axios: 0..GetGamepadAxisCount(i) - 1 {
                    DrawText(TextFormat("\tAxis %d = %f", axios, GetGamepadAxisMovement(i, get_gamepad_axis(axios))), 10, y, 10, BLACK);
                    y += 11;
                }

                for button: 0..31 {
                    DrawText(TextFormat("\tButton %d = %d", button, IsGamepadButtonDown(i, get_gamepad_button(button))), 10, y, 10, BLACK);
                    y += 11;
                }
            }
        }

        DrawFPS(GetScreenWidth() - 100, 100);
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

get_gamepad_button :: (i: int) -> GamepadButton {
    if i == {
        case 0 ; return .GAMEPAD_BUTTON_UNKNOWN;             // Unknown button, just for error checking
        case 1 ; return .GAMEPAD_BUTTON_LEFT_FACE_UP;        // Gamepad left DPAD up button
        case 2 ; return .GAMEPAD_BUTTON_LEFT_FACE_RIGHT;     // Gamepad left DPAD right button
        case 3 ; return .GAMEPAD_BUTTON_LEFT_FACE_DOWN;      // Gamepad left DPAD down button
        case 4 ; return .GAMEPAD_BUTTON_LEFT_FACE_LEFT;      // Gamepad left DPAD left button
        case 5 ; return .GAMEPAD_BUTTON_RIGHT_FACE_UP;       // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
        case 6 ; return .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT;    // Gamepad right button right (i.e. PS3: Circle, Xbox: B)
        case 7 ; return .GAMEPAD_BUTTON_RIGHT_FACE_DOWN;     // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
        case 8 ; return .GAMEPAD_BUTTON_RIGHT_FACE_LEFT;     // Gamepad right button left (i.e. PS3: Square, Xbox: X)
        case 9 ; return .GAMEPAD_BUTTON_LEFT_TRIGGER_1;      // Gamepad top/back trigger left (first), it could be a trailing button
        case 10; return .GAMEPAD_BUTTON_LEFT_TRIGGER_2;      // Gamepad top/back trigger left (second), it could be a trailing button
        case 11; return .GAMEPAD_BUTTON_RIGHT_TRIGGER_1;     // Gamepad top/back trigger right (first), it could be a trailing button
        case 12; return .GAMEPAD_BUTTON_RIGHT_TRIGGER_2;     // Gamepad top/back trigger right (second), it could be a trailing button
        case 13; return .GAMEPAD_BUTTON_MIDDLE_LEFT;         // Gamepad center buttons, left one (i.e. PS3: Select)
        case 14; return .GAMEPAD_BUTTON_MIDDLE;              // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
        case 15; return .GAMEPAD_BUTTON_MIDDLE_RIGHT;        // Gamepad center buttons, right one (i.e. PS3: Start)
        case 16; return .GAMEPAD_BUTTON_LEFT_THUMB;          // Gamepad joystick pressed button left
        case 17; return .GAMEPAD_BUTTON_RIGHT_THUMB;         // Gamepad joystick pressed button right
    }
    return .GAMEPAD_BUTTON_UNKNOWN;
}