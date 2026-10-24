#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - inline styling");

    textSize: Vector2;   // Measure text box for provided font and text
    colRandom: Color = RED;      // Random color used on text
    frameCounter: s32 = 0;       // Used to generate a new random color every certain frames

    SetTargetFPS(60);           // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        frameCounter += 1;

        if ((frameCounter%20) == 0)
        {
            colRandom.r = cast(u8)GetRandomValue(0, 255);
            colRandom.g = cast(u8)GetRandomValue(0, 255);
            colRandom.b = cast(u8)GetRandomValue(0, 255);
            colRandom.a = 255;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Text inline styling strategy used: [ ] delimiters for format
            // - Define foreground color:      [cRRGGBBAA]
            // - Define background color:      [bRRGGBBAA]
            // - Reset formating:              [r]
            // Colors defined with [cRRGGBBAA] or [bRRGGBBAA] are multiplied by the base color alpha
            // This allows global transparency control while keeping per-section styling (ex. text fade effects)
            // Example: [bAA00AAFF][cFF0000FF]red text on gray background[r] normal text

            DrawTextStyled(GetFontDefault(), "This changes the [cFF0000FF]foreground color[r] of provided text!!!",
                Vector2.{ 100, 80 }, 20.0, 2.0, BLACK);

            DrawTextStyled(GetFontDefault(), "This changes the [bFF00FFFF]background color[r] of provided text!!!",
                Vector2.{ 100, 120 }, 20.0, 2.0, BLACK);

            DrawTextStyled(GetFontDefault(), "This changes the [c00ff00ff][bff0000ff]foreground and background colors[r]!!!",
                Vector2.{ 100, 160 }, 20.0, 2.0, BLACK);

            DrawTextStyled(GetFontDefault(), "This changes the [c00ff00ff]alpha[r] relative [cffffffff][b000000ff]from source[r] [cff000088]color[r]!!!",
                Vector2.{ 100, 200 }, 20.0, 2.0, Color.{ 0, 0, 0, 100 });

            // Get pointer to formated text
            text: *u8 = TextFormat("Let's be [c%02x%02x%02xFF]CREATIVE[r] !!!", colRandom.r, colRandom.g, colRandom.b);
            DrawTextStyled(GetFontDefault(), text, Vector2.{ 100, 240 }, 40.0, 2.0, BLACK);

            textSize = MeasureTextStyled(GetFontDefault(), text, 40.0, 2.0);
            DrawRectangleLines(100, 240, cast(s32)textSize.x, cast(s32)textSize.y, GREEN);

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
// Draw text using inline styling
// PARAM: color is the default text color, background color is BLANK by default
// NOTE: Using input color as the base alpha multiplied to inline styles
DrawTextStyled :: (font: Font, text: *u8, position: Vector2, fontSize: float, spacing: float, color: Color)
{
    // Text inline styling strategy used: [ ] delimiters for format
    // - Define foreground color:      [cRRGGBBAA]
    // - Define background color:      [bRRGGBBAA]
    // - Reset formating:              [r]
    // Example: [bAA00AAFF][cFF0000FF]red text on gray background[r] normal text

    //if (font.texture.id == 0) font = GetFontDefault();

    textLen: s32 = cast(s32)TextLength(text);

    colFront: Color = color;
    colBack: Color = BLANK;
    backRecPadding: s32 = 4; // Background rectangle padding

    textOffsetY: float = 0.0;
    textOffsetX: float = 0.0;
    textLineSpacing: float = 0.0;
    scaleFactor: float = fontSize/font.baseSize;

    i: s32 = 0;
    while (i < textLen)
    {
        codepointByteCount: s32 = 0;
        codepoint: s32 = GetCodepointNext(*text[i], *codepointByteCount);

        if (codepoint == #char "\n")
        {
            textOffsetY += (fontSize + textLineSpacing);
            textOffsetX = 0.0;
        }
        else
        {
            if (codepoint == #char "[") // Process pipe styling
            {
                if (((i + 2) < textLen) && (text[i + 1] == #char "r") && (text[i + 2] == #char "]")) // Reset styling
                {
                    colFront = color;
                    colBack = BLANK;

                    i += 3;     // Skip "[r]"
                    continue;   // Do not draw characters
                }
                else if (((i + 1) < textLen) && ((text[i + 1] == #char "c") || (text[i + 1] == #char "b")))
                {
                    i += 2;     // Skip "[c" or "[b" to start parsing color

                    // Parse following color
                    colHexText: [9]u8;
                    textPtr: *u8 = *text[i]; // Color should start here, let's see...

                    colHexCount: s32 = 0;
                    while ((textPtr != null) && (textPtr[colHexCount] != #char "\0") && (textPtr[colHexCount] != #char "]"))
                    {
                        if (((textPtr[colHexCount] >= #char "0") && (textPtr[colHexCount] <= #char "9")) ||
                            ((textPtr[colHexCount] >= #char "A") && (textPtr[colHexCount] <= #char "F")) ||
                            ((textPtr[colHexCount] >= #char "a") && (textPtr[colHexCount] <= #char "f")))
                        {
                            colHexText[colHexCount] = textPtr[colHexCount];
                            colHexCount += 1;
                        }
                        else break; // Only affects while loop
                    }

                    // Convert hex color text into actual Color
                    val, success := string_to_int(to_string(colHexText), base = 16);
                    colHexValue: u32 = cast(u32) val;
                    if (text[i - 1] == #char "c")
                    {
						colFront = GetColor(colHexValue);
						//colFront.a *= (unsigned char)(colFront.a*(float)color.a/255.0); // TODO: Review
					}
                    else if (text[i - 1] == #char "b")
					{
						colBack = GetColor(colHexValue);
						//colBack.a *= (unsigned char)(colFront.a*(float)color.a/255.0);
					}

                    i += (colHexCount + 1); // Skip color value retrieved and ']'
                    continue;   // Do not draw characters
                }
            }

            index: s32 = GetGlyphIndex(font, codepoint);
            increaseX: float = 0.0;

            if (font.glyphs[index].advanceX == 0) increaseX = (cast(float)font.recs[index].width*scaleFactor + spacing);
            else increaseX += (cast(float)font.glyphs[index].advanceX*scaleFactor + spacing);

            // Draw background rectangle color (if required)
            if (colBack.a > 0) DrawRectangleRec(Rectangle.{ position.x + textOffsetX, position.y + textOffsetY - backRecPadding, increaseX, fontSize + 2*backRecPadding }, colBack);

            if ((codepoint != #char " ") && (codepoint != #char "\t"))
            {
                DrawTextCodepoint(font, codepoint, Vector2.{ position.x + textOffsetX, position.y + textOffsetY }, fontSize, colFront);
            }

            textOffsetX += increaseX;
        }

        i += codepointByteCount;
    }
}

// Measure inline styled text
// NOTE: Measuring styled text requires skipping styling data
// WARNING: Not considering line breaks
MeasureTextStyled :: (font: Font, text: *u8, fontSize: float, spacing: float) -> Vector2
{
    textSize: Vector2;

    if ((font.texture.id == 0) || (text == null) || (text[0] == #char "\0")) return textSize; // Security check

    textLen: s32 = cast(s32)TextLength(text); // Get size in bytes of text
    //float textLineSpacing = fontSize*1.5f; // Not used...

    textWidth: float = 0.0;
    textHeight: float = fontSize;
    scaleFactor: float = fontSize/cast(float)font.baseSize;

    codepoint: s32 = 0;              // Current character
    index: s32 = 0;                  // Index position in sprite font
    validCodepointCounter: s32 = 0;

    i: s32 = 0;
    while (i < textLen)
    {
        codepointByteCount: s32 = 0;
        codepoint = GetCodepointNext(*text[i], *codepointByteCount);

        if (codepoint == #char "[") // Ignore pipe inline styling
        {
            if (((i + 2) < textLen) && (text[i + 1] == #char "r") && (text[i + 2] == #char "]")) // Reset styling
            {
                i += 3;     // Skip "[r]"
                continue;   // Do not measure characters
            }
            else if (((i + 1) < textLen) && ((text[i + 1] == #char "c") || (text[i + 1] == #char "b")))
            {
                i += 2;     // Skip "[c" or "[b" to start parsing color

                textPtr: *u8 = *text[i]; // Color should start here, let's see...

                colHexCount: s32 = 0;
                while ((textPtr != null) && (textPtr[colHexCount] != #char "\0") && (textPtr[colHexCount] != #char "]"))
                {
                    if (((textPtr[colHexCount] >= #char "0") && (textPtr[colHexCount] <= #char "9")) ||
                        ((textPtr[colHexCount] >= #char "A") && (textPtr[colHexCount] <= #char "F")) ||
                        ((textPtr[colHexCount] >= #char "a") && (textPtr[colHexCount] <= #char "f")))
                    {
                        colHexCount += 1;
                    }
                    else break; // Only affects while loop
                }

                i += (colHexCount + 1); // Skip color value retrieved and ']'
                continue;   // Do not measure characters
            }
        }
        else if (codepoint != #char "\n")
        {
            index = GetGlyphIndex(font, codepoint);

            if (font.glyphs[index].advanceX > 0) textWidth += font.glyphs[index].advanceX;
            else textWidth += (font.recs[index].width + font.glyphs[index].offsetX);

            validCodepointCounter += 1;
            i += codepointByteCount;
        }
    }

    textSize.x = textWidth*scaleFactor + (validCodepointCounter - 1)*spacing;
    textSize.y = textHeight;

    return textSize;
}
