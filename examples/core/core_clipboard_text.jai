#import "raylib";
#import "Basic";

MAX_TEXT_SAMPLES :: 5;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - clipboard text");

    // Define some sample texts
    sampleTexts: [MAX_TEXT_SAMPLES]*u8 = .[
        "Hello from raylib!",
        "The quick brown fox jumps over the lazy dog",
        "Clipboard operations are useful!",
        "raylib is a simple and easy-to-use library",
        "Copy and paste me!"
    ];

    clipboardText: *u8 = null;
    inputBuffer: [256]u8;
    for "Hello from raylib!" inputBuffer[it_index] = it; // Random initial string

    // UI required variables
    textBoxEditMode  : bool = false;

    btnCutPressed    : bool = false;
    btnCopyPressed   : bool = false;
    btnPastePressed  : bool = false;
    btnClearPressed  : bool = false;
    btnRandomPressed : bool = false;

    // Set UI style
    GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, 20);
    GuiSetIconScale(2);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Handle button interactions
        if (btnCutPressed)
        {
            SetClipboardText(inputBuffer.data);
            clipboardText = GetClipboardText();
            inputBuffer[0] = #char "\0"; // Quick solution to clear text
            //memset(inputBuffer, 0, 256); // Clear full buffer properly
        }

        if (btnCopyPressed)
        {
            SetClipboardText(inputBuffer.data); // Copy text to clipboard
            clipboardText = GetClipboardText(); // Get text from clipboard
        }

        if (btnPastePressed)
        {
            // Paste text from clipboard
            clipboardText = GetClipboardText();
            if (clipboardText != null) TextCopy(inputBuffer.data, clipboardText);
        }

        if (btnClearPressed)
        {
            inputBuffer[0] = #char "\0"; // Quick solution to clear text
            //memset(inputBuffer, 0, 256); // Clear full buffer properly
        }

        if (btnRandomPressed)
        {
            // Get random text from sample list
            TextCopy(inputBuffer.data, sampleTexts[GetRandomValue(0, MAX_TEXT_SAMPLES - 1)]);
        }

        // Quick cut/copy/paste with keyboard shortcuts
        if (IsKeyDown(.KEY_LEFT_CONTROL) || IsKeyDown(.KEY_RIGHT_CONTROL))
        {
            if (IsKeyPressed(.KEY_X))
            {
                SetClipboardText(inputBuffer.data);
                inputBuffer[0] = #char "\0"; // Quick solution to clear text
            }

            if (IsKeyPressed(.KEY_C)) SetClipboardText(inputBuffer.data);

            if (IsKeyPressed(.KEY_V))
            {
                clipboardText = GetClipboardText();
                print("%\n", clipboardText);
                if (clipboardText != null) TextCopy(inputBuffer.data, clipboardText);
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        // Draw instructions
        GuiLabel(Rectangle.{ 50, 20, 700, 36 }, "Use the BUTTONS or KEY SHORTCUTS:");
        DrawText("[CTRL+X] - CUT | [CTRL+C] COPY | [CTRL+V] | PASTE", 50, 60, 20, MAROON);

        // Draw text box
        if (GuiTextBox(Rectangle.{ 50, 120, 652, 40 }, inputBuffer.data, 256, textBoxEditMode)) textBoxEditMode = !textBoxEditMode;

        // Random text button
        btnRandomPressed = GuiButton(Rectangle.{ 50 + 652 + 8, 120, 40, 40 }, "#77#") == GuiResult.RESULT_PRESSED;

        // Draw buttons
        btnCutPressed = GuiButton(Rectangle.{ 50, 180, 158, 40 }, "#17#CUT") == GuiResult.RESULT_PRESSED;
        btnCopyPressed = GuiButton(Rectangle.{ 50 + 165, 180, 158, 40 }, "#16#COPY") == GuiResult.RESULT_PRESSED;
        btnPastePressed = GuiButton(Rectangle.{ 50 + 165*2, 180, 158, 40 }, "#18#PASTE") == GuiResult.RESULT_PRESSED;
        btnClearPressed = GuiButton(Rectangle.{ 50 + 165*3, 180, 158, 40 }, "#143#CLEAR") == GuiResult.RESULT_PRESSED;

        // Draw clipboard status
        GuiSetState(.STATE_DISABLED);
        GuiLabel(Rectangle.{ 50, 260, 700, 40 }, "Clipboard current text data:");
        GuiSetStyle(.TEXTBOX, cast(s32)GuiTextBoxProperty.TEXT_READONLY, 1);
        GuiTextBox(Rectangle.{ 50, 300, 700, 40 }, clipboardText, 256, false);
        GuiSetStyle(.TEXTBOX, cast(s32)GuiTextBoxProperty.TEXT_READONLY, 0);
        GuiLabel(Rectangle.{ 50, 360, 700, 40 }, "Try copying text from other applications and pasting here!");
        GuiSetState(.STATE_NORMAL);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}