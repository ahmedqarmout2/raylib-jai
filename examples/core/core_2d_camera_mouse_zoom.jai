#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera mouse zoom");

    camera: Camera2D;
    camera.zoom = 1.0;

    zoomMode: bool = false;       // false-Mouse Wheel, true-Mouse Move

    SetTargetFPS(60);       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_ONE)) zoomMode = false;
        else if (IsKeyPressed(.KEY_TWO)) zoomMode = true;

        // Translate based on mouse right click
        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT))
        {
            delta: Vector2 = GetMouseDelta();
            delta = Vector2Scale(delta, -1.0/camera.zoom);
            camera.target = Vector2Add(camera.target, delta);
        }

        if (!zoomMode)
        {
            // Zoom based on mouse wheel
            wheel: float = GetMouseWheelMove();
            if (wheel != 0)
            {
                // Get the world point that is under the mouse
                mouseWorldPos: Vector2 = GetScreenToWorld2D(GetMousePosition(), camera);

                // Set the offset to where the mouse is
                camera.offset = GetMousePosition();

                // Set the target to match, so that the camera maps the world space point
                // under the cursor to the screen space point under the cursor at any zoom
                camera.target = mouseWorldPos;

                // Zoom increment
                // Uses log scaling to provide consistent zoom speed
                scale: float = 0.2*wheel;
                camera.zoom = Clamp(exp(log(camera.zoom)+scale), 0.125, 64.0);
            }
        }
        else
        {
            // Zoom based on mouse right click
            if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT))
            {
                // Get the world point that is under the mouse
                mouseWorldPos: Vector2 = GetScreenToWorld2D(GetMousePosition(), camera);

                // Set the offset to where the mouse is
                camera.offset = GetMousePosition();

                // Set the target to match, so that the camera maps the world space point
                // under the cursor to the screen space point under the cursor at any zoom
                camera.target = mouseWorldPos;
            }

            if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT))
            {
                // Zoom increment
                // Uses log scaling to provide consistent zoom speed
                deltaX: float = GetMouseDelta().x;
                scale: float = 0.005*deltaX;
                camera.zoom = Clamp(exp(log(camera.zoom)+scale), 0.125, 64.0);
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            BeginMode2D(camera);
                // Draw the 3d grid, rotated 90 degrees and centered around 0,0
                // just so we have something in the XY plane
                rlPushMatrix();
                    rlTranslatef(0, 25*50, 0);
                    rlRotatef(90, 1, 0, 0);
                    DrawGrid(100, 50);
                rlPopMatrix();

                // Draw a reference circle
                DrawCircle(GetScreenWidth()/2, GetScreenHeight()/2, 50, MAROON);
            EndMode2D();

            // Draw mouse reference
            //Vector2 mousePos = GetWorldToScreen2D(GetMousePosition(), camera)
            DrawCircleV(GetMousePosition(), 4, DARKGRAY);
            DrawTextEx(GetFontDefault(), TextFormat("[%i, %i]", GetMouseX(), GetMouseY()),
                Vector2Add(GetMousePosition(), Vector2.{ -44, -24 }), 20, 2, BLACK);

            DrawText("[1][2] Select mouse zoom mode (Wheel or Move)", 20, 20, 20, DARKGRAY);
            if (!zoomMode) DrawText("Mouse left button drag to move, mouse wheel to zoom", 20, 50, 20, DARKGRAY);
            else DrawText("Mouse left button drag to move, mouse press and move to zoom", 20, 50, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}