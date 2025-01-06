#import "raylib";
#import "Basic";
#import "Math";

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    sunRadius: float = 4.0;
    earthRadius: float = 0.6;
    earthOrbitRadius: float = 8.0;
    moonRadius: float = 0.16;
    moonOrbitRadius: float = 1.5;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - rlgl module usage with push/pop matrix transformations");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 16.0, 16.0, 16.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    rotationSpeed: float = 0.2;         // General system rotation speed

    earthRotation: float = 0.0;         // Rotation of earth around itself (days) in degrees
    earthOrbitRotation: float = 0.0;    // Rotation of earth around the Sun (years) in degrees
    moonRotation: float = 0.0;          // Rotation of moon around itself
    moonOrbitRotation: float = 0.0;     // Rotation of moon around earth in degrees

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        earthRotation += (5.0*rotationSpeed);
        earthOrbitRotation += (365/360.0*(5.0*rotationSpeed)*rotationSpeed);
        moonRotation += (2.0*rotationSpeed);
        moonOrbitRotation += (8.0*rotationSpeed);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                rlPushMatrix();
                    rlScalef(sunRadius, sunRadius, sunRadius);          // Scale Sun
                    DrawSphereBasic(GOLD);                              // Draw the Sun
                rlPopMatrix();

                rlPushMatrix();
                    rlRotatef(earthOrbitRotation, 0.0, 1.0, 0.0);    // Rotation for Earth orbit around Sun
                    rlTranslatef(earthOrbitRadius, 0.0, 0.0);         // Translation for Earth orbit

                    rlPushMatrix();
                        rlRotatef(earthRotation, 0.25, 1.0, 0.0);       // Rotation for Earth itself
                        rlScalef(earthRadius, earthRadius, earthRadius);// Scale Earth

                        DrawSphereBasic(BLUE);                          // Draw the Earth
                    rlPopMatrix();

                    rlRotatef(moonOrbitRotation, 0.0, 1.0, 0.0);     // Rotation for Moon orbit around Earth
                    rlTranslatef(moonOrbitRadius, 0.0, 0.0);          // Translation for Moon orbit
                    rlRotatef(moonRotation, 0.0, 1.0, 0.0);          // Rotation for Moon itself
                    rlScalef(moonRadius, moonRadius, moonRadius);       // Scale Moon

                    DrawSphereBasic(LIGHTGRAY);                         // Draw the Moon
                rlPopMatrix();

                // Some reference elements (not affected by previous matrix transformations)
                DrawCircle3D(Vector3.{ 0.0, 0.0, 0.0 }, earthOrbitRadius, Vector3.{ 1, 0, 0 }, 90.0, Fade(RED, 0.5));
                DrawGrid(20, 1.0);

            EndMode3D();

            DrawText("EARTH ORBITING AROUND THE SUN!", 400, 10, 20, MAROON);
            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//--------------------------------------------------------------------------------------------
// Module Functions Definitions (local)
//--------------------------------------------------------------------------------------------

// Draw sphere without any matrix transformation
// NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0
DrawSphereBasic :: (color: Color) {
    rings: s32 = 16;
    slices: s32 = 16;

    // Make sure there is enough space in the internal render batch
    // buffer to store all required vertex, batch is reseted if required
    rlCheckRenderBatchLimit((rings + 2)*slices*6);

    rlBegin(RL_TRIANGLES);
        rlColor4ub(color.r, color.g, color.b, color.a);

        for i: 0..rings + 1
        {
            for j: 0..slices-1
            {
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*i)),
                           cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)));
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)));
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*(j*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*(j*360/slices)));

                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*i))*sin(DEG2RAD*(j*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*i)),
                           cos(DEG2RAD*(270+(180/(rings + 1))*i))*cos(DEG2RAD*(j*360/slices)));
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*sin(DEG2RAD*((j+1)*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i))),
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i)))*cos(DEG2RAD*((j+1)*360/slices)));
                rlVertex3f(cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*sin(DEG2RAD*((j+1)*360/slices)),
                           sin(DEG2RAD*(270+(180/(rings + 1))*(i+1))),
                           cos(DEG2RAD*(270+(180/(rings + 1))*(i+1)))*cos(DEG2RAD*((j+1)*360/slices)));
            }
        }
    rlEnd();
}
