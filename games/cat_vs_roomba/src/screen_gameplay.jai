/*
*********************************************************************************************
*
*   raylib - Advance Game template
*
*   Gameplay Screen Functions Definitions (Init, Update, Draw, Unload)
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************
*/

TILE_REQUIRED_CLEAN_TIME    : s32 :     2;           // Frames it takes to clean a dirt level
TILE_SCORE_BY_CLEANED_LEVEL : s32 :     100;         // Score by cleanied dirt level
TILE_REQUIRED_CLEAN_AREA    : s32 :     28*28;       // Required are for actually cleaning tile

TILE_SIZE   : s32 :            36;      // Tile size, it should match texture
MAX_TILES_X : s32 :            32;
MAX_TILES_Y : s32 :            17;

CAT_TARGET_RADIUS    : s32 :   3;       // Target proximity radius
CAT_DIRT_CELL_RADIUS : s32 :   2;       // Cells around sg_cat for dirt spreading

TIME_LIMIT_SECONDS : s32 :     180;     // Time to complete the level in seconds

MAX_SCORE_POPUPS : s32 :       60;      // Maximum simultaneous score pop-ups!

//----------------------------------------------------------------------------------
// Module types
//----------------------------------------------------------------------------------
// One dirt tile type
Dirtile :: struct {
    position: Vector2;       // Relative to top-left corner
    level: s32;              // Dirtiness: 0-Clean, 1-2-3-Dirt levels
    sg_state: s32;              // Current dirtiness sg_state
    counter: s32;            // Frames counter for cleaning
    //int time;               // Time it takes to make it clean --> Depends on level
    //int score;              // It depends on the dirt level
    cleaned: bool;           // If it was cleaned (not clean by default)
};

// Score poping-up type
ScorePopup :: struct {
    position: Vector2;
    value: s32;
    alpha: float;
    enabled: bool;
};

// Furniture tile set
FurSet :: struct {
    id     : s32;       // Furniture tile id
    posX   : s32;       // Position X on tileset
    posY   : s32;       // Position Y on tileset
    width  : s32;       // Furniture piece width
    height : s32;       // Furniture piece height
};

// Furniture type
Furniture :: struct {
    furId   : s32;        // Tileset id
    cellX   : s32;        // Cell position X
    cellY   : s32;        // Cell position Y
    sg_state   : s32;        // 0-Block, 1-Alpha, 2-Breakable
    counter : s32;        // Counter in case of break
};

//----------------------------------------------------------------------------------
// Module Variables Definition (local)
//----------------------------------------------------------------------------------
sg_framesCounter : s32 = 0;
timeLevelSeconds : s32 = 0;
levelFinished : bool = false;
sg_finishScreen : s32 = 0;

roomOffset :: Vector2.{ 70, 70 };

sg_roomba: Texture2D;
sg_cat: Texture2D;
dirtiles: Texture2D;
furniture: Texture2D;

#if TILE_VIEWER_MODE {
tracemap: Texture2D;
fursetid: Texture2D;
}

catch: Music;

fxCat: [2]Sound;
fxRoomba: [3]Sound;

sg_roombaPosition: Vector2 = .{ 100, 100 };
sg_roombaSpeed: Vector2 = .{ 4, 4 };
sg_roombaTilePosX: s32 = 0;
sg_roombaTilePosY: s32 = 0;

catPosition: Vector2 = .{ 0, 0 };
catTargetPosition: Vector2 = .{ 0, 0 };
catSpeed: Vector2 = .{ 3, 3 };
catTilePosX: s32 = 0;
catTilePosY: s32 = 0;
catShouldMove: bool = false;

mousePosition: Vector2 = .{ 0, 0 };
mouseTileX: s32 = -1;
mouseTileY: s32 = -1;

tiles: [MAX_TILES_X*MAX_TILES_Y]Dirtile;

popup: [MAX_SCORE_POPUPS]ScorePopup;

furset: [32]FurSet;
furmap: [40]Furniture;
furnitureCount: s32 = 0;

