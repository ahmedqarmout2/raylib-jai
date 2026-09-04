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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - animation blending");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 6.0, 6.0, 6.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };  // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };      // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                            // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;         // Camera projection type

    // Load model
    model: Model = LoadModel("resources/models/gltf/robot.glb"); // Load character model
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model world position

    // Load skinning shader
    // WARNING: It requires SUPPORT_GPU_SKINNING enabled on raylib (disabled by default)
    skinningShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/skinning.vs", GLSL_VERSION),
                                       TextFormat("resources/shaders/glsl%i/skinning.fs", GLSL_VERSION));

    // Assign skinning shader to all materials shaders
    //for (int i = 0; i < model.materialCount; i++) model.materials[i].shader = skinningShader;

    // Load model animations
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/gltf/robot.glb", *animCount);

    // Animation playing variables
    // NOTE: Two animations are played with a smooth transition between them
    currentAnimPlaying: s32 = 0;         // Current animation playing (0 o 1)
    nextAnimToPlay: s32 = 1;             // Next animation to play (to transition)
    animTransition: bool = false;        // Flag to register anim transition state

    animIndex0: s32 = 10;                // Current animation playing (walking)
    animCurrentFrame0: float = 0.0;     // Current animation frame (supporting interpolated frames)
    animFrameSpeed0: float = 0.5;       // Current animation play speed
    animIndex1: s32 = 6;                 // Next animation to play (running)
    animCurrentFrame1: float = 0.0;     // Next animation frame (supporting interpolated frames)
    animFrameSpeed1: float = 0.5;       // Next animation play speed

    animBlendFactor: float = 0.0;       // Blend factor from anim0[frame0] --> anim1[frame1], [0.0..1.0]
                                        // NOTE: 0.0 results in full anim0[] and 1.0 in full anim1[]

    animBlendTime: float = 2.0;         // Time to blend from one playing animation to another (in seconds)
    animBlendTimeCounter: float = 0.0;  // Time counter (delta time)

    animPause: bool = false;             // Pause animation

    // UI required variables
    animNames: [64]*u8;        // Pointers to animation names for dropdown box
    for i: 0..animCount-1 animNames[i] = anims[i].name.data;

    dropdownEditMode0: bool = false;
    dropdownEditMode1: bool = false;
    animFrameProgress0: float = 0.0;
    animFrameProgress1: float = 0.0;
    animBlendProgress: float = 0.0;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsKeyPressed(.KEY_P)) animPause = !animPause;

        if (!animPause)
        {
            // Start transition from anim0[] to anim1[]
            if (IsKeyPressed(.KEY_SPACE) && !animTransition)
            {
                if (currentAnimPlaying == 0)
                {
                    // Transition anim0 --> anim1
                    nextAnimToPlay = 1;
                    animCurrentFrame1 = 0.0;
                }
                else
                {
                    // Transition anim1 --> anim0
                    nextAnimToPlay = 0;
                    animCurrentFrame0 = 0.0;
                }

                // Set animation transition
                animTransition = true;
                animBlendTimeCounter = 0.0;
                animBlendFactor = 0.0;
            }

            if (animTransition)
            {
                // Playing anim0 and anim1 at the same time
                animCurrentFrame0 += animFrameSpeed0;
                if (animCurrentFrame0 >= anims[animIndex0].keyframeCount * 1.0) animCurrentFrame0 = 0.0;
                animCurrentFrame1 += animFrameSpeed1;
                if (animCurrentFrame1 >= anims[animIndex1].keyframeCount * 1.0) animCurrentFrame1 = 0.0;

                // Increment blend factor over time to transition from anim0 --> anim1 over time
                // NOTE: Time blending could be other than linear, using some easing
                animBlendFactor = animBlendTimeCounter/animBlendTime;
                animBlendTimeCounter += GetFrameTime();
                animBlendProgress = animBlendFactor;

                // Update model with animations blending
                if (nextAnimToPlay == 1)
                {
                    // Blend anim0 --> anim1
                    UpdateModelAnimationEx(model, anims[animIndex0], animCurrentFrame0,
                        anims[animIndex1], animCurrentFrame1, animBlendFactor);
                }
                else
                {
                    // Blend anim1 --> anim0
                    UpdateModelAnimationEx(model, anims[animIndex1], animCurrentFrame1,
                        anims[animIndex0], animCurrentFrame0, animBlendFactor);
                }

                // Check if transition completed
                if (animBlendFactor > 1.0)
                {
                    // Reset frame states
                    if (currentAnimPlaying == 0) animCurrentFrame0 = 0.0;
                    else if (currentAnimPlaying == 1) animCurrentFrame1 = 0.0;
                    currentAnimPlaying = nextAnimToPlay; // Update current animation playing

                    animBlendFactor = 0.0; // Reset blend factor
                    animTransition = false; // Exit transition mode
                    animBlendTimeCounter = 0.0;
                }
            }
            else
            {
                // Play only one anim, the current one
                if (currentAnimPlaying == 0)
                {
                    // Playing anim0 at defined speed
                    animCurrentFrame0 += animFrameSpeed0;
                    if (animCurrentFrame0 >= anims[animIndex0].keyframeCount * 1.0) animCurrentFrame0 = 0.0;
                    UpdateModelAnimation(model, anims[animIndex0], animCurrentFrame0);
                    //UpdateModelAnimationEx(model, anims[animIndex0], animCurrentFrame0,
                    //    anims[animIndex1], animCurrentFrame1, 0.0); // Same as above, first animation frame blend
                }
                else if (currentAnimPlaying == 1)
                {
                    // Playing anim1 at defined speed
                    animCurrentFrame1 += animFrameSpeed1;
                    if (animCurrentFrame1 >= anims[animIndex1].keyframeCount * 1.0) animCurrentFrame1 = 0.0;
                    UpdateModelAnimation(model, anims[animIndex1], animCurrentFrame1);
                    //UpdateModelAnimationEx(model, anims[animIndex0], animCurrentFrame0,
                    //    anims[animIndex1], animCurrentFrame1, 1.0); // Same as above, second animation frame blend
                }
            }
        }

        // Update progress bars values with current frame for each animation
        animFrameProgress0 = animCurrentFrame0;
        animFrameProgress1 = animCurrentFrame1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0, WHITE); // Draw animated model

                DrawGrid(10, 1.0);

            EndMode3D();

            if (animTransition) DrawText("ANIM TRANSITION BLENDING!", 170, 50, 30, BLUE);

            // Draw UI elements
            //---------------------------------------------------------------------------------------------
            if (dropdownEditMode0) GuiDisable();
            GuiSlider(Rectangle.{ 10, 38, 160, 12 },
                null, TextFormat("x%.1f", animFrameSpeed0), *animFrameSpeed0, 0.1, 2.0);
            GuiEnable();
            if (dropdownEditMode1) GuiDisable();
            GuiSlider(Rectangle.{ GetScreenWidth() - 170.0, 38, 160, 12 },
                TextFormat("%.1fx", animFrameSpeed1), null, *animFrameSpeed1, 0.1, 2.0);
            GuiEnable();

            // Draw animation selectors for blending transition
            // NOTE: Transition does not start until requested
            GuiSetStyle(.DROPDOWNBOX, cast(s32)GuiDropdownBoxProperty.DROPDOWN_ITEMS_SPACING, 1);
            if (GuiDropdownBox(Rectangle.{ 10, 10, 160, 24 }, TextJoin(animNames.data, animCount, ";"),
                *animIndex0, dropdownEditMode0)) dropdownEditMode0 = !dropdownEditMode0;

            // Blending process progress bar
            if (nextAnimToPlay == 1) GuiSetStyle(.PROGRESSBAR, cast(s32)GuiProgressBarProperty.PROGRESS_SIDE, 0); // Left-->Right
            else GuiSetStyle(.PROGRESSBAR, cast(s32)GuiProgressBarProperty.PROGRESS_SIDE, 1); // Right-->Left
            GuiProgressBar(Rectangle.{ 180, 14, 440, 16 }, null, null, *animBlendProgress, 0.0, 1.0);
            GuiSetStyle(.PROGRESSBAR, cast(s32)GuiProgressBarProperty.PROGRESS_SIDE, 0); // Reset to Left-->Right

            if (GuiDropdownBox(Rectangle.{ GetScreenWidth() - 170.0, 10, 160, 24 }, TextJoin(animNames.data, animCount, ";"),
                *animIndex1, dropdownEditMode1)) dropdownEditMode1 = !dropdownEditMode1;

            // Draw playing timeline with keyframes for anim0[]
            GuiProgressBar(Rectangle.{ 60, GetScreenHeight() - 60.0, GetScreenWidth() - 180.0, 20 }, "ANIM 0",
                TextFormat("FRAME: %.2f / %i", animFrameProgress0, anims[animIndex0].keyframeCount),
                *animFrameProgress0, 0.0, cast(float)anims[animIndex0].keyframeCount);
            for i: 0..anims[animIndex0].keyframeCount-1
                DrawRectangle(60 + cast(s32)((cast(float)(GetScreenWidth() - 180)/cast(float)anims[animIndex0].keyframeCount)*cast(float)i),
                    GetScreenHeight() - 60, 1, 20, BLUE);

            // Draw playing timeline with keyframes for anim1[]
            GuiProgressBar(Rectangle.{ 60, GetScreenHeight() - 30.0, GetScreenWidth() - 180.0, 20 }, "ANIM 1",
                TextFormat("FRAME: %.2f / %i", animFrameProgress1, anims[animIndex1].keyframeCount),
                *animFrameProgress1, 0.0, cast(float)anims[animIndex1].keyframeCount);
            for i: 0..anims[animIndex1].keyframeCount-1
                DrawRectangle(60 + cast(s32)((cast(float)(GetScreenWidth() - 180)/cast(float)anims[animIndex1].keyframeCount)*cast(float)i),
                    GetScreenHeight() - 30, 1, 20, BLUE);
            //---------------------------------------------------------------------------------------------

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(anims, animCount); // Unload model animation
    UnloadModel(model);             // Unload model and meshes/material
    UnloadShader(skinningShader);   // Unload GPU skinning shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
