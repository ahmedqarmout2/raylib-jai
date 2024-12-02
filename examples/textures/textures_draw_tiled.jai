#import "raylib";
#import "Basic";
#import "Math";

OPT_WIDTH   : s32 : 220;       // Max width for the options container
MARGIN_SIZE : s32 : 8;         // Size for the margins
COLOR_SIZE  : s32 : 16;        // Size of the color select buttons

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_WINDOW_RESIZABLE); // Make the window resizable
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - Draw part of a texture tiled");
    defer CloseWindow(); // Close window and OpenGL context

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    texPattern: Texture = LoadTexture("resources/patterns.png");
    defer UnloadTexture(texPattern);  // Unload texture

    SetTextureFilter(texPattern, .TEXTURE_FILTER_TRILINEAR); // Makes the texture smoother when upscaled

    // Coordinates for all patterns inside the texture
    recPattern: [6]Rectangle : .[
        .{ 3, 3, 66, 66 },
        .{ 75, 3, 100, 100 },
        .{ 3, 75, 66, 66 },
        .{ 7, 156, 50, 50 },
        .{ 85, 106, 90, 45 },
        .{ 75, 154, 100, 60}
    ];

    // Setup colors
    colors: [10]Color : .[ BLACK, MAROON, ORANGE, BLUE, PURPLE, BEIGE, LIME, RED, DARKGRAY, SKYBLUE ];
    MAX_COLORS: s32 : colors.count;
    colorRec: [MAX_COLORS]Rectangle;

    // Calculate rectangle for each color
    i: s32 = 0;
    x: s32 = 0;
    y: s32 = 0;
    while (i < MAX_COLORS) {
        defer i += 1;

        colorRec[i].x = 2.0 + MARGIN_SIZE + x;
        colorRec[i].y = 22.0 + 256.0 + MARGIN_SIZE + y;
        colorRec[i].width = COLOR_SIZE*2.0;
        colorRec[i].height = cast(float)COLOR_SIZE;

        if (i == (MAX_COLORS/2 - 1)) {
            x = 0;
            y += COLOR_SIZE + MARGIN_SIZE;
        }
        else x += (COLOR_SIZE*2 + MARGIN_SIZE);
    }

    activePattern : s32   = 0;
    activeCol     : s32   = 0;
    scale         : float = 1.0;
    rotation      : float = 0.0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Handle mouse
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
            mouse: Vector2 = GetMousePosition();

            // Check which pattern was clicked and set it as the active pattern
            for i: 0..recPattern.count-1 {
                if (CheckCollisionPointRec(mouse, Rectangle.{ 2 + MARGIN_SIZE + recPattern[i].x, 40 + MARGIN_SIZE + recPattern[i].y, recPattern[i].width, recPattern[i].height })) {
                    activePattern = cast(s32)i;
                    break;
                }
            }

            // Check to see which color was clicked and set it as the active color
            for i: 0..MAX_COLORS-1 {
                if (CheckCollisionPointRec(mouse, colorRec[i])) {
                    activeCol = cast(s32)i;
                    break;
                }
            }
        }

        // Handle keys

        // Change scale
        if (IsKeyPressed(.KEY_UP)) scale += 0.25;
        if (IsKeyPressed(.KEY_DOWN)) scale -= 0.25;
        if (scale > 10.0) scale = 10.0;
        else if ( scale <= 0.0) scale = 0.25;

        // Change rotation
        if (IsKeyPressed(.KEY_LEFT)) rotation -= 25.0;
        if (IsKeyPressed(.KEY_RIGHT)) rotation += 25.0;

        // Reset
        if (IsKeyPressed(.KEY_SPACE)) { rotation = 0.0; scale = 1.0; }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        // Draw the tiled area
        DrawTextureTiled(
            texPattern,
            recPattern[activePattern],
            Rectangle.{
                cast(float)OPT_WIDTH+MARGIN_SIZE,
                cast(float)MARGIN_SIZE,
                GetScreenWidth() - OPT_WIDTH - 2.0*MARGIN_SIZE,
                GetScreenHeight() - 2.0*MARGIN_SIZE},
            Vector2.{0.0, 0.0},
            rotation,
            scale,
            colors[activeCol]);

        // Draw options
        DrawRectangle(MARGIN_SIZE, MARGIN_SIZE, OPT_WIDTH - MARGIN_SIZE, GetScreenHeight() - 2*MARGIN_SIZE, ColorAlpha(LIGHTGRAY, 0.5));

        DrawText("Select Pattern", 2 + MARGIN_SIZE, 30 + MARGIN_SIZE, 10, BLACK);
        DrawTexture(texPattern, 2 + MARGIN_SIZE, 40 + MARGIN_SIZE, BLACK);
        DrawRectangle(
            2 + MARGIN_SIZE + cast(s32)recPattern[activePattern].x,
            40 + MARGIN_SIZE + cast(s32)recPattern[activePattern].y,
            cast(s32)recPattern[activePattern].width,
            cast(s32)recPattern[activePattern].height,
            ColorAlpha(DARKBLUE, 0.3));

        DrawText("Select Color", 2+MARGIN_SIZE, 10+256+MARGIN_SIZE, 10, BLACK);
        for i: 0..MAX_COLORS-1 {
            DrawRectangleRec(colorRec[i], colors[i]);
            if (activeCol == i) DrawRectangleLinesEx(colorRec[i], 3, ColorAlpha(WHITE, 0.5));
        }

        DrawText("Scale (UP/DOWN to change)", 2 + MARGIN_SIZE, 80 + 256 + MARGIN_SIZE, 10, BLACK);
        DrawText(TextFormat("%.2fx", scale), 2 + MARGIN_SIZE, 92 + 256 + MARGIN_SIZE, 20, BLACK);

        DrawText("Rotation (LEFT/RIGHT to change)", 2 + MARGIN_SIZE, 122 + 256 + MARGIN_SIZE, 10, BLACK);
        DrawText(TextFormat("%.0f degrees", rotation), 2 + MARGIN_SIZE, 134 + 256 + MARGIN_SIZE, 20, BLACK);

        DrawText("Press [SPACE] to reset", 2 + MARGIN_SIZE, 164 + 256 + MARGIN_SIZE, 10, DARKBLUE);

        // Draw FPS
        DrawText(TextFormat("%i FPS", GetFPS()), 2 + MARGIN_SIZE, 2 + MARGIN_SIZE, 20, BLACK);
        //----------------------------------------------------------------------------------
    }
}