// Furniture collisions map
// 0-block, 1-normal, 2-alpha, 3-breakable
furcolmap: [MAX_TILES_X*MAX_TILES_Y]s32 = .[
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,3,1,1,1,0,0,1,1,1,1,1,1,1,1,
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,3,3,1,1,1,0,0,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    0,0,1,1,1,1,2,2,2,1,1,1,0,0,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,
    0,0,1,1,1,1,2,2,2,1,1,1,0,0,1,1,1,2,2,2,1,1,1,1,3,3,1,1,1,1,0,0,
    3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1,1,3,3,1,1,1,1,0,0,
    3,3,1,1,2,2,2,2,2,2,2,2,1,1,1,1,2,2,2,2,2,1,1,1,0,0,0,0,0,0,0,0,
    1,1,1,1,2,2,2,2,2,2,2,2,1,1,1,1,1,2,2,2,1,1,1,1,0,0,0,0,0,0,0,0,
    1,1,1,1,2,2,2,2,2,2,2,2,1,1,1,1,1,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,0,0,0,0,0,0,0,0,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,0,0,0,0,0,0,0,0,3,3,1,1,1,1,1,1,1,0,0,1,2,2,2,2,2,2,1,1,
    0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,2,2,2,2,2,2,1,1,
    0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,1,1,
    0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,1,1,
    0,0,0,0,0,0,0,0,0,0,2,2,2,3,3,3,3,1,1,0,0,1,2,2,2,2,2,2,2,2,0,0,
    0,0,0,0,0,0,0,0,0,0,2,2,2,3,3,3,3,1,1,0,0,1,2,2,2,2,2,2,2,2,0,0 ];

showObjective: bool = false;

//----------------------------------------------------------------------------------
// Gameplay Screen Functions Definition
//----------------------------------------------------------------------------------

