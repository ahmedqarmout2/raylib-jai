#import "raylib";
#import "Basic";
#import "Math";

MAX_BALLS ::    5000;  // Maximum quantity of balls

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Ball data type
Ball :: struct {
    position: Vector2;
    speed: Vector2;
    prevPosition: Vector2;
    radius: float;
    friction: float;
    elasticity: float;
    color: Color;
    grabbed: bool;
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - ball physics");

    balls: *Ball = cast(*Ball)alloc(size_of(Ball)*MAX_BALLS);

    // Init first ball in the array
    balls[0] = Ball.{
        position = .{ GetScreenWidth()/2.0, GetScreenHeight()/2.0 },
        speed = .{ 200, 200 },
        prevPosition = .{ 0, 0 },
        radius = 40,
        friction = 0.99,
        elasticity = 0.9,
        color = BLUE,
        grabbed = false
    };

    ballCount: s32 = 1;
    grabbedBall: *Ball = null;       // A pointer to the current ball that is grabbed
    pressOffset: Vector2 = .{ 0, 0 };    // Mouse press offset relative to the ball that grabbedd

    gravity: float = 100;            // World gravity

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        delta: float = GetFrameTime();
        mousePos: Vector2 = GetMousePosition();

        // Checks if a ball was grabbed
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
        {
            i: s32 = ballCount - 1;
            while (i >= 0)
            {
                defer i -= 1;
                ball: *Ball = *balls[i];
                pressOffset.x = mousePos.x - ball.position.x;
                pressOffset.y = mousePos.y - ball.position.y;

                // If the distance between the ball position and the mouse press position
                // is less than or equal to the ball radius, the event occurred inside the ball
                if (length(Vector2.{ pressOffset.x, pressOffset.y }) <= ball.radius)
                {
                    ball.grabbed = true;
                    grabbedBall = ball;
                    break;
                }
            }
        }

        // Releases any ball the was grabbed
        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT))
        {
            if (grabbedBall != null)
            {
                grabbedBall.grabbed = false;
                grabbedBall = null;
            }
        }

        // Creates a new ball
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT) || (IsKeyDown(.KEY_LEFT_CONTROL) && IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)))
        {
            if (ballCount < MAX_BALLS)
            {
                balls[ballCount] = Ball.{
                    position = mousePos,
                    speed = .{ cast(float)GetRandomValue(-300, 300), cast(float)GetRandomValue(-300, 300) },
                    prevPosition = .{ 0, 0 },
                    radius = 20.0 + cast(float)GetRandomValue(0, 30),
                    friction = 0.99,
                    elasticity = 0.9,
                    color = .{ cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), 255 },
                    grabbed = false
                };
                ballCount += 1;
            }
        }

        // Shake balls
        if (IsMouseButtonPressed(.MOUSE_BUTTON_MIDDLE))
        {
            for i: 0..ballCount-1
            {
                if (!balls[i].grabbed) balls[i].speed = Vector2.{ cast(float)GetRandomValue(-2000, 2000), cast(float)GetRandomValue(-2000, 2000) };
            }
        }

        // Changes gravity
        gravity += GetMouseWheelMove()*5;

        // Updates each ball state
        for i: 0..ballCount-1
        {
            ball: *Ball = *balls[i];

            // The ball is not grabbed
            if (!ball.grabbed)
            {
                // Ball repositioning using the velocity
                ball.position.x += ball.speed.x * delta;
                ball.position.y += ball.speed.y * delta;

                // Does the ball hit the screen right boundary?
                if ((ball.position.x + ball.radius) >= screenWidth * 1.0)
                {
                    ball.position.x = screenWidth - ball.radius; // Ball repositioning
                    ball.speed.x = -ball.speed.x*ball.elasticity;  // Elasticity makes the ball lose 10% of its velocity on hit
                }
                // Does the ball hit the screen left boundary?
                else if ((ball.position.x - ball.radius) <= 0)
                {
                    ball.position.x = ball.radius;
                    ball.speed.x = -ball.speed.x*ball.elasticity;
                }

                // The same for y axis
                if ((ball.position.y + ball.radius) >= screenHeight * 1.0)
                {
                    ball.position.y = screenHeight - ball.radius;
                    ball.speed.y = -ball.speed.y*ball.elasticity;
                }
                else if ((ball.position.y - ball.radius) <= 0)
                {
                    ball.position.y = ball.radius;
                    ball.speed.y = -ball.speed.y*ball.elasticity;
                }

                // Friction makes the ball lose 1% of its velocity each frame
                ball.speed.x = ball.speed.x*ball.friction;
                // Gravity affects only the y axis
                ball.speed.y = ball.speed.y*ball.friction + gravity;
            }
            else
            {
                // Ball repositioning using the mouse position
                ball.position.x = mousePos.x - pressOffset.x;
                ball.position.y = mousePos.y - pressOffset.y;

                // While the ball is grabbed, recalculates its velocity
                ball.speed.x = (ball.position.x - ball.prevPosition.x)/delta;
                ball.speed.y = (ball.position.y - ball.prevPosition.y)/delta;
                ball.prevPosition = ball.position;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            for i: 0..ballCount-1
            {
                DrawCircleV(balls[i].position, balls[i].radius, balls[i].color);
                DrawCircleLinesV(balls[i].position, balls[i].radius, BLACK);
            }

            DrawText("grab a ball by pressing with the mouse and throw it by releasing", 10, 10, 10, DARKGRAY);
            DrawText("right click to create new balls (keep left control pressed to create a lot)", 10, 30, 10, DARKGRAY);
            DrawText("use mouse wheel to change gravity", 10, 50, 10, DARKGRAY);
            DrawText("middle click to shake", 10, 70, 10, DARKGRAY);
            DrawText(TextFormat("BALL COUNT: %d", ballCount), 10, GetScreenHeight() - 70, 20, BLACK);
            DrawText(TextFormat("GRAVITY: %.2f", gravity), 10, GetScreenHeight() - 40, 20, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    free(balls);
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}