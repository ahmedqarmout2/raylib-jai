#import "raylib";
#import "Basic";
#import "Math";

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;
    splitWidth: s32 = screenWidth/2;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - framebuffer rendering");

    // Camera to look at the 3D world
    subjectCamera: Camera3D;
    subjectCamera.position = Vector3.{ 5.0, 5.0, 5.0 };
    subjectCamera.target = Vector3.{ 0.0, 0.0, 0.0 };
    subjectCamera.up = Vector3.{ 0.0, 1.0, 0.0 };
    subjectCamera.fovy = 45.0;
    subjectCamera.projection = .CAMERA_PERSPECTIVE;

    // Camera to observe the subject camera and 3D world
    observerCamera: Camera3D;
    observerCamera.position = Vector3.{ 10.0, 10.0, 10.0 };
    observerCamera.target = Vector3.{ 0.0, 0.0, 0.0 };
    observerCamera.up = Vector3.{ 0.0, 1.0, 0.0 };
    observerCamera.fovy = 45.0;
    observerCamera.projection = .CAMERA_PERSPECTIVE;

    // Set up render textures
    observerTarget: RenderTexture2D = LoadRenderTexture(splitWidth, screenHeight);
    observerSource: Rectangle = .{ 0.0, 0.0, cast(float)observerTarget.texture.width, -cast(float)observerTarget.texture.height };
    observerDest: Rectangle = .{ 0.0, 0.0, cast(float)splitWidth, cast(float)screenHeight };

    subjectTarget: RenderTexture2D = LoadRenderTexture(splitWidth, screenHeight);
    subjectSource: Rectangle = .{ 0.0, 0.0, cast(float)subjectTarget.texture.width, -cast(float)subjectTarget.texture.height };
    subjectDest: Rectangle = .{ cast(float)splitWidth, 0.0, cast(float)splitWidth, cast(float)screenHeight };
    textureAspectRatio: float = cast(float)subjectTarget.texture.width/cast(float)subjectTarget.texture.height;

    // Rectangles for cropping render texture
    captureSize: float = 128.0;
    cropSource: Rectangle = .{ (subjectTarget.texture.width - captureSize)/2.0, (subjectTarget.texture.height - captureSize)/2.0, captureSize, -captureSize };
    cropDest: Rectangle = .{ splitWidth + 20.0, 20.0, captureSize, captureSize};

    SetTargetFPS(60);
    DisableCursor();
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*observerCamera, .CAMERA_FREE);
        UpdateCamera(*subjectCamera, .CAMERA_ORBITAL);

        if (IsKeyPressed(.KEY_R)) observerCamera.target = Vector3.{ 0.0, 0.0, 0.0 };

        // Build LHS observer view texture
        BeginTextureMode(observerTarget);

            ClearBackground(RAYWHITE);

            BeginMode3D(observerCamera);

                DrawGrid(10, 1.0);
                DrawCube(Vector3.{ 0.0, 0.0, 0.0 }, 2.0, 2.0, 2.0, GOLD);
                DrawCubeWires(Vector3.{ 0.0, 0.0, 0.0 }, 2.0, 2.0, 2.0, PINK);
                DrawCameraPrism(subjectCamera, textureAspectRatio, GREEN);

            EndMode3D();

            DrawText("Observer View", 10, observerTarget.texture.height - 30, 20, BLACK);
            DrawText("WASD + Mouse to Move", 10, 10, 20, DARKGRAY);
            DrawText("Scroll to Zoom", 10, 30, 20, DARKGRAY);
            DrawText("R to Reset Observer Target", 10, 50, 20, DARKGRAY);

        EndTextureMode();

        // Build RHS subject view texture
        BeginTextureMode(subjectTarget);

            ClearBackground(RAYWHITE);

            BeginMode3D(subjectCamera);

                DrawCube(Vector3.{ 0.0, 0.0, 0.0 }, 2.0, 2.0, 2.0, GOLD);
                DrawCubeWires(Vector3.{ 0.0, 0.0, 0.0 }, 2.0, 2.0, 2.0, PINK);
                DrawGrid(10, 1.0);

            EndMode3D();

            DrawRectangleLines(cast(s32)((subjectTarget.texture.width - captureSize)/2.0), cast(s32)((subjectTarget.texture.height - captureSize)/2.0), cast(s32)captureSize, cast(s32)captureSize, GREEN);
            DrawText("Subject View", 10, subjectTarget.texture.height - 30, 20, BLACK);

        EndTextureMode();
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(BLACK);

            // Draw observer texture LHS
            DrawTexturePro(observerTarget.texture, observerSource, observerDest, Vector2.{0.0, 0.0 }, 0.0, WHITE);

            // Draw subject texture RHS
            DrawTexturePro(subjectTarget.texture, subjectSource, subjectDest, Vector2.{ 0.0, 0.0 }, 0.0, WHITE);

            // Draw the small crop overlay on top
            DrawTexturePro(subjectTarget.texture, cropSource, cropDest, Vector2.{ 0.0, 0.0 }, 0.0, WHITE);
            DrawRectangleLinesEx(cropDest, 2, BLACK);

            // Draw split screen divider line
            DrawLine(splitWidth, 0, splitWidth, screenHeight, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(observerTarget);
    UnloadRenderTexture(subjectTarget);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
DrawCameraPrism :: (camera: Camera3D, aspect: float, color: Color)
{
    length: float = Vector3Distance(camera.position, camera.target);
    // Define the 4 corners of the camera's prism plane sliced at the target in Normalized Device Coordinates
    planeNDC: [4]Vector3 = .[
        .{ -1.0, -1.0, 1.0 }, // Bottom Left
        .{  1.0, -1.0, 1.0 }, // Bottom Right
        .{  1.0,  1.0, 1.0 }, // Top Right
        .{ -1.0,  1.0, 1.0 }  // Top Left
    ];

    // Build the matrices
    view: Matrix4 = GetCameraMatrix(camera);
    proj: Matrix4 = MatrixPerspective(camera.fovy * DEG2RAD, aspect, 0.05, length);
    // Combine view and projection so we can reverse the full camera transform
    viewProj: Matrix4 = MatrixMultiply(view, proj);
    // Invert the view-projection matrix to unproject points from NDC space back into world space
    inverseViewProj: Matrix4 = MatrixInvert(viewProj);

    // Transform the 4 plane corners from NDC into world space
    corners: [4]Vector3;
    for i: 0..3
    {
        x: float = planeNDC[i].x;
        y: float = planeNDC[i].y;
        z: float = planeNDC[i].z;

        // Multiply NDC position by the inverse view-projection matrix
        // This produces a homogeneous (x, y, z, w) position in world space
        vx: float = inverseViewProj._11*x + inverseViewProj._12*y + inverseViewProj._13*z + inverseViewProj._14;
        vy: float = inverseViewProj._21*x + inverseViewProj._22*y + inverseViewProj._23*z + inverseViewProj._24;
        vz: float = inverseViewProj._31*x + inverseViewProj._32*y + inverseViewProj._33*z + inverseViewProj._34;
        vw: float = inverseViewProj._41*x + inverseViewProj._42*y + inverseViewProj._43*z + inverseViewProj._44;

        corners[i] = Vector3.{ vx/vw, vy/vw, vz/vw };
    }

    // Draw the far plane sliced at the target
    DrawLine3D(corners[0], corners[1], color);
    DrawLine3D(corners[1], corners[2], color);
    DrawLine3D(corners[2], corners[3], color);
    DrawLine3D(corners[3], corners[0], color);

    // Draw the prism lines from the far plane to the camera position
    for i: 0..3
    {
        DrawLine3D(camera.position, corners[i], color);
    }
}