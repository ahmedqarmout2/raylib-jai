#import "raylib";
#import "Basic";
#import "Math";

TextAlignment :: enum s32 {
    TEXT_ALIGN_LEFT   :: 0;
    TEXT_ALIGN_TOP    :: 0;
    TEXT_ALIGN_CENTRE :: 1;
    TEXT_ALIGN_MIDDLE :: 1;
    TEXT_ALIGN_RIGHT  :: 2;
    TEXT_ALIGN_BOTTOM :: 2;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - words alignment");

    // Define the rectangle we will draw the text in
    textContainerRect: Rectangle = Rectangle.{ cast(float)screenWidth/2-cast(float)screenWidth/4, cast(float)screenHeight/2-cast(float)screenHeight/3, cast(float)screenWidth/2, cast(float)screenHeight*2/3 };

    // Some text to display the current alignment
    textAlignNameH: [3]*u8 = .[ "Left", "Centre", "Right" ];
    textAlignNameV: [3]*u8 = .[ "Top", "Middle", "Bottom" ];

    // Define the text we're going to draw in the rectangle
    wordIndex: s32 = 0;
    wordCount: s32 = 0;
    words: **u8 = TextSplit("raylib is a simple and easy-to-use library to enjoy videogames programming", #char " ", *wordCount);

    // Initialize the font size we're going to use
    fontSize: s32 = 40;

    // And of course the font...
    font: Font = GetFontDefault();

    // Initialize the alignment variables
    hAlign: TextAlignment = .TEXT_ALIGN_CENTRE;
    vAlign: TextAlignment = .TEXT_ALIGN_MIDDLE;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_LEFT))
        {
            if (hAlign > 0) hAlign = hAlign - 1;
        }

        if (IsKeyPressed(.KEY_RIGHT))
        {
            hAlign = hAlign + 1;
            if (hAlign > 2) hAlign = 2;
        }

        if (IsKeyPressed(.KEY_UP))
        {
            if (vAlign > 0) vAlign = vAlign - 1;
        }

        if (IsKeyPressed(.KEY_DOWN))
        {
            vAlign = vAlign + 1;
            if (vAlign > 2) vAlign = 2;
        }

        // One word per second
        if (wordCount > 0)  wordIndex = cast(s32)GetTime()%wordCount;
        else  wordIndex = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(DARKBLUE);

            DrawText("Use Arrow Keys to change the text alignment", 20, 20, 20, LIGHTGRAY);
            DrawText(TextFormat("Alignment: Horizontal = %s, Vertical = %s", textAlignNameH[hAlign], textAlignNameV[vAlign]), 20, 40, 20, LIGHTGRAY);

            DrawRectangleRec(textContainerRect, BLUE);

            // Get the size of the text to draw
            textSize: Vector2 = MeasureTextEx(font, words[wordIndex], cast(float)fontSize, fontSize*0.1);

            // Calculate the top-left text position based on the rectangle and alignment
            textPos: Vector2 = Vector2.{
                textContainerRect.x + Lerp(0.0, textContainerRect.width  - textSize.x, (cast(float)hAlign)*0.5),
                textContainerRect.y + Lerp(0.0, textContainerRect.height - textSize.y, (cast(float)vAlign)*0.5)
            };

            // Draw the text
            DrawTextEx(font, words[wordIndex], textPos, cast(float)fontSize, fontSize*0.1, RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
