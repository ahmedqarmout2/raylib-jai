#import "raylib";
#import "Basic";
#import "Math";

MAX_FRAME_SPEED: s32 : 15;
MIN_FRAME_SPEED: s32 : 1;

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    scarfy: Texture2D = LoadTexture("resources/scarfy.png");        // Texture loading

    position: Vector2   = .{ 350.0, 280.0 };
    frameRec: Rectangle = .{ 0.0, 0.0, cast(float)scarfy.width/6, cast(float)scarfy.height };

    currentFrame  : s32 = 0;
    framesCounter : s32 = 0;
    framesSpeed   : s32 = 8;       // Number of spritesheet frames shown by second

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        framesCounter += 1;

        if (framesCounter >= (60/framesSpeed)) {
            framesCounter = 0;
            currentFrame += 1;

            if (currentFrame > 5) currentFrame = 0;

            frameRec.x = cast(float)currentFrame*cast(float)scarfy.width/6;
        }

        // Control frames speed
        if      (IsKeyPressed(.KEY_RIGHT)) framesSpeed += 1;
        else if (IsKeyPressed(.KEY_LEFT))  framesSpeed -= 1;

        if      (framesSpeed > MAX_FRAME_SPEED) framesSpeed = MAX_FRAME_SPEED;
        else if (framesSpeed < MIN_FRAME_SPEED) framesSpeed = MIN_FRAME_SPEED;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawTexture(scarfy, 15, 40, WHITE);
        DrawRectangleLines(15, 40, scarfy.width, scarfy.height, LIME);
        DrawRectangleLines(15 + cast(s32)frameRec.x, 40 + cast(s32)frameRec.y, cast(s32)frameRec.width, cast(s32)frameRec.height, RED);

        DrawText("FRAME SPEED: ", 165, 210, 10, DARKGRAY);
        DrawText(TextFormat("%02i FPS", framesSpeed), 575, 210, 10, DARKGRAY);
        DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, DARKGRAY);

        for i: 0..MAX_FRAME_SPEED-1 {
            if (i < framesSpeed) DrawRectangle(250 + 21*i, 205, 20, 20, RED);
            DrawRectangleLines(250 + 21*i, 205, 20, 20, MAROON);
        }

        DrawTextureRec(scarfy, frameRec, position, WHITE);  // Draw part of the texture

        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(scarfy);       // Texture unloading
    //--------------------------------------------------------------------------------------
}