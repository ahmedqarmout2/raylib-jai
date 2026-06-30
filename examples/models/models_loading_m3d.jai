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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading m3d");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 1.5, 1.5, 1.5 };    // Camera position
    camera.target = Vector3.{ 0.0, 0.4, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                             // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load model
    model: Model = LoadModel("resources/models/m3d/cesium_man.m3d");             // Load the animated model mesh and basic data
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position

    // Load animation data
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/m3d/cesium_man.m3d", *animCount);

    // Animation playing variables
    animIndex: s32 = 0;                 // Current animation playing
    animCurrentFrame: float = 0.0;      // Current animation frame (supporting interpolated frames)

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Select current animation
        if (IsKeyPressed(.KEY_RIGHT)) animIndex = (animIndex + 1)%animCount;
        else if (IsKeyPressed(.KEY_LEFT)) animIndex = (animIndex + animCount - 1)%animCount;

        // Update model animation
        animCurrentFrame += 1.0;
        if (animCurrentFrame >= cast(float)anims[animIndex].keyframeCount) animCurrentFrame = 0.0;
        UpdateModelAnimation(model, anims[animIndex], animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // Draw 3d model with texture
                if (!IsKeyDown(.KEY_SPACE)) DrawModel(model, position, 1.0, WHITE);
                else
                {
                    // Draw the animated skeleton
                    DrawModelSkeleton(model.skeleton, anims[animIndex].keyframePoses[cast(s32)animCurrentFrame], 1.0, RED);
                }

                DrawGrid(10, 1.0);

            EndMode3D();

            DrawText(TextFormat("Current animation: %s", *anims[animIndex].name), 10, 10, 20, LIGHTGRAY);
            DrawText("Press SPACE to draw skeleton", 10, 40, 20, MAROON);
            DrawText("(c) CesiumMan model by KhronosGroup", GetScreenWidth() - 210, GetScreenHeight() - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(anims, animCount);   // Unload model animations data
    UnloadModel(model);                        // Unload model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}


// Draw model skeleton
DrawModelSkeleton :: (skeleton: ModelSkeleton, pose: ModelAnimPose, scale: float, color: Color)
{
    // Loop to (boneCount - 1) because the last one is a special "no bone" bone,
    // needed to workaround buggy models without a -1, a cube is always drawn at the origin
    for i: 0..skeleton.boneCount - 2
    {
        // Display the frame-pose skeleton
        DrawCube(pose[i].translation, scale*0.05, scale*0.05, scale*0.05, color);

        if (skeleton.bones[i].parent >= 0)
        {
            DrawLine3D(pose[i].translation, pose[skeleton.bones[i].parent].translation, color);
        }
    }
}