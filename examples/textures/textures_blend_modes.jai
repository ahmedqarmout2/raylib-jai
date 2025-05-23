#import "raylib";
#import "Basic";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - blend modes");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    bgImage: Image = LoadImage("resources/cyberpunk_street_background.png");     // Loaded in CPU memory (RAM)
    bgTexture: Texture2D = LoadTextureFromImage(bgImage);                        // Image converted to texture, GPU memory (VRAM)
    defer UnloadTexture(bgTexture); // Unload background texture

    fgImage: Image = LoadImage("resources/cyberpunk_street_foreground.png");     // Loaded in CPU memory (RAM)
    fgTexture: Texture2D = LoadTextureFromImage(fgImage);                        // Image converted to texture, GPU memory (VRAM)
    defer UnloadTexture(fgTexture); // Unload foreground texture

    // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM
    UnloadImage(bgImage);
    UnloadImage(fgImage);

    blendCountMax: s32 : 4;
    blendMode: BlendMode = .BLEND_ALPHA;
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) {
            if blendMode == {
                case .BLEND_ALPHA;      blendMode = .BLEND_ADDITIVE;
                case .BLEND_ADDITIVE;   blendMode = .BLEND_MULTIPLIED;
                case .BLEND_MULTIPLIED; blendMode = .BLEND_ADD_COLORS;
                case .BLEND_ADD_COLORS; blendMode = .BLEND_ALPHA;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTexture(bgTexture, screenWidth/2 - bgTexture.width/2, screenHeight/2 - bgTexture.height/2, WHITE);

        {
            // Apply the blend mode and then draw the foreground texture
            BeginBlendMode(blendMode);
            defer EndBlendMode();

            DrawTexture(fgTexture, screenWidth/2 - fgTexture.width/2, screenHeight/2 - fgTexture.height/2, WHITE);
        }

        // Draw the texts
        DrawText("Press SPACE to change blend modes.", 310, 350, 10, GRAY);

        if blendMode == {
            case .BLEND_ALPHA;      DrawText("Current: BLEND_ALPHA",      (screenWidth / 2) - 60, 370, 10, GRAY);
            case .BLEND_ADDITIVE;   DrawText("Current: BLEND_ADDITIVE",   (screenWidth / 2) - 60, 370, 10, GRAY);
            case .BLEND_MULTIPLIED; DrawText("Current: BLEND_MULTIPLIED", (screenWidth / 2) - 60, 370, 10, GRAY);
            case .BLEND_ADD_COLORS; DrawText("Current: BLEND_ADD_COLORS", (screenWidth / 2) - 60, 370, 10, GRAY);
        }

        DrawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)", screenWidth - 330, screenHeight - 20, 10, GRAY);
        //----------------------------------------------------------------------------------
    }
}