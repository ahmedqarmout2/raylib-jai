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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - font loading");
    defer CloseWindow(); // Close window and OpenGL context

    // Define characters to draw
    // NOTE: raylib supports UTF-8 encoding, following list is actually codified as UTF8 internally
    msg: [256]char;
    s := "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓ\nÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷\nøùúûüýþÿ";
    for s msg[it_index] = it;

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

    // BMFont (AngelCode) : Font data and image atlas have been generated using external program
    fontBm: Font = LoadFont("resources/pixantiqua.fnt");
    defer UnloadFont(fontBm);     // AngelCode Font unloading

    // TTF font : Font data and atlas are generated directly from TTF
    // NOTE: We define a font base size of 32 pixels tall and up-to 250 characters
    fontTtf: Font = LoadFontEx("resources/pixantiqua.ttf", 32, null, 250);
    defer UnloadFont(fontTtf);    // TTF Font unloading

    SetTextLineSpacing(16);         // Set line spacing for multiline text (when line breaks are included '\n')

    useTtf: bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_SPACE)) useTtf = true;
        else useTtf = false;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("Hold SPACE to use TTF generated font", 20, 20, 20, LIGHTGRAY);

        if (!useTtf) {
            DrawTextEx(fontBm, msg.data, Vector2.{20.0, 100.0}, cast(float)fontBm.baseSize, 2, MAROON);
            DrawText("Using BMFont (Angelcode) imported", 20, GetScreenHeight() - 30, 20, GRAY);
        } else {
            DrawTextEx(fontTtf, msg.data, Vector2.{20.0, 100.0}, cast(float)fontTtf.baseSize, 2, LIME);
            DrawText("Using TTF font generated", 20, GetScreenHeight() - 30, 20, GRAY);
        }
        //----------------------------------------------------------------------------------
    }
}
