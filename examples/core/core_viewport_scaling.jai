#import "raylib";
#import "Basic";
#import "Math";

RESOLUTION_COUNT ::   4;   // For iteration purposes and teaching example

ViewportType :: enum s32 {
    // Only upscale, useful for pixel art
    KEEP_ASPECT_INTEGER;
    KEEP_HEIGHT_INTEGER;
    KEEP_WIDTH_INTEGER;
    // Can also downscale
    KEEP_ASPECT;
    KEEP_HEIGHT;
    KEEP_WIDTH;
    // For itteration purposes and as a teaching example
    VIEWPORT_TYPE_COUNT;
};

// For displaying on GUI
ViewportTypeNames: [ViewportType.VIEWPORT_TYPE_COUNT]*u8 = .[
    "KEEP_ASPECT_INTEGER",
    "KEEP_HEIGHT_INTEGER",
    "KEEP_WIDTH_INTEGER",
    "KEEP_ASPECT",
    "KEEP_HEIGHT",
    "KEEP_WIDTH",
];

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 = 800;
    screenHeight : s32 = 450;

    SetConfigFlags(.FLAG_WINDOW_RESIZABLE);
    InitWindow(screenWidth, screenHeight, "raylib [core] example - viewport scaling");

    // Preset resolutions that could be created by subdividing screen resolution
    resolutionList: [RESOLUTION_COUNT]Vector2 = .[
        Vector2.{ 64, 64 },
        Vector2.{ 256, 240 },
        Vector2.{ 320, 180 },
        // 4K doesn't work with integer scaling but included for example purposes with non-integer scaling
        Vector2.{ 3840, 2160 },
    ];

    resolutionIndex: s32 = 0;
    gameWidth: s32 = 64;
    gameHeight: s32 = 64;

    target: RenderTexture2D;
    sourceRect: Rectangle;
    destRect: Rectangle;

    viewportType: ViewportType = .KEEP_ASPECT_INTEGER;
    ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);

    // Button rectangles
    decreaseResolutionButton: Rectangle = Rectangle.{ 200, 30, 10, 10 };
    increaseResolutionButton: Rectangle = Rectangle.{ 215, 30, 10, 10 };
    decreaseTypeButton: Rectangle = Rectangle.{ 200, 45, 10, 10 };
    increaseTypeButton: Rectangle = Rectangle.{ 215, 45, 10, 10 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //----------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsWindowResized()) ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);

        mousePosition: Vector2 = GetMousePosition();
        mousePressed: bool = IsMouseButtonPressed(.MOUSE_BUTTON_LEFT);

        // Check buttons and rescale
        if (CheckCollisionPointRec(mousePosition, decreaseResolutionButton) && mousePressed)
        {
            resolutionIndex = (resolutionIndex + RESOLUTION_COUNT - 1)%RESOLUTION_COUNT;
            gameWidth = cast(s32)resolutionList[resolutionIndex].x;
            gameHeight = cast(s32)resolutionList[resolutionIndex].y;
            ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);
        }

        if (CheckCollisionPointRec(mousePosition, increaseResolutionButton) && mousePressed)
        {
            resolutionIndex = (resolutionIndex + 1)%RESOLUTION_COUNT;
            gameWidth = cast(s32)resolutionList[resolutionIndex].x;
            gameHeight = cast(s32)resolutionList[resolutionIndex].y;
            ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);
        }

        if (CheckCollisionPointRec(mousePosition, decreaseTypeButton) && mousePressed)
        {
            viewportType = (viewportType + ViewportType.VIEWPORT_TYPE_COUNT - 1)%ViewportType.VIEWPORT_TYPE_COUNT;
            ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);
        }

        if (CheckCollisionPointRec(mousePosition, increaseTypeButton) && mousePressed)
        {
            viewportType = (viewportType + 1)%ViewportType.VIEWPORT_TYPE_COUNT;
            ResizeRenderSize(viewportType, *screenWidth, *screenHeight, gameWidth, gameHeight, *sourceRect, *destRect, *target);
        }

        textureMousePosition: Vector2 = Screen2RenderTexturePosition(mousePosition, *sourceRect, *destRect);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        // Draw our scene to the render texture
        BeginTextureMode(target);
            ClearBackground(WHITE);
            DrawCircleV(textureMousePosition, 20.0, LIME);
        EndTextureMode();

        // Draw render texture to main framebuffer
        BeginDrawing();
            ClearBackground(BLACK);

            // Draw our render texture with rotation applied
            DrawTexturePro(target.texture, sourceRect, destRect, Vector2.{ 0.0, 0.0 }, 0.0, WHITE);

            // Draw Native resolution (GUI or anything)
            // Draw info box
            infoRect: Rectangle = Rectangle.{5, 5, 330, 105};
            DrawRectangleRec(infoRect, Fade(LIGHTGRAY, 0.7));
            DrawRectangleLinesEx(infoRect, 1, BLUE);

            DrawText(TextFormat("Window Resolution: %d x %d", screenWidth, screenHeight), 15, 15, 10, BLACK);
            DrawText(TextFormat("Game Resolution: %d x %d", gameWidth, gameHeight), 15, 30, 10, BLACK);

            DrawText(TextFormat("Type: %s", ViewportTypeNames[viewportType]), 15, 45, 10, BLACK);
            scaleRatio: Vector2 = Vector2.{destRect.width/sourceRect.width, -destRect.height/sourceRect.height};
            if (scaleRatio.x < 0.001 || scaleRatio.y < 0.001) DrawText(TextFormat("Scale ratio: INVALID"), 15, 60, 10, BLACK);
            else DrawText(TextFormat("Scale ratio: %.2f x %.2f", scaleRatio.x, scaleRatio.y), 15, 60, 10, BLACK);

            DrawText(TextFormat("Source size: %.2f x %.2f", sourceRect.width, -sourceRect.height), 15, 75, 10, BLACK);
            DrawText(TextFormat("Destination size: %.2f x %.2f", destRect.width, destRect.height), 15, 90, 10, BLACK);

            // Draw buttons
            DrawRectangleRec(decreaseTypeButton, SKYBLUE);
            DrawRectangleRec(increaseTypeButton, SKYBLUE);
            DrawRectangleRec(decreaseResolutionButton, SKYBLUE);
            DrawRectangleRec(increaseResolutionButton, SKYBLUE);
            DrawText("<", cast(s32)decreaseTypeButton.x + 3, cast(s32)decreaseTypeButton.y + 1, 10, BLACK);
            DrawText(">", cast(s32)increaseTypeButton.x + 3, cast(s32)increaseTypeButton.y + 1, 10, BLACK);
            DrawText("<", cast(s32)decreaseResolutionButton.x + 3, cast(s32)decreaseResolutionButton.y + 1, 10, BLACK);
            DrawText(">", cast(s32)increaseResolutionButton.x + 3, cast(s32)increaseResolutionButton.y + 1, 10, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //----------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //----------------------------------------------------------------------------------
}

