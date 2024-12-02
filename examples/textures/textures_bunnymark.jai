#import "raylib";
#import "Basic";
#import "Math";

MAX_BUNNIES: s32 : 50000;    // 50K bunnies limit

// This is the maximum amount of elements (quads) per batch
// NOTE: This value is defined in [rlgl] module and can be changed there
MAX_BATCH_ELEMENTS: s32 : 8192;

Bunny :: struct {
    position : Vector2;
    speed    : Vector2;
    color    : Color;
};

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark");
    defer CloseWindow(); // Close window and OpenGL context

    // Load bunny texture
    texBunny: Texture2D = LoadTexture("resources/wabbit_alpha.png");
    defer UnloadTexture(texBunny);    // Unload bunny texture

    bunnies: [..]Bunny;    // Bunnies array
    array_resize(*bunnies, MAX_BUNNIES);
    defer array_free(bunnies);        // Unload bunnies data array

    bunniesCount: s32 = 0;         // Bunnies counter

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
            // Create more bunnies
            for i: 0..99 {
                if (bunniesCount < MAX_BUNNIES) {
                    bunnies[bunniesCount].position = GetMousePosition();
                    bunnies[bunniesCount].speed.x  = cast(float)GetRandomValue(-250, 250)/60.0;
                    bunnies[bunniesCount].speed.y  = cast(float)GetRandomValue(-250, 250)/60.0;
                    bunnies[bunniesCount].color    = Color.{
                        cast(u8)GetRandomValue(50, 240),
                        cast(u8) GetRandomValue(80, 240),
                        cast(u8) GetRandomValue(100, 240),
                        255 };
                    bunniesCount += 1;
                }
            }
        }

        // Update bunnies
        for i: 0..bunniesCount-1 {
            bunnies[i].position.x += bunnies[i].speed.x;
            bunnies[i].position.y += bunnies[i].speed.y;

            if (((bunnies[i].position.x + texBunny.width/2) > cast(float)GetScreenWidth()) ||
                ((bunnies[i].position.x + texBunny.width/2) < 0)) bunnies[i].speed.x *= -1;
            if (((bunnies[i].position.y + texBunny.height/2) > cast(float)GetScreenHeight()) ||
                ((bunnies[i].position.y + texBunny.height/2 - 40) < 0)) bunnies[i].speed.y *= -1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        for i: 0..bunniesCount-1 {
            // NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
            // a draw call is launched and buffer starts being filled again;
            // before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
            // Process of sending data is costly and it could happen that GPU data has not been completely
            // processed for drawing while new data is tried to be sent (updating current in-use buffers)
            // it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
            DrawTexture(texBunny, cast(s32)bunnies[i].position.x, cast(s32)bunnies[i].position.y, bunnies[i].color);
        }

        DrawRectangle(0, 0, screenWidth, 40, BLACK);
        DrawText(TextFormat("bunnies: %i", bunniesCount), 120, 10, 20, GREEN);
        DrawText(TextFormat("batched draw calls: %i", 1 + bunniesCount/MAX_BATCH_ELEMENTS), 320, 10, 20, MAROON);

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}