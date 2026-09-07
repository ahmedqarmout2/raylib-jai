#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - animation timing");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 6.0, 6.0, 6.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    // Load model
    model: Model = LoadModel("resources/models/gltf/robot.glb");
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model world position

    // Load model animations
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/gltf/robot.glb", *animCount);

    // Animation playing variables
    animIndex: s32 = 10;                  // Current animation playing
    animCurrentFrame: float = 0.0;      // Current animation frame (supporting interpolated frames)
    animFrameSpeed: float = 0.5;        // Animation play speed
    animPause: bool = false;             // Pause animation

    // UI required variables
    animNames: [64]*u8;
    for i: 0..animCount-1 animNames[i] = anims[i].name.data;

    dropdownEditMode: bool = false;
    animFrameProgress: float = 0.0;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsKeyPressed(.KEY_P)) animPause = !animPause;

        if (!animPause && (animIndex < animCount))
        {
            // Update model animation
            animCurrentFrame += animFrameSpeed;
            if (animCurrentFrame >= anims[animIndex].keyframeCount * 1.0) animCurrentFrame = 0.0;
            UpdateModelAnimation(model, anims[animIndex], animCurrentFrame);
        }

        // NOTE: Animation and playing speed selected through UI

        // Update progressbar value with current frame
        animFrameProgress = animCurrentFrame;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0, WHITE);

                DrawGrid(10, 1.0);

            EndMode3D();

            // Draw UI, select anim and playing speed
            GuiSetStyle(.DROPDOWNBOX, cast(s32)GuiDropdownBoxProperty.DROPDOWN_ITEMS_SPACING, 1);
            if (GuiDropdownBox(Rectangle.{ 10, 10, 140, 24 }, TextJoin(animNames.data, animCount, ";"),
                *animIndex, dropdownEditMode)) dropdownEditMode = !dropdownEditMode;

            GuiSlider(Rectangle.{ 260, 10, 500, 24 }, "FRAME SPEED: ", TextFormat("x%.1f", animFrameSpeed),
                *animFrameSpeed, 0.1, 2.0);

            // Draw playing timeline with keyframes
            GuiLabel(Rectangle.{ 10, GetScreenHeight() - 64.0, GetScreenWidth() - 20.0, 24 },
                TextFormat("CURRENT FRAME: %.2f / %i", animFrameProgress, anims[animIndex].keyframeCount));
            GuiProgressBar(Rectangle.{ 10, GetScreenHeight() - 40.0, GetScreenWidth() - 20.0, 24 }, null, null,
                *animFrameProgress, 0.0, cast(float)anims[animIndex].keyframeCount);
            for i: 0..anims[animIndex].keyframeCount - 1
                DrawRectangle(10 + cast(s32)((cast(float)(GetScreenWidth() - 20)/cast(float)anims[animIndex].keyframeCount)*cast(float)i),
                    GetScreenHeight() - 40, 1, 24, BLUE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(anims, animCount); // Unload model animation
    UnloadModel(model);         // Unload model and meshes/material

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

