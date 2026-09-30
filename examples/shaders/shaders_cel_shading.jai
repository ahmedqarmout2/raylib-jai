#import "raylib";
#import "Basic";
#import "Math";

#load "rlights.jai";

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
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - cel shading");

    camera: Camera;
    camera.position = Vector3.{ 9.0, 6.0, 9.0 };
    camera.target = Vector3.{ 0.0, 1.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Load model
    model: Model = LoadModel("resources/models/old_car_new.glb");

    // Load cel shader
    celShader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/cel.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/cel.fs", GLSL_VERSION));
    celShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW] = GetShaderLocation(celShader, "viewPos");

    // Apply cel shader to model, keep copy of default shader
    defaultShader: Shader = model.materials[0].shader;
    model.materials[0].shader = celShader;

    // numBands: controls toon quantization steps (2 = hard binary, 20 = near-smooth)
    numBands: float = 10.0;
    numBandsLoc: s32 = GetShaderLocation(celShader, "numBands");
    SetShaderValue(celShader, numBandsLoc, *numBands, .SHADER_UNIFORM_FLOAT);

    // Inverted-hull outline shader: draws back faces extruded along normals
    outlineShader: Shader = LoadShader(
        TextFormat("resources/shaders/glsl%i/outline_hull.vs", GLSL_VERSION),
        TextFormat("resources/shaders/glsl%i/outline_hull.fs", GLSL_VERSION));
    outlineThicknessLoc: s32 = GetShaderLocation(outlineShader, "outlineThickness");

    // Single directional white light, angled so toon bands are visible on the model sides.
    // Spins opposite to CAMERA_ORBITAL (0.5 rad/s) so lighting changes as you watch.
    lights: [MAX_LIGHTS]Light;
    lights[0] = CreateLight(.LIGHT_DIRECTIONAL, Vector3.{ 50.0, 50.0, 50.0 }, Vector3Zero(), WHITE, celShader);

    celEnabled: bool = true;
    outlineEnabled: bool = true;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        cameraPos: [3]float = .[camera.position.x, camera.position.y, camera.position.z];
        SetShaderValue(celShader, celShader.locs[ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW], *cameraPos, .SHADER_UNIFORM_VEC3);

        // [Z] Toggle cel shading on/off
        if (IsKeyPressed(.KEY_Z))
        {
            celEnabled = !celEnabled;
            if (celEnabled) model.materials[0].shader = celShader; // Apply cel shader to model
            else model.materials[0].shader = defaultShader; // Apply default shader to model
        }

        // [C] Toggle outline on/off
        if (IsKeyPressed(.KEY_C)) outlineEnabled = !outlineEnabled;

        // [Q/E] Decrease/increase toon band count (press or hold to repeat)
        if (IsKeyPressed(.KEY_E) || IsKeyPressedRepeat(.KEY_E)) numBands = Clamp(numBands + 1.0, 2.0, 20.0);
        if (IsKeyPressed(.KEY_Q) || IsKeyPressedRepeat(.KEY_Q)) numBands = Clamp(numBands - 1.0, 2.0, 20.0);
        SetShaderValue(celShader, numBandsLoc, *numBands, .SHADER_UNIFORM_FLOAT);

        // Spin light opposite to CAMERA_ORBITAL (0.5 rad/s), angled 45 degrees off vertical
        t: float = cast(float)GetTime();
        lights[0].position = Vector3.{ sin(-t*0.3)*5.0, 5.0, cos(-t*0.3)*5.0 };

        for i: 0..MAX_LIGHTS-1 UpdateLightValues(celShader, lights[i]);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                if (outlineEnabled)
                {
                    // Outline pass: cull front faces, draw extruded back faces as silhouette
                    thickness: float = 0.005;
                    SetShaderValue(outlineShader, outlineThicknessLoc, *thickness, .SHADER_UNIFORM_FLOAT);

                    rlSetCullFace(.RL_CULL_FACE_FRONT);

                    model.materials[0].shader = outlineShader;

                    DrawModel(model, Vector3Zero(), 0.75, WHITE);

                    if (celEnabled) model.materials[0].shader = celShader; // Apply cel shader to model
                    else model.materials[0].shader = defaultShader; // Apply default shader to model

                    rlSetCullFace(.RL_CULL_FACE_BACK);
                }

                DrawModel(model, Vector3Zero(), 0.75, WHITE);
                DrawSphereEx(lights[0].position, 0.2, 50, 50, YELLOW);  // Light position indicator
                DrawGrid(10, 10.0);

            EndMode3D();

            DrawFPS(10, 10);
            DrawText(TextFormat("Cel: %s  [Z]", temp_c_string(ifx celEnabled then "ON" else "OFF")), 10, 65, 20, ifx celEnabled then DARKGREEN else DARKGRAY);
            DrawText(TextFormat("Outline: %s  [C]", temp_c_string(ifx outlineEnabled then "ON" else "OFF")), 10, 90, 20, ifx outlineEnabled then DARKGREEN else DARKGRAY);
            DrawText(TextFormat("Bands: %.0  [Q/E]", numBands), 10, 115, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);
    UnloadShader(celShader);
    UnloadShader(outlineShader);

    CloseWindow();
    //--------------------------------------------------------------------------------------
}
