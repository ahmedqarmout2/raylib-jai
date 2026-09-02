#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION ::       330;

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

    // NOTE: screenWidth/screenHeight should match VR device aspect ratio
    InitWindow(screenWidth, screenHeight, "raylib [core] example - vr simulator");

    // VR device parameters definition
    device: VrDeviceInfo = .{
        // Oculus Rift CV1 parameters for simulator
        hResolution = 2160,                 // Horizontal resolution in pixels
        vResolution = 1200,                 // Vertical resolution in pixels
        hScreenSize = 0.133793,            // Horizontal size in meters
        vScreenSize = 0.0669,              // Vertical size in meters
        eyeToScreenDistance = 0.041,       // Distance between eye and display in meters
        lensSeparationDistance = 0.07,     // Lens separation distance in meters
        interpupillaryDistance = 0.07,     // IPD (distance between pupils) in meters

        // NOTE: CV1 uses fresnel-hybrid-asymmetric lenses with specific compute shaders
        // Following parameters are just an approximation to CV1 distortion stereo rendering
        lensDistortionValues[0] = 1.0,     // Lens distortion constant parameter 0
        lensDistortionValues[1] = 0.22,    // Lens distortion constant parameter 1
        lensDistortionValues[2] = 0.24,    // Lens distortion constant parameter 2
        lensDistortionValues[3] = 0.0,     // Lens distortion constant parameter 3
        chromaAbCorrection[0] = 0.996,     // Chromatic aberration correction parameter 0
        chromaAbCorrection[1] = -0.004,    // Chromatic aberration correction parameter 1
        chromaAbCorrection[2] = 1.014,     // Chromatic aberration correction parameter 2
        chromaAbCorrection[3] = 0.0,       // Chromatic aberration correction parameter 3
    };

    // Load VR stereo config for VR device parameteres (Oculus Rift CV1 parameters)
    config: VrStereoConfig = LoadVrStereoConfig(device);

    // Distortion shader (uses device lens distortion and chroma)
    distortion: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/distortion.fs", GLSL_VERSION));

    // Update distortion shader with lens and distortion-scale parameters
    SetShaderValue(distortion, GetShaderLocation(distortion, "leftLensCenter"),
                   *config.leftLensCenter, .SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "rightLensCenter"),
                   *config.rightLensCenter, .SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "leftScreenCenter"),
                   *config.leftScreenCenter, .SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "rightScreenCenter"),
                   *config.rightScreenCenter, .SHADER_UNIFORM_VEC2);

    SetShaderValue(distortion, GetShaderLocation(distortion, "scale"),
                   *config.scale, .SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "scaleIn"),
                   *config.scaleIn, .SHADER_UNIFORM_VEC2);
    SetShaderValue(distortion, GetShaderLocation(distortion, "deviceWarpParam"),
                   *device.lensDistortionValues, .SHADER_UNIFORM_VEC4);
    SetShaderValue(distortion, GetShaderLocation(distortion, "chromaAbParam"),
                   *device.chromaAbCorrection, .SHADER_UNIFORM_VEC4);

    // Initialize framebuffer for stereo rendering
    // NOTE: Screen size should match HMD aspect ratio
    target: RenderTexture2D = LoadRenderTexture(device.hResolution, device.vResolution);

    // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
    sourceRec: Rectangle = .{ 0.0, 0.0, cast(float)target.texture.width, -cast(float)target.texture.height };
    destRec: Rectangle = .{ 0.0, 0.0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight() };

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 5.0, 2.0, 5.0 };    // Camera position
    camera.target = Vector3.{ 0.0, 2.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };          // Camera up vector
    camera.fovy = 60.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    cubePosition: Vector3 = .{ 0.0, 0.0, 0.0 };

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_FIRST_PERSON);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);
            ClearBackground(RAYWHITE);
            BeginVrStereoMode(config);
                BeginMode3D(camera);

                    DrawCube(cubePosition, 2.0, 2.0, 2.0, RED);
                    DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, MAROON);
                    DrawGrid(40, 1.0);

                EndMode3D();
            EndVrStereoMode();
        EndTextureMode();

        BeginDrawing();
            ClearBackground(RAYWHITE);
            BeginShaderMode(distortion);
                DrawTexturePro(target.texture, sourceRec, destRec, Vector2.{ 0.0, 0.0 }, 0.0, WHITE);
            EndShaderMode();
            DrawFPS(10, 10);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadVrStereoConfig(config);   // Unload stereo config

    UnloadRenderTexture(target);    // Unload stereo render fbo
    UnloadShader(distortion);       // Unload distortion shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}