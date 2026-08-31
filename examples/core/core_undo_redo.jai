#import "raylib";
#import "Basic";
#import "Math";
#import "String";

MAX_UNDO_STATES ::            26;      // Maximum undo states supported for the ring buffer

GRID_CELL_SIZE   ::           24;
MAX_GRID_CELLS_X ::           30;
MAX_GRID_CELLS_Y ::           13;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Point struct, like Vector2 but using int
Point :: struct {
    x: s32;
    y: s32;
};

// Player state struct
// NOTE: Contains all player data that needs to be affected by undo/redo
PlayerState :: struct {
    cell: Point;
    color: Color;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // We have multiple options to implement an Undo/Redo system
    // Probably the most professional one is using the Command pattern to
    // define Actions and store those actions into an array as the events happen,
    // raylib internal Automation System actually uses a similar approach,
    // but in this example we are using another more simple solution,
    // just record PlayerState changes when detected, checking for changes every certain frames
    // This approach requires more memory and is more performance costly but it is quite simple to implement

    InitWindow(screenWidth, screenHeight, "raylib [core] example - undo redo");

    // Undo/redo system variables
    currentUndoIndex: s32 = 0;
    firstUndoIndex: s32 = 0;
    lastUndoIndex: s32 = 0;
    undoFrameCounter: s32 = 0;
    undoInfoPos: Vector2 = .{ 110, 400 };

    // Init current player state and undo/redo recorded states array
    player: PlayerState;
    player.cell = .{ 10, 10 };
    player.color = RED;

    // Init undo buffer to store MAX_UNDO_STATES states
    states: *PlayerState = cast(*PlayerState)alloc(MAX_UNDO_STATES * size_of(PlayerState));
    // Init all undo states to current state
    for i: 0..MAX_UNDO_STATES-1 memcpy(*states[i], *player, size_of(PlayerState));

    // Grid variables
    gridPosition: Vector2 = .{ 40, 60 };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Player movement logic
        if (IsKeyPressed(.KEY_RIGHT)) player.cell.x += 1;
        else if (IsKeyPressed(.KEY_LEFT)) player.cell.x -= 1;
        else if (IsKeyPressed(.KEY_UP)) player.cell.y -= 1;
        else if (IsKeyPressed(.KEY_DOWN)) player.cell.y += 1;

        // Make sure player does not go out of bounds
        if (player.cell.x < 0) player.cell.x = 0;
        else if (player.cell.x >= MAX_GRID_CELLS_X) player.cell.x = MAX_GRID_CELLS_X - 1;
        if (player.cell.y < 0) player.cell.y = 0;
        else if (player.cell.y >= MAX_GRID_CELLS_Y) player.cell.y = MAX_GRID_CELLS_Y - 1;

        // Player color change logic
        if (IsKeyPressed(.KEY_SPACE))
        {
            player.color.r = cast(u8)GetRandomValue(20, 255);
            player.color.g = cast(u8)GetRandomValue(20, 220);
            player.color.b = cast(u8)GetRandomValue(20, 240);
        }

        // Undo state change logic
        undoFrameCounter += 1;

        // Waiting a number of frames before checking if we should store a new state snapshot
        if (undoFrameCounter >= 2) // Checking every 2 frames
        {
            if (memcmp(*states[currentUndoIndex], *player, size_of(PlayerState)) != 0)
            {
                // Move cursor to next available position of the undo ring buffer to record state
                currentUndoIndex += 1;
                if (currentUndoIndex >= MAX_UNDO_STATES) currentUndoIndex = 0;
                if (currentUndoIndex == firstUndoIndex) firstUndoIndex += 1;
                if (firstUndoIndex >= MAX_UNDO_STATES) firstUndoIndex = 0;

                memcpy(*states[currentUndoIndex], *player, size_of(PlayerState));
                lastUndoIndex = currentUndoIndex;
            }

            undoFrameCounter = 0;
        }

        // Recover previous state from buffer: CTRL+Z
        if (IsKeyDown(.KEY_LEFT_CONTROL) && IsKeyPressed(.KEY_Z))
        {
            if (currentUndoIndex != firstUndoIndex)
            {
                currentUndoIndex -= 1;
                if (currentUndoIndex < 0) currentUndoIndex = MAX_UNDO_STATES - 1;

                if (memcmp(*states[currentUndoIndex], *player, size_of(PlayerState)) != 0)
                {
                    memcpy(*player, *states[currentUndoIndex], size_of(PlayerState));
                }
            }
        }

        // Recover next state from buffer: CTRL+Y
        if (IsKeyDown(.KEY_LEFT_CONTROL) && IsKeyPressed(.KEY_Y))
        {
            if (currentUndoIndex != lastUndoIndex)
            {
                nextUndoIndex: s32 = currentUndoIndex + 1;
                if (nextUndoIndex >= MAX_UNDO_STATES) nextUndoIndex = 0;

                if (nextUndoIndex != firstUndoIndex)
                {
                    currentUndoIndex = nextUndoIndex;

                    if (memcmp(*states[currentUndoIndex], *player, size_of(PlayerState)) != 0)
                    {
                        memcpy(*player, *states[currentUndoIndex], size_of(PlayerState));
                    }
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw controls info
            DrawText("[ARROWS] MOVE PLAYER - [SPACE] CHANGE PLAYER COLOR", 40, 20, 20, DARKGRAY);

            // Draw player visited cells recorded by undo
            // NOTE: Remember we are using a ring buffer approach so,
            // some cells info could start at the end of the array and end at the beginning
            if (lastUndoIndex > firstUndoIndex)
            {
                for i: firstUndoIndex..currentUndoIndex-1
                    DrawRectangleRec(Rectangle.{gridPosition.x + states[i].cell.x*GRID_CELL_SIZE, gridPosition.y + states[i].cell.y*GRID_CELL_SIZE,
                        GRID_CELL_SIZE, GRID_CELL_SIZE }, LIGHTGRAY);
            }
            else if (firstUndoIndex > lastUndoIndex)
            {
                if ((currentUndoIndex < MAX_UNDO_STATES) && (currentUndoIndex > lastUndoIndex))
                {
                    for i: firstUndoIndex..currentUndoIndex-1
                        DrawRectangleRec(Rectangle.{ gridPosition.x + states[i].cell.x*GRID_CELL_SIZE, gridPosition.y + states[i].cell.y*GRID_CELL_SIZE,
                            GRID_CELL_SIZE, GRID_CELL_SIZE }, LIGHTGRAY);
                }
                else
                {
                    for i: firstUndoIndex..MAX_UNDO_STATES-1
                        DrawRectangle(cast(s32)gridPosition.x + states[i].cell.x*GRID_CELL_SIZE, cast(s32)gridPosition.y + states[i].cell.y*GRID_CELL_SIZE,
                            GRID_CELL_SIZE, GRID_CELL_SIZE, LIGHTGRAY);
                    for i: 0..currentUndoIndex-1
                        DrawRectangle(cast(s32)gridPosition.x + states[i].cell.x*GRID_CELL_SIZE, cast(s32)gridPosition.y + states[i].cell.y*GRID_CELL_SIZE,
                            GRID_CELL_SIZE, GRID_CELL_SIZE, LIGHTGRAY);
                }
            }

            // Draw game grid
            for y: 0..MAX_GRID_CELLS_Y
                DrawLine(cast(s32)gridPosition.x, cast(s32)(gridPosition.y + y*GRID_CELL_SIZE),
                    cast(s32)gridPosition.x + MAX_GRID_CELLS_X*GRID_CELL_SIZE, cast(s32)(gridPosition.y + y*GRID_CELL_SIZE), GRAY);
            for x: 0..MAX_GRID_CELLS_X
                DrawLine(cast(s32)(gridPosition.x + x*GRID_CELL_SIZE), cast(s32)gridPosition.y,
                    cast(s32)(gridPosition.x + x*GRID_CELL_SIZE), cast(s32)(gridPosition.y + MAX_GRID_CELLS_Y*GRID_CELL_SIZE), GRAY);

            // Draw player
            DrawRectangle(cast(s32)gridPosition.x + player.cell.x*GRID_CELL_SIZE, cast(s32)gridPosition.y + player.cell.y*GRID_CELL_SIZE,
                GRID_CELL_SIZE + 1, GRID_CELL_SIZE + 1, player.color);

            // Draw undo system buffer info
            DrawText("UNDO STATES:", cast(s32)undoInfoPos.x - 85, cast(s32)undoInfoPos.y + 9, 10, DARKGRAY);
            DrawUndoBuffer(undoInfoPos, firstUndoIndex, lastUndoIndex, currentUndoIndex, 24);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    free(states);        // Free undo states array

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definition
//------------------------------------------------------------------------------------
// Draw undo system visualization logic
// NOTE: Visualizing the ring buffer array, every square can store a player state
DrawUndoBuffer :: (position: Vector2, firstUndoIndex: s32, lastUndoIndex: s32, currentUndoIndex: s32, slotSize: s32)
{
    // Draw index marks
    DrawRectangle(cast(s32)position.x + 8 + slotSize*currentUndoIndex, cast(s32)position.y - 10, 8, 8, RED);
    DrawRectangleLines(cast(s32)position.x + 2 + slotSize*firstUndoIndex, cast(s32)position.y + 27, 8, 8, BLACK);
    DrawRectangle(cast(s32)position.x + 14 + slotSize*lastUndoIndex, cast(s32)position.y + 27, 8, 8, BLACK);

    // Draw background gray slots
    for i: 0..MAX_UNDO_STATES-1
    {
        DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, LIGHTGRAY);
        DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, GRAY);
    }

    // Draw occupied slots: firstUndoIndex --> lastUndoIndex
    if (firstUndoIndex <= lastUndoIndex)
    {
        for i: firstUndoIndex..lastUndoIndex
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, SKYBLUE);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, BLUE);
        }
    }
    else if (lastUndoIndex < firstUndoIndex)
    {
        for i: firstUndoIndex..MAX_UNDO_STATES-1
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, SKYBLUE);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, BLUE);
        }

        for i: 0..lastUndoIndex
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, SKYBLUE);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, BLUE);
        }
    }

    // Draw occupied slots: firstUndoIndex --> currentUndoIndex
    if (firstUndoIndex < currentUndoIndex)
    {
        for i: firstUndoIndex..currentUndoIndex-1
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, GREEN);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, LIME);
        }
    }
    else if (currentUndoIndex < firstUndoIndex)
    {
        for i: firstUndoIndex..MAX_UNDO_STATES-1
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, GREEN);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, LIME);
        }

        for i: 0..currentUndoIndex-1
        {
            DrawRectangle(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, GREEN);
            DrawRectangleLines(cast(s32)(position.x + slotSize*i), cast(s32)position.y, slotSize, slotSize, LIME);
        }
    }

    // Draw current selected UNDO slot
    DrawRectangle(cast(s32)position.x + slotSize*currentUndoIndex, cast(s32)position.y, slotSize, slotSize, GOLD);
    DrawRectangleLines(cast(s32)position.x + slotSize*currentUndoIndex, cast(s32)position.y, slotSize, slotSize, ORANGE);
}
