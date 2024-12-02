#import "raylib";
#import "Basic";

NUM_TEXTURES: s32 : 9;      // Currently we have 8 generation algorithms but some are have multiple purposes (Linear and Square Gradients)

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - procedural images generation");
    defer CloseWindow(); // Close window and OpenGL context

    verticalGradient   : Image = GenImageGradientLinear(screenWidth, screenHeight, 0, RED, BLUE);
    horizontalGradient : Image = GenImageGradientLinear(screenWidth, screenHeight, 90, RED, BLUE);
    diagonalGradient   : Image = GenImageGradientLinear(screenWidth, screenHeight, 45, RED, BLUE);
    radialGradient     : Image = GenImageGradientRadial(screenWidth, screenHeight, 0.0, WHITE, BLACK);
    squareGradient     : Image = GenImageGradientSquare(screenWidth, screenHeight, 0.0, WHITE, BLACK);
    checked            : Image = GenImageChecked(screenWidth, screenHeight, 32, 32, RED, BLUE);
    whiteNoise         : Image = GenImageWhiteNoise(screenWidth, screenHeight, 0.5);
    perlinNoise        : Image = GenImagePerlinNoise(screenWidth, screenHeight, 50, 50, 4.0);
    cellular           : Image = GenImageCellular(screenWidth, screenHeight, 32);

    textures: [NUM_TEXTURES]Texture2D;

    textures[0] = LoadTextureFromImage(verticalGradient);
    textures[1] = LoadTextureFromImage(horizontalGradient);
    textures[2] = LoadTextureFromImage(diagonalGradient);
    textures[3] = LoadTextureFromImage(radialGradient);
    textures[4] = LoadTextureFromImage(squareGradient);
    textures[5] = LoadTextureFromImage(checked);
    textures[6] = LoadTextureFromImage(whiteNoise);
    textures[7] = LoadTextureFromImage(perlinNoise);
    textures[8] = LoadTextureFromImage(cellular);

    // Unload image data (CPU RAM)
    UnloadImage(verticalGradient);
    UnloadImage(horizontalGradient);
    UnloadImage(diagonalGradient);
    UnloadImage(radialGradient);
    UnloadImage(squareGradient);
    UnloadImage(checked);
    UnloadImage(whiteNoise);
    UnloadImage(perlinNoise);
    UnloadImage(cellular);

    currentTexture: s32 = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

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
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTexture(textures[currentTexture], 0, 0, WHITE);

        DrawRectangle(30, 400, 325, 30, Fade(SKYBLUE, 0.5));
        DrawRectangleLines(30, 400, 325, 30, Fade(WHITE, 0.5));
        DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, WHITE);

        if currentTexture == {
            case 0; DrawText("VERTICAL GRADIENT", 560, 10, 20, RAYWHITE);
            case 1; DrawText("HORIZONTAL GRADIENT", 540, 10, 20, RAYWHITE);
            case 2; DrawText("DIAGONAL GRADIENT", 540, 10, 20, RAYWHITE);
            case 3; DrawText("RADIAL GRADIENT", 580, 10, 20, LIGHTGRAY);
            case 4; DrawText("SQUARE GRADIENT", 580, 10, 20, LIGHTGRAY);
            case 5; DrawText("CHECKED", 680, 10, 20, RAYWHITE);
            case 6; DrawText("WHITE NOISE", 640, 10, 20, RED);
            case 7; DrawText("PERLIN NOISE", 640, 10, 20, RED);
            case 8; DrawText("CELLULAR", 670, 10, 20, RAYWHITE);
        }
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload textures data (GPU VRAM)
    for textures UnloadTexture(it);
    //--------------------------------------------------------------------------------------
}