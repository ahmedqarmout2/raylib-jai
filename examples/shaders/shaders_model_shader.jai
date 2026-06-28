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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);      // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - model shader");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{4.0, 4.0, 4.0};    // Camera position
    camera.target     = Vector3.{0.0, 1.0, -1.0};   // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera projection type

    model: Model = LoadModel("resources/models/watermill.obj");                   // Load OBJ model
    texture: Texture2D = LoadTexture("resources/models/watermill_diffuse.png");   // Load model texture

    // Load shader for model
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION));

    model.materials[0].shader = shader;                     // Set shader effect to 3d model
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture; // Bind texture to model

    position: Vector3 = .{0.0, 0.0, 0.0};    // Set model position

    DisableCursor();                    // Limit cursor to relative movement inside the window
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FREE);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 0.2, WHITE);   // Draw 3d model with texture

                DrawGrid(10, 1.0);     // Draw a grid
            
            EndMode3D();

            DrawText("(c) Watermill 3D model by Alberto Cano", screenWidth - 210, screenHeight - 20, 10, GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);       // Unload shader
    UnloadTexture(texture);     // Unload texture
    UnloadModel(model);         // Unload model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}