// Gameplay Screen Initialization logic
InitGameplayScreen :: ()
{
    // Initialize GAMEPLAY screen variables here!
    sg_framesCounter = 0;
    sg_finishScreen = 0;
    timeLevelSeconds = TIME_LIMIT_SECONDS;
    levelFinished = false;

    sg_roomba = LoadTexture("resources/roomba.png");
    sg_cat = LoadTexture("resources/cat.png");
    dirtiles = LoadTexture("resources/dirtiles.png");
    furniture = LoadTexture("resources/furniture.png");

#if TILE_VIEWER_MODE {
    tracemap = LoadTexture("resources/tracemap.png");
    fursetid = LoadTexture("resources/fursetid.png");
}

    furCount: s32 = 0;

    {
        input_file :: "resources/furset.txt";
        file, success := file_open(input_file);
        if !success {
            print("Could not open file: %\n", input_file);
            return;
        }
        length := file_length(file);
        buffer := cast(*u8)alloc(length);

        success = file_read(file, buffer, length);
        if !success {
            print("Could not read file: %\n", input_file);
            return;
        }

        file_data: string;
        file_data.data  = buffer;
        file_data.count = length;
        file_lines := split(file_data, "\n");

        for file_lines {
            if it[0] == {
                case #char "f";
                {
                    parts := split(it, " ");
                    furset[furCount].id     = cast(s32)string_to_int(parts[1]);
                    furset[furCount].posX   = cast(s32)string_to_int(parts[2]);
                    furset[furCount].posY   = cast(s32)string_to_int(parts[3]);
                    furset[furCount].width  = cast(s32)string_to_int(parts[4]);
                    furset[furCount].height = cast(s32)string_to_int(parts[5]);
                    furCount += 1;
                }
                case #char "."; // This is a comment
            }
        }

        free(buffer);
        file_close(*file);
    }

    // Position and size come in cell form, not pixels
    for i: 0..furCount-1
    {
        furset[i].posX   *= TILE_SIZE;
        furset[i].posY   *= TILE_SIZE;
        furset[i].width  *= TILE_SIZE;
        furset[i].height *= TILE_SIZE;
    }

    print("Furniture SET elements read: %\n", furCount);

    {
        input_file :: "resources/furmap.txt";
        file, success := file_open(input_file);
        if !success {
            print("Could not open file: %\n", input_file);
            return;
        }
        length := file_length(file);
        buffer := cast(*u8)alloc(length);

        success = file_read(file, buffer, length);
        if !success {
            print("Could not read file: %\n", input_file);
            return;
        }

        file_data: string;
        file_data.data  = buffer;
        file_data.count = length;
        file_lines := split(file_data, "\n");

        for file_lines {
            if it[0] == {
                case #char "f";
                {
                    parts := split(it, " ");
                    furmap[furnitureCount].furId    = cast(s32)string_to_int(parts[1]);
                    furmap[furnitureCount].cellX    = cast(s32)string_to_int(parts[2]);
                    furmap[furnitureCount].cellY    = cast(s32)string_to_int(parts[3]);
                    furmap[furnitureCount].sg_state = cast(s32)string_to_int(parts[4]);
                    furmap[furnitureCount].counter  = cast(s32)string_to_int(parts[5]);
                    furnitureCount += 1;
                }
                case #char "."; // This is a comment
            }
        }

        free(buffer);
        file_close(*file);
    }

    print("Furniture MAP elements read: %\n", furnitureCount);

    // Init dirt tiles
    for y: 0..MAX_TILES_Y-1
    {
        for x: 0..MAX_TILES_X-1
        {
            tiles[y*MAX_TILES_X + x].position = Vector2.{ roomOffset.x + TILE_SIZE*x, roomOffset.y + TILE_SIZE*y };

            if ((furcolmap[y*MAX_TILES_X + x] != 0) &&
                (furcolmap[y*MAX_TILES_X + x] != 3))
            {
                // TODO: Level of dirtiness depends on difficulty level
                // Adjust probability of every tile dirt level
                dirt: s32 = GetRandomValue(0, 100);

                if (dirt < 50) tiles[y*MAX_TILES_X + x].level = 0;          // 50% probability
                else if (dirt < 70) tiles[y*MAX_TILES_X + x].level = 1;     // 20% probability
                else if (dirt < 90) tiles[y*MAX_TILES_X + x].level = 2;     // 10% probability
                else if (dirt < 100) tiles[y*MAX_TILES_X + x].level = 3;    // 10% probability
            }
            else tiles[y*MAX_TILES_X + x].level = 0;

            tiles[y*MAX_TILES_X + x].sg_state = tiles[y*MAX_TILES_X + x].level;
            tiles[y*MAX_TILES_X + x].counter = ifx (tiles[y*MAX_TILES_X + x].level == 0) then 0 else TILE_REQUIRED_CLEAN_TIME;
            tiles[y*MAX_TILES_X + x].cleaned = ifx (tiles[y*MAX_TILES_X + x].level == 0) then true else false;
        }
    }

    // Init score popups
    for i: 0..MAX_SCORE_POPUPS-1
    {
        popup[i].position = Vector2.{ 0, 0 };
        popup[i].value = TILE_SCORE_BY_CLEANED_LEVEL;
        popup[i].enabled = false;
        popup[i].alpha = 1.0;
    }

    // Init sg_cat position
    catPosition = Vector2.{ 30*TILE_SIZE + roomOffset.x, TILE_SIZE + roomOffset.y };
    catTargetPosition = catPosition;

    showObjective = true;

    // Load music and sounds
    fxCat[0] = LoadSound("resources/fxcat01.wav");
    fxCat[1] = LoadSound("resources/fxcat02.wav");
    fxRoomba[0] = LoadSound("resources/fxrobot01.wav");
    fxRoomba[1] = LoadSound("resources/fxrobot02.wav");
    fxRoomba[2] = LoadSound("resources/fxrobot03.wav");

    catch = LoadMusicStream("resources/catch22.mod");

    StopMusicStream(music);
    SetMusicVolume(catch, 0.6);
    PlayMusicStream(catch);

    result = 0;     // Global variable: screens.h
}

