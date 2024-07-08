#import "raylib";
#import "Basic";
#import "Math";

MAX_POINTS: s32 : 11;      // 10 points and back to the start

main :: () {
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [textures] example - textured polygon");
    //--------------------------------------------------------------------------------------

    set_working_directory(#filepath);

    // Define texture coordinates to map our texture to poly
    texcoords: [MAX_POINTS]Vector2 = .[
        Vector2.{ 0.75, 0.0 },
        Vector2.{ 0.25, 0.0 },
        Vector2.{ 0.0, 0.5 },
        Vector2.{ 0.0, 0.75 },
        Vector2.{ 0.25, 1.0},
        Vector2.{ 0.375, 0.875},
        Vector2.{ 0.625, 0.875},
        Vector2.{ 0.75, 1.0},
        Vector2.{ 1.0, 0.75},
        Vector2.{ 1.0, 0.5},
        Vector2.{ 0.75, 0.0}  // Close the poly
    ];

    // Define the base poly vertices from the UV's
    // NOTE: They can be specified in any other way
    points: [MAX_POINTS]Vector2;
    for i: 0..MAX_POINTS-1 {
        points[i].x = (texcoords[i].x - 0.5)*256.0;
        points[i].y = (texcoords[i].y - 0.5)*256.0;
    }
    
    // Define the vertices drawing position
    // NOTE: Initially same as points but updated every frame
    positions: [MAX_POINTS]Vector2;
    for i: 0..MAX_POINTS-1 positions[i] = points[i];

    // Load texture to be mapped to poly
    texture: Texture = LoadTexture("resources/cat.png");

    angle: float = 0.0;             // Rotation angle (in degrees)

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        angle += 1;
        for i: 0..MAX_POINTS-1 positions[i] = Vector2Rotate(points[i], angle*DEG2RAD);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(RAYWHITE);

        DrawText("textured polygon", 20, 20, 20, DARKGRAY);

        DrawTexturePoly(
            texture,
            Vector2.{ GetScreenWidth()/2.0, GetScreenHeight()/2.0 },
            positions,
            texcoords,
            MAX_POINTS,
            WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture); // Unload texture

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

// Draw textured polygon, defined by vertex and texture coordinates
// NOTE: Polygon center must have straight line path to all points
// without crossing perimeter, points must be in anticlockwise order
DrawTexturePoly :: (texture: Texture2D, center: Vector2, points: []Vector2, texcoords: []Vector2, pointCount: s32, tint: Color) {
    rlSetTexture(texture.id);

    // Texturing is only supported on RL_QUADS
    rlBegin(RL_QUADS);

    rlColor4ub(tint.r, tint.g, tint.b, tint.a);

    for i: 0..pointCount - 2 {
        rlTexCoord2f(0.5, 0.5);
        rlVertex2f(center.x, center.y);

        rlTexCoord2f(texcoords[i].x, texcoords[i].y);
        rlVertex2f(points[i].x + center.x, points[i].y + center.y);

        rlTexCoord2f(texcoords[i + 1].x, texcoords[i + 1].y);
        rlVertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y);

        rlTexCoord2f(texcoords[i + 1].x, texcoords[i + 1].y);
        rlVertex2f(points[i + 1].x + center.x, points[i + 1].y + center.y);
    }
    rlEnd();

    rlSetTexture(0);
}