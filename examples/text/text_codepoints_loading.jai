#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

// Text to be displayed, must be UTF-8 (save this code file as UTF-8)
// NOTE: It can contain all the required text for the game,
// this text will be scanned to get all the required codepoints
text: *char = "いろはにほへと　ちりぬるを\nわかよたれそ　つねならむ\nうゐのおくやま　けふこえて\nあさきゆめみし　ゑひもせす";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - codepoints loading");
    defer CloseWindow(); // Close window and OpenGL context

    // Get codepoints from text
    codepointCount: s32 = 0;
    codepoints: *s32 = LoadCodepoints(text, *codepointCount);

    // Removed duplicate codepoints to generate smaller font atlas
    codepointsNoDupsCount: s32 = 0;
    codepointsNoDups: *s32 = CodepointRemoveDuplicates(codepoints, codepointCount, *codepointsNoDupsCount);
    UnloadCodepoints(codepoints);

    // Load font containing all the provided codepoint glyphs
    // A texture font atlas is automatically generated
    font: Font = LoadFontEx("resources/DotGothic16-Regular.ttf", 36, codepointsNoDups, codepointsNoDupsCount);
    defer UnloadFont(font);     // Unload font

    // Set bilinear scale filter for better font scaling
    SetTextureFilter(font.texture, .TEXTURE_FILTER_BILINEAR);

    SetTextLineSpacing(20);         // Set line spacing for multiline text (when line breaks are included '\n')

    // Free codepoints, atlas has already been generated
    free(codepointsNoDups);

    showFontAtlas: bool = false;

    codepointSize: s32 = 0;
    codepoint: s32 = 0;
    ptr: *char = text;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) showFontAtlas = !showFontAtlas;

        // Testing code: getting next and previous codepoints on provided text
        if (IsKeyPressed(.KEY_RIGHT)) {
            // Get next codepoint in string and move pointer
            codepoint = GetCodepointNext(ptr, *codepointSize);
            ptr += codepointSize;
        } else if (IsKeyPressed(.KEY_LEFT)) {
            // Get previous codepoint in string and move pointer
            codepoint = GetCodepointPrevious(ptr, *codepointSize);
            ptr -= codepointSize;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawRectangle(0, 0, GetScreenWidth(), 70, BLACK);
        DrawText(TextFormat("Total codepoints contained in provided text: %i", codepointCount), 10, 10, 20, GREEN);
        DrawText(TextFormat("Total codepoints required for font atlas (duplicates excluded): %i", codepointsNoDupsCount), 10, 40, 20, GREEN);

        if (showFontAtlas) {
            // Draw generated font texture atlas containing provided codepoints
            DrawTexture(font.texture, 150, 100, BLACK);
            DrawRectangleLines(150, 100, font.texture.width, font.texture.height, BLACK);
        } else {
            // Draw provided text with laoded font, containing all required codepoint glyphs
            DrawTextEx(font, text, Vector2.{ 160, 110 }, 48, 5, BLACK);
        }

        DrawText("Press SPACE to toggle font atlas view!", 10, GetScreenHeight() - 30, 20, GRAY);
        //----------------------------------------------------------------------------------
    }
}

// Remove codepoint duplicates if requested
// WARNING: This process could be a bit slow if there text to process is very long
CodepointRemoveDuplicates :: (codepoints: *s32, codepointCount: s32, codepointsResultCount: *s32) -> *s32 {
    codepointsNoDupsCount: s32 = codepointCount;
    codepointsNoDups: *s32 = cast(*s32)alloc(size_of(s32));
    memcpy(codepointsNoDups, codepoints, codepointCount*size_of(s32));

    // Remove duplicates
    i: s32 = 0;
    while (i < codepointsNoDupsCount) {
        defer i += 1;

        j: s32 = i + 1;
        while (j < codepointsNoDupsCount) {
            defer j += 1;
            if (codepointsNoDups[i] == codepointsNoDups[j]) {

                k: s32 = j;
                while (k < codepointsNoDupsCount) {
                    defer k += 1;

                    codepointsNoDups[k] = codepointsNoDups[k + 1];
                }

                codepointsNoDupsCount -= 1;
                j -= 1;
            }
        }
    }

    // NOTE: The size of codepointsNoDups is the same as original array but
    // only required positions are filled (codepointsNoDupsCount)

    <<codepointsResultCount = codepointsNoDupsCount;
    return codepointsNoDups;
}