#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

MAX_FONTS :: 8;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - raylib fonts");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    fonts: [MAX_FONTS]Font;

    fonts[0] = LoadFont("resources/fonts/alagard.png");
    fonts[1] = LoadFont("resources/fonts/pixelplay.png");
    fonts[2] = LoadFont("resources/fonts/mecha.png");
    fonts[3] = LoadFont("resources/fonts/setback.png");
    fonts[4] = LoadFont("resources/fonts/romulus.png");
    fonts[5] = LoadFont("resources/fonts/pixantiqua.png");
    fonts[6] = LoadFont("resources/fonts/alpha_beta.png");
    fonts[7] = LoadFont("resources/fonts/jupiter_crash.png");

    messages: [MAX_FONTS][..]char;
    s: [MAX_FONTS]string = .[
        "ALAGARD FONT designed by Hewett Tsoi",
        "PIXELPLAY FONT designed by Aleksander Shevchuk",
        "MECHA FONT designed by Captain Falcon",
        "SETBACK FONT designed by Brian Kent (AEnigma)",
        "ROMULUS FONT designed by Hewett Tsoi",
        "PIXANTIQUA FONT designed by Gerhard Grossmann",
        "ALPHA_BETA FONT designed by Brian Kent (AEnigma)",
        "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)" ];
    
    for i: 0..s.count-1 {
        array_resize(*messages[i], s[i].count);
        for j: 0..s[i].count-1 {
            messages[i][j] = s[i][j];
        }
    }

    defer {
        // Fonts unloading
        for i: 0..MAX_FONTS-1 UnloadFont(fonts[i]);
        for i: 0..MAX_FONTS-1 array_free(messages[i]);
    }

    spacings: [MAX_FONTS]s32 = .[2, 4, 8, 4, 3, 4, 4, 1];

    positions: [MAX_FONTS]Vector2;

    for i: 0..MAX_FONTS-1 {
        positions[i].x = screenWidth/2.0 - MeasureTextEx(fonts[i], messages[i].data, fonts[i].baseSize*2.0, cast(float)spacings[i]).x/2.0;
        positions[i].y = 60.0 + fonts[i].baseSize + 45.0*i;
    }

    // Small Y position corrections
    positions[3].y += 8;
    positions[4].y += 2;
    positions[7].y -= 8;

    colors: [MAX_FONTS]Color = .[MAROON, ORANGE, DARKGREEN, DARKBLUE, DARKPURPLE, LIME, GOLD, RED];

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawText("free fonts included with raylib", 250, 20, 20, DARKGRAY);
        DrawLine(220, 50, 590, 50, DARKGRAY);

        for i: 0..MAX_FONTS-1 {
            DrawTextEx(fonts[i], messages[i].data, positions[i], fonts[i].baseSize*2.0, cast(float)spacings[i], colors[i]);
        }
        //----------------------------------------------------------------------------------
    }
}
