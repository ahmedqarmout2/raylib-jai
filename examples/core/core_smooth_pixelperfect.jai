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

    virtualScreenWidth  : s32 : 160;
    virtualScreenHeight : s32 : 90;

    virtualRatio : float : cast(float)screenWidth/cast(float)virtualScreenWidth;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixelperfect");

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
    destRec   : Rectangle = .{ (screenWidth - screenWidth/1.25)/2.0, (screenHeight - screenHeight/1.25)/2.0, screenWidth/1.25, screenHeight/1.25 };

    origin : Vector2 = .{ 0.0, 0.0 };

    rotation : float = 0.0;

    cameraX : float = 0.0;
    cameraY : float = 0.0;

    smoothOn: bool = true;
    overscan: bool = false;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
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

        if (IsKeyPressed(.KEY_S)) smoothOn = !smoothOn;
        if (IsKeyPressed(.KEY_O)) overscan = !overscan;

        if (overscan)
        {
            destRec = Rectangle.{ -virtualRatio, -virtualRatio, screenWidth + (virtualRatio*2), screenHeight + (virtualRatio*2) };
        }
        else
        {
            destRec = Rectangle.{ (screenWidth - screenWidth/1.25)/2.0, (screenHeight - screenHeight/1.25)/2.0, screenWidth/1.25, screenHeight/1.25 };
        }
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
            ClearBackground(LIGHTGRAY);

            if (smoothOn)
            {
                BeginMode2D(screenSpaceCamera);
                   DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0, WHITE);
                EndMode2D();
            }
            else
            {
                DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0, WHITE);
            }

            DrawText(TextFormat("Screen resolution: %ix%i", screenWidth, screenHeight), 10, 10, 20, DARKBLUE);
            DrawText(TextFormat("World resolution: %ix%i", virtualScreenWidth, virtualScreenHeight), 10, 40, 20, DARKGREEN);
            DrawText(TextFormat("Smooth: %s", temp_c_string(ifx smoothOn then "ON" else "OFF")), 10, screenHeight - 60, 20, RED);
            DrawText(TextFormat("Overscan: %s", temp_c_string(ifx overscan then "ON" else "OFF")), 10, screenHeight - 30, 20, RED);
            DrawFPS(GetScreenWidth() - 95, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}