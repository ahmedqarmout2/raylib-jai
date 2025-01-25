#import "raylib";
#import "Basic";
#import "Math";

// Custom Blend Modes
RLGL_SRC_ALPHA :: 0x0302;
RLGL_MIN       :: 0x8007;
RLGL_MAX       :: 0x8008;

MAX_BOXES   :: 20;
MAX_SHADOWS :: MAX_BOXES*3;         // MAX_BOXES *3. Each box can cast up to two shadow volumes for the edges it is away from, and one for the box itself
MAX_LIGHTS  :: 16;

// Shadow geometry type
ShadowGeometry :: struct {
    vertices: [4]Vector2;
};

// Light info type
LightInfo :: struct {
    active : bool;                // Is this light slot active?
    dirty  : bool;                 // Does this light need to be updated?
    valid  : bool;                 // Is this light in a valid position?

    position: Vector2;           // Light position
    mask: RenderTexture;         // Alpha mask for the light
    outerRadius: float;          // The distance the light touches
    bounds: Rectangle;           // A cached rectangle of the light bounds to help with culling

    shadows: [MAX_SHADOWS]ShadowGeometry;
    shadowCount: s32;
};

lights: [MAX_LIGHTS]LightInfo;

// Move a light and mark it as dirty so that we update it's mask next frame
MoveLight :: (slot: s32, x: float, y: float)
{
    lights[slot].dirty = true;
    lights[slot].position.x = x; 
    lights[slot].position.y = y;

    // update the cached bounds
    lights[slot].bounds.x = x - lights[slot].outerRadius;
    lights[slot].bounds.y = y - lights[slot].outerRadius;
}

// Compute a shadow volume for the edge
// It takes the edge and projects it back by the light radius and turns it into a quad
ComputeShadowVolumeForEdge :: (slot: s32, sp: Vector2, ep: Vector2)
{
    if (lights[slot].shadowCount >= MAX_SHADOWS) return;

    extension: float = lights[slot].outerRadius*2;

    spVector: Vector2 = Vector2Normalize(Vector2Subtract(sp, lights[slot].position));
    spProjection: Vector2 = Vector2Add(sp, Vector2Scale(spVector, extension));

    epVector: Vector2 = Vector2Normalize(Vector2Subtract(ep, lights[slot].position));
    epProjection: Vector2 = Vector2Add(ep, Vector2Scale(epVector, extension));

    lights[slot].shadows[lights[slot].shadowCount].vertices[0] = sp;
    lights[slot].shadows[lights[slot].shadowCount].vertices[1] = ep;
    lights[slot].shadows[lights[slot].shadowCount].vertices[2] = epProjection;
    lights[slot].shadows[lights[slot].shadowCount].vertices[3] = spProjection;

    lights[slot].shadowCount += 1;
}

// Draw the light and shadows to the mask for a light
DrawLightMask :: (slot: s32)
{
    // Use the light mask
    BeginTextureMode(lights[slot].mask);

        ClearBackground(WHITE);

        // Force the blend mode to only set the alpha of the destination
        rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN);
        rlSetBlendMode(.BLEND_CUSTOM);

        // If we are valid, then draw the light radius to the alpha mask
        if (lights[slot].valid) DrawCircleGradient(cast(s32)lights[slot].position.x, cast(s32)lights[slot].position.y, lights[slot].outerRadius, ColorAlpha(WHITE, 0), WHITE);
        
        rlDrawRenderBatchActive();

        // Cut out the shadows from the light radius by forcing the alpha to maximum
        rlSetBlendMode(.BLEND_ALPHA);
        rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MAX);
        rlSetBlendMode(.BLEND_CUSTOM);

        // Draw the shadows to the alpha mask
        for i: 0..lights[slot].shadowCount-1
        {
            DrawTriangleFan(lights[slot].shadows[i].vertices.data, 4, WHITE);
        }

        rlDrawRenderBatchActive();
        
        // Go back to normal blend mode
        rlSetBlendMode(.BLEND_ALPHA);

    EndTextureMode();
}

