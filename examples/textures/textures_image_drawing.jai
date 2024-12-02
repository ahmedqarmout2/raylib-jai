#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    cat: Image = LoadImage("resources/cat.png");            // Load image in CPU memory (RAM)
    ImageCrop(*cat, Rectangle.{ 100, 10, 280, 380 });       // Crop an image piece
    ImageFlipHorizontal(*cat);                              // Flip cropped image horizontally
    ImageResize(*cat, 150, 200);                            // Resize flipped-cropped image

    parrots: Image = LoadImage("resources/parrots.png");    // Load image in CPU memory (RAM)

    // Draw one image over the other with a scaling of 1.5f
    ImageDraw(*parrots, cat, Rectangle.{ 0, 0, cast(float)cat.width, cast(float)cat.height }, Rectangle.{ 30, 40, cat.width*1.5, cat.height*1.5 }, WHITE);
    ImageCrop(*parrots, Rectangle.{ 0, 50, cast(float)parrots.width, cast(float)parrots.height - 100 }); // Crop resulting image

    // Draw on the image with a few image draw methods
    ImageDrawPixel(*parrots, 10, 10, RAYWHITE);
    ImageDrawCircleLines(*parrots, 10, 10, 5, RAYWHITE);
    ImageDrawRectangle(*parrots, 5, 20, 10, 10, RAYWHITE);

    UnloadImage(cat);       // Unload image from RAM

    // Load custom font for frawing on image
    font: Font = LoadFont("resources/custom_jupiter_crash.png");

    // Draw over image using custom font
    ImageDrawTextEx(*parrots, font, "PARROTS & CAT", Vector2.{ 300, 230 }, cast(float)font.baseSize, -2, WHITE);

    UnloadFont(font);       // Unload custom font (already drawn used on image)

    texture: Texture2D = LoadTextureFromImage(parrots);      // Image converted to texture, uploaded to GPU memory (VRAM)
    defer UnloadTexture(texture);       // Texture unloading

    UnloadImage(parrots);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    SetTargetFPS(60);
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

        DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, WHITE);
        DrawRectangleLines(screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, texture.width, texture.height, DARKGRAY);

        DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, DARKGRAY);
        DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, DARKGRAY);
        //----------------------------------------------------------------------------------
    }
}