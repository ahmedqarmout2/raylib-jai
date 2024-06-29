#import "raylib";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - core world screen");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 10.0, 10.0, 10.0 }; // Camera position
    camera.target   = Vector3.{ 0.0 , 0.0 , 0.0  }; // Camera looking at point
    camera.up       = Vector3.{ 0.0 , 1.0 , 0.0  }; // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    cubePosition: Vector3 = .{ 0.0, 0.0, 0.0 };
    cubeScreenPosition: Vector2 = .{ 0.0, 0.0 };

    DisableCursor();               // Limit cursor to relative movement inside the window

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_THIRD_PERSON);

        // Calculate cube screen space position (with a little offset to be in top)
        cubeScreenPosition = GetWorldToScreen(Vector3.{cubePosition.x, cubePosition.y + 2.5, cubePosition.z}, camera);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

            DrawCube(cubePosition, 2.0, 2.0, 2.0, RED);
            DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON);

            DrawGrid(10, 1.0);

            EndMode3D();

            DrawText("Enemy: 100 / 100", cast(s32)cubeScreenPosition.x - MeasureText("Enemy: 100/100", 20)/2, cast(s32)cubeScreenPosition.y, 20, BLACK);
            
            DrawText(TextFormat("Cube position in screen space coordinates: [%i, %i]", cast(s32)cubeScreenPosition.x, cast(s32)cubeScreenPosition.y), 10, 10, 20, LIME);
            DrawText("Text 2d should be always on top of the cube", 10, 40, 20, GRAY);
        }
        //----------------------------------------------------------------------------------
    }
}