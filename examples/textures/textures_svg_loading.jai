#import "raylib";
#import "Basic";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - svg loading");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    image: Image = LoadImageSvg("resources/test.svg", 400, 350); // Loaded in CPU memory (RAM)
    texture: Texture2D = LoadTextureFromImage(image);            // Image converted to texture, GPU memory (VRAM)
    UnloadImage(image);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    SetTargetFPS(60);     // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Nothing to do
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2, WHITE);

        //Red border to illustrate how the SVG is centered within the specified dimensions
        DrawRectangleLines((screenWidth / 2 - texture.width / 2) - 1, (screenHeight / 2 - texture.height / 2) - 1, texture.width + 2, texture.height + 2, RED);

        DrawText("this IS a texture loaded from an SVG file!", 300, 410, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}