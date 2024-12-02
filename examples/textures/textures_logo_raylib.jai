#import "raylib";
#import "Basic";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - texture loading and drawing");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    texture: Texture2D = LoadTexture("resources/raylib_logo.png");        // Texture loading
    defer UnloadTexture(texture);       // Texture unloading
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Nothing to do
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2, WHITE);

        DrawText("this IS a texture!", 360, 370, 10, GRAY);
        //----------------------------------------------------------------------------------
    }
}