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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image channel");

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
    textureAlpha      : Texture2D = LoadTextureFromImage(imageAlpha);
    textureRed        : Texture2D = LoadTextureFromImage(imageRed);
    textureGreen      : Texture2D = LoadTextureFromImage(imageGreen);
    textureBlue       : Texture2D = LoadTextureFromImage(imageBlue);
    backgroundTexture : Texture2D = LoadTextureFromImage(backgroundImage);

    UnloadImage(fudesumiImage);
    UnloadImage(imageAlpha);
    UnloadImage(imageRed);
    UnloadImage(imageGreen);
    UnloadImage(imageBlue);
    UnloadImage(backgroundImage);

    fudesumiRec: Rectangle = .{0, 0, fudesumiImage.width*1.0, fudesumiImage.height*1.0};

    fudesumiPos : Rectangle = .{50, 10, fudesumiImage.width*0.8, fudesumiImage.height*0.8};
    redPos      : Rectangle = .{410, 10, fudesumiPos.width / 2, fudesumiPos.height / 2};
    greenPos    : Rectangle = .{600, 10, fudesumiPos.width / 2, fudesumiPos.height / 2};
    bluePos     : Rectangle = .{410, 230, fudesumiPos.width / 2, fudesumiPos.height / 2};
    alphaPos    : Rectangle = .{600, 230, fudesumiPos.width / 2, fudesumiPos.height / 2};

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            DrawTexture(backgroundTexture, 0, 0, WHITE);
            DrawTexturePro(fudesumiTexture, fudesumiRec, fudesumiPos, Vector2.{0, 0}, 0, WHITE);

            DrawTexturePro(textureRed, fudesumiRec, redPos, Vector2.{0, 0}, 0, RED);
            DrawTexturePro(textureGreen, fudesumiRec, greenPos, Vector2.{0, 0}, 0, GREEN);
            DrawTexturePro(textureBlue, fudesumiRec, bluePos, Vector2.{0, 0}, 0, BLUE);
            DrawTexturePro(textureAlpha, fudesumiRec, alphaPos, Vector2.{0, 0}, 0, WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(backgroundTexture);
    UnloadTexture(fudesumiTexture);
    UnloadTexture(textureRed);
    UnloadTexture(textureGreen);
    UnloadTexture(textureBlue);
    UnloadTexture(textureAlpha);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}