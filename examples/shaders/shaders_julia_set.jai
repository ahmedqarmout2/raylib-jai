#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

// A few good julia sets
pointsOfInterest: [6][2]float = .[
    .[-0.348827, 0.607167],
    .[-0.786268, 0.169728],
    .[-0.8, 0.156],
    .[0.285, 0.0],
    .[-0.835, -0.2321],
    .[-0.70176, -0.3842]
];

screenWidth   : s32   = 800;
screenHeight  : s32   = 450;
zoomSpeed     : float = 1.01;
offsetSpeedMul: float = 2.0;
startingZoom  : float = 0.75;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - julia sets");
    defer CloseWindow(); // Close window and OpenGL context

    // Load julia set shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/julia_set.fs", GLSL_VERSION));
    defer UnloadShader(shader);               // Unload shader

    // Create a RenderTexture2D to be used for render to texture
    target: RenderTexture2D = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
    defer UnloadRenderTexture(target);        // Unload render texture

    // c constant to use in z^2 + c
    c: [2]float = .[pointsOfInterest[0][0], pointsOfInterest[0][1]];

    // Offset and zoom to draw the julia set at. (centered on screen and default size)
    offset: [2]float = .[0.0, 0.0];
    zoom: float = startingZoom;

    // Get variable (uniform) locations on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    cLoc     : s32 = GetShaderLocation(shader, "c");
    zoomLoc  : s32 = GetShaderLocation(shader, "zoom");
    offsetLoc: s32 = GetShaderLocation(shader, "offset");

    // Upload the shader uniform values!
    SetShaderValue(shader, cLoc     , *c     , .SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, zoomLoc  , *zoom  , .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, offsetLoc, *offset, .SHADER_UNIFORM_VEC2);

    incrementSpeed: s32  = 0;           // Multiplier of speed to change c value
    showControls  : bool = true;        // Show controls

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Press [1 - 6] to reset c to a point of interest
        if (IsKeyPressed(.KEY_ONE) ||
            IsKeyPressed(.KEY_TWO) ||
            IsKeyPressed(.KEY_THREE) ||
            IsKeyPressed(.KEY_FOUR) ||
            IsKeyPressed(.KEY_FIVE) ||
            IsKeyPressed(.KEY_SIX)) {
                 if (IsKeyPressed(.KEY_ONE))   { c[0] = pointsOfInterest[0][0]; c[1] = pointsOfInterest[0][1]; }
            else if (IsKeyPressed(.KEY_TWO))   { c[0] = pointsOfInterest[1][0]; c[1] = pointsOfInterest[1][1]; }
            else if (IsKeyPressed(.KEY_THREE)) { c[0] = pointsOfInterest[2][0]; c[1] = pointsOfInterest[2][1]; }
            else if (IsKeyPressed(.KEY_FOUR))  { c[0] = pointsOfInterest[3][0]; c[1] = pointsOfInterest[3][1]; }
            else if (IsKeyPressed(.KEY_FIVE))  { c[0] = pointsOfInterest[4][0]; c[1] = pointsOfInterest[4][1]; }
            else if (IsKeyPressed(.KEY_SIX))   { c[0] = pointsOfInterest[5][0]; c[1] = pointsOfInterest[5][1]; }

            SetShaderValue(shader, cLoc, *c, .SHADER_UNIFORM_VEC2);
        }

        // If "R" is pressed, reset zoom and offset.
        if (IsKeyPressed(.KEY_R)) {
            zoom = startingZoom;
            offset[0] = 0.0;
            offset[1] = 0.0;
            SetShaderValue(shader, zoomLoc  , *zoom  , .SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, *offset, .SHADER_UNIFORM_VEC2);
        }

        if (IsKeyPressed(.KEY_SPACE)) incrementSpeed = 0;         // Pause animation (c change)
        if (IsKeyPressed(.KEY_F1))    showControls   = !showControls;  // Toggle whether or not to show controls

             if (IsKeyPressed(.KEY_RIGHT)) incrementSpeed += 1;
        else if (IsKeyPressed(.KEY_LEFT))  incrementSpeed -= 1;

        // If either left or right button is pressed, zoom in/out.
        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) || IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
            // Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out.
            zoom *= ifx IsMouseButtonDown(.MOUSE_BUTTON_LEFT) then zoomSpeed else 1.0/zoomSpeed;

            mousePos: Vector2 = GetMousePosition();
            offsetVelocity: Vector2 ;
            // Find the velocity at which to change the camera. Take the distance of the mouse
            // from the center of the screen as the direction, and adjust magnitude based on
            // the current zoom.
            offsetVelocity.x = (mousePos.x/cast(float)screenWidth - 0.5)*offsetSpeedMul/zoom;
            offsetVelocity.y = (mousePos.y/cast(float)screenHeight - 0.5)*offsetSpeedMul/zoom;

            // Apply move velocity to camera
            offset[0] += GetFrameTime()*offsetVelocity.x;
            offset[1] += GetFrameTime()*offsetVelocity.y;

            // Update the shader uniform values!
            SetShaderValue(shader, zoomLoc  , *zoom  , .SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, *offset, .SHADER_UNIFORM_VEC2);
        }

        // Increment c value with time
        dc: float = GetFrameTime()*cast(float)incrementSpeed*0.0005;
        c[0] += dc;
        c[1] += dc;
        SetShaderValue(shader, cLoc, *c, .SHADER_UNIFORM_VEC2);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            // Using a render texture to draw Julia set
            BeginTextureMode(target);       // Enable drawing to texture
            defer EndTextureMode();

            ClearBackground(BLACK);     // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // so shader can not be applied here directly because input vertexTexCoord
            // do not represent full screen coordinates (space where want to apply shader)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), BLACK);
        }

        BeginDrawing();
        defer EndDrawing();

        ClearBackground(BLACK);     // Clear screen background

        {
            // Draw the saved texture and rendered julia set with shader
            // NOTE: We do not invert texture on Y, already considered inside shader
            BeginShaderMode(shader);
            defer EndShaderMode();

            // WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
            // when rendering the RenderTexture2D to fit in the HighDPI scaled Window
            DrawTextureEx(target.texture, Vector2.{0.0, 0.0}, 0.0, 1.0, WHITE);
        }

        if (showControls) {
            DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, RAYWHITE);
            DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, RAYWHITE);
            DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, RAYWHITE);
            DrawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, RAYWHITE);
            DrawText("Press KEY_SPACE to stop movement animation", 10, 75, 10, RAYWHITE);
            DrawText("Press KEY_R to recenter the camera", 10, 90, 10, RAYWHITE);
        }
        //----------------------------------------------------------------------------------
    }
}