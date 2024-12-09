#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

MAX_FONTS :: 8;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - draw text inside a rectangle");
    defer CloseWindow(); // Close window and OpenGL context

    text: [..]char;
    s := "Text cannot escape\tthis container\t...word wrap also works when active so here's a long text for testing.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nec ullamcorper sit amet risus nullam eget felis eget.";

    array_resize(*text, s.count);
    for s text[it_index] = it;

    resizing: bool = false;
    wordWrap: bool = true;

    container: Rectangle = .{25.0, 25.0, screenWidth - 50.0, screenHeight - 250.0};
    resizer  : Rectangle = .{container.x + container.width - 17, container.y + container.height - 17, 14, 14};

    // Minimum width and heigh for the container rectangle
    minWidth : float = 60;
    minHeight: float = 60;
    maxWidth : float = screenWidth - 50.0;
    maxHeight: float = screenHeight - 160.0;

    lastMouse: Vector2 = .{0.0, 0.0}; // Stores last mouse coordinates
    borderColor: Color = MAROON;         // Container border color
    font: Font = GetFontDefault();       // Get default system font

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) wordWrap = !wordWrap;

        mouse: Vector2 = GetMousePosition();

        // Check if the mouse is inside the container and toggle border color
        if (CheckCollisionPointRec(mouse, container)) borderColor = Fade(MAROON, 0.4);
        else if (!resizing) borderColor = MAROON;

        // Container resizing logic
        if (resizing) {
            if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) resizing = false;

            width: float = container.width + (mouse.x - lastMouse.x);
            container.width = ifx (width > minWidth) then (ifx (width < maxWidth) then width else maxWidth) else minWidth;

            height: float = container.height + (mouse.y - lastMouse.y);
            container.height = ifx (height > minHeight) then (ifx (height < maxHeight) then height else maxHeight) else minHeight;
        } else {
            // Check if we're resizing
            if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) && CheckCollisionPointRec(mouse, resizer)) resizing = true;
        }

        // Move resizer rectangle properly
        resizer.x = container.x + container.width - 17;
        resizer.y = container.y + container.height - 17;

        lastMouse = mouse; // Update mouse
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawRectangleLinesEx(container, 3, borderColor);    // Draw container border

        // Draw text in container (add some padding)
        DrawTextBoxed(font, text.data, Rectangle.{container.x + 4, container.y + 4, container.width - 4, container.height - 4}, 20.0, 2.0, wordWrap, GRAY);

        DrawRectangleRec(resizer, borderColor);             // Draw the resize box

        // Draw bottom info
        DrawRectangle(0, screenHeight - 54, screenWidth, 54, GRAY);
        DrawRectangleRec(Rectangle.{382.0, screenHeight - 34.0, 12.0, 12.0}, MAROON);

        DrawText("Word Wrap: ", 313, screenHeight-115, 20, BLACK);
        if (wordWrap) DrawText("ON", 447, screenHeight - 115, 20, RED);
        else DrawText("OFF", 447, screenHeight - 115, 20, BLACK);

        DrawText("Press [SPACE] to toggle word wrap", 218, screenHeight - 86, 20, GRAY);

        DrawText("Click hold & drag the    to resize the container", 155, screenHeight - 38, 20, RAYWHITE);
        //----------------------------------------------------------------------------------
    }
}

// Draw text using font inside rectangle limits
DrawTextBoxed :: (font: Font, text: *char, rec: Rectangle, fontSize: float, spacing: float, wordWrap: bool, tint: Color) {
    DrawTextBoxedSelectable(font, text, rec, fontSize, spacing, wordWrap, tint, 0, 0, WHITE, WHITE);
}

