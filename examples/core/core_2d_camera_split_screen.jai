#import "raylib";
#import "Math";

PLAYER_SIZE :: 40;

main :: () {
    screenWidth  :: 800;
    screenHeight :: 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera split screen");
    //--------------------------------------------------------------------------------------

    // De-Initialization
    //--------------------------------------------------------------------------------------
    defer CloseWindow();           // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

    player1 : Rectangle = .{ 200, 200, PLAYER_SIZE, PLAYER_SIZE };
    player2 : Rectangle = .{ 250, 200, PLAYER_SIZE, PLAYER_SIZE };

    camera1: Camera2D;
    camera1.target   = Vector2.{ player1.x, player1.y };
    camera1.offset   = Vector2.{ 200.0, 200.0 };
    camera1.rotation = 0.0;
    camera1.zoom     = 1.0;

    camera2: Camera2D;
    camera2.target   = Vector2.{ player2.x, player2.y };
    camera2.offset   = Vector2.{ 200.0, 200.0 };
    camera2.rotation = 0.0;
    camera2.zoom     = 1.0;

    screenCamera1: RenderTexture = LoadRenderTexture(screenWidth/2, screenHeight);
    defer UnloadRenderTexture(screenCamera1); // Unload render texture

    screenCamera2: RenderTexture = LoadRenderTexture(screenWidth/2, screenHeight);
    defer UnloadRenderTexture(screenCamera2); // Unload render texture

    // Build a flipped rectangle the size of the split view to use for drawing later
    splitScreenRect : Rectangle = .{ 0.0, 0.0, xx screenCamera1.texture.width, xx -screenCamera1.texture.height };

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_S))      player1.y += 3.0;
        else if (IsKeyDown(.KEY_W)) player1.y -= 3.0;
        if (IsKeyDown(.KEY_D))      player1.x += 3.0;
        else if (IsKeyDown(.KEY_A)) player1.x -= 3.0;

        if (IsKeyDown(.KEY_UP))        player2.y -= 3.0;
        else if (IsKeyDown(.KEY_DOWN)) player2.y += 3.0;
        if (IsKeyDown(.KEY_RIGHT))     player2.x += 3.0;
        else if (IsKeyDown(.KEY_LEFT)) player2.x -= 3.0;

        camera1.target = Vector2.{ player1.x, player1.y };
        camera2.target = Vector2.{ player2.x, player2.y };
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(screenCamera1);
        ClearBackground(RAYWHITE);

        BeginMode2D(camera1);

        // Draw full scene with first camera
        for i: 0..screenWidth/PLAYER_SIZE {
            DrawLineV(Vector2.{ xx (PLAYER_SIZE*i), 0 }, Vector2.{ xx (PLAYER_SIZE*i), screenHeight }, LIGHTGRAY);
        }

        for i: 0..screenHeight/PLAYER_SIZE {
            DrawLineV(Vector2.{ 0, xx (PLAYER_SIZE*i) }, Vector2.{ screenWidth, xx (PLAYER_SIZE*i) }, LIGHTGRAY);
        }

        for i: 0..screenWidth/PLAYER_SIZE-1 {
            for j: 0..screenHeight/PLAYER_SIZE-1 {
                DrawText(TextFormat("[%i,%i]", i, j), xx (10 + PLAYER_SIZE*i), xx (15 + PLAYER_SIZE*j), 10, LIGHTGRAY);
            }
        }

        DrawRectangleRec(player1, RED);
        DrawRectangleRec(player2, BLUE);
        EndMode2D();
        
        DrawRectangle(0, 0, GetScreenWidth()/2, 30, Fade(RAYWHITE, 0.6));
        DrawText("PLAYER1: W/S/A/D to move", 10, 10, 10, MAROON);
            
        EndTextureMode();

        BeginTextureMode(screenCamera2);
        ClearBackground(RAYWHITE);

        BeginMode2D(camera2);

        // Draw full scene with second camera
        for i: 0..screenWidth/PLAYER_SIZE {
            DrawLineV(Vector2.{ xx (PLAYER_SIZE*i), 0 }, Vector2.{ xx (PLAYER_SIZE*i), screenHeight }, LIGHTGRAY);
        }

        for i: 0..screenHeight/PLAYER_SIZE {
            DrawLineV(Vector2.{ 0, xx (PLAYER_SIZE*i) }, Vector2.{ screenWidth, xx (PLAYER_SIZE*i) }, LIGHTGRAY);
        }

        for i: 0..screenWidth/PLAYER_SIZE-1 {
            for j: 0..screenHeight/PLAYER_SIZE-1 {
                DrawText(TextFormat("[%i,%i]", i, j), xx (10 + PLAYER_SIZE*i), xx (15 + PLAYER_SIZE*j), 10, LIGHTGRAY);
            }
        }

        DrawRectangleRec(player1, RED);
        DrawRectangleRec(player2, BLUE);

        EndMode2D();

        DrawRectangle(0, 0, GetScreenWidth()/2, 30, Fade(RAYWHITE, 0.6));
        DrawText("PLAYER2: UP/DOWN/LEFT/RIGHT to move", 10, 10, 10, DARKBLUE);

        EndTextureMode();

        // Draw both views render textures to the screen side by side
        BeginDrawing();
        ClearBackground(BLACK);

        DrawTextureRec(screenCamera1.texture, splitScreenRect, Vector2.{ 0, 0 }, WHITE);
        DrawTextureRec(screenCamera2.texture, splitScreenRect, Vector2.{ screenWidth/2.0, 0 }, WHITE);
    
        DrawRectangle(GetScreenWidth()/2 - 2, 0, 4, GetScreenHeight(), LIGHTGRAY);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }
}