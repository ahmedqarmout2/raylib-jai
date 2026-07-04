#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - font spritefont");

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
    msg1: [50]u8;
    copy_string_to_array(msg1.data, "THIS IS A custom SPRITE FONT...");

    msg2: [50]u8;
    copy_string_to_array(msg2.data, "...and this is ANOTHER CUSTOM font...");

    msg3: [50]u8;
    copy_string_to_array(msg3.data, "...and a THIRD one! GREAT! :D");

    font1: Font = LoadFont("resources/custom_mecha.png");          // Font loading
    font2: Font = LoadFont("resources/custom_alagard.png");        // Font loading
    font3: Font = LoadFont("resources/custom_jupiter_crash.png");  // Font loading

    fontPosition1: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font1, msg1.data, cast(float)font1.baseSize, -3).x/2,
                              screenHeight/2.0 - font1.baseSize/2.0 - 80.0 };

    fontPosition2: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font2, msg2.data, cast(float)font2.baseSize, -2.0).x/2.0,
                              screenHeight/2.0 - font2.baseSize/2.0 - 10.0 };

    fontPosition3: Vector2 = .{ screenWidth/2.0 - MeasureTextEx(font3, msg3.data, cast(float)font3.baseSize, 2.0).x/2.0,
                              screenHeight/2.0 - font3.baseSize/2.0 + 50.0 };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update variables here...
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawTextEx(font1, msg1.data, fontPosition1, cast(float)font1.baseSize, -3, WHITE);
            DrawTextEx(font2, msg2.data, fontPosition2, cast(float)font2.baseSize, -2, WHITE);
            DrawTextEx(font3, msg3.data, fontPosition3, cast(float)font3.baseSize, 2, WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadFont(font1);      // Font unloading
    UnloadFont(font2);      // Font unloading
    UnloadFont(font3);      // Font unloading

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
