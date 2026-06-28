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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - ascii rendering");

    // Texture to test static drawing
    fudesumi: Texture2D = LoadTexture("resources/fudesumi.png");
    // Texture to test moving drawing
    raysan: Texture2D = LoadTexture("resources/raysan.png");

    // Load shader to be used on postprocessing
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/ascii.fs", GLSL_VERSION));

    // These locations are used to send data to the GPU
    resolutionLoc: s32 = GetShaderLocation(shader, "resolution");
    fontSizeLoc: s32 = GetShaderLocation(shader, "fontSize");

    // Set the character size for the ASCII effect
    // Fontsize should be 9 or more
    fontSize: float = 9.0;

    // Send the updated values to the shader
    resolution: [2]float = .[cast(float)screenWidth, cast(float)screenHeight];
    SetShaderValue(shader, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);

    circlePos: Vector2 = Vector2.{40.0, cast(float)screenHeight*0.5};
    circleSpeed: float = 1.0;

    // RenderTexture to apply the postprocessing later
    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        circlePos.x += circleSpeed;
        if ((circlePos.x > 200.0) || (circlePos.x < 40.0)) circleSpeed *= -1; // Revert speed

        if (IsKeyPressed(.KEY_LEFT) && (fontSize > 9.0)) fontSize -= 1;  // Reduce fontSize
        if (IsKeyPressed(.KEY_RIGHT) && (fontSize < 15.0)) fontSize += 1;  // Increase fontSize

        // Set fontsize for the shader
        SetShaderValue(shader, fontSizeLoc, *fontSize, .SHADER_UNIFORM_FLOAT);

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
            ClearBackground(WHITE);

            // Draw scene in our render texture
            DrawTexture(fudesumi, 500, -30, WHITE);
            DrawTextureV(raysan, circlePos, WHITE);
        EndTextureMode();

        BeginDrawing();
            ClearBackground(RAYWHITE);

            BeginShaderMode(shader);
                // Draw the scene texture (that we rendered earlier) to the screen
                // The shader will process every pixel of this texture
                DrawTextureRec(target.texture,
                    Rectangle.{ 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height },
                    Vector2.{ 0, 0 }, WHITE);
            EndShaderMode();

            DrawRectangle(0, 0, screenWidth, 40, BLACK);
            DrawText(TextFormat("Ascii effect - FontSize:%2.0f - [Left] -1 [Right] +1 ", fontSize), 120, 10, 20, LIGHTGRAY);
            DrawFPS(10, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture

    UnloadShader(shader);           // Unload shader
    UnloadTexture(fudesumi);        // Unload texture
    UnloadTexture(raysan);          // Unload texture

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}