//--------------------------------------------------------------------------------------
// Module Functions Definition
//--------------------------------------------------------------------------------------
KeepAspectCenteredInteger :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    sourceRect.x = 0.0;
    sourceRect.y = cast(float)gameHeight;
    sourceRect.width = cast(float)gameWidth;
    sourceRect.height = cast(float)-gameHeight;

    ratio_x: s32 = (screenWidth/gameWidth);
    ratio_y: s32 = (screenHeight/gameHeight);
    resizeRatio: float = cast(float)(ifx (ratio_x < ratio_y) then ratio_x else ratio_y);

    destRect.x = cast(float)cast(s32)((screenWidth - (gameWidth*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (gameHeight*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(gameWidth*resizeRatio);
    destRect.height = cast(float)cast(s32)(gameHeight*resizeRatio);
}

KeepHeightCenteredInteger :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    resizeRatio: float = cast(float)screenHeight/gameHeight;
    sourceRect.x = 0.0;
    sourceRect.y = 0.0;
    sourceRect.width = cast(float)cast(s32)(screenWidth/resizeRatio);
    sourceRect.height = cast(float)-gameHeight;

    destRect.x = cast(float)cast(s32)((screenWidth - (sourceRect.width*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (gameHeight*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(sourceRect.width*resizeRatio);
    destRect.height = cast(float)cast(s32)(gameHeight*resizeRatio);
}

KeepWidthCenteredInteger :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    resizeRatio: float = cast(float)screenWidth/gameWidth;
    sourceRect.x = 0.0;
    sourceRect.y = 0.0;
    sourceRect.width = cast(float)gameWidth;
    sourceRect.height = cast(float)cast(s32)(screenHeight/resizeRatio);

    destRect.x = cast(float)cast(s32)((screenWidth - (gameWidth*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (sourceRect.height*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(gameWidth*resizeRatio);
    destRect.height = cast(float)cast(s32)(sourceRect.height*resizeRatio);

    sourceRect.height *= -1.0;
}

KeepAspectCentered :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    sourceRect.x = 0.0;
    sourceRect.y = cast(float)gameHeight;
    sourceRect.width = cast(float)gameWidth;
    sourceRect.height = cast(float)-gameHeight;

    ratio_x: float = (cast(float)screenWidth/cast(float)gameWidth);
    ratio_y: float = (cast(float)screenHeight/cast(float)gameHeight);
    resizeRatio: float = (ifx ratio_x < ratio_y then ratio_x else ratio_y);

    destRect.x = cast(float)cast(s32)((screenWidth - (gameWidth*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (gameHeight*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(gameWidth*resizeRatio);
    destRect.height = cast(float)cast(s32)(gameHeight*resizeRatio);
}

KeepHeightCentered :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    resizeRatio: float = (cast(float)screenHeight/cast(float)gameHeight);
    sourceRect.x = 0.0;
    sourceRect.y = 0.0;
    sourceRect.width = cast(float)cast(s32)(cast(float)screenWidth/resizeRatio);
    sourceRect.height = cast(float)-gameHeight;

    destRect.x = cast(float)cast(s32)((screenWidth - (sourceRect.width*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (gameHeight*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(sourceRect.width*resizeRatio);
    destRect.height = cast(float)cast(s32)(gameHeight*resizeRatio);
}

KeepWidthCentered :: (screenWidth: s32, screenHeight: s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle)
{
    resizeRatio: float = (cast(float)screenWidth/cast(float)gameWidth);
    sourceRect.x = 0.0;
    sourceRect.y = 0.0;
    sourceRect.width = cast(float)gameWidth;
    sourceRect.height = cast(float)cast(s32)(cast(float)screenHeight/resizeRatio);

    destRect.x = cast(float)cast(s32)((screenWidth - (gameWidth*resizeRatio))*0.5);
    destRect.y = cast(float)cast(s32)((screenHeight - (sourceRect.height*resizeRatio))*0.5);
    destRect.width = cast(float)cast(s32)(gameWidth*resizeRatio);
    destRect.height = cast(float)cast(s32)(sourceRect.height*resizeRatio);

    sourceRect.height *= -1.0;
}

ResizeRenderSize :: (viewportType: ViewportType, screenWidth: *s32, screenHeight: *s32, gameWidth: s32, gameHeight: s32, sourceRect: *Rectangle, destRect: *Rectangle, target: *RenderTexture2D)
{
    (.*)screenWidth = GetScreenWidth();
    (.*)screenHeight = GetScreenHeight();

    if viewportType ==
    {
        case .KEEP_ASPECT_INTEGER; KeepAspectCenteredInteger((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
        case .KEEP_HEIGHT_INTEGER; KeepHeightCenteredInteger((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
        case .KEEP_WIDTH_INTEGER; KeepWidthCenteredInteger((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
        case .KEEP_ASPECT; KeepAspectCentered((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
        case .KEEP_HEIGHT; KeepHeightCentered((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
        case .KEEP_WIDTH; KeepWidthCentered((.*)screenWidth, (.*)screenHeight, gameWidth, gameHeight, sourceRect, destRect);
    }

    UnloadRenderTexture((.*)target);
    (.*)target = LoadRenderTexture(cast(s32)sourceRect.width, -cast(s32)sourceRect.height);
}

// Example how to calculate position on RenderTexture
Screen2RenderTexturePosition :: (point: Vector2, textureRect: *Rectangle, scaledRect: *Rectangle) -> Vector2
{
    relativePosition: Vector2 = .{point.x - scaledRect.x, point.y - scaledRect.y};
    ratio: Vector2 = .{textureRect.width/scaledRect.width, -textureRect.height/scaledRect.height};

    return Vector2.{relativePosition.x*ratio.x, relativePosition.y*ratio.x};
}