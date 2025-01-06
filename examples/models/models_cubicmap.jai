#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - cubesmap loading and drawing");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 16.0, 14.0, 16.0 };     // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };          // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };              // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                    // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;                 // Camera projection type

    image: Image = LoadImage("resources/cubicmap.png");      // Load cubicmap image (RAM)
    cubicmap: Texture2D = LoadTextureFromImage(image);       // Convert image to texture to display (VRAM)

    mesh: Mesh = GenMeshCubicmap(image, Vector3.{ 1.0, 1.0, 1.0 });
    model: Model = LoadModelFromMesh(mesh);

    // NOTE: By default each cube is mapped to one part of texture atlas
    texture: Texture2D = LoadTexture("resources/cubicmap_atlas.png");    // Load map texture
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;    // Set map diffuse texture

    mapPosition: Vector3 = .{ -16.0, 0.0, -8.0 };          // Set model position

    UnloadImage(image);     // Unload cubesmap image from RAM, already uploaded to VRAM

    pause: bool = false;     // Pause camera orbital rotation (and zoom)

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_P)) pause = !pause;

        if (!pause) UpdateCamera(*camera, .CAMERA_ORBITAL);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, mapPosition, 1.0, WHITE);

            EndMode3D();

            DrawTextureEx(cubicmap, Vector2.{ screenWidth - cubicmap.width*4.0 - 20, 20.0 }, 0.0, 4.0, WHITE);
            DrawRectangleLines(screenWidth - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, GREEN);

            DrawText("cubicmap image used to", 658, 90, 10, GRAY);
            DrawText("generate map 3d model", 658, 104, 10, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(cubicmap);    // Unload cubicmap texture
    UnloadTexture(texture);     // Unload map texture
    UnloadModel(model);         // Unload map model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
