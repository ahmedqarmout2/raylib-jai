#import "raylib";
#import "Basic";

MAX_FILEPATH_RECORDED :: 4096;
MAX_FILEPATH_SIZE     :: 2048;

char :: u8;

main :: () {
    screenWidth  :: 800;
    screenHeight :: 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - drop files");
    //--------------------------------------------------------------------------------------

    filePathCounter: s32 = 0;
    filePaths: [MAX_FILEPATH_RECORDED]*char; // We will register a maximum of filepaths

    // Allocate space for the required file paths
    for i: 0..MAX_FILEPATH_RECORDED-1 {
        filePaths[i] = cast(*char)alloc(MAX_FILEPATH_SIZE*size_of(char));
    }

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

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

        ClearBackground(RAYWHITE);

        if (filePathCounter == 0) DrawText("Drop your files to this window!", 100, 40, 20, DARKGRAY);
        else {
            DrawText("Dropped files:", 100, 40, 20, DARKGRAY);

            for i: 0..filePathCounter-1 {
                if (i%2 == 0) DrawRectangle(0, xx (85 + 40*i), screenWidth, 40, Fade(LIGHTGRAY, 0.5));
                else DrawRectangle(0, xx (85 + 40*i), screenWidth, 40, Fade(LIGHTGRAY, 0.3));

                DrawText(filePaths[i], 120, xx (100 + 40*i), 10, GRAY);
            }

            DrawText("Drop new files...", 100, xx (110 + 40*filePathCounter), 20, DARKGRAY);
        }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..MAX_FILEPATH_RECORDED-1 {
        free(filePaths[i]); // Free allocated memory for all filepaths
    }

    CloseWindow();             // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

}