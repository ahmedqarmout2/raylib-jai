#import "raylib";
#import "Basic";
#import "Math";

FLT_MAX :: FLOAT32_MAX;     // Maximum value of a float, from bit pattern 01111111011111111111111111111111

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh picking");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 20.0, 20.0, 20.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 8.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.6, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    ray: Ray;        // Picking ray

    tower: Model = LoadModel("resources/models/obj/turret.obj");                 // Load OBJ model
    texture: Texture2D = LoadTexture("resources/models/obj/turret_diffuse.png"); // Load model texture
    tower.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;            // Set model diffuse texture

    towerPos: Vector3 = .{ 0.0, 0.0, 0.0 };                        // Set model position
    towerBBox: BoundingBox = GetMeshBoundingBox(tower.meshes[0]);    // Get mesh bounding box

    // Ground quad
    g0: Vector3 = Vector3.{ -50.0, 0.0, -50.0 };
    g1: Vector3 = Vector3.{ -50.0, 0.0,  50.0 };
    g2: Vector3 = Vector3.{  50.0, 0.0,  50.0 };
    g3: Vector3 = Vector3.{  50.0, 0.0, -50.0 };

    // Test triangle
    ta: Vector3 = Vector3.{ -25.0, 0.5, 0.0 };
    tb: Vector3 = Vector3.{ -4.0, 2.5, 1.0 };
    tc: Vector3 = Vector3.{ -8.0, 6.5, 0.0 };

    bary: Vector3 = .{ 0.0, 0.0, 0.0 };

    // Test sphere
    sp: Vector3 = Vector3.{ -30.0, 5.0, 5.0 };
    sr: float = 4.0;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsCursorHidden()) UpdateCamera(*camera, .CAMERA_FIRST_PERSON);          // Update camera

        // Toggle camera controls
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT))
        {
            if (IsCursorHidden()) EnableCursor();
            else DisableCursor();
        }

        // Display information about closest hit
        collision: RayCollision;
        hitObjectName: *u8 = "None";
        collision.distance = FLT_MAX;
        collision.hit = false;
        cursorColor: Color = WHITE;

        // Get ray and test against objects
        ray = GetScreenToWorldRay(GetMousePosition(), camera);

        // Check ray collision against ground quad
        groundHitInfo: RayCollision = GetRayCollisionQuad(ray, g0, g1, g2, g3);

        if ((groundHitInfo.hit) && (groundHitInfo.distance < collision.distance))
        {
            collision = groundHitInfo;
            cursorColor = GREEN;
            hitObjectName = "Ground";
        }

        // Check ray collision against test triangle
        triHitInfo: RayCollision = GetRayCollisionTriangle(ray, ta, tb, tc);

        if ((triHitInfo.hit) && (triHitInfo.distance < collision.distance))
        {
            collision = triHitInfo;
            cursorColor = PURPLE;
            hitObjectName = "Triangle";

            bary = Vector3Barycenter(collision.point, ta, tb, tc);
        }

        // Check ray collision against test sphere
        sphereHitInfo: RayCollision = GetRayCollisionSphere(ray, sp, sr);

        if ((sphereHitInfo.hit) && (sphereHitInfo.distance < collision.distance))
        {
            collision = sphereHitInfo;
            cursorColor = ORANGE;
            hitObjectName = "Sphere";
        }

        // Check ray collision against bounding box first, before trying the full ray-mesh test
        boxHitInfo: RayCollision = GetRayCollisionBox(ray, towerBBox);

        if ((boxHitInfo.hit) && (boxHitInfo.distance < collision.distance))
        {
            collision = boxHitInfo;
            cursorColor = ORANGE;
            hitObjectName = "Box";

            // Check ray collision against model meshes
            meshHitInfo: RayCollision;
            for m: 0..tower.meshCount-1 {
                // NOTE: We consider the model.transform for the collision check but 
                // it can be checked against any transform Matrix, used when checking against same
                // model drawn multiple times with multiple transforms
                meshHitInfo = GetRayCollisionMesh(ray, tower.meshes[m], tower.transform);
                if (meshHitInfo.hit)
                {
                    // Save the closest hit mesh
                    if ((!collision.hit) || (collision.distance > meshHitInfo.distance)) collision = meshHitInfo;
                    
                    break;  // Stop once one mesh collision is detected, the colliding mesh is m
                }
            }

            if (meshHitInfo.hit)
            {
                collision = meshHitInfo;
                cursorColor = ORANGE;
                hitObjectName = "Mesh";
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // Draw the tower
                // WARNING: If scale is different than 1.0,
                // not considered by GetRayCollisionModel()
                DrawModel(tower, towerPos, 1.0, WHITE);

                // Draw the test triangle
                DrawLine3D(ta, tb, PURPLE);
                DrawLine3D(tb, tc, PURPLE);
                DrawLine3D(tc, ta, PURPLE);

                // Draw the test sphere
                DrawSphereWires(sp, sr, 8, 8, PURPLE);

                // Draw the mesh bbox if we hit it
                if (boxHitInfo.hit) DrawBoundingBox(towerBBox, LIME);

                // If we hit something, draw the cursor at the hit point
                if (collision.hit)
                {
                    DrawCube(collision.point, 0.3, 0.3, 0.3, cursorColor);
                    DrawCubeWires(collision.point, 0.3, 0.3, 0.3, RED);

                    normalEnd: Vector3;
                    normalEnd.x = collision.point.x + collision.normal.x;
                    normalEnd.y = collision.point.y + collision.normal.y;
                    normalEnd.z = collision.point.z + collision.normal.z;

                    DrawLine3D(collision.point, normalEnd, RED);
                }

                DrawRay(ray, MAROON);

                DrawGrid(10, 10.0);

            EndMode3D();

            // Draw some debug GUI text
            DrawText(TextFormat("Hit Object: %s", hitObjectName), 10, 50, 10, BLACK);

            if (collision.hit)
            {
                ypos: s32 = 70;

                DrawText(TextFormat("Distance: %3.2f", collision.distance), 10, ypos, 10, BLACK);

                DrawText(TextFormat("Hit Pos: %3.2f %3.2f %3.2f",
                                    collision.point.x,
                                    collision.point.y,
                                    collision.point.z), 10, ypos + 15, 10, BLACK);

                DrawText(TextFormat("Hit Norm: %3.2f %3.2f %3.2f",
                                    collision.normal.x,
                                    collision.normal.y,
                                    collision.normal.z), 10, ypos + 30, 10, BLACK);

                if (triHitInfo.hit && TextIsEqual(hitObjectName, "Triangle"))
                    DrawText(TextFormat("Barycenter: %3.2f %3.2f %3.2f",  bary.x, bary.y, bary.z), 10, ypos + 45, 10, BLACK);
            }

            DrawText("Right click mouse to toggle camera controls", 10, 430, 10, GRAY);

            DrawText("(c) Turret 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(tower);         // Unload model
    UnloadTexture(texture);     // Unload texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
