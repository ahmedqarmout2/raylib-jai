#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

// A few good interesting places
pointsOfInterest: [6][3]float64 =
.[
    .[ -1.76826775, -0.00422996283, 28435.9238 ],
    .[ 0.322004497, -0.0357099883, 56499.7266 ],
    .[ -0.748880744, -0.0562955774, 9237.59082 ],
    .[ -1.78385007, -0.0156200649, 14599.5283 ],
    .[ -0.0985441282, -0.924688697, 26259.8535 ],
    .[ 0.317785531, -0.0322612226, 29297.9258 ],
];

zoomSpeed: float = 1.01;
offsetSpeedMul: float = 2.0;

startingZoom: float = 0.6;
startingOffset: [2]float = .[ -0.5, 0.0 ];

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - mandelbrot set");

    // Load mandelbrot set shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/mandelbrot_set.fs", GLSL_VERSION));

    // Create a RenderTexture2D to be used for render to texture
    target: RenderTexture2D = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

    // Offset and zoom to draw the mandelbrot set at. (centered on screen and default size)
    offset: [2]float = .[ startingOffset[0], startingOffset[1] ];
    zoom: float = startingZoom;
    // Depending on the zoom the mximum number of iterations must be adapted to get more detail as we zzoom in
    // The solution is not perfect, so a control has been added to increase/decrease the number of iterations with UP/DOWN keys
    maxIterations: s32 = 333;
    maxIterationsMultiplier: float = 166.5;

    // Get variable (uniform) locations on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    zoomLoc: s32 = GetShaderLocation(shader, "zoom");
    offsetLoc: s32 = GetShaderLocation(shader, "offset");
    maxIterationsLoc: s32 = GetShaderLocation(shader, "maxIterations");

    // Upload the shader uniform values!
    SetShaderValue(shader, zoomLoc, *zoom, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, offsetLoc, *offset, .SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, maxIterationsLoc, *maxIterations, .SHADER_UNIFORM_INT);

    showControls: bool = true;           // Show controls

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        updateShader: bool = false;

        // Press [1 - 6] to reset c to a point of interest
        if (IsKeyPressed(.KEY_ONE) ||
            IsKeyPressed(.KEY_TWO) ||
            IsKeyPressed(.KEY_THREE) ||
            IsKeyPressed(.KEY_FOUR) ||
            IsKeyPressed(.KEY_FIVE) ||
            IsKeyPressed(.KEY_SIX))
        {
            interestIndex: s32 = 0;
            if (IsKeyPressed(.KEY_ONE)) interestIndex = 0;
            else if (IsKeyPressed(.KEY_TWO)) interestIndex = 1;
            else if (IsKeyPressed(.KEY_THREE)) interestIndex = 2;
            else if (IsKeyPressed(.KEY_FOUR)) interestIndex = 3;
            else if (IsKeyPressed(.KEY_FIVE)) interestIndex = 4;
            else if (IsKeyPressed(.KEY_SIX)) interestIndex = 5;

            offset[0] = cast(float)pointsOfInterest[interestIndex][0];
            offset[1] = cast(float)pointsOfInterest[interestIndex][1];
            zoom = cast(float)pointsOfInterest[interestIndex][2];
            updateShader = true;
        }

        // If "R" is pressed, reset zoom and offset
        if (IsKeyPressed(.KEY_R))
        {
            offset[0] = startingOffset[0];
            offset[1] = startingOffset[1];
            zoom = startingZoom;
            updateShader = true;
        }

        if (IsKeyPressed(.KEY_F1)) showControls = !showControls;  // Toggle whether or not to show controls

        // Change number of max iterations with UP and DOWN keys
        // WARNING: Increasing the number of max iterations greatly impacts performance
        if (IsKeyPressed(.KEY_UP))
        {
            maxIterationsMultiplier *= 1.4;
            updateShader = true;
        }
        else if (IsKeyPressed(.KEY_DOWN))
        {
            maxIterationsMultiplier /= 1.4;
            updateShader = true;
        }

        // If either left or right button is pressed, zoom in/out
        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) || IsMouseButtonDown(.MOUSE_BUTTON_RIGHT))
        {
            // Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out
            zoom *= ifx IsMouseButtonDown(.MOUSE_BUTTON_LEFT) then zoomSpeed else (1.0/zoomSpeed);

            mousePos: Vector2 = GetMousePosition();
            offsetVelocity: Vector2;
            // Find the velocity at which to change the camera. Take the distance of the mouse
            // From the center of the screen as the direction, and adjust magnitude based on the current zoom
            offsetVelocity.x = (mousePos.x/cast(float)screenWidth - 0.5)*offsetSpeedMul/zoom;
            offsetVelocity.y = (mousePos.y/cast(float)screenHeight - 0.5)*offsetSpeedMul/zoom;

            // Apply move velocity to camera
            offset[0] += GetFrameTime()*offsetVelocity.x;
            offset[1] += GetFrameTime()*offsetVelocity.y;

            updateShader = true;
        }

        // In case a parameter has been changed, update the shader values
        if (updateShader)
        {
            // As we zoom in, increase the number of max iterations to get more detail
            // Aproximate formula, but it works-ish
            maxIterations = cast(s32)(sqrt(2.0*sqrt(abs(1.0 - sqrt(37.5*zoom))))*maxIterationsMultiplier);

            // Update the shader uniform values!
            SetShaderValue(shader, zoomLoc, *zoom, .SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, *offset, .SHADER_UNIFORM_VEC2);
            SetShaderValue(shader, maxIterationsLoc, *maxIterations, .SHADER_UNIFORM_INT);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        // Using a render texture to draw Mandelbrot set
        BeginTextureMode(target);       // Enable drawing to texture
            ClearBackground(BLACK);     // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // So shader can not be applied here directly because input vertexTexCoord
            // Do not represent full screen coordinates (space where want to apply shader)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);
        EndTextureMode();

        BeginDrawing();
            ClearBackground(BLACK);     // Clear screen background

            // Draw the saved texture and rendered mandelbrot set with shader
            // NOTE: We do not invert texture on Y, already considered inside shader
            BeginShaderMode(shader);
                // WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
                // When rendering the RenderTexture2D to fit in the HighDPI scaled Window
                DrawTextureEx(target.texture, Vector2.{ 0.0, 0.0 }, 0.0, 1.0, WHITE);
            EndShaderMode();

            if (showControls)
            {
                DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, RAYWHITE);
                DrawText("Press F1 to toggle these controls", 10, 30, 10, RAYWHITE);
                DrawText("Press [1 - 6] to change point of interest", 10, 45, 10, RAYWHITE);
                DrawText("Press UP | DOWN to change number of iterations", 10, 60, 10, RAYWHITE);
                DrawText("Press R to recenter the camera", 10, 75, 10, RAYWHITE);
            }
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);               // Unload shader
    UnloadRenderTexture(target);        // Unload render texture

    CloseWindow();                      // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
