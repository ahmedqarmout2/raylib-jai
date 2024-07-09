#import "raylib";
#import "Basic";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - texture to image");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    image: Image = LoadImage("resources/raylib_logo.png");  // Load image data into CPU memory (RAM)
    texture: Texture2D = LoadTextureFromImage(image);       // Image converted to texture, GPU memory (RAM -> VRAM)
    UnloadImage(image);                                     // Unload image data from CPU memory (RAM)

    image = LoadImageFromTexture(texture);                  // Load image from GPU texture (VRAM -> RAM)
    UnloadTexture(texture);                                 // Unload texture from GPU memory (VRAM)

    texture = LoadTextureFromImage(image);                  // Recreate texture from retrieved image data (RAM -> VRAM)
    UnloadImage(image);                                     // Unload retrieved image data from CPU memory (RAM)

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

        DrawText("this IS a texture loaded from an image!", 300, 370, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}