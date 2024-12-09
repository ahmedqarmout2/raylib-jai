#import "raylib";
#import "Basic";
#import "Math";

char :: u8;

EMOJI_PER_WIDTH  :: 8;
EMOJI_PER_HEIGHT :: 4;

//--------------------------------------------------------------------------------------
// Global variables
//--------------------------------------------------------------------------------------
// Arrays that holds the random emojis
Emoji :: struct {
    int index;      // Index inside `emojiCodepoints`
    int message;    // Message index
    Color color;    // Emoji color
};

emoji :: [EMOJI_PER_WIDTH*EMOJI_PER_HEIGHT]Emoji;

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT | .FLAG_VSYNC_HINT);

    InitWindow(screenWidth, screenHeight, "raylib [text] example - unicode");
    defer CloseWindow(); // Close window and OpenGL context

    // Load the font resources
    // NOTE: fontAsian is for asian languages,
    // fontEmoji is the emojis and fontDefault is used for everything else
    fontDefault: Font = LoadFont("resources/dejavu.fnt");
    fontAsian  : Font = LoadFont("resources/noto_cjk.fnt");
    fontEmoji  : Font = LoadFont("resources/symbola.fnt");

    hoveredPos : Vector2 = .{0.0, 0.0};
    selectedPos: Vector2 = .{0.0, 0.0};

    // Set a random set of emojis when starting up
    RandomizeEmoji();

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
