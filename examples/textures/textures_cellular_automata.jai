#import "raylib";
#import "Basic";
#import "Math";

// Initialization constants
//--------------------------------------------------------------------------------------
screenWidth: s32 = 800;
screenHeight: s32 = 450;
imageWidth: s32 = 800;
imageHeight: s32 = 800/2;

// Rule button sizes and positions
drawRuleStartX: s32       = 585;
drawRuleStartY: s32       = 10;
drawRuleSpacing: s32      = 15;
drawRuleGroupSpacing: s32 = 50;
drawRuleSize: s32         = 14;
drawRuleInnerSize: s32    = 10;

// Preset button sizes
presetsSizeX: s32 = 42;
presetsSizeY: s32 = 22;

linesUpdatedPerFrame: s32 = 4;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - cellular automata");

    // Image that contains the cellular automaton
    image: Image = GenImageColor(imageWidth, imageHeight, RAYWHITE);
    // The top central pixel set as black
    ImageDrawPixel(*image, imageWidth/2, 0, BLACK);

    texture: Texture2D = LoadTextureFromImage(image);

    // Some interesting rules
    presetValues: [10]s32 = .[ 18, 30, 60, 86, 102, 124, 126, 150, 182, 225 ];
    presetsCount: s32 = presetValues.count;

    // Variables
    rule: s32 = 30;  // Starting rule
    line: s32 = 1;   // Line to compute, starting from line 1. One point in line 0 is already set

    SetTargetFPS(60);
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Handle mouse
        mouse: Vector2 = GetMousePosition();
        mouseInCell: s32 = -1;   // -1: outside any button; 0-7: rule cells; 8+: preset cells

        // Check mouse on rule cells
        for i: 0..7
        {
            cellX: s32 = drawRuleStartX - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing;
            cellY: s32 = drawRuleStartY + drawRuleSpacing;
            if ((mouse.x >= cellX*1.0) && (mouse.x <= cellX*1.0 + drawRuleSize) &&
                (mouse.y >= cellY*1.0) && (mouse.y <= cellY*1.0 + drawRuleSize))
            {
                mouseInCell = cast(s32)i;    // 0-7: rule cells
                break;
            }
        }

        // Check mouse on preset cells
        if (mouseInCell < 0)
        {
            for i: 0..presetsCount-1
            {
                cellX: s32 = 4 + (presetsSizeX + 2)*(i/2);
                cellY: s32 = 2 + (presetsSizeY + 2)*(i%2);
                if ((mouse.x >= cellX*1.0) && (mouse.x <= cellX*1.0 + presetsSizeX) &&
                    (mouse.y >= cellY*1.0) && (mouse.y <= cellY*1.0 + presetsSizeY))
                {
                    mouseInCell = i + 8;    // 8+: preset cells
                    break;
                }
            }
        }

        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && (mouseInCell >= 0))
        {
            // Rule changed both by selecting a preset or toggling a bit
            if (mouseInCell < 8)
                rule ^= cast(s32)(1 << mouseInCell);
            else
                rule = presetValues[mouseInCell - 8];

            // Reset image
            ImageClearBackground(*image, RAYWHITE);
            ImageDrawPixel(*image, imageWidth/2, 0, BLACK);
            line = 1;
        }

        // Compute next lines
        //----------------------------------------------------------------------------------
        if (line < imageHeight)
        {
            i: s32 = 0;
            while ((i < linesUpdatedPerFrame) && (line + i < imageHeight))
            {
                defer i += 1;
                ComputeLine(*image, line + i, rule);
            }
            line += linesUpdatedPerFrame;

            UpdateTexture(texture, image.data);
        }

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw cellular automaton texture
            DrawTexture(texture, 0, screenHeight - imageHeight, WHITE);

            // Draw preset values
            for i: 0..presetsCount-1
            {
                DrawText(TextFormat("%i", presetValues[i]), 8 + (presetsSizeX + 2)*(i/2), 4 + (presetsSizeY + 2)*(i%2), 20, GRAY);
                DrawRectangleLines(4 + (presetsSizeX + 2)*(i/2), 2 + (presetsSizeY + 2)*(i%2), presetsSizeX, presetsSizeY, BLUE);

                // If the mouse is on this preset, highlight it
                if (mouseInCell == i + 8)
                    DrawRectangleLinesEx(Rectangle.{ 2 + (presetsSizeX + 2.0)*(i/2),
                                                       (presetsSizeY + 2.0)*(i%2),
                                                       presetsSizeX + 4.0, presetsSizeY + 4.0 }, 3, RED);
            }

            // Draw rule bits
            for i: 0..7
            {
                // The three input bits
                for j: 0..2
                {
                    DrawRectangleLines(drawRuleStartX - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing*cast(s32)j, drawRuleStartY, drawRuleSize, drawRuleSize, GRAY);
                    if (i & (4 >> j))
                        DrawRectangle(drawRuleStartX + 2 - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing*cast(s32)j, drawRuleStartY + 2, drawRuleInnerSize, drawRuleInnerSize, BLACK);
                }

                // The output bit
                DrawRectangleLines(drawRuleStartX - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing, drawRuleStartY + drawRuleSpacing, drawRuleSize, drawRuleSize, BLUE);
                if (rule & (1 << i))
                    DrawRectangle(drawRuleStartX + 2 - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing, drawRuleStartY + 2 + drawRuleSpacing, drawRuleInnerSize, drawRuleInnerSize, BLACK);

                // If the mouse is on this rule bit, highlight it
                if (mouseInCell == i)
                    DrawRectangleLinesEx(Rectangle.{ drawRuleStartX - drawRuleGroupSpacing*cast(s32)i + drawRuleSpacing - 2.0,
                                                      drawRuleStartY + drawRuleSpacing - 2.0,
                                                      drawRuleSize + 4.0, drawRuleSize + 4.0 }, 3, RED);
            }

            DrawText(TextFormat("RULE: %i", rule), drawRuleStartX + drawRuleSpacing*4, drawRuleStartY + 1, 30, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadImage(image);
    UnloadTexture(texture);

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Functions
//----------------------------------------------------------------------------------
ComputeLine :: (image: *Image, line: s32, rule: s32)
{
    // Compute next line pixels. Boundaries are not computed, always 0
    for i: 1..imageWidth - 2
    {
        // Get, from the previous line, the 3 pixels states as a binary value
        prevValue: s32 = cast(s32)(ifx (GetImageColor((.*)image, i - 1, line - 1).r < 5) then 4 else 0) +     // Left pixel
                              cast(s32)(ifx (GetImageColor((.*)image, i,     line - 1).r < 5) then 2 else 0) +     // Center pixel
                              cast(s32)(ifx (GetImageColor((.*)image, i + 1, line - 1).r < 5) then 1 else 0);      // Right pixel
        // Get next value from rule bitmask
        currValue: bool = cast(bool)(rule & (1 << prevValue));
        // Update pixel color
        ImageDrawPixel(image, i, line, ifx (currValue) then BLACK else RAYWHITE);
    }
}