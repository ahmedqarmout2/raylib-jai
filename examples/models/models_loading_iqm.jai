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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading iqm");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 10.0, 10.0, 10.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 4.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera mode type

    model: Model = LoadModel("resources/models/iqm/guy.iqm");                    // Load the animated model mesh and basic data
    texture: Texture2D = LoadTexture("resources/models/iqm/guytex.png");         // Load model texture and set material
    SetMaterialTexture(*model.materials[0], MATERIAL_MAP_DIFFUSE, texture);     // Set model material map texture
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position

    // Load animation data
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/iqm/guyanim.iqm", *animCount);

    // Animation playing variables
    animIndex: u32 = 0;         // Current animation playing
    animCurrentFrame: float = 0.0;      // Current animation frame (supporting interpolated frames)
    animSpeed: float = 1.0; // How fast the animation plays

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsKeyPressed(.KEY_RIGHT))
        {
            animIndex = ifx (animIndex == cast(u32)animCount - 1) then 0 else animIndex + 1;
            animCurrentFrame = 0.0;
        }
        if (IsKeyPressed(.KEY_LEFT))
        {
            animIndex = ifx (animIndex == 0) then cast(u32)animCount - 1 else animIndex - 1;
            animCurrentFrame = 0.0;
        }

        if (IsKeyPressed(.KEY_UP))   animSpeed = min(5.0, animSpeed + 0.1);
        if (IsKeyPressed(.KEY_DOWN)) animSpeed = max(0.0, animSpeed - 0.1);

        animCurrentFrame += animSpeed;
        UpdateModelAnimation(model, anims[animIndex], animCurrentFrame);
        if (animCurrentFrame >= anims[animIndex].keyframeCount * 1.0) animCurrentFrame = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModelEx(model, position, Vector3.{ 1.0, 0.0, 0.0 }, -90.0, Vector3.{ 1.0, 1.0, 1.0 }, WHITE);

                DrawGrid(10, 1.0);

            EndMode3D();

            DrawText(TextFormat("Current animation: %s", *anims[animIndex].name), 10, 10, 20, MAROON);
            DrawText(TextFormat("Animation speed: %.2f", animSpeed), 10, 40, 20, MAROON);
            DrawText("Use left and right arrow keys to change current animation", 10, screenHeight - 34, 10, BLACK);
            DrawText("Use up and down arrow keys to change animation speed", 10, screenHeight - 20, 10, BLACK);
            DrawText("(c) Guy IQM 3D model by @culacant", screenWidth - 200, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);                    // Unload texture
    UnloadModelAnimations(anims, animCount);   // Unload model animations data
    UnloadModel(model);                        // Unload model

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
