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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - normalmap rendering");

    camera: Camera;
    camera.position = Vector3.{ 0.0, 2.0, -4.0 };
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Load basic normal map lighting shader
    shader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/normalmap.vs", GLSL_VERSION),
                               TextFormat("resources/shaders/glsl%i/normalmap.fs", GLSL_VERSION));

    // Get some required shader locations
    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_NORMAL] = GetShaderLocation(shader, "normalMap");
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");

    // NOTE: "matModel" location name is automatically assigned on shader loading,
    // no need to get the location again if using that uniform name
    // shader.locs[SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");

    // This example uses just 1 point light
    lightPosition: Vector3 = .{ 0.0, 1.0, 0.0 };
    lightPosLoc: s32 = GetShaderLocation(shader, "lightPos");

    // Load a plane model that has proper normals and tangents
    plane: Model = LoadModel("resources/models/plane.glb");

    // Set the plane model's shader and texture maps
    plane.materials[0].shader = shader;
    plane.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = LoadTexture("resources/tiles_diffuse.png");
    plane.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_NORMAL].texture = LoadTexture("resources/tiles_normal.png");

    // Generate Mipmaps and use TRILINEAR filtering to help with texture aliasing
    GenTextureMipmaps(*plane.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture);
    GenTextureMipmaps(*plane.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_NORMAL].texture);

    SetTextureFilter(plane.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture, .TEXTURE_FILTER_TRILINEAR);
    SetTextureFilter(plane.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_NORMAL].texture, .TEXTURE_FILTER_TRILINEAR);

    // Specular exponent AKA shininess of the material
    specularExponent: float = 8.0;
    specularExponentLoc: s32 = GetShaderLocation(shader, "specularExponent");

    // Allow toggling the normal map on and off for comparison purposes
    useNormalMap: bool = true;
    useNormalMapLoc: s32 = GetShaderLocation(shader, "useNormalMap");

    SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Move the light around on the X and Z axis using WASD keys
        direction: Vector3;
        if (IsKeyDown(.KEY_W)) direction = Vector3Add(direction, Vector3.{ 0.0, 0.0, 1.0 });
        if (IsKeyDown(.KEY_S)) direction = Vector3Add(direction, Vector3.{ 0.0, 0.0, -1.0 });
        if (IsKeyDown(.KEY_D)) direction = Vector3Add(direction, Vector3.{ -1.0, 0.0, 0.0 });
        if (IsKeyDown(.KEY_A)) direction = Vector3Add(direction, Vector3.{ 1.0, 0.0, 0.0 });

        direction = Vector3Normalize(direction);
        lightPosition = Vector3Add(lightPosition, Vector3Scale(direction, GetFrameTime()*3.0));

        // Increase/Decrease the specular exponent(shininess)
        if (IsKeyDown(.KEY_UP)) specularExponent = Clamp(specularExponent + 40.0*GetFrameTime(), 2.0, 128.0);
        if (IsKeyDown(.KEY_DOWN)) specularExponent = Clamp(specularExponent - 40.0*GetFrameTime(), 2.0, 128.0);

        // Toggle normal map on and off
        if (IsKeyPressed(.KEY_N)) useNormalMap = !useNormalMap;

        // Spin plane model at a constant rate
        plane.transform = MatrixRotateY(cast(float)GetTime()*0.5);

        // Update shader values
        lightPos: [3]float = .[lightPosition.x, lightPosition.y, lightPosition.z];
        SetShaderValue(shader, lightPosLoc, *lightPos, .SHADER_UNIFORM_VEC3);

        camPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *camPos, .SHADER_UNIFORM_VEC3);

        SetShaderValue(shader, specularExponentLoc, *specularExponent, .SHADER_UNIFORM_FLOAT);

        SetShaderValue(shader, useNormalMapLoc, *useNormalMap, .SHADER_UNIFORM_INT);
        //--------------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                BeginShaderMode(shader);

                    DrawModel(plane, Vector3Zero(), 2.0, WHITE);

                EndShaderMode();

                // Draw sphere to show light position
                DrawSphereWires(lightPosition, 0.2, 8, 8, ORANGE);

            EndMode3D();

            textColor: Color = ifx (useNormalMap) then DARKGREEN else RED;
            toggleStr: *u8 = temp_c_string(ifx (useNormalMap) then "On" else "Off");
            DrawText(TextFormat("Use key [N] to toggle normal map: %s", toggleStr), 10, 10, 10, textColor);

            yOffset: s32 = 24;
            DrawText("Use keys [W][A][S][D] to move the light", 10, 10 + yOffset*1, 10, BLACK);
            DrawText("Use keys [Up][Down] to change specular exponent", 10, 10 + yOffset*2, 10, BLACK);
            DrawText(TextFormat("Specular Exponent: %.2f", specularExponent), 10, 10 + yOffset*3, 10, BLUE);

            DrawFPS(screenWidth - 90, 10);

        EndDrawing();
        //--------------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);
    UnloadModel(plane);

    CloseWindow(); // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
