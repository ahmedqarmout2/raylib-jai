#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAP_SIZE :: 10;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - lightmap");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{4.0, 6.0, 8.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    mesh: Mesh = GenMeshPlane(cast(float)MAP_SIZE, cast(float)MAP_SIZE, 1, 1);

    // GenMeshPlane doesn't generate texcoords2 so we will upload them separately
    mesh.texcoords2 = cast(*float) alloc(mesh.vertexCount*2*size_of(float));

    // X                          // Y
    mesh.texcoords2[0] = 0.0;    mesh.texcoords2[1] = 0.0;
    mesh.texcoords2[2] = 1.0;    mesh.texcoords2[3] = 0.0;
    mesh.texcoords2[4] = 0.0;    mesh.texcoords2[5] = 1.0;
    mesh.texcoords2[6] = 1.0;    mesh.texcoords2[7] = 1.0;

    // Load a new texcoords2 attributes buffer
    mesh.vboId[ShaderLocationIndex.SHADER_LOC_VERTEX_TEXCOORD02] = rlLoadVertexBuffer(mesh.texcoords2, mesh.vertexCount*2*size_of(float), false);
    rlEnableVertexArray(mesh.vaoId);

    // Index 5 is for texcoords2
    rlSetVertexAttribute(5, 2, RL_FLOAT, false, 0, 0);
    rlEnableVertexAttribute(5);
    rlDisableVertexArray();

    // Load lightmap shader
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/lightmap.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/lightmap.fs", GLSL_VERSION));

    texture: Texture = LoadTexture("resources/cubicmap_atlas.png");
    light  : Texture = LoadTexture("resources/spark_flame.png");

    GenTextureMipmaps(*texture);
    SetTextureFilter(texture, .TEXTURE_FILTER_TRILINEAR);

    lightmap: RenderTexture = LoadRenderTexture(MAP_SIZE, MAP_SIZE);

    SetTextureFilter(lightmap.texture, .TEXTURE_FILTER_TRILINEAR);

    material: Material = LoadMaterialDefault();
    material.shader = shader;
    material.maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture    = texture;
    material.maps[MaterialMapIndex.MATERIAL_MAP_METALNESS].texture = lightmap.texture;

    {
        // Drawing to lightmap
        BeginTextureMode(lightmap);
        defer EndTextureMode();

        ClearBackground(BLACK);

        BeginBlendMode(.BLEND_ADDITIVE);
        DrawTexturePro(
            light,
            Rectangle.{0, 0, cast(float)light.width, cast(float)light.height},
            Rectangle.{0, 0, 20, 20},
            Vector2.{10.0, 10.0},
            0.0,
            RED
        );
        DrawTexturePro(
            light,
            Rectangle.{0, 0, cast(float)light.width, cast(float)light.height},
            Rectangle.{8, 4, 20, 20},
            Vector2.{10.0, 10.0},
            0.0,
            BLUE
        );
        DrawTexturePro(
            light,
            Rectangle.{0, 0, cast(float)light.width, cast(float)light.height},
            Rectangle.{8, 8, 10, 10},
            Vector2.{5.0, 5.0},
            0.0,
            GREEN
        );
        BeginBlendMode(.BLEND_ALPHA);
    }

    defer {
        UnloadMesh(mesh);       // Unload the mesh
        UnloadShader(shader);   // Unload shader
        UnloadTexture(texture); // Unload texture
        UnloadTexture(light);   // Unload texture
    };

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginMode3D(camera);
            defer EndMode3D();

            DrawMesh(mesh, material, MatrixIdentity());
        }

        DrawFPS(10, 10);

        DrawTexturePro(
            lightmap.texture,
            Rectangle.{0, 0, -MAP_SIZE, -MAP_SIZE},
            Rectangle.{cast(float)(GetRenderWidth() - MAP_SIZE*8 - 10), 10, MAP_SIZE*8, MAP_SIZE*8},
            Vector2.{0.0, 0.0},
            0.0,
            WHITE);
            
        DrawText("lightmap", GetRenderWidth() - 66, 16 + MAP_SIZE*8, 10, GRAY);
        DrawText("10x10 pixels", GetRenderWidth() - 76, 30 + MAP_SIZE*8, 10, GRAY);
        //----------------------------------------------------------------------------------
    }
}