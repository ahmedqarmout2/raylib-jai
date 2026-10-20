#import "raylib";
#import "Basic";
#import "Math";

MAX_PIE_SLICES :: 10;       // Max pie slices

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - pie chart");

    sliceCount: s32 = 7;
    donutInnerRadius: float = 25.0;
    values: [MAX_PIE_SLICES]float = .[ 300.0, 100.0, 450.0, 350.0, 600.0, 380.0, 750.0, 0.0, 0.0, 0.0 ]; // Initial slice values
    editingLabel: [MAX_PIE_SLICES]bool;

    showValues: bool = true;
    showPercentages: bool = false;
    showDonut: bool = false;
    hoveredSlice: s32 = -1;
    scrollPanelBounds: Rectangle = Rectangle.{};
    scrollContentOffset:  = Vector2.{};
    view: Rectangle = Rectangle.{};

    // UI layout parameters
    panelWidth: s32 = 270;
    panelMargin: s32 = 5;

    // UI Panel top-left anchor
    panelPos: Vector2 = .{
        cast(float)screenWidth - panelMargin - panelWidth,
        cast(float)panelMargin
    };

    // UI Panel rectangle
    panelRect: Rectangle = .{
        panelPos.x, panelPos.y,
        cast(float)panelWidth,
        cast(float)screenHeight - 2.0*panelMargin
    };

    // Pie chart geometry
    canvas: Rectangle = .{ 0, 0, panelPos.x, cast(float)screenHeight };
    center: Vector2 = .{ canvas.width/2.0, canvas.height/2.0 };
    radius: float = 205.0;

    // Total value for percentage calculations
    totalValue: float = 0.0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        // Calculate total value for percentage calculations
        totalValue = 0.0;
        for i: 0..sliceCount-1 totalValue += values[i];

        // Check for mouse hover over slices
        hoveredSlice = -1; // Reset hovered slice
        mousePos: Vector2 = GetMousePosition();

        if (CheckCollisionPointRec(mousePos, canvas)) // Only check if mouse is inside the canvas
        {
            dx: float = mousePos.x - center.x;
            dy: float = mousePos.y - center.y;
            distance: float  = sqrt(dx*dx + dy*dy);

            if (distance <= radius) // Inside the pie radius
            {
                angle: float = atan2(dy, dx)*RAD2DEG;
                if (angle < 0) angle += 360;

                currentAngle: float = 0.0;
                for i: 0..sliceCount-1
                {
                    sweep: float = ifx (totalValue > 0) then (values[i]/totalValue)*360.0 else 0.0;

                    if ((angle >= currentAngle) && (angle < (currentAngle + sweep)))
                    {
                        hoveredSlice = i;
                        break;
                    }

                    currentAngle += sweep;
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw the pie chart on the canvas
            startAngle: float = 0.0;
            for i: 0..sliceCount-1
            {
                sweepAngle: float = ifx (totalValue > 0) then (values[i]/totalValue)*360.0 else 0.0;
                midAngle: float = startAngle + sweepAngle/2.0; // Middle angle for label positioning

                color: Color = ColorFromHSV(cast(float)i/sliceCount*360.0, 0.75, 0.9);
                currentRadius: float = radius;

                // Make the hovered slice pop out by adding 5 pixels to its radius
                if (i == hoveredSlice) currentRadius += 20.0;

                // Draw the pie slice using raylib's DrawCircleSector function
                DrawCircleSector(center, currentRadius, startAngle, startAngle + sweepAngle, 120, color);

                // Draw the label for the current slice
                if (values[i] > 0)
                {
                    labelText: *u8;
                    if (showValues && showPercentages) labelText = TextFormat("%.1f (%.0f%%)", values[i], (values[i]/totalValue)*100.0);
                    else if (showValues) labelText = TextFormat("%.1f", values[i]);
                    else if (showPercentages) labelText = TextFormat("%.0f%%", (values[i]/totalValue)*100.0);
                    else labelText[0] = #char "\0";

                    textSize: Vector2 = MeasureTextEx(GetFontDefault(), labelText, 20, 1);
                    labelRadius: float  = radius*0.7;
                    labelPos: Vector2 = .{ center.x + cos(midAngle*DEG2RAD)*labelRadius - textSize.x/2.0,
                        center.y + sin(midAngle*DEG2RAD)*labelRadius - textSize.y/2.0 };
                    DrawText(labelText, cast(s32)labelPos.x, cast(s32)labelPos.y, 20, WHITE);
                }

                // Draw inner circle to create donut effect
                // TODO: This is a hacky solution, better use DrawRing()
                if (showDonut) DrawCircleV(center, donutInnerRadius, RAYWHITE);

                startAngle += sweepAngle;
            }

            // UI control panel
            DrawRectangleRec(panelRect, Fade(LIGHTGRAY, 0.5));
            DrawRectangleLinesEx(panelRect, 1.0, GRAY);

            GuiSpinner(Rectangle.{ panelPos.x + 95, cast(float)panelPos.y + 12, 125, 25 }, "Slices ", *sliceCount, 1, MAX_PIE_SLICES, false);
            GuiCheckBox(Rectangle.{ panelPos.x + 20, cast(float)panelPos.y + 12 + 40, 20, 20 }, "Show Values", *showValues);
            GuiCheckBox(Rectangle.{ panelPos.x + 20, cast(float)panelPos.y + 12 + 70, 20, 20 }, "Show Percentages", *showPercentages);
            GuiCheckBox(Rectangle.{ panelPos.x + 20, cast(float)panelPos.y + 12 + 100, 20, 20 }, "Make Donut", *showDonut);

            if (showDonut) GuiDisable();
            GuiSliderBar(Rectangle.{ panelPos.x + 80, cast(float)panelPos.y + 12 + 130, panelRect.width - 100, 30 },
                "Inner Radius", null, *donutInnerRadius, 5.0, radius - 10.0);
            GuiEnable();

            GuiLine(Rectangle.{ panelPos.x + 10, cast(float)panelPos.y + 12 + 170, panelRect.width - 20, 1 }, null);

            // Scrollable area for slice editors
            scrollPanelBounds = Rectangle.{
                panelPos.x + panelMargin,
                cast(float)panelPos.y + 12 + 190,
                panelRect.width - panelMargin*2,
                panelRect.y + panelRect.height - panelPos.y + 12 + 190 - panelMargin
            };
            contentHeight: s32 = sliceCount*35;

            GuiScrollPanel(scrollPanelBounds, null, Rectangle.{ 0, 0, panelRect.width - 25, cast(float)contentHeight },
                *scrollContentOffset, *view);

            contentX: float = view.x + scrollContentOffset.x; // Left of content
            contentY: float = view.y + scrollContentOffset.y; // Top of content

            BeginScissorMode(cast(s32)view.x, cast(s32)view.y, cast(s32)view.width, cast(s32)view.height);

                for i: 0..sliceCount-1
                {
                    rowY: s32 = cast(s32)(contentY + 5 + i*35);

                    // Color indicator
                    color: Color = ColorFromHSV(cast(float)i/sliceCount*360.0, 0.75, 0.9);
                    DrawRectangle(cast(s32)(contentX + 15), rowY + 5, 20, 20, color);

                    // Label textbox
                    if (GuiTextBox(Rectangle.{ contentX + 45, cast(float)rowY, 75, 30 }, TextFormat("Slice %02i", i + 1), 32, editingLabel[i]))
                        editingLabel[i] = !editingLabel[i];

                    GuiSliderBar(Rectangle.{ contentX + 130, cast(float)rowY, 110, 30 }, null, null, *values[i], 0.0, 1000.0);
                }

            EndScissorMode();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}