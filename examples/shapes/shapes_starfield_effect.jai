#import "raylib";
#import "Basic";
#import "Math";

STAR_COUNT :: 420;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - starfield effect");

    bgColor: Color = ColorLerp(DARKBLUE, BLACK, 0.69);

    // Speed at which we fly forward
    speed: float = 10.0/9.0;

    // We're either drawing lines or circles
    drawLines: bool = true;

    stars: [STAR_COUNT]Vector3;
    starsScreenPos: [STAR_COUNT]Vector2;

    // Setup the stars with a random position
    for i: 0..STAR_COUNT-1
    {
        stars[i].x = cast(float)GetRandomValue(-screenWidth / 2, cast(s32)screenWidth / 2);
        stars[i].y = cast(float)GetRandomValue(-screenHeight / 2, cast(s32)screenHeight / 2);
        stars[i].z = 1.0;
    }

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Change speed based on mouse
        mouseMove: float = GetMouseWheelMove();
        if (cast(s32)mouseMove != 0) speed += 2.0*mouseMove/9.0;
        if (speed < 0.0) speed = 0.1;
        else if (speed > 2.0) speed = 2.0;

        // Toggle lines / points with space bar
        if (IsKeyPressed(.KEY_SPACE)) drawLines = !drawLines;

        dt: float = GetFrameTime();
        for i: 0..STAR_COUNT-1
        {
            // Update star's timer
            stars[i].z -= dt*speed;

            // Calculate the screen position
            starsScreenPos[i] = Vector2.{
                screenWidth*0.5 + stars[i].x/stars[i].z,
                screenHeight*0.5 + stars[i].y/stars[i].z,
            };

            // If the star is too old, or offscreen, it dies and we make a new random one
            if ((stars[i].z < 0.0) || (starsScreenPos[i].x < 0) || (starsScreenPos[i].y < 0.0) ||
                (starsScreenPos[i].x > screenWidth * 1.0) || (starsScreenPos[i].y > screenHeight * 1.0))
            {
                stars[i].x = cast(float)GetRandomValue(-screenWidth / 2, screenWidth / 2);
                stars[i].y = cast(float)GetRandomValue(-screenHeight / 2, screenHeight / 2);
                stars[i].z = 1.0;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(bgColor);

            for i: 0..STAR_COUNT-1
            {
                if (drawLines)
                {
                    // Get the time a little while ago for this star, but clamp it
                    t: float = Clamp(stars[i].z + 1.0/32.0, 0.0, 1.0);

                    // If it's different enough from the current time, we proceed
                    if ((t - stars[i].z) > 0.001)
                    {
                        // Calculate the screen position of the old point
                        startPos: Vector2 = Vector2.{
                            screenWidth*0.5 + stars[i].x/t,
                            screenHeight*0.5 + stars[i].y/t,
                        };

                        // Draw a line connecting the old point to the current point
                        DrawLineV(startPos, starsScreenPos[i], RAYWHITE);
                    }
                }
                else
                {
                    // Make the radius grow as the star ages
                    radius: float = Lerp(stars[i].z, 1.0, 5.0);

                    // Draw the circle
                    DrawCircleV(starsScreenPos[i], radius, RAYWHITE);
                }
            }

            DrawText(TextFormat("[MOUSE WHEEL] Current Speed: %.0", 9.0*speed/2.0), 10, 40, 20, RAYWHITE);
            DrawText(TextFormat("[SPACE] Current draw mode: %s", temp_c_string(ifx drawLines then "Lines" else "Circles")), 10, 70, 20, RAYWHITE);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}