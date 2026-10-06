#import "raylib";
#import "Basic";
#import "Math";

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
Branch :: struct {
    start: Vector2;
    end: Vector2;
    angle: float;
    length: float;
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

    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - recursive tree");

    start: Vector2 = .{ (screenWidth/2.0) - 125.0, cast(float)screenHeight };
    angle: float = 40.0;
    thick: float = 1.0;
    treeDepth: float = 10.0;
    branchDecay: float = 0.66;
    length: float = 120.0;
    bezier: bool = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        theta: float = angle*DEG2RAD;
        maxBranches: s32 = cast(s32)(pow(2, floor(treeDepth)));
        branches: [1030]Branch;
        count: s32 = 0;

        initialEnd: Vector2 = .{ start.x + length*sin(0.0), start.y - length*cos(0.0) };
        branches[count] = Branch.{start, initialEnd, 0.0, length};
        count += 1;

        i := 0;
        while (i < count)
        {
            defer i+= 1;

            branch: Branch = branches[i];
            if (branch.length < 2) continue;

            nextLength: float = branch.length*branchDecay;

            if (count < maxBranches && nextLength >= 2)
            {
                branchStart: Vector2 = branch.end;

                angle1: float = branch.angle + theta;
                branchEnd1: Vector2 = .{ branchStart.x + nextLength*sin(angle1), branchStart.y - nextLength*cos(angle1) };
                branches[count] = Branch.{branchStart, branchEnd1, angle1, nextLength};
                count += 1;

                angle2: float = branch.angle - theta;
                branchEnd2: Vector2 = .{ branchStart.x + nextLength*sin(angle2), branchStart.y - nextLength*cos(angle2) };
                branches[count] = Branch.{branchStart, branchEnd2, angle2, nextLength};
                count += 1;
            }
        }
        //----------------------------------------------------------------------------------
        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            for i: 0..count-1
            {
                branch: Branch = branches[i];
                if (branch.length >= 2)
                {
                    if (bezier) DrawLineBezier(branch.start, branch.end, thick, RED);
                    else DrawLineEx(branch.start, branch.end, thick, RED);
                }
            }

            DrawLine(580, 0, 580, GetScreenHeight(), Color.{ 218, 218, 218, 255 });
            DrawRectangle(580, 0, GetScreenWidth(), GetScreenHeight(), Color.{ 232, 232, 232, 255 });

            // Draw GUI controls
            //------------------------------------------------------------------------------
            GuiSliderBar(Rectangle.{ 640, 40, 120, 20}, "Angle", TextFormat("%.0f", angle), *angle, 0, 180);
            GuiSliderBar(Rectangle.{ 640, 70, 120, 20 }, "Length", TextFormat("%.0f", length), *length, 12.0, 240.0);
            GuiSliderBar(Rectangle.{ 640, 100, 120, 20}, "Decay", TextFormat("%.2f", branchDecay), *branchDecay, 0.1, 0.78);
            GuiSliderBar(Rectangle.{ 640, 130, 120, 20 }, "Depth", TextFormat("%.0f", treeDepth), *treeDepth, 1.0, 10.0);
            GuiSliderBar(Rectangle.{ 640, 160, 120, 20}, "Thick", TextFormat("%.0f", thick), *thick, 1, 8);
            GuiCheckBox(Rectangle.{ 640, 190, 20, 20 }, "Bezier", *bezier);
            //------------------------------------------------------------------------------

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}