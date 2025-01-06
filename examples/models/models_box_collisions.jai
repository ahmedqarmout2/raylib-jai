#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - box collisions");

    // Define the camera to look into our 3d world
    camera: Camera = .{ .{0.0, 10.0, 10.0}, .{0.0, 0.0, 0.0}, .{0.0, 1.0, 0.0}, 45.0, .CAMERA_PERSPECTIVE};

    playerPosition: Vector3 = .{ 0.0, 1.0, 2.0 };
    playerSize: Vector3 = .{ 1.0, 2.0, 1.0 };
    playerColor: Color = GREEN;

    enemyBoxPos: Vector3 = .{ -4.0, 1.0, 0.0 };
    enemyBoxSize: Vector3  = .{ 2.0, 2.0, 2.0 };

    enemySpherePos: Vector3 = .{ 4.0, 0.0, 0.0 };
    enemySphereSize: float = 1.5;

    collision: bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Move player
        if (IsKeyDown(.KEY_RIGHT)) playerPosition.x += 0.2;
        else if (IsKeyDown(.KEY_LEFT)) playerPosition.x -= 0.2;
        else if (IsKeyDown(.KEY_DOWN)) playerPosition.z += 0.2;
        else if (IsKeyDown(.KEY_UP)) playerPosition.z -= 0.2;

        collision = false;

        // Check collisions player vs enemy-box
        if (CheckCollisionBoxes(
            BoundingBox.{Vector3.{ playerPosition.x - playerSize.x/2,
                                     playerPosition.y - playerSize.y/2,
                                     playerPosition.z - playerSize.z/2 },
                          Vector3.{ playerPosition.x + playerSize.x/2,
                                     playerPosition.y + playerSize.y/2,
                                     playerPosition.z + playerSize.z/2 }},
            BoundingBox.{Vector3.{ enemyBoxPos.x - enemyBoxSize.x/2,
                                     enemyBoxPos.y - enemyBoxSize.y/2,
                                     enemyBoxPos.z - enemyBoxSize.z/2 },
                          Vector3.{ enemyBoxPos.x + enemyBoxSize.x/2,
                                     enemyBoxPos.y + enemyBoxSize.y/2,
                                     enemyBoxPos.z + enemyBoxSize.z/2 }})) collision = true;

        // Check collisions player vs enemy-sphere
        if (CheckCollisionBoxSphere(
            BoundingBox.{Vector3.{ playerPosition.x - playerSize.x/2,
                                     playerPosition.y - playerSize.y/2,
                                     playerPosition.z - playerSize.z/2 },
                          Vector3.{ playerPosition.x + playerSize.x/2,
                                     playerPosition.y + playerSize.y/2,
                                     playerPosition.z + playerSize.z/2 }},
            enemySpherePos, enemySphereSize)) collision = true;

        if (collision) playerColor = RED;
        else playerColor = GREEN;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // Draw enemy-box
                DrawCube(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, GRAY);
                DrawCubeWires(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, DARKGRAY);

                // Draw enemy-sphere
                DrawSphere(enemySpherePos, enemySphereSize, GRAY);
                DrawSphereWires(enemySpherePos, enemySphereSize, 16, 16, DARKGRAY);

                // Draw player
                DrawCubeV(playerPosition, playerSize, playerColor);

                DrawGrid(10, 1.0);        // Draw a grid

            EndMode3D();

            DrawText("Move player with arrow keys to collide", 220, 40, 20, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
