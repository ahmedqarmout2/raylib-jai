#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - GPU skinning");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 5.0, 5.0, 5.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };  // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };      // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                            // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;         // Camera projection type

    // Load gltf model
    characterModel: Model = LoadModel("resources/models/gltf/greenman.glb"); // Load character model
    
    // Load skinning shader
    skinningShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/skinning.vs", GLSL_VERSION),
                                       TextFormat("resources/shaders/glsl%i/skinning.fs", GLSL_VERSION));
    
    characterModel.materials[1].shader = skinningShader;
    
    // Load gltf model animations
    animsCount: s32 = 0;
    animIndex: s32 = 0;
    animCurrentFrame: s32 = 0;
    modelAnimations: *ModelAnimation = LoadModelAnimations("resources/models/gltf/greenman.glb", *animsCount);

    position: Vector3 = .{ 0.0, 0.0, 0.0 }; // Set model position

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_THIRD_PERSON);
        
        // Select current animation
        if (IsKeyPressed(.KEY_T)) animIndex = (animIndex + 1)%animsCount;
        else if (IsKeyPressed(.KEY_G)) animIndex = (animIndex + animsCount - 1)%animsCount;

        // Update model animation
        anim: ModelAnimation = modelAnimations[animIndex];
        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
        characterModel.transform = MatrixTranslate(position.x, position.y, position.z);
        UpdateModelAnimationBones(characterModel, anim, animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
            
                // Draw character mesh, pose calculation is done in shader (GPU skinning)
                DrawMesh(characterModel.meshes[0], characterModel.materials[1], characterModel.transform);

                DrawGrid(10, 1.0);
                
            EndMode3D();

            DrawText("Use the T/G to switch animation", 10, 10, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(modelAnimations, animsCount); // Unload model animation
    UnloadModel(characterModel);    // Unload model and meshes/material
    UnloadShader(skinningShader);   // Unload GPU skinning shader
    
    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}