#import "raylib";
#import "Basic";

NUM_PROCESSES: s32 : 9;

ImageProcess :: enum s32 {
    NONE :: 0;
    COLOR_GRAYSCALE;
    COLOR_TINT;
    COLOR_INVERT;
    COLOR_CONTRAST;
    COLOR_BRIGHTNESS;
    GAUSSIAN_BLUR;
    FLIP_VERTICAL;
    FLIP_HORIZONTAL;
};

processText: [9]*u8: .[
    "NO PROCESSING",
    "COLOR GRAYSCALE",
    "COLOR TINT",
    "COLOR INVERT",
    "COLOR CONTRAST",
    "COLOR BRIGHTNESS",
    "GAUSSIAN BLUR",
    "FLIP VERTICAL",
    "FLIP HORIZONTAL"
];

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image processing");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    imOrigin: Image = LoadImage("resources/parrots.png");       // Loaded in CPU memory (RAM)
    ImageFormat(*imOrigin, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8); // Format image to RGBA 32bit (required for texture update) <-- ISSUE
    texture: Texture2D = LoadTextureFromImage(imOrigin);        // Image converted to texture, GPU memory (VRAM)

    imCopy: Image = ImageCopy(imOrigin);

    currentProcess : s32  = 0;
    textureReload  : bool = false;

    toggleRecs: [NUM_PROCESSES]Rectangle;
    mouseHoverRec: s32 = -1;

    for i: 0..NUM_PROCESSES-1 toggleRecs[i] = Rectangle.{ 40.0, cast(float)(50 + 32*i), 150.0, 30.0 };

    SetTargetFPS(60);

    get_image_process_value :: (i: s32) -> ImageProcess {
        if i == 1 return .COLOR_GRAYSCALE;
        if i == 2 return .COLOR_TINT;
        if i == 3 return .COLOR_INVERT;
        if i == 4 return .COLOR_CONTRAST;
        if i == 5 return .COLOR_BRIGHTNESS;
        if i == 6 return .GAUSSIAN_BLUR;
        if i == 7 return .FLIP_VERTICAL;
        if i == 8 return .FLIP_HORIZONTAL;
        return .NONE;
    }

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Mouse toggle group logic
        for i: 0..NUM_PROCESSES-1 {
            if (CheckCollisionPointRec(GetMousePosition(), toggleRecs[i])) {
                mouseHoverRec = i;

                if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) {
                    currentProcess = i;
                    textureReload   = true;
                }
                break;
            }
            else mouseHoverRec = -1;
        }

        // Keyboard toggle group logic
        if (IsKeyPressed(.KEY_DOWN)) {
            currentProcess += 1;
            if (currentProcess > (NUM_PROCESSES - 1)) currentProcess = 0;
            textureReload = true;
        } else if (IsKeyPressed(.KEY_UP)) {
            currentProcess -= 1;
            if (currentProcess < 0) currentProcess = 7;
            textureReload = true;
        }

        // Reload texture when required
        if (textureReload) {
            UnloadImage(imCopy);                // Unload image-copy data
            imCopy = ImageCopy(imOrigin);     // Restore image-copy from image-origin

            // NOTE: Image processing is a costly CPU process to be done every frame,
            // If image processing is required in a frame-basis, it should be done
            // with a texture and by shaders
            if get_image_process_value(currentProcess) == {
                case .COLOR_GRAYSCALE;  ImageColorGrayscale(*imCopy);
                case .COLOR_TINT;       ImageColorTint(*imCopy, GREEN);
                case .COLOR_INVERT;     ImageColorInvert(*imCopy);
                case .COLOR_CONTRAST;   ImageColorContrast(*imCopy, -40);
                case .COLOR_BRIGHTNESS; ImageColorBrightness(*imCopy, -80);
                case .GAUSSIAN_BLUR;    ImageBlurGaussian(*imCopy, 10);
                case .FLIP_VERTICAL;    ImageFlipVertical(*imCopy);
                case .FLIP_HORIZONTAL;  ImageFlipHorizontal(*imCopy);
            }

            pixels: *Color = LoadImageColors(imCopy);   // Load pixel data from image (RGBA 32bit)
            UpdateTexture(texture, pixels);             // Update texture with new image data
            UnloadImageColors(pixels);                  // Unload pixels data from RAM

            textureReload = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawText("IMAGE PROCESSING:", 40, 30, 10, DARKGRAY);

        // Draw rectangles
        for i: 0..NUM_PROCESSES-1 {
            DrawRectangleRec(toggleRecs[i], ifx((i == currentProcess) || (i == mouseHoverRec)) then SKYBLUE else LIGHTGRAY);
            DrawRectangleLines(cast(s32)toggleRecs[i].x, cast(s32)toggleRecs[i].y, cast(s32)toggleRecs[i].width, cast(s32)toggleRecs[i].height, ifx((i == currentProcess) || (i == mouseHoverRec)) then BLUE else GRAY);
            DrawText(processText[i], cast(s32)(toggleRecs[i].x + toggleRecs[i].width/2 - MeasureText(processText[i], 10)/2), cast(s32)toggleRecs[i].y + 11, 10, ifx((i == currentProcess) || (i == mouseHoverRec)) then DARKBLUE else DARKGRAY);
        }

        DrawTexture(texture, screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, WHITE);
        DrawRectangleLines(screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, texture.width, texture.height, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Unload texture from VRAM
    UnloadImage(imOrigin);        // Unload image-origin from RAM
    UnloadImage(imCopy);          // Unload image-copy from RAM
    //--------------------------------------------------------------------------------------
}