#import "raylib";
#import "Basic";
#import "Math";

MAX_TEXTURE_COLLECTION :: 20;

TextureCollection :: struct {
    texture: Texture2D;
    position: Vector2;
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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - clipboard image");

    collection: [MAX_TEXTURE_COLLECTION]TextureCollection;
    currentCollectionIndex: s32 = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(.KEY_R))    // Reset image collection
        {
            // Unload textures to avoid memory leaks
            for i: 0..currentCollectionIndex-1 UnloadTexture(collection[i].texture);

            currentCollectionIndex = 0;
        }

        if (IsKeyDown(.KEY_LEFT_CONTROL) && IsKeyPressed(.KEY_V) &&
            (currentCollectionIndex < MAX_TEXTURE_COLLECTION))
        {
            image: Image = GetClipboardImage();

            if (IsImageValid(image))
            {
                collection[currentCollectionIndex].texture = LoadTextureFromImage(image);
                collection[currentCollectionIndex].position = GetMousePosition();
                currentCollectionIndex += 1;
                UnloadImage(image);
            }
            else TraceLog(.LOG_INFO, "IMAGE: Could not retrieve image from clipboard");
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            for i: 0..currentCollectionIndex-1
            {
                if (IsTextureValid(collection[i].texture))
                {
                    DrawTexturePro(collection[i].texture,
                        Rectangle.{0,0,cast(float)collection[i].texture.width, cast(float)collection[i].texture.height},
                        Rectangle.{collection[i].position.x,collection[i].position.y, cast(float)collection[i].texture.width, cast(float)collection[i].texture.height},
                        Vector2.{collection[i].texture.width*0.5, collection[i].texture.height*0.5},
                        0.0, WHITE);
                }
            }

            DrawRectangle(0, 0, screenWidth, 40, BLACK);
            DrawText("Clipboard Image - Ctrl+V to Paste and R to Reset ", 120, 10, 20, LIGHTGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..currentCollectionIndex-1
    {
        UnloadTexture(collection[i].texture);
    }

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
