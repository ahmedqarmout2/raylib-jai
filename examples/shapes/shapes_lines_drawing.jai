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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - lines drawing");

    // Hint text that shows before you click the screen
    startText: bool = true;

    // The mouse's position on the previous frame
    mousePositionPrevious: Vector2 = GetMousePosition();

    // The canvas to draw lines on
    canvas: RenderTexture = LoadRenderTexture(screenWidth, screenHeight);

    // The line's thickness
    lineThickness: float = 8.0;
    // The lines hue (in HSV, from 0-360)
    lineHue: float = 0.0;

    // Clear the canvas to the background color
    BeginTextureMode(canvas);
        ClearBackground(RAYWHITE);
    EndTextureMode();

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Disable the hint text once the user clicks
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && startText) startText = false;

        // Clear the canvas when the user middle-clicks
        if (IsMouseButtonPressed(.MOUSE_BUTTON_MIDDLE))
        {
            BeginTextureMode(canvas);
                ClearBackground(RAYWHITE);
            EndTextureMode();
        }

        // Store whether the left and right buttons are down
        leftButtonDown: bool = IsMouseButtonDown(.MOUSE_BUTTON_LEFT);
        rightButtonDown: bool = IsMouseButtonDown(.MOUSE_BUTTON_RIGHT);

        if (leftButtonDown || rightButtonDown)
        {
            // The color for the line
            drawColor: Color = WHITE;

            if (leftButtonDown)
            {
                // Increase the hue value by the distance our cursor has moved since the last frame (divided by 3)
                lineHue += Vector2Distance(mousePositionPrevious, GetMousePosition())/3.0;

                // While the hue is >=360, subtract it to bring it down into the range 0-360
                // This is more visually accurate than resetting to zero
                while (lineHue >= 360.0) lineHue -= 360.0;

                // Create the final color
                drawColor = ColorFromHSV(lineHue, 1.0, 1.0);
            }
            else if (rightButtonDown) drawColor = RAYWHITE; // Use the background color as an "eraser"

            // Draw the line onto the canvas
            BeginTextureMode(canvas);
                // Circles act as "caps", smoothing corners
                DrawCircleV(mousePositionPrevious, lineThickness/2.0, drawColor);
                DrawCircleV(GetMousePosition(), lineThickness/2.0, drawColor);
                DrawLineEx(mousePositionPrevious, GetMousePosition(), lineThickness, drawColor);
            EndTextureMode();
        }

        // Update line thickness based on mousewheel
        lineThickness += GetMouseWheelMove();
        lineThickness = Clamp(lineThickness, 1.0, 500.0);

        // Update mouse's previous position
        mousePositionPrevious = GetMousePosition();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            // Draw the render texture to the screen, flipped vertically to make it appear top-side up
            DrawTextureRec(canvas.texture, Rectangle.{ 0.0, 0.0, cast(float)canvas.texture.width, cast(float)-canvas.texture.height }, Vector2Zero(), WHITE);

            // Draw the preview circle
            if (!leftButtonDown) DrawCircleLinesV(GetMousePosition(), lineThickness/2.0, Color.{ 127, 127, 127, 127 });

            // Draw the hint text
            if (startText) DrawText("try clicking and dragging!", 275, 215, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(canvas); // Unload the canvas render texture

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}