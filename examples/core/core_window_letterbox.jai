#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    windowWidth  : s32 : 800;
    windowHeight : s32 : 450;

    // Enable config flags for resizable window and vertical synchro
    SetConfigFlags(.FLAG_WINDOW_RESIZABLE | .FLAG_VSYNC_HINT);
    InitWindow(windowWidth, windowHeight, "raylib [core] example - window scale letterbox");
    defer CloseWindow(); // Close window and OpenGL context

    SetWindowMinSize(320, 240);

    gameScreenWidth  : s32 = 640;
    gameScreenHeight : s32 = 480;

    // Render texture initialization, used to hold the rendering result so we can easily resize it
    target: RenderTexture2D = LoadRenderTexture(gameScreenWidth, gameScreenHeight);
    defer UnloadRenderTexture(target);        // Unload render texture

    SetTextureFilter(target.texture, .TEXTURE_FILTER_BILINEAR);  // Texture scale filter to use

    colors: [10]Color;
    for 0..9 colors[it] = Color.{ cast(u8)GetRandomValue(100, 250), cast(u8)GetRandomValue(50, 150), cast(u8)GetRandomValue(10, 100), 255 };

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Compute required framebuffer scaling
        scale: float = min(cast(float)GetScreenWidth()/gameScreenWidth, cast(float)GetScreenHeight()/gameScreenHeight);

        if (IsKeyPressed(.KEY_SPACE)) {
            // Recalculate random colors for the bars
            for 0..9 colors[it] = Color.{ cast(u8)GetRandomValue(100, 250), cast(u8)GetRandomValue(50, 150), cast(u8)GetRandomValue(10, 100), 255 };
        }

        // Update virtual mouse (clamped mouse value behind game screen)
        mouse: Vector2 = GetMousePosition();
        virtualMouse: Vector2;
        virtualMouse.x = (mouse.x - (GetScreenWidth() - (gameScreenWidth*scale))*0.5)/scale;
        virtualMouse.y = (mouse.y - (GetScreenHeight() - (gameScreenHeight*scale))*0.5)/scale;
        virtualMouse = Vector2Clamp(virtualMouse, Vector2.{ 0.0, 0.0 }, Vector2.{ cast(float)gameScreenWidth, cast(float)gameScreenHeight });

        // Apply the same transformation as the virtual mouse to the real mouse (i.e. to work with raygui)
        //SetMouseOffset(-(GetScreenWidth() - (gameScreenWidth*scale))*0.5f, -(GetScreenHeight() - (gameScreenHeight*scale))*0.5f);
        //SetMouseScale(1/scale, 1/scale);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            // Draw everything in the render texture, note this will not be rendered on screen, yet
            BeginTextureMode(target);
            defer EndTextureMode();

            ClearBackground(RAYWHITE);  // Clear render texture background color

            i: s32 = 0;
            while (i < 10) {
                DrawRectangle(0, (gameScreenHeight/10)*i, gameScreenWidth, gameScreenHeight/10, colors[i]);
                i += 1;
            }

            DrawText("If executed inside a window,\nyou can resize the window,\nand see the screen scaling!", 10, 25, 20, WHITE);
            DrawText(TextFormat("Default Mouse: [%i , %i]", cast(s32)mouse.x, cast(s32)mouse.y), 350, 25, 20, GREEN);
            DrawText(TextFormat("Virtual Mouse: [%i , %i]", cast(s32)virtualMouse.x, cast(s32)virtualMouse.y), 350, 55, 20, YELLOW);
        }

        
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(BLACK);     // Clear screen background

        // Draw render texture to screen, properly scaled
        DrawTexturePro(
            target.texture,
            Rectangle.{ 0.0, 0.0, cast(float)target.texture.width, cast(float)-target.texture.height },
            Rectangle.{
                (GetScreenWidth() - (cast(float)gameScreenWidth*scale))*0.5,
                (GetScreenHeight() - (cast(float)gameScreenHeight*scale))*0.5,
                cast(float)gameScreenWidth*scale,
                cast(float)gameScreenHeight*scale},
            Vector2.{ 0.0, 0.0 },
            0.0,
            WHITE);
        //----------------------------------------------------------------------------------
    }
}