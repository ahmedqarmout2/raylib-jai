#import "raylib";
#import "Basic";
#import "Math";

ColorRect :: struct {
    c: Color;
    r: Rectangle;
}

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - Generates a random sequence");
    defer CloseWindow(); // Close window and OpenGL context

    rectCount: s32 = 20;
    rectSize: float = cast(float)screenWidth/rectCount;
    rectangles: [..]ColorRect = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);
    defer array_free(rectangles);

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if(IsKeyPressed(.KEY_SPACE)) {
            ShuffleColorRectSequence(rectangles, rectCount);
        }

        if(IsKeyPressed(.KEY_UP)) {
            rectCount += 1;
            rectSize = cast(float)screenWidth/rectCount;
            array_free(rectangles);
            rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);
        }

        if(IsKeyPressed(.KEY_DOWN)) {
            if(rectCount >= 4){
                rectCount -= 1;
                rectSize = cast(float)screenWidth/rectCount;
                array_free(rectangles);
                rectangles = GenerateRandomColorRectSequence(rectCount, rectSize, cast(float)screenWidth, 0.75 * screenHeight);
            }
        }

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        fontSize: s32 = 20;
        for x: 0..rectCount-1 {
            DrawRectangleRec(rectangles[x].r, rectangles[x].c);
            DrawTextCenterKeyHelp("SPACE", "to shuffle the sequence."                          , 10, screenHeight - 96, fontSize, BLACK);
            DrawTextCenterKeyHelp("UP"   , "to add a rectangle and generate a new sequence."   , 10, screenHeight - 64, fontSize, BLACK);
            DrawTextCenterKeyHelp("DOWN" , "to remove a rectangle and generate a new sequence.", 10, screenHeight - 32, fontSize, BLACK);
        }

        rectCountText     : *u8  = TextFormat("%d rectangles", rectCount);
        rectCountTextSize : s32  = MeasureText(rectCountText, fontSize);
        DrawText(rectCountText, screenWidth - rectCountTextSize - 10, 10, fontSize, BLACK);

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}

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
    defer UnloadRandomSequence(seq);

    rectangles: [..]ColorRect;
    array_resize(*rectangles, rectCount);

    rectSeqWidth: float = rectCount * rectWidth;
    startX: float = (screenWidth - rectSeqWidth) * 0.5;

    for x: 0..rectCount-1 {
        rectHeight: s32 = cast(s32)Remap(cast(float)seq[x], 0, cast(float)rectCount-1, 0, screenHeight);
        rectangles[x].c = GenerateRandomColor();
        rectangles[x].r = Rectangle.{
            startX + x * rectWidth, screenHeight - rectHeight, rectWidth, cast(float)rectHeight
        };
    }
    return rectangles;
}

ShuffleColorRectSequence :: (rectangles: [..]ColorRect, rectCount: s32) {
    seq: *s32 = LoadRandomSequence(cast(u32)rectCount, 0, rectCount-1);
    defer UnloadRandomSequence(seq);

    for i1: 0..rectCount-1 {
        r1: *ColorRect = *rectangles[i1];
        r2: *ColorRect = *rectangles[seq[i1]];

        // swap only the color and height
        tmp: ColorRect = r1.*;
        r1.c           = r2.c;
        r1.r.height    = r2.r.height;
        r1.r.y         = r2.r.y;

        r2.c        = tmp.c;
        r2.r.height = tmp.r.height;
        r2.r.y      = tmp.r.y;
    }
}

DrawTextCenterKeyHelp :: (key: *u8, text: *u8, posX: s32, posY: s32, fontSize: s32, color: Color) {
    spaceSize : s32 = MeasureText(" ", fontSize); 
    pressSize : s32 = MeasureText("Press", fontSize); 
    keySize   : s32 = MeasureText(key, fontSize); 
    textSize  : s32 = MeasureText(text, fontSize); 
    totalSize : s32 = pressSize + 2 * spaceSize + keySize + 2 * spaceSize + textSize;
    textSizeCurrent: s32 = 0;

    DrawText("Press", posX, posY, fontSize, color);
    textSizeCurrent += pressSize + 2 * spaceSize;
    DrawText(key, posX + textSizeCurrent, posY, fontSize, RED);
    DrawRectangle(posX + textSizeCurrent, posY + fontSize, keySize, 3, RED);
    textSizeCurrent += keySize + 2 * spaceSize;
    DrawText(text, posX + textSizeCurrent, posY, fontSize, color);
}
