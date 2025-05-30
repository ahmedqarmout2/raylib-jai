#import "raylib";
#import "Basic";
#import "Math";

MAX_COLUMNS : s32 : 20;

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera first person");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world (position, target, up vector)
    camera: Camera;
    camera.position = Vector3.{ 0.0, 2.0, 4.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 60.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    cameraMode: CameraMode = .CAMERA_FIRST_PERSON;

    // Generates some random columns
    heights   : [MAX_COLUMNS]float;
    positions : [MAX_COLUMNS]Vector3;
    colors    : [MAX_COLUMNS]Color;

    for i: 0..MAX_COLUMNS-1 {
        heights[i]   = cast(float)GetRandomValue(1, 12);
        positions[i] = Vector3.{ cast(float)GetRandomValue(-15, 15), heights[i]/2.0, cast(float)GetRandomValue(-15, 15) };
        colors[i]    = Color.{ cast(u8)GetRandomValue(20, 255), cast(u8)GetRandomValue(10, 55), 30, 255 };
    }

    DisableCursor();               // Limit cursor to relative movement inside the window

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Switch camera mode
        if (IsKeyPressed(.KEY_ONE)) {
            cameraMode = .CAMERA_FREE;
            camera.up  = Vector3.{ 0.0, 1.0, 0.0 }; // Reset roll
        }

        if (IsKeyPressed(.KEY_TWO)) {
            cameraMode = .CAMERA_FIRST_PERSON;
            camera.up  = Vector3.{ 0.0, 1.0, 0.0 }; // Reset roll
        }

        if (IsKeyPressed(.KEY_THREE)) {
            cameraMode = .CAMERA_THIRD_PERSON;
            camera.up  = Vector3.{ 0.0, 1.0, 0.0 }; // Reset roll
        }

        if (IsKeyPressed(.KEY_FOUR)) {
            cameraMode = .CAMERA_ORBITAL;
            camera.up  = Vector3.{ 0.0, 1.0, 0.0 }; // Reset roll
        }

        // Switch camera projection
        if (IsKeyPressed(.KEY_P)) {
            if (camera.projection == .CAMERA_PERSPECTIVE) {
                // Create isometric view
                cameraMode = .CAMERA_THIRD_PERSON;
                // Note: The target distance is related to the render distance in the orthographic projection
                camera.position = Vector3.{ 0.0, 2.0, -100.0 };
                camera.target = Vector3.{ 0.0, 2.0, 0.0 };
                camera.up = Vector3.{ 0.0, 1.0, 0.0 };
                camera.projection = .CAMERA_ORTHOGRAPHIC;
                camera.fovy = 20.0; // near plane width in CAMERA_ORTHOGRAPHIC
                CameraYaw(*camera, -135 * DEG2RAD, true);
                CameraPitch(*camera, -45 * DEG2RAD, true, true, false);
            } else if (camera.projection == .CAMERA_ORTHOGRAPHIC) {
                // Reset to default view
                cameraMode = .CAMERA_THIRD_PERSON;
                camera.position = Vector3.{ 0.0, 2.0, 10.0 };
                camera.target = Vector3.{ 0.0, 2.0, 0.0 };
                camera.up = Vector3.{ 0.0, 1.0, 0.0 };
                camera.projection = .CAMERA_PERSPECTIVE;
                camera.fovy = 60.0;
            }
        }

        // Update camera computes movement internally depending on the camera mode
        // Some default standard keyboard/mouse inputs are hardcoded to simplify use
        // For advance camera controls, it's reecommended to compute camera movement manually
        UpdateCamera(*camera, cameraMode);                  // Update camera

/*
        // Camera PRO usage example (EXPERIMENTAL)
        // This new camera function allows custom movement/rotation values to be directly provided
        // as input parameters, with this approach, rcamera module is internally independent of raylib inputs
        UpdateCameraPro(&camera,
            Vector3.{
                (IsKeyDown(KEY_W) || IsKeyDown(KEY_UP))*0.1f -      // Move forward-backward
                (IsKeyDown(KEY_S) || IsKeyDown(KEY_DOWN))*0.1f,    
                (IsKeyDown(KEY_D) || IsKeyDown(KEY_RIGHT))*0.1f -   // Move right-left
                (IsKeyDown(KEY_A) || IsKeyDown(KEY_LEFT))*0.1f,
                0.0f                                                // Move up-down
            },
            Vector3.{
                GetMouseDelta().x*0.05f,                            // Rotation: yaw
                GetMouseDelta().y*0.05f,                            // Rotation: pitch
                0.0f                                                // Rotation: roll
            },
            GetMouseWheelMove()*2.0f);                              // Move to target (zoom)
*/
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

                DrawPlane(Vector3.{ 0.0, 0.0, 0.0 }, Vector2.{ 32.0, 32.0 }, LIGHTGRAY); // Draw ground
                DrawCube(Vector3.{ -16.0, 2.5, 0.0 }, 1.0, 5.0, 32.0, BLUE);     // Draw a blue wall
                DrawCube(Vector3.{ 16.0, 2.5, 0.0 }, 1.0, 5.0, 32.0, LIME);      // Draw a green wall
                DrawCube(Vector3.{ 0.0, 2.5, 16.0 }, 32.0, 5.0, 1.0, GOLD);      // Draw a yellow wall

                // Draw some cubes around
                for i: 0..MAX_COLUMNS-1 {
                    DrawCube(positions[i], 2.0, heights[i], 2.0, colors[i]);
                    DrawCubeWires(positions[i], 2.0, heights[i], 2.0, MAROON);
                }

                // Draw player cube
                if (cameraMode == .CAMERA_THIRD_PERSON) {
                    DrawCube(camera.target, 0.5, 0.5, 0.5, PURPLE);
                    DrawCubeWires(camera.target, 0.5, 0.5, 0.5, DARKPURPLE);
                }
            }

            // Draw info boxes
            DrawRectangle(5, 5, 330, 100, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(5, 5, 330, 100, BLUE);

            DrawText("Camera controls:", 15, 15, 10, BLACK);
            DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, BLACK);
            DrawText("- Look around: arrow keys or mouse", 15, 45, 10, BLACK);
            DrawText("- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, BLACK);
            DrawText("- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, BLACK);
            DrawText("- Camera projection key: P", 15, 90, 10, BLACK);

            DrawRectangle(600, 5, 195, 100, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(600, 5, 195, 100, BLUE);

            DrawText("Camera status:", 610, 15, 10, BLACK);

            t1 : *u8 = get_c_string(ifx (cameraMode == .CAMERA_FREE) then "FREE" else
                              ifx (cameraMode == .CAMERA_FIRST_PERSON) then "FIRST_PERSON" else
                              ifx (cameraMode == .CAMERA_THIRD_PERSON) then "THIRD_PERSON" else
                              ifx (cameraMode == .CAMERA_ORBITAL) then "ORBITAL" else "CUSTOM");
            DrawText(TextFormat("- Mode: %s", t1), 610, 30, 10, BLACK);

            t2 : *u8 = get_c_string(ifx (camera.projection == .CAMERA_PERSPECTIVE) then "PERSPECTIVE" else
                              ifx (camera.projection == .CAMERA_ORTHOGRAPHIC) then "ORTHOGRAPHIC" else "CUSTOM");
            DrawText(TextFormat("- Projection: %s", t2), 610, 45, 10, BLACK);

            DrawText(TextFormat("- Position: (%06.3f, %06.3f, %06.3f)", camera.position.x, camera.position.y, camera.position.z), 610, 60, 10, BLACK);
            DrawText(TextFormat("- Target: (%06.3f, %06.3f, %06.3f)", camera.target.x, camera.target.y, camera.target.z), 610, 75, 10, BLACK);
            DrawText(TextFormat("- Up: (%06.3f, %06.3f, %06.3f)", camera.up.x, camera.up.y, camera.up.z), 610, 90, 10, BLACK);
        }
        //----------------------------------------------------------------------------------
    }
}