/*
*******************************************************************************************
*
*   raylib - classic game: space invaders
*
*   Sample game developed by Ian Eito, Albert Martos and Ramon Santamaria
*
*   This game has been created using raylib v1.3 (www.raylib.com)
*   raylib is licensed under an unmodified zlib/libpng license (View raylib.h for details)
*
*   Copyright (c) 2015 Ramon Santamaria (@raysan5)
*
*******************************************************************************************
*/

#import "raylib";

#import "Basic";
#import "Math";

//----------------------------------------------------------------------------------
// Some Defines
//----------------------------------------------------------------------------------
NUM_SHOOTS      :: 50;
NUM_MAX_ENEMIES :: 50;
FIRST_WAVE      :: 10;
SECOND_WAVE     :: 20;
THIRD_WAVE      :: 50;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
EnemyWave :: enum {
    FIRST;
    SECOND;
    THIRD;
};

Player :: struct {
    rec   : Rectangle;
    speed : Vector2;
    color : Color;
};

Enemy :: struct {
    rec    : Rectangle;
    speed  : Vector2;
    active : bool;
    color  : Color;
};

Shoot :: struct {
    rec    : Rectangle;
    speed  : Vector2;
    active : bool;
    color  : Color;
};

//------------------------------------------------------------------------------------
// Global Variables Declaration
//------------------------------------------------------------------------------------
screenWidth  : s32 = 800;
screenHeight : s32 = 450;

gameOver : bool = false;
pause    : bool =  false;
score    : s32 = 0;
victory  : bool = false;

player : Player;
enemy  : [NUM_MAX_ENEMIES]Enemy;
shoot  : [NUM_SHOOTS]Shoot;
wave   : EnemyWave;

shootRate : s32 = 0;
alpha     : float = 0.0;

activeEnemies : s32 = 0;
enemiesKill   : s32 = 0;
smooth        : bool = false;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization (Note windowTitle is unused on Android)
    //---------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "classic game: space invaders");

    InitGame();

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update and Draw
        //----------------------------------------------------------------------------------
        UpdateDrawFrame();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadGame();         // Unload loaded data (textures, sounds, models...)

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definitions (local)
//------------------------------------------------------------------------------------

// Initialize game variables
InitGame :: ()
{
    // Initialize game variables
    shootRate = 0;
    pause = false;
    gameOver = false;
    victory = false;
    smooth = false;
    wave = .FIRST;
    activeEnemies = FIRST_WAVE;
    enemiesKill = 0;
    score = 0;
    alpha = 0;

    // Initialize player
    player.rec.x =  20;
    player.rec.y = 50;
    player.rec.width = 20;
    player.rec.height = 20;
    player.speed.x = 5;
    player.speed.y = 5;
    player.color = BLACK;

    // Initialize enemies
    for i: 0..NUM_MAX_ENEMIES-1
    {
        enemy[i].rec.width = 10;
        enemy[i].rec.height = 10;
        enemy[i].rec.x = GetRandomValue(screenWidth, screenWidth + 1000) * 1.0;
        enemy[i].rec.y = GetRandomValue(0, cast(s32)(screenHeight - enemy[i].rec.height)) * 1.0;
        enemy[i].speed.x = 5;
        enemy[i].speed.y = 5;
        enemy[i].active = true;
        enemy[i].color = GRAY;
    }

    // Initialize shoots
    for i: 0..NUM_SHOOTS-1
    {
        shoot[i].rec.x = player.rec.x;
        shoot[i].rec.y = player.rec.y + player.rec.height/4;
        shoot[i].rec.width = 10;
        shoot[i].rec.height = 5;
        shoot[i].speed.x = 7;
        shoot[i].speed.y = 0;
        shoot[i].active = false;
        shoot[i].color = MAROON;
    }
}

