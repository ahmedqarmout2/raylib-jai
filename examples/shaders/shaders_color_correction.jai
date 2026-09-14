#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

MAX_TEXTURES :: 4;

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - color correction");

    texture: [MAX_TEXTURES]Texture2D = .[
        LoadTexture("resources/parrots.png"),
        LoadTexture("resources/cat.png"),
        LoadTexture("resources/mandrill.png"),
        LoadTexture("resources/fudesumi.png")
    ];

    shdrColorCorrection: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/color_correction.fs", GLSL_VERSION));

    imageIndex: s32 = 0;
    resetButtonClicked: bool = false;

    contrast: float = 0.0;
    saturation: float = 0.0;
    brightness: float = 0.0;

    // Get shader locations
    contrastLoc: s32 = GetShaderLocation(shdrColorCorrection, "contrast");
    saturationLoc: s32 = GetShaderLocation(shdrColorCorrection, "saturation");
    brightnessLoc: s32 = GetShaderLocation(shdrColorCorrection, "brightness");

    // Set shader values (they can be changed later)
    SetShaderValue(shdrColorCorrection, contrastLoc, *contrast, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shdrColorCorrection, saturationLoc, *saturation, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shdrColorCorrection, brightnessLoc, *brightness, .SHADER_UNIFORM_FLOAT);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Select texture to draw
        if (IsKeyPressed(.KEY_ONE)) imageIndex = 0;
        else if (IsKeyPressed(.KEY_TWO)) imageIndex = 1;
        else if (IsKeyPressed(.KEY_THREE)) imageIndex = 2;
        else if (IsKeyPressed(.KEY_FOUR)) imageIndex = 3;

        // Reset values to 0
        if (IsKeyPressed(.KEY_R) || resetButtonClicked)
        {
            contrast = 0.0;
            saturation = 0.0;
            brightness = 0.0;
        }

        // Send the values to the shader
        SetShaderValue(shdrColorCorrection, contrastLoc, *contrast, .SHADER_UNIFORM_FLOAT);
        SetShaderValue(shdrColorCorrection, saturationLoc, *saturation, .SHADER_UNIFORM_FLOAT);
        SetShaderValue(shdrColorCorrection, brightnessLoc, *brightness, .SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginShaderMode(shdrColorCorrection);

                DrawTexture(texture[imageIndex], 580/2 - texture[imageIndex].width/2, GetScreenHeight()/2 - texture[imageIndex].height/2, WHITE);

            EndShaderMode();

            DrawLine(580, 0, 580, GetScreenHeight(), Color.{ 218, 218, 218, 255 });
            DrawRectangle(580, 0, GetScreenWidth(), GetScreenHeight(), Color.{ 232, 232, 232, 255 });

            // Draw UI info text
            DrawText("Color Correction", 585, 40, 20, GRAY);

            DrawText("Picture", 602, 75, 10, GRAY);
            DrawText("Press [1] - [4] to Change Picture", 600, 230, 8, GRAY);
            DrawText("Press [R] to Reset Values", 600, 250, 8, GRAY);

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiToggleGroup(Rectangle.{ 645, 70, 20, 20 }, "1;2;3;4", *imageIndex);

            GuiSliderBar(Rectangle.{ 645, 100, 120, 20 }, "Contrast", TextFormat("%.0f", contrast), *contrast, -100.0, 100.0);
            GuiSliderBar(Rectangle.{ 645, 130, 120, 20 }, "Saturation", TextFormat("%.0f", saturation), *saturation, -100.0, 100.0);
            GuiSliderBar(Rectangle.{ 645, 160, 120, 20 }, "Brightness", TextFormat("%.0f", brightness), *brightness, -100.0, 100.0);

            resetButtonClicked = GuiButton(Rectangle.{ 645, 190, 40, 20 }, "Reset") == GuiResult.RESULT_PRESSED;
            //------------------------------------------------------------------------------

            DrawFPS(710, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..MAX_TEXTURES-1 UnloadTexture(texture[i]);
    UnloadShader(shdrColorCorrection);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