// Draw part of a texture (defined by a rectangle) with rotation and scale tiled into dest.
DrawTextureTiled :: (texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float, scale: float, tint: Color) {
    if ((texture.id <= 0) || (scale <= 0.0)) return;  // Wanna see a infinite loop?!...just delete this line!
    if ((source.width == 0) || (source.height == 0)) return;

    tileWidth  : s32 = cast(s32)(source.width*scale);
    tileHeight : s32 = cast(s32)(source.height*scale);
    if ((cast(s32)dest.width < tileWidth) && (cast(s32)dest.height < tileHeight)) {
        // Can fit only one tile
        DrawTexturePro(
            texture,
            Rectangle.{
                source.x,
                source.y,
                (cast(float)dest.width/tileWidth)*source.width,
                (cast(float)dest.height/tileHeight)*source.height},
            Rectangle.{
                dest.x,
                dest.y,
                dest.width,
                dest.height},
            origin,
            rotation,
            tint);
    } else if (cast(s32)dest.width <= tileWidth) {
        // Tiled vertically (one column)
        dy: s32 = 0;
        while (dy+tileHeight < cast(s32)dest.height) {
            defer dy += tileHeight;

            DrawTexturePro(
                texture,
                Rectangle.{
                    source.x,
                    source.y,
                    (cast(float)dest.width/tileWidth)*source.width,
                    source.height},
                Rectangle.{
                    dest.x,
                    dest.y + dy,
                    dest.width,
                    cast(float)tileHeight},
                origin,
                rotation,
                tint);
        }

        // Fit last tile
        if (dy < cast(s32)dest.height) {
            DrawTexturePro(
                texture,
                Rectangle.{
                    source.x,
                    source.y,
                    (cast(float)dest.width/tileWidth)*source.width,
                    (cast(float)(dest.height - dy)/tileHeight)*source.height},
                Rectangle.{
                    dest.x,
                    dest.y + dy,
                    dest.width,
                    dest.height - dy},
                origin,
                rotation,
                tint);
        }
    } else if (cast(s32)dest.height <= tileHeight) {
        // Tiled horizontally (one row)
        dx: s32 = 0;
        while (dx+tileWidth < cast(s32)dest.width) {
            defer dx += tileWidth;

            DrawTexturePro(
                texture,
                Rectangle.{
                    source.x,
                    source.y,
                    source.width,
                    (cast(float)dest.height/tileHeight)*source.height},
                Rectangle.{
                    dest.x + dx,
                    dest.y,
                    cast(float)tileWidth,
                    dest.height},
                origin,
                rotation,
                tint);
        }

        // Fit last tile
        if (dx < cast(s32)dest.width) {
            DrawTexturePro(
                texture,
                Rectangle.{
                    source.x,
                    source.y,
                    (cast(float)(dest.width - dx)/tileWidth)*source.width,
                    (cast(float)dest.height/tileHeight)*source.height},
                Rectangle.{
                    dest.x + dx,
                    dest.y,
                    dest.width - dx, dest.height},
                origin,
                rotation,
                tint);
        }
    } else {
        // Tiled both horizontally and vertically (rows and columns)
        dx: s32 = 0;
        while (dx+tileWidth < cast(s32)dest.width) {
            defer dx += tileWidth;

            dy: s32 = 0;
            while (dy+tileHeight < cast(s32)dest.height) {
                defer dy += tileHeight;

                DrawTexturePro(
                    texture,
                    source,
                    Rectangle.{
                        dest.x + dx,
                        dest.y + dy,
                        cast(float)tileWidth,
                        cast(float)tileHeight},
                    origin,
                    rotation,
                    tint);
            }

            if (dy < cast(s32)dest.height) {
                DrawTexturePro(
                    texture,
                    Rectangle.{
                        source.x,
                        source.y,
                        source.width,
                        (cast(float)(dest.height - dy)/tileHeight)*source.height},
                    Rectangle.{
                        dest.x + dx,
                        dest.y + dy,
                        cast(float)tileWidth,
                        dest.height - dy},
                    origin,
                    rotation,
                    tint);
            }
        }

        // Fit last column of tiles
        if (dx < cast(s32)dest.width) {
            dy: s32 = 0;
            while (dy+tileHeight < cast(s32)dest.height) {
                defer dy += tileHeight;
                DrawTexturePro(
                    texture,
                    Rectangle.{
                        source.x,
                        source.y,
                        (cast(float)(dest.width - dx)/tileWidth)*source.width,
                        source.height},
                    Rectangle.{
                        dest.x + dx,
                        dest.y + dy,
                        dest.width - dx,
                        cast(float)tileHeight},
                    origin,
                    rotation,
                    tint);
            }

            // Draw final tile in the bottom right corner
            if (dy < cast(s32)dest.height) {
                DrawTexturePro(
                    texture,
                    Rectangle.{
                        source.x,
                        source.y,
                        (cast(float)(dest.width - dx)/tileWidth)*source.width,
                        (cast(float)(dest.height - dy)/tileHeight)*source.height},
                    Rectangle.{
                        dest.x + dx,
                        dest.y + dy,
                        dest.width - dx,
                        dest.height - dy},
                    origin,
                    rotation,
                    tint);
            }
        }
    }
}