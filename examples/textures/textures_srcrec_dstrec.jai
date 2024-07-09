#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] examples - texture source and destination rectangles");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    scarfy: Texture2D = LoadTexture("resources/scarfy.png");        // Texture loading

    frameWidth  : s32 = scarfy.width/6;
    frameHeight : s32 = scarfy.height;

    // Source rectangle (part of the texture to use for drawing)
    sourceRec: Rectangle = .{ 0.0, 0.0, cast(float)frameWidth, cast(float)frameHeight };

    // Destination rectangle (screen rectangle where drawing part of texture)
    destRec: Rectangle = .{ screenWidth/2.0, screenHeight/2.0, frameWidth*2.0, frameHeight*2.0 };

    // Origin of the texture (rotation/scale point), it's relative to destination rectangle size
    origin: Vector2 = .{ cast(float)frameWidth, cast(float)frameHeight };

    rotation: s32 = 0;

    SetTargetFPS(60);

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        rotation += 1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        // NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
        // sourceRec defines the part of the texture we use for drawing
        // destRec defines the rectangle where our texture part will fit (scaling it to fit)
        // origin defines the point of the texture used as reference for rotation and scaling
        // rotation defines the texture rotation (using origin as rotation point)
        DrawTexturePro(scarfy, sourceRec, destRec, origin, cast(float)rotation, WHITE);

        DrawLine(cast(s32)destRec.x, 0, cast(s32)destRec.x, screenHeight, GRAY);
        DrawLine(0, cast(s32)destRec.y, screenWidth, cast(s32)destRec.y, GRAY);

        DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(scarfy);        // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}