// Setup a light
SetupLight :: (slot: s32, x: float, y: float, radius: float)
{
    lights[slot].active = true;
    lights[slot].valid = false;  // The light must prove it is valid
    lights[slot].mask = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());
    lights[slot].outerRadius = radius;

    lights[slot].bounds.width = radius * 2;
    lights[slot].bounds.height = radius * 2;

    MoveLight(slot, x, y);

    // Force the render texture to have something in it
    DrawLightMask(slot);
}

// See if a light needs to update it's mask
UpdateLight :: (slot: s32, boxes: *Rectangle, count: s32) -> bool
{
    if (!lights[slot].active || !lights[slot].dirty) return false;

    lights[slot].dirty = false;
    lights[slot].shadowCount = 0;
    lights[slot].valid = false;

    for i: 0..count-1
    {
        // Are we in a box? if so we are not valid
        if (CheckCollisionPointRec(lights[slot].position, boxes[i])) return false;

        // If this box is outside our bounds, we can skip it
        if (!CheckCollisionRecs(lights[slot].bounds, boxes[i])) continue;

        // Check the edges that are on the same side we are, and cast shadow volumes out from them
        
        // Top
        sp: Vector2 = Vector2.{ boxes[i].x, boxes[i].y };
        ep: Vector2  = Vector2.{ boxes[i].x + boxes[i].width, boxes[i].y };

        if (lights[slot].position.y > ep.y) ComputeShadowVolumeForEdge(slot, sp, ep);

        // Right
        sp = ep;
        ep.y += boxes[i].height;
        if (lights[slot].position.x < ep.x) ComputeShadowVolumeForEdge(slot, sp, ep);

        // Bottom
        sp = ep;
        ep.x -= boxes[i].width;
        if (lights[slot].position.y < ep.y) ComputeShadowVolumeForEdge(slot, sp, ep);

        // Left
        sp = ep;
        ep.y -= boxes[i].height;
        if (lights[slot].position.x > ep.x) ComputeShadowVolumeForEdge(slot, sp, ep);

        // The box itself
        lights[slot].shadows[lights[slot].shadowCount].vertices[0] = Vector2.{ boxes[i].x, boxes[i].y };
        lights[slot].shadows[lights[slot].shadowCount].vertices[1] = Vector2.{ boxes[i].x, boxes[i].y + boxes[i].height };
        lights[slot].shadows[lights[slot].shadowCount].vertices[2] = Vector2.{ boxes[i].x + boxes[i].width, boxes[i].y + boxes[i].height };
        lights[slot].shadows[lights[slot].shadowCount].vertices[3] = Vector2.{ boxes[i].x + boxes[i].width, boxes[i].y };
        lights[slot].shadowCount += 1;
    }

    lights[slot].valid = true;

    DrawLightMask(slot);

    return true;
}

