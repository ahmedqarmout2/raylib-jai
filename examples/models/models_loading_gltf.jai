#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading gltf animations");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 6.0, 6.0, 6.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    // Load gltf model
    model: Model = LoadModel("resources/models/gltf/robot.glb");
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position
    
    // Load gltf model animations
    animsCount: s32 = 0;
    animIndex: s32 = 0;
    animCurrentFrame: s32 = 0;
    modelAnimations: *ModelAnimation = LoadModelAnimations("resources/models/gltf/robot.glb", *animsCount);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Select current animation
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT)) animIndex = (animIndex + 1)%animsCount;
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) animIndex = (animIndex + animsCount - 1)%animsCount;

        // Update model animation
        anim: ModelAnimation = modelAnimations[animIndex];
        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
        UpdateModelAnimation(model, anim, animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                DrawModel(model, position, 1.0, WHITE);    // Draw animated model
                DrawGrid(10, 1.0);
            EndMode3D();

            DrawText("Use the LEFT/RIGHT mouse buttons to switch animation", 10, 10, 20, GRAY);
            DrawText(TextFormat("Animation: %s", anim.name.data), 10, GetScreenHeight() - 20, 10, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);         // Unload model and meshes/material

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}