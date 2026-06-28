#import "raylib";
#import "Basic";
#import "Math";

#load "shared/rlights.jai";

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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);  // Enable Multi Sampling Anti Aliasing 4x (if available)
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - fog rendering");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{2.0, 2.0, 6.0};    // Camera position
    camera.target     = Vector3.{0.0, 0.5, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    // Load models and texture
    modelA: Model = LoadModelFromMesh(GenMeshTorus(0.4, 1.0, 16, 32));
    modelB: Model = LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
    modelC: Model = LoadModelFromMesh(GenMeshSphere(0.5, 32, 32));
    texture: Texture = LoadTexture("resources/texel_checker.png");

    // Assign texture to default model material
    modelA.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;
    modelB.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;
    modelC.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;

    // Load shader and set up some uniforms
    shader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/lighting.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/fog.fs", GLSL_VERSION));
    shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_MODEL] = GetShaderLocation(shader, "matModel");
    shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW]  = GetShaderLocation(shader, "viewPos");

    // Ambient light level
    ambient: Vector4 = Vector4.{ 0.2, 0.2, 0.2, 1.0 };
    ambientLoc: s32 = GetShaderLocation(shader, "ambient");
    SetShaderValue(shader, ambientLoc, *ambient, .SHADER_UNIFORM_VEC4);

    fogColor: Vector4 = ColorNormalize(GRAY);
    fogColorLoc: s32 = GetShaderLocation(shader, "fogColor");
    SetShaderValue(shader, fogColorLoc, *fogColor, .SHADER_UNIFORM_VEC4);

    fogDensity: float = 0.15;
    fogDensityLoc: s32 = GetShaderLocation(shader, "fogDensity");
    SetShaderValue(shader, fogDensityLoc, *fogDensity, .SHADER_UNIFORM_FLOAT);

    // NOTE: All models share the same shader
    modelA.materials[0].shader = shader;
    modelB.materials[0].shader = shader;
    modelC.materials[0].shader = shader;

    // Using just 1 point lights
    CreateLight(.LIGHT_POINT, Vector3.{0, 2, 6}, Vector3Zero(), WHITE, shader);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsKeyDown(.KEY_UP))
        {
            fogDensity += 0.001;
            if (fogDensity > 1.0) fogDensity = 1.0;
        }

        if (IsKeyDown(.KEY_DOWN))
        {
            fogDensity -= 0.001;
            if (fogDensity < 0.0) fogDensity = 0.0;
        }

        SetShaderValue(shader, fogDensityLoc, *fogDensity, .SHADER_UNIFORM_FLOAT);

        // Rotate the torus
        modelA.transform = MatrixMultiply(modelA.transform, MatrixRotateX(-0.025));
        modelA.transform = MatrixMultiply(modelA.transform, MatrixRotateZ(0.012));

        // Update the light shader with the camera view position
        SetShaderValue(shader, shader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *camera.position.x, .SHADER_UNIFORM_VEC3);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(GRAY);

            BeginMode3D(camera);

                // Draw the three models
                DrawModel(modelA, Vector3Zero(), 1.0, WHITE);
                DrawModel(modelB, Vector3.{-2.6, 0, 0}, 1.0, WHITE);
                DrawModel(modelC, Vector3.{ 2.6, 0, 0}, 1.0, WHITE);

                i: s32 = -20;
                while (i < 20) {
                    defer i += 2;

                    DrawModel(modelA, Vector3.{cast(float)i, 0, 2}, 1.0, WHITE);
                }

            EndMode3D();

            DrawText(TextFormat("Use KEY_UP/KEY_DOWN to change fog density [%.2f]", fogDensity), 10, 10, 20, RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(modelA);        // Unload the model A
    UnloadModel(modelB);        // Unload the model B
    UnloadModel(modelC);        // Unload the model C
    UnloadTexture(texture);     // Unload the texture
    UnloadShader(shader);       // Unload shader

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}