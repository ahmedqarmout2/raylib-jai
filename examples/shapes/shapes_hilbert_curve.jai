#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - hilbert curve");

    order: s32 = 2;
    size: float = cast(float)GetScreenHeight();
    strokeCount: s32 = 0;
    hilbertPath: *Vector2 = LoadHilbertPath(order, size, *strokeCount);

    prevOrder: s32 = order;
    prevSize: s32 = cast(s32)size;       // NOTE: Size from slider is float but for comparison we use int
    counter: s32 = 0;
    thick: float = 2.0;
    animate: bool = true;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    //--------------------------------------------------------------------------------------
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Check if order or size have changed to regenerate
        // NOTE: Size from slider is float but for comparison we use int
        if ((prevOrder != order) || (prevSize != cast(s32)size))
        {
            UnloadHilbertPath(hilbertPath);
            hilbertPath = LoadHilbertPath(order, size, *strokeCount);

            if (animate) counter = 0;
            else counter = strokeCount;

            prevOrder = order;
            prevSize = cast(s32)size;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //--------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (counter < strokeCount)
            {
                // Draw Hilbert path animation, one stroke every frame
                for i: 1..counter
                {
                    DrawLineEx(hilbertPath[i], hilbertPath[i - 1], thick, ColorFromHSV((cast(float)i/strokeCount)*360.0, 1.0, 1.0));
                }

                counter += 1;
            }
            else
            {
                // Draw full Hilbert path
                for i: 1..strokeCount-1
                {
                    DrawLineEx(hilbertPath[i], hilbertPath[i - 1], thick, ColorFromHSV((cast(float)i/strokeCount)*360.0, 1.0, 1.0));
                }
            }

            // Draw UI using raygui
            GuiCheckBox(Rectangle.{ 450, 50, 20, 20 }, "ANIMATE GENERATION ON CHANGE", *animate);
            GuiSpinner(Rectangle.{ 585, 100, 180, 30 }, "HILBERT CURVE ORDER:  ", *order, 2, 8, false);
            GuiSlider(Rectangle.{ 524, 150, 240, 24 }, "THICKNESS:  ", null, *thick, 1.0, 10.0);
            GuiSlider(Rectangle.{ 524, 190, 240, 24 }, "TOTAL SIZE: ", null, *size, 10.0, GetScreenHeight()*1.5);

        EndDrawing();
        //--------------------------------------------------------------------------
    }
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadHilbertPath(hilbertPath);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
// Load the whole Hilbert Path (including each U and their link)
LoadHilbertPath :: (order: s32, size: float, strokeCount: *s32) -> *Vector2
{
    N: s32 = cast(s32)1 << order;
    len: float = size/N;
    (.*)strokeCount = N*N;

    hilbertPath: *Vector2 = cast(*Vector2)alloc((.*)strokeCount * size_of(Vector2));

    for i: 0..(.*)strokeCount-1
    {
        hilbertPath[i] = ComputeHilbertStep(order, i);
        hilbertPath[i].x = hilbertPath[i].x*len + len/2.0;
        hilbertPath[i].y = hilbertPath[i].y*len + len/2.0;
    }

    return hilbertPath;
}

// Unload Hilbert path data
UnloadHilbertPath :: (hilbertPath: *Vector2)
{
    free(hilbertPath);
}

// Compute Hilbert path U positions
ComputeHilbertStep :: (order: s32, index: s32) -> Vector2 
{
    // Hilbert points base pattern
    hilbertPoints: [4]Vector2 = .[
        .{ x = 0, y = 0 },
        .{ x = 0, y = 1 },
        .{ x = 1, y = 1 },
        .{ x = 1, y = 0 },
    ];

    hilbertIndex: s32 = index&3;
    vect: Vector2 = hilbertPoints[hilbertIndex];
    temp: float = 0.0;
    len: s32 = 0;

    for j: 1..order-1
    {
        index = index >> 2;
        hilbertIndex = index&3;
        len = cast(s32)1 << j;

        if hilbertIndex ==
        {
            case 0;
            {
                temp = vect.x;
                vect.x = vect.y;
                vect.y = temp;
            }
            case 2; vect.x += len; #through;
            case 1; vect.y += len;
            case 3;
            {
                temp = len - 1 - vect.x;
                vect.x = 2*len - 1 - vect.y;
                vect.y = temp;
            }
        }
    }

    return vect;
}
