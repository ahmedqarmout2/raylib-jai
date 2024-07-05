#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [texture] example - image text drawing");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    parrots: Image = LoadImage("resources/parrots.png"); // Load image in CPU memory (RAM)

    // TTF Font loading with custom generation parameters
    font: Font = LoadFontEx("resources/KAISG.ttf", 64, null, 0);

    // Draw over image using custom font
    ImageDrawTextEx(*parrots, font, "[Parrots font drawing]", Vector2.{ 20.0, 20.0 }, cast(float)font.baseSize, 0.0, RED);

    texture: Texture2D = LoadTextureFromImage(parrots);  // Image converted to texture, uploaded to GPU memory (VRAM)
    UnloadImage(parrots);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    position: Vector2 = .{ cast(float)(screenWidth/2 - texture.width/2), cast(float)(screenHeight/2 - texture.height/2 - 20) };

    showFont: bool = false;

    SetTargetFPS(60);

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_SPACE)) showFont = true;
        else showFont = false;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        if (!showFont) {
            // Draw texture with text already drawn inside
            DrawTextureV(texture, position, WHITE);

            // Draw text directly using sprite font
            DrawTextEx(font, "[Parrots font drawing]", Vector2.{ position.x + 20, position.y + 20 + 280 }, cast(float)font.baseSize, 0.0, WHITE);
        } else DrawTexture(font.texture, screenWidth/2 - font.texture.width/2, 50, BLACK);

        DrawText("PRESS SPACE to SHOW FONT ATLAS USED", 290, 420, 10, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);     // Texture unloading

    UnloadFont(font);           // Unload custom font

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}