#import "raylib";
#import "Basic";
#import "Math";
#import "String";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - text file loading");

    // Setting up the camera
    cam: Camera2D = .{
        offset = .{0, 0},
        target = .{0, 0},
        rotation = 0,
        zoom = 1
    };

    // Loading text file from resources/text_file.txt
    fileName: *u8 = "resources/text_file.txt";
    text: *u8 = LoadFileText(fileName);

    // Loading all the text lines
    lineCount: s32 = 0;
    lines: **u8 = LoadTextLines(text, *lineCount);

    // Stylistic choises
    fontSize: s32 = 20;
    textTop: s32 = 25 + fontSize; // Top of the screen from where the text is rendered
    wrapWidth: s32 = screenWidth - 20;

    // Wrap the lines as needed
    for i: 0..lineCount-1
    {
        j: s32 = 0;
        lastSpace: s32 = 0;          // Keeping track of last valid space to insert '\n'
        lastWrapStart: s32 = 0;      // Keeping track of the start of this wrapped line.

        while (j <= strlen(lines[i]))
        {
            if (lines[i][j] == #char" " || lines[i][j] == #char"\0")
            {
                before: u8 = lines[i][j];
                // Making a C Style string by adding a '\0' at the required location so that we can use the MeasureText function
                lines[i][j] = #char"\0";

                // Checking if the text has crossed the wrapWidth, then going back and inserting a newline
                if (MeasureText(lines[i] + lastWrapStart, fontSize) > wrapWidth)
                {
                    lines[i][lastSpace] = #char"\n";

                    // Since we added a newline the place of wrap changed so we update our lastWrapStart
                    lastWrapStart = lastSpace + 1;
                }

                if(before != #char"\0") lines[i][j] = #char" ";  // Resetting the space back
                lastSpace = j; // Since we encountered a new space we update our last encountered space location
            }

            j += 1;
        }
    }

    // Calculating the total height so that we can show a scrollbar
    textHeight: s32 = 0;

    for i: 0..lineCount-1
    {
        size: Vector2 = MeasureTextEx(GetFontDefault(), lines[i], cast(float)fontSize, 2);
        textHeight += cast(s32)size.y + 10;
    }

    // A simple scrollbar on the side to show how far we have read into the file
    scrollBar: Rectangle = .{
        x = cast(float)screenWidth - 5,
        y = 0,
        width = 5,
        height = screenHeight*100.0/(textHeight - screenHeight) // Scrollbar height is just a percentage
    };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        scroll: float = GetMouseWheelMove();
        cam.target.y -= scroll*fontSize*1.5;   // Choosing an arbitrary speed for scroll

        if (cam.target.y < 0) cam.target.y = 0;  // Snapping to 0 if we go too far back

        // Ensuring that the camera does not scroll past all text
        if (cam.target.y > textHeight - screenHeight + textTop*1.0)
            cam.target.y = cast(float)textHeight - screenHeight + textTop;

        // Computing the position of the scrollBar depending on the percentage of text covered
        scrollBar.y = Lerp(cast(float)textTop, cast(float)screenHeight - scrollBar.height, cast(float)(cam.target.y - textTop)/(textHeight - screenHeight));
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode2D(cam);
                // Going through all the read lines
                t: s32 = textTop;
                for i: 0..lineCount-1
                {
                    // Each time we go through and calculate the height of the text to move the cursor appropriately
                    size: Vector2;
                    if(compare(to_string(lines[i], strlen(lines[i])), "")){
                        // Fix for empty line in the text file
                        size = MeasureTextEx( GetFontDefault(), lines[i], cast(float)fontSize, 2);
                    }else{
                        size = MeasureTextEx( GetFontDefault(), " ", cast(float)fontSize, 2);
                    }

                    DrawText(lines[i], 10, t, fontSize, RED);

                    // Inserting extra space for real newlines,
                    // wrapped lines are rendered closer together
                    t += cast(s32)size.y + 10;
                }
            EndMode2D();

            // Header displaying which file is being read currently
            DrawRectangle(0, 0, screenWidth, textTop - 10, BEIGE);
            DrawText(TextFormat("File: %s", fileName), 10, 10, fontSize, MAROON);

            DrawRectangleRec(scrollBar, MAROON);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTextLines(lines, lineCount);
    UnloadFileText(text);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
