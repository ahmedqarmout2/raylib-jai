#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - SDF fonts");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

    msg: [50]char;
    s := "Signed Distance Fields";
    for s msg[it_index] = it;

    // Loading file to memory
    fileSize: s32 = 0;
    fileData: *u8 = LoadFileData("resources/anonymous_pro_bold.ttf", *fileSize);

    // Default font generation from TTF font
    fontDefault: Font;
    defer UnloadFont(fontDefault);    // Default font unloading

    fontDefault.baseSize = 16;
    fontDefault.glyphCount = 95;

    // Loading font data from memory data
    // Parameters > font size: 16, no glyphs array provided (0), glyphs count: 95 (autogenerate chars array)
    fontDefault.glyphs = LoadFontData(fileData, fileSize, 16, null, 95, .FONT_DEFAULT);
    // Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 4 px, pack method: 0 (default)
    atlas: Image = GenImageFontAtlas(fontDefault.glyphs, *fontDefault.recs, 95, 16, 4, 0);
    fontDefault.texture = LoadTextureFromImage(atlas);
    UnloadImage(atlas);

    // SDF font generation from TTF font
    fontSDF: Font;
    defer UnloadFont(fontSDF);        // SDF font unloading

    fontSDF.baseSize = 16;
    fontSDF.glyphCount = 95;
    // Parameters > font size: 16, no glyphs array provided (0), glyphs count: 0 (defaults to 95)
    fontSDF.glyphs = LoadFontData(fileData, fileSize, 16, null, 0, .FONT_SDF);
    // Parameters > glyphs count: 95, font size: 16, glyphs padding in image: 0 px, pack method: 1 (Skyline algorythm)
    atlas = GenImageFontAtlas(fontSDF.glyphs, *fontSDF.recs, 95, 16, 0, 1);
    fontSDF.texture = LoadTextureFromImage(atlas);
    UnloadImage(atlas);

    UnloadFileData(fileData);      // Free memory from loaded file

    // Load SDF required shader (we use default vertex shader)
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/sdf.fs", GLSL_VERSION));
    defer UnloadShader(shader);       // Unload SDF shader

    SetTextureFilter(fontSDF.texture, .TEXTURE_FILTER_BILINEAR);    // Required for SDF font

    fontPosition: Vector2 = .{40, screenHeight/2.0 - 50};
    textSize: Vector2 = .{0.0, 0.0};
    fontSize: float = 16.0;
    currentFont: s32 = 0;            // 0 - fontDefault, 1 - fontSDF

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        fontSize += GetMouseWheelMove()*8.0;

        if (fontSize < 6) fontSize = 6;

        if (IsKeyDown(.KEY_SPACE)) currentFont = 1;
        else currentFont = 0;

        if (currentFont == 0) textSize = MeasureTextEx(fontDefault, msg.data, fontSize, 0);
        else textSize = MeasureTextEx(fontSDF, msg.data, fontSize, 0);

        fontPosition.x = GetScreenWidth()/2 - textSize.x/2;
        fontPosition.y = GetScreenHeight()/2 - textSize.y/2 + 80;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        if (currentFont == 1) {
            // NOTE: SDF fonts require a custom SDf shader to compute fragment color
            BeginShaderMode(shader);    // Activate SDF font shader
            DrawTextEx(fontSDF, msg.data, fontPosition, fontSize, 0, BLACK);
            EndShaderMode();            // Activate our default shader for next drawings

            DrawTexture(fontSDF.texture, 10, 10, BLACK);
        } else {
            DrawTextEx(fontDefault, msg.data, fontPosition, fontSize, 0, BLACK);
            DrawTexture(fontDefault.texture, 10, 10, BLACK);
        }

        if (currentFont == 1) DrawText("SDF!", 320, 20, 80, RED);
        else DrawText("default font", 315, 40, 30, GRAY);

        DrawText("FONT SIZE: 16.0", GetScreenWidth() - 240, 20, 20, DARKGRAY);
        DrawText(TextFormat("RENDER SIZE: %02.02f", fontSize), GetScreenWidth() - 240, 50, 20, DARKGRAY);
        DrawText("Use MOUSE WHEEL to SCALE TEXT!", GetScreenWidth() - 240, 90, 10, DARKGRAY);

        DrawText("HOLD SPACE to USE SDF FONT VERSION!", 340, GetScreenHeight() - 30, 20, MAROON);
        //----------------------------------------------------------------------------------
    }
}