// Update game (one frame)
UpdateGame :: ()
{
    if (!gameOver)
    {
        if (IsKeyPressed(.KEY_P)) pause = !pause;

        if (!pause)
        {
            if wave ==
            {
                case .FIRST;
                {
                    if (!smooth)
                    {
                        alpha += 0.02;

                        if (alpha >= 1.0) smooth = true;
                    }

                    if (smooth) alpha -= 0.02;

                    if (enemiesKill == activeEnemies)
                    {
                        enemiesKill = 0;

                        for i: 0..activeEnemies-1
                        {
                            if (!enemy[i].active) enemy[i].active = true;
                        }

                        activeEnemies = SECOND_WAVE;
                        wave = .SECOND;
                        smooth = false;
                        alpha = 0.0;
                    }
                }
                case .SECOND;
                {
                    if (!smooth)
                    {
                        alpha += 0.02;

                        if (alpha >= 1.0) smooth = true;
                    }

                    if (smooth) alpha -= 0.02;

                    if (enemiesKill == activeEnemies)
                    {
                        enemiesKill = 0;

                        for i: 0..activeEnemies
                        {
                            if (!enemy[i].active) enemy[i].active = true;
                        }

                        activeEnemies = THIRD_WAVE;
                        wave = .THIRD;
                        smooth = false;
                        alpha = 0.0;
                    }
                }
                case .THIRD;
                {
                    if (!smooth)
                    {
                        alpha += 0.02;

                        if (alpha >= 1.0) smooth = true;
                    }

                    if (smooth) alpha -= 0.02;

                    if (enemiesKill == activeEnemies) victory = true;

                }
            }

            // Player movement
            if (IsKeyDown(.KEY_RIGHT)) player.rec.x += player.speed.x;
            if (IsKeyDown(.KEY_LEFT)) player.rec.x -= player.speed.x;
            if (IsKeyDown(.KEY_UP)) player.rec.y -= player.speed.y;
            if (IsKeyDown(.KEY_DOWN)) player.rec.y += player.speed.y;

            // Player collision with enemy
            for i: 0..activeEnemies-1
            {
                if (CheckCollisionRecs(player.rec, enemy[i].rec)) gameOver = true;
            }

             // Enemy behaviour
            for i: 0..activeEnemies-1
            {
                if (enemy[i].active)
                {
                    enemy[i].rec.x -= enemy[i].speed.x;

                    if (enemy[i].rec.x < 0)
                    {
                        enemy[i].rec.x = GetRandomValue(screenWidth, screenWidth + 1000) * 1.0;
                        enemy[i].rec.y = GetRandomValue(0, cast(s32)(screenHeight - enemy[i].rec.height)) * 1.0;
                    }
                }
            }

            // Wall behaviour
            if (player.rec.x <= 0) player.rec.x = 0;
            if (player.rec.x + player.rec.width >= screenWidth * 1.0) player.rec.x = screenWidth - player.rec.width;
            if (player.rec.y <= 0) player.rec.y = 0;
            if (player.rec.y + player.rec.height >= screenHeight * 1.0) player.rec.y = screenHeight - player.rec.height;

            // Shoot initialization
            if (IsKeyDown(.KEY_SPACE))
            {
                shootRate += 5;

                for i: 0..NUM_SHOOTS-1
                {
                    if (!shoot[i].active && shootRate%20 == 0)
                    {
                        shoot[i].rec.x = player.rec.x;
                        shoot[i].rec.y = player.rec.y + player.rec.height/4;
                        shoot[i].active = true;
                        break;
                    }
                }
            }

            // Shoot logic
            for i: 0..NUM_SHOOTS-1
            {
                if (shoot[i].active)
                {
                    // Movement
                    shoot[i].rec.x += shoot[i].speed.x;

                    // Collision with enemy
                    for j: 0..activeEnemies-1
                    {
                        if (enemy[j].active)
                        {
                            if (CheckCollisionRecs(shoot[i].rec, enemy[j].rec))
                            {
                                shoot[i].active = false;
                                enemy[j].rec.x = GetRandomValue(screenWidth, screenWidth + 1000) * 1.0;
                                enemy[j].rec.y = GetRandomValue(0, cast(s32)(screenHeight - enemy[j].rec.height)) * 1.0;
                                shootRate = 0;
                                enemiesKill += 1;
                                score += 100;
                            }

                            if (shoot[i].rec.x + shoot[i].rec.width >= screenWidth * 1.0)
                            {
                                shoot[i].active = false;
                                shootRate = 0;
                            }
                        }
                    }
                }
            }
        }
    }
    else
    {
        if (IsKeyPressed(.KEY_ENTER))
        {
            InitGame();
            gameOver = false;
        }
    }
}

// Draw game (one frame)
DrawGame :: ()
{
    BeginDrawing();

        ClearBackground(RAYWHITE);

        if (!gameOver)
        {
            DrawRectangleRec(player.rec, player.color);

            if (wave == .FIRST) DrawText("FIRST WAVE", screenWidth/2 - MeasureText("FIRST WAVE", 40)/2, screenHeight/2 - 40, 40, Fade(BLACK, alpha));
            else if (wave == .SECOND) DrawText("SECOND WAVE", screenWidth/2 - MeasureText("SECOND WAVE", 40)/2, screenHeight/2 - 40, 40, Fade(BLACK, alpha));
            else if (wave == .THIRD) DrawText("THIRD WAVE", screenWidth/2 - MeasureText("THIRD WAVE", 40)/2, screenHeight/2 - 40, 40, Fade(BLACK, alpha));

            for i: 0..activeEnemies-1
            {
                if (enemy[i].active) DrawRectangleRec(enemy[i].rec, enemy[i].color);
            }

            for i: 0..NUM_SHOOTS-1
            {
                if (shoot[i].active) DrawRectangleRec(shoot[i].rec, shoot[i].color);
            }

            DrawText(TextFormat("%04i", score), 20, 20, 40, GRAY);

            if (victory) DrawText("YOU WIN", screenWidth/2 - MeasureText("YOU WIN", 40)/2, screenHeight/2 - 40, 40, BLACK);

            if (pause) DrawText("GAME PAUSED", screenWidth/2 - MeasureText("GAME PAUSED", 40)/2, screenHeight/2 - 40, 40, GRAY);
        }
        else DrawText("PRESS [ENTER] TO PLAY AGAIN", GetScreenWidth()/2 - MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20)/2, GetScreenHeight()/2 - 50, 20, GRAY);

    EndDrawing();
}

// Unload game variables
UnloadGame :: ()
{
    // TODO: Unload all dynamic loaded data (textures, sounds, models...)
}

// Update and Draw (one frame)
UpdateDrawFrame :: ()
{
    UpdateGame();
    DrawGame();
}
