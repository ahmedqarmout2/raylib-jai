#import "raylib";
#import "Basic";
#import "Math";

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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite stacking");

    booth: Texture2D = LoadTexture("resources/booth.png");

    stackScale: float = 3.0; // Overall scale of the stacked sprite
    stackSpacing: float = 2.0; // Vertical spacing between each layer
    stackCount: s32 = 122; // Number of layers, used for calculating the size of a single slice
    rotationSpeed: float = 30.0; // Stacked sprites rotation speed
    rotation: float = 0.0; // Current rotation of the stacked sprite
    speedChange: float = 0.25; // Amount speed will change by when the user presses A/D

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Use mouse wheel to affect stack separation
        stackSpacing += GetMouseWheelMove()*0.1;
        stackSpacing = Clamp(stackSpacing, 0.0, 5.0);

        // Add a positive/negative offset to spin right/left at different speeds
        if (IsKeyDown(.KEY_LEFT) || IsKeyDown(.KEY_A)) rotationSpeed -= speedChange;
        if (IsKeyDown(.KEY_RIGHT) || IsKeyDown(.KEY_D)) rotationSpeed += speedChange;

        rotation += rotationSpeed*GetFrameTime();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Get the size of a single slice
            frameWidth: float = cast(float)booth.width;
            frameHeight: float = cast(float)booth.height/cast(float)stackCount;

            // Get the scaled resolution to draw at
            scaledWidth: float = frameWidth*stackScale;
            scaledHeight: float = frameHeight*stackScale;

            // Draw the stacked sprite, rotated to the correct angle, with an vertical offset applied based on its y location
            i: s32 = stackCount - 1;
            while (i >= 0)
            {
                defer i -= 1;

                // Center vertically
                source: Rectangle = .{ 0.0, cast(float)i*frameHeight, frameWidth, frameHeight };
                dest: Rectangle = .{ screenWidth/2.0, (screenHeight/2.0) + (i*stackSpacing) - (stackSpacing*stackCount/2.0), scaledWidth, scaledHeight };
                origin: Vector2 = .{ scaledWidth/2.0, scaledHeight/2.0 };

                DrawTexturePro(booth, source, dest, origin, rotation, WHITE);
            }

            DrawText("A/D to spin\nmouse wheel to change separation (aka 'angle')", 10, 10, 20, DARKGRAY);
            DrawText(TextFormat("current spacing: %.01f", stackSpacing), 10, 50, 20, DARKGRAY);
            DrawText(TextFormat("current speed: %.02f", rotationSpeed), 10, 70, 20, DARKGRAY);
            DrawText("redbooth model (c) kluchek under cc 4.0", 10, 420, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(booth);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}