#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - extract channel from image");
    defer CloseWindow(); // Close window and OpenGL context

    fudesumiImage: Image = LoadImage("resources/fudesumi.png");

    imageAlpha: Image = ImageFromChannel(fudesumiImage, 3);
    ImageAlphaMask(*imageAlpha, imageAlpha);

    imageRed: Image = ImageFromChannel(fudesumiImage, 0);
    ImageAlphaMask(*imageRed, imageAlpha);

    imageGreen: Image = ImageFromChannel(fudesumiImage, 1);
    ImageAlphaMask(*imageGreen, imageAlpha);

    imageBlue: Image = ImageFromChannel(fudesumiImage, 2);
    ImageAlphaMask(*imageBlue, imageAlpha);

    backgroundImage: Image = GenImageChecked(screenWidth, screenHeight, screenWidth/20, screenHeight/20, ORANGE, YELLOW);

    fudesumiTexture   : Texture2D = LoadTextureFromImage(fudesumiImage);
    defer UnloadTexture(fudesumiTexture);

    textureAlpha      : Texture2D = LoadTextureFromImage(imageAlpha);
    defer UnloadTexture(textureAlpha);

    textureRed        : Texture2D = LoadTextureFromImage(imageRed);
    defer UnloadTexture(textureRed);

    textureGreen      : Texture2D = LoadTextureFromImage(imageGreen);
    defer UnloadTexture(textureGreen);

    textureBlue       : Texture2D = LoadTextureFromImage(imageBlue);
    defer UnloadTexture(textureBlue);

    backgroundTexture : Texture2D = LoadTextureFromImage(backgroundImage);
    defer UnloadTexture(backgroundTexture);

    UnloadImage(fudesumiImage);
    UnloadImage(imageAlpha);
    UnloadImage(imageRed);
    UnloadImage(imageGreen);
    UnloadImage(imageBlue);
    UnloadImage(backgroundImage);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    fudesumiRec: Rectangle = .{0, 0, fudesumiImage.width*1.0, fudesumiImage.height*1.0};

    fudesumiPos : Rectangle = .{50, 10, fudesumiImage.width*0.8, fudesumiImage.height*0.8};
    redPos      : Rectangle = .{410, 10, fudesumiPos.width / 2, fudesumiPos.height / 2};
    greenPos    : Rectangle = .{600, 10, fudesumiPos.width / 2, fudesumiPos.height / 2};
    bluePos     : Rectangle = .{410, 230, fudesumiPos.width / 2, fudesumiPos.height / 2};
    alphaPos    : Rectangle = .{600, 230, fudesumiPos.width / 2, fudesumiPos.height / 2};
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

        DrawTexture(backgroundTexture, 0, 0, WHITE);
        DrawTexturePro(fudesumiTexture, fudesumiRec, fudesumiPos, Vector2.{0, 0}, 0, WHITE);

        DrawTexturePro(textureRed, fudesumiRec, redPos, Vector2.{0, 0}, 0, RED);
        DrawTexturePro(textureGreen, fudesumiRec, greenPos, Vector2.{0, 0}, 0, GREEN);
        DrawTexturePro(textureBlue, fudesumiRec, bluePos, Vector2.{0, 0}, 0, BLUE);
        DrawTexturePro(textureAlpha, fudesumiRec, alphaPos, Vector2.{0, 0}, 0, WHITE);
        //----------------------------------------------------------------------------------
    }
}