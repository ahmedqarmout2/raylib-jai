#import "raylib";
#import "Basic";
#import "Math";

// Constant for Simulation
SIMULATION_STEPS :: 30;
G :: 9.81;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_WINDOW_HIGHDPI);
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - double pendulum");

    // Simulation Parameters
    l1: float = 15.0; m1: float = 0.2; theta1: float = DEG2RAD*170; w1: float = 0;
    l2: float = 15.0; m2: float = 0.1; theta2: float = DEG2RAD*0; w2: float = 0;
    lengthScaler: float = 0.1;
    totalM: float = m1 + m2;

    previousPosition: Vector2 = CalculateDoublePendulumEndPoint(l1, theta1, l2, theta2);
    previousPosition.x += (cast(float)screenWidth/2);
    previousPosition.y += (cast(float)screenHeight/2 - 100);

    // Scale length
    L1: float = l1*lengthScaler;
    L2: float = l2*lengthScaler;

    // Draw parameters
    lineThick: float = 20; trailThick: float = 2;
    fateAlpha: float = 0.01;

    // Create framebuffer
    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);
    SetTextureFilter(target.texture, .TEXTURE_FILTER_BILINEAR);

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        dt: float = GetFrameTime();
        step: float = dt/SIMULATION_STEPS; step2: float = step*step;

        // Update Physics - larger steps = better approximation
        for i: 0..SIMULATION_STEPS-1
        {
            delta: float = theta1 - theta2;
            sinD: float = sin(delta); cosD: float = cos(delta); cos2D: float = cos(2*delta);
            ww1: float = w1*w1; ww2: float = w2*w2;

            // Calculate a1
            a1: float = (-G*(2*m1 + m2)*sin(theta1)
                         - m2*G*sin(theta1 - 2*theta2)
                         - 2*sinD*m2*(ww2*L2 + ww1*L1*cosD))
                        /(L1*(2*m1 + m2 - m2*cos2D));

            // Calculate a2
            a2: float = (2*sinD*(ww1*L1*totalM
                         + G*totalM*cos(theta1)
                         + ww2*L2*m2*cosD))
                        /(L2*(2*m1 + m2 - m2*cos2D));

            // Update thetas
            theta1 += w1*step + 0.5*a1*step2;
            theta2 += w2*step + 0.5*a2*step2;

            // Update omegas
            w1 += a1*step;
            w2 += a2*step;
        }

        // Calculate position
        currentPosition: Vector2 = CalculateDoublePendulumEndPoint(l1, theta1, l2, theta2);
        currentPosition.x += cast(float)screenWidth/2;
        currentPosition.y += cast(float)screenHeight/2 - 100;

        // Draw to render texture
        BeginTextureMode(target);
            // Draw a transparent rectangle - smaller alpha = longer trails
            DrawRectangle(0, 0, screenWidth, screenHeight, Fade(BLACK, fateAlpha));

            // Draw trail
            DrawCircleV(previousPosition, trailThick, RED);
            DrawLineEx(previousPosition, currentPosition, trailThick*2, RED);
        EndTextureMode();

        // Update previous position
        previousPosition = currentPosition;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(BLACK);

            // Draw trails texture
            DrawTextureRec(target.texture, Rectangle.{ 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height }, Vector2.{ 0, 0 }, WHITE);

            // Draw double pendulum
            DrawRectanglePro(Rectangle.{ screenWidth/2.0, screenHeight/2.0 - 100, 10*l1, lineThick },
                Vector2.{0, lineThick*0.5}, 90 - RAD2DEG*theta1, RAYWHITE);

            endpoint1: Vector2 = CalculatePendulumEndPoint(l1, theta1);
            DrawRectanglePro(Rectangle.{ screenWidth/2.0 + endpoint1.x, screenHeight/2.0 - 100 + endpoint1.y, 10*l2, lineThick },
                Vector2.{0, lineThick*0.5}, 90 - RAD2DEG*theta2, RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Calculate pendulum end point
CalculatePendulumEndPoint :: (l: float, theta: float) -> Vector2
{
    return Vector2.{ 10*l*sin(theta), 10*l*cos(theta) };
}

// Calculate double pendulum end point
CalculateDoublePendulumEndPoint :: (l1: float, theta1: float, l2: float, theta2: float) -> Vector2
{
    endpoint1: Vector2 = CalculatePendulumEndPoint(l1, theta1);
    endpoint2: Vector2 = CalculatePendulumEndPoint(l2, theta2);
    return Vector2.{ endpoint1.x + endpoint2.x, endpoint1.y + endpoint2.y };
}
