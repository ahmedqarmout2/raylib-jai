#import "raylib";
#import "Math";

main :: () {
    screenWidth  :: 800;
    screenHeight :: 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 10.0, 10.0, 10.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    cubePosition : Vector3 = .{ 0.0, 1.0, 0.0 };
    cubeSize     : Vector3 = .{ 2.0, 2.0, 2.0 };

    ray: Ray;                      // Picking line ray
    collision: RayCollision;       // Ray collision hit info

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsCursorHidden()) UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Toggle camera controls
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT)) {
            if (IsCursorHidden()) EnableCursor();
            else DisableCursor();
        }

        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
            if (!collision.hit) {
                ray = GetMouseRay(GetMousePosition(), camera);

                // Check collision between ray and box
                collision = GetRayCollisionBox(
                    ray,
                    BoundingBox.{
                        Vector3.{ cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2 },
                        Vector3.{ cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2 }
                    });
            } else collision.hit = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        BeginMode3D(camera);

        if (collision.hit) {
            DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, RED);
            DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, MAROON);

            DrawCubeWires(cubePosition, cubeSize.x + 0.2, cubeSize.y + 0.2, cubeSize.z + 0.2, GREEN);
        } else {
            DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, GRAY);
            DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, DARKGRAY);
        }

        DrawRay(ray, MAROON);
        DrawGrid(10, 1.0);

        EndMode3D();

        DrawText("Try clicking on the box with your mouse!", 240, 10, 20, DARKGRAY);

        if (collision.hit) DrawText("BOX SELECTED", (screenWidth - MeasureText("BOX SELECTED", 30)) / 2, xx (screenHeight * 0.1), 30, GREEN);

        DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY);

        DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}