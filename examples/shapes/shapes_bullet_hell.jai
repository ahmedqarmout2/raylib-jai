#import "raylib";
#import "Basic";
#import "Math";

MAX_BULLETS :: 500000;      // Max bullets to be processed

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
Bullet :: struct {
    position: Vector2;       // Bullet position on screen
    acceleration: Vector2;   // Amount of pixels to be incremented to position every frame
    disabled: bool;          // Skip processing and draw case out of screen
    color: Color;            // Bullet color
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - bullet hell");

    // Bullets definition
    bullets: *Bullet = cast(*Bullet)alloc(MAX_BULLETS * size_of(Bullet)); // Bullets array
    bulletCount: s32 = 0;
    bulletDisabledCount: s32 = 0; // Used to calculate how many bullets are on screen
    bulletRadius: s32 = 10;
    bulletSpeed: float = 3.0;
    bulletRows: s32 = 6;
    bulletColor: [2]Color  = .[ RED, BLUE ];

    // Spawner variables
    baseDirection: float = 0;
    angleIncrement: s32 = 5; // After spawn all bullet rows, increment this value on the baseDirection for next the frame
    spawnCooldown: float = 2;
    spawnCooldownTimer: float = spawnCooldown;

    // Magic circle
    magicCircleRotation: float = 0;

    // Used on performance drawing
    bulletTexture: RenderTexture = LoadRenderTexture(24, 24);

    // Draw circle to bullet texture, then draw bullet using DrawTexture()
    // NOTE: This is done to improve the performance, since DrawCircle() is very slow
    BeginTextureMode(bulletTexture);
        DrawCircle(12, 12, cast(float)bulletRadius, WHITE);
        DrawCircleLines(12, 12, cast(float)bulletRadius, BLACK);
    EndTextureMode();

    drawInPerformanceMode: bool = true; // Switch between DrawCircle() and DrawTexture()

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Reset the bullet index
        // New bullets will replace the old ones that are already disabled due to out-of-screen
        if (bulletCount >= MAX_BULLETS)
        {
            bulletCount = 0;
            bulletDisabledCount = 0;
        }

        spawnCooldownTimer -= 1;
        if (spawnCooldownTimer < 0)
        {
            spawnCooldownTimer = spawnCooldown;

            // Spawn bullets
            degreesPerRow: float = 360.0/bulletRows;
            for row: 0..bulletRows-1
            {
                if (bulletCount < MAX_BULLETS)
                {
                    bullets[bulletCount].position = Vector2.{cast(float) screenWidth/2, cast(float) screenHeight/2};
                    bullets[bulletCount].disabled = false;
                    bullets[bulletCount].color = bulletColor[row%2];

                    bulletDirection: float = baseDirection + (degreesPerRow*row);

                    // Bullet speed*bullet direction, this will determine how much pixels will be incremented/decremented
                    // from the bullet position every frame. Since the bullets doesn't change its direction and speed,
                    // only need to calculate it at the spawning time
                    // 0 degrees = right, 90 degrees = down, 180 degrees = left and 270 degrees = up, basically clockwise
                    // Case you want it to be anti-clockwise, add "* -1" at the y acceleration
                    bullets[bulletCount].acceleration = Vector2.{
                        bulletSpeed*cos(bulletDirection*DEG2RAD),
                        bulletSpeed*sin(bulletDirection*DEG2RAD)
                    };

                    bulletCount += 1;
                }
            }

            baseDirection += angleIncrement;
        }

        // Update bullets position based on its acceleration
        for i: 0..bulletCount-1
        {
            // Only update bullet if inside the screen
            if (!bullets[i].disabled)
            {
                bullets[i].position.x += bullets[i].acceleration.x;
                bullets[i].position.y += bullets[i].acceleration.y;

                // Disable bullet if out of screen
                if ((bullets[i].position.x < -bulletRadius*2.0) ||
                    (bullets[i].position.x > screenWidth + bulletRadius*2.0) ||
                    (bullets[i].position.y < -bulletRadius*2.0) ||
                    (bullets[i].position.y > screenHeight + bulletRadius*2.0))
                {
                    bullets[i].disabled = true;
                    bulletDisabledCount += 1;
                }
            }
        }

        // Input logic
        if ((IsKeyPressed(.KEY_RIGHT) || IsKeyPressed(.KEY_D)) && (bulletRows < 359)) bulletRows += 1;
        if ((IsKeyPressed(.KEY_LEFT) || IsKeyPressed(.KEY_A)) && (bulletRows > 1)) bulletRows -= 1;
        if (IsKeyPressed(.KEY_UP) || IsKeyPressed(.KEY_W)) bulletSpeed += 0.25;
        if ((IsKeyPressed(.KEY_DOWN) || IsKeyPressed(.KEY_S)) && (bulletSpeed > 0.50)) bulletSpeed -= 0.25;
        if (IsKeyPressed(.KEY_Z) && (spawnCooldown > 1)) spawnCooldown -= 1;
        if (IsKeyPressed(.KEY_X)) spawnCooldown += 1;
        if (IsKeyPressed(.KEY_ENTER)) drawInPerformanceMode = !drawInPerformanceMode;

        if (IsKeyDown(.KEY_SPACE))
        {
            angleIncrement += 1;
            angleIncrement %= 360;
        }

        if (IsKeyPressed(.KEY_C))
        {
            bulletCount = 0;
            bulletDisabledCount = 0;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            // Draw magic circle
            magicCircleRotation += 1;
            DrawRectanglePro(Rectangle.{ cast(float)screenWidth/2, cast(float)screenHeight/2, 120, 120 },
                Vector2.{ 60.0, 60.0 }, magicCircleRotation, PURPLE);
            DrawRectanglePro(Rectangle.{ cast(float)screenWidth/2, cast(float)screenHeight/2, 120, 120 },
                Vector2.{ 60.0, 60.0 }, magicCircleRotation + 45, PURPLE);
            DrawCircleLines(screenWidth/2, screenHeight/2, 70, BLACK);
            DrawCircleLines(screenWidth/2, screenHeight/2, 50, BLACK);
            DrawCircleLines(screenWidth/2, screenHeight/2, 30, BLACK);

            // Draw bullets
            if (drawInPerformanceMode)
            {
                // Draw bullets using pre-rendered texture containing circle
                for i: 0..bulletCount-1
                {
                    // Do not draw disabled bullets (out of screen)
                    if (!bullets[i].disabled)
                    {
                        DrawTexture(bulletTexture.texture,
                            cast(s32)(bullets[i].position.x - bulletTexture.texture.width*0.5),
                            cast(s32)(bullets[i].position.y - bulletTexture.texture.height*0.5),
                            bullets[i].color);
                    }
                }
            }
            else
            {
                // Draw bullets using DrawCircle(), less performant
                for i: 0..bulletCount-1
                {
                    // Do not draw disabled bullets (out of screen)
                    if (!bullets[i].disabled)
                    {
                        DrawCircleV(bullets[i].position, cast(float)bulletRadius, bullets[i].color);
                        DrawCircleLinesV(bullets[i].position, cast(float)bulletRadius, BLACK);
                    }
                }
            }

            // Draw UI
            DrawRectangle(10, 10, 280, 150, Color.{0,0, 0, 200 });
            DrawText("Controls:", 20, 20, 10, LIGHTGRAY);
            DrawText("- Right/Left or A/D: Change rows number", 40, 40, 10, LIGHTGRAY);
            DrawText("- Up/Down or W/S: Change bullet speed", 40, 60, 10, LIGHTGRAY);
            DrawText("- Z or X: Change spawn cooldown", 40, 80, 10, LIGHTGRAY);
            DrawText("- Space (Hold): Change the angle increment", 40, 100, 10, LIGHTGRAY);
            DrawText("- Enter: Switch draw method (Performance)", 40, 120, 10, LIGHTGRAY);
            DrawText("- C: Clear bullets", 40, 140, 10, LIGHTGRAY);

            DrawRectangle(610, 10, 170, 30, Color.{0,0, 0, 200 });
            if (drawInPerformanceMode) DrawText("Draw method: DrawTexture(*)", 620, 20, 10, GREEN);
            else DrawText("Draw method: DrawCircle(*)", 620, 20, 10, RED);

            DrawRectangle(135, 410, 530, 30, Color.{0,0, 0, 200 });
            DrawText(TextFormat("[ FPS: %d, Bullets: %d, Rows: %d, Bullet speed: %.2f, Angle increment per frame: %d, Cooldown: %.0 ]",
                    GetFPS(), bulletCount - bulletDisabledCount, bulletRows, bulletSpeed,  angleIncrement, spawnCooldown),
                155, 420, 10, GREEN);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(bulletTexture); // Unload bullet texture

    free(bullets);     // Free bullets array data

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}