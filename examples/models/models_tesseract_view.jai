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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - tesseract view");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 4.0, 4.0, 4.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 0.0, 1.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 50.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera mode type

    // Find the coordinates by setting XYZW to +-1
    tesseract: [16]Vector4 = .[
        .{  1,  1,  1, 1 }, .{  1,  1,  1, -1 },
        .{  1,  1, -1, 1 }, .{  1,  1, -1, -1 },
        .{  1, -1,  1, 1 }, .{  1, -1,  1, -1 },
        .{  1, -1, -1, 1 }, .{  1, -1, -1, -1 },
        .{ -1,  1,  1, 1 }, .{ -1,  1,  1, -1 },
        .{ -1,  1, -1, 1 }, .{ -1,  1, -1, -1 },
        .{ -1, -1,  1, 1 }, .{ -1, -1,  1, -1 },
        .{ -1, -1, -1, 1 }, .{ -1, -1, -1, -1 },
    ];

    rotation: float = 0.0;
    transformed: [16]Vector3;
    wValues: [16]float;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rotation = DEG2RAD*45.0*cast(float)GetTime();

        for i: 0..15
        {
            p: Vector4 = tesseract[i];

            // Rotate the XW part of the vector
            rotXW: Vector2 = Vector2Rotate(Vector2.{ p.x, p.w }, rotation);
            p.x = rotXW.x;
            p.w = rotXW.y;

            // Projection from XYZW to XYZ from perspective point (0, 0, 0, 3)
            // NOTE: Trace a ray from (0, 0, 0, 3) > p and continue until W = 0
            c: float = 3.0/(3.0 - p.w);
            p.x = c*p.x;
            p.y = c*p.y;
            p.z = c*p.z;

            // Split XYZ coordinate and W values later for drawing
            transformed[i] = Vector3.{ p.x, p.y, p.z };
            wValues[i] = p.w;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                for i: 0..15
                {
                    // Draw spheres to indicate the W value
                    DrawSphere(transformed[i], abs(wValues[i]*0.1), RED);

                    for j: 0..15
                    {
                        // Two lines are connected if they differ by 1 coordinate
                        // This way we dont have to keep an edge list
                        v1: Vector4 = tesseract[i];
                        v2: Vector4 = tesseract[j];
                        diff: s32 = cast(s32)(v1.x == v2.x) + cast(s32)(v1.y == v2.y) + cast(s32)(v1.z == v2.z) + cast(s32)(v1.w == v2.w);

                        // Draw only differing by 1 coordinate and the lower index only (duplicate lines)
                        if (diff == 3 && i < j) DrawLine3D(transformed[i], transformed[j], MAROON);
                    }
                }
            EndMode3D();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