// Gameplay Screen Update logic
UpdateGameplayScreen :: ()
{
    UpdateMusicStream(catch);

    if (showObjective)
    {
        if (IsKeyPressed(.KEY_ENTER))
        {
            showObjective = false;
            PlaySound(fxCoin);
        }

        return;
    }

    sg_framesCounter += 1;

    if (sg_framesCounter == 60)
    {
        timeLevelSeconds -= 1;

        if (timeLevelSeconds == 0)
        {
            levelFinished = true;
            sg_finishScreen = 1;
            PlaySound(fxCoin);

            if (GetTileCleanPercent() >= 80) result = 1;
        }

        sg_framesCounter = 0;
    }

    mousePosition = GetMousePosition();
    mouseTileX = cast(s32)floor((mousePosition.x - roomOffset.x)/TILE_SIZE);
    mouseTileY = cast(s32)floor((mousePosition.y - roomOffset.y)/TILE_SIZE);

    // sg_roomba movement logic
    prevPosition: Vector2 = sg_roombaPosition;

    if (IsKeyDown(.KEY_D)) sg_roombaPosition.x += sg_roombaSpeed.x;
    else if (IsKeyDown(.KEY_A)) sg_roombaPosition.x -= sg_roombaSpeed.x;
    if (IsKeyDown(.KEY_W)) sg_roombaPosition.y -= sg_roombaSpeed.y;
    else if (IsKeyDown(.KEY_S)) sg_roombaPosition.y += sg_roombaSpeed.y;

    // Verify current player position is valid or reset
    sg_roombaTilePosX = cast(s32)(floor(sg_roombaPosition.x - roomOffset.x)/TILE_SIZE);
    sg_roombaTilePosY = cast(s32)(floor(sg_roombaPosition.y - roomOffset.y)/TILE_SIZE);
    if ((sg_roombaPosition.x - sg_roomba.width/2 < roomOffset.x) ||
        ((sg_roombaPosition.x + sg_roomba.width/2) >= (roomOffset.x + MAX_TILES_X*TILE_SIZE)) ||
        (sg_roombaPosition.y - sg_roomba.height/2 < roomOffset.y) ||
        ((sg_roombaPosition.y + sg_roomba.height/2) >= (roomOffset.y + MAX_TILES_Y*TILE_SIZE)) ||
        (furcolmap[sg_roombaTilePosY*MAX_TILES_X + sg_roombaTilePosX] == 0) ||
        (furcolmap[sg_roombaTilePosY*MAX_TILES_X + sg_roombaTilePosX] == 3)) sg_roombaPosition = prevPosition;

    // Dyson movement logic
    // if (IsKeyDown(KEY_RIGHT)) dysonPosition.x += dysonSpeed.x;
    // else if (IsKeyDown(KEY_LEFT)) dysonPosition.x -= dysonSpeed.x;
    // if (IsKeyDown(KEY_UP)) dysonPosition.y -= dysonSpeed.y;
    // else if (IsKeyDown(KEY_DOWN)) dysonPosition.y += dysonSpeed.y;

    // Check collision area between sg_roomba and dirt tiles to verify it's beeing cleaned
    // TODO: OPTIMIZATION: Check only sg_roomba surrounding tiles
    for y: 0..MAX_TILES_Y-1
    {
        for x: 0..MAX_TILES_X-1
        {
            // Check if tile requires cleaning
            if (tiles[y*MAX_TILES_X + x].sg_state > 0)
            {
                // TODO: Get better collision area measure, considering round sg_roomba
                cleanRec: Rectangle = GetCollisionRec(Rectangle.{ tiles[y*MAX_TILES_X + x].position.x, tiles[y*MAX_TILES_X + x].position.y, 36, 36 },
                                                      Rectangle.{ sg_roombaPosition.x - sg_roomba.width/2, sg_roombaPosition.y - sg_roomba.height/2, sg_roomba.width*1.0, sg_roomba.height*1.0 });

                // Check sg_roomba is covering at least half of the tile
                if ((cleanRec.width*cleanRec.height) > TILE_REQUIRED_CLEAN_AREA*1.0)
                {
                    // Start cleaning tile
                    tiles[y*MAX_TILES_X + x].counter -= 1;

                    if (tiles[y*MAX_TILES_X + x].counter < 0)
                    {
                        tiles[y*MAX_TILES_X + x].sg_state -= 1;

                        if (tiles[y*MAX_TILES_X + x].sg_state == 0)
                        {
                            tiles[y*MAX_TILES_X + x].counter = 0;
                            score += tiles[y*MAX_TILES_X + x].level*TILE_SCORE_BY_CLEANED_LEVEL;

                            // Show scoring popup, enable first ready!
                            for i: 0..MAX_SCORE_POPUPS-1
                            {
                                if (!popup[i].enabled)
                                {
                                    popup[i].position = tiles[y*MAX_TILES_X + x].position;
                                    popup[i].value = TILE_SCORE_BY_CLEANED_LEVEL*tiles[y*MAX_TILES_X + x].level;
                                    popup[i].enabled = true;
                                    popup[i].alpha = 1.0;
                                    break;
                                }
                            }
                        }
                        else tiles[y*MAX_TILES_X + x].counter = TILE_REQUIRED_CLEAN_TIME;
                    }
                }
            }
        }
    }

    // Update enabled popups!
    for i: 0..MAX_SCORE_POPUPS-1
    {
        if (popup[i].enabled)
        {
            popup[i].position.y -= 2;
            popup[i].alpha -= 0.015;

            if (popup[i].alpha < 0.0) popup[i].enabled = false;
        }
    }

    // sg_cat movement logic
    if (IsMouseButtonPressed(MOUSE_LEFT_BUTTON))
    {
        // Check for a valid cell to move on
        if ((mousePosition.x > roomOffset.x) && (mousePosition.x < (roomOffset.x + MAX_TILES_X*TILE_SIZE)) &&
            (mousePosition.y > roomOffset.y) && (mousePosition.y < (roomOffset.y + MAX_TILES_Y*TILE_SIZE)) &&
            furcolmap[mouseTileY*MAX_TILES_X + mouseTileX] != 0)
        {
            catTargetPosition = GetMousePosition();
            catShouldMove = true;
        }
    }

    if (IsMouseButtonPressed(MOUSE_RIGHT_BUTTON)) PlaySound(fxCat[GetRandomValue(0,1)]);
    if (IsKeyPressed(.KEY_SPACE)) PlaySound(fxRoomba[GetRandomValue(0,2)]);

    // Check if sg_cat should move
    if (catShouldMove)
    {
        if (CheckCollisionPointCircle(catPosition, catTargetPosition, CAT_TARGET_RADIUS*1.0))
        {
            catShouldMove = false;

            // Spread dirt all around selected cell!
            // NOTE: We consider sg_cat drawing offset
            catTilePosX = cast(s32)floor((catPosition.x - sg_cat.width/2 - roomOffset.x)/TILE_SIZE) + 1;
            catTilePosY = cast(s32)floor((catPosition.y - sg_cat.height/2 - 10 - roomOffset.y)/TILE_SIZE) + 1;

            // Check if tile includes a dirt element
            if (furcolmap[mouseTileY*MAX_TILES_X + mouseTileX] == 3)
            {
                for y: (catTilePosY - CAT_DIRT_CELL_RADIUS)..(catTilePosY + CAT_DIRT_CELL_RADIUS + 1)-1
                {
                    for x: (catTilePosX - CAT_DIRT_CELL_RADIUS)..(catTilePosX + CAT_DIRT_CELL_RADIUS + 1)-1
                    {
                        if (((y >= 0) && (y < MAX_TILES_Y) && (x >= 0) && (x < MAX_TILES_X)) &&
                            (tiles[y*MAX_TILES_X + x].sg_state == 0) &&
                            (furcolmap[y*MAX_TILES_X + x] != 0) &&
                            (furcolmap[y*MAX_TILES_X + x] != 3))
                        {
                            dirt: s32 = GetRandomValue(0, 100);

                            if (dirt < 50) tiles[y*MAX_TILES_X + x].level = 0;          // 50% probability
                            else if (dirt < 70) tiles[y*MAX_TILES_X + x].level = 1;     // 20% probability
                            else if (dirt < 90) tiles[y*MAX_TILES_X + x].level = 2;     // 10% probability
                            else if (dirt < 100) tiles[y*MAX_TILES_X + x].level = 3;    // 10% probability

                            tiles[y*MAX_TILES_X + x].sg_state = tiles[y*MAX_TILES_X + x].level;
                            tiles[y*MAX_TILES_X + x].counter = ifx (tiles[y*MAX_TILES_X + x].level == 0) then 0 else TILE_REQUIRED_CLEAN_TIME;
                            tiles[y*MAX_TILES_X + x].cleaned = tiles[y*MAX_TILES_X + x].level == 0;
                        }
                    }
                }
            }
        }
        else
        {
            dir: Vector2 = Vector2Subtract(catTargetPosition, catPosition);
            dirnorm: Vector2 = Vector2Normalize(dir);

            catPosition.x += catSpeed.x*dirnorm.x;
            catPosition.y += catSpeed.y*dirnorm.y;
        }
    }

    if (levelFinished)
    {
        // TODO: Check level finished
    }
}

