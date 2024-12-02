#import "raylib";
#import "Basic";
#import "Math";

MAX_BUILDINGS : s32 : 100;

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera");
    defer CloseWindow(); // Close window and OpenGL context

    player : Rectangle = .{400, 280, 40, 40};
    buildings: [MAX_BUILDINGS]Rectangle;
    buildColors: [MAX_BUILDINGS]Color;

    spacing : s32 = 0;

    for i: 0..MAX_BUILDINGS-1 {
        buildings[i].width  = cast(float)GetRandomValue(50, 200);
        buildings[i].height = cast(float)GetRandomValue(100, 800);
        buildings[i].y = screenHeight - 130.0 - buildings[i].height;
        buildings[i].x = -6000.0 + spacing;

        spacing += cast(s32)buildings[i].width;

        buildColors[i] = Color.{ cast(u8)GetRandomValue(200, 240), cast(u8)GetRandomValue(200, 240), cast(u8)GetRandomValue(200, 250), 255 };
    }

    camera: Camera2D;
    camera.target = Vector2.{player.x + 20.0, player.y + 20.0};
    camera.offset = Vector2.{screenWidth/2.0, screenHeight/2.0};
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Player movement
        if (IsKeyDown(.KEY_RIGHT)) player.x += 2;
        else if (IsKeyDown(.KEY_LEFT)) player.x -= 2;

        // Camera target follows player
        camera.target = Vector2.{player.x + 20, player.y + 20};

        // Camera rotation controls
        if (IsKeyDown(.KEY_A)) camera.rotation -= 1;
        else if (IsKeyDown(.KEY_S)) camera.rotation += 1;

        // Limit camera rotation to 80 degrees (-40 to 40)
        if (camera.rotation > 40) camera.rotation = 40;
        else if (camera.rotation < -40) camera.rotation = -40;

        // Camera zoom controls
        camera.zoom += cast(float)(GetMouseWheelMove() * 0.05);

        if (camera.zoom > 3.0) camera.zoom = 3.0;
        else if (camera.zoom < 0.1) camera.zoom = 0.1;

        // Camera reset (zoom and rotation)
        if (IsKeyPressed(.KEY_R)) {
            camera.zoom = 1.0;
            camera.rotation = 0.0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(RAYWHITE);

            {
                BeginMode2D(camera);
                defer EndMode2D();

                DrawRectangle(-6000, 320, 13000, 8000, DARKGRAY);

                for i: 0..MAX_BUILDINGS-1 DrawRectangleRec(buildings[i], buildColors[i]);

                DrawRectangleRec(player, RED);

                DrawLine(cast(s32)camera.target.x, -screenHeight * 10, cast(s32)camera.target.x, screenHeight * 10, GREEN);
                DrawLine(-screenWidth * 10, cast(s32)camera.target.y, screenWidth * 10, cast(s32)camera.target.y, GREEN);
            }

            DrawText("SCREEN AREA", 640, 10, 20, RED);

            DrawRectangle(0, 0, screenWidth, 5, RED);
            DrawRectangle(0, 5, 5, screenHeight - 10, RED);
            DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, RED);
            DrawRectangle(0, screenHeight - 5, screenWidth, 5, RED);

            DrawRectangle( 10, 10, 250, 113, Fade(SKYBLUE, 0.5));
            DrawRectangleLines( 10, 10, 250, 113, BLUE);

            DrawText("Free 2d camera controls:", 20, 20, 10, BLACK);
            DrawText("- Right/Left to move Offset", 40, 40, 10, DARKGRAY);
            DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY);
            DrawText("- A / S to Rotate", 40, 80, 10, DARKGRAY);
            DrawText("- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}