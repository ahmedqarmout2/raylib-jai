#import "raylib";
#import "Basic";
#import "Math";

MAX_POINTS :: 10000000;     // 10 million
MIN_POINTS :: 1000;         // 1 thousand

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - point rendering");

    camera: Camera = .{
        position   = .{ 3.0, 3.0, 3.0 },
        target     = .{ 0.0, 0.0, 0.0 },
        up         = .{ 0.0, 1.0, 0.0 },
        fovy       = 45.0,
        projection = .CAMERA_PERSPECTIVE
    };

    position: Vector3 = .{ 0.0, 0.0, 0.0 };
    useDrawModelPoints: bool = true;
    numPointsChanged: bool = false;
    numPoints: s32 = 1000;
    
    mesh: Mesh = GenMeshPoints(numPoints);
    model: Model = LoadModelFromMesh(mesh);
    
    //SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while(!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsKeyPressed(.KEY_SPACE)) useDrawModelPoints = !useDrawModelPoints;
        if (IsKeyPressed(.KEY_UP))
        {
            numPoints = ifx(numPoints*10 > MAX_POINTS) then MAX_POINTS else numPoints*10;
            numPointsChanged = true;
        }
        if (IsKeyPressed(.KEY_DOWN))
        {
            numPoints = ifx(numPoints/10 < MIN_POINTS) then MIN_POINTS else numPoints/10;
            numPointsChanged = true;
        }

        // Upload a different point cloud size
        if (numPointsChanged)
        {
            UnloadModel(model);
            mesh = GenMeshPoints(numPoints);
            model = LoadModelFromMesh(mesh);
            numPointsChanged = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(BLACK);

            BeginMode3D(camera);

                // The new method only uploads the points once to the GPU
                if (useDrawModelPoints)
                {
                    DrawModelPoints(model, position, 1.0, WHITE);
                }
                else
                {
                    // The old method must continually draw the "points" (lines)
                    for i: 0..numPoints-1
                    {
                        pos: Vector3 = .{
                            x = mesh.vertices[i*3 + 0],
                            y = mesh.vertices[i*3 + 1],
                            z = mesh.vertices[i*3 + 2],
                        };
                        color: Color = .{
                            r = mesh.colors[i*4 + 0],
                            g = mesh.colors[i*4 + 1],
                            b = mesh.colors[i*4 + 2],
                            a = mesh.colors[i*4 + 3],
                        };
                        
                        DrawPoint3D(pos, color);
                    }
                }

                // Draw a unit sphere for reference
                DrawSphereWires(position, 1.0, 10, 10, YELLOW);
                
            EndMode3D();

            // Draw UI text
            DrawText(TextFormat("Point Count: %d", numPoints), 20, screenHeight - 50, 40, WHITE);
            DrawText("Up - increase points", 20, 70, 20, WHITE);
            DrawText("Down - decrease points", 20, 100, 20, WHITE);
            DrawText("Space - drawing function", 20, 130, 20, WHITE);
            
            if (useDrawModelPoints) DrawText("Using: DrawModelPoints()", 20, 160, 20, GREEN);
            else DrawText("Using: DrawPoint3D()", 20, 160, 20, RED);
            
            DrawFPS(10, 10);
            
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);

    CloseWindow();
    //--------------------------------------------------------------------------------------
}

// Generate a spherical point cloud
GenMeshPoints :: (numPoints: s32) -> Mesh
{
    mesh: Mesh = .{ 
        triangleCount = 1,
        vertexCount = numPoints,
        vertices = cast(*float)MemAlloc(cast(u32)(numPoints*3*size_of(float))),
        colors = cast(*u8)MemAlloc(cast(u32)(numPoints*4*size_of(u8))),
    };

    // https://en.wikipedia.org/wiki/Spherical_coordinate_system
    for i: 0..numPoints-1 {
        theta: float = PI*GetRandomValue(0, S32_MAX)/S32_MAX;
        phi: float = 2.0*PI*GetRandomValue(0, S32_MAX)/S32_MAX;
        r: float = 10.0*GetRandomValue(0, S32_MAX)/S32_MAX;
        
        mesh.vertices[i*3 + 0] = r*sin(theta)*cos(phi);
        mesh.vertices[i*3 + 1] = r*sin(theta)*sin(phi);
        mesh.vertices[i*3 + 2] = r*cos(theta);
        
        color: Color = ColorFromHSV(r*360.0, 1.0, 1.0);
        
        mesh.colors[i*4 + 0] = color.r;
        mesh.colors[i*4 + 1] = color.g;
        mesh.colors[i*4 + 2] = color.b;
        mesh.colors[i*4 + 3] = color.a;
    }

    // Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    UploadMesh(*mesh, false);
    
    return mesh;
}
