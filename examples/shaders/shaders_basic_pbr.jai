#import "raylib";
#import "Basic";
#import "Math";

#load "shared/rlights.jai";

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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic pbr");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{2.0, 2.0, 6.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.5, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load basic lighting shader
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/pbr.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/pbr.fs", GLSL_VERSION));
    defer UnloadShader(shader);   // Unload shader

    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_ALBEDO] = GetShaderLocation(shader, "albedoMap");
    // WARNING: Metalness, roughness, and ambient occlusion are all packed into a MRA texture
    // They are passed as to the SHADER_LOC_MAP_METALNESS location for convenience,
    // shader already takes care of it accordingly
    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_METALNESS] = GetShaderLocation(shader, "mraMap");
    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_NORMAL] = GetShaderLocation(shader, "normalMap");
    // WARNING: Similar to the MRA map, the emissive map packs different information 
    // into a single texture: it stores height and emission data
    // It is binded to SHADER_LOC_MAP_EMISSION location an properly processed on shader
    shader.locs[ShaderLocationIndex.SHADER_LOC_MAP_EMISSION] = GetShaderLocation(shader, "emissiveMap");
    shader.locs[ShaderLocationIndex.SHADER_LOC_COLOR_DIFFUSE] = GetShaderLocation(shader, "albedoColor");

    // Setup additional required shader locations, including lights data
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(shader, "viewPos");
    lightCountLoc: s32 = GetShaderLocation(shader, "numOfLights");
    maxLightCount: s32 = MAX_LIGHTS;
    SetShaderValue(shader, lightCountLoc, *maxLightCount, .SHADER_UNIFORM_INT);

    // Setup ambient color and intensity parameters
    ambientIntensity: float = 0.02;
    ambientColor: Color = Color.{26, 32, 135, 255};
    ambientColorNormalized: Vector3 = Vector3.{ambientColor.r/255.0, ambientColor.g/255.0, ambientColor.b/255.0};
    SetShaderValue(shader, GetShaderLocation(shader, "ambientColor"), *ambientColorNormalized, .SHADER_UNIFORM_VEC3);
    SetShaderValue(shader, GetShaderLocation(shader, "ambient")     , *ambientIntensity, .SHADER_UNIFORM_FLOAT);

    // Get location for shader parameters that can be modified in real time
    emissiveIntensityLoc : s32 = GetShaderLocation(shader, "emissivePower");
    emissiveColorLoc     : s32 = GetShaderLocation(shader, "emissiveColor");
    textureTilingLoc     : s32 = GetShaderLocation(shader, "tiling");

    // Load old car model using PBR maps and shader
    // WARNING: We know this model consists of a single model.meshes[0] and
    // that model.materials[0] is by default assigned to that mesh
    // There could be more complex models consisting of multiple meshes and
    // multiple materials defined for those meshes... but always 1 mesh = 1 material
    car: Model = LoadModel("resources/models/old_car_new.glb");

    // Assign already setup PBR shader to model.materials[0], used by models.meshes[0]
    car.materials[0].shader = shader;

    // Setup materials[0].maps default parameters
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].color    = WHITE;
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_METALNESS].value = 0.0;
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ROUGHNESS].value = 0.0;
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_OCCLUSION].value = 1.0;
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].color  = Color.{255, 162, 0, 255};

    // Setup materials[0].maps default textures
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture    = LoadTexture("resources/old_car_d.png");
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_METALNESS].texture = LoadTexture("resources/old_car_mra.png");
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_NORMAL].texture    = LoadTexture("resources/old_car_n.png");
    car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].texture  = LoadTexture("resources/old_car_e.png");
    
    // Load floor model mesh and assign material parameters
    // NOTE: A basic plane shape can be generated instead of being loaded from a model file
    floor: Model = LoadModel("resources/models/plane.glb");
    //Mesh floorMesh = GenMeshPlane(10, 10, 10, 10);
    //GenMeshTangents(&floorMesh);      // TODO: Review tangents generation
    //Model floor = LoadModelFromMesh(floorMesh);

    // Assign material shader for our floor model, same PBR shader 
    floor.materials[0].shader = shader;
    
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].color    = WHITE;
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_METALNESS].value = 0.0;
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ROUGHNESS].value = 0.0;
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_OCCLUSION].value = 1.0;
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].color  = BLACK;

    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_ALBEDO].texture    = LoadTexture("resources/road_a.png");
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_METALNESS].texture = LoadTexture("resources/road_mra.png");
    floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_NORMAL].texture    = LoadTexture("resources/road_n.png");

    // Models texture tiling parameter can be stored in the Material struct if required (CURRENTLY NOT USED)
    // NOTE: Material.params[4] are available for generic parameters storage (float)
    carTextureTiling   : Vector2 = Vector2.{0.5, 0.5};
    floorTextureTiling : Vector2 = Vector2.{0.5, 0.5};

    // Create some lights
    lights: [MAX_LIGHTS]Light;
    lights[0] = CreateLight(.LIGHT_POINT, Vector3.{-1.0, 1.0, -2.0}, Vector3.{0.0, 0.0, 0.0}, YELLOW, 4.0, shader);
    lights[1] = CreateLight(.LIGHT_POINT, Vector3.{ 2.0, 1.0,  1.0}, Vector3.{0.0, 0.0, 0.0}, GREEN , 3.3, shader);
    lights[2] = CreateLight(.LIGHT_POINT, Vector3.{-2.0, 1.0,  1.0}, Vector3.{0.0, 0.0, 0.0}, RED   , 8.3, shader);
    lights[3] = CreateLight(.LIGHT_POINT, Vector3.{ 1.0, 1.0, -2.0}, Vector3.{0.0, 0.0, 0.0}, BLUE  , 2.0, shader);

    // Setup material texture maps usage in shader
    // NOTE: By default, the texture maps are always used
    usage: s32 = 1;
    SetShaderValue(shader, GetShaderLocation(shader, "useTexAlbedo")  , *usage, .SHADER_UNIFORM_INT);
    SetShaderValue(shader, GetShaderLocation(shader, "useTexNormal")  , *usage, .SHADER_UNIFORM_INT);
    SetShaderValue(shader, GetShaderLocation(shader, "useTexMRA")     , *usage, .SHADER_UNIFORM_INT);
    SetShaderValue(shader, GetShaderLocation(shader, "useTexEmissive"), *usage, .SHADER_UNIFORM_INT);

    defer {
        // Unbind (disconnect) shader from car.material[0] 
        // to avoid UnloadMaterial() trying to unload it automatically
        s: Shader = ---;
        car.materials[0].shader = s;
        UnloadMaterial(car.materials[0]);
        car.materials[0].maps = null;
        UnloadModel(car);

        floor.materials[0].shader = s;
        UnloadMaterial(floor.materials[0]);
        floor.materials[0].maps = null;
        UnloadModel(floor);

        UnloadShader(shader);       // Unload Shader
    };
    
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update the shader with the camera view vector (points towards { 0.0, 0.0, 0.0 })
        cameraPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);

        // Check key inputs to enable/disable lights
        if (IsKeyPressed(.KEY_ONE))   { lights[2].enabled = !lights[2].enabled; }
        if (IsKeyPressed(.KEY_TWO))   { lights[1].enabled = !lights[1].enabled; }
        if (IsKeyPressed(.KEY_THREE)) { lights[3].enabled = !lights[3].enabled; }
        if (IsKeyPressed(.KEY_FOUR))  { lights[0].enabled = !lights[0].enabled; }

        // Update light values on shader (actually, only enable/disable them)
        for i: 0..MAX_LIGHTS-1 UpdateLight(shader, lights[i]);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();
        
        ClearBackground(BLACK);
        
        {
            BeginMode3D(camera);
            defer EndMode3D();

            // Set floor model texture tiling and emissive color parameters on shader
            SetShaderValue(shader, textureTilingLoc, *floorTextureTiling, .SHADER_UNIFORM_VEC2);
            floorEmissiveColor: Vector4 = ColorNormalize(floor.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].color);
            SetShaderValue(shader, emissiveColorLoc, *floorEmissiveColor, .SHADER_UNIFORM_VEC4);

            DrawModel(floor, Vector3.{0.0, 0.0, 0.0}, 5.0, WHITE);   // Draw floor model

            // Set old car model texture tiling, emissive color and emissive intensity parameters on shader
            SetShaderValue(shader, textureTilingLoc, *carTextureTiling, .SHADER_UNIFORM_VEC2);
            carEmissiveColor: Vector4 = ColorNormalize(car.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_EMISSION].color);
            SetShaderValue(shader, emissiveColorLoc, *carEmissiveColor, .SHADER_UNIFORM_VEC4);
            emissiveIntensity: float = 0.01;
            SetShaderValue(shader, emissiveIntensityLoc, *emissiveIntensity, .SHADER_UNIFORM_FLOAT);

            DrawModel(car, Vector3.{0.0, 0.0, 0.0}, 0.25, WHITE);   // Draw car model

            // Draw spheres to show the lights positions
            for i: 0..MAX_LIGHTS-1 {
                lightColor: Color = lights[i].color;

                if (lights[i].enabled) DrawSphereEx(lights[i].position, 0.2, 8, 8, lightColor);
                else DrawSphereWires(lights[i].position, 0.2, 8, 8, ColorAlpha(lightColor, 0.3));
            }
        }

        DrawText("Toggle lights: [1][2][3][4]", 10, 40, 20, LIGHTGRAY);

        DrawText("(c) Old Rusty Car model by Renafox (https://skfb.ly/LxRy)", screenWidth - 320, screenHeight - 20, 10, LIGHTGRAY);

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}