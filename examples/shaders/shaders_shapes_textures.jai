#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

SHADOWMAP_RESOLUTION :: 1024;

cam: Camera;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shapes and texture shaders");
    defer CloseWindow(); // Close window and OpenGL context

    fudesumi: Texture2D = LoadTexture("resources/fudesumi.png");
    defer UnloadTexture(fudesumi);    // Unload texture

    // Load shader to be used on some parts drawing
    // NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
    // NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/grayscale.fs", GLSL_VERSION));
    defer UnloadShader(shader);       // Unload shader

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Start drawing with default shader

            DrawText("USING DEFAULT SHADER", 20, 40, 10, RED);

            DrawCircle(80, 120, 35, DARKBLUE);
            DrawCircleGradient(80, 220, 60, GREEN, SKYBLUE);
            DrawCircleLines(80, 340, 80, DARKBLUE);


            // Activate our custom shader to be applied on next shapes/textures drawings
            BeginShaderMode(shader);

                DrawText("USING CUSTOM SHADER", 190, 40, 10, RED);

                DrawRectangle(250 - 60, 90, 120, 60, RED);
                DrawRectangleGradientH(250 - 90, 170, 180, 130, MAROON, GOLD);
                DrawRectangleLines(250 - 40, 320, 80, 60, ORANGE);

            // Activate our default shader for next drawings
            EndShaderMode();

            DrawText("USING DEFAULT SHADER", 370, 40, 10, RED);

            DrawTriangle(Vector2.{430, 80},
                         Vector2.{430 - 60, 150},
                         Vector2.{430 + 60, 150}, VIOLET);

            DrawTriangleLines(Vector2.{430, 160},
                              Vector2.{430 - 20, 230},
                              Vector2.{430 + 20, 230}, DARKBLUE);

            DrawPoly(Vector2.{430, 320}, 6, 80, 0, BROWN);

            // Activate our custom shader to be applied on next shapes/textures drawings
            BeginShaderMode(shader);

                DrawTexture(fudesumi, 500, -30, WHITE);    // Using custom shader

            // Activate our default shader for next drawings
            EndShaderMode();

            DrawText("(c) Fudesumi sprite by Eiden Marsal", 380, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}
