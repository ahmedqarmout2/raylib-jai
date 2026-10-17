#import "raylib";
#import "Basic";
#import "Math";

//--------------------------------------------------------------------------------------
// Global Definitions
//--------------------------------------------------------------------------------------
CANVAS_SIZE   ::  512;
PALETTE_COUNT ::  8;

//--------------------------------------------------------------------------------------
// Types and Structures Definition
//--------------------------------------------------------------------------------------
ToolMode :: enum s32 { TOOL_PAINT :: 0; TOOL_PICKER; };
ShapeType :: enum s32 { SHAPE_SPHERE :: 0; SHAPE_CUBE; SHAPE_CYLINDER; SHAPE_TORUS; };

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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - mesh uv painting");

    camera: Camera3D;
    camera.position = Vector3.{ 0.0, 3.5, 6.5 };
    camera.target = Vector3.{ 0.0, 0.0, 0.0 };
    camera.up = Vector3.{ 0.0, 1.0, 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    // CPU-side canvas plus the GPU texture it gets pushed to after every stroke
    canvasImage: Image = GenImageColor(CANVAS_SIZE, CANVAS_SIZE, RAYWHITE);
    canvasTexture: Texture2D  = LoadTextureFromImage(canvasImage);
    SetTextureFilter(canvasTexture, .TEXTURE_FILTER_BILINEAR);

    model: Model;
    modelBBox: BoundingBox;
    currentShape: ShapeType = .SHAPE_SPHERE;
    ChangeShape(*model, *modelBBox, *currentShape, .SHAPE_SPHERE, canvasTexture);

    currentTool: ToolMode = .TOOL_PAINT;
    activeColor: Color = RED;
    brushRadius: s32 = 12;
    lastHitUV: Vector2 = .{ 0, 0 };
    hasLastHit: bool = false;

    palette: [PALETTE_COUNT]Color = .[ RED, ORANGE, GOLD, LIME, SKYBLUE, PURPLE, DARKGRAY, WHITE ];
    uiPanelRec: Rectangle = .{ 10.0, 10.0, 230.0, 490.0 };

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePos: Vector2 = GetMousePosition();
        isMouseOverUI: bool = CheckCollisionPointRec(mousePos, uiPanelRec);

        if (IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) UpdateCamera(*camera, .CAMERA_THIRD_PERSON);

        if (!isMouseOverUI && IsMouseButtonDown(.MOUSE_BUTTON_LEFT))
        {
            ray: Ray = GetScreenToWorldRay(mousePos, camera);
            hitUV: Vector2 = .{ 0, 0 };

            if (GetMeshHitUV(ray, model, modelBBox, *hitUV))
            {
                px: s32 = cast(s32)(hitUV.x * CANVAS_SIZE);
                py: s32 = cast(s32)(hitUV.y * CANVAS_SIZE);

                if (currentTool == .TOOL_PAINT)
                {
                    // Stroke from the last hit to this one, guarding against jumps across a UV seam
                    if (hasLastHit && (abs(hitUV.x - lastHitUV.x) < 0.25) && (abs(hitUV.y - lastHitUV.y) < 0.25))
                    {
                        lastPx: s32 = cast(s32)(lastHitUV.x * CANVAS_SIZE);
                        lastPy: s32 = cast(s32)(lastHitUV.y * CANVAS_SIZE);
                        dist: float = Vector2Distance(Vector2.{ cast(float)lastPx, cast(float)lastPy }, Vector2.{ cast(float)px, cast(float)py });
                        steps: s32 = cast(s32)(dist / 2.0) + 1;

                        for i: 0..steps
                        {
                            t: float = cast(float)i / cast(float)steps;
                            ImageDrawCircle(*canvasImage, cast(s32)Lerp(cast(float)lastPx, cast(float)px, t),
                                cast(s32)Lerp(cast(float)lastPy, cast(float)py, t), brushRadius, activeColor);
                        }
                    }
                    else ImageDrawCircle(*canvasImage, px, py, brushRadius, activeColor);

                    UpdateTexture(canvasTexture, canvasImage.data);
                    lastHitUV = hitUV;
                    hasLastHit = true;
                }
                else
                {
                    activeColor = GetImageColor(canvasImage, px, py);
                    currentTool = .TOOL_PAINT;
                    hasLastHit = false;
                }
            }
            else hasLastHit = false;
        }
        else hasLastHit = false;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Color.{ 30, 32, 40, 255 });

            BeginMode3D(camera);
                DrawModel(model, Vector3Zero(), 1.0, WHITE);
                DrawGrid(10, 1.0);
            EndMode3D();

            // Side panel
            DrawRectangleRec(uiPanelRec, Fade(BLACK, 0.8));
            DrawRectangleLinesEx(uiPanelRec, 2.0, DARKGRAY);
            DrawText("MESH UV PAINTER", 25, 22, 20, GOLD);

            // Tool selection toggles
            paintActive: bool = (currentTool == .TOOL_PAINT);
            pickerActive: bool = (currentTool == .TOOL_PICKER);
            if (GuiToggle(Rectangle.{ 25, 55, 95, 32 }, "PAINT", *paintActive)) currentTool = .TOOL_PAINT;
            if (GuiToggle(Rectangle.{ 125, 55, 95, 32 }, "PICKER", *pickerActive)) currentTool = .TOOL_PICKER;

            // Shape selection toggles
            DrawText("Mesh Shape:", 25, 100, 10, LIGHTGRAY);
            sphereActive: bool = (currentShape == .SHAPE_SPHERE);
            cubeActive: bool = (currentShape == .SHAPE_CUBE);
            cylinderActive: bool = (currentShape == .SHAPE_CYLINDER);
            torusActive: bool = (currentShape == .SHAPE_TORUS);

            if (GuiToggle(Rectangle.{ 25, 120, 95, 28 }, "SPHERE", *sphereActive))
                ChangeShape(*model, *modelBBox, *currentShape, .SHAPE_SPHERE, canvasTexture);
            if (GuiToggle(Rectangle.{ 125, 120, 95, 28 }, "CUBE", *cubeActive))
                ChangeShape(*model, *modelBBox, *currentShape, .SHAPE_CUBE, canvasTexture);
            if (GuiToggle(Rectangle.{ 25, 153, 95, 28 }, "CYLINDER", *cylinderActive))
                ChangeShape(*model, *modelBBox, *currentShape, .SHAPE_CYLINDER, canvasTexture);
            if (GuiToggle(Rectangle.{ 125, 153, 95, 28 }, "TORUS", *torusActive))
                ChangeShape(*model, *modelBBox, *currentShape, .SHAPE_TORUS, canvasTexture);

            // Color display
            DrawText("Active Color:", 25, 195, 10, LIGHTGRAY);
            DrawRectangle(125, 193, 95, 20, activeColor);
            DrawRectangleLines(125, 193, 95, 20, WHITE);

            // Color swatches
            DrawText("Palette Swatches:", 25, 225, 10, LIGHTGRAY);
            for i: 0..PALETTE_COUNT-1
            {
                swatchRec: Rectangle = .{ 25.0 + (i%4)*48, 245.0 + (i/4)*45, 40.0, 38.0 };
                DrawRectangleRec(swatchRec, palette[i]);
                DrawRectangleLinesEx(swatchRec, 1.0, WHITE);
                if (CheckCollisionPointRec(mousePos, swatchRec) && IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) activeColor = palette[i];
            }

            // Brush size buttons
            DrawText(TextFormat("Brush Size: %dpx", brushRadius), 25, 345, 10, LIGHTGRAY);
            if (GuiButton(Rectangle.{ 25, 365, 95, 30 }, "SIZE -") && (brushRadius > 2)) brushRadius -= 2;
            if (GuiButton(Rectangle.{ 125, 365, 95, 30 }, "SIZE +") && (brushRadius < 64)) brushRadius += 2;

            // Canvas action buttons
            if (GuiButton(Rectangle.{ 25, 410, 95, 30 }, "CLEAR"))
            {
                ImageClearBackground(*canvasImage, RAYWHITE);
                UpdateTexture(canvasTexture, canvasImage.data);
            }
            if (GuiButton(Rectangle.{ 125, 410, 95, 30 }, "FILL"))
            {
                ImageClearBackground(*canvasImage, activeColor);
                UpdateTexture(canvasTexture, canvasImage.data);
            }

            DrawText("Left click: paint / pick color   |   Right drag: orbit camera", 260, screenHeight - 25, 10, RAYWHITE);
            DrawFPS(screenWidth - 90, 15);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);
    UnloadImage(canvasImage);
    UnloadTexture(canvasTexture);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Unloads the current model and builds a new primitive shape in its place, sharing the
