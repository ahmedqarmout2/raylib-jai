#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - render texture");

    // Define a render texture to render
    renderTextureWidth: s32 = 300;
    renderTextureHeight: s32 = 300;
    target: RenderTexture2D = LoadRenderTexture(renderTextureWidth, renderTextureHeight);

    ballPosition: Vector2 = .{ renderTextureWidth/2.0, renderTextureHeight/2.0 };
    ballSpeed: Vector2 = { 5.0, 4.0 };
    ballRadius: s32 = 20;

    rotation: float = 0.0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //----------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //-----------------------------------------------------
        // Ball movement logic
        ballPosition.x += ballSpeed.x;
        ballPosition.y += ballSpeed.y;

        // Check walls collision for bouncing
        if ((ballPosition.x >= (renderTextureWidth - ballRadius)*1.0) || (ballPosition.x <= ballRadius*1.0)) ballSpeed.x *= -1.0;
        if ((ballPosition.y >= (renderTextureHeight - ballRadius)*1.0) || (ballPosition.y <= ballRadius*1.0)) ballSpeed.y *= -1.0;

        // Render texture rotation
        rotation += 0.5;
        //-----------------------------------------------------

        // Draw
        //-----------------------------------------------------
        // Draw our scene to the render texture
        BeginTextureMode(target);

            ClearBackground(SKYBLUE);

            DrawRectangle(0, 0, 20, 20, RED);
            DrawCircleV(ballPosition, cast(float)ballRadius, MAROON);

        EndTextureMode();

        // Draw render texture to main framebuffer
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw our render texture with rotation applied
            // NOTE 1: We set the origin of the texture to the center of the render texture
            // NOTE 2: We flip vertically the texture setting negative source rectangle height
            DrawTexturePro(target.texture,
                Rectangle.{ 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height },
                Rectangle.{ screenWidth/2.0, screenHeight/2.0, cast(float)target.texture.width, cast(float)target.texture.height },
                Vector2.{ target.texture.width/2.0, target.texture.height/2.0 }, rotation, WHITE);

            DrawText("DRAWING BOUNCING BALL INSIDE RENDER TEXTURE!", 10, screenHeight - 40, 20, BLACK);

            DrawFPS(10, 10);

        EndDrawing();
        //-----------------------------------------------------
    }

    // De-Initialization
    //---------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //----------------------------------------------------------
}