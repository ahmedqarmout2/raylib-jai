#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - text writing anim");
    defer CloseWindow(); // Close window and OpenGL context

    message: [128]char;
    copy_string_to_array(message.data, "This sample illustrates a text writing\nanimation effect! Check it out! ;)");

    framesCounter: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_SPACE)) framesCounter += 8;
        else framesCounter +=1 ;

        if (IsKeyPressed(.KEY_ENTER)) framesCounter = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText(TextSubtext(message.data, 0, framesCounter/10), 210, 160, 20, MAROON);

        DrawText("PRESS [ENTER] to RESTART!", 240, 260, 20, LIGHTGRAY);
        DrawText("HOLD [SPACE] to SPEED UP!", 239, 300, 20, LIGHTGRAY);
        //----------------------------------------------------------------------------------
    }
}