// same canvas texture, and recomputes the transformed bounding box used for ray testing
ChangeShape :: (model: *Model, bbox: *BoundingBox, currentShape: *ShapeType, newShape: ShapeType, canvasTexture: Texture2D)
{
    UnloadModel((.*)model);

    mesh: Mesh;

    if newShape ==
    {
        case .SHAPE_SPHERE;   mesh = GenMeshSphere(1.5, 32, 32);
        case .SHAPE_CUBE;     mesh = GenMeshCube(2.2, 2.2, 2.2);
        case .SHAPE_CYLINDER; mesh = GenMeshCylinder(1.2, 2.5, 24);
        case .SHAPE_TORUS;    mesh = GenMeshTorus(0.6, 1.6, 24, 36);
        case;                 mesh = GenMeshSphere(1.5, 32, 32);
    }

    (.*)model = LoadModelFromMesh(mesh);

    // GenMeshCylinder builds upward from y = 0; shift it down to center on the origin
    if (newShape == .SHAPE_CYLINDER) model.transform = MatrixTranslate(0.0, -1.25, 0.0);

    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = canvasTexture;

    box: BoundingBox = GetMeshBoundingBox(model.meshes[0]);
    box.min = Vector3Transform(box.min, model.transform);
    box.max = Vector3Transform(box.max, model.transform);
    (.*)bbox = box;

    (.*)currentShape = newShape;
}

