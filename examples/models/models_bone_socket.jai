#import "raylib";
#import "Basic";
#import "Math";

BONE_SOCKETS       :: 3;
BONE_SOCKET_HAT    :: 0;
BONE_SOCKET_HAND_R :: 1;
BONE_SOCKET_HAND_L :: 2;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - bone socket");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{5.0, 5.0, 5.0}; // Camera position
    camera.target     = Vector3.{0.0, 2.0, 0.0}; // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0}; // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                    // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;     // Camera projection type

    // Load gltf model
    characterModel: Model = LoadModel("resources/models/gltf/greenman.glb"); // Load character model
    equipModel: [BONE_SOCKETS]Model = .[
        LoadModel("resources/models/gltf/greenman_hat.glb"),    // Index for the hat model is the same as BONE_SOCKET_HAT
        LoadModel("resources/models/gltf/greenman_sword.glb"),  // Index for the sword model is the same as BONE_SOCKET_HAND_R
        LoadModel("resources/models/gltf/greenman_shield.glb")  // Index for the shield model is the same as BONE_SOCKET_HAND_L
    ];

    showEquip: [3]bool = .[true, true, true];   // Toggle on/off equip

    // Load gltf model animations
    animsCount: s32 = 0;
    animIndex : s32 = 0;
    animCurrentFrame: s32 = 0;
    modelAnimations: *ModelAnimation = LoadModelAnimations("resources/models/gltf/greenman.glb", *animsCount);

    // indices of bones for sockets
    boneSocketIndex: [BONE_SOCKETS]s32 = .[-1, -1, -1];

    // search bones for sockets 
    for i: 0..characterModel.boneCount-1 {
        if (TextIsEqual(characterModel.bones[i].name.data, "socket_hat")) {
            boneSocketIndex[BONE_SOCKET_HAT] = i;
            continue;
        }
        
        if (TextIsEqual(characterModel.bones[i].name.data, "socket_hand_R")) {
            boneSocketIndex[BONE_SOCKET_HAND_R] = i;
            continue;
        }
        
        if (TextIsEqual(characterModel.bones[i].name.data, "socket_hand_L")) {
            boneSocketIndex[BONE_SOCKET_HAND_L] = i;
            continue;
        }
    }

    position: Vector3 = .{0.0, 0.0, 0.0}; // Set model position
    angle: u16 = 0;           // Set angle for rotate character

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {       // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_THIRD_PERSON);
        
        // Rotate character
        if (IsKeyDown(.KEY_F)) angle = cast(u16)((angle + 1)%360);
        else if (IsKeyDown(.KEY_H)) angle = cast(u16)((360 + angle - 1)%360);

        // Select current animation
        if (IsKeyPressed(.KEY_T)) animIndex = (animIndex + 1)%animsCount;
        else if (IsKeyPressed(.KEY_G)) animIndex = (animIndex + animsCount - 1)%animsCount;

        // Toggle shown of equip
        if (IsKeyPressed(.KEY_ONE)) showEquip[BONE_SOCKET_HAT] = !showEquip[BONE_SOCKET_HAT];
        if (IsKeyPressed(.KEY_TWO)) showEquip[BONE_SOCKET_HAND_R] = !showEquip[BONE_SOCKET_HAND_R];
        if (IsKeyPressed(.KEY_THREE)) showEquip[BONE_SOCKET_HAND_L] = !showEquip[BONE_SOCKET_HAND_L];
        
        // Update model animation
        anim: ModelAnimation = modelAnimations[animIndex];
        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
        UpdateModelAnimation(characterModel, anim, animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                // Draw character
                characterRotate: Quaternion = QuaternionFromAxisAngle(Vector3.{0.0, 1.0, 0.0}, angle*DEG2RAD);
                characterModel.transform = MatrixMultiply(QuaternionToMatrix(characterRotate), MatrixTranslate(position.x, position.y, position.z));
                UpdateModelAnimation(characterModel, anim, animCurrentFrame);
                DrawMesh(characterModel.meshes[0], characterModel.materials[1], characterModel.transform);

                // Draw equipments (hat, sword, shield)
                for i: 0..BONE_SOCKETS-1 {
                    if (!showEquip[i]) continue;

                    transform: *Transform = *anim.framePoses[animCurrentFrame][boneSocketIndex[i]];
                    inRotation: Quaternion = characterModel.bindPose[boneSocketIndex[i]].rotation;
                    outRotation: Quaternion  = transform.rotation;
                    
                    // Calculate socket rotation (angle between bone in initial pose and same bone in current animation frame)
                    rotate: Quaternion = QuaternionMultiply(outRotation, QuaternionInvert(inRotation));
                    matrixTransform: Matrix4  = QuaternionToMatrix(rotate);
                    // Translate socket to its position in the current animation
                    matrixTransform = MatrixMultiply(matrixTransform, MatrixTranslate(transform.translation.x, transform.translation.y, transform.translation.z));
                    // Transform the socket using the transform of the character (angle and translate)
                    matrixTransform = MatrixMultiply(matrixTransform, characterModel.transform);
                    
                    // Draw mesh at socket position with socket angle rotation
                    DrawMesh(equipModel[i].meshes[0], equipModel[i].materials[1], matrixTransform);
                }

                DrawGrid(10, 1.0);
            EndMode3D();

            DrawText("Use the T/G to switch animation", 10, 10, 20, GRAY);
            DrawText("Use the F/H to rotate character left/right", 10, 35, 20, GRAY);
            DrawText("Use the 1,2,3 to toggle shown of hat, sword and shield", 10, 60, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(modelAnimations, animsCount);
    UnloadModel(characterModel);         // Unload character model and meshes/material
    
    // Unload equipment model and meshes/material
    for i: 0..BONE_SOCKETS-1 UnloadModel(equipModel[i]);

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
