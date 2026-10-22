#import "raylib";
#import "Basic";
#import "Math";

MAX_COLORS ::     256;
SCALE_FACTOR ::     2;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;


    InitWindow(screenWidth, screenHeight, "raylib [textures] example - screen buffer");

    imageWidth: s32 = screenWidth/SCALE_FACTOR;
    imageHeight: s32 = screenHeight/SCALE_FACTOR;
    flameWidth: s32 = screenWidth/SCALE_FACTOR;

    palette: [MAX_COLORS]Color;
    indexBuffer: *u8 = alloc(imageWidth*imageWidth*size_of(u8));
    flameRootBuffer: *u8 = alloc(flameWidth*size_of(u8));

    screenImage: Image = GenImageColor(imageWidth, imageHeight, BLACK);
    screenTexture: Texture = LoadTextureFromImage(screenImage);

    // Generate flame color palette
    for i: 0..MAX_COLORS-1
    {
        t: float = cast(float)i/cast(float)(MAX_COLORS - 1);
        hue: float = t*t;
        saturation: float = t;
        value: float = t;

        palette[i] = ColorFromHSV(250.0 + 150.0*hue, saturation, value);
    }

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Grow flameRoot
        for x: 2..flameWidth-1
        {
            flame: s32 = cast(s32)flameRootBuffer[x];
            flame += GetRandomValue(0, 2);
            flameRootBuffer[x] = ifx (flame > 255) then 255 else cast(u8)flame;
        }

        // Transfer flameRoot to indexBuffer
        for x: 0..flameWidth-1
        {
            i: s32 = x + (imageHeight - 1)*imageWidth;
            indexBuffer[i] = flameRootBuffer[x];
        }

        // Clear top row, because it can't move any higher
        for x: 0..imageWidth-1
        {
            if (indexBuffer[x] != 0) indexBuffer[x] = 0;
        }

        // Skip top row, it is already cleared
        for y: 1..imageHeight-1
        {
            for x: 0..imageWidth-1
            {
                i: s32 = x + y*imageWidth;
                colorIndex: u8 = indexBuffer[i];

                if (colorIndex != 0)
                {
                    // Move pixel a row above
                    indexBuffer[i] = 0;
                    moveX: s32 = GetRandomValue(0, 2) - 1;
                    newX: s32 = x + moveX;

                    if ((newX > 0) && (newX < imageWidth))
                    {
                        iabove: s32 = i - imageWidth + moveX;
                        decay: u8 = cast(u8)GetRandomValue(0, 3);
                        colorIndex -= ifx (decay < colorIndex) then decay else colorIndex;
                        indexBuffer[iabove] = colorIndex;
                    }
                }
            }
        }

        // Update screenImage with palette colors
        for y: 1..imageHeight-1
        {
            for x: 0..imageWidth-1
            {
                i: s32 = x + y*imageWidth;
                colorIndex: u8 = indexBuffer[i];
                col: Color = palette[colorIndex];

                ImageDrawPixel(*screenImage, x, y, col);
            }
        }

        UpdateTexture(screenTexture, screenImage.data);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawTextureEx(screenTexture, Vector2.{ 0, 0 }, 0.0, 2.0, WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    free(indexBuffer);
    free(flameRootBuffer);
    UnloadTexture(screenTexture);
    UnloadImage(screenImage);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
