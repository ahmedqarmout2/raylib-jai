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

    image: Image = LoadImage("resources/cat.png");     // Loaded in CPU memory (RAM)

    gaussiankernel: [9]float = .[ 
        1.0, 2.0, 1.0,
        2.0, 4.0, 2.0,
        1.0, 2.0, 1.0 ];

    sobelkernel: [9]float = .[
        1.0, 0.0, -1.0,
        2.0, 0.0, -2.0,
        1.0, 0.0, -1.0 ];

    sharpenkernel: [9]float = .[
        0.0, -1.0, 0.0,
       -1.0, 5.0, -1.0,
        0.0, -1.0, 0.0 ];

    NormalizeKernel(gaussiankernel.data, 9);
    NormalizeKernel(sharpenkernel.data , 9);
    NormalizeKernel(sobelkernel.data   , 9);

    catSharpend: Image = ImageCopy(image);
    ImageKernelConvolution(*catSharpend, sharpenkernel.data, 9);
 
    catSobel: Image = ImageCopy(image);
    ImageKernelConvolution(*catSobel, sobelkernel.data, 9);

    catGaussian: Image = ImageCopy(image);
    for 0..5 {
        ImageKernelConvolution(*catGaussian, gaussiankernel.data, 9);
    }

    ImageCrop(*image      , Rectangle.{0, 0, 200, 450});
    ImageCrop(*catGaussian, Rectangle.{0, 0, 200, 450});
    ImageCrop(*catSobel   , Rectangle.{0, 0, 200, 450});
    ImageCrop(*catSharpend, Rectangle.{0, 0, 200, 450});
    
    // Images converted to texture, GPU memory (VRAM)
    texture            : Texture2D = LoadTextureFromImage(image);
    defer UnloadTexture(texture);

    catSharpendTexture : Texture2D = LoadTextureFromImage(catSharpend);
    defer UnloadTexture(catSharpendTexture);

    catSobelTexture    : Texture2D = LoadTextureFromImage(catSobel);
    defer UnloadTexture(catSobelTexture);

    catGaussianTexture : Texture2D = LoadTextureFromImage(catGaussian);
    defer UnloadTexture(catGaussianTexture);
    
    // Once images have been converted to texture and uploaded to VRAM, 
    // they can be unloaded from RAM
    UnloadImage(image);
    UnloadImage(catGaussian);
    UnloadImage(catSobel);
    UnloadImage(catSharpend);

    SetTargetFPS(60);     // Set our game to run at 60 frames-per-second
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

        DrawTexture(catSharpendTexture, 0  , 0, WHITE);
        DrawTexture(catSobelTexture   , 200, 0, WHITE);
        DrawTexture(catGaussianTexture, 400, 0, WHITE);
        DrawTexture(texture           , 600, 0, WHITE);
        //----------------------------------------------------------------------------------
    }
}

NormalizeKernel :: (kernel: *float, size: s32) {
    sum: float = 0.0;
    for 0..size-1 sum += kernel[it];

    if (sum != 0.0) {
        for 0..size-1 kernel[it] /= sum;
    }
}