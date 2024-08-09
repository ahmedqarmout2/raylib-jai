#import "raylib";
#import "Basic";

NUM_TEXTURES: s32 : 3;

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - texture rotation");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

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

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) || IsKeyPressed(.KEY_RIGHT)) {
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
    for textures UnloadTexture(it);
    //--------------------------------------------------------------------------------------
}