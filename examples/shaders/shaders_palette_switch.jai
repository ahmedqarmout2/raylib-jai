#import "raylib";
#import "Basic";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_PALETTES       :: 3;
COLORS_PER_PALETTE :: 8;
VALUES_PER_COLOR   :: 3;

palettes: [MAX_PALETTES][COLORS_PER_PALETTE*VALUES_PER_COLOR]s32 = .[
    .[   // 3-BIT RGB
        0, 0, 0,
        255, 0, 0,
        0, 255, 0,
        0, 0, 255,
        0, 255, 255,
        255, 0, 255,
        255, 255, 0,
        255, 255, 255,
    ],
    .[   // AMMO-8 (GameBoy-like)
        4, 12, 6,
        17, 35, 24,
        30, 58, 41,
        48, 93, 66,
        77, 128, 97,
        137, 162, 87,
        190, 220, 127,
        238, 255, 204,
    ],
    .[   // RKBV (2-strip film)
        21, 25, 26,
        138, 76, 88,
        217, 98, 117,
        230, 184, 193,
        69, 107, 115,
        75, 151, 166,
        165, 189, 194,
        255, 245, 247,
    ]
];

paletteText: []*u8 = .[
    "3-BIT RGB",
    "AMMO-8 (GameBoy-like)",
    "RKBV (2-strip film)"
];

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - color palette switch");
    defer CloseWindow(); // Close window and OpenGL context

    // Load shader to be used on some parts drawing
    // NOTE 1: Using GLSL 330 shader version, on OpenGL ES 2.0 use GLSL 100 shader version
    // NOTE 2: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shader: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/palette_switch.fs", GLSL_VERSION));
    defer UnloadShader(shader);       // Unload shader

    // Get variable (uniform) location on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    paletteLoc: s32 = GetShaderLocation(shader, "palette");

    currentPalette: s32 = 0;
    lineHeight    : s32 = screenHeight/COLORS_PER_PALETTE;

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
             if (IsKeyPressed(.KEY_RIGHT)) currentPalette += 1;
        else if (IsKeyPressed(.KEY_LEFT))  currentPalette -= 1;

        if (currentPalette >= MAX_PALETTES) currentPalette = 0;
        else if (currentPalette < 0) currentPalette = MAX_PALETTES - 1;

        // Send palette data to the shader to be used on drawing
        // NOTE: We are sending RGB triplets w/o the alpha channel
        SetShaderValueV(shader, paletteLoc, *palettes[currentPalette], .SHADER_UNIFORM_IVEC3, COLORS_PER_PALETTE);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginShaderMode(shader);
            defer EndShaderMode();

            for i:0..COLORS_PER_PALETTE-1 {
                // Draw horizontal screen-wide rectangles with increasing "palette index"
                // The used palette index is encoded in the RGB components of the pixel
                DrawRectangle(0, lineHeight*cast(s32)i, GetScreenWidth(), lineHeight, Color.{cast(u8)i, cast(u8)i, cast(u8)i, 255});
            }
        }

        DrawText("< >", 10, 10, 30, DARKBLUE);
        DrawText("CURRENT PALETTE:", 60, 15, 20, RAYWHITE);
        DrawText(paletteText[currentPalette], 300, 15, 20, RED);

        DrawFPS(700, 15);
        //----------------------------------------------------------------------------------
    }
}