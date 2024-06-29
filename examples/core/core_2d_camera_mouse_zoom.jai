#import "raylib";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera mouse zoom");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    camera: Camera2D;
    camera.zoom = 1.0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Translate based on mouse right click
        if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
            delta: Vector2 = GetMouseDelta();
            delta = Vector2Scale(delta, -1.0/camera.zoom);

            camera.target = Vector2Add(camera.target, delta);
        }

        // Zoom based on mouse wheel
        wheel: float = GetMouseWheelMove();
        if (wheel != 0) {
            // Get the world point that is under the mouse
            mouseWorldPos: Vector2 = GetScreenToWorld2D(GetMousePosition(), camera);
            
            // Set the offset to where the mouse is
            camera.offset = GetMousePosition();

            // Set the target to match, so that the camera maps the world space point 
            // under the cursor to the screen space point under the cursor at any zoom
            camera.target = mouseWorldPos;

            // Zoom increment
            zoomIncrement: float = 0.125;

            camera.zoom += (wheel*zoomIncrement);
            if (camera.zoom < zoomIncrement) camera.zoom = zoomIncrement;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        ClearBackground(BLACK);

        BeginMode2D(camera);

        // Draw the 3d grid, rotated 90 degrees and centered around 0,0 
        // just so we have something in the XY plane
        rlPushMatrix();
        rlTranslatef(0, 25*50, 0);
        rlRotatef(90, 1, 0, 0);
        DrawGrid(100, 50);
        rlPopMatrix();

        // Draw a reference circle
        DrawCircle(100, 100, 50, YELLOW);
                
        EndMode2D();

        DrawText("Mouse right button drag to move, mouse wheel to zoom", 10, 10, 20, WHITE);
        
        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}