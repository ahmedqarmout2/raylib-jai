#import "raylib";
#import "Basic";
#import "Math";

MAP_TILE_SIZE          : s32 : 32;  // Tiles size 32x32 pixels
PLAYER_SIZE            : s32 : 16;  // Player size
PLAYER_TILE_VISIBILITY : s32 : 2;   // Player can see 2 tiles around its position

// Map data type
Map :: struct {
    tilesX  : s32;            // Number of tiles in X axis
    tilesY  : s32;            // Number of tiles in Y axis
    tileIds : [..]u8;         // Tile ids (tilesX*tilesY), defines type of tile to draw
    tileFog : [..]u8;         // Tile fog state (tilesX*tilesY), defines if a tile has fog or half-fog
};

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - fog of war");
    //--------------------------------------------------------------------------------------

    map: Map;
    map.tilesX = 25;
    map.tilesY = 15;

    // NOTE: We can have up to 256 values for tile ids and for tile fog state,
    // probably we don't need that many values for fog state, it can be optimized
    // to use only 2 bits per fog state (reducing size by 4) but logic will be a bit more complex
    array_resize(*map.tileIds, map.tilesX*map.tilesY);
    array_resize(*map.tileFog, map.tilesX*map.tilesY);

    // Load map tiles (generating 2 random tile ids for testing)
    // NOTE: Map tile ids should be probably loaded from an external map file
    for i: 0..map.tilesY*map.tilesX-1 map.tileIds[i] = cast(u8)GetRandomValue(0, 1);

    // Player position on the screen (pixel coordinates, not tile coordinates)
    playerPosition: Vector2 = .{ 180, 130 };
    playerTileX: s32 = 0;
    playerTileY: s32 = 0;

    // Render texture to render fog of war
    // NOTE: To get an automatic smooth-fog effect we use a render texture to render fog
    // at a smaller size (one pixel per tile) and scale it on drawing with bilinear filtering
    fogOfWar: RenderTexture2D = LoadRenderTexture(map.tilesX, map.tilesY);
    SetTextureFilter(fogOfWar.texture, .TEXTURE_FILTER_BILINEAR);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // Move player around
        if (IsKeyDown(.KEY_RIGHT)) playerPosition.x += 5;
        if (IsKeyDown(.KEY_LEFT))  playerPosition.x -= 5;
        if (IsKeyDown(.KEY_DOWN))  playerPosition.y += 5;
        if (IsKeyDown(.KEY_UP))    playerPosition.y -= 5;

        // Check player position to avoid moving outside tilemap limits
        if (playerPosition.x < 0) playerPosition.x = 0;
        else if ((playerPosition.x + PLAYER_SIZE) > cast(float)(map.tilesX*MAP_TILE_SIZE)) playerPosition.x = cast(float)map.tilesX*MAP_TILE_SIZE - PLAYER_SIZE;
        if (playerPosition.y < 0) playerPosition.y = 0;
        else if ((playerPosition.y + PLAYER_SIZE) > cast(float)(map.tilesY*MAP_TILE_SIZE)) playerPosition.y = cast(float)map.tilesY*MAP_TILE_SIZE - PLAYER_SIZE;

        // Previous visited tiles are set to partial fog
        for i: 0..map.tilesX*map.tilesY-1 if (map.tileFog[i] == 1) map.tileFog[i] = 2;

        // Get current tile position from player pixel position
        playerTileX = cast(s32)((playerPosition.x + MAP_TILE_SIZE/2)/MAP_TILE_SIZE);
        playerTileY = cast(s32)((playerPosition.y + MAP_TILE_SIZE/2)/MAP_TILE_SIZE);

        // Check visibility and update fog
        // NOTE: We check tilemap limits to avoid processing tiles out-of-array-bounds (it could crash program)
        for y: (playerTileY - PLAYER_TILE_VISIBILITY)..(playerTileY + PLAYER_TILE_VISIBILITY)-1 
            for x: (playerTileX - PLAYER_TILE_VISIBILITY)..(playerTileX + PLAYER_TILE_VISIBILITY)-1
                if ((x >= 0) && (x < map.tilesX) && (y >= 0) && (y < map.tilesY)) map.tileFog[y*map.tilesX + x] = 1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(fogOfWar);
        ClearBackground(BLANK);
        for y: 0..map.tilesY-1
            for x: 0..map.tilesX-1
                if (map.tileFog[y*map.tilesX + x] == 0) DrawRectangle(x, y, 1, 1, BLACK);
                else if (map.tileFog[y*map.tilesX + x] == 2) DrawRectangle(x, y, 1, 1, Fade(BLACK, 0.8));
        EndTextureMode();

        BeginDrawing();

        ClearBackground(RAYWHITE);

        for y: 0..map.tilesY-1 {
            for x: 0..map.tilesX-1 {
                // Draw tiles from id (and tile borders)
                DrawRectangle(
                    x*MAP_TILE_SIZE,
                    y*MAP_TILE_SIZE,
                    MAP_TILE_SIZE,
                    MAP_TILE_SIZE,
                    ifx(map.tileIds[y*map.tilesX + x] == 0) then BLUE else Fade(BLUE, 0.9));
                DrawRectangleLines(x*MAP_TILE_SIZE, y*MAP_TILE_SIZE, MAP_TILE_SIZE, MAP_TILE_SIZE, Fade(DARKBLUE, 0.5));
            }
        }

        // Draw player
        DrawRectangleV(playerPosition, Vector2.{ cast(float)PLAYER_SIZE, cast(float)PLAYER_SIZE }, RED);

        // Draw fog of war (scaled to full map, bilinear filtering)
        DrawTexturePro(
            fogOfWar.texture,
            Rectangle.{ 0, 0, cast(float)fogOfWar.texture.width,   cast(float)-fogOfWar.texture.height },
            Rectangle.{ 0, 0, cast(float)map.tilesX*MAP_TILE_SIZE, cast(float)map.tilesY*MAP_TILE_SIZE },
            Vector2.{ 0, 0 },
            0.0,
            WHITE);

        // Draw player current tile
        DrawText(TextFormat("Current tile: [%i,%i]", playerTileX, playerTileY), 10, 10, 20, RAYWHITE);
        DrawText("ARROW KEYS to move", 10, screenHeight-25, 20, RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    array_free(map.tileIds);        // Free allocated map tile ids
    array_free(map.tileFog);        // Free allocated map tile fog state

    UnloadRenderTexture(fogOfWar);  // Unload render texture

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}