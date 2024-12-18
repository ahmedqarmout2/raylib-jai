#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_POSTPRO_SHADERS :: 12;

PostproShader :: enum {
    FX_GRAYSCALE :: 0;
    FX_POSTERIZATION;
    FX_DREAM_VISION;
    FX_PIXELIZER;
    FX_CROSS_HATCHING;
    FX_CROSS_STITCHING;
    FX_PREDATOR_VIEW;
    FX_SCANLINES;
    FX_FISHEYE;
    FX_SOBEL;
    FX_BLOOM;
    FX_BLUR;
    //FX_FXAA
};

postproShaderText: []*u8 = .[
    "GRAYSCALE",
    "POSTERIZATION",
    "DREAM_VISION",
    "PIXELIZER",
    "CROSS_HATCHING",
    "CROSS_STITCHING",
    "PREDATOR_VIEW",
    "SCANLINES",
    "FISHEYE",
    "SOBEL",
    "BLOOM",
    "BLUR",
    //"FXAA"
];

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);      // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - postprocessing shader");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{2.0, 3.0, 2.0};    // Camera position
    camera.target     = Vector3.{0.0, 1.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    model: Model  = LoadModel("resources/models/church.obj");                 // Load OBJ model
    texture: Texture2D = LoadTexture("resources/models/church_diffuse.png"); // Load model texture (diffuse map)
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;        // Set model diffuse texture

    position: Vector3 = .{0.0, 0.0, 0.0};            // Set model position

    // Load all postpro shaders
    // NOTE 1: All postpro shader use the base vertex shader (DEFAULT_VERTEX_SHADER)
    // NOTE 2: We load the correct shader depending on GLSL version
    shaders: [MAX_POSTPRO_SHADERS]Shader;

    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shaders[PostproShader.FX_GRAYSCALE]       = LoadShader(null, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION));
    shaders[PostproShader.FX_POSTERIZATION]   = LoadShader(null, TextFormat("resources/shaders/glsl%i/posterization.fs", GLSL_VERSION));
    shaders[PostproShader.FX_DREAM_VISION]    = LoadShader(null, TextFormat("resources/shaders/glsl%i/dream_vision.fs", GLSL_VERSION));
    shaders[PostproShader.FX_PIXELIZER]       = LoadShader(null, TextFormat("resources/shaders/glsl%i/pixelizer.fs", GLSL_VERSION));
    shaders[PostproShader.FX_CROSS_HATCHING]  = LoadShader(null, TextFormat("resources/shaders/glsl%i/cross_hatching.fs", GLSL_VERSION));
    shaders[PostproShader.FX_CROSS_STITCHING] = LoadShader(null, TextFormat("resources/shaders/glsl%i/cross_stitching.fs", GLSL_VERSION));
    shaders[PostproShader.FX_PREDATOR_VIEW]   = LoadShader(null, TextFormat("resources/shaders/glsl%i/predator.fs", GLSL_VERSION));
    shaders[PostproShader.FX_SCANLINES]       = LoadShader(null, TextFormat("resources/shaders/glsl%i/scanlines.fs", GLSL_VERSION));
    shaders[PostproShader.FX_FISHEYE]         = LoadShader(null, TextFormat("resources/shaders/glsl%i/fisheye.fs", GLSL_VERSION));
    shaders[PostproShader.FX_SOBEL]           = LoadShader(null, TextFormat("resources/shaders/glsl%i/sobel.fs", GLSL_VERSION));
    shaders[PostproShader.FX_BLOOM]           = LoadShader(null, TextFormat("resources/shaders/glsl%i/bloom.fs", GLSL_VERSION));
    shaders[PostproShader.FX_BLUR]            = LoadShader(null, TextFormat("resources/shaders/glsl%i/blur.fs", GLSL_VERSION));

    currentShader: PostproShader = .FX_GRAYSCALE;

    // Create a RenderTexture2D to be used for render to texture
    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);

    defer {
        // Unload all postpro shaders
        for i: 0..MAX_POSTPRO_SHADERS-1 UnloadShader(shaders[i]);

        UnloadTexture(texture);         // Unload texture
        UnloadModel(model);             // Unload model
        UnloadRenderTexture(target);    // Unload render texture
    };

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

             if (IsKeyPressed(.KEY_RIGHT)) currentShader += 1;
        else if (IsKeyPressed(.KEY_LEFT))  currentShader -= 1;

        if (currentShader >= MAX_POSTPRO_SHADERS) currentShader = 0;
        else if (currentShader < 0) currentShader = MAX_POSTPRO_SHADERS - 1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginTextureMode(target);       // Enable drawing to texture
            defer EndTextureMode();               // End drawing to texture (now we have a texture available for next passes)

            ClearBackground(RAYWHITE);  // Clear texture background

            BeginMode3D(camera);        // Begin 3d mode drawing
            defer EndMode3D();                // End 3d mode drawing, returns to orthographic 2d mode

            DrawModel(model, position, 0.1, WHITE);   // Draw 3d model with texture
            DrawGrid(10, 1.0);     // Draw a grid
        }

        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);  // Clear screen background

        {
            // Render generated texture using selected postprocessing shader
            BeginShaderMode(shaders[currentShader]);
            defer EndShaderMode();

            // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
            DrawTextureRec(target.texture, Rectangle.{0, 0, cast(float)target.texture.width, cast(float)-target.texture.height}, Vector2.{0, 0}, WHITE);
        }

        // Draw 2d shapes and text over drawn texture
        DrawRectangle(0, 9, 580, 30, Fade(LIGHTGRAY, 0.7));

        DrawText("(c) Church 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, GRAY);
        DrawText("CURRENT POSTPRO SHADER:", 10, 15, 20, BLACK);
        DrawText(postproShaderText[currentShader], 330, 15, 20, RED);
        DrawText("< >", 540, 10, 30, DARKBLUE);
        DrawFPS(700, 15);
        //----------------------------------------------------------------------------------
    }
}