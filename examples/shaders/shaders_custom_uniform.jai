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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - custom uniform variable");
    defer CloseWindow(); // Close window and OpenGL context

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{8.0, 8.0, 8.0};   // Camera position
    camera.target     = Vector3.{0.0, 1.5, 0.0};   // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};   // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                      // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;       // Camera projection type

    model: Model = LoadModel("resources/models/barracks.obj");                   // Load OBJ model
    defer UnloadModel(model);                 // Unload model

    texture: Texture2D = LoadTexture("resources/models/barracks_diffuse.png");   // Load model texture (diffuse map)
    defer UnloadTexture(texture);             // Unload texture

    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;                     // Set model diffuse texture

    position: Vector3 = .{0.0, 0.0, 0.0};                                    // Set model position

    // Load postprocessing shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/swirl.fs", GLSL_VERSION));
    defer UnloadShader(shader);               // Unload shader

    // Get variable (uniform) location on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    swirlCenterLoc: s32 = GetShaderLocation(shader, "center");

    swirlCenter: [2]float = .[cast(float)screenWidth/2, cast(float)screenHeight/2];

    // Create a RenderTexture2D to be used for render to texture
    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);
    defer UnloadRenderTexture(target);        // Unload render texture

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera,.CAMERA_ORBITAL);
        
        mousePosition: Vector2 = GetMousePosition();

        swirlCenter[0] = mousePosition.x;
        swirlCenter[1] = screenHeight - mousePosition.y;

        // Send new value to the shader to be used on drawing
        SetShaderValue(shader, swirlCenterLoc, *swirlCenter, .SHADER_UNIFORM_VEC2);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginTextureMode(target);   // Enable drawing to texture
            defer EndTextureMode();     // End drawing to texture (now we have a texture available for next passes)

            ClearBackground(RAYWHITE);  // Clear texture background

            {
                BeginMode3D(camera);    // Begin 3d mode drawing
                defer EndMode3D();      // End 3d mode drawing, returns to orthographic 2d mode

                DrawModel(model, position, 0.5, WHITE);   // Draw 3d model with texture
                DrawGrid(10, 1.0);      // Draw a grid
            }

            DrawText("TEXT DRAWN IN RENDER TEXTURE", 200, 10, 30, RED);
        }
        
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);  // Clear screen background

        {
            // Enable shader using the custom uniform
            BeginShaderMode(shader);
            defer EndShaderMode();

            // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
            DrawTextureRec(target.texture, Rectangle.{0, 0, cast(float)target.texture.width, cast(float)-target.texture.height}, Vector2.{0, 0}, WHITE);
        }

        // Draw some 2d text over drawn texture
        DrawText("(c) Barracks 3D model by Alberto Cano", screenWidth - 220, screenHeight - 20, 10, GRAY);
        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}