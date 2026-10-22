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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - magnifying glass");

    bunny: Texture2D = LoadTexture("resources/raybunny.png");
    parrots: Texture2D = LoadTexture("resources/parrots.png");

    // Use image draw to generate a mask texture instead of loading it from a file.
    circle: Image = GenImageColor(256, 256, BLANK);
    ImageDrawCircle(*circle, 128, 128, 128, WHITE);
    mask: Texture2D = LoadTextureFromImage(circle); // Copy the mask image from RAM to VRAM
    UnloadImage(circle); // Unload the image from RAM

    magnifiedWorld: RenderTexture2D = LoadRenderTexture(256, 256);

    camera: Camera2D;
    // Set magnifying glass zoom
    camera.zoom = 2;
    // Offset by half the size of the magnifying glass to counteract drawing the texture centered on the mouse position
    camera.offset = Vector2Multiply(Vector2.{ 128, 128 }, GetWindowScaleDPI());

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mPos: Vector2 = GetMousePosition();
        camera.target = mPos;

        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw the normal version of the world
            DrawTexture(parrots, 144, 33, WHITE);
            DrawText("Use the magnifying glass to find hidden bunnies!", 154, 6, 20, BLACK);

            // Render to a the magnifying glass
            BeginTextureMode(magnifiedWorld);
                ClearBackground(RAYWHITE);

                BeginMode2D(camera);
                    // Draw the same things in the magnified world as were in the normal version
                    DrawTexture(parrots, 144, 33, WHITE);
                    DrawText("Use the magnifying glass to find hidden bunnies!", 154, 6, 20, BLACK);

                    // Draw bunnies only in the magnified world.
                    // BLEND_MULTIPLIED lets them take on the color of the image below them.
                    BeginBlendMode(.BLEND_MULTIPLIED);
                        DrawTexture(bunny, 250, 350, WHITE);
                        DrawTexture(bunny, 500, 100, WHITE);
                        DrawTexture(bunny, 420, 300, WHITE);
                        DrawTexture(bunny, 650, 10, WHITE);
                    EndBlendMode();
                EndMode2D();

                // Mask the magnifying glass view texture to a circle
                // To make the mask affect only alpha, a CUSTOM blend mode is used with SEPARATE color/alpha functions
                BeginBlendMode(.BLEND_CUSTOM_SEPARATE);
                    // C: Color, A: Alpha, s: source (texture to draw), d: destination (texture drawn to)
                    //   glSrcRGB: RL_ZERO      - Cs * 0 = 0  - discard source rgb because we don't want to draw our texture's colors at all
                    //   glDstRGB: RL_ONE       - Cd * 1 = Cd - use destination colors unmodified
                    //   glSrcAlpha: RL_ONE     - As * 1 = As - use source alpha unmodified
                    //   glDstAlpha: RL_ZERO    - Ad * 0 = 0  - discard destination alpha
                    //   glEqRGB: RL_FUNC_ADD   - Cs(0) + Cd = Cd - destination color is unmodified
                    //   glEqAlpha: RL_FUNC_ADD - As + Ad(0) = As - destination alpha is set to source alpha
                    rlSetBlendFactorsSeparate(RL_ZERO, RL_ONE, RL_ONE, RL_ZERO, RL_FUNC_ADD, RL_FUNC_ADD);
                    DrawTexture(mask, 0, 0, WHITE);
                EndBlendMode();
            EndTextureMode();

            // Draw magnifiedWorld to screen, centered on cursor
            DrawTextureRec(magnifiedWorld.texture, Rectangle.{0, 0, 256, -256}, Vector2.{mPos.x - 128, mPos.y - 128}, WHITE);

            // Draw the outer ring of the magnifying glass
            DrawRing(mPos, 126, 130, 0, 360, 64, BLACK);

            // Draw floating specular highlight on the glass
            rx: float = mPos.x/800;
            ry: float = mPos.y/800;
            DrawCircle(cast(s32)(mPos.x - 64*rx) - 32, cast(s32)(mPos.y - 64*ry) - 32, 4, ColorAlpha(WHITE, 0.5));

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(parrots);
    UnloadTexture(bunny);
    UnloadTexture(mask);
    UnloadRenderTexture(magnifiedWorld);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
