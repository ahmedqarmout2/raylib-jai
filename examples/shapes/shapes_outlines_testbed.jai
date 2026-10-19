#import "raylib";
#import "Basic";
#import "Math";

COLOR_FILLED ::  DARKBLUE;
COLOR_OUTLINE :: YELLOW;

SHAPE_SPACING :: 14.0;
SHAPE_SIZE :: 46.0;
BOX_SPACING :: 10.0;

MOUSE_CAMERA_ZOOM_SPEED :: 0.3;
KEYBOARD_CAMERA_MOVE_SPEED :: 10.0;
KEYBOARD_CAMERA_ZOOM_SPEED :: 0.1;

CAMERA_ZOOM_MIN :: 0.1;
CAMERA_ZOOM_MAX :: 1000.0;

// The shapes are ordered according to their order in this enum, left to right
Shapes :: enum s32 {
    ORDER_RECTANGLE :: 0;
    ORDER_RECTANGLE_ROUNDED;
    ORDER_CIRCLE;
    ORDER_ELLIPSE;
    ORDER_CIRCLE_SECTOR;
    ORDER_RING;
    ORDER_TRIANGLE;
    ORDER_POLYGON;
    COUNT_SHAPES;
};

// The line style groups are ordered according to their order in this enum, top to bottom
Style :: enum s32 {
    ORDER_LINES :: 0;
    ORDER_LINES_EX_WORLD;
    ORDER_LINES_EX_SCREEN;
};

