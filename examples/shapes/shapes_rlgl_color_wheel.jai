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

    // The minimum/maximum points the circle can have
    pointsMin: u32 = 3;
    pointsMax: u32 = 256;

    // The current number of points and the radius of the circle
    triangleCount: u32 = 64;
    pointScale: float = 150.0;

    // Slider value, literally maps to value in HSV
    value: float = 1.0;

    // The center of the screen
    center: Vector2 = .{ cast(float)screenWidth/2.0, cast(float)screenHeight/2.0 };
    // The location of the color wheel
    circlePosition: Vector2 = center;

    // The currently selected color
    color: Color = .{ 255, 255, 255, 255 };

    // Indicates if the slider is being clicked
    sliderClicked: bool = false;

    // Indicates if the current color going to be updated, as well as the handle position
    settingColor: bool = false;

    // How the color wheel will be rendered
    renderType: s32 = RL_TRIANGLES;

    // Enable anti-aliasing
    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - rlgl color wheel");

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        triangleCount += cast(u32)GetMouseWheelMove();
        triangleCount = cast(u32)Clamp(cast(float)triangleCount, cast(float)pointsMin, cast(float)pointsMax);

        sliderRectangle: Rectangle = .{ 42.0, 16.0 + 64.0 + 45.0, 64.0, 16.0 };
        mousePosition: Vector2 = GetMousePosition();

        // Checks if the user is hovering over the value slider
        sliderHover: bool = (mousePosition.x >= sliderRectangle.x && mousePosition.y >= sliderRectangle.y && mousePosition.x < sliderRectangle.x + sliderRectangle.width && mousePosition.y < sliderRectangle.y + sliderRectangle.height);

        // Copy color as hex
        if (IsKeyDown(.KEY_LEFT_CONTROL) && IsKeyDown(.KEY_C))
        {
            if (IsKeyPressed(.KEY_C))
            {
                SetClipboardText(TextFormat("#%02X%02X%02X", color.r, color.g, color.b));
            }
        }

        // Scale up the color wheel, adjusting the handle visually
        if (IsKeyDown(.KEY_UP))
        {
            pointScale *= 1.025;

            if (pointScale > cast(float)screenHeight/2.0)
            {
                pointScale = cast(float)screenHeight/2.0;
            }
            else
            {
                circlePosition = Vector2Add(Vector2Multiply(Vector2Subtract(circlePosition, center), Vector2.{ 1.025, 1.025 }), center);
            }
        }

        // Scale down the wheel, adjusting the handle visually
        if (IsKeyDown(.KEY_DOWN))
        {
            pointScale *= 0.975;

            if (pointScale < 32.0)
            {
                pointScale = 32.0;
            }
            else
            {
                circlePosition = Vector2Add(Vector2Multiply(Vector2Subtract(circlePosition, center), Vector2.{ 0.975, 0.975 }), center);
            }

            distance: float = Vector2Distance(center, circlePosition)/pointScale;
            angle: float = ((Vector2Angle(Vector2.{ 0.0, -pointScale }, Vector2Subtract(center, circlePosition))/PI + 1.0)/2.0);

            if (distance > 1.0)
            {
                circlePosition = Vector2Add(Vector2.{ sin(angle*(PI*2.0))*pointScale, -cos(angle*(PI*2.0))*pointScale }, center);
            }
        }

        // Checks if the user clicked on the color wheel
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && Vector2Distance(GetMousePosition(), center) <= pointScale + 10.0)
        {
            settingColor = true;
        }

        // Update flag when mouse button is released
        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) settingColor = false;

        // Check if the user clicked/released the slider for the color's value
        if (sliderHover && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) sliderClicked = true;

        if (sliderClicked && IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) sliderClicked = false;

        // Update render mode accordingly
        if (IsKeyPressed(.KEY_SPACE)) renderType = RL_LINES;

        if (IsKeyReleased(.KEY_SPACE)) renderType = RL_TRIANGLES;

        // If the slider or the wheel was clicked, update the current color
        if (settingColor || sliderClicked)
        {
            if (settingColor) circlePosition = GetMousePosition();

            distance: float = Vector2Distance(center, circlePosition)/pointScale;

            angle: float = ((Vector2Angle(Vector2.{ 0.0, -pointScale }, Vector2Subtract(center, circlePosition))/PI + 1.0)/2.0);
            if (settingColor && distance > 1.0) circlePosition = Vector2Add(Vector2.{ sin(angle*(PI*2.0))*pointScale, -cos(angle*(PI* 2.0))*pointScale }, center);

            angle360: float = angle*360.0;
            valueActual: float = Clamp(distance, 0.0, 1.0);
            color = ColorLerp(Color.{ cast(u8)(value*255.0), cast(u8)(value*255.0), cast(u8)(value*255.0), 255 }, ColorFromHSV(angle360, Clamp(distance, 0.0, 1.0), 1.0), valueActual);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        // Begin rendering color wheel
        rlBegin(renderType);
        for i: 0..triangleCount-1
        {
            angleOffset: float = ((PI*2.0)/cast(float)triangleCount);
            angle: float = angleOffset*cast(float)i;
            angleOffsetCalculated: float = (cast(float)i + 1)*angleOffset;
            scale: Vector2 = Vector2.{ pointScale, pointScale };

            offset: Vector2 = Vector2Multiply(Vector2.{ sin(angle), -cos(angle) }, scale);
            offset2: Vector2 = Vector2Multiply(Vector2.{ sin(angleOffsetCalculated), -cos(angleOffsetCalculated) }, scale);

            position: Vector2 = Vector2Add(center, offset);
            position2: Vector2 = Vector2Add(center, offset2);

            angleNonRadian: float = (angle/(2.0*PI))*360.0;
            angleNonRadianOffset: float = (angleOffset/(2.0*PI))*360.0;

            currentColor: Color = ColorFromHSV(angleNonRadian, 1.0, 1.0);
            offsetColor: Color = ColorFromHSV(angleNonRadian + angleNonRadianOffset, 1.0, 1.0);

            // Input vertices differently depending on mode
            if (renderType == RL_TRIANGLES)
            {
                // RL_TRIANGLES expects three vertices per triangle
                rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a);
                rlVertex2f(position.x, position.y);
                rlColor4f(value, value, value, 1.0);
                rlVertex2f(center.x, center.y);
                rlColor4ub(offsetColor.r, offsetColor.g, offsetColor.b, offsetColor.a);
                rlVertex2f(position2.x, position2.y);
            }
            else if (renderType == RL_LINES)
            {
                // RL_LINES expects two vertices per line
                rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a);
                rlVertex2f(position.x, position.y);
                rlColor4ub(WHITE.r, WHITE.g, WHITE.b, WHITE.a);
                rlVertex2f(center.x, center.y);

                rlVertex2f(center.x, center.y);
                rlColor4ub(offsetColor.r, offsetColor.g, offsetColor.b, offsetColor.a);
                rlVertex2f(position2.x, position2.y);

                rlVertex2f(position2.x, position2.y);
                rlColor4ub(currentColor.r, currentColor.g, currentColor.b, currentColor.a);
                rlVertex2f(position.x, position.y);
            }
        }
        rlEnd();

        // Make the handle slightly more visible overtop darker colors
        handleColor: Color = BLACK;

        if (Vector2Distance(center, circlePosition)/pointScale <= 0.5 && value <= 0.5)
        {
            handleColor = DARKGRAY;
        }

        // Draw the color handle
        DrawCircleLinesV(circlePosition, 4.0, handleColor);

        // Draw the color in a preview, with a darkened outline.
        DrawRectangleV(Vector2.{ 8.0, 8.0 }, Vector2.{ 64.0, 64.0 }, color);
        DrawRectangleLinesEx(Rectangle.{ 8.0, 8.0, 64.0, 64.0 }, 2.0, ColorLerp(color, BLACK, 0.5));

        // Draw current color as hex and decimal
        DrawText(TextFormat("#%02X%02X%02X\n(%d, %d, %d)", color.r, color.g, color.b, color.r, color.g, color.b), 8, 8 + 64 + 8, 20, DARKGRAY);

        // Update the visuals for the copying text
        copyColor: Color = DARKGRAY;
        offset: s32 = 0;
        if (IsKeyDown(.KEY_LEFT_CONTROL) && IsKeyDown(.KEY_C))
        {
            copyColor = DARKGREEN;
            offset = 4;
        }

        // Draw the copying text
        DrawText("press ctrl+c to copy!", 8, 425 - offset, 20, copyColor);

        // Display the number of rendered triangles
        DrawText(TextFormat("triangle count: %d", triangleCount), 8, 395, 20, DARKGRAY);

        // Slider to change color's value
        GuiSliderBar(sliderRectangle, "value: ", "", *value, 0.0, 1.0);

        // Draw FPS next to outlined color preview
        DrawFPS(64 + 16, 8);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}