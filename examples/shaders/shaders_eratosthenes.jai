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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Sieve of Eratosthenes");
    defer CloseWindow(); // Close window and OpenGL context

    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);
    defer UnloadRenderTexture(target);        // Unload render texture

    // Load Eratosthenes shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/eratosthenes.fs", GLSL_VERSION));
    defer UnloadShader(shader);               // Unload shader

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Nothing to do here, everything is happening in the shader
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginTextureMode(target);       // Enable drawing to texture
            defer EndTextureMode();               // End drawing to texture (now we have a blank texture available for the shader)

            ClearBackground(BLACK);     // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // so shader can not be applied here directly because input vertexTexCoord
            // do not represent full screen coordinates (space where want to apply shader)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);
        }

        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);  // Clear screen background

        BeginShaderMode(shader);
        defer EndShaderMode();

        // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
        DrawTextureRec(target.texture, Rectangle.{0, 0, cast(float)target.texture.width, cast(float)-target.texture.height}, Vector2.{0.0, 0.0}, WHITE);
        //----------------------------------------------------------------------------------
    }
}