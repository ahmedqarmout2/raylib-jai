#import "raylib";
#import "Basic";
#import "Math";

#load "shared/rlights.jai";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_INSTANCES :: 10000;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - mesh instancing");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{-125.0, 125.0, -125.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.0};            // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};            // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                               // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;                // Camera projection type

    // Define mesh to be instanced
    cube: Mesh = GenMeshCube(1.0, 1.0, 1.0);

    // Define transforms to be uploaded to GPU for instances
    transforms: [MAX_INSTANCES]Matrix4;   // Pre-multiplied transformations passed to rlgl
    defer array_free(transforms);

    // Translate and rotate cubes randomly
    for i: 0..MAX_INSTANCES-1 {
        translation: Matrix4 = MatrixTranslate(cast(float)GetRandomValue(-50, 50), cast(float)GetRandomValue(-50, 50), cast(float)GetRandomValue(-50, 50));
        axis: Vector3 = Vector3Normalize(Vector3.{cast(float)GetRandomValue(0, 360), cast(float)GetRandomValue(0, 360), cast(float)GetRandomValue(0, 360)});
        angle: float = cast(float)GetRandomValue(0, 10)*DEG2RAD;
        rotation: Matrix4 = MatrixRotate(axis, angle);

        transforms[i] = MatrixMultiply(rotation, translation);
    }

    // Load lighting shader
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/lighting_instancing.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/lighting.fs", GLSL_VERSION));

    // Get shader locations
    shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MVP]   = GetShaderLocation(shader, "mvp");
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW]  = GetShaderLocation(shader, "viewPos");
    shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL] = GetShaderLocationAttrib(shader, "instanceTransform");

    // Set shader value: ambient light level
    ambientLoc: s32 = GetShaderLocation(shader, "ambient");
    value: [4]float = .[0.2, 0.2, 0.2, 1.0];
    SetShaderValue(shader, ambientLoc, *value, .SHADER_UNIFORM_VEC4);

    // Create one light
    CreateLight(.LIGHT_DIRECTIONAL, Vector3.{50.0, 50.0, 0.0}, Vector3Zero(), WHITE, shader);

    // NOTE: We are assigning the intancing shader to material.shader
    // to be used on mesh drawing with DrawMeshInstanced()
    matInstances: Material = LoadMaterialDefault();
    matInstances.shader = shader;
    matInstances.maps[MATERIAL_MAP_DIFFUSE].color = RED;

    // Load default material (using raylib intenral default shader) for non-instanced mesh drawing
    // WARNING: Default shader enables vertex color attribute BUT GenMeshCube() does not generate vertex colors, so,
    // when drawing the color attribute is disabled and a default color value is provided as input for thevertex attribute
    matDefault: Material = LoadMaterialDefault();
    matDefault.maps[MATERIAL_MAP_DIFFUSE].color = BLUE;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update the light shader with the camera view position
        cameraPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginMode3D(camera);
            defer EndMode3D();

            // Draw cube mesh with default material (BLUE)
            DrawMesh(cube, matDefault, MatrixTranslate(-10.0, 0.0, 0.0));

            // Draw meshes instanced using material containing instancing shader (RED + lighting),
            // transforms[] for the instances should be provided, they are dynamically
            // updated in GPU every frame, so we can animate the different mesh instances
            DrawMeshInstanced(cube, matInstances, transforms.data, MAX_INSTANCES);

            // Draw cube mesh with default material (BLUE)
            DrawMesh(cube, matDefault, MatrixTranslate(10.0, 0.0, 0.0));
        }

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}