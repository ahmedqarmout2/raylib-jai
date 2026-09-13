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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - rotating cube");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 0.0, 3.0, 3.0 };
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Load image to create texture for the cube
    model: Model = LoadModelFromMesh(GenMeshCube(1.0, 1.0, 1.0));
    img: Image = LoadImage("resources/cubicmap_atlas.png");
    crop: Image = ImageFromImage(img, Rectangle.{0, img.height/2.0, img.width/2.0, img.height/2.0});
    texture: Texture2D = LoadTextureFromImage(crop);
    UnloadImage(img);
    UnloadImage(crop);

    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;

    rotation: float = 0.0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rotation += 1.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                // Draw model defining: position, size, rotation-axis, rotation (degrees), size, and tint-color
                DrawModelEx(model, Vector3.{ 0.0, 0.0, 0.0 }, Vector3.{ 0.5, 1.0, 0.0 },
                    rotation, Vector3.{ 1.0, 1.0, 1.0 }, WHITE);

                DrawGrid(10, 1.0);

            EndMode3D();

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture); // Unload texture
    UnloadModel(model);     // Unload model

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
