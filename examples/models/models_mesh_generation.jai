#import "raylib";
#import "Basic";
#import "Math";

NUM_MODELS :: 9;               // Parametric 3d shapes to generate

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh generation");

    // We generate a checked image for texturing
    checked: Image = GenImageChecked(2, 2, 1, 1, RED, GREEN);
    texture: Texture2D = LoadTextureFromImage(checked);
    UnloadImage(checked);

    models: [NUM_MODELS]Model;

    models[0] = LoadModelFromMesh(GenMeshPlane(2, 2, 4, 3));
    models[1] = LoadModelFromMesh(GenMeshCube(2.0, 1.0, 2.0));
    models[2] = LoadModelFromMesh(GenMeshSphere(2, 32, 32));
    models[3] = LoadModelFromMesh(GenMeshHemiSphere(2, 16, 16));
    models[4] = LoadModelFromMesh(GenMeshCylinder(1, 2, 16));
    models[5] = LoadModelFromMesh(GenMeshTorus(0.25, 4.0, 16, 32));
    models[6] = LoadModelFromMesh(GenMeshKnot(1.0, 2.0, 16, 128));
    models[7] = LoadModelFromMesh(GenMeshPoly(5, 2.0));
    models[8] = LoadModelFromMesh(GenMeshCustom());
    
    // Generated meshes could be exported as .obj files
    //ExportMesh(models[0].meshes[0], "plane.obj");
    //ExportMesh(models[1].meshes[0], "cube.obj");
    //ExportMesh(models[2].meshes[0], "sphere.obj");
    //ExportMesh(models[3].meshes[0], "hemisphere.obj");
    //ExportMesh(models[4].meshes[0], "cylinder.obj");
    //ExportMesh(models[5].meshes[0], "torus.obj");
    //ExportMesh(models[6].meshes[0], "knot.obj");
    //ExportMesh(models[7].meshes[0], "poly.obj");
    //ExportMesh(models[8].meshes[0], "custom.obj");

    // Set checked texture as default diffuse component for all models material
    for i: 0..NUM_MODELS-1 models[i].materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;

    // Define the camera to look into our 3d world
    camera: Camera = .{ .{ 5.0, 5.0, 5.0 }, .{ 0.0, 0.0, 0.0 }, .{ 0.0, 1.0, 0.0 }, 45.0, .CAMERA_PERSPECTIVE };

    // Model drawing position
    position: Vector3 = .{ 0.0, 0.0, 0.0 };

    currentModel: s32 = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, .CAMERA_ORBITAL);

        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
        {
            currentModel = (currentModel + 1)%NUM_MODELS; // Cycle between the textures
        }

        if (IsKeyPressed(.KEY_RIGHT))
        {
            currentModel += 1;
            if (currentModel >= NUM_MODELS) currentModel = 0;
        }
        else if (IsKeyPressed(.KEY_LEFT))
        {
            currentModel -= 1;
            if (currentModel < 0) currentModel = NUM_MODELS - 1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

               DrawModel(models[currentModel], position, 1.0, WHITE);
               DrawGrid(10, 1.0);

            EndMode3D();

            DrawRectangle(30, 400, 310, 30, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(30, 400, 310, 30, Fade(DARKBLUE, 0.5));
            DrawText("MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, BLUE);

            if currentModel == {
                case 0; DrawText("PLANE", 680, 10, 20, DARKBLUE);
                case 1; DrawText("CUBE", 680, 10, 20, DARKBLUE);
                case 2; DrawText("SPHERE", 680, 10, 20, DARKBLUE);
                case 3; DrawText("HEMISPHERE", 640, 10, 20, DARKBLUE);
                case 4; DrawText("CYLINDER", 680, 10, 20, DARKBLUE);
                case 5; DrawText("TORUS", 680, 10, 20, DARKBLUE);
                case 6; DrawText("KNOT", 680, 10, 20, DARKBLUE);
                case 7; DrawText("POLY", 680, 10, 20, DARKBLUE);
                case 8; DrawText("Custom (triangle)", 580, 10, 20, DARKBLUE);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture); // Unload texture

    // Unload models data (GPU VRAM)
    for i: 0..NUM_MODELS-1 UnloadModel(models[i]);

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

// Generate a simple triangle mesh from code
GenMeshCustom :: () -> Mesh {
    mesh: Mesh;
    mesh.triangleCount = 1;
    mesh.vertexCount = mesh.triangleCount*3;
    mesh.vertices = cast(*float)alloc(mesh.vertexCount*3*size_of(float));    // 3 vertices, 3 coordinates each (x, y, z)
    mesh.texcoords = cast(*float)alloc(mesh.vertexCount*2*size_of(float));   // 3 vertices, 2 coordinates each (x, y)
    mesh.normals = cast(*float)alloc(mesh.vertexCount*3*size_of(float));     // 3 vertices, 3 coordinates each (x, y, z)

    // Vertex at (0, 0, 0)
    mesh.vertices[0] = 0;
    mesh.vertices[1] = 0;
    mesh.vertices[2] = 0;
    mesh.normals[0] = 0;
    mesh.normals[1] = 1;
    mesh.normals[2] = 0;
    mesh.texcoords[0] = 0;
    mesh.texcoords[1] = 0;

    // Vertex at (1, 0, 2)
    mesh.vertices[3] = 1;
    mesh.vertices[4] = 0;
    mesh.vertices[5] = 2;
    mesh.normals[3] = 0;
    mesh.normals[4] = 1;
    mesh.normals[5] = 0;
    mesh.texcoords[2] = 0.5;
    mesh.texcoords[3] = 1.0;

    // Vertex at (2, 0, 0)
    mesh.vertices[6] = 2;
    mesh.vertices[7] = 0;
    mesh.vertices[8] = 0;
    mesh.normals[6] = 0;
    mesh.normals[7] = 1;
    mesh.normals[8] = 0;
    mesh.texcoords[4] = 1;
    mesh.texcoords[5] =0;

    // Upload mesh data from CPU (RAM) to GPU (VRAM) memory
    UploadMesh(*mesh, false);

    return mesh;
}
