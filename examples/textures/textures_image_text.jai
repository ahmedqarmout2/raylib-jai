#import "raylib";
#import "Basic";
#import "Math";

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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image text");

    parrots: Image = LoadImage("resources/parrots.png"); // Load image in CPU memory (RAM)

    // When no codepoints are provided, LoadFontEx() loads a default set of codepoints
    // This set includes '@', which "KAISG.ttf" doesn't have a glyph for, causing a warning to be logged
    // We avoid this by just excluding it from the list of codepoints we load
    codepointCount: s32 = 0;
    codepoints: *s32 = LoadCodepoints(" !\"#$%&'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~", *codepointCount);
    // TTF Font loading with custom generation parameters
    font: Font = LoadFontEx("resources/KAISG.ttf", 64, codepoints, codepointCount);
    UnloadCodepoints(codepoints);

    // Draw over image using custom font
    ImageDrawTextEx(*parrots, font, "[Parrots font drawing]", Vector2.{ 20.0, 20.0 }, cast(float)font.baseSize, 0.0, RED);

    texture: Texture2D = LoadTextureFromImage(parrots);  // Image converted to texture, uploaded to GPU memory (VRAM)
    UnloadImage(parrots);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    position: Vector2 = .{ cast(float)(screenWidth/2 - texture.width/2), cast(float)(screenHeight/2 - texture.height/2 - 20) };

    showFont: bool = false;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_SPACE)) showFont = true;
        else showFont = false;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (!showFont)
            {
                // Draw texture with text already drawn inside
                DrawTextureV(texture, position, WHITE);

                // Draw text directly using sprite font
                DrawTextEx(font, "[Parrots font drawing]", Vector2.{ position.x + 20, position.y + 20 + 280 }, cast(float)font.baseSize, 0.0, WHITE);
            }
            else
            {
                // Make the font atlas texture fit the screen, so we can see the whole thing
                scale: float = 1.0;

                atlasRatio: float = cast(float)font.texture.width/cast(float)font.texture.height;
                screenRatio: float = cast(float)screenWidth/cast(float)screenHeight;
                if (atlasRatio >= screenRatio) scale = cast(float)screenWidth/cast(float)font.texture.width;
                else scale = cast(float)screenHeight/cast(float)font.texture.height;

                width: float = cast(float)font.texture.width * scale;
                height: float = cast(float)font.texture.height * scale;

                DrawTextureEx(font.texture, Vector2.{ (cast(float)screenWidth - width)/2, (cast(float)screenHeight - height)/2 }, 0, scale, BLACK);
            }

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