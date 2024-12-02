#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera mode");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera3D;
    camera.position = Vector3.{ 0.0, 10.0, 10.0 };  // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera mode type

    cubePosition : Vector3 = .{ 0.0, 0.0, 0.0 };

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginMode3D(camera);
            defer EndMode3D();

            DrawCube(cubePosition, 2.0, 2.0, 2.0, RED);
            DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON);

            DrawGrid(10, 1.0);
        }

        DrawText("Welcome to the third dimension!", 10, 40, 20, DARKGRAY);

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}