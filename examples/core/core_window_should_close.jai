#import "raylib";
#import "Basic";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - window should close");
    defer CloseWindow(); // Close window and OpenGL context

    SetExitKey(.KEY_NULL);       // Disable KEY_ESCAPE to close window, X-button still works
    
    exitWindowRequested : bool  = false;   // Flag to request window to exit
    exitWindow          : bool  = false;    // Flag to set window to exit

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!exitWindow) {
        // Update
        //----------------------------------------------------------------------------------
        if (WindowShouldClose() || IsKeyPressed(.KEY_ESCAPE)) exitWindowRequested = true;
        
        if (exitWindowRequested) {
            // A request for close window has been issued, we can save data before closing
            // or just show a message asking for confirmation
            
            if (IsKeyPressed(.KEY_Y)) exitWindow = true;
            else if (IsKeyPressed(.KEY_N)) exitWindowRequested = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            if (exitWindowRequested) {
                DrawRectangle(0, 100, screenWidth, 200, BLACK);
                DrawText("Are you sure you want to exit program? [Y/N]", 40, 180, 30, WHITE);
            }
            else DrawText("Try to close the window to get confirmation message!", 120, 200, 20, LIGHTGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}