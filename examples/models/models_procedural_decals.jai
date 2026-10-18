#import "raylib";
#import "Basic";
#import "Math";

//--------------------------------------------------------------------------------------
// Global Definitions
//--------------------------------------------------------------------------------------
MAX_DECALS :: 256;

//--------------------------------------------------------------------------------------
// Types and Structures Definition
//--------------------------------------------------------------------------------------

// Growable triangle-soup buffer used while building a clipped decal mesh
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
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT);
    InitWindow(screenWidth, screenHeight, "raylib [models] example - procedural decals");

    camera: Camera3D;
    camera.position = Vector3.{ 0.0, 2.5, 5.0 };
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // Target model: a procedurally generated knot with a checkerboard skin
    model: Model = LoadModelFromMesh(GenMeshTorus(0.8, 1.8, 32, 64));

    checkerImage: Image = GenImageChecked(512, 512, 32, 32, LIGHTGRAY, GRAY);
    modelTexture: Texture2D  = LoadTextureFromImage(checkerImage);
    UnloadImage(checkerImage);
    SetTextureFilter(modelTexture, .TEXTURE_FILTER_BILINEAR);
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = modelTexture;

    modelBBox: BoundingBox = GetMeshBoundingBox(model.meshes[0]);
    camera.target = Vector3Lerp(modelBBox.min, modelBBox.max, 0.5);

    modelSize: float = min(min(abs(modelBBox.max.x - modelBBox.min.x),
        abs(modelBBox.max.y - modelBBox.min.y)), abs(modelBBox.max.z - modelBBox.min.z));

    decalSize: float = modelSize*0.35;
    decalOffset: float = 0.01;

    // Translucent cube previewing where the next decal will land
    placementCube: Model = LoadModelFromMesh(GenMeshCube(decalSize, decalSize, decalSize));
    placementCube.materials[0].maps[0].color = LIME;

    // Decal texture: a procedurally drawn target/bullseye, no image file needed
    decalImage: Image = GenImageColor(128, 128, BLANK);
    ImageDrawCircle(*decalImage, 64, 64, 60, RED);
    ImageDrawCircle(*decalImage, 64, 64, 45, WHITE);
    ImageDrawCircle(*decalImage, 64, 64, 30, RED);
    ImageDrawCircle(*decalImage, 64, 64, 15, YELLOW);

    decalTexture: Texture2D = LoadTextureFromImage(decalImage);
    UnloadImage(decalImage);
    SetTextureFilter(decalTexture, .TEXTURE_FILTER_BILINEAR);

    decalMaterial: Material = LoadMaterialDefault();
    decalMaterial.maps[MATERIAL_MAP_DIFFUSE].texture = decalTexture;
    decalMaterial.maps[MATERIAL_MAP_DIFFUSE].color = RAYWHITE;

    showModel: bool = true;
    decals: [MAX_DECALS]Model;
    decalCount: s32 = 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) UpdateCamera(*camera, .CAMERA_THIRD_PERSON);

        // Cast a ray from the mouse and keep the closest point it hits on the model
        ray: Ray = GetScreenToWorldRay(GetMousePosition(), camera);
        collision: RayCollision;

        if (GetRayCollisionBox(ray, modelBBox).hit && (decalCount < MAX_DECALS))
        {
            for m: 0..model.meshCount-1
            {
                meshHit: RayCollision = GetRayCollisionMesh(ray, model.meshes[m], model.transform);
                if (meshHit.hit && (!collision.hit || (meshHit.distance < collision.distance))) collision = meshHit;
            }
        }

        // Project a new decal at the hit point, facing along the surface normal
        if (collision.hit && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && (decalCount < MAX_DECALS))
        {
            lookTarget: Vector3 = Vector3Add(collision.point, collision.normal);
            splat: Matrix4 = MatrixLookAt(collision.point, lookTarget, Vector3.{ 0.0, 1.0, 0.0 });
            splat = MatrixMultiply(splat, MatrixRotateZ(DEG2RAD*cast(float)GetRandomValue(-180, 180)));

            decalMesh: Mesh = GenMeshDecal(model, splat, decalSize, decalOffset);

            if (decalMesh.vertexCount > 0)
            {
                decals[decalCount] = LoadModelFromMesh(decalMesh);
                decals[decalCount].materials[0].maps[0] = decalMaterial.maps[0];
                decalCount += 1;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            BeginMode3D(camera);

                if (showModel) DrawModel(model, Vector3Zero(), 1.0, WHITE);

                for i: 0..decalCount-1 DrawModel(decals[i], Vector3Zero(), 1.0, WHITE);

                // Preview cube at the surface point currently under the mouse
                if (collision.hit)
                {
                    lookTarget: Vector3 = Vector3Add(collision.point, collision.normal);
                    splat: Matrix4 = MatrixLookAt(collision.point, lookTarget, Vector3.{ 0.0, 1.0, 0.0 });
                    placementCube.transform = MatrixInvert(splat);
                    DrawModel(placementCube, Vector3Zero(), 1.0, Fade(WHITE, 0.5));
                }

                DrawGrid(10, 1.0);

            EndMode3D();

            // Vertex/triangle counts: base model vs total once decal geometry is added
            baseVertices: s32 = 0; baseTriangles: s32 = 0;
            for i: 0..model.meshCount-1
            {
                baseVertices += model.meshes[i].vertexCount;
                baseTriangles += model.meshes[i].triangleCount;
            }

            totalVertices: s32 = baseVertices; totalTriangles: s32 = baseTriangles;
            for i: 0..decalCount-1
            {
                totalVertices += decals[i].meshes[0].vertexCount;
                totalTriangles += decals[i].meshes[0].triangleCount;
            }

            statX: s32 = screenWidth - 280;
            DrawText("Vertices", statX + 90, 10, 10, LIME);
            DrawText("Triangles", statX + 180, 10, 10, LIME);
            DrawText("Base Model", statX, 25, 10, LIME);
            DrawText(TextFormat("%d", baseVertices), statX + 90, 25, 10, LIME);
            DrawText(TextFormat("%d", baseTriangles), statX + 180, 25, 10, LIME);
            DrawText("TOTAL", statX, 40, 10, LIME);
            DrawText(TextFormat("%d", totalVertices), statX + 90, 40, 10, LIME);
            DrawText(TextFormat("%d", totalTriangles), statX + 180, 40, 10, LIME);

            if (GuiButton(Rectangle.{ 10, screenHeight - 80.0, 100, 40 }, temp_c_string(ifx showModel then "Hide Model" else "Show Model")))
                showModel = !showModel;

            if (GuiButton(Rectangle.{ 120, screenHeight - 80.0, 100, 40 }, "Clear Decals"))
            {
                for i: 0..decalCount-1 UnloadModel(decals[i]);
                decalCount = 0;
            }

            DrawText("Left click: place decal   |   Right drag: orbit camera", 10, screenHeight - 25, 10, DARKGRAY);
            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    for i: 0..decalCount-1 UnloadModel(decals[i]);

    UnloadModel(placementCube);
    UnloadTexture(decalTexture);
    UnloadTexture(modelTexture);
    UnloadModel(model);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Appends a triangle to a growable mesh builder buffer, growing it in fixed-size chunks
AddTriangleToMeshBuilder :: (mb: *MeshBuilder, v0: Vector3, v1: Vector3, v2: Vector3)
{
    if (mb.vertexCapacity <= (mb.vertexCount + 3))
    {
        newVertexCapacity: s32 = (1 + (mb.vertexCapacity/256))*256;
        newVertices: *Vector3 = cast(*Vector3)MemAlloc(cast(u32)newVertexCapacity*size_of(Vector3));

        if (mb.vertexCapacity > 0)
        {
            memcpy(newVertices, mb.vertices, mb.vertexCount*size_of(Vector3));
            MemFree(mb.vertices);
        }

        mb.vertices = newVertices;
        mb.vertexCapacity = newVertexCapacity;
    }

    index: s32 = mb.vertexCount;
    mb.vertexCount += 3;

    mb.vertices[index + 0] = v0;
    mb.vertices[index + 1] = v1;
    mb.vertices[index + 2] = v2;
}

// Frees a mesh builder's backing buffers
FreeMeshBuilder :: (mb: *MeshBuilder)
{
    if (mb.vertices != null) MemFree(mb.vertices);
    if (mb.uvs != null) MemFree(mb.uvs);
    (.*)mb = MeshBuilder.{};
}

// Converts a mesh builder's triangle soup into a standard uploaded raylib Mesh
BuildMesh :: (mb: *MeshBuilder) -> Mesh
{
    outMesh: Mesh;

    outMesh.vertexCount = mb.vertexCount;
    outMesh.triangleCount = mb.vertexCount/3;
    outMesh.vertices = cast(*float)MemAlloc(cast(u32)outMesh.vertexCount*3*size_of(float));
    if (mb.uvs != null) outMesh.texcoords = cast(*float)MemAlloc(cast(u32)outMesh.vertexCount*2*size_of(float));

    for i: 0..mb.vertexCount-1
    {
        outMesh.vertices[3*i + 0] = mb.vertices[i].x;
        outMesh.vertices[3*i + 1] = mb.vertices[i].y;
        outMesh.vertices[3*i + 2] = mb.vertices[i].z;

        if (mb.uvs != null)
        {
            outMesh.texcoords[2*i + 0] = mb.uvs[i].x;
            outMesh.texcoords[2*i + 1] = mb.uvs[i].y;
        }
    }

    UploadMesh(*outMesh, false);

    return outMesh;
}

// Clips the segment [v0, v1] against the plane p.x = s, returning the intersection point
ClipSegment :: (v0: Vector3, v1: Vector3, p: Vector3, s: float) -> Vector3
{
    d0: float = Vector3DotProduct(v0, p) - s;
    d1: float = Vector3DotProduct(v1, p) - s;
    t: float = d0/(d0 - d1);

    return Vector3Lerp(v0, v1, t);
}

// Builds a decal mesh: the model's triangles are transformed into the decal's local space
// (so the decal sits at the origin, facing +Z) and clipped against a decalSize-sided box,
// following the same clip-space projection idea used by engines' decal systems (and by
// three.js' DecalGeometry, which the technique is commonly traced back to). What's left
// after clipping becomes the decal's own small mesh, UV-mapped from its local coordinates
GenMeshDecal :: (model: Model, projection: Matrix4, decalSize: float, decalOffset: float) -> Mesh
{
    invProj: Matrix4 = MatrixInvert(projection);
    meshBuilders: [2]MeshBuilder;
    mbIndex: s32 = 0;

    // Gather triangles that land anywhere near the decal box; this is a loose, cheap
    // pre-filter meant to skip most of the model, the precise clip happens below
    for meshIndex: 0..model.meshCount-1
    {
        mesh: Mesh = model.meshes[meshIndex];

        for tri: 0..mesh.triangleCount-1
        {
            vertices: [3]Vector3;

            if (mesh.indices == null)
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
                    idx: s32 = mesh.indices[3*tri + v];
                    vertices[v] = Vector3.{
                        mesh.vertices[3*idx + 0],
                        mesh.vertices[3*idx + 1],
                        mesh.vertices[3*idx + 2]
                    };
                }
            }

            insideCount: s32 = 0;
            for i: 0..2
            {
                v: Vector3 = Vector3Transform(vertices[i], projection);
                if ((abs(v.x) < decalSize) || (abs(v.y) <= decalSize) || (abs(v.z) <= decalSize)) insideCount += 1;
                vertices[i] = v;
            }

            if (insideCount > 0) AddTriangleToMeshBuilder(*meshBuilders[mbIndex], vertices[0], vertices[1], vertices[2]);
        }
    }

    // Clip the surviving triangles against each of the decal box's 6 faces in turn
    planes: [6]Vector3 = .[
        .{  1,  0,  0 }, .{ -1,  0,  0 },
        .{  0,  1,  0 }, .{  0, -1,  0 },
        .{  0,  0,  1 }, .{  0,  0, -1 }
    ];

    for face: 0..5
    {
        mbIndex = 1 - mbIndex;

        inMesh: *MeshBuilder = *meshBuilders[1 - mbIndex];
        outMesh: *MeshBuilder = *meshBuilders[mbIndex];

        outMesh.vertexCount = 0;
        s: float = 0.5*decalSize;

        i: s32 = 0;
        while (i < inMesh.vertexCount)
        {
            defer i += 3;

            nV1: Vector3; nV2: Vector3; nV3: Vector3; nV4: Vector3;

            d1: float = Vector3DotProduct(inMesh.vertices[i + 0], planes[face]) - s;
            d2: float = Vector3DotProduct(inMesh.vertices[i + 1], planes[face]) - s;
            d3: float = Vector3DotProduct(inMesh.vertices[i + 2], planes[face]) - s;

            v1Out: s32 = cast(s32)(ifx (d1 > 0) then 1 else 0);
            v2Out: s32 = cast(s32)(ifx (d2 > 0) then 1 else 0);
            v3Out: s32 = cast(s32)(ifx (d3 > 0) then 1 else 0);
            total: s32 = v1Out + v2Out + v3Out;

            if total ==
            {
                case 0;
                    // Whole triangle is inside this face, keep it as-is
                    AddTriangleToMeshBuilder(outMesh, inMesh.vertices[i], inMesh.vertices[i + 1], inMesh.vertices[i + 2]);
                case 1;
                    // One corner is outside; clip it off, turning the triangle into a quad
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

                        AddTriangleToMeshBuilder(outMesh, nV3, nV2, nV1);
                        AddTriangleToMeshBuilder(outMesh, nV2, nV3, nV4);
                    }

                    if (v3Out)
                    {
                        nV1 = inMesh.vertices[i];
                        nV2 = inMesh.vertices[i + 1];
                        nV3 = ClipSegment(inMesh.vertices[i + 2], nV1, planes[face], s);
                        nV4 = ClipSegment(inMesh.vertices[i + 2], nV2, planes[face], s);
                    }

                    AddTriangleToMeshBuilder(outMesh, nV1, nV2, nV3);
                    AddTriangleToMeshBuilder(outMesh, nV4, nV3, nV2);
                case 2;
                    // Two corners are outside; only the small corner near the surviving vertex remains
                    if (!v1Out)
                    {
                        nV1 = inMesh.vertices[i];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i + 1], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i + 2], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, nV1, nV2, nV3);
                    }

                    if (!v2Out)
                    {
                        nV1 = inMesh.vertices[i + 1];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i + 2], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, nV1, nV2, nV3);
                    }

                    if (!v3Out)
                    {
                        nV1 = inMesh.vertices[i + 2];
                        nV2 = ClipSegment(nV1, inMesh.vertices[i], planes[face], s);
                        nV3 = ClipSegment(nV1, inMesh.vertices[i + 1], planes[face], s);
                        AddTriangleToMeshBuilder(outMesh, nV1, nV2, nV3);
                    }
            }
        }
    }

    finalMesh: *MeshBuilder = *meshBuilders[mbIndex];
    decalMesh: Mesh = Mesh.{};

    if (finalMesh.vertexCount > 0)
    {
        finalMesh.uvs = cast(*Vector2)MemAlloc(size_of(Vector2)*cast(u32)finalMesh.vertexCount);

        for i: 0..finalMesh.vertexCount-1
        {
            // Clipped coordinates run roughly (-decalSize/2 .. decalSize/2); remap to (0..1)
            finalMesh.uvs[i].x = (finalMesh.vertices[i].x/decalSize + 0.5);
            finalMesh.uvs[i].y = (finalMesh.vertices[i].y/decalSize + 0.5);

            // Nudge slightly along the normal so the decal doesn't z-fight with the surface
            finalMesh.vertices[i].z -= decalOffset;
            finalMesh.vertices[i] = Vector3Transform(finalMesh.vertices[i], invProj);
        }

        decalMesh = BuildMesh(finalMesh);
    }

    FreeMeshBuilder(*meshBuilders[0]);
    FreeMeshBuilder(*meshBuilders[1]);

    return decalMesh;
}
