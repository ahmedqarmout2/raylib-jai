#import "raylib";
#import "Basic";
#import "Math";

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
Circle :: struct {
    center: Vector2;
    radius: float;
};

Triangle :: struct {
    v1: Vector2;
    v2: Vector2;
    v3: Vector2;
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - drag puzzle");

    // Rectangle
    rec: Rectangle = .{ screenWidth/2.0 - 250, screenHeight/2.0 + 50, 100.0, 100.0 };
    recArea: Rectangle = .{ screenWidth/2.0 - 60, screenHeight/2.0 - 110, 110.0, 110.0 };
    recPickedUp: bool = false;

    // Circle
    circ: Circle = .{ .{ screenWidth/2.0, screenHeight/2.0 + 100 }, 50.0 };
    circArea: Circle = .{ .{ screenWidth/2.0 - 195, screenHeight/2.0 - 55 }, 55.0 };
    circPickedUp: bool = false;

    // Triangle
    tri: Triangle = .{ .{ 600, 282 }, .{ 550, 369 }, .{ 650, 369 } };
    triArea: Triangle = .{ .{ 600, 115 }, .{ 540, 222 }, .{ 660, 222 } };
    triPickedUp: bool = false;

    mouseOffset: Vector2 = .{ 0.0, 0.0 };    // Stores the offset of the mouse relative to the object's pivot point

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mousePosition: Vector2 = GetMousePosition();
        recPlaced: bool = false;
        circPlaced: bool = false;
        triPlaced: bool = false;

        // Detect object pickup input
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && CheckCollisionPointRec(mousePosition, rec))
        {
            recPickedUp = true;
            mouseOffset = Vector2.{ rec.x - mousePosition.x, rec.y - mousePosition.y };
        }
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && CheckCollisionPointCircle(mousePosition, circ.center, circ.radius))
        {
            circPickedUp = true;
            mouseOffset = Vector2.{ circ.center.x - mousePosition.x, circ.center.y - mousePosition.y };
        }
        else if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT) && CheckCollisionPointTriangle(mousePosition, tri.v1, tri.v2, tri.v3))
        {
            triPickedUp = true;
            mouseOffset = Vector2.{ tri.v1.x - mousePosition.x, tri.v1.y - mousePosition.y }; // Uses v1 as the pivot point
        }

        // Detect object drop input
        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT) && recPickedUp) recPickedUp = false;
        else if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT) && circPickedUp) circPickedUp = false;
        else if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT) && triPickedUp) triPickedUp = false;

        // Rectangle update
        if (recPickedUp)
        {
            rec.x = mousePosition.x + mouseOffset.x;
            rec.y = mousePosition.y + mouseOffset.y;
        }
        RecCol: Rectangle = GetCollisionRec(recArea, rec);
        if (RecCol.width == rec.width && RecCol.height == rec.height) recPlaced = true;

        // Circle update
        if (circPickedUp)
        {
            circ.center.x = mousePosition.x + mouseOffset.x;
            circ.center.y = mousePosition.y + mouseOffset.y;
        }
        if (Vector2Distance(circ.center, circArea.center) < circArea.radius - circ.radius) circPlaced = true;

        // Triangle update
        if (triPickedUp)
        {
            v2Offset: Vector2 = .{ tri.v2.x - tri.v1.x, tri.v2.y - tri.v1.y };
            v3Offset: Vector2 = .{ tri.v3.x - tri.v1.x, tri.v3.y - tri.v1.y };

            tri.v1 = Vector2.{ mousePosition.x + mouseOffset.x, mousePosition.y + mouseOffset.y };
            tri.v2 = Vector2.{ tri.v1.x + v2Offset.x, tri.v1.y + v2Offset.y };
            tri.v3 = Vector2.{ tri.v1.x + v3Offset.x, tri.v1.y + v3Offset.y };
        }
        if (
            CheckCollisionPointTriangle(tri.v1, triArea.v1, triArea.v2, triArea.v3) &&
            CheckCollisionPointTriangle(tri.v2, triArea.v1, triArea.v2, triArea.v3) &&
            CheckCollisionPointTriangle(tri.v2, triArea.v1, triArea.v2, triArea.v3)
        ) triPlaced = true;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            DrawRectangleLinesEx(recArea, 2.0, ifx recPlaced then GREEN else RED);
            DrawCircleLinesEx(circArea.center, circArea.radius, 2.0, ifx circPlaced then GREEN else RED);
            DrawTriangleLinesEx(triArea.v1, triArea.v2, triArea.v3, 2.0, ifx triPlaced then GREEN else RED);

            // Draws objects that are not picked up first
            if (!triPickedUp) DrawTriangle(tri.v1, tri.v2, tri.v3, VIOLET);
            if (!circPickedUp) DrawCircleV(circ.center, circ.radius, BLUE);
            if (!recPickedUp) DrawRectangleRec(rec, ORANGE);

            // Draws the object that is being dragged on top of others
            if (triPickedUp) DrawTriangle(tri.v1, tri.v2, tri.v3, VIOLET);
            if (circPickedUp) DrawCircleV(circ.center, circ.radius, BLUE);
            if (recPickedUp) DrawRectangleRec(rec, ORANGE);

            DrawText("Use mouse to drag and drop the objects into the right spot!", 10, 10, 20, GRAY);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