// Draw text using font inside rectangle limits with support for text selection
DrawTextBoxedSelectable :: (font: Font, text: *char, rec: Rectangle, fontSize: float, spacing: float, wordWrap: bool, tint: Color, selectStart: s32, selectLength: s32, selectTint: Color, selectBackTint: Color) {
    length: s32 = cast(s32) TextLength(text);  // Total length in bytes of the text, scanned by codepoints in loop

    textOffsetY: float = 0;          // Offset between lines (on line break '\n')
    textOffsetX: float = 0.0;        // Offset X to next character to draw

    scaleFactor: float = fontSize/cast(float)font.baseSize;     // Character rectangle scaling factor

    // Word/character wrapping mechanism variables
    my_enum :: enum { MEASURE_STATE :: 0; DRAW_STATE :: 1; }
    state: my_enum = ifx wordWrap then .MEASURE_STATE else .DRAW_STATE;

    startLine: s32 = -1;         // Index where to begin drawing (where a line begins)
    endLine  : s32 = -1;         // Index where to stop drawing (where a line ends)
    lastk    : s32 = -1;         // Holds last value of the character position

    i: s32 = 0;
    k: s32 = 0;
    while (i < length) {
        defer i += 1;
        defer k += 1;

        // Get next codepoint from byte string and glyph index in font
        codepointByteCount: s32 = 0;
        codepoint         : s32 = GetCodepoint(*text[i], *codepointByteCount);
        index             : s32 = GetGlyphIndex(font, codepoint);

        // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if (codepoint == 0x3f) codepointByteCount = 1;
        i += (codepointByteCount - 1);

        glyphWidth: float = 0;
        if (codepoint != #char "\n") {
            glyphWidth = ifx (font.glyphs[index].advanceX == 0) then font.recs[index].width*scaleFactor else font.glyphs[index].advanceX*scaleFactor;

            if (i + 1 < length) glyphWidth = glyphWidth + spacing;
        }

        // NOTE: When wordWrap is ON we first measure how much of the text we can draw before going outside of the rec container
        // We store this info in startLine and endLine, then we change states, draw the text between those two variables
        // and change states again and again recursively until the end of the text (or until we get outside of the container).
        // When wordWrap is OFF we don't need the measure state so we go to the drawing state immediately
        // and begin drawing on the next line before we can get outside the container.
        if (state == .MEASURE_STATE) {
            // TODO: There are multiple types of spaces in UNICODE, maybe it's a good idea to add support for more
            // Ref: http://jkorpela.fi/chars/spaces.html
            if ((codepoint == #char " ") || (codepoint == #char "\t") || (codepoint == #char "\n")) endLine = i;

            if ((textOffsetX + glyphWidth) > rec.width) {
                endLine = ifx (endLine < 1) then i else endLine;
                if (i == endLine) endLine -= codepointByteCount;
                if ((startLine + codepointByteCount) == endLine) endLine = (i - codepointByteCount);

                state = ifx (state == .MEASURE_STATE) then .DRAW_STATE else .MEASURE_STATE;
            } else if ((i + 1) == length) {
                endLine = i;
                state = ifx (state == .MEASURE_STATE) then .DRAW_STATE else .MEASURE_STATE;
            } else if (codepoint == #char "\n") state = ifx (state == .MEASURE_STATE) then .DRAW_STATE else .MEASURE_STATE;

            if (state == .DRAW_STATE) {
                textOffsetX = 0;
                i = startLine;
                glyphWidth = 0;

                // Save character position when we switch states
                tmp: s32 = lastk;
                lastk = k - 1;
                k = tmp;
            }
        } else {
            if (codepoint == #char "\n") {
                if (!wordWrap) {
                    textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                    textOffsetX = 0;
                }
            } else {
                if (!wordWrap && ((textOffsetX + glyphWidth) > rec.width)) {
                    textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                    textOffsetX = 0;
                }

                // When text overflows rectangle height limit, just stop drawing
                if ((textOffsetY + font.baseSize*scaleFactor) > rec.height) break;

                // Draw selection background
                isGlyphSelected: bool = false;
                if ((selectStart >= 0) && (k >= selectStart) && (k < (selectStart + selectLength))) {
                    DrawRectangleRec(Rectangle.{rec.x + textOffsetX - 1, rec.y + textOffsetY, glyphWidth, cast(float)font.baseSize*scaleFactor}, selectBackTint);
                    isGlyphSelected = true;
                }

                // Draw current character glyph
                if ((codepoint != #char " ") && (codepoint != #char "\t"))
                {
                    DrawTextCodepoint(font, codepoint, Vector2.{rec.x + textOffsetX, rec.y + textOffsetY}, fontSize, ifx isGlyphSelected then selectTint else tint);
                }
            }

            if (wordWrap && (i == endLine)) {
                textOffsetY += (font.baseSize + font.baseSize/2)*scaleFactor;
                textOffsetX  = 0;
                startLine    = endLine;
                endLine      = -1;
                glyphWidth   = 0;
                selectStart += lastk - k;
                k            = lastk;

                state = ifx (state == .MEASURE_STATE) then .DRAW_STATE else .MEASURE_STATE;
            }
        }

        if ((textOffsetX != 0) || (codepoint != #char " ")) textOffsetX += glyphWidth;  // avoid leading spaces
    }
}