// Raycasts against the model's mesh triangles and returns the UV coordinate of the
// closest hit, interpolated from the hit triangle's vertices with barycentric weights
GetMeshHitUV :: (ray: Ray, model: Model, bbox: BoundingBox, outUV: *Vector2) -> bool
{
    if (!GetRayCollisionBox(ray, bbox).hit) return false; // Fast reject

    mesh: Mesh = model.meshes[0];
    closestDistance: float = 1.0e9;
    found: bool = false;
    hitUV: Vector2;

    for tri: 0..mesh.triangleCount-1
    {
        i0: s32; i1: s32; i2: s32;

        if (mesh.indices != null)
        {
            i0 = mesh.indices[3*tri + 0];
            i1 = mesh.indices[3*tri + 1];
            i2 = mesh.indices[3*tri + 2];
        }
        else { i0 = 3*tri; i1 = 3*tri + 1; i2 = 3*tri + 2; }

        a: Vector3 = Vector3Transform(Vector3.{ mesh.vertices[3*i0], mesh.vertices[3*i0 + 1], mesh.vertices[3*i0 + 2] }, model.transform);
        b: Vector3 = Vector3Transform(Vector3.{ mesh.vertices[3*i1], mesh.vertices[3*i1 + 1], mesh.vertices[3*i1 + 2] }, model.transform);
        c: Vector3 = Vector3Transform(Vector3.{ mesh.vertices[3*i2], mesh.vertices[3*i2 + 1], mesh.vertices[3*i2 + 2] }, model.transform);

        hit: RayCollision = GetRayCollisionTriangle(ray, a, b, c);

        if (hit.hit && (hit.distance < closestDistance))
        {
            closestDistance = hit.distance;
            found = true;

            uvA: Vector2 = .{ mesh.texcoords[2*i0], mesh.texcoords[2*i0 + 1] };
            uvB: Vector2 = .{ mesh.texcoords[2*i1], mesh.texcoords[2*i1 + 1] };
            uvC: Vector2 = .{ mesh.texcoords[2*i2], mesh.texcoords[2*i2 + 1] };

            w: Vector3 = Vector3Barycenter(hit.point, a, b, c);

            hitUV.x = w.x*uvA.x + w.y*uvB.x + w.z*uvC.x;
            hitUV.y = w.x*uvA.y + w.y*uvB.y + w.z*uvC.y;

            // Wrap into [0, 1] in case of minor floating point drift at UV seams
            hitUV.x -= floor(hitUV.x);
            hitUV.y -= floor(hitUV.y);
        }
    }

    if (found && (outUV != null)) (.*)outUV = hitUV;

    return found;
}
