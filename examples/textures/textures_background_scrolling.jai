#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - background scrolling");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Be careful, background width must be equal or bigger than screen width
    // if not, texture should be draw more than two times for scrolling effect
    background: Texture2D = LoadTexture("resources/cyberpunk_street_background.png");
    defer UnloadTexture(background);  // Unload background texture

    midground : Texture2D = LoadTexture("resources/cyberpunk_street_midground.png");
    defer UnloadTexture(midground);   // Unload midground texture

    foreground: Texture2D = LoadTexture("resources/cyberpunk_street_foreground.png");
    defer UnloadTexture(foreground);  // Unload foreground texture

    scrollingBack: float = 0.0;
    scrollingMid : float = 0.0;
    scrollingFore: float = 0.0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        scrollingBack -= 0.1;
        scrollingMid  -= 0.5;
        scrollingFore -= 1.0;

        // NOTE: Texture is scaled twice its size, so it sould be considered on scrolling
        if (scrollingBack <= cast(float)-background.width*2) scrollingBack = 0;
        if (scrollingMid  <= cast(float)-midground.width*2)  scrollingMid  = 0;
        if (scrollingFore <= cast(float)-foreground.width*2) scrollingFore = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(GetColor(0x052c46ff));

            // Draw background image twice
            // NOTE: Texture is scaled twice its size
            DrawTextureEx(background, Vector2.{ scrollingBack, 20 }, 0.0, 2.0, WHITE);
            DrawTextureEx(background, Vector2.{ background.width*2 + scrollingBack, 20 }, 0.0, 2.0, WHITE);

            // Draw midground image twice
            DrawTextureEx(midground, Vector2.{ scrollingMid, 20 }, 0.0, 2.0, WHITE);
            DrawTextureEx(midground, Vector2.{ midground.width*2 + scrollingMid, 20 }, 0.0, 2.0, WHITE);

            // Draw foreground image twice
            DrawTextureEx(foreground, Vector2.{ scrollingFore, 70 }, 0.0, 2.0, WHITE);
            DrawTextureEx(foreground, Vector2.{ foreground.width*2 + scrollingFore, 70 }, 0.0, 2.0, WHITE);

            DrawText("BACKGROUND SCROLLING & PARALLAX", 10, 10, 20, RED);
            DrawText("(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)", screenWidth - 330, screenHeight - 20, 10, RAYWHITE);
        }
        //----------------------------------------------------------------------------------
    }
}