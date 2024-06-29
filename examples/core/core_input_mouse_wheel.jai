#import "raylib";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - input mouse wheel");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    boxPositionY : s32 = screenHeight/2 - 40;
    scrollSpeed  : s32 = 4;        // Scrolling speed in pixels

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        boxPositionY -= cast(s32)(GetMouseWheelMove()*scrollSpeed);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawRectangle(screenWidth/2 - 40, boxPositionY, 80, 80, MAROON);

        DrawText("Use mouse wheel to move the cube up and down!", 10, 10, 20, GRAY);
        DrawText(TextFormat("Box position Y: %03i", boxPositionY), 10, 40, 20, LIGHTGRAY);
        //----------------------------------------------------------------------------------
    }
}