#import "raylib";
#import "Basic";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - scissor test");

    scissorArea : Rectangle = .{ 0, 0, 300, 300 };
    scissorMode : bool      = true;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_S)) scissorMode = !scissorMode;

        // Centre the scissor area around the mouse position
        scissorArea.x = GetMouseX() - scissorArea.width/2;
        scissorArea.y = GetMouseY() - scissorArea.height/2;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (scissorMode) BeginScissorMode(cast(s32)scissorArea.x, cast(s32)scissorArea.y, cast(s32)scissorArea.width, cast(s32)scissorArea.height);

            // Draw full screen rectangle and some text
            // NOTE: Only part defined by scissor area will be rendered
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), RED);
            DrawText("Move the mouse around to reveal this text!", 190, 200, 20, LIGHTGRAY);

            if (scissorMode) EndScissorMode();

            DrawRectangleLinesEx(scissorArea, 1, BLACK);
            DrawText("Press S to toggle scissor test", 10, 10, 20, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}