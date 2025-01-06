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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - skybox loading and drawing");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 1.0, 1.0, 1.0 };    // Camera position
    camera.target = Vector3.{ 4.0, 1.0, 4.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    // Load skybox model
    cube: Mesh = GenMeshCube(1.0, 1.0, 1.0);
    skybox: Model = LoadModelFromMesh(cube);

    // Set this to true to use an HDR Texture, Note that raylib must be built with HDR Support for this to work SUPPORT_FILEFORMAT_HDR
    useHDR: bool = false;

    // Load skybox shader and set required locations
    // NOTE: Some locations are automatically set at shader loading
    skybox.materials[0].shader = LoadShader(TextFormat("resources/shaders/glsl%i/skybox.vs", GLSL_VERSION),
                                            TextFormat("resources/shaders/glsl%i/skybox.fs", GLSL_VERSION));

    value: s32 = cast(s32)(ifx useHDR then 1 else 0);
    SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "environmentMap"), *(s32.[cast(s32)MaterialMapIndex.MATERIAL_MAP_CUBEMAP]), .SHADER_UNIFORM_INT);
    SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "doGamma"), *(s32.[value]), .SHADER_UNIFORM_INT);
    SetShaderValue(skybox.materials[0].shader, GetShaderLocation(skybox.materials[0].shader, "vflipped"), *(s32.[value]), .SHADER_UNIFORM_INT);

    // Load cubemap shader and setup required shader locations
    shdrCubemap: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/cubemap.vs", GLSL_VERSION),
                                    TextFormat("resources/shaders/glsl%i/cubemap.fs", GLSL_VERSION));

    SetShaderValue(shdrCubemap, GetShaderLocation(shdrCubemap, "equirectangularMap"), *(s32.[0]), .SHADER_UNIFORM_INT);

    skyboxFileName: [256]u8;
    
    if (useHDR)
    {
        TextCopy(skyboxFileName.data, "resources/dresden_square_2k.hdr");

        // Load HDR panorama (sphere) texture
        panorama: Texture2D = LoadTexture(skyboxFileName.data);

        // Generate cubemap (texture with 6 quads-cube-mapping) from panorama HDR texture
        // NOTE 1: New texture is generated rendering to texture, shader calculates the sphere->cube coordinates mapping
        // NOTE 2: It seems on some Android devices WebGL, fbo does not properly support a FLOAT-based attachment,
        // despite texture can be successfully created.. so using PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 instead of PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture = GenTextureCubemap(shdrCubemap, panorama, 1024, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);

        UnloadTexture(panorama);        // Texture not required anymore, cubemap already generated
    }
    else
    {
        img: Image = LoadImage("resources/skybox.png");
        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture = LoadTextureCubemap(img, .CUBEMAP_LAYOUT_AUTO_DETECT);    // CUBEMAP_LAYOUT_PANORAMA
        UnloadImage(img);
    }

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);

        // Load new cubemap texture on drag&drop
        if (IsFileDropped())
        {
            droppedFiles: FilePathList = LoadDroppedFiles();

            if (droppedFiles.count == 1)         // Only support one file dropped
            {
                if (IsFileExtension(droppedFiles.paths[0], ".png;.jpg;.hdr;.bmp;.tga"))
                {
                    // Unload current cubemap texture to load new one
                    UnloadTexture(skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture);
                    
                    if (useHDR)
                    {
                        // Load HDR panorama (sphere) texture
                        panorama: Texture2D = LoadTexture(droppedFiles.paths[0]);

                        // Generate cubemap from panorama texture
                        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture = GenTextureCubemap(shdrCubemap, panorama, 1024, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
                        
                        UnloadTexture(panorama);    // Texture not required anymore, cubemap already generated
                    }
                    else
                    {
                        img: Image = LoadImage(droppedFiles.paths[0]);
                        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture = LoadTextureCubemap(img, .CUBEMAP_LAYOUT_AUTO_DETECT);
                        UnloadImage(img);
                    }

                    TextCopy(skyboxFileName.data, droppedFiles.paths[0]);
                }
            }

            UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // We are inside the cube, we need to disable backface culling!
                rlDisableBackfaceCulling();
                rlDisableDepthMask();
                    DrawModel(skybox, Vector3.{0, 0, 0}, 1.0, WHITE);
                rlEnableBackfaceCulling();
                rlEnableDepthMask();

                DrawGrid(10, 1.0);

            EndMode3D();

            if (useHDR) DrawText(TextFormat("Panorama image from hdrihaven.com: %s", GetFileName(skyboxFileName.data)), 10, GetScreenHeight() - 20, 10, BLACK);
            else DrawText(TextFormat(": %s", GetFileName(skyboxFileName.data)), 10, GetScreenHeight() - 20, 10, BLACK);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(skybox.materials[0].shader);
    UnloadTexture(skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture);

    UnloadModel(skybox);        // Unload skybox model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

// Generate cubemap texture from HDR texture
GenTextureCubemap :: (shader: Shader, panorama: Texture2D, size: s32, format: PixelFormat) -> TextureCubemap
{
    cubemap: TextureCubemap;

    rlDisableBackfaceCulling();     // Disable backface culling to render inside the cube

    // STEP 1: Setup framebuffer
    //------------------------------------------------------------------------------------------
    rbo: u32 = rlLoadTextureDepth(size, size, true);
    cubemap.id = rlLoadTextureCubemap(null, size, format, 1);

    fbo: u32 = rlLoadFramebuffer();
    rlFramebufferAttach(fbo, rbo, .RL_ATTACHMENT_DEPTH, .RL_ATTACHMENT_RENDERBUFFER, 0);
    rlFramebufferAttach(fbo, cubemap.id, .RL_ATTACHMENT_COLOR_CHANNEL0, .RL_ATTACHMENT_CUBEMAP_POSITIVE_X, 0);

    // Check if framebuffer is complete with attachments (valid)
    if (rlFramebufferComplete(fbo)) TraceLog(.LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", fbo);
    //------------------------------------------------------------------------------------------

    // STEP 2: Draw to framebuffer
    //------------------------------------------------------------------------------------------
    // NOTE: Shader is used to convert HDR equirectangular environment map to cubemap equivalent (6 faces)
    rlEnableShader(shader.id);

    // Define projection matrix and send it to shader
    matFboProjection: Matrix4 = MatrixPerspective(90.0*DEG2RAD, 1.0, rlGetCullDistanceNear(), rlGetCullDistanceFar());
    rlSetUniformMatrix(shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_PROJECTION], matFboProjection);

    // Define view matrix for every side of the cubemap
    fboViews: [6]Matrix4 = .[
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{  1.0,  0.0,  0.0 }, Vector3.{ 0.0, -1.0,  0.0 }),
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{ -1.0,  0.0,  0.0 }, Vector3.{ 0.0, -1.0,  0.0 }),
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{  0.0,  1.0,  0.0 }, Vector3.{ 0.0,  0.0,  1.0 }),
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{  0.0, -1.0,  0.0 }, Vector3.{ 0.0,  0.0, -1.0 }),
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{  0.0,  0.0,  1.0 }, Vector3.{ 0.0, -1.0,  0.0 }),
        MatrixLookAt(Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{  0.0,  0.0, -1.0 }, Vector3.{ 0.0, -1.0,  0.0 })
    ];

    rlViewport(0, 0, size, size);   // Set viewport to current fbo dimensions
    
    // Activate and enable texture for drawing to cubemap faces
    rlActiveTextureSlot(0);
    rlEnableTexture(panorama.id);

    for i: 0..5
    {
        // Set the view matrix for the current cube face
        rlSetUniformMatrix(shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_VIEW], fboViews[i]);
        
        // Select the current cubemap face attachment for the fbo
        // WARNING: This function by default enables->attach->disables fbo!!!
        rlFramebufferAttach(fbo, cubemap.id, .RL_ATTACHMENT_COLOR_CHANNEL0, cast(rlFramebufferAttachTextureType)((cast(s32) rlFramebufferAttachTextureType.RL_ATTACHMENT_CUBEMAP_POSITIVE_X) + i), 0);
        rlEnableFramebuffer(fbo);

        // Load and draw a cube, it uses the current enabled texture
        rlClearScreenBuffers();
        rlLoadDrawCube();

        // ALTERNATIVE: Try to use internal batch system to draw the cube instead of rlLoadDrawCube
        // for some reason this method does not work, maybe due to cube triangles definition? normals pointing out?
        // TODO: Investigate this issue...
        //rlSetTexture(panorama.id); // WARNING: It must be called after enabling current framebuffer if using internal batch system!
        //rlClearScreenBuffers();
        //DrawCubeV(Vector3Zero(), Vector3One(), WHITE);
        //rlDrawRenderBatchActive();
    }
    //------------------------------------------------------------------------------------------

    // STEP 3: Unload framebuffer and reset state
    //------------------------------------------------------------------------------------------
    rlDisableShader();          // Unbind shader
    rlDisableTexture();         // Unbind texture
    rlDisableFramebuffer();     // Unbind framebuffer
    rlUnloadFramebuffer(fbo);   // Unload framebuffer (and automatically attached depth texture/renderbuffer)

    // Reset viewport dimensions to default
    rlViewport(0, 0, rlGetFramebufferWidth(), rlGetFramebufferHeight());
    rlEnableBackfaceCulling();
    //------------------------------------------------------------------------------------------

    cubemap.width = size;
    cubemap.height = size;
    cubemap.mipmaps = 1;
    cubemap.format = format;

    return cubemap;
}
