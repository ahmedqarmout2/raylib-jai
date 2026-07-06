#import "raylib";
#import "Basic";

NUM_TEXTURES: s32 : 3;

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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image rotate");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    image45    : Image = LoadImage("resources/raylib_logo.png");
    image90    : Image = LoadImage("resources/raylib_logo.png");
    imageNeg90 : Image = LoadImage("resources/raylib_logo.png");

    ImageRotate(*image45, 45);
    ImageRotate(*image90, 90);
    ImageRotate(*imageNeg90, -90);

    textures: [NUM_TEXTURES]Texture2D;

    textures[0] = LoadTextureFromImage(image45);
    textures[1] = LoadTextureFromImage(image90);
    textures[2] = LoadTextureFromImage(imageNeg90);

    currentTexture: s32 = 0;
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) || IsKeyPressed(.KEY_RIGHT))
        {
            currentTexture = (currentTexture + 1)%NUM_TEXTURES; // Cycle between the textures
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawTexture(textures[currentTexture], screenWidth/2 - textures[currentTexture].width/2, screenHeight/2 - textures[currentTexture].height/2, WHITE);

            DrawText("Press LEFT MOUSE BUTTON to rotate the image clockwise", 250, 420, 10, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..NUM_TEXTURES-1 UnloadTexture(textures[i]);

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}