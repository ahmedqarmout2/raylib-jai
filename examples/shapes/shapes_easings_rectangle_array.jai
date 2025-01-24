#import "raylib";
#import "Basic";
#import "Math";

RECS_WIDTH          :: 50;
RECS_HEIGHT         :: 50;

MAX_RECS_X          :: 800/RECS_WIDTH;
MAX_RECS_Y          :: 450/RECS_HEIGHT;

PLAY_TIME_IN_FRAMES :: 240;                 // At 60 fps = 4 seconds

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - easings rectangle array");

    recs: [MAX_RECS_X*MAX_RECS_Y]Rectangle;

    for y: 0..MAX_RECS_Y-1
    {
        for x: 0..MAX_RECS_X-1
        {
            recs[y*MAX_RECS_X + x].x = RECS_WIDTH/2.0 + RECS_WIDTH*x;
            recs[y*MAX_RECS_X + x].y = RECS_HEIGHT/2.0 + RECS_HEIGHT*y;
            recs[y*MAX_RECS_X + x].width = RECS_WIDTH;
            recs[y*MAX_RECS_X + x].height = RECS_HEIGHT;
        }
    }

    rotation: float = 0.0;
    framesCounter: s32 = 0;
    state: s32 = 0;                  // Rectangles animation state: 0-Playing, 1-Finished

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (state == 0)
        {
            framesCounter += 1;

            for i: 0..MAX_RECS_X*MAX_RECS_Y-1
            {
                recs[i].height = EaseCircOut(cast(float)framesCounter, RECS_HEIGHT, -RECS_HEIGHT, PLAY_TIME_IN_FRAMES);
                recs[i].width = EaseCircOut(cast(float)framesCounter, RECS_WIDTH, -RECS_WIDTH, PLAY_TIME_IN_FRAMES);

                if (recs[i].height < 0) recs[i].height = 0;
                if (recs[i].width < 0) recs[i].width = 0;

                if ((recs[i].height == 0) && (recs[i].width == 0)) state = 1;   // Finish playing

                rotation = EaseLinearIn(cast(float)framesCounter, 0.0, 360.0, PLAY_TIME_IN_FRAMES);
            }
        }
        else if ((state == 1) && IsKeyPressed(.KEY_SPACE))
        {
            // When animation has finished, press space to restart
            framesCounter = 0;

            for i: 0.. MAX_RECS_X*MAX_RECS_Y-1
            {
                recs[i].height = RECS_HEIGHT;
                recs[i].width = RECS_WIDTH;
            }

            state = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            if (state == 0)
            {
                for i: 0..MAX_RECS_X*MAX_RECS_Y-1
                {
                    DrawRectanglePro(recs[i], Vector2.{ recs[i].width/2, recs[i].height/2 }, rotation, RED);
                }
            }
            else if (state == 1) DrawText("PRESS [SPACE] TO PLAY AGAIN!", 240, 200, 20, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