// Set up some boxes
SetupBoxes :: (boxes: *Rectangle, count: *s32)
{
    boxes[0] = Rectangle.{ 150,80, 40, 40 };
    boxes[1] = Rectangle.{ 1200, 700, 40, 40 };
    boxes[2] = Rectangle.{ 200, 600, 40, 40 };
    boxes[3] = Rectangle.{ 1000, 50, 40, 40 };
    boxes[4] = Rectangle.{ 500, 350, 40, 40 };

    for i: 5..MAX_BOXES-1
    {
        boxes[i] = Rectangle.{cast(float)GetRandomValue(0,GetScreenWidth()), cast(float)GetRandomValue(0,GetScreenHeight()), cast(float)GetRandomValue(10,100), cast(float)GetRandomValue(10,100) };
    }

    <<count = MAX_BOXES;
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;
    
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - top down lights");

    // Initialize our 'world' of boxes
    boxCount: s32 = 0;
    boxes: [MAX_BOXES]Rectangle;
    SetupBoxes(boxes.data, *boxCount);

    // Create a checkerboard ground texture
    img: Image = GenImageChecked(64, 64, 32, 32, DARKBROWN, DARKGRAY);
    backgroundTexture: Texture2D = LoadTextureFromImage(img);
    UnloadImage(img);

    // Create a global light mask to hold all the blended lights
    lightMask: RenderTexture = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

    // Setup initial light
    SetupLight(0, 600, 400, 300);
    nextLight: s32 = 1;

    showLines: bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Drag light 0
        if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) MoveLight(0, GetMousePosition().x, GetMousePosition().y);

        // Make a new light
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT) && (nextLight < MAX_LIGHTS))
        {
            SetupLight(nextLight, GetMousePosition().x, GetMousePosition().y, 200);
            nextLight += 1;
        }

        // Toggle debug info
        if (IsKeyPressed(.KEY_F1)) showLines = !showLines;

        // Update the lights and keep track if any were dirty so we know if we need to update the master light mask
        dirtyLights: bool = false;
        for i: 0..MAX_LIGHTS-1
        {
            if (UpdateLight(cast(s32)i, boxes.data, boxCount)) dirtyLights = true;
        }

        // Update the light mask
        if (dirtyLights)
        {
            // Build up the light mask
            BeginTextureMode(lightMask);
            
                ClearBackground(BLACK);

                // Force the blend mode to only set the alpha of the destination
                rlSetBlendFactors(RLGL_SRC_ALPHA, RLGL_SRC_ALPHA, RLGL_MIN);
                rlSetBlendMode(.BLEND_CUSTOM);

                // Merge in all the light masks
                for i: 0..MAX_LIGHTS-1
                {
                    if (lights[i].active) DrawTextureRec(lights[i].mask.texture, Rectangle.{ 0, 0, cast(float)GetScreenWidth(), -cast(float)GetScreenHeight() }, Vector2Zero(), WHITE);
                }

                rlDrawRenderBatchActive();

                // Go back to normal blend
                rlSetBlendMode(.BLEND_ALPHA);
            EndTextureMode();
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(BLACK);
            
            // Draw the tile background
            DrawTextureRec(backgroundTexture, Rectangle.{ 0, 0, cast(float)GetScreenWidth(), cast(float)GetScreenHeight() }, Vector2Zero(), WHITE);
            
            // Overlay the shadows from all the lights
            DrawTextureRec(lightMask.texture, Rectangle.{ 0, 0, cast(float)GetScreenWidth(), -cast(float)GetScreenHeight() }, Vector2Zero(), ColorAlpha(WHITE, ifx showLines then 0.75 else 1.0));

            // Draw the lights
            for i: 0..MAX_LIGHTS-1
            {
                if (lights[i].active) DrawCircle(cast(s32)lights[i].position.x, cast(s32)lights[i].position.y, 10, ifx (i == 0) then YELLOW else WHITE);
            }

            if (showLines)
            {
                for s: 0..lights[0].shadowCount-1
                {
                    DrawTriangleFan(lights[0].shadows[s].vertices.data, 4, DARKPURPLE);
                }

                for b: 0..boxCount-1
                {
                    if (CheckCollisionRecs(boxes[b],lights[0].bounds)) DrawRectangleRec(boxes[b], PURPLE);

                    DrawRectangleLines(cast(s32)boxes[b].x, cast(s32)boxes[b].y, cast(s32)boxes[b].width, cast(s32)boxes[b].height, DARKBLUE);
                }

                DrawText("(F1) Hide Shadow Volumes", 10, 50, 10, GREEN);
            }
            else
            {
                DrawText("(F1) Show Shadow Volumes", 10, 50, 10, GREEN);
            }

            DrawFPS(screenWidth - 80, 10);
            DrawText("Drag to move light #1", 10, 10, 10, DARKGREEN);
            DrawText("Right click to add new light", 10, 30, 10, DARKGREEN);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(backgroundTexture);
    UnloadRenderTexture(lightMask);
    for i: 0..MAX_LIGHTS-1
    {
        if (lights[i].active) UnloadRenderTexture(lights[i].mask);
    }

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
