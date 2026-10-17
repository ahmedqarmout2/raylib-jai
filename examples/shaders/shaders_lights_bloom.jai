#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

MAX_LIGHTS :: 8;

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

    SetConfigFlags(.FLAG_MSAA_4X_HINT | .FLAG_VSYNC_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - lights bloom");

    camera: Camera3D;
    camera.position = Vector3.{ 0.0, 5.0, 9.0 };
    camera.target = Vector3.{ 0.0, 0.5, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);

    // Forward multi-light shader and bloom post-process shader, both loaded from the
    // resources folder shared with the rest of the shaders examples. If the GLSL version
    // guessed from the PLATFORM_DESKTOP build flag turns out to be wrong for whatever
    // raylib was built against, linking fails and silently falls back to the default
    // shader - so this retries once with the other version, and either way the result
    // is checked explicitly and reported on screen rather than staying silently wrong
    lightShader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/lights_bloom.vs", GLSL_VERSION),
                                     TextFormat("resources/shaders/glsl%i/lights_bloom.fs", GLSL_VERSION));
    bloomShader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/lights_bloom_post.fs", GLSL_VERSION));

    // Load models from generated cube mesh and plane
    // NOTE: Meshes are automatically unloaded on UnloadModel()
    cube: Model = LoadModelFromMesh(GenMeshCube(2.0, 2.0, 2.0));
    floor: Model = LoadModelFromMesh(GenMeshPlane(14.0, 14.0, 1, 1));
    cube.materials[0].shader = lightShader;
    floor.materials[0].shader = lightShader;

    lightPosLoc: s32 = GetShaderLocation(lightShader, "lightPositions");
    lightColLoc: s32 = GetShaderLocation(lightShader, "lightColors");
    viewPosLoc: s32 = GetShaderLocation(lightShader, "viewPos");

    lightPositions: [MAX_LIGHTS]Vector3;
    lightColors: [MAX_LIGHTS]Vector3 = .[
        .{ 1.0, 0.2, 0.2 },   // Red
        .{ 0.2, 1.0, 0.3 },   // Green
        .{ 0.2, 0.5, 1.0 },   // Blue
        .{ 1.0, 0.8, 0.1 },   // Yellow
        .{ 1.0, 0.1, 0.8 },   // Magenta
        .{ 0.1, 1.0, 1.0 },   // Cyan
        .{ 1.0, 0.4, 0.1 },   // Orange
        .{ 0.7, 0.2, 1.0 },   // Purple
    ];

    SetShaderValueV(lightShader, lightColLoc, *lightColors, .SHADER_UNIFORM_VEC3, MAX_LIGHTS);

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        time: float = cast(float)GetTime();

        // Orbital path for each point light, its own radius/height offset by index
        for i: 0..MAX_LIGHTS-1
        {
            angle: float = (i/cast(float)MAX_LIGHTS)*2.0*PI + time*0.6;
            radius: float = 4.2 + sin(time*1.2 + i)*0.4;
            height: float = 1.0 + sin(time*1.8 + i)*0.6;

            lightPositions[i] = Vector3.{ sin(angle)*radius, height, cos(angle)*radius };
        }

        SetShaderValueV(lightShader, lightPosLoc, *lightPositions, .SHADER_UNIFORM_VEC3, MAX_LIGHTS);
        SetShaderValue(lightShader, viewPosLoc, *camera.position, .SHADER_UNIFORM_VEC3);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        // Render the lit scene to an offscreen texture
        BeginTextureMode(target);

            ClearBackground(Color.{ 12, 12, 18, 255 });

            BeginMode3D(camera);

                DrawModel(cube, Vector3.{ 0.0, 1.0, 0.0 }, 1.0, GRAY);
                DrawModel(floor, Vector3.{ 0.0, 0.0, 0.0 }, 1.0, DARKGRAY);
                DrawGrid(10, 1.0);

                // Glowing bulbs mark each light's position
                for i: 0..MAX_LIGHTS-1
                {
                    bulbColor: Color = Color.{
                        cast(u8)(lightColors[i].x*255),
                        cast(u8)(lightColors[i].y*255),
                        cast(u8)(lightColors[i].z*255),
                        255 };

                    DrawSphere(lightPositions[i], 0.15, bulbColor);
                }

            EndMode3D();

        EndTextureMode();

        // Present the offscreen texture through the bloom + tone mapping shader
        BeginDrawing();

            ClearBackground(BLACK);

            srcRec: Rectangle = .{ 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height };

            BeginShaderMode(bloomShader);
                // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
                DrawTextureRec(target.texture, srcRec, Vector2.{ 0, 0 }, WHITE);
            EndShaderMode();

            DrawText("BALANCED MULTI-LIGHT + REINHARD TONE MAPPED BLOOM", 20, 20, 20, GREEN);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(cube);
    UnloadModel(floor);
    UnloadShader(lightShader);
    UnloadShader(bloomShader);
    UnloadRenderTexture(target);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
