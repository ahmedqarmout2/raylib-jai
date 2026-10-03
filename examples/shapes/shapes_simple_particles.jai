#import "raylib";
#import "Basic";
#import "Math";

MAX_PARTICLES :: 3000;  // Max number of particles

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
ParticleType :: enum s32 {
    WATER :: 0;
    SMOKE;
    FIRE;
};

particleTypeNames: [3]string = .["WATER", "SMOKE", "FIRE"];

Particle :: struct {
    type: ParticleType;      // Particle type (WATER, SMOKE, FIRE)
    position: Vector2;       // Particle position on screen
    velocity: Vector2;       // Particle current speed and direction
    radius: float;           // Particle radius
    color: Color;            // Particle color

    lifeTime: float;         // Particle life time
    alive: bool;             // Particle alive: inside screen and life time
};

CircularBuffer :: struct {
    head: s32;               // Index for the next write
    tail: s32;               // Index for the next read
    buffer: *Particle;       // Particle buffer array
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - simple particles");

    // Definition of particles
    particles: *Particle = cast(*Particle)alloc(MAX_PARTICLES * size_of(Particle)); // Particle array
    circularBuffer: CircularBuffer = .{ 0, 0, particles };

    // Particle emitter parameters
    emissionRate: s32 = -2;          // Negative: on average every -X frames. Positive: particles per frame
    currentType: ParticleType = .WATER;
    emitterPosition: Vector2 = .{ screenWidth/2.0, screenHeight/2.0 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Emit new particles: when emissionRate is 1, emit every frame
        if (emissionRate < 0)
        {
            if (GetRandomValue(0, S32_MAX)%(-emissionRate) == 0) EmitParticle(*circularBuffer, emitterPosition, currentType);
        }
        else
        {
            for i: 0..emissionRate EmitParticle(*circularBuffer, emitterPosition, currentType);
        }

        // Update the parameters of each particle
        UpdateParticles(*circularBuffer, screenWidth, screenHeight);

        // Remove dead particles from the circular buffer
        UpdateCircularBuffer(*circularBuffer);

        // Change Particle Emission Rate (UP/DOWN arrows)
        if (IsKeyPressed(.KEY_UP)) emissionRate += 1;
        if (IsKeyPressed(.KEY_DOWN)) emissionRate -= 1;

        // Change Particle Type (LEFT/RIGHT arrows)
        if (IsKeyPressed(.KEY_RIGHT)) ifx (currentType == .FIRE) then (currentType = .WATER) else currentType += 1;
        if (IsKeyPressed(.KEY_LEFT)) ifx (currentType == .WATER) then (currentType = .FIRE) else currentType -= 1;

        if (IsMouseButtonDown(MOUSE_LEFT_BUTTON)) emitterPosition = GetMousePosition();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Call the function with a loop to draw all particles
            DrawParticles(*circularBuffer);

            // Draw UI and Instructions
            DrawRectangle(5, 5, 315, 75, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(5, 5, 315, 75, BLUE);

            DrawText("CONTROLS:", 15, 15, 10, BLACK);
            DrawText("UP/DOWN: Change Particle Emission Rate", 15, 35, 10, BLACK);
            DrawText("LEFT/RIGHT: Change Particle Type (Water, Smoke, Fire)", 15, 55, 10, BLACK);

            if (emissionRate < 0) DrawText(TextFormat("Particles every %d frames | Type: %s", -emissionRate, particleTypeNames[currentType].data), 15, 95, 10, DARKGRAY);
            else DrawText(TextFormat("%d Particles per frame | Type: %s", emissionRate + 1, particleTypeNames[currentType].data), 15, 95, 10, DARKGRAY);

            DrawFPS(screenWidth - 80, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    free(particles);     // Free particles array data

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
EmitParticle :: (circularBuffer: *CircularBuffer, emitterPosition: Vector2, type: ParticleType)
{
    newParticle: *Particle = AddToCircularBuffer(circularBuffer);

    // If buffer is full, newParticle is NULL
    if (newParticle != null)
    {
        // Fill particle properties
        newParticle.position = emitterPosition;
        newParticle.alive = true;
        newParticle.lifeTime = 0.0;
        newParticle.type = type;
        speed: float = cast(float)(GetRandomValue(0, S32_MAX)%10)/5.0;
        if type ==
        {
            case .WATER;
            {
                newParticle.radius = 5.0;
                newParticle.color = BLUE;
            }
            case .SMOKE;
            {
                newParticle.radius = 7.0;
                newParticle.color = GRAY;
            }
            case .FIRE;
            {
                newParticle.radius = 10.0;
                newParticle.color = YELLOW;
                speed /= 10.0;
            }
        }

        direction: float = cast(float)(GetRandomValue(0, S32_MAX)%360);
        newParticle.velocity = Vector2.{ speed*cos(direction*DEG2RAD), speed*sin(direction*DEG2RAD) };
    }
}

AddToCircularBuffer :: (circularBuffer: *CircularBuffer) -> *Particle
{
    particle: *Particle = null;

    // Check if buffer full
    if (((circularBuffer.head + 1)%MAX_PARTICLES) != circularBuffer.tail)
    {
        // Add new particle to the head position and advance head
        particle = *circularBuffer.buffer[circularBuffer.head];
        circularBuffer.head = (circularBuffer.head + 1)%MAX_PARTICLES;
    }

    return particle;
}

UpdateParticles :: (circularBuffer: *CircularBuffer, screenWidth: s32, screenHeight: s32)
{
    i: s32 = circularBuffer.tail;
    while (i != circularBuffer.head)
    {
        defer i = (i + 1)%MAX_PARTICLES;

        // Update particle life and positions
        circularBuffer.buffer[i].lifeTime += 1.0/60.0; // 60 FPS . 1/60 seconds per frame

        if circularBuffer.buffer[i].type ==
        {
            case .WATER;
            {
                circularBuffer.buffer[i].position.x += circularBuffer.buffer[i].velocity.x;
                circularBuffer.buffer[i].velocity.y += 0.2;   // Gravity
                circularBuffer.buffer[i].position.y += circularBuffer.buffer[i].velocity.y;
            }
            case .SMOKE;
            {
                circularBuffer.buffer[i].position.x += circularBuffer.buffer[i].velocity.x;
                circularBuffer.buffer[i].velocity.y -= 0.05;  // Upwards
                circularBuffer.buffer[i].position.y += circularBuffer.buffer[i].velocity.y;
                circularBuffer.buffer[i].radius += 0.5;       // Increment radius: smoke expands
                circularBuffer.buffer[i].color.a -= 4;         // Decrement alpha: smoke fades

                // If alpha transparent, particle dies
                if (circularBuffer.buffer[i].color.a < 4) circularBuffer.buffer[i].alive = false;
            }
            case .FIRE;
            {
                // Add a little horizontal oscillation to fire particles
                circularBuffer.buffer[i].position.x += circularBuffer.buffer[i].velocity.x + cos(circularBuffer.buffer[i].lifeTime*215.0);
                circularBuffer.buffer[i].velocity.y -= 0.05;  // Upwards
                circularBuffer.buffer[i].position.y += circularBuffer.buffer[i].velocity.y;
                circularBuffer.buffer[i].radius -= 0.15;      // Decrement radius: fire shrinks
                circularBuffer.buffer[i].color.g -= 3;         // Decrement green: fire turns reddish starting from yellow

                // If radius too small, particle dies
                if (circularBuffer.buffer[i].radius <= 0.02) circularBuffer.buffer[i].alive = false;
            }
        }

        // Disable particle when out of screen
        center: Vector2 = circularBuffer.buffer[i].position;
        radius: float = circularBuffer.buffer[i].radius;

        if ((center.x < -radius) || (center.x > (screenWidth + radius)) ||
            (center.y < -radius) || (center.y > (screenHeight + radius)))
        {
            circularBuffer.buffer[i].alive = false;
        }
    }
}

UpdateCircularBuffer :: (circularBuffer: *CircularBuffer)
{
    // Update circular buffer: advance tail over dead particles
    while ((circularBuffer.tail != circularBuffer.head) && !circularBuffer.buffer[circularBuffer.tail].alive)
    {
        circularBuffer.tail = (circularBuffer.tail + 1)%MAX_PARTICLES;
    }
}

DrawParticles :: (circularBuffer: *CircularBuffer)
{
    i: s32 = circularBuffer.tail;
    while (i != circularBuffer.head)
    {
        defer i = (i + 1)%MAX_PARTICLES;

        if (circularBuffer.buffer[i].alive)
        {
            DrawCircleV(circularBuffer.buffer[i].position,
                        circularBuffer.buffer[i].radius,
                        circularBuffer.buffer[i].color);
        }
    }
}
