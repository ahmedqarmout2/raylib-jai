#import "raylib";
#import "Basic";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - compute hash");

    // UI controls variables
    textInput: [96]u8;
    for "The quick brown fox jumps over the lazy dog." textInput[it_index] = it;
    textBoxEditMode: bool = false;
    btnComputeHashes: bool = false;

    // Data hash values
    hashCRC32: u32 = 0;
    hashMD5: *u32 = null;
    hashSHA1: *u32 = null;
    hashSHA256: *u32 = null;

    // Base64 encoded data
    base64Text: *u8;
    base64TextSize :s32 = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (btnComputeHashes)
        {
            textInputLen: s32 = cast(s32)strlen(textInput.data);

            // Encode data to Base64 string (includes NULL terminator), memory must be MemFree()
            base64Text = EncodeDataBase64(textInput.data, textInputLen, *base64TextSize);

            hashCRC32 = ComputeCRC32(textInput.data, textInputLen);     // Compute CRC32 hash code (4 bytes)
            hashMD5 = ComputeMD5(textInput.data, textInputLen);         // Compute MD5 hash code, returns static int[4] (16 bytes)
            hashSHA1 = ComputeSHA1(textInput.data, textInputLen);       // Compute SHA1 hash code, returns static int[5] (20 bytes)
            hashSHA256 = ComputeSHA256(textInput.data, textInputLen);   // Compute SHA256 hash code, returns static int[8] (32 bytes)
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, 20);
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SPACING, 2);
            GuiLabel(Rectangle.{ 40, 26, 720, 32 }, "INPUT DATA (TEXT):");
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SPACING, 1);
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, 10);

            if (GuiTextBox(Rectangle.{ 40, 64, 720, 32 }, textInput.data, 95, textBoxEditMode)) textBoxEditMode = !textBoxEditMode;

            btnComputeHashes = GuiButton(Rectangle.{ 40, 64 + 40, 720, 32 }, "COMPUTE INPUT DATA HASHES") == .RESULT_PRESSED;;

            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, 20);
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SPACING, 2);
            GuiLabel(Rectangle.{ 40, 160, 720, 32 }, "INPUT DATA HASH VALUES:");
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SPACING, 1);
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, 10);

            GuiSetStyle(.TEXTBOX, cast(s32)GuiTextBoxProperty.TEXT_READONLY, 1);
            GuiLabel(Rectangle.{ 40, 200, 120, 32 }, "CRC32 [32 bit]:");
            GuiTextBox(Rectangle.{ 40 + 120, 200, 720 - 120, 32 }, GetDataAsHexText(*hashCRC32, 1).data, 120, false);
            GuiLabel(Rectangle.{ 40, 200 + 36, 120, 32 }, "MD5 [128 bit]:");
            GuiTextBox(Rectangle.{ 40 + 120, 200 + 36, 720 - 120, 32 }, GetDataAsHexText(hashMD5, 4).data, 120, false);
            GuiLabel(Rectangle.{ 40, 200 + 36*2, 120, 32 }, "SHA1 [160 bit]:");
            GuiTextBox(Rectangle.{ 40 + 120, 200 + 36*2, 720 - 120, 32 }, GetDataAsHexText(hashSHA1, 5).data, 120, false);
            GuiLabel(Rectangle.{ 40, 200 + 36*3, 120, 32 }, "SHA256 [256 bit]:");
            GuiTextBox(Rectangle.{ 40 + 120, 200 + 36*3, 720 - 120, 32 }, GetDataAsHexText(hashSHA256, 8).data, 120, false);

            GuiSetState(.STATE_FOCUSED);
            GuiLabel(Rectangle.{ 40, 200 + 36*5 - 30, 320, 32 }, "BONUS - BAS64 ENCODED STRING:");
            GuiSetState(.STATE_NORMAL);
            GuiLabel(Rectangle.{ 40, 200 + 36*5, 120, 32 }, "BASE64 ENCODING:");
            GuiTextBox(Rectangle.{ 40 + 120, 200 + 36*5, 720 - 120, 32 }, base64Text, 120, false);
            GuiSetStyle(.TEXTBOX, cast(s32)GuiTextBoxProperty.TEXT_READONLY, 0);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    MemFree(base64Text);    // Free Base64 text data

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
GetDataAsHexText :: (data: *u32, dataSize: s32) -> [128]u8
{
    text: [128]u8;
    memset(text.data, 0, 128);

    if ((data != null) && (dataSize > 0) && (dataSize < ((128/8) - 1)))
    {
        for i: 0..dataSize-1 TextCopy(text.data + i*8, TextFormat("%08X", data[i]));
    }
    else TextCopy(text.data, "00000000");

    return text;
}
