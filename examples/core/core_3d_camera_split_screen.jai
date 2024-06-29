#import "raylib";
#import "Math";

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera split screen");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();         // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    // Setup player 1 camera and screen
    cameraPlayer1: Camera;
    cameraPlayer1.fovy = 45.0;
    cameraPlayer1.up.y = 1.0;
    cameraPlayer1.target.y = 1.0;
    cameraPlayer1.position.z = -3.0;
    cameraPlayer1.position.y = 1.0;

    screenPlayer1 : RenderTexture2D = LoadRenderTexture(screenWidth/2, screenHeight);
    defer UnloadRenderTexture(screenPlayer1); // Unload render texture

    // Setup player two camera and screen
    cameraPlayer2: Camera;
    cameraPlayer2.fovy = 45.0;
    cameraPlayer2.up.y = 1.0;
    cameraPlayer2.target.y = 3.0;
    cameraPlayer2.position.x = -3.0;
    cameraPlayer2.position.y = 3.0;

    screenPlayer2 : RenderTexture2D = LoadRenderTexture(screenWidth / 2, screenHeight);
    defer UnloadRenderTexture(screenPlayer2); // Unload render texture

    // Build a flipped rectangle the size of the split view to use for drawing later
    splitScreenRect : Rectangle = .{ 0.0, 0.0, cast(float)screenPlayer1.texture.width, cast(float)-screenPlayer1.texture.height };
    
    // Grid data
    count   : s32   = 5;
    spacing : float = 4;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // If anyone moves this frame, how far will they move based on the time since the last frame
        // this moves thigns at 10 world units per second, regardless of the actual FPS
        offsetThisFrame : float = 10.0*GetFrameTime();

        // Move Player1 forward and backwards (no turning)
        if (IsKeyDown(.KEY_W)) {
            cameraPlayer1.position.z += offsetThisFrame;
            cameraPlayer1.target.z   += offsetThisFrame;
        } else if (IsKeyDown(.KEY_S)) {
            cameraPlayer1.position.z -= offsetThisFrame;
            cameraPlayer1.target.z   -= offsetThisFrame;
        }

        // Move Player2 forward and backwards (no turning)
        if (IsKeyDown(.KEY_UP)) {
            cameraPlayer2.position.x += offsetThisFrame;
            cameraPlayer2.target.x   += offsetThisFrame;
        } else if (IsKeyDown(.KEY_DOWN)) {
            cameraPlayer2.position.x -= offsetThisFrame;
            cameraPlayer2.target.x   -= offsetThisFrame;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            // Draw Player1 view to the render texture
            BeginTextureMode(screenPlayer1);
            ClearBackground(SKYBLUE);

            BeginMode3D(cameraPlayer1);

            // Draw scene: grid of cube trees on a plane to make a "world"
            DrawPlane(Vector3.{ 0, 0, 0 }, Vector2.{ 50, 50 }, BEIGE); // Simple world plane

            x : float = -count*spacing;
            while (x <= count*spacing) {
                defer x += spacing;

                z : float = -count*spacing;
                while (z <= count*spacing) {
                    defer z += spacing;

                    DrawCube(Vector3.{ x, 1.5, z }, 1, 1, 1, LIME);
                    DrawCube(Vector3.{ x, 0.5, z }, 0.25, 1, 0.25, BROWN);
                }
            }

            // Draw a cube at each player's position
            DrawCube(cameraPlayer1.position, 1, 1, 1, RED);
            DrawCube(cameraPlayer2.position, 1, 1, 1, BLUE);

            EndMode3D();

            DrawRectangle(0, 0, GetScreenWidth()/2, 40, Fade(RAYWHITE, 0.8));
            DrawText("PLAYER1: W/S to move", 10, 10, 20, MAROON);

            EndTextureMode();
        }

        {
            // Draw Player2 view to the render texture
            BeginTextureMode(screenPlayer2);
            ClearBackground(SKYBLUE);

            BeginMode3D(cameraPlayer2);

            // Draw scene: grid of cube trees on a plane to make a "world"
            DrawPlane(Vector3.{ 0, 0, 0 }, Vector2.{ 50, 50 }, BEIGE); // Simple world plane

            x : float = -count*spacing;
            while (x <= count*spacing) {
                defer x += spacing;

                z : float = -count*spacing;
                while (z <= count*spacing) {
                    defer z += spacing;

                    DrawCube(Vector3.{ x, 1.5, z }, 1, 1, 1, LIME);
                    DrawCube(Vector3.{ x, 0.5, z }, 0.25, 1, 0.25, BROWN);
                }
            }

            // Draw a cube at each player's position
            DrawCube(cameraPlayer1.position, 1, 1, 1, RED);
            DrawCube(cameraPlayer2.position, 1, 1, 1, BLUE);

            EndMode3D();

            DrawRectangle(0, 0, GetScreenWidth()/2, 40, Fade(RAYWHITE, 0.8));
            DrawText("PLAYER2: UP/DOWN to move", 10, 10, 20, DARKBLUE);

            EndTextureMode();
        }

        // Draw both views render textures to the screen side by side
        BeginDrawing();
        ClearBackground(BLACK);

        DrawTextureRec(screenPlayer1.texture, splitScreenRect, Vector2.{ 0, 0 }, WHITE);
        DrawTextureRec(screenPlayer2.texture, splitScreenRect, Vector2.{ screenWidth/2.0, 0 }, WHITE);

        DrawRectangle(GetScreenWidth()/2 - 2, 0, 4, GetScreenHeight(), LIGHTGRAY);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}