// Gameplay Screen Draw logic
DrawGameplayScreen :: ()
{
    DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), GetColor(0x57374cff));

    // Draw tiles
    for y: 0..MAX_TILES_Y-1
    {
        for x: 0..MAX_TILES_X-1
        {
            // Draw dirty tiles
            DrawTextureRec(dirtiles, Rectangle.{ tiles[y*MAX_TILES_X + x].sg_state*TILE_SIZE*1.0, 0, TILE_SIZE*1.0, TILE_SIZE*1.0 },
                           Vector2.{ roomOffset.x + TILE_SIZE*x, roomOffset.y + TILE_SIZE*y }, WHITE);

            // TODO: Draw possible walls
        }
    }

    // Draw starting point for sg_roomba and sg_cat
    DrawTextureRec(furniture, Rectangle.{ furset[30].posX*1.0, furset[30].posY*1.0, furset[30].width*1.0, furset[30].height*1.0 }, roomOffset, WHITE);
    DrawTextureRec(furniture, Rectangle.{ furset[29].posX*1.0, furset[29].posY*1.0, furset[29].width*1.0, furset[29].height*1.0 }, Vector2.{ roomOffset.x + 29*36, roomOffset.y }, WHITE);

    DrawTexture(sg_roomba, cast(s32)(sg_roombaPosition.x - sg_roomba.width/2), cast(s32)(sg_roombaPosition.y - sg_roomba.height/2), WHITE);
    DrawTexture(sg_cat, cast(s32)(catPosition.x - sg_cat.width/2), cast(s32)(catPosition.y - sg_cat.height/2 - 10), WHITE);

    furAlpha := 1.0;

    // Draw home objects
    for i: 0..furnitureCount-1
    {
        if (CheckCollisionCircleRec(Vector2.{ sg_roombaPosition.x - sg_roomba.width/2, sg_roombaPosition.y - sg_roomba.height/2 }, sg_roomba.width*1.0,
                                    Rectangle.{ roomOffset.x + furmap[i].cellX*TILE_SIZE, roomOffset.y + furmap[i].cellY*TILE_SIZE,
                                                 furset[furmap[i].furId].width*1.0, furset[furmap[i].furId].height*1.0}) && (furmap[i].sg_state == 1))
        {
            DrawTextureRec(furniture, Rectangle.{ furset[furmap[i].furId].posX*1.0, furset[furmap[i].furId].posY*1.0, furset[furmap[i].furId].width*1.0, furset[furmap[i].furId].height*1.0 },
                           Vector2.{ roomOffset.x + furmap[i].cellX*TILE_SIZE, roomOffset.y + furmap[i].cellY*TILE_SIZE }, Fade(WHITE, 0.5));
        }
        else
        {
            DrawTextureRec(furniture, Rectangle.{ furset[furmap[i].furId].posX*1.0, furset[furmap[i].furId].posY*1.0, furset[furmap[i].furId].width*1.0, furset[furmap[i].furId].height*1.0 },
                           Vector2.{ roomOffset.x + furmap[i].cellX*TILE_SIZE, roomOffset.y + furmap[i].cellY*TILE_SIZE }, Fade(WHITE, furAlpha));
        }
    }

