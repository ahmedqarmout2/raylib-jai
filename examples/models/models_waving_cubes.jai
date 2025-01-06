#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - waving cubes");

    // Initialize the camera
    camera: Camera3D;
    camera.position = Vector3.{ 30.0, 20.0, 30.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 70.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    // Specify the amount of blocks in each direction
    numBlocks: s32 = 15;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        time: float64 = GetTime();

        // Calculate time scale for cube position and size
        scale: float = (2.0 + cast(float)sin(time))*0.7;

        // Move camera around the scene
        cameraTime: float64 = time*0.3;
        camera.position.x = cast(float)cos(cameraTime)*40.0;
        camera.position.z = cast(float)sin(cameraTime)*40.0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                DrawGrid(10, 5.0);

                for x: 0..numBlocks-1
                {
                    for y: 0..numBlocks-1
                    {
                        for z: 0..numBlocks-1
                        {
                            // Scale of the blocks depends on x/y/z positions
                            blockScale: float = (x + y + z)/30.0;

                            // Scatter makes the waving effect by adding blockScale over time
                            scatter: float = sin(blockScale*20.0 + cast(float)(time*4.0));

                            // Calculate the cube position
                            cubePos: Vector3 = .{
                                cast(float)(x - numBlocks/2)*(scale*3.0) + scatter,
                                cast(float)(y - numBlocks/2)*(scale*2.0) + scatter,
                                cast(float)(z - numBlocks/2)*(scale*3.0) + scatter
                            };

                            // Pick a color with a hue depending on cube position for the rainbow color effect
                            // NOTE: This function is quite costly to be done per cube and frame, 
                            // pre-catching the results into a separate array could improve performance
                            cubeColor: Color = ColorFromHSV(cast(float)(((x + y + z)*18)%360), 0.75, 0.9);

                            // Calculate cube size
                            cubeSize: float = (2.4 - scale)*blockScale;

                            // And finally, draw the cube!
                            DrawCube(cubePos, cubeSize, cubeSize, cubeSize, cubeColor);
                        }
                    }
                }

            EndMode3D();

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
