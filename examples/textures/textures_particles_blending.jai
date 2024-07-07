#import "raylib";
#import "Basic";
#import "Math";

MAX_PARTICLES: s32 : 200;

// Particle structure with basic data
Particle :: struct {
    position : Vector2;
    color    : Color;
    alpha    : float;
    size     : float;
    rotation : float;
    active   : bool;        // NOTE: Use it to activate/deactive particle
};

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - particles blending");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    // Particles pool, reuse them!
    mouseTail: [MAX_PARTICLES]Particle;

    // Initialize particles
    for i: 0..MAX_PARTICLES-1 {
        mouseTail[i].position = Vector2.{ 0, 0 };
        mouseTail[i].color    = Color.{ cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), 255 };
        mouseTail[i].alpha    = 1.0;
        mouseTail[i].size     = cast(float)GetRandomValue(1, 30)/20.0;
        mouseTail[i].rotation = cast(float)GetRandomValue(0, 360);
        mouseTail[i].active   = false;
    }

    gravity: float = 3.0;

    smoke: Texture2D = LoadTexture("resources/spark_flame.png");

    blending: BlendMode = .BLEND_ALPHA;

    SetTargetFPS(60);
    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------

        // Activate one particle every frame and Update active particles
        // NOTE: Particles initial position should be mouse position when activated
        // NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
        // NOTE: When a particle disappears, active = false and it can be reused.
        for i: 0..MAX_PARTICLES-1 {
            if (!mouseTail[i].active) {
                mouseTail[i].active   = true;
                mouseTail[i].alpha    = 1.0;
                mouseTail[i].position = GetMousePosition();
                i = MAX_PARTICLES;
            }
        }

        for i: 0..MAX_PARTICLES-1 {
            if (mouseTail[i].active) {
                mouseTail[i].position.y += gravity/2;
                mouseTail[i].alpha      -= 0.005;

                if (mouseTail[i].alpha <= 0.0) mouseTail[i].active = false;

                mouseTail[i].rotation += 2.0;
            }
        }

        if (IsKeyPressed(.KEY_SPACE)) {
            if (blending == .BLEND_ALPHA) blending = .BLEND_ADDITIVE;
            else blending = .BLEND_ALPHA;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(DARKGRAY);

        BeginBlendMode(blending);

        // Draw active particles
        for i: 0..MAX_PARTICLES-1 {
            if (mouseTail[i].active)
                DrawTexturePro(
                    smoke,
                    Rectangle.{ 0.0, 0.0, cast(float)smoke.width, cast(float)smoke.height },
                    Rectangle.{ mouseTail[i].position.x, mouseTail[i].position.y, smoke.width*mouseTail[i].size, smoke.height*mouseTail[i].size },
                    Vector2.{ cast(float)(smoke.width*mouseTail[i].size/2.0), cast(float)(smoke.height*mouseTail[i].size/2.0) },
                    mouseTail[i].rotation,
                    Fade(mouseTail[i].color,
                    mouseTail[i].alpha));
        }

        EndBlendMode();

        DrawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, BLACK);

        if (blending == .BLEND_ALPHA) DrawText("ALPHA BLENDING", 290, screenHeight - 40, 20, BLACK);
        else DrawText("ADDITIVE BLENDING", 280, screenHeight - 40, 20, RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(smoke);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}