#if TILE_VIEWER_MODE {
    DrawTexture(tracemap, roomOffset.x, roomOffset.y, Fade(WHITE, 0.5));
    DrawTexture(fursetid, 0, 720, WHITE);
}

    // TODO: If an object has been used by sg_cat, draw it in gray
    // Maybe add a tempo bar for reusing?

    // Draw UI
    DrawTextEx(font2, "SCORE:", Vector2.{ 80, 10 }, font2.baseSize*1.0, 2, WHITE);
    DrawTextEx(font, TextFormat("%i", score), Vector2.{ 260, 10 }, font.baseSize*1.0, 2, WHITE);
    DrawTextEx(font2, "CLEAN:", Vector2.{ 500, 10 }, font2.baseSize*1.0, 2, WHITE);
    DrawTextEx(font, TextFormat("%.2f%%", GetTileCleanPercent()), Vector2.{ 690, 10 }, font.baseSize*1.0, 2, WHITE);
    DrawTextEx(font2, "TIME:", Vector2.{ 950, 10 }, font2.baseSize*1.0, 2, WHITE);
    DrawTextEx(font, TextFormat("%i:%02is", timeLevelSeconds/60, timeLevelSeconds%60), Vector2.{ 1100, 10 }, font.baseSize*1.0, 2, WHITE);

    // Debug information
    //DrawText(TextFormat("CatTilePos: [ %i, %i ]", catTilePosX, catTilePosY), roomOffset.x, 690, 20, RAYWHITE);
    //DrawText(TextFormat("MousePos: [ %i, %i ]", mouseTileX, mouseTileY), 400, 690, 20, RED);
    //DrawText(TextFormat("sg_roombaPos: [ %i, %i ]", sg_roombaTilePosX, sg_roombaTilePosY), 600, 690, 20, GREEN);

    if ((mouseTileY >= 0) && (mouseTileY < MAX_TILES_Y) && (mouseTileX >= 0) && (mouseTileX < MAX_TILES_X))
    {
        DrawRectangleLinesEx(Rectangle.{ tiles[mouseTileY*MAX_TILES_X + mouseTileX].position.x,
                                          tiles[mouseTileY*MAX_TILES_X + mouseTileX].position.y, TILE_SIZE*1.0, TILE_SIZE*1.0 }, 2, RED);
    }

    // Draw enabled popups!
    for i: 0..MAX_SCORE_POPUPS-1
    {
        if (popup[i].enabled) DrawText(TextFormat("+%i", popup[i].value), cast(s32)popup[i].position.x, cast(s32)popup[i].position.y, 20, Fade(RED, popup[i].alpha));
    }

    // Show objective
    if (showObjective)
    {
        DrawRectangle(0, 150, GetScreenWidth(), GetScreenHeight() - 300, Fade(DARKGRAY, 0.7));
        DrawTextEx(font2, "OBJECTIVE:", Vector2.{ 500, 240 }, font2.baseSize*1.0, 2, WHITE);
        DrawTextEx(font, "CLEAN 80% OF THE ROOM", Vector2.{ 300, 320 }, font.baseSize*1.0, 2, WHITE);
    }

}

