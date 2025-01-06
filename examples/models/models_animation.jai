#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - model animation");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{10.0, 10.0, 10.0}; // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera mode type

    model: Model = LoadModel("resources/models/iqm/guy.iqm");                    // Load the animated model mesh and basic data
    texture: Texture2D = LoadTexture("resources/models/iqm/guytex.png");         // Load model texture and set material
    SetMaterialTexture(*model.materials[0], MATERIAL_MAP_DIFFUSE, texture);     // Set model material map texture

    position: Vector3 = .{ 0.0, 0.0, 0.0 };            // Set model position

    // Load animation data
    animsCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/iqm/guyanim.iqm", *animsCount);
    animFrameCounter: s32 = 0;

    DisableCursor();                    // Catch cursor
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Play animation when spacebar is held down
        if (IsKeyDown(.KEY_SPACE)) {
            animFrameCounter += 1;
            UpdateModelAnimation(model, anims[0], animFrameCounter);
            if (animFrameCounter >= anims[0].frameCount) animFrameCounter = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModelEx(model, position, Vector3.{1.0, 0.0, 0.0}, -90.0, Vector3.{1.0, 1.0, 1.0}, WHITE);

                for i: 0..model.boneCount-1 {
                    DrawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2, 0.2, 0.2, RED);
                }

                DrawGrid(10, 1.0);         // Draw a grid

            EndMode3D();

            DrawText("PRESS SPACE to PLAY MODEL ANIMATION", 10, 10, 20, MAROON);
            DrawText("(c) Guy IQM 3D model by @culacant", screenWidth - 200, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);                     // Unload texture
    UnloadModelAnimations(anims, animsCount);   // Unload model animations data
    UnloadModel(model);                         // Unload model

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}