#import "raylib";
#import "Basic";
#import "String";

STORAGE_DATA_FILE :: "storage.data";   // Storage file

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - storage values");

    score: s32 = 0;
    hiscore: s32 = 0;
    framesCounter: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_R))
        {
            score = GetRandomValue(1000, 2000);
            hiscore = GetRandomValue(2000, 4000);
        }

        if (IsKeyPressed(.KEY_ENTER))
        {
            SaveStorageValue(score, hiscore);
        }
        else if (IsKeyPressed(.KEY_SPACE))
        {
            // NOTE: If requested position could not be found, value 0 is returned
            score, hiscore = LoadStorageValue();
        }

        framesCounter += 1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawText(TextFormat("SCORE: %i", score), 280, 130, 40, MAROON);
            DrawText(TextFormat("HI-SCORE: %i", hiscore), 210, 200, 50, BLACK);

            DrawText(TextFormat("frames: %i", framesCounter), 10, 10, 20, LIME);

            DrawText("Press R to generate random numbers", 220, 40, 20, LIGHTGRAY);
            DrawText("Press ENTER to SAVE values", 250, 310, 20, LIGHTGRAY);
            DrawText("Press SPACE to LOAD values", 252, 350, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Declaration
//------------------------------------------------------------------------------------
SaveStorageValue :: (score: s32, hiscore: s32)
{
    rawData : string = sprint("%,%", score, hiscore);
    fileData: *u8 = to_c_string(rawData);

    success: bool = SaveFileData(STORAGE_DATA_FILE, fileData, cast(s32)(rawData.count*size_of(u8)));
    TraceLog(ifx success then .LOG_INFO else .LOG_ERROR, "FILEIO: [%s] %s storage values: score: %i, hiscore: %i", STORAGE_DATA_FILE, to_c_string(ifx success then "Saved" else "Failed to save"), score, hiscore);
}

LoadStorageValue :: () -> s32, s32
{
    dataSize: s32 = 0;
    score: s32 = 0;
    hiscore: s32 = 0;

    fileData: *u8 = LoadFileData(STORAGE_DATA_FILE, *dataSize);
    defer UnloadFileData(fileData);

    if (fileData != null)
    {
        rawData := to_string(fileData, strlen(fileData));
        dataParts := split(rawData, ",");
        if dataParts.count != 2 {
            TraceLog(.LOG_ERROR, "FILEIO: [%s] Failed to load storage data.", STORAGE_DATA_FILE);
            return score, hiscore;
        }

        score = cast(s32)to_integer(dataParts[0]);
        hiscore = cast(s32)to_integer(dataParts[1]);
        TraceLog(.LOG_INFO, "FILEIO: [%s] Loaded storage value: score: %i, hiscore: %i", STORAGE_DATA_FILE, score, hiscore);
    }
    return score, hiscore;
}
