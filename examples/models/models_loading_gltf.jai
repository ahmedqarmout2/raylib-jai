#import "raylib";
#import "Basic";
#import "Math";

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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading gltf");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 6.0, 6.0, 6.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load gltf model
    model: Model = LoadModel("resources/models/gltf/robot.glb");
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position
    
    // Load model animations
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/gltf/robot.glb", *animCount);

    // Animation playing variables
    animIndex: s32 = 0;         // Current animation playing
    animCurrentFrame: s32 = 0;  // Current animation frame

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Select current animation
        if (IsKeyPressed(.KEY_RIGHT)) animIndex = (animIndex + 1)%animCount;
        else if (IsKeyPressed(.KEY_LEFT)) animIndex = (animIndex + animCount - 1)%animCount;

        // Update model animation
        animCurrentFrame = (animCurrentFrame + 1)%anims[animIndex].keyframeCount;
        UpdateModelAnimation(model, anims[animIndex], cast(float)animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0, WHITE);

                DrawGrid(10, 1.0);

            EndMode3D();

            DrawText(TextFormat("Current animation: %s", *anims[animIndex].name), 10, 40, 20, MAROON);
            DrawText("Use the LEFT/RIGHT keys to switch animation", 10, 10, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(anims, animCount); // Unload model animations data
    UnloadModel(model);         // Unload model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}