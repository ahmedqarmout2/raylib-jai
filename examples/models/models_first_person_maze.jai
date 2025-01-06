#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - first person maze");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 0.2, 0.4, 0.2 };    // Camera position
    camera.target = Vector3.{ 0.185, 0.4, 0.0 };    // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    imMap: Image = LoadImage("resources/cubicmap.png");      // Load cubicmap image (RAM)
    cubicmap: Texture2D = LoadTextureFromImage(imMap);       // Convert image to texture to display (VRAM)
    mesh: Mesh = GenMeshCubicmap(imMap, Vector3.{ 1.0, 1.0, 1.0 });
    model: Model = LoadModelFromMesh(mesh);

    // NOTE: By default each cube is mapped to one part of texture atlas
    texture: Texture2D = LoadTexture("resources/cubicmap_atlas.png");    // Load map texture
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;    // Set map diffuse texture

    // Get map image data to be used for collision detection
    mapPixels: *Color = LoadImageColors(imMap);
    UnloadImage(imMap);             // Unload image from RAM

    mapPosition: Vector3 = .{ -16.0, 0.0, -8.0 };  // Set model position

    DisableCursor();                // Limit cursor to relative movement inside the window

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        oldCamPos: Vector3 = camera.position;    // Store old camera position

        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Check player collision (we simplify to 2D collision detection)
        playerPos: Vector2 = .{ camera.position.x, camera.position.z };
        playerRadius: float = 0.1;  // Collision radius (player is modelled as a cilinder for collision)

        playerCellX: s32 = cast(s32)(playerPos.x - mapPosition.x + 0.5);
        playerCellY: s32 = cast(s32)(playerPos.y - mapPosition.z + 0.5);

        // Out-of-limits security check
        if (playerCellX < 0) playerCellX = 0;
        else if (playerCellX >= cubicmap.width) playerCellX = cubicmap.width - 1;

        if (playerCellY < 0) playerCellY = 0;
        else if (playerCellY >= cubicmap.height) playerCellY = cubicmap.height - 1;

        // Check map collisions using image data and player position
        // TODO: Improvement: Just check player surrounding cells for collision
        for y: 0..cubicmap.height-1 {
            for x: 0..cubicmap.width-1 {
                if ((mapPixels[y*cubicmap.width + x].r == 255) &&       // Collision: white pixel, only check R channel
                    (CheckCollisionCircleRec(playerPos, playerRadius,
                    Rectangle.{ mapPosition.x - 0.5 + x*1.0, mapPosition.z - 0.5 + y*1.0, 1.0, 1.0 }))) {
                    // Collision detected, reset camera position
                    camera.position = oldCamPos;
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                DrawModel(model, mapPosition, 1.0, WHITE);                     // Draw maze map
            EndMode3D();

            DrawTextureEx(cubicmap, Vector2.{ GetScreenWidth() - cubicmap.width*4.0 - 20, 20.0 }, 0.0, 4.0, WHITE);
            DrawRectangleLines(GetScreenWidth() - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, GREEN);

            // Draw player position radar
            DrawRectangle(GetScreenWidth() - cubicmap.width*4 - 20 + playerCellX*4, 20 + playerCellY*4, 4, 4, RED);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadImageColors(mapPixels);   // Unload color array

    UnloadTexture(cubicmap);        // Unload cubicmap texture
    UnloadTexture(texture);         // Unload map texture
    UnloadModel(model);             // Unload map model

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}