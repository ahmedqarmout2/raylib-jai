#import "raylib";
#import "Basic";
#import "Math";

ColorRect :: struct {
    color: Color;
    rect: Rectangle;
}

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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - random sequence");

    rectCount: s32 = 20;
    rectSize: float = cast(float)screenWidth/rectCount;
    rectangles: [..]ColorRect = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_SPACE)) ShuffleColorRectSequence(rectangles, rectCount);

        if(IsKeyPressed(.KEY_UP))
        {
            rectCount += 1;
            rectSize = cast(float)screenWidth/rectCount;
            array_free(rectangles);

            // Re-generate random sequence with new count
            rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);
        }

        if(IsKeyPressed(.KEY_DOWN))
        {
            if(rectCount >= 4)
            {
                rectCount -= 1;
                rectSize = cast(float)screenWidth/rectCount;
                array_free(rectangles);

                // Re-generate random sequence with new count
                rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);
            }
        }

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            fontSize: s32 = 20;
            for x: 0..rectCount-1
            {
                DrawRectangleRec(rectangles[x].rect, rectangles[x].color);

                DrawText("Press SPACE to shuffle the current sequence", 10, screenHeight - 96, 20, BLACK);
                DrawText("Press UP to add a rectangle and generate a new sequence", 10, screenHeight - 64, 20, BLACK);
                DrawText("Press DOWN to remove a rectangle and generate a new sequence", 10, screenHeight - 32, 20, BLACK);
            }

            DrawText(TextFormat("Count: %d rectangles", rectCount), 10, 10, 20, MAROON);

            DrawFPS(screenWidth - 80, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    array_free(rectangles);
    CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
GenerateRandomColor :: () -> Color {
    return Color.{
        cast(u8)GetRandomValue(0, 255),
        cast(u8)GetRandomValue(0, 255),
        cast(u8)GetRandomValue(0, 255),
        255
    };
}

GenerateRandomColorRectSequence :: (rectCount: s32, rectWidth: float, screenWidth: float, screenHeight: float) -> [..]ColorRect {
    seq: *s32 = LoadRandomSequence(cast(u32)rectCount, 0, rectCount-1);

    rectangles: [..]ColorRect;
    array_resize(*rectangles, rectCount);

    rectSeqWidth: float = rectCount * rectWidth;
    startX: float = (screenWidth - rectSeqWidth) * 0.5;

    for x: 0..rectCount-1
    {
        rectHeight: s32 = cast(s32)Remap(cast(float)seq[x], 0, cast(float)rectCount-1, 0, screenHeight);
        rectangles[x].color = GenerateRandomColor();
        rectangles[x].rect = Rectangle.{
            startX + x * rectWidth, screenHeight - rectHeight, rectWidth, cast(float)rectHeight
        };
    }

    UnloadRandomSequence(seq);

    return rectangles;
}

ShuffleColorRectSequence :: (rectangles: [..]ColorRect, rectCount: s32) {
    seq: *s32 = LoadRandomSequence(cast(u32)rectCount, 0, rectCount-1);
    defer UnloadRandomSequence(seq);

    for i1: 0..rectCount-1
    {
        r1: *ColorRect = *rectangles[i1];
        r2: *ColorRect = *rectangles[seq[i1]];

        // swap only the color and height
        tmp: ColorRect    = r1.*;
        r1.color          = r2.color;
        r1.rect.height    = r2.rect.height;
        r1.rect.y         = r2.rect.y;

        r2.color       = tmp.color;
        r2.rect.height = tmp.rect.height;
        r2.rect.y      = tmp.rect.y;
    }
}
