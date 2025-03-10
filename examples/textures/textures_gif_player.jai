#import "raylib";
#import "Basic";

MAX_FRAME_DELAY: s32 : 20;
MIN_FRAME_DELAY: s32 : 1;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - gif playing");
    defer CloseWindow(); // Close window and OpenGL context

    animFrames: s32 = 0;

    // Load all GIF animation frames into a single Image
    // NOTE: GIF data is always loaded as RGBA (32bit) by default
    // NOTE: Frames are just appended one after another in image.data memory
    imScarfyAnim: Image = LoadImageAnim("resources/scarfy_run.gif", *animFrames);
    defer UnloadImage(imScarfyAnim);      // Unload image (contains all frames)

    // Load texture from image
    // NOTE: We will update this texture when required with next frame data
    // WARNING: It's not recommended to use this technique for sprites animation,
    // use spritesheets instead, like illustrated in textures_sprite_anim example
    texScarfyAnim: Texture2D = LoadTextureFromImage(imScarfyAnim);
    defer UnloadTexture(texScarfyAnim);   // Unload texture

    nextFrameDataOffset: u32 = 0;  // Current byte offset to next frame in image.data

    currentAnimFrame : s32 = 0;    // Current animation frame to load and draw
    frameDelay       : s32 = 8;    // Frame delay to switch between animation frames
    frameCounter     : s32 = 0;    // General frames counter

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        frameCounter += 1;
        if (frameCounter >= frameDelay) {
            // Move to next frame
            // NOTE: If final frame is reached we return to first frame
            currentAnimFrame += 1;
            if (currentAnimFrame >= animFrames) currentAnimFrame = 0;

            // Get memory offset position for next frame data in image.data
            nextFrameDataOffset = cast(u32)(imScarfyAnim.width*imScarfyAnim.height*4*currentAnimFrame);

            // Update GPU texture data with next frame image data
            // WARNING: Data size (frame size) and pixel format must match already created texture
            UpdateTexture(texScarfyAnim, (cast(*u8)imScarfyAnim.data) + nextFrameDataOffset);

            frameCounter = 0;
        }

        // Control frames delay
        if (IsKeyPressed(.KEY_RIGHT))     frameDelay += 1;
        else if (IsKeyPressed(.KEY_LEFT)) frameDelay -= 1;

        if (frameDelay > MAX_FRAME_DELAY)      frameDelay = MAX_FRAME_DELAY;
        else if (frameDelay < MIN_FRAME_DELAY) frameDelay = MIN_FRAME_DELAY;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText(TextFormat("TOTAL GIF FRAMES:  %02i", animFrames), 50, 30, 20, LIGHTGRAY);
        DrawText(TextFormat("CURRENT FRAME: %02i", currentAnimFrame), 50, 60, 20, GRAY);
        DrawText(TextFormat("CURRENT FRAME IMAGE.DATA OFFSET: %02i", nextFrameDataOffset), 50, 90, 20, GRAY);

        DrawText("FRAMES DELAY: ", 100, 305, 10, DARKGRAY);
        DrawText(TextFormat("%02i frames", frameDelay), 620, 305, 10, DARKGRAY);
        DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 350, 10, DARKGRAY);

        for i: 0..MAX_FRAME_DELAY-1 {
            if (i < frameDelay) DrawRectangle(190 + 21*i, 300, 20, 20, RED);
            DrawRectangleLines(190 + 21*i, 300, 20, 20, MAROON);
        }

        DrawTexture(texScarfyAnim, GetScreenWidth()/2 - texScarfyAnim.width/2, 140, WHITE);

        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY);
        //----------------------------------------------------------------------------------
    }
}