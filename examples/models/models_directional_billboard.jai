#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - directional billboard");

    // Set up the camera
    camera: Camera;
    camera.position = Vector3.{ 2.0, 1.0, 2.0 }; // Starting position
    camera.target = Vector3.{ 0.0, 0.5, 0.0 };  // Target position
    camera.up = Vector3.{ 0.0, 1.0, 0.0 }; // Up vector
    camera.fovy = 45.0; // FOV
    camera.projection = .CAMERA_PERSPECTIVE; // Projection type (Standard 3D perspective)

    // Load billboard texture
    skillbot: Texture = LoadTexture("resources/skillbot.png");

    // Timer to update animation
    anim_timer: float = 0.0;
    // Animation frame
    anim: u32 = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        // Update timer with delta time
        anim_timer += GetFrameTime();

        // Update frame index after a certain amount of time (half a second)
        if (anim_timer > 0.5)
        {
            anim_timer = 0.0;
            anim += 1;
        }

        // Reset frame index to zero on overflow
        if (anim >= 4) anim = 0;

        // Find the current direction frame based on the camera position to the billboard object
        dir: float = cast(float)floor(((Vector2Angle(Vector2.{ 2.0, 0.0 }, Vector2.{ camera.position.x, camera.position.z })/PI)*4.0) + 0.25);

        // Correct frame index if angle is negative
        if (dir < 0.0)
        {
            dir = 8.0 - cast(float)abs(cast(s32)dir);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        BeginMode3D(camera);

            DrawGrid(10, 1.0);

            // Draw billboard pointing straight up to the sky, rotated relative to the camera and offset from the bottom
            DrawBillboardPro(camera, skillbot, Rectangle.{ 0.0 + (anim*24.0), 0.0 + (dir*24.0), 24.0, 24.0 }, Vector3Zero(), Vector3.{ 0.0, 1.0, 0.0 }, Vector2One(), Vector2.{ 0.5, 0.0 }, 0, WHITE);

        EndMode3D();

        // Render various variables for reference
        DrawText(TextFormat("animation: %d", anim), 10, 10, 20, DARKGRAY);
        DrawText(TextFormat("direction frame: %.0", dir), 10, 40, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload billboard texture
    UnloadTexture(skillbot);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}