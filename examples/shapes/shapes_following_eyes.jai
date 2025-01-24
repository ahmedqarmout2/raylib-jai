#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - following eyes");

    scleraLeftPosition  : Vector2 = .{ GetScreenWidth()/2.0 - 100.0, GetScreenHeight()/2.0 };
    scleraRightPosition : Vector2 = .{ GetScreenWidth()/2.0 + 100.0, GetScreenHeight()/2.0 };
    scleraRadius: float = 80;

    irisLeftPosition  : Vector2 = .{ GetScreenWidth()/2.0 - 100.0, GetScreenHeight()/2.0 };
    irisRightPosition : Vector2 = .{ GetScreenWidth()/2.0 + 100.0, GetScreenHeight()/2.0 };
    irisRadius: float = 24;

    angle : float = 0.0;
    dx    : float = 0.0;
    dy    : float = 0.0;
    dxx   : float = 0.0;
    dyy   : float = 0.0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        irisLeftPosition = GetMousePosition();
        irisRightPosition = GetMousePosition();

        // Check not inside the left eye sclera
        if (!CheckCollisionPointCircle(irisLeftPosition, scleraLeftPosition, scleraRadius - irisRadius))
        {
            dx = irisLeftPosition.x - scleraLeftPosition.x;
            dy = irisLeftPosition.y - scleraLeftPosition.y;

            angle = atan2(dy, dx);

            dxx = (scleraRadius - irisRadius)*cos(angle);
            dyy = (scleraRadius - irisRadius)*sin(angle);

            irisLeftPosition.x = scleraLeftPosition.x + dxx;
            irisLeftPosition.y = scleraLeftPosition.y + dyy;
        }

        // Check not inside the right eye sclera
        if (!CheckCollisionPointCircle(irisRightPosition, scleraRightPosition, scleraRadius - irisRadius))
        {
            dx = irisRightPosition.x - scleraRightPosition.x;
            dy = irisRightPosition.y - scleraRightPosition.y;

            angle = atan2(dy, dx);

            dxx = (scleraRadius - irisRadius)*cos(angle);
            dyy = (scleraRadius - irisRadius)*sin(angle);

            irisRightPosition.x = scleraRightPosition.x + dxx;
            irisRightPosition.y = scleraRightPosition.y + dyy;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawCircleV(scleraLeftPosition, scleraRadius, LIGHTGRAY);
            DrawCircleV(irisLeftPosition, irisRadius, BROWN);
            DrawCircleV(irisLeftPosition, 10, BLACK);

            DrawCircleV(scleraRightPosition, scleraRadius, LIGHTGRAY);
            DrawCircleV(irisRightPosition, irisRadius, DARKGREEN);
            DrawCircleV(irisRightPosition, 10, BLACK);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
