#import "raylib";
#import "Basic";
#import "Math";

MAX_INPUT_CHARS :: 9;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - input box");

    name: [MAX_INPUT_CHARS + 1]u8;
    for 0..MAX_INPUT_CHARS name[it] = #char "\0";      // NOTE: One extra space required for null terminator u8 '\0'

    letterCount: s32 = 0;

    textBox: Rectangle = .{ screenWidth/2.0 - 100, 180, 225, 50 };
    mouseOnText: bool = false;

    framesCounter: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (CheckCollisionPointRec(GetMousePosition(), textBox)) mouseOnText = true;
        else mouseOnText = false;

        if (mouseOnText)
        {
            // Set the window's cursor to the I-Beam
            SetMouseCursor(.MOUSE_CURSOR_IBEAM);

            // Get char pressed (unicode character) on the queue
            key: s32 = GetCharPressed();

            // Check if more characters have been pressed on the same frame
            while (key > 0)
            {
                // NOTE: Only allow keys in range [32..125]
                if ((key >= 32) && (key <= 125) && (letterCount < MAX_INPUT_CHARS))
                {
                    name[letterCount]     = cast(u8)key;
                    name[letterCount + 1] = #char "\0"; // Add null terminator at the end of the string.
                    letterCount += 1;
                }

                key = GetCharPressed();  // Check next character in the queue
            }

            if (IsKeyPressed(.KEY_BACKSPACE))
            {
                letterCount -= 1;
                if (letterCount < 0) letterCount = 0;
                name[letterCount] = #char "\0";
            }
        }
        else SetMouseCursor(.MOUSE_CURSOR_DEFAULT);

        if (mouseOnText) framesCounter += 1;
        else framesCounter = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, GRAY);

            DrawRectangleRec(textBox, LIGHTGRAY);
            if (mouseOnText) DrawRectangleLines(cast(s32)textBox.x, cast(s32)textBox.y, cast(s32)textBox.width, cast(s32)textBox.height, RED);
            else DrawRectangleLines(cast(s32)textBox.x, cast(s32)textBox.y, cast(s32)textBox.width, cast(s32)textBox.height, DARKGRAY);

            DrawText(name.data, cast(s32)textBox.x + 5, cast(s32)textBox.y + 8, 40, MAROON);

            DrawText(TextFormat("INPUT CHARS: %i/%i", letterCount, MAX_INPUT_CHARS), 315, 250, 20, DARKGRAY);

            if (mouseOnText)
            {
                if (letterCount < MAX_INPUT_CHARS)
                {
                    // Draw blinking underscore char
                    if (((framesCounter/20)%2) == 0) DrawText("_", cast(s32)textBox.x + 8 + MeasureText(name.data, 40), cast(s32)textBox.y + 12, 40, MAROON);
                }
                else DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, GRAY);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

// Check if any key is pressed
// NOTE: We limit keys check to keys between 32 (KEY_SPACE) and 126
IsAnyKeyPressed :: () -> bool
{
    keyPressed: bool = false;
    key: KeyboardKey = GetKeyPressed();

    if ((key >= 32) && (key <= 126)) keyPressed = true;

    return keyPressed;
}
