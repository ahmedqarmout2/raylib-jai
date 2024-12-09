#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - font filters");
    defer CloseWindow(); // Close window and OpenGL context

    msg: [50]char;
    s := "Loaded Font";
    for s msg[it_index] = it;

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

    // TTF Font loading with custom generation parameters
    font: Font = LoadFontEx("resources/KAISG.ttf", 96, null, 0);
    defer UnloadFont(font);           // Font unloading

    // Generate mipmap levels to use trilinear filtering
    // NOTE: On 2D drawing it won't be noticeable, it looks like FILTER_BILINEAR
    GenTextureMipmaps(*font.texture);

    fontSize    : float = cast(float)font.baseSize;
    fontPosition: Vector2 = .{40.0, screenHeight/2.0 - 80.0};
    textSize    : Vector2 = .{0.0, 0.0};

    // Setup texture scaling filter
    SetTextureFilter(font.texture, .TEXTURE_FILTER_POINT);
    currentFontFilter: s32 = 0;      // TEXTURE_FILTER_POINT

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        fontSize += GetMouseWheelMove()*4.0;

        // Choose font texture filter method
        if (IsKeyPressed(.KEY_ONE)) {
            SetTextureFilter(font.texture, .TEXTURE_FILTER_POINT);
            currentFontFilter = 0;
        } else if (IsKeyPressed(.KEY_TWO)) {
            SetTextureFilter(font.texture, .TEXTURE_FILTER_BILINEAR);
            currentFontFilter = 1;
        } else if (IsKeyPressed(.KEY_THREE)) {
            // NOTE: Trilinear filter won't be noticed on 2D drawing
            SetTextureFilter(font.texture, .TEXTURE_FILTER_TRILINEAR);
            currentFontFilter = 2;
        }

        textSize = MeasureTextEx(font, msg.data, fontSize, 0);

             if (IsKeyDown(.KEY_LEFT))  fontPosition.x -= 10;
        else if (IsKeyDown(.KEY_RIGHT)) fontPosition.x += 10;

        // Load a dropped TTF file dynamically (at current fontSize)
        if (IsFileDropped()) {
            droppedFiles: FilePathList = LoadDroppedFiles();
            defer UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory

            // NOTE: We only support first ttf file dropped
            if (IsFileExtension(droppedFiles.paths[0], ".ttf")) {
                UnloadFont(font);
                font = LoadFontEx(droppedFiles.paths[0], cast(s32)fontSize, null, 0);
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("Use mouse wheel to change font size", 20, 20, 10, GRAY);
        DrawText("Use KEY_RIGHT and KEY_LEFT to move text", 20, 40, 10, GRAY);
        DrawText("Use 1, 2, 3 to change texture filter", 20, 60, 10, GRAY);
        DrawText("Drop a new TTF font for dynamic loading", 20, 80, 10, DARKGRAY);

        DrawTextEx(font, msg.data, fontPosition, fontSize, 0, BLACK);

        // TODO: It seems texSize measurement is not accurate due to chars offsets...
        //DrawRectangleLines(fontPosition.x, fontPosition.y, textSize.x, textSize.y, RED);

        DrawRectangle(0, screenHeight - 80, screenWidth, 80, LIGHTGRAY);
        DrawText(TextFormat("Font size: %02.02f", fontSize), 20, screenHeight - 50, 10, DARKGRAY);
        DrawText(TextFormat("Text size: [%02.02f, %02.02f]", textSize.x, textSize.y), 20, screenHeight - 30, 10, DARKGRAY);
        DrawText("CURRENT TEXTURE FILTER:", 250, 400, 20, GRAY);

        if (currentFontFilter == 0) DrawText("POINT", 570, 400, 20, BLACK);
        else if (currentFontFilter == 1) DrawText("BILINEAR", 570, 400, 20, BLACK);
        else if (currentFontFilter == 2) DrawText("TRILINEAR", 570, 400, 20, BLACK);
        //----------------------------------------------------------------------------------
    }
}
