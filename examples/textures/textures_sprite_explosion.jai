#import "raylib";
#import "Basic";
#import "Math";

NUM_FRAMES_PER_LINE : s32 : 5;
NUM_LINES           : s32 : 5;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite explosion");
    defer CloseWindow(); // Close window and OpenGL context

    InitAudioDevice();
    defer CloseAudioDevice();

    // Load explosion sound
    fxBoom: Sound = LoadSound("resources/boom.wav");
    defer UnloadSound(fxBoom);        // Unload sound

    // Load explosion texture
    explosion: Texture2D = LoadTexture("resources/explosion.png");
    defer UnloadTexture(explosion);   // Unload texture

    // Init variables for animation
    frameWidth   : float = cast(float)(explosion.width/NUM_FRAMES_PER_LINE);   // Sprite one frame rectangle width
    frameHeight  : float = cast(float)(explosion.height/NUM_LINES);           // Sprite one frame rectangle height
    currentFrame : s32   = 0;
    currentLine  : s32   = 0;

    frameRec: Rectangle = .{ 0, 0, frameWidth, frameHeight };
    position: Vector2   = .{ 0.0, 0.0 };

    active: bool = false;
    framesCounter: s32 = 0;

    SetTargetFPS(120);
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Check for mouse button pressed and activate explosion (if not active)
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && !active) {
            position = GetMousePosition();
            active = true;

            position.x -= frameWidth/2.0;
            position.y -= frameHeight/2.0;

            PlaySound(fxBoom);
        }

        // Compute explosion animation frames
        if (active) {
            framesCounter += 1;

            if (framesCounter > 2) {
                currentFrame += 1;

                if (currentFrame >= NUM_FRAMES_PER_LINE) {
                    currentFrame = 0;
                    currentLine += 1;

                    if (currentLine >= NUM_LINES) {
                        currentLine = 0;
                        active = false;
                    }
                }

                framesCounter = 0;
            }
        }

        frameRec.x = frameWidth*currentFrame;
        frameRec.y = frameHeight*currentLine;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        // Draw explosion required frame rectangle
        if (active) DrawTextureRec(explosion, frameRec, position, WHITE);
        //----------------------------------------------------------------------------------
    }
}