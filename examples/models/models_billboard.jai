#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - drawing billboards");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position   = Vector3.{5.0, 4.0, 5.0}; // Camera position
    camera.target     = Vector3.{0.0, 3.0, 0.0};    // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};    // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                       // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;        // Camera mode type

    bill: Texture2D = LoadTexture("resources/billboard.png");    // Our billboard texture
    billPositionStatic: Vector3 = .{ 0.0, 2.0, 0.0 };          // Position of static billboard
    billPositionRotating: Vector3 = .{ 1.0, 2.0, 1.0 };        // Position of rotating billboard

    // Entire billboard texture, source is used to take a segment from a larger texture.
    source: Rectangle = .{ 0.0, 0.0, cast(float)bill.width, cast(float)bill.height };

    // NOTE: Billboard locked on axis-Y
    billUp: Vector3 = .{ 0.0, 1.0, 0.0 };

    // Set the height of the rotating billboard to 1.0 with the aspect ratio fixed
    size: Vector2 = .{ source.width/source.height, 1.0 };

    // Rotate around origin
    // Here we choose to rotate around the image center
    origin: Vector2 = Vector2Scale(size, 0.5);

    // Distance is needed for the correct billboard draw order
    // Larger distance (further away from the camera) should be drawn prior to smaller distance.
    distanceStatic: float;
    distanceRotating: float;
    rotation: float = 0.0;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        rotation += 0.4;
        distanceStatic = Vector3Distance(camera.position, billPositionStatic);
        distanceRotating = Vector3Distance(camera.position, billPositionRotating);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawGrid(10, 1.0);        // Draw a grid

                // Draw order matters!
                if (distanceStatic > distanceRotating)  {
                    DrawBillboard(camera, bill, billPositionStatic, 2.0, WHITE);
                    DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE);
                } else {
                    DrawBillboardPro(camera, bill, source, billPositionRotating, billUp, size, origin, rotation, WHITE);
                    DrawBillboard(camera, bill, billPositionStatic, 2.0, WHITE);
                }
                
            EndMode3D();

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(bill);        // Unload texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