BOX_WIDTH :: SHAPE_SIZE*Shapes.COUNT_SHAPES + SHAPE_SPACING*(Shapes.COUNT_SHAPES - 1) + BOX_SPACING*2.0;
BOX_HEIGHT :: SHAPE_SIZE + BOX_SPACING*2.0;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - outlines testbed");

    camera: Camera2D;
    camera.zoom = 1;

    // User configurable options while running the program.
    lineOpacity: float          = 130;
    lineThickness: float        = 4.0;
    rectangleRoundness: float   = 0.4;
    rectangleSegments: float    = 9;
    ellipseRadiusY: float       = 0.5;
    circleStartAngle: float     = 20.0;
    circleEndAngle: float       = 270.0;
    circleSegments: float       = 36;
    ringInnerRadiusScale: float = 0.3;
    polygonSides: float         = 6;

    disableMouseControl: bool = false;

    optionsBackground: Rectangle = .{ 510, 0, 290, 450 };

    zoomPoint: Vector2 = .{(cast(float)screenWidth - optionsBackground.width)/2.0, cast(float)screenHeight/2.0};

    GuiSetStyle(.LABEL, cast(s32)GuiControlProperty.TEXT_COLOR_NORMAL, ColorToInt(WHITE));

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePosScreen: Vector2 = GetMousePosition();
        mouseWheelVec: Vector2 = GetMouseWheelMoveV();

        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && CheckCollisionPointRec(mousePosScreen, optionsBackground)) disableMouseControl = true;

        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT)) disableMouseControl = false;

        if (!disableMouseControl) {
            if (mouseWheelVec.y != 0.0) {
                prevWorldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);

                camera.zoom *= exp(MOUSE_CAMERA_ZOOM_SPEED*mouseWheelVec.y); // Constant zoom rate
                camera.zoom = Clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

                worldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);
                camera.target = Vector2Add(camera.target, Vector2Subtract(prevWorldZoomPoint, worldZoomPoint));
            }

            if (IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
                mouseDelta: Vector2 = GetMouseDelta();
                camera.target.x -= mouseDelta.x/camera.zoom;
                camera.target.y -= mouseDelta.y/camera.zoom;

                mouseMaxX: s32 = cast(s32)optionsBackground.x;
                mouseMaxY: s32 = screenHeight;

                newX: s32 = cast(s32)mousePosScreen.x;
                newY: s32 = cast(s32)mousePosScreen.y;

                // In C, the '%' operator computes the remainder, we want the modulus
                newX = (newX%mouseMaxX + mouseMaxX)%mouseMaxX;
                newY = (newY%mouseMaxY + mouseMaxY)%mouseMaxY;

                if ((newX != cast(s32)mousePosScreen.x) || (newY != cast(s32)mousePosScreen.y)) SetMousePosition(newX, newY);
            }
        }

        if (IsKeyDown(.KEY_A)) camera.target.x -= KEYBOARD_CAMERA_MOVE_SPEED/camera.zoom;
        if (IsKeyDown(.KEY_D)) camera.target.x += KEYBOARD_CAMERA_MOVE_SPEED/camera.zoom;
        if (IsKeyDown(.KEY_W)) camera.target.y -= KEYBOARD_CAMERA_MOVE_SPEED/camera.zoom;
        if (IsKeyDown(.KEY_S)) camera.target.y += KEYBOARD_CAMERA_MOVE_SPEED/camera.zoom;

        if (IsKeyDown(.KEY_UP))
        {
            prevWorldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);

            camera.zoom *= exp(KEYBOARD_CAMERA_ZOOM_SPEED);
            camera.zoom = Clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

            worldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);
            camera.target = Vector2Add(camera.target, Vector2Subtract(prevWorldZoomPoint, worldZoomPoint));
        }
        if (IsKeyDown(.KEY_DOWN))
        {
            prevWorldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);

            camera.zoom *= exp(-KEYBOARD_CAMERA_ZOOM_SPEED);
            camera.zoom = Clamp(camera.zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX);

            worldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);
            camera.target = Vector2Add(camera.target, Vector2Subtract(prevWorldZoomPoint, worldZoomPoint));
        }

        if (IsKeyPressed(.KEY_Z))
        {
            zoomPoint: Vector2 = .{(cast(float)screenWidth - optionsBackground.width)/2.0, cast(float)screenHeight/2.0};
            prevWorldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);

            camera.zoom = 1.0;

            worldZoomPoint: Vector2 = GetScreenToWorld2D(zoomPoint, camera);
            camera.target = Vector2Add(camera.target, Vector2Subtract(prevWorldZoomPoint, worldZoomPoint));
        }

        if (IsKeyPressed(.KEY_C)) camera.target = Vector2.{};
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Color.{ 50, 50, 55, 255 });

            colorOutline: Color = COLOR_OUTLINE;
            colorOutline.a = cast(u8)lineOpacity;

            BeginMode2D(camera);

            shapeOffset: float = BOX_SPACING*2.0;
            shapePaddingX: float = SHAPE_SIZE + SHAPE_SPACING;
            shapePaddingY: float = SHAPE_SIZE + SHAPE_SPACING + BOX_SPACING*2.0;

            radiusX: float = SHAPE_SIZE/2.0;
            radiusY: float = radiusX*ellipseRadiusY;

            ringOuterRadius: float = SHAPE_SIZE/2.0;
            ringInnerRadius: float = ringOuterRadius*ringInnerRadiusScale;

            triangleVertex0Offset: Vector2 = .{ 0.0, SHAPE_SIZE*0.8 };
            triangleVertex1Offset: Vector2 = .{ SHAPE_SIZE*0.6, SHAPE_SIZE };
            triangleVertex2Offset: Vector2 = .{ SHAPE_SIZE, 0.0 };

            // ----------------------------------------
            // Draw*Lines()
            posY: float = shapeOffset + shapePaddingY*Style.ORDER_LINES;

            // Rectangle
            posX: float = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE;
            DrawRectangleRec(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, COLOR_FILLED);
            DrawRectangleLines(cast(s32)posX, cast(s32)posY, cast(s32)SHAPE_SIZE, cast(s32)SHAPE_SIZE, colorOutline);

            // Rectangle Rounded
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE_ROUNDED;
            DrawRectangleRounded(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, COLOR_FILLED);
            DrawRectangleRoundedLines(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, colorOutline);

            // Circle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE;
            DrawCircleV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, COLOR_FILLED);
            DrawCircleLinesV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, colorOutline);

            // Ellipse
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_ELLIPSE;
            DrawEllipseV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, COLOR_FILLED);
            DrawEllipseLinesV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, colorOutline);

            // Circle Sector
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE_SECTOR;
            DrawCircleSector(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawCircleSectorLines(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, colorOutline);

            // Ring
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RING;
            DrawRing(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawRingLines(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, colorOutline);

            // Triangle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_TRIANGLE;
            DrawTriangle(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                         Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                         Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                         COLOR_FILLED);
            DrawTriangleLines(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                              Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                              Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                              colorOutline);

            // Polygon
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_POLYGON;
            DrawPoly(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, COLOR_FILLED);
            DrawPolyLines(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, colorOutline);

            // Group the shapes
            GuiGroupBox(Rectangle.{ shapeOffset - BOX_SPACING, posY - BOX_SPACING, BOX_WIDTH, BOX_HEIGHT }, "Draw*Lines()");
            // ----------------------------------------

            // ----------------------------------------
            // Draw*LinesEx() with world space pixel thickness
            posY = shapeOffset + shapePaddingY*Style.ORDER_LINES_EX_WORLD;

            // Rectangle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE;
            DrawRectangleRec(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, COLOR_FILLED);
            DrawRectangleLinesEx(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, lineThickness, colorOutline);

            // Rectangle Rounded
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE_ROUNDED;
            DrawRectangleRounded(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, COLOR_FILLED);
            DrawRectangleRoundedLinesEx(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, lineThickness, colorOutline);

            // Circle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE;
            DrawCircleV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, COLOR_FILLED);
            DrawCircleLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, lineThickness, colorOutline);

            // Ellipse
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_ELLIPSE;
            DrawEllipseV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, COLOR_FILLED);
            DrawEllipseLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, lineThickness, colorOutline);

            // Circle Sector
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE_SECTOR;
            DrawCircleSector(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawCircleSectorLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, lineThickness, colorOutline);

            // Ring
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RING;
            DrawRing(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawRingLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, lineThickness, colorOutline);

            // Triangle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_TRIANGLE;
            DrawTriangle(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                         Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                         Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                         COLOR_FILLED);
            DrawTriangleLinesEx(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                                Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                                Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                                lineThickness, colorOutline);

            // Polygon
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_POLYGON;
            DrawPoly(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, COLOR_FILLED);
            DrawPolyLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, lineThickness, colorOutline);

            // Group the shapes
            GuiGroupBox(Rectangle.{ shapeOffset - BOX_SPACING, posY - BOX_SPACING, BOX_WIDTH, BOX_HEIGHT }, "Draw*LinesEx() with *world space* pixel thickness");
            // ----------------------------------------

            // ----------------------------------------
            // Draw*LinesEx() with screen space pixel thickness
            posY = shapeOffset + shapePaddingY*Style.ORDER_LINES_EX_SCREEN;

            constantThickness: float = lineThickness/camera.zoom;

            // Rectangle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE;
            DrawRectangleRec(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, COLOR_FILLED);
            DrawRectangleLinesEx(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, constantThickness, colorOutline);

            // Rectangle Rounded
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RECTANGLE_ROUNDED;
            DrawRectangleRounded(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, COLOR_FILLED);
            DrawRectangleRoundedLinesEx(Rectangle.{ posX, posY, SHAPE_SIZE, SHAPE_SIZE }, rectangleRoundness, cast(s32)rectangleSegments, constantThickness, colorOutline);

            // Circle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE;
            DrawCircleV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, COLOR_FILLED);
            DrawCircleLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, constantThickness, colorOutline);

            // Ellipse
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_ELLIPSE;
            DrawEllipseV(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, COLOR_FILLED);
            DrawEllipseLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, radiusY, constantThickness, colorOutline);

            // Circle Sector
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_CIRCLE_SECTOR;
            DrawCircleSector(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawCircleSectorLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, radiusX, circleStartAngle, circleEndAngle, cast(s32)circleSegments, constantThickness, colorOutline);

            // Ring
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_RING;
            DrawRing(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, COLOR_FILLED);
            DrawRingLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, ringInnerRadius, ringOuterRadius, circleStartAngle, circleEndAngle, cast(s32)circleSegments, constantThickness, colorOutline);

            // Triangle
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_TRIANGLE;
            DrawTriangle(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                         Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                         Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                         COLOR_FILLED);
            DrawTriangleLinesEx(Vector2.{ posX + triangleVertex0Offset.x, posY + triangleVertex0Offset.y },
                                Vector2.{ posX + triangleVertex1Offset.x, posY + triangleVertex1Offset.y },
                                Vector2.{ posX + triangleVertex2Offset.x, posY + triangleVertex2Offset.y },
                                constantThickness, colorOutline);

            // Polygon
            posX = shapeOffset + shapePaddingX*Shapes.ORDER_POLYGON;
            DrawPoly(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, COLOR_FILLED);
            DrawPolyLinesEx(Vector2.{ posX + SHAPE_SIZE/2.0, posY + SHAPE_SIZE/2.0 }, cast(s32)polygonSides, radiusX, 0.0, constantThickness, colorOutline);

            // Group the shapes
            GuiGroupBox(Rectangle.{ shapeOffset - BOX_SPACING, posY - BOX_SPACING, BOX_WIDTH, BOX_HEIGHT }, "Draw*LinesEx() with *screen space* pixel thickness");
            // ----------------------------------------

            EndMode2D();

            DrawRectangleRec(optionsBackground, Fade(DARKGRAY, 0.75));

            DrawRectangleRec(Rectangle.{ optionsBackground.x, 360, optionsBackground.width, 90 }, Fade(BLACK, 0.4));
            DrawLineEx(Vector2.{ optionsBackground.x, 360 }, Vector2.{ optionsBackground.x + optionsBackground.width, 360 }, 1.0, BLACK);

            DrawText("Move with the mouse or WASD keys", cast(s32)optionsBackground.x + 10, 370, 10, ORANGE);
            DrawText("Zoom with the mouse or UP and DOWN keys", cast(s32)optionsBackground.x + 10, 390, 10, ORANGE);
            DrawText("Press C to reset position", cast(s32)optionsBackground.x + 10, 410, 10, ORANGE);
            DrawText("Press Z to reset zoom", cast(s32)optionsBackground.x + 10, 430, 10, ORANGE);

            DrawLineEx(Vector2.{ optionsBackground.x, optionsBackground.y }, Vector2.{ optionsBackground.x, optionsBackground.y + optionsBackground.height }, 1.0, BLACK);

            GuiSliderBar(Rectangle.{ 605,  10, 150, 25 }, "Line Opacity"    , TextFormat("%d"  , cast(s32)lineOpacity)      , *lineOpacity         ,  0     , 255);
            GuiSliderBar(Rectangle.{ 605,  45, 150, 25 }, "Thickness"       , TextFormat("%.2f", lineThickness)         , *lineThickness       , -20.0 , 40.0);
            GuiSliderBar(Rectangle.{ 605,  80, 150, 25 }, "Rect Roundness"  , TextFormat("%.2f", rectangleRoundness)    , *rectangleRoundness  , -1.0  , 2.0);
            GuiSliderBar(Rectangle.{ 605, 115, 150, 25 }, "Rect Segments"   , TextFormat("%d"  , cast(s32)rectangleSegments), *rectangleSegments   , -1     , 100);
            GuiSliderBar(Rectangle.{ 605, 150, 150, 25 }, "Ellipse Radius Y", TextFormat("%.2f", ellipseRadiusY)        , *ellipseRadiusY      , 0.0   , 1.25);
            GuiSliderBar(Rectangle.{ 605, 185, 150, 25 }, "Start Angle"     , TextFormat("%.2f", circleStartAngle)      , *circleStartAngle    , -360.0, 360.0);
            GuiSliderBar(Rectangle.{ 605, 220, 150, 25 }, "End Angle"       , TextFormat("%.2f", circleEndAngle)        , *circleEndAngle      , -360.0, 360.0);
            GuiSliderBar(Rectangle.{ 605, 255, 150, 25 }, "Circle Segments" , TextFormat("%d"  , cast(s32)circleSegments)   , *circleSegments      , -1     , 100);
            GuiSliderBar(Rectangle.{ 605, 290, 150, 25 }, "Ring Radius"     , TextFormat("%.2f", ringInnerRadiusScale)  , *ringInnerRadiusScale, -1.0  , 2.0);
            GuiSliderBar(Rectangle.{ 605, 325, 150, 25 }, "Poly Sides"      , TextFormat("%d"  , cast(s32)polygonSides)     , *polygonSides        , -1     , 100);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
