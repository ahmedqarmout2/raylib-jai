#import "raylib";
#import "Basic";
#import "Math";

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
ActionType :: enum s32 {
    NO_ACTION :: 0;
    ACTION_UP;
    ACTION_DOWN;
    ACTION_LEFT;
    ACTION_RIGHT;
    ACTION_FIRE;
    MAX_ACTION;
};

// Key and button inputs
ActionInput :: struct {
    key: KeyboardKey;
    button: GamepadButton;
};

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
gamepadIndex: s32 = 0; // Gamepad default index
actionInputs: [ActionType.MAX_ACTION]ActionInput;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input actions");

    // Set default actions
    actionSet: bool = true;
    SetActionsDefault();
    releaseAction: bool = false;

    position: Vector2 = Vector2.{ 400.0, 200.0 };
    size: Vector2 = Vector2.{ 40.0, 40.0 };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        gamepadIndex = 0; //  Set gamepad being checked

        if (IsActionDown(.ACTION_UP)) position.y -= 2;
        if (IsActionDown(.ACTION_DOWN)) position.y += 2;
        if (IsActionDown(.ACTION_LEFT)) position.x -= 2;
        if (IsActionDown(.ACTION_RIGHT)) position.x += 2;
        if (IsActionPressed(.ACTION_FIRE))
        {
            position.x = (screenWidth-size.x)/2;
            position.y = (screenHeight-size.y)/2;
        }

        // Register release action for one frame
        releaseAction = false;
        if (IsActionReleased(.ACTION_FIRE)) releaseAction = true;

        // Switch control scheme by pressing TAB
        if (IsKeyPressed(.KEY_TAB))
        {
            actionSet = !actionSet;
            if (actionSet) SetActionsDefault();
            else SetActionsCursor();
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(GRAY);

            DrawRectangleV(position, size, ifx releaseAction then BLUE else RED);

            t: *u8 = temp_c_string(ifx (actionSet) then "Current input set: WASD (default)" else "Current input set: Arrow keys");
            DrawText(t, 10, 10, 20, WHITE);
            DrawText("Use TAB key to toggles Actions keyset", 10, 50, 20, GREEN);

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
// Check action key/button pressed
// NOTE: Combines key pressed and gamepad button pressed in one action
IsActionPressed :: (action: ActionType) -> bool
{
    result: bool = false;

    if (action < ActionType.MAX_ACTION) result = (IsKeyPressed(actionInputs[action].key) || IsGamepadButtonPressed(gamepadIndex, actionInputs[action].button));

    return result;
}

// Check action key/button released
// NOTE: Combines key released and gamepad button released in one action
IsActionReleased :: (action: ActionType) -> bool
{
    result: bool = false;

    if (action < ActionType.MAX_ACTION) result = (IsKeyReleased(actionInputs[action].key) || IsGamepadButtonReleased(gamepadIndex, actionInputs[action].button));

    return result;
}

// Check action key/button down
// NOTE: Combines key down and gamepad button down in one action
IsActionDown :: (action: ActionType) -> bool
{
    result: bool = false;

    if (action < ActionType.MAX_ACTION) result = (IsKeyDown(actionInputs[action].key) || IsGamepadButtonDown(gamepadIndex, actionInputs[action].button));

    return result;
}

// Set the "default" keyset
// NOTE: Here WASD and gamepad buttons on the left side for movement
SetActionsDefault :: ()
{
    actionInputs[ActionType.ACTION_UP].key = .KEY_W;
    actionInputs[ActionType.ACTION_DOWN].key = .KEY_S;
    actionInputs[ActionType.ACTION_LEFT].key = .KEY_A;
    actionInputs[ActionType.ACTION_RIGHT].key = .KEY_D;
    actionInputs[ActionType.ACTION_FIRE].key = .KEY_SPACE;

    actionInputs[ActionType.ACTION_UP].button = .GAMEPAD_BUTTON_LEFT_FACE_UP;
    actionInputs[ActionType.ACTION_DOWN].button = .GAMEPAD_BUTTON_LEFT_FACE_DOWN;
    actionInputs[ActionType.ACTION_LEFT].button = .GAMEPAD_BUTTON_LEFT_FACE_LEFT;
    actionInputs[ActionType.ACTION_RIGHT].button = .GAMEPAD_BUTTON_LEFT_FACE_RIGHT;
    actionInputs[ActionType.ACTION_FIRE].button = .GAMEPAD_BUTTON_RIGHT_FACE_DOWN;
}

// Set the "alternate" keyset
// NOTE: Here cursor keys and gamepad buttons on the right side for movement
SetActionsCursor :: ()
{
    actionInputs[ActionType.ACTION_UP].key = .KEY_UP;
    actionInputs[ActionType.ACTION_DOWN].key = .KEY_DOWN;
    actionInputs[ActionType.ACTION_LEFT].key = .KEY_LEFT;
    actionInputs[ActionType.ACTION_RIGHT].key = .KEY_RIGHT;
    actionInputs[ActionType.ACTION_FIRE].key = .KEY_SPACE;

    actionInputs[ActionType.ACTION_UP].button = .GAMEPAD_BUTTON_RIGHT_FACE_UP;
    actionInputs[ActionType.ACTION_DOWN].button = .GAMEPAD_BUTTON_RIGHT_FACE_DOWN;
    actionInputs[ActionType.ACTION_LEFT].button = .GAMEPAD_BUTTON_RIGHT_FACE_LEFT;
    actionInputs[ActionType.ACTION_RIGHT].button = .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT;
    actionInputs[ActionType.ACTION_FIRE].button = .GAMEPAD_BUTTON_LEFT_FACE_DOWN;
}
