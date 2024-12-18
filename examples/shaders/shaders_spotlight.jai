#import "raylib";
#import "Basic";
#import "Math";

#if OS == .WINDOWS || OS == .MACOS
    GLSL_VERSION :: 330;
else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    GLSL_VERSION :: 100;

MAX_SPOTS :: 3;        // NOTE: It must be the same as define in shader
MAX_STARS :: 400;

// Spot data
Spot :: struct {
    position: Vector2;
    speed   : Vector2;
    inner   : float;
    radius  : float;

    // Shader locations
    positionLoc: s32;
    innerLoc   : s32;
    radiusLoc  : s32;
};

// Stars in the star field have a position and velocity
Star :: struct {
    position : Vector2;
    speed    : Vector2;
};

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shader spotlight");
    HideCursor();

    texRay: Texture = LoadTexture("resources/raysan.png");

    stars: [MAX_STARS]Star;

    for n: 0..MAX_STARS-1 ResetStar(*stars[n]);

    // Progress all the stars on, so they don't all start in the centre
    m: float = 0;
    while (m < screenWidth/2.0) {
        defer m += 1;
        for n: 0..MAX_STARS-1 UpdateStar(*stars[n]);
    }

    frameCounter: s32 = 0;

    // Use default vert shader
    shdrSpot: Shader = LoadShader(null, TextFormat("resources/shaders/glsl%i/spotlight.fs", GLSL_VERSION));

    // Get the locations of spots in the shader
    spots: [MAX_SPOTS]Spot;

    for i: 0..MAX_SPOTS-1 {
        posName    : *u8 = tprint("spots[%].pos"   , i).data;
        innerName  : *u8 = tprint("spots[%].inner" , i).data;
        radiusName : *u8 = tprint("spots[%].radius", i).data;

        spots[i].positionLoc = GetShaderLocation(shdrSpot, posName);
        spots[i].innerLoc    = GetShaderLocation(shdrSpot, innerName);
        spots[i].radiusLoc   = GetShaderLocation(shdrSpot, radiusName);
    }

    // Tell the shader how wide the screen is so we can have
    // a pitch black half and a dimly lit half.
    wLoc: s32 = GetShaderLocation(shdrSpot, "screenWidth");
    sw: float = cast(float)GetScreenWidth();
    SetShaderValue(shdrSpot, wLoc, *sw, .SHADER_UNIFORM_FLOAT);

    // Randomize the locations and velocities of the spotlights
    // and initialize the shader locations
    for i: 0..MAX_SPOTS-1 {
        spots[i].position.x = cast(float)GetRandomValue(64, screenWidth - 64);
        spots[i].position.y = cast(float)GetRandomValue(64, screenHeight - 64);
        spots[i].speed = Vector2.{0, 0};

        while ((abs(spots[i].speed.x) + abs(spots[i].speed.y)) < 2) {
            spots[i].speed.x = GetRandomValue(-400, 40) / 10.0;
            spots[i].speed.y = GetRandomValue(-400, 40) / 10.0;
        }

        spots[i].inner = 28.0 * (i + 1);
        spots[i].radius = 48.0 * (i + 1);

        SetShaderValue(shdrSpot, spots[i].positionLoc, *spots[i].position.x, .SHADER_UNIFORM_VEC2);
        SetShaderValue(shdrSpot, spots[i].innerLoc, *spots[i].inner, .SHADER_UNIFORM_FLOAT);
        SetShaderValue(shdrSpot, spots[i].radiusLoc, *spots[i].radius, .SHADER_UNIFORM_FLOAT);
    }

    SetTargetFPS(60);               // Set  to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose()) {    // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        frameCounter += 1;

        // Move the stars, resetting them if the go offscreen
        for n: 0..MAX_STARS-1 UpdateStar(*stars[n]);

        // Update the spots, send them to the shader
        for i: 0..MAX_SPOTS-1 {
            if (i == 0) {
                mp: Vector2 = GetMousePosition();
                spots[i].position.x = mp.x;
                spots[i].position.y = screenHeight - mp.y;
            } else {
                spots[i].position.x += spots[i].speed.x;
                spots[i].position.y += spots[i].speed.y;

                if (spots[i].position.x < 64) spots[i].speed.x = -spots[i].speed.x;
                if (spots[i].position.x > (screenWidth - 64.0)) spots[i].speed.x = -spots[i].speed.x;
                if (spots[i].position.y < 64) spots[i].speed.y = -spots[i].speed.y;
                if (spots[i].position.y > (screenHeight - 64.0)) spots[i].speed.y = -spots[i].speed.y;
            }

            SetShaderValue(shdrSpot, spots[i].positionLoc, *spots[i].position.x, .SHADER_UNIFORM_VEC2);
        }

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(DARKBLUE);

            // Draw stars and bobs
            for n: 0..MAX_STARS-1 {
                // Single pixel is just too small these days!
                DrawRectangle(cast(s32)stars[n].position.x, cast(s32)stars[n].position.y, 2, 2, WHITE);
            }

            for i: 0..15 {
                DrawTexture(texRay,
                    cast(s32)((screenWidth/2.0) + cos((frameCounter + i*8)/51.45)*(screenWidth/2.2) - 32),
                    cast(s32)((screenHeight/2.0) + sin((frameCounter + i*8)/17.87)*(screenHeight/4.2)), WHITE);
            }

            // Draw spot lights
            BeginShaderMode(shdrSpot);
                // Instead of a blank rectangle you could render here
                // a render texture of the full screen used to do screen
                // scaling (slight adjustment to shader would be required
                // to actually pay attention to the colour!)
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            DrawFPS(10, 10);

            DrawText("Move the mouse!", 10, 30, 20, GREEN);
            DrawText("Pitch Black", cast(s32)(screenWidth*0.2), screenHeight/2, 20, GREEN);
            DrawText("Dark", cast(s32)(screenWidth*.66), screenHeight/2, 20, GREEN);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texRay);
    UnloadShader(shdrSpot);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

ResetStar :: (s: *Star) {
    s.position = Vector2.{GetScreenWidth()/2.0, GetScreenHeight()/2.0};

    s.speed.x = cast(float)GetRandomValue(-1000, 1000)/100.0;
    s.speed.y = cast(float)GetRandomValue(-1000, 1000)/100.0;


    while (!((abs(s.speed.x) > 0) || (abs(s.speed.y) > 1))) {
        s.speed.x = cast(float)GetRandomValue(-1000, 1000)/100.0;
        s.speed.y = cast(float)GetRandomValue(-1000, 1000)/100.0;
    }

    s.position = Vector2Add(s.position, Vector2Multiply(s.speed, Vector2.{8.0, 8.0}));
}

UpdateStar :: (s: *Star) {
    s.position = Vector2Add(s.position, s.speed);

    if ((s.position.x < 0) || (s.position.x > cast(float)GetScreenWidth()) ||
        (s.position.y < 0) || (s.position.y > cast(float)GetScreenHeight())) {
        ResetStar(s);
    }
}
