#import "raylib";
#import "Basic";
#import "Math";

NUM_FRAMES: s32 : 3;       // Number of frames (rectangles) for the button sprite texture

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite button");
    defer CloseWindow(); // Close window and OpenGL context

    InitAudioDevice();      // Initialize audio device
    defer CloseAudioDevice();     // Close audio device

    fxButton : Sound     = LoadSound("resources/buttonfx.wav");   // Load button sound
    defer UnloadSound(fxButton);  // Unload sound

    button   : Texture2D = LoadTexture("resources/button.png"); // Load button texture
    defer UnloadTexture(button);  // Unload button texture

    // Define frame rectangle for drawing
    frameHeight: float = cast(float)button.height/NUM_FRAMES;
    sourceRec: Rectangle = .{ 0, 0, cast(float)button.width, frameHeight };

    // Define button bounds on screen
    btnBounds: Rectangle = .{ screenWidth/2.0 - button.width/2.0, screenHeight/2.0 - button.height/NUM_FRAMES/2.0, cast(float)button.width, frameHeight };

    btnState: s32 = 0;               // Button state: 0-NORMAL, 1-MOUSE_HOVER, 2-PRESSED
    btnAction: bool = false;         // Button action should be activated

    mousePoint: Vector2 = .{ 0.0, 0.0 };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        mousePoint = GetMousePosition();
        btnAction = false;

        // Check button state
        if (CheckCollisionPointRec(mousePoint, btnBounds)) {
            if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) btnState = 2;
            else btnState = 1;

            if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) btnAction = true;
        } else btnState = 0;

        if (btnAction) {
            PlaySound(fxButton);
        }

        // Calculate button frame rectangle to draw depending on button state
        sourceRec.y = btnState*frameHeight;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        DrawTextureRec(button, sourceRec, Vector2.{ btnBounds.x, btnBounds.y }, WHITE); // Draw button frame
        //----------------------------------------------------------------------------------
    }
}