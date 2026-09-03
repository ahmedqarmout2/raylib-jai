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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - animation blend custom");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 4.0, 4.0, 4.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 1.0, 0.0 };  // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };      // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                            // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;         // Camera projection type

    // Load gltf model
    model: Model = LoadModel("resources/models/gltf/greenman.glb");
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

    // Use specific animation indices: 2-walk/move, 3-attack
    animIndex0: s32 = 2; // Walk/Move animation (index 2)
    animIndex1: s32 = 3; // Attack animation (index 3)
    animCurrentFrame0: s32 = 0;
    animCurrentFrame1: s32 = 0;

    // Validate indices
    if (animIndex0 >= animCount) animIndex0 = 0;
    if (animIndex1 >= animCount) animIndex1 = cast(s32) ifx (animCount > 1) then 1 else 0;

    upperBodyBlend: bool = true;     // Toggle: true = upper/lower body blending, false = uniform blending (50/50)

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Toggle upper/lower body blending mode (SPACE key)
        if (IsKeyPressed(.KEY_SPACE)) upperBodyBlend = !upperBodyBlend;

        // Update animation frames
        anim0: ModelAnimation = anims[animIndex0];
        anim1: ModelAnimation = anims[animIndex1];

        animCurrentFrame0 = (animCurrentFrame0 + 1)%anim0.keyframeCount;
        animCurrentFrame1 = (animCurrentFrame1 + 1)%anim1.keyframeCount;

        // Blend the two animations
        // When upperBodyBlend is ON: upper body = attack (1.0), lower body = walk (0.0)
        // When upperBodyBlend is OFF: uniform blend at 0.5 (50% walk, 50% attack)
        blendFactor: float = (ifx upperBodyBlend then 1.0 else 0.5);
        UpdateModelAnimationBones(*model, *anim0, animCurrentFrame0,
            *anim1, animCurrentFrame1, blendFactor, upperBodyBlend);

        // raylib provided animation blending function
        //UpdateModelAnimationEx(model, anim0, (float)animCurrentFrame0,
        //    anim1, (float)animCurrentFrame1, blendFactor);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0, WHITE);

                DrawGrid(10, 1.0);

            EndMode3D();

            // Draw UI
            DrawText(TextFormat("ANIM 0: %s", anim0.name.data), 10, 10, 20, GRAY);
            DrawText(TextFormat("ANIM 1: %s", anim1.name.data), 10, 40, 20, GRAY);
            DrawText(TextFormat("[SPACE] Toggle blending mode: %s",
                temp_c_string(ifx upperBodyBlend then "Upper/Lower Body Blending" else "Uniform Blending")),
                10, GetScreenHeight() - 30, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModelAnimations(anims, animCount); // Unload model animation
    UnloadModel(model);    // Unload model and meshes/material
    UnloadShader(skinningShader);   // Unload GPU skinning shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Check if a bone is part of upper body (for selective blending)
IsUpperBodyBone :: (boneName: *u8) -> bool
{
    // Common upper body bone names (adjust based on your model)
    if (TextIsEqual(boneName, "spine") || TextIsEqual(boneName, "spine1") || TextIsEqual(boneName, "spine2") ||
        TextIsEqual(boneName, "chest") || TextIsEqual(boneName, "upperChest") ||
        TextIsEqual(boneName, "neck") || TextIsEqual(boneName, "head") ||
        TextIsEqual(boneName, "shoulder") || TextIsEqual(boneName, "shoulder_L") || TextIsEqual(boneName, "shoulder_R") ||
        TextIsEqual(boneName, "upperArm") || TextIsEqual(boneName, "upperArm_L") || TextIsEqual(boneName, "upperArm_R") ||
        TextIsEqual(boneName, "lowerArm") || TextIsEqual(boneName, "lowerArm_L") || TextIsEqual(boneName, "lowerArm_R") ||
        TextIsEqual(boneName, "hand") || TextIsEqual(boneName, "hand_L") || TextIsEqual(boneName, "hand_R") ||
        TextIsEqual(boneName, "clavicle") || TextIsEqual(boneName, "clavicle_L") || TextIsEqual(boneName, "clavicle_R"))
    {
        return true;
    }

    // Check if bone name contains upper body keywords
    if (strstr(boneName, "spine") != null || strstr(boneName, "chest") != null ||
        strstr(boneName, "neck") != null || strstr(boneName, "head") != null ||
        strstr(boneName, "shoulder") != null || strstr(boneName, "arm") != null ||
        strstr(boneName, "hand") != null || strstr(boneName, "clavicle") != null)
    {
        return true;
    }

    return false;
}

// Blend two animations per-bone with selective upper/lower body blending
UpdateModelAnimationBones :: (model: *Model, anim0: *ModelAnimation, frame0: s32,
    anim1: *ModelAnimation, frame1: s32, blend: float, upperBodyBlend: bool)
{
    // Validate inputs
    if ((anim0.boneCount != 0) && (anim0.keyframePoses != null) &&
        (anim1.boneCount != 0) && (anim1.keyframePoses != null) &&
        (model.skeleton.boneCount != 0) && (model.skeleton.bindPose != null))
    {
        // Clamp blend factor to [0, 1]
        blend = min(1.0, max(0.0, blend));

        // Ensure frame indices are valid
        if (frame0 >= anim0.keyframeCount) frame0 = anim0.keyframeCount - 1;
        if (frame1 >= anim1.keyframeCount) frame1 = anim1.keyframeCount - 1;
        if (frame0 < 0) frame0 = 0;
        if (frame1 < 0) frame1 = 0;

        // Get bone count (use minimum of all to be safe)
        boneCount: s32 = model.skeleton.boneCount;
        if (anim0.boneCount < boneCount) boneCount = anim0.boneCount;
        if (anim1.boneCount < boneCount) boneCount = anim1.boneCount;

        // Blend each bone
        for boneIndex: 0..boneCount-1
        {
            // Determine blend factor for this bone
            boneBlendFactor: float = blend;

            // If upper body blending is enabled, use different blend factors for upper vs lower body
            if (upperBodyBlend)
            {
                boneName: *u8 = model.skeleton.bones[boneIndex].name.data;
                isUpperBody: bool = IsUpperBodyBone(boneName);

                // Upper body: use anim1 (attack), Lower body: use anim0 (walk)
                // blend = 0.0 means full anim0 (walk), 1.0 means full anim1 (attack)
                if (isUpperBody) boneBlendFactor = blend; // Upper body: blend towards anim1 (attack)
                else boneBlendFactor = 1.0 - blend; // Lower body: blend towards anim0 (walk) - invert the blend
            }

            // Get transforms from both animations
            bindTransform: *Transform = *model.skeleton.bindPose[boneIndex];
            animTransform0: *Transform = *anim0.keyframePoses[frame0][boneIndex];
            animTransform1: *Transform = *anim1.keyframePoses[frame1][boneIndex];

            // Blend the transforms
            blended: Transform;
            blended.translation = Vector3Lerp(animTransform0.translation, animTransform1.translation, boneBlendFactor);
            blended.rotation = QuaternionSlerp(animTransform0.rotation, animTransform1.rotation, boneBlendFactor);
            blended.scale = Vector3Lerp(animTransform0.scale, animTransform1.scale, boneBlendFactor);

            // Convert bind pose to matrix
            bindMatrix: Matrix4 = MatrixMultiply(MatrixMultiply(
                MatrixScale(bindTransform.scale.x, bindTransform.scale.y, bindTransform.scale.z),
                QuaternionToMatrix(bindTransform.rotation)),
                MatrixTranslate(bindTransform.translation.x, bindTransform.translation.y, bindTransform.translation.z));

            // Convert blended transform to matrix
            blendedMatrix: Matrix4 = MatrixMultiply(MatrixMultiply(
                MatrixScale(blended.scale.x, blended.scale.y, blended.scale.z),
                QuaternionToMatrix(blended.rotation)),
                MatrixTranslate(blended.translation.x, blended.translation.y, blended.translation.z));

            // Calculate final bone matrix (similar to UpdateModelAnimationBones)
            model.boneMatrices[boneIndex] = MatrixMultiply(MatrixInvert(bindMatrix), blendedMatrix);
        }

        // CPU skinning, updates CPU buffers and uploads them to GPU (if available)
        // NOTE: Fallback in case GPU skinning is not supported or enabled
        for m: 0..model.meshCount-1
        {
            mesh: Mesh = model.meshes[m];
            animVertex: Vector3;
            animNormal: Vector3;
            vertexValuesCount: s32 = mesh.vertexCount*3;

            boneIndex: s32 = 0;
            boneCounter: s32 = 0;
            boneWeight: float = 0.0;
            bufferUpdateRequired: bool = false; // Flag to check when anim vertex information is updated

            // Skip if missing bone data or missing anim buffers initialization
            if ((mesh.boneWeights == null) || (mesh.boneIndices == null) ||
                (mesh.animVertices == null) || (mesh.animNormals == null)) continue;

            vCounter: s32 = 0;
            while (vCounter < vertexValuesCount)
            {
                defer vCounter += 3;

                mesh.animVertices[vCounter] = 0;
                mesh.animVertices[vCounter + 1] = 0;
                mesh.animVertices[vCounter + 2] = 0;
                if (mesh.animNormals != null)
                {
                    mesh.animNormals[vCounter] = 0;
                    mesh.animNormals[vCounter + 1] = 0;
                    mesh.animNormals[vCounter + 2] = 0;
                }

                // Iterates over 4 bones per vertex
                j: s32 = 0;
                while (j < 4)
                {
                    defer j += 1;
                    defer boneCounter += 1;

                    boneWeight = mesh.boneWeights[boneCounter];
                    boneIndex = mesh.boneIndices[boneCounter];

                    // Early stop when no transformation will be applied
                    if (boneWeight == 0.0) continue;
                    animVertex = Vector3.{ mesh.vertices[vCounter], mesh.vertices[vCounter + 1], mesh.vertices[vCounter + 2] };
                    animVertex = Vector3Transform(animVertex, model.boneMatrices[boneIndex]);
                    mesh.animVertices[vCounter] += animVertex.x*boneWeight;
                    mesh.animVertices[vCounter + 1] += animVertex.y*boneWeight;
                    mesh.animVertices[vCounter + 2] += animVertex.z*boneWeight;
                    bufferUpdateRequired = true;

                    // Normals processing
                    // NOTE: We use meshes.baseNormals (default normal) to calculate meshes.normals (animated normals)
                    if ((mesh.normals != null) && (mesh.animNormals != null ))
                    {
                        animNormal = Vector3.{ mesh.normals[vCounter], mesh.normals[vCounter + 1], mesh.normals[vCounter + 2] };
                        animNormal = Vector3Transform(animNormal, MatrixTranspose(MatrixInvert(model.boneMatrices[boneIndex])));
                        mesh.animNormals[vCounter] += animNormal.x*boneWeight;
                        mesh.animNormals[vCounter + 1] += animNormal.y*boneWeight;
                        mesh.animNormals[vCounter + 2] += animNormal.z*boneWeight;
                    }
                }
            }

            if (bufferUpdateRequired)
            {
                // Update GPU vertex buffers with updated data (position + normals)
                rlUpdateVertexBuffer(mesh.vboId[ShaderLocationIndex.SHADER_LOC_VERTEX_POSITION], mesh.animVertices, mesh.vertexCount*3*size_of(float), 0);
                if (mesh.normals != null) rlUpdateVertexBuffer(mesh.vboId[ShaderLocationIndex.SHADER_LOC_VERTEX_NORMAL], mesh.animNormals, mesh.vertexCount*3*size_of(float), 0);
            }
        }
    }
}

