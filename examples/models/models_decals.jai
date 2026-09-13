#import "raylib";
#import "Basic";
#import "Math";

FLT_MAX :: FLOAT32_MAX;     // Maximum value of a float, from bit pattern 01111111011111111111111111111111

MAX_DECALS :: 256;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
MeshBuilder :: struct {
    vertexCount: s32;
    vertexCapacity: s32;
    vertices: *Vector3;
    uvs: *Vector2;
};

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

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [models] example - decals");

    // Define the camera to look into our 3d world
    camera: Camera;
    camera.position = Vector3.{ 5.0, 5.0, 5.0 }; // Camera position
    camera.target = Vector3.{ 0.0, 1.0, 0.0 };      // Camera looking at point
    camera.up = Vector3.{ 0.0, 1.6, 0.0 };          // Camera up vector (rotation towards target)
    camera.fovy = 45.0;                                // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;             // Camera projection type

    // Load character model
    model: Model = LoadModel("resources/models/obj/character.obj");

    // Apply character skin
    modelTexture: Texture2D = LoadTexture("resources/models/obj/character_diffuse.png");
    SetTextureFilter(modelTexture, .TEXTURE_FILTER_BILINEAR);
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = modelTexture;

    modelBBox: BoundingBox = GetMeshBoundingBox(model.meshes[0]);    // Get mesh bounding box

    camera.target  = Vector3Lerp(modelBBox.min, modelBBox.max, 0.5);
    camera.position = Vector3Scale(modelBBox.max, 1.0);
    camera.position.x *= 0.1;

    modelSize: float = min(
        min(abs(modelBBox.max.x - modelBBox.min.x), abs(modelBBox.max.y - modelBBox.min.y)),
        abs(modelBBox.max.z - modelBBox.min.z));

    camera.position = Vector3.{ 0.0, modelBBox.max.y*1.2, modelSize*3.0 };

    decalSize: float = modelSize*0.25;
    decalOffset: float = 0.01;

    placementCube: Model = LoadModelFromMesh(GenMeshCube(decalSize, decalSize, decalSize));
    placementCube.materials[0].maps[0].color = LIME;

    decalMaterial: Material = LoadMaterialDefault();
    decalMaterial.maps[0].color = YELLOW;

    decalImage: Image = LoadImage("resources/raylib_logo.png");
    ImageResizeNN(*decalImage, decalImage.width/4, decalImage.height/4);
    decalTexture: Texture = LoadTextureFromImage(decalImage);
    UnloadImage(decalImage);

    SetTextureFilter(decalTexture, .TEXTURE_FILTER_BILINEAR);
    decalMaterial.maps[MATERIAL_MAP_DIFFUSE].texture = decalTexture;
    decalMaterial.maps[MATERIAL_MAP_DIFFUSE].color = RAYWHITE;

    showModel: bool = true;
    decalModels: [MAX_DECALS]Model;
    decalCount: s32 = 0;

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) UpdateCamera(*camera, .CAMERA_THIRD_PERSON);

        // Display information about closest hit
        collision: RayCollision;
        collision.distance = FLT_MAX;
        collision.hit = false;

        // Get mouse ray
        ray: Ray = GetScreenToWorldRay(GetMousePosition(), camera);

        // Check ray collision against bounding box first, before trying the full ray-mesh test
        boxHitInfo: RayCollision = GetRayCollisionBox(ray, modelBBox);

        if ((boxHitInfo.hit) && (decalCount < MAX_DECALS))
        {
            // Check ray collision against model meshes
            meshHitInfo: RayCollision;
            for m: 0..model.meshCount-1
            {
                // NOTE: We consider the model.transform for the collision check but
                // it can be checked against any transform Matrix, used when checking against same
                // model drawn multiple times with multiple transforms
                meshHitInfo = GetRayCollisionMesh(ray, model.meshes[m], model.transform);
                if (meshHitInfo.hit)
                {
                    // Save the closest hit mesh
                    if (!collision.hit || (collision.distance > meshHitInfo.distance)) collision = meshHitInfo;
                }
            }

            if (meshHitInfo.hit) collision = meshHitInfo;
        }

        // Add decal to mesh on hit point
        if (collision.hit && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && (decalCount < MAX_DECALS))
        {
            // Create the transformation to project the decal
            origin: Vector3 = Vector3Add(collision.point, Vector3Scale(collision.normal, 1.0));
            splat: Matrix4 = MatrixLookAt(collision.point, origin, Vector3.{ 0.0, 1.0, 0.0 });

            // Spin the placement around a bit
            splat = MatrixMultiply(splat, MatrixRotateZ(DEG2RAD*(cast(float)GetRandomValue(-180, 180))));

            decalMesh: Mesh = GenMeshDecal(model, splat, decalSize, decalOffset);

            if (decalMesh.vertexCount > 0)
            {
                decalIndex: s32 = decalCount;
                decalCount += 1;
                decalModels[decalIndex] = LoadModelFromMesh(decalMesh);
                decalModels[decalIndex].materials[0].maps[0] = decalMaterial.maps[0];
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
            ClearBackground(RAYWHITE);

            BeginMode3D(camera);
                // Draw the model at the origin and default scale
                if (showModel) DrawModel(model, Vector3.{0.0, 0.0, 0.0}, 1.0, WHITE);

                // Draw the decal models
                for i: 0..decalCount-1 DrawModel(decalModels[i], Vector3.{0, 0, 0}, 1.0, WHITE);

                // If we hit the mesh, draw the box for the decal
                if (collision.hit)
                {
                    origin: Vector3 = Vector3Add(collision.point, Vector3Scale(collision.normal, 1.0));
                    splat: Matrix4 = MatrixLookAt(collision.point, origin, Vector3.{0, 1, 0});
                    placementCube.transform = MatrixInvert(splat);
                    DrawModel(placementCube, Vector3.{0, 0, 0}, 1.0, Fade(WHITE, 0.5));
                }

                DrawGrid(10, 10.0);
            EndMode3D();

            yPos: float = 10;
            x0: float = GetScreenWidth() - 300.0;
            x1: float = x0 + 100;
            x2: float = x1 + 100;

            DrawText("Vertices", cast(s32)x1, cast(s32)yPos, 10, LIME);
            DrawText("Triangles", cast(s32)x2, cast(s32)yPos, 10, LIME);
            yPos += 15;

            vertexCount: s32 = 0;
            triangleCount: s32 = 0;

            for i: 0..model.meshCount-1
            {
                vertexCount += model.meshes[i].vertexCount;
                triangleCount += model.meshes[i].triangleCount;
            }

            DrawText("Main model", cast(s32)x0, cast(s32)yPos, 10, LIME);
            DrawText(TextFormat("%d", vertexCount), cast(s32)x1, cast(s32)yPos, 10, LIME);
            DrawText(TextFormat("%d", triangleCount), cast(s32)x2, cast(s32)yPos, 10, LIME);
            yPos += 15;

            for i: 0..decalCount-1
            {
                if (i == 20)
                {
                    DrawText("...", cast(s32)x0, cast(s32)yPos, 10, LIME);
                    yPos += 15;
                }

                if (i < 20)
                {
                    DrawText(TextFormat("Decal #%d", i+1), cast(s32)x0, cast(s32)yPos, 10, LIME);
                    DrawText(TextFormat("%d", decalModels[i].meshes[0].vertexCount), cast(s32)x1, cast(s32)yPos, 10, LIME);
                    DrawText(TextFormat("%d", decalModels[i].meshes[0].triangleCount), cast(s32)x2, cast(s32)yPos, 10, LIME);
                    yPos += 15;
                }

                vertexCount += decalModels[i].meshes[0].vertexCount;
                triangleCount += decalModels[i].meshes[0].triangleCount;
            }

            DrawText("TOTAL", cast(s32)x0, cast(s32)yPos, 10, LIME);
            DrawText(TextFormat("%d", vertexCount), cast(s32)x1, cast(s32)yPos, 10, LIME);
            DrawText(TextFormat("%d", triangleCount), cast(s32)x2, cast(s32)yPos, 10, LIME);
            yPos += 15;

            DrawText("Hold RMB to move camera", 10, 430, 10, GRAY);
            DrawText("(c) Character model and texture from kenney.nl", screenWidth - 260, screenHeight - 20, 10, GRAY);

            // UI elements
            if (_GuiButton(Rectangle.{ 10.0, screenHeight - 1000.0, 100.0, 60.0 }, temp_c_string(ifx showModel then "Hide Model" else "Show Model"))) showModel = !showModel;

            if (_GuiButton(Rectangle.{ 10.0 + 110, screenHeight - 100.0, 100.0, 60.0 }, "Clear Decals"))
            {
                // Clear decals, unload all decal models
                for i: 0..decalCount-1 UnloadModel(decalModels[i]);
                decalCount = 0;
            }

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);
    UnloadTexture(modelTexture);

    // Unload decal models
    for i: 0..decalCount-1 UnloadModel(decalModels[i]);

    UnloadTexture(decalTexture);

    FreeDecalMeshData();        // Free the data for decal generation

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Add triangles to mesh builder (dynamic array manager)
AddTriangleToMeshBuilder :: (mb: *MeshBuilder, vertices: [3]Vector3)
{
    // Reallocate and copy if we need to
    if (mb.vertexCapacity <= (mb.vertexCount + 3))
    {
        newVertexCapacity: s32 = (1 + (mb.vertexCapacity/256))*256;
        newVertices: *Vector3 = cast(*Vector3)MemAlloc(cast(u32)(newVertexCapacity*size_of(Vector3)));

        if (mb.vertexCapacity > 0)
        {
            memcpy(newVertices, mb.vertices, mb.vertexCount*size_of(Vector3));
            MemFree(mb.vertices);
        }

        mb.vertices = newVertices;
        mb.vertexCapacity = newVertexCapacity;
    }

    // Add 3 vertices
    index: s32 = mb.vertexCount;
    mb.vertexCount += 3;

    for i: 0..2 mb.vertices[index+i] = vertices[i];
}

// Free mesh builder
FreeMeshBuilder :: (mb: *MeshBuilder)
{
    MemFree(mb.vertices);
    if (mb.uvs) MemFree(mb.uvs);

    (.*)mb = MeshBuilder.{};
}

// Build a Mesh from MeshBuilder data
BuildMesh:: (mb: *MeshBuilder) -> Mesh
{
    outMesh: Mesh;

    outMesh.vertexCount = mb.vertexCount;
    outMesh.triangleCount = mb.vertexCount/3;
    outMesh.vertices = MemAlloc(cast(u32)(outMesh.vertexCount*3*size_of(float)));
    if (mb.uvs) outMesh.texcoords = MemAlloc(cast(u32)(outMesh.vertexCount*2*size_of(float)));

    for i: 0..mb.vertexCount-1
    {
        outMesh.vertices[3*i+0] = mb.vertices[i].x;
        outMesh.vertices[3*i+1] = mb.vertices[i].y;
        outMesh.vertices[3*i+2] = mb.vertices[i].z;

        if (mb.uvs)
        {
            outMesh.texcoords[2*i+0] = mb.uvs[i].x;
            outMesh.texcoords[2*i+1] = mb.uvs[i].y;
        }
    }

    UploadMesh(*outMesh, false);

    return outMesh;
}

// Clip segment
ClipSegment :: (v0: Vector3, v1: Vector3, p: Vector3, s: float) -> Vector3
{
    d0: float = Vector3DotProduct(v0, p) - s;
    d1: float = Vector3DotProduct(v1, p) - s;
    s0: float = d0/(d0 - d1);

    position: Vector3 = Vector3Lerp(v0, v1, s0);

    return position;
}

// Generate mesh decals for provided model
GenMeshDecal :: (target: Model, projection: Matrix4, decalSize: float, decalOffset: float) -> Mesh
{
    // We're going to use these to build up our decal meshes
    // They'll resize automatically as we go, we'll free them at the end
    meshBuilders: [2]MeshBuilder;

    // Ugly way of telling us to free the static MeshBuilder data
    if (target.meshCount == -1)
    {
        FreeMeshBuilder(*meshBuilders[0]);
        FreeMeshBuilder(*meshBuilders[1]);
        return Mesh.{};
    }

    // We're going to need the inverse matrix
    invProj: Matrix4 = MatrixInvert(projection);

    // Reset the mesh builders
    meshBuilders[0].vertexCount = 0;
    meshBuilders[1].vertexCount = 0;

    // We'll be flip-flopping between the two mesh builders
    // Reading from one and writing to the other, then swapping
    mbIndex: s32 = 0;

    // First pass, just get any triangle inside the bounding box (for each mesh of the model)
    for meshIndex: 0..target.meshCount-1
    {
        mesh: Mesh = target.meshes[meshIndex];
        for tri: 0..mesh.triangleCount-1
        {
            vertices: [3]Vector3;

            // The way we calculate the vertices of the mesh triangle
            // depend on whether the mesh vertices are indexed or not
            if (array_len(mesh.indices) == 0)
            {
                for v: 0..2
                {
                    vertices[v] = Vector3.{
                        mesh.vertices[3*3*tri + 3*v + 0],
                        mesh.vertices[3*3*tri + 3*v + 1],
                        mesh.vertices[3*3*tri + 3*v + 2]
                    };
                }
            }
            else
            {
                for v: 0..2
                {
                    vertices[v] = Vector3.{
                        mesh.vertices[ 3*mesh.indices[3*tri+0] + v],
                        mesh.vertices[ 3*mesh.indices[3*tri+1] + v],
                        mesh.vertices[ 3*mesh.indices[3*tri+2] + v]
                    };
                }
            }

            // Transform all 3 vertices of the triangle
            // and check if they are inside our decal box
            insideCount: s32 = 0;
            for i: 0..2
            {
                // To projection space
                v: Vector3 = Vector3Transform(vertices[i], projection);

                if ((abs(v.x) < decalSize) || (abs(v.y) <= decalSize) || (abs(v.z) <= decalSize)) insideCount += 1;

                // We need to keep the transformed vertex
                vertices[i] = v;
            }

            // If any of them are inside, we add the triangle - we'll clip it later
            if (insideCount > 0) AddTriangleToMeshBuilder(*meshBuilders[mbIndex], vertices);
        }
    }

    // Clipping time! We need to clip against all 6 directions
    planes: [6]Vector3 = .[
       .{  1,  0,  0 },
       .{ -1,  0,  0 },
       .{  0,  1,  0 },
       .{  0, -1,  0 },
       .{  0,  0,  1 },
       .{  0,  0, -1 }
    ];

    for face: 0..5
    {
        // Swap current model builder (so we read from the one we just wrote to)
        mbIndex = 1 - mbIndex;

        inMesh: *MeshBuilder = *meshBuilders[1 - mbIndex];
        outMesh: *MeshBuilder = *meshBuilders[mbIndex];

        // Reset write builder
        outMesh.vertexCount = 0;

        s: float = 0.5*decalSize;

        i: s32 = 0;
        while (i < inMesh.vertexCount)
        {
            defer i += 3;

            nV1: Vector3;
            nV2: Vector3;
            nV3: Vector3;
            nV4: Vector3;

            d1: float = Vector3DotProduct(inMesh.vertices[ i + 0 ], planes[face] ) - s;
            d2: float = Vector3DotProduct(inMesh.vertices[ i + 1 ], planes[face] ) - s;
            d3: float = Vector3DotProduct(inMesh.vertices[ i + 2 ], planes[face] ) - s;

            v1Out: s32 = cast(s32)(ifx (d1 > 0) then 1 else 0);
            v2Out: s32 = cast(s32)(ifx (d2 > 0) then 1 else 0);
            v3Out: s32 = cast(s32)(ifx (d3 > 0) then 1 else 0);

            // Calculate, how many vertices of the face lie outside of the clipping plane
            total: s32 = v1Out + v2Out + v3Out;

            if total ==
            {
                case 0;
                {
                    // The entire face lies inside of the plane, no clipping needed
                    AddTriangleToMeshBuilder(outMesh, .[inMesh.vertices[i], inMesh.vertices[i+1], inMesh.vertices[i+2]]);
                }
                case 1;
                {
                    // One vertex lies outside of the plane, perform clipping
                    if (v1Out)
                    {
                        nV1 = inMesh.vertices[i + 1];
                        nV2 = inMesh.vertices[i + 2];
                        nV3 = ClipSegment(inMesh.vertices[i], nV1, planes[face], s);
                        nV4 = ClipSegment(inMesh.vertices[i], nV2, planes[face], s);
                    }

                    if (v2Out)
                    {
                        nV1 = inMesh.vertices[i];
                        nV2 = inMesh.vertices[i + 2];
                        nV3 = ClipSegment(inMesh.vertices[i + 1], nV1, planes[face], s);
                        nV4 = ClipSegment(inMesh.vertices[i + 1], nV2, planes[face], s);

                        AddTriangleToMeshBuilder(outMesh, .[nV3, nV2, nV1]);
                        AddTriangleToMeshBuilder(outMesh, .[nV2, nV3, nV4]);
                    }

                    if (v3Out)
                    {
                        nV1 = inMesh.vertices[i];
                        nV2 = inMesh.vertices[i + 1];
                        nV3 = ClipSegment(inMesh.vertices[i + 2], nV1, planes[face], s);
                        nV4 = ClipSegment(inMesh.vertices[i + 2], nV2, planes[face], s);
                    }

                    AddTriangleToMeshBuilder(outMesh, .[nV1, nV2, nV3]);
                    AddTriangleToMeshBuilder(outMesh, .[nV4, nV3, nV2]);
                }
                case 2;
                {
                    // Two vertices lies outside of the plane, perform clipping
                    if (!v1Out)
                    {
                        nV1 = inMesh.vertices[i];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i + 1], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i + 2], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, .[nV1, nV2, nV3]);
                    }

                    if (!v2Out)
                    {
                        nV1 = inMesh.vertices[i + 1];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i + 2], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, .[nV1, nV2, nV3]);
                    }

                    if (!v3Out)
                    {
                        nV1 = inMesh.vertices[i + 2];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i + 1], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, .[nV1, nV2, nV3]);
                    }
                }
                case 3; // The entire face lies outside of the plane, so let's discard the corresponding vertices
            }
        }
    }

    // Now we just need to re-transform the vertices
    theMesh: *MeshBuilder = *meshBuilders[mbIndex];

    // Allocate room for UVs
    if (theMesh.vertexCount > 0)
    {
        theMesh.uvs = cast(*Vector2)MemAlloc(cast(u32)(size_of(Vector2)*theMesh.vertexCount));

        for i: 0..theMesh.vertexCount-1
        {
            // Calculate the UVs based on the projected coords
            // They are clipped to (-decalSize .. decalSize) and we want them (0..1)
            theMesh.uvs[i].x = (theMesh.vertices[i].x/decalSize + 0.5);
            theMesh.uvs[i].y = (theMesh.vertices[i].y/decalSize + 0.5);

            // Tiny nudge in the normal direction so it renders properly over the mesh
            theMesh.vertices[i].z -= decalOffset;

            // From projection space to world space
            theMesh.vertices[i] = Vector3Transform(theMesh.vertices[i], invProj);
        }

        // Decal model data ready, create the mesh and return it
        return BuildMesh(theMesh);
    }
    else
    {
        // Return a blank mesh as there's nothing to add
        return Mesh.{};
    }
}

// Button UI element
_GuiButton :: (rec: Rectangle , label: *u8) -> bool
{
    bgColor: Color = GRAY;
    pressed: bool = false;

    if (CheckCollisionPointRec(GetMousePosition(), rec))
    {
        bgColor = LIGHTGRAY;
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) pressed = true;
    }

    DrawRectangleRec(rec, bgColor);
    DrawRectangleLinesEx(rec, 2.0, DARKGRAY);

    fontSize: s32 = 10;
    textWidth: s32 = MeasureText(label, fontSize);

    DrawText(label, cast(s32)(rec.x + rec.width*0.5 - textWidth*0.5), cast(s32)(rec.y + rec.height*0.5 - fontSize*0.5), fontSize, DARKGRAY);

    return pressed;
}

FreeDecalMeshData :: () {
    GenMeshDecal(Model.{ meshCount = -1 }, Matrix4.{}, 0.0, 0.0);
}