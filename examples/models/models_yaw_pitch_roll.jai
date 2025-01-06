#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    //SetConfigFlags(FLAG_MSAA_4X_HINT | FLAG_WINDOW_HIGHDPI);
    InitWindow(screenWidth, screenHeight, "raylib [models] example - plane rotations (yaw, pitch, roll)");

    camera: Camera;
    camera.position = Vector3.{ 0.0, 50.0, -120.0 };// Camera position perspective
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 30.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera type

    model: Model = LoadModel("resources/models/obj/plane.obj");                  // Load model
    texture: Texture2D = LoadTexture("resources/models/obj/plane_diffuse.png");  // Load model texture
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;            // Set map diffuse texture

    pitch: float = 0.0;
    roll: float = 0.0;
    yaw: float = 0.0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Plane pitch (x-axis) controls
        if (IsKeyDown(.KEY_DOWN)) pitch += 0.6;
        else if (IsKeyDown(.KEY_UP)) pitch -= 0.6;
        else
        {
            if (pitch > 0.3) pitch -= 0.3;
            else if (pitch < -0.3) pitch += 0.3;
        }

        // Plane yaw (y-axis) controls
        if (IsKeyDown(.KEY_S)) yaw -= 1.0;
        else if (IsKeyDown(.KEY_A)) yaw += 1.0;
        else
        {
            if (yaw > 0.0) yaw -= 0.5;
            else if (yaw < 0.0) yaw += 0.5;
        }

        // Plane roll (z-axis) controls
        if (IsKeyDown(.KEY_LEFT)) roll -= 1.0;
        else if (IsKeyDown(.KEY_RIGHT)) roll += 1.0;
        else
        {
            if (roll > 0.0) roll -= 0.5;
            else if (roll < 0.0) roll += 0.5;
        }

        // Tranformation matrix for rotations
        model.transform = MatrixRotateXYZ(Vector3.{ DEG2RAD*pitch, DEG2RAD*yaw, DEG2RAD*roll });
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw 3D model (recomended to draw 3D always before 2D)
            BeginMode3D(camera);

                DrawModel(model, Vector3.{ 0.0, -8.0, 0.0 }, 1.0, WHITE);   // Draw 3d model with texture
                DrawGrid(10, 10.0);

            EndMode3D();

            // Draw controls info
            DrawRectangle(30, 370, 260, 70, Fade(GREEN, 0.5));
            DrawRectangleLines(30, 370, 260, 70, Fade(DARKGREEN, 0.5));
            DrawText("Pitch controlled with: KEY_UP / KEY_DOWN", 40, 380, 10, DARKGRAY);
            DrawText("Roll controlled with: KEY_LEFT / KEY_RIGHT", 40, 400, 10, DARKGRAY);
            DrawText("Yaw controlled with: KEY_A / KEY_S", 40, 420, 10, DARKGRAY);

            DrawText("(c) WWI Plane Model created by GiaHanLam", screenWidth - 240, screenHeight - 20, 10, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);     // Unload model data
    UnloadTexture(texture); // Unload texture data

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
