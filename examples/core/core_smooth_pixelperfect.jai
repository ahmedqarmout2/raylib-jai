#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    virtualScreenWidth  : s32 : 160;
    virtualScreenHeight : s32 : 90;

    virtualRatio : float : cast(float)screenWidth/cast(float)virtualScreenWidth;


    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixel-perfect camera");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    worldSpaceCamera: Camera2D;  // Game world camera
    worldSpaceCamera.zoom = 1.0;

    screenSpaceCamera: Camera2D; // Smoothing camera
    screenSpaceCamera.zoom = 1.0;

    target: RenderTexture2D = LoadRenderTexture(virtualScreenWidth, virtualScreenHeight); // This is where we'll draw all our objects.

    rec01 : Rectangle = .{ 70.0, 35.0, 20.0, 20.0 };
    rec02 : Rectangle = .{ 90.0, 55.0, 30.0, 10.0 };
    rec03 : Rectangle = .{ 80.0, 65.0, 15.0, 25.0 };

    // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
    sourceRec : Rectangle = .{ 0.0, 0.0, cast(float)target.texture.width, -cast(float)target.texture.height };
    destRec   : Rectangle = .{ -virtualRatio, -virtualRatio, screenWidth + (virtualRatio*2), screenHeight + (virtualRatio*2) };

    origin : Vector2 = .{ 0.0, 0.0 };

    rotation : float = 0.0;

    cameraX : float = 0.0;
    cameraY : float = 0.0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        rotation += 60.0*GetFrameTime();   // Rotate the rectangles, 60 degrees per second

        // Make the camera move to demonstrate the effect
        cameraX = cast(float)sin(GetTime())*50.0 - 10.0;
        cameraY = cast(float)cos(GetTime())*30.0;

        // Set the camera's target to the values computed above
        screenSpaceCamera.target = Vector2.{ cameraX, cameraY };

        // Round worldSpace coordinates, keep decimals into screenSpace coordinates
        worldSpaceCamera.target.x   = screenSpaceCamera.target.x;
        screenSpaceCamera.target.x -= worldSpaceCamera.target.x;
        screenSpaceCamera.target.x *= virtualRatio;

        worldSpaceCamera.target.y   = screenSpaceCamera.target.y;
        screenSpaceCamera.target.y -= worldSpaceCamera.target.y;
        screenSpaceCamera.target.y *= virtualRatio;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
        ClearBackground(RAYWHITE);

        BeginMode2D(worldSpaceCamera);
        DrawRectanglePro(rec01, origin, rotation, BLACK);
        DrawRectanglePro(rec02, origin, -rotation, RED);
        DrawRectanglePro(rec03, origin, rotation + 45.0, BLUE);
        EndMode2D();
        EndTextureMode();

        BeginDrawing();
        ClearBackground(RED);

        BeginMode2D(screenSpaceCamera);
        DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0, WHITE);
        EndMode2D();

        DrawText(TextFormat("Screen resolution: %ix%i", screenWidth, screenHeight), 10, 10, 20, DARKBLUE);
        DrawText(TextFormat("World resolution: %ix%i", virtualScreenWidth, virtualScreenHeight), 10, 40, 20, DARKGREEN);
        DrawFPS(GetScreenWidth() - 95, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture
    //--------------------------------------------------------------------------------------
}