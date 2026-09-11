#import "raylib";
#import "Basic";
#import "Math";

WORLD_SIZE :: 8 ;  // Size of our voxel world (8x8x8 cubes)

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - basic voxel");

    DisableCursor(); // Lock mouse to window center

    // Define the camera to look into our 3d world (first person)
    camera: Camera3D;
    camera.position = Vector3.{ -2.0, 0.0, -2.0 };  // Camera position at ground level
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector
    camera.fovy = 45.0;                                 // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;              // Camera projection type

    // Create a cube model
    cubeMesh: Mesh = GenMeshCube(1.0, 1.0, 1.0);      // Create a unit cube mesh
    cubeModel: Model = LoadModelFromMesh(cubeMesh);       // Convert mesh to a model
    cubeModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].color = BEIGE;

    // Initialize voxel world - fill with voxels
    voxels: [WORLD_SIZE][WORLD_SIZE][WORLD_SIZE]bool;
    for x: 0..WORLD_SIZE-1
    {
        for y: 0..WORLD_SIZE-1
        {
            for z: 0..WORLD_SIZE-1
            {
                voxels[x][y][z] = true;
            }
        }
    }

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Handle voxel removal with mouse click
        // This method is quite inefficient. Ray marching through the voxel grid using DDA would be faster, but more complex.
        if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
        {
            // Cast a ray from the screen center (where crosshair would be)
            screenCenter: Vector2 = .{ GetScreenWidth()/2.0, GetScreenHeight()/2.0 };
            ray: Ray = GetMouseRay(screenCenter, camera);

            // Check ray collision with all voxels
            closestDistance: float = 99999.0;
            closestVoxelPosition: Vector3 = .{ -1, -1, -1 };
            voxelFound: bool = false;
            for x: 0..WORLD_SIZE-1
            {
                for y: 0..WORLD_SIZE-1
                {
                    for z: 0..WORLD_SIZE-1
                    {
                        if (!voxels[x][y][z]) continue; // Skip empty voxels

                        // Build a bounding box for this voxel
                        position: Vector3 = .{ cast(float)x, cast(float)y, cast(float)z };
                        box: BoundingBox = .{
                            Vector3.{ position.x - 0.5, position.y - 0.5, position.z - 0.5 },
                            Vector3.{ position.x + 0.5, position.y + 0.5, position.z + 0.5 }
                        };

                        // Check ray-box collision
                        collision: RayCollision = GetRayCollisionBox(ray, box);
                        if (collision.hit && (collision.distance < closestDistance))
                        {
                            closestDistance = collision.distance;
                            closestVoxelPosition = Vector3.{ x*1.0, y*1.0, z*1.0 };
                            voxelFound = true;
                        }
                    }
                }
            }

            // Remove the closest voxel if one was hit
            if (voxelFound)
            {
                voxels[cast(s32)closestVoxelPosition.x]
                      [cast(s32)closestVoxelPosition.y]
                      [cast(s32)closestVoxelPosition.z] = false;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawGrid(10, 1.0);

                // Draw all voxels
                for x: 0..WORLD_SIZE-1
                {
                    for y: 0..WORLD_SIZE-1
                    {
                        for z: 0..WORLD_SIZE-1
                        {
                            if (!voxels[x][y][z]) continue;

                            position: Vector3 = .{ cast(float)x, cast(float)y, cast(float)z };
                            DrawModel(cubeModel, position, 1.0, BEIGE);
                            DrawCubeWires(position, 1.0, 1.0, 1.0, BLACK);
                        }
                    }
                }

            EndMode3D();

            // Draw reference point for raycasting to delete blocks
            DrawCircle(GetScreenWidth()/2, GetScreenHeight()/2, 4, RED);

            DrawText("Left-click a voxel to remove it!", 10, 10, 20, DARKGRAY);
            DrawText("WASD to move, mouse to look around", 10, 35, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(cubeModel);

    CloseWindow();
    //--------------------------------------------------------------------------------------
}
