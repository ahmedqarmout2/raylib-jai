#import "raylib";
#import "Basic";
#import "Math";

MAX_COLORS_COUNT: s32 : 23;          // Number of colors available

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - mouse painting");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    // Colors to choose from
    colors: [MAX_COLORS_COUNT]Color = .[
        RAYWHITE,
        YELLOW,
        GOLD,
        ORANGE,
        PINK,
        RED,
        MAROON,
        GREEN,
        LIME,
        DARKGREEN,
        SKYBLUE,
        BLUE,
        DARKBLUE,
        PURPLE,
        VIOLET,
        DARKPURPLE,
        BEIGE,
        BROWN,
        DARKBROWN,
        LIGHTGRAY,
        GRAY,
        DARKGRAY,
        BLACK];

    // Define colorsRecs data (for every rectangle)
    colorsRecs: [MAX_COLORS_COUNT]Rectangle;

    for i: 0..MAX_COLORS_COUNT-1 {
        colorsRecs[i].x      = 10 + 30.0*i + 2*i;
        colorsRecs[i].y      = 10;
        colorsRecs[i].width  = 30;
        colorsRecs[i].height = 30;
    }

    colorSelected: s32 = 0;
    colorSelectedPrev: s32 = colorSelected;
    colorMouseHover: s32 = 0;
    brushSize: float = 20.0;
    mouseWasPressed: bool = false;

    btnSaveRec: Rectangle = .{ 750, 10, 40, 30 };
    btnSaveMouseHover: bool = false;
    showSaveMessage: bool = false;
    saveMessageCounter: s32 = 0;

    // Create a RenderTexture2D to use as a canvas
    target: RenderTexture2D = LoadRenderTexture(screenWidth, screenHeight);

    // Clear render texture before entering the game loop
    BeginTextureMode(target);
    ClearBackground(colors[0]);
    EndTextureMode();

    SetTargetFPS(120);              // Set our game to run at 120 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        mousePos: Vector2 = GetMousePosition();

        // Move between colors with keys
        if (IsKeyPressed(.KEY_RIGHT)) colorSelected += 1;
        else if (IsKeyPressed(.KEY_LEFT)) colorSelected -= 1;

        if (colorSelected >= MAX_COLORS_COUNT) colorSelected = MAX_COLORS_COUNT - 1;
        else if (colorSelected < 0) colorSelected = 0;

        // Choose color with mouse
        for i: 0..MAX_COLORS_COUNT-1 {
            if (CheckCollisionPointRec(mousePos, colorsRecs[i])) {
                colorMouseHover = i;
                break;
            }
            else colorMouseHover = -1;
        }

        if ((colorMouseHover >= 0) && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
            colorSelected = colorMouseHover;
            colorSelectedPrev = colorSelected;
        }

        // Change brush size
        brushSize += GetMouseWheelMove()*5;
        if (brushSize < 2) brushSize = 2;
        if (brushSize > 50) brushSize = 50;

        if (IsKeyPressed(.KEY_C)) {
            // Clear render texture to clear color
            BeginTextureMode(target);
            ClearBackground(colors[0]);
            EndTextureMode();
        }

        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT) || (GetGestureDetected() == .GESTURE_DRAG)) {
            // Paint circle into render texture
            // NOTE: To avoid discontinuous circles, we could store
            // previous-next mouse points and just draw a line using brush size
            BeginTextureMode(target);
            if (mousePos.y > 50) DrawCircle(cast(s32)mousePos.x, cast(s32)mousePos.y, brushSize, colors[colorSelected]);
            EndTextureMode();
        }

        if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
            if (!mouseWasPressed) {
                colorSelectedPrev = colorSelected;
                colorSelected = 0;
            }

            mouseWasPressed = true;

            // Erase circle from render texture
            BeginTextureMode(target);
            if (mousePos.y > 50) DrawCircle(cast(s32)mousePos.x, cast(s32)mousePos.y, brushSize, colors[0]);
            EndTextureMode();
        } else if (IsMouseButtonReleased(.MOUSE_BUTTON_RIGHT) && mouseWasPressed) {
            colorSelected = colorSelectedPrev;
            mouseWasPressed = false;
        }

        // Check mouse hover save button
        if (CheckCollisionPointRec(mousePos, btnSaveRec)) btnSaveMouseHover = true;
        else btnSaveMouseHover = false;

        // Image saving logic
        // NOTE: Saving painted texture to a default named image
        if ((btnSaveMouseHover && IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) || IsKeyPressed(.KEY_S)) {
            image: Image = LoadImageFromTexture(target.texture);
            ImageFlipVertical(*image);
            ExportImage(image, "my_amazing_texture_painting.png");
            UnloadImage(image);
            showSaveMessage = true;
        }

        if (showSaveMessage) {
            // On saving, show a full screen message for 2 seconds
            saveMessageCounter += 1;
            if (saveMessageCounter > 240) {
                showSaveMessage = false;
                saveMessageCounter = 0;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
        DrawTextureRec(target.texture, Rectangle.{ 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height }, Vector2.{ 0, 0 }, WHITE);

        // Draw drawing circle for reference
        if (mousePos.y > 50) {
            if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) DrawCircleLines(cast(s32)mousePos.x, cast(s32)mousePos.y, brushSize, GRAY);
            else DrawCircle(GetMouseX(), GetMouseY(), brushSize, colors[colorSelected]);
        }

        // Draw top panel
        DrawRectangle(0, 0, GetScreenWidth(), 50, RAYWHITE);
        DrawLine(0, 50, GetScreenWidth(), 50, LIGHTGRAY);

        // Draw color selection rectangles
        for i: 0..MAX_COLORS_COUNT-1 DrawRectangleRec(colorsRecs[i], colors[i]);
        DrawRectangleLines(10, 10, 30, 30, LIGHTGRAY);

        if (colorMouseHover >= 0) DrawRectangleRec(colorsRecs[colorMouseHover], Fade(WHITE, 0.6));

        DrawRectangleLinesEx(
            Rectangle.{
                colorsRecs[colorSelected].x - 2,
                colorsRecs[colorSelected].y - 2,
                colorsRecs[colorSelected].width + 4,
                colorsRecs[colorSelected].height + 4 },
            2,
            BLACK);

        // Draw save image button
        DrawRectangleLinesEx(btnSaveRec, 2, ifx btnSaveMouseHover then RED else BLACK);
        DrawText("SAVE!", 755, 20, 10, ifx btnSaveMouseHover then RED else BLACK);

        // Draw save image message
        if (showSaveMessage) {
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(RAYWHITE, 0.8));
            DrawRectangle(0, 150, GetScreenWidth(), 80, BLACK);
            DrawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20, RAYWHITE);
        }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture
    //--------------------------------------------------------------------------------------
}