// Gameplay Screen Unload logic
UnloadGameplayScreen :: ()
{
    // Unload GAMEPLAY screen variables here!
    UnloadTexture(sg_roomba);
    UnloadTexture(sg_cat);
    UnloadTexture(dirtiles);
    UnloadTexture(furniture);

    UnloadSound(fxCat[0]);
    UnloadSound(fxCat[1]);
    UnloadSound(fxRoomba[0]);
    UnloadSound(fxRoomba[1]);
    UnloadSound(fxRoomba[2]);

    StopMusicStream(catch);
    UnloadMusicStream(catch);
}

// Gameplay Screen should finish?
FinishGameplayScreen :: () -> s32
{
    return sg_finishScreen;
}

//----------------------------------------------------------------------------------
// Module Functions Declaration (local)
//----------------------------------------------------------------------------------

// Check how much cleaning we have done
GetTileCleanPercent :: () -> float
{
    value: float = 0;

    tileLevelsToClean: s32 = 0;
    tileLevelsCleaned: s32 = 0;

    for y: 0..MAX_TILES_Y-1
    {
        for x: 0..MAX_TILES_X-1
        {
            if (tiles[y*MAX_TILES_X + x].level > 0)
            {
                tileLevelsToClean += tiles[y*MAX_TILES_X + x].level;
                tileLevelsCleaned += tiles[y*MAX_TILES_X + x].sg_state;
            }
        }
    }

    value = (cast(float)(tileLevelsToClean - tileLevelsCleaned)/tileLevelsToClean)*100.0;

    return value;
}