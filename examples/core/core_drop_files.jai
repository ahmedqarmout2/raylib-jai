#import "raylib";
#import "Basic";

MAX_FILEPATH_RECORDED : s32 : 4096;
MAX_FILEPATH_SIZE     : s32 : 2048;

char :: u8;

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files");
    defer CloseWindow(); // Close window and OpenGL context

    filePathCounter: s32 = 0;
    filePaths: [MAX_FILEPATH_RECORDED]*char; // We will register a maximum of filepaths

    // Allocate space for the required file paths
    for i: 0..MAX_FILEPATH_RECORDED-1 {
        filePaths[i] = cast(*char)alloc(MAX_FILEPATH_SIZE*size_of(char));
    }

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsFileDropped()) {
            droppedFiles: FilePathList = LoadDroppedFiles();

            i: s32 = 0;
            offset: s32 = filePathCounter;
            while (i < cast(s32)droppedFiles.count) {
                defer i += 1;

                if (filePathCounter < (MAX_FILEPATH_RECORDED - 1)) {
                    TextCopy(filePaths[offset + i], droppedFiles.paths[i]);
                    filePathCounter += 1;
                }
            }

            UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        if (filePathCounter == 0) DrawText("Drop your files to this window!", 100, 40, 20, DARKGRAY);
        else {
            DrawText("Dropped files:", 100, 40, 20, DARKGRAY);

            i: s32 = 0;
            while (i < filePathCounter) {
                defer i += 1;

                if (i%2 == 0) DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(LIGHTGRAY, 0.5));
                else DrawRectangle(0, 85 + 40*i, screenWidth, 40, Fade(LIGHTGRAY, 0.3));

                DrawText(filePaths[i], 120, 100 + 40*i, 10, GRAY);
            }

            DrawText("Drop new files...", 100, 110 + 40*filePathCounter, 20, DARKGRAY);
        }
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..MAX_FILEPATH_RECORDED-1 {
        free(filePaths[i]); // Free allocated memory for all filepaths
    }
    //--------------------------------------------------------------------------------------

}