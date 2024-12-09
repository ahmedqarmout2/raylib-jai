#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - text formatting");
    defer CloseWindow(); // Close window and OpenGL context

    score   : s32 = 100020;
    hiscore : s32 = 200450;
    lives   : s32 = 5;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText(TextFormat("Score: %08i", score), 200, 80, 20, RED);

        DrawText(TextFormat("HiScore: %08i", hiscore), 200, 120, 20, GREEN);

        DrawText(TextFormat("Lives: %02i", lives), 200, 160, 40, BLUE);

        DrawText(TextFormat("Elapsed Time: %02.02f ms", GetFrameTime()*1000), 200, 220, 20, BLACK);
        //----------------------------------------------------------------------------------
    }
}
