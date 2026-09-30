#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Interaction mode
InteractionMode :: enum s32 {
    MODE_RUN :: 0;
    MODE_PAUSE;
    MODE_DRAW;
};

// Struct to store example preset patterns
PresetPattern :: struct {
    name: *u8;
    position: Vector2;
};

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - game of life");

    menuWidth: s32 = 100;
    windowWidth: s32 = screenWidth - menuWidth;
    windowHeight: s32 = screenHeight;

    worldWidth: s32 = 2048;
    worldHeight: s32 = 2048;

    randomTiles: s32 = 8;      // Random preset: divide the world to compute random points in each tile

    worldRectSource: Rectangle = .{ 0, 0, cast(float)worldWidth, cast(float)-worldHeight };
    worldRectDest: Rectangle = .{ 0, 0, cast(float)worldWidth, cast(float)worldHeight };
    textureOnScreen: Rectangle = .{ 0, 0, cast(float)windowWidth, cast(float)windowHeight };

    numberOfPresets :: 10;
    presetPatterns: [numberOfPresets]PresetPattern = .[
        .{ "Glider", .{ 0.5, 0.5 } }, .{ "R-pentomino", .{ 0.5, 0.5 } }, .{ "Acorn", .{ 0.5,0.5 } },
        .{ "Spaceships", .{ 0.1, 0.5 } }, .{ "Still lifes", .{ 0.5, 0.5 } }, .{ "Oscillators", .{ 0.5, 0.5 } },
        .{ "Puffer train", .{ 0.1, 0.5 } }, .{ "Glider Gun", .{ 0.2, 0.2 } }, .{ "Breeder", .{ 0.1, 0.5 } },
        .{ "Random", .{ 0.5, 0.5 } }
    ];


    zoom: s32 = 1;
    offsetX: float = (worldWidth - windowWidth)/2.0;    // Centered on window
    offsetY: float = (worldHeight - windowHeight)/2.0;  // Centered on window
    framesPerStep: s32 = 1;
    frame: s32 = 0;

    preset: s32 = -1;            // No button pressed for preset
    mode: s32 = cast(s32)InteractionMode.MODE_RUN;        // Starting mode: running
    buttonZoomIn: bool = false;  // Button states: false not pressed
    buttonZomOut: bool = false;
    buttonFaster: bool = false;
    buttonSlower: bool = false;

    // Load shader
    shdrGameOfLife: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/game_of_life.fs", GLSL_VERSION));

    // Set shader uniform size of the world
    resolutionLoc: s32 = GetShaderLocation(shdrGameOfLife, "resolution");
    resolution: [2]float = .[ cast(float)worldWidth, cast(float)worldHeight ];
    SetShaderValue(shdrGameOfLife, resolutionLoc, *resolution, .SHADER_UNIFORM_VEC2);

    // Define two textures: the current world and the previous world
    world1: RenderTexture2D = LoadRenderTexture(worldWidth, worldHeight);
    world2: RenderTexture2D = LoadRenderTexture(worldWidth, worldHeight);
    BeginTextureMode(world2);
        ClearBackground(RAYWHITE);
    EndTextureMode();

    startPattern: Image = LoadImage("resources/game_of_life/r_pentomino.png");
    UpdateTextureRec(world2.texture, Rectangle.{ worldWidth/2.0, worldHeight/2.0, cast(float)(startPattern.width), cast(float)(startPattern.height) }, startPattern.data);
    UnloadImage(startPattern);

    // Pointers to the two textures, to be swapped
    currentWorld: *RenderTexture2D = *world2;
    previousWorld: *RenderTexture2D = *world1;

    // Image to be used in DRAW mode, to be changed with mouse input
    imageToDraw: *Image = null;

    SetTargetFPS(60);               // Set at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        frame += 1;

        // Change zoom: both by buttons or by mouse wheel
        mouseWheelMove: float = GetMouseWheelMove();
        if (buttonZoomIn || (buttonZomOut && (zoom > 1)) || (mouseWheelMove != 0.0))
        {
            FreeImageToDraw(*imageToDraw);  // Zoom change: free the image to draw to be recreated again

            centerX: float = offsetX + (windowWidth/2.0)/zoom;
            centerY: float = offsetY + (windowHeight/2.0)/zoom;
            if (buttonZoomIn || (mouseWheelMove > 0.0)) zoom *= 2;
            if ((buttonZomOut || (mouseWheelMove < 0.0)) && (zoom > 1)) zoom /= 2;
            offsetX = centerX - (windowWidth/2.0)/zoom;
            offsetY = centerY - (windowHeight/2.0)/zoom;
        }

        // Change speed: number of frames per step
        if (buttonFaster && framesPerStep > 1)    framesPerStep -= 1;
        if (buttonSlower)                         framesPerStep += 1;

        // Mouse management
        if ((mode == cast(s32)InteractionMode.MODE_RUN) || (mode == cast(s32)InteractionMode.MODE_PAUSE))
        {
            FreeImageToDraw(*imageToDraw);  // Free the image to draw: no longer needed in these modes

            // Pan with mouse left button
            previousMousePosition: Vector2 = .{ 0.0, 0.0 };
            mousePosition: Vector2 = GetMousePosition();
            if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) && (mousePosition.x < windowWidth * 1.0))
            {
                offsetX -= (mousePosition.x - previousMousePosition.x)/zoom;
                offsetY -= (mousePosition.y - previousMousePosition.y)/zoom;
            }
            previousMousePosition = mousePosition;
        }
        else // MODE_DRAW
        {
            offsetDecimalX: float = offsetX - floor(offsetX);
            offsetDecimalY: float = offsetY - floor(offsetY);
            sizeInWorldX: s32 = cast(s32)(ceil(cast(float)(windowWidth + offsetDecimalX*zoom)/zoom));
            sizeInWorldY: s32 = cast(s32)(ceil(cast(float)(windowHeight + offsetDecimalY*zoom)/zoom));
            if (offsetX + sizeInWorldX >= worldWidth * 1.0) sizeInWorldX = worldWidth - cast(s32)floor(offsetX);
            if (offsetY + sizeInWorldY >= worldHeight * 1.0) sizeInWorldY = worldHeight - cast(s32)floor(offsetY);

            // Create image to draw if not created yet
            if (imageToDraw == null)
            {
                worldOnScreen: RenderTexture2D = LoadRenderTexture(sizeInWorldX, sizeInWorldY);
                BeginTextureMode(worldOnScreen);
                    DrawTexturePro(currentWorld.texture, Rectangle.{ floor(offsetX), floor(offsetY), cast(float)(sizeInWorldX), -cast(float)(sizeInWorldY) },
                            Rectangle.{ 0, 0, cast(float)(sizeInWorldX), cast(float)(sizeInWorldY) }, Vector2.{ 0, 0 }, 0.0, WHITE);
                EndTextureMode();
                imageToDraw = cast(*Image)alloc(size_of(Image));
                (.*)imageToDraw = LoadImageFromTexture(worldOnScreen.texture);

                UnloadRenderTexture(worldOnScreen);
            }

            mousePosition: Vector2 = GetMousePosition();
            firstColor: s32 = -1;
            if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) && (mousePosition.x < windowWidth * 1.0))
            {
                mouseX: s32 = cast(s32)(mousePosition.x + offsetDecimalX*zoom)/zoom;
                mouseY: s32 = cast(s32)(mousePosition.y + offsetDecimalY*zoom)/zoom;
                if (mouseX >= sizeInWorldX) mouseX = sizeInWorldX - 1;
                if (mouseY >= sizeInWorldY) mouseY = sizeInWorldY - 1;
                if (firstColor == -1) firstColor = cast(s32)(ifx (GetImageColor((.*)imageToDraw, mouseX, mouseY).r < 5) then 0 else 1);
                prevColor: s32 = cast(s32)(ifx (GetImageColor((.*)imageToDraw, mouseX, mouseY).r < 5) then 0 else 1);

                ImageDrawPixel(imageToDraw, mouseX, mouseY, ifx (firstColor) then BLACK else RAYWHITE);

                if (prevColor != firstColor) UpdateTextureRec(currentWorld.texture, Rectangle.{ floor(offsetX), floor(offsetY), cast(float)(sizeInWorldX), cast(float)(sizeInWorldY) }, imageToDraw.data);
            }
            else firstColor = -1;
        }

        // Load selected preset
        if (preset >= 0)
        {
            pattern: Image;
            if (preset < numberOfPresets - 1)   // Preset with pattern image lo load
            {
                if preset ==
                {
                    case 0; pattern = LoadImage("resources/game_of_life/glider.png");
                    case 1; pattern = LoadImage("resources/game_of_life/r_pentomino.png");
                    case 2; pattern = LoadImage("resources/game_of_life/acorn.png");
                    case 3; pattern = LoadImage("resources/game_of_life/spaceships.png");
                    case 4; pattern = LoadImage("resources/game_of_life/still_lifes.png");
                    case 5; pattern = LoadImage("resources/game_of_life/oscillators.png");
                    case 6; pattern = LoadImage("resources/game_of_life/puffer_train.png");
                    case 7; pattern = LoadImage("resources/game_of_life/glider_gun.png");
                    case 8; pattern = LoadImage("resources/game_of_life/breeder.png");
                }
                BeginTextureMode((.*)currentWorld);
                    ClearBackground(RAYWHITE);
                EndTextureMode();

                UpdateTextureRec(currentWorld.texture, Rectangle.{ worldWidth*presetPatterns[preset].position.x - pattern.width/2.0,
                                                                     worldHeight*presetPatterns[preset].position.y - pattern.height/2.0,
                                                                     cast(float)(pattern.width), cast(float)(pattern.height) }, pattern.data);
            }
            else    // Last preset: Random values
            {
                pattern = GenImageColor(worldWidth/randomTiles, worldHeight/randomTiles, RAYWHITE);
                for i: 0..randomTiles-1
                {
                    for j: 0..randomTiles-1
                    {
                        ImageClearBackground(*pattern, RAYWHITE);
                        for x: 0..pattern.width-1
                        {
                            for y: 0..pattern.height
                            {
                                if (GetRandomValue(0, 100) < 15) ImageDrawPixel(*pattern, x, y, BLACK);
                            }
                        }
                        UpdateTextureRec(currentWorld.texture,
                                         Rectangle.{ cast(float)(pattern.width*i), cast(float)(pattern.height*j),
                                                      cast(float)(pattern.width), cast(float)(pattern.height) }, pattern.data);
                    }
                }
            }

            UnloadImage(pattern);

            mode = cast(s32)InteractionMode.MODE_PAUSE;
            offsetX = worldWidth*presetPatterns[preset].position.x - cast(float)windowWidth/zoom/2.0;
            offsetY = worldHeight*presetPatterns[preset].position.y - cast(float)windowHeight/zoom/2.0;
        }

        // Check window draw inside world limits
        if (offsetX < 0) offsetX = 0;
        if (offsetY < 0) offsetY = 0;
        if (offsetX > worldWidth - cast(float)(windowWidth)/zoom) offsetX = worldWidth - cast(float)(windowWidth)/zoom;
        if (offsetY > worldHeight - cast(float)(windowHeight)/zoom) offsetY = worldHeight - cast(float)(windowHeight)/zoom;

        // Rectangles for drawing texture portion to screen
        textureSourceToScreen: Rectangle = .{ offsetX, offsetY, cast(float)windowWidth/zoom, cast(float)windowHeight/zoom };
        //----------------------------------------------------------------------------------

        // Draw to texture
        //----------------------------------------------------------------------------------
        if ((mode == cast(s32)InteractionMode.MODE_RUN) && ((frame%framesPerStep) == 0))
        {
            // Swap worlds
            tempWorld: *RenderTexture2D = currentWorld;
            currentWorld = previousWorld;
            previousWorld = tempWorld;

            // Draw to texture
            BeginTextureMode((.*)currentWorld);
                BeginShaderMode(shdrGameOfLife);
                    DrawTexturePro(previousWorld.texture, worldRectSource, worldRectDest, Vector2.{ 0, 0 }, 0.0, RAYWHITE);
                EndShaderMode();
            EndTextureMode();
        }
        //----------------------------------------------------------------------------------

        // Draw to screen
        //----------------------------------------------------------------------------------
        BeginDrawing();

            DrawTexturePro(currentWorld.texture, textureSourceToScreen, textureOnScreen, Vector2.{ 0, 0 }, 0.0, WHITE);

            DrawLine(windowWidth, 0, windowWidth, screenHeight, Color.{ 218, 218, 218, 255 });
            DrawRectangle(windowWidth, 0, screenWidth - windowWidth, screenHeight, Color.{ 232, 232, 232, 255 });

            DrawText("Conway's", 704, 4, 20, DARKBLUE);
            DrawText(" game of", 704, 19, 20, DARKBLUE);
            DrawText("  life", 708, 34, 20, DARKBLUE);
            DrawText("in raylib", 757, 42, 6, BLACK);

            DrawText("Presets", 710, 58, 8, GRAY);
            preset = -1;
            for i: 0..numberOfPresets-1
                if (GuiButton(Rectangle.{ 710.0, 70.0 + 18*i, 80.0, 16.0 }, presetPatterns[i].name)) preset = cast(s32)i;

            GuiToggleGroup(Rectangle.{ 710, 258, 80, 16 }, "Run\nPause\nDraw", *mode);

            DrawText(TextFormat("Zoom: %ix", zoom), 710, 316, 8, GRAY);
            buttonZoomIn = GuiButton(Rectangle.{ 710, 328, 80, 16 }, "Zoom in") == .RESULT_PRESSED;
            buttonZomOut = GuiButton(Rectangle.{ 710, 346, 80, 16 }, "Zoom out") == .RESULT_PRESSED;

            DrawText(TextFormat("Speed: %i frame%s", framesPerStep, temp_c_string(ifx (framesPerStep > 1) then "s" else "")), 710, 370, 8, GRAY);
            buttonFaster = GuiButton(Rectangle.{ 710, 382, 80, 16 }, "Faster") == .RESULT_PRESSED;
            buttonSlower = GuiButton(Rectangle.{ 710, 400, 80, 16 }, "Slower") == .RESULT_PRESSED;

            DrawFPS(712, 426);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shdrGameOfLife);
    UnloadRenderTexture(world1);
    UnloadRenderTexture(world2);

    FreeImageToDraw(*imageToDraw);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Functions definition
//----------------------------------------------------------------------------------
FreeImageToDraw :: (imageToDraw: **Image)
{
    if ((.*)imageToDraw != null)
    {
        UnloadImage((.*)imageToDraw);
        free((.*)imageToDraw);
        (.*)imageToDraw = null;
    }
}
