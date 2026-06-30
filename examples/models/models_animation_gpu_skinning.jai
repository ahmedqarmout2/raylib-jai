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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - animation gpu skinning");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 5.0, 5.0, 5.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };  // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };      // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                            // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;         // Camera projection type

    // Load gltf model
    model: Model = LoadModel("resources/models/gltf/greenman.glb"); // Load character model
    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position

    // Load skinning shader
    // WARNING: GPU skinning must be enabled in raylib with a compilation flag,
    // if not enabled, CPU skinning will be used instead
    skinningShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/skinning.vs", GLSL_VERSION),
                                       TextFormat("resources/shaders/glsl%i/skinning.fs", GLSL_VERSION));
    model.materials[1].shader = skinningShader;

    // Load gltf model animations
    animCount: s32 = 0;
    anims: *ModelAnimation = LoadModelAnimations("resources/models/gltf/greenman.glb", *animCount);

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
        UpdateCamera(*camera, .CAMERA_THIRD_PERSON);
        
        // Select current animation
        if (IsKeyPressed(.KEY_T)) animIndex = (animIndex + 1)%animCount;
        else if (IsKeyPressed(.KEY_G)) animIndex = (animIndex + animCount - 1)%animCount;

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
            DrawText("Use the T/G to switch animation", 10, 10, 20, GRAY);

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