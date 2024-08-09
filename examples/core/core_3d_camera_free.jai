#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    // Define the camera to look into our 3d world
    camera: Camera3D;
    camera.position = Vector3.{ 10.0, 10.0, 10.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    cubePosition : Vector3 = .{ 0.0, 0.0, 0.0 };

    DisableCursor();               // Limit cursor to relative movement inside the window

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE);

        if (IsKeyPressed(#char "Z")) camera.target = Vector3.{ 0.0, 0.0, 0.0 };
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
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

            DrawRectangle( 10, 10, 320, 93, Fade(SKYBLUE, 0.5));
            DrawRectangleLines( 10, 10, 320, 93, BLUE);

            DrawText("Free camera default controls:", 20, 20, 10, BLACK);
            DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, DARKGRAY);
            DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, DARKGRAY);
            DrawText("- Z to zoom to (0, 0, 0)", 40, 80, 10, DARKGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}