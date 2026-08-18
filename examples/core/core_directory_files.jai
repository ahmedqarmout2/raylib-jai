#import "raylib";
#import "Basic";

MAX_FILEPATH_SIZE :: 1024;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - directory files");

    directory: [MAX_FILEPATH_SIZE]u8;
    TextCopy(directory.data, GetWorkingDirectory());

    // Load file-paths on current working directory
    // NOTE: LoadDirectoryFiles() loads files and directories by default,
    // use LoadDirectoryFilesEx() for custom filters and recursive directories loading
    //FilePathList files = LoadDirectoryFiles(directory);
    files: FilePathList = LoadDirectoryFilesEx(directory.data, ".png;.c", false);

    btnBackPressed: bool = false;

    listScrollIndex: s32 = 0;
    listItemActive: s32 = -1;
    listItemFocused: s32 = -1;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (btnBackPressed)
        {
            TextCopy(directory.data, GetPrevDirectoryPath(directory.data));
            UnloadDirectoryFiles(files);
            files = LoadDirectoryFiles(directory.data);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            btnBackPressed = GuiButton(Rectangle.{ 40.0, 10.0, 48, 28 }, "<") == .RESULT_PRESSED;

            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, GuiGetFont().baseSize*2);
            GuiLabel(Rectangle.{ 40 + 48 + 10, 10, 700, 28 }, directory.data);
            GuiSetStyle(.DEFAULT, cast(s32)GuiDefaultProperty.TEXT_SIZE, GuiGetFont().baseSize);

            GuiSetStyle(.LISTVIEW, cast(s32)GuiControlProperty.TEXT_ALIGNMENT, cast(s32)GuiTextAlignment.TEXT_ALIGN_LEFT);
            GuiSetStyle(.LISTVIEW, cast(s32)GuiControlProperty.TEXT_PADDING, 40);
            GuiListViewEx(Rectangle.{ 0, 50, cast(float)GetScreenWidth(), cast(float)GetScreenHeight() - 50 },
                files.paths, cast(s32)files.count, *listScrollIndex, *listItemActive, *listItemFocused);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadDirectoryFiles(files);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
