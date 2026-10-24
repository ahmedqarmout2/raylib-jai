#import "raylib";
#import "Basic";
#import "Math";

STR_MAX_SIZE ::            10000;
TURTLE_STACK_MAX_SIZE ::      50;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
TurtleState :: struct {
    origin: Vector2;
    angle: float;
};

PenroseLSystem :: struct {
    steps: s32;
    production: *u8;
    ruleW: *u8;
    ruleX: *u8;
    ruleY: *u8;
    ruleZ: *u8;
    drawLength: float;
    theta: float;
};

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
turtleStack: [TURTLE_STACK_MAX_SIZE]TurtleState;
turtleTop: s32 = -1;

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
    InitWindow(screenWidth, screenHeight, "raylib [shapes] example - penrose tile");

    drawLength: float = 460.0;
    minGenerations: s32 = 0;
    maxGenerations: s32 = 4;
    generations: s32 = 0;

    // Initializee new penrose tile
    ls: PenroseLSystem = CreatePenroseLSystem(drawLength*(generations/cast(float)maxGenerations));
    for i: 0..generations-1 BuildProductionStep(*ls);

    SetTargetFPS(120);              // Set our game to run at 120 frames-per-second
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        rebuild: bool = false;
        if (IsKeyPressed(.KEY_UP))
        {
            if (generations < maxGenerations)
            {
                generations += 1;
                rebuild = true;
            }
        }
        else if (IsKeyPressed(.KEY_DOWN))
        {
            if (generations > minGenerations)
            {
                generations -= 1;
                if (generations > 0) rebuild = true;
            }
        }

        if (rebuild)
        {
            free(ls.production); // Free previous production for re-creation
            ls = CreatePenroseLSystem(drawLength*(generations/cast(float)maxGenerations));
            for i: 0..generations-1 BuildProductionStep(*ls);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground( RAYWHITE );

            if (generations > 0) DrawPenroseLSystem(*ls);

            DrawText("penrose l-system", 10, 10, 20, DARKGRAY);
            DrawText("press up or down to change generations", 10, 30, 20, DARKGRAY);
            DrawText(TextFormat("generations: %d", generations), 10, 50, 20, DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Push turtle state for next step
PushTurtleState :: (state: TurtleState)
{
    if (turtleTop < (TURTLE_STACK_MAX_SIZE - 1))
    {
        turtleTop += 1;
        turtleStack[turtleTop] = state;
    }
    else TraceLog(.LOG_WARNING, "TURTLE STACK OVERFLOW!");
}

// Pop turtle state step
PopTurtleState :: () -> TurtleState
{
    if (turtleTop >= 0)
    {
        defer turtleTop -= 1;
        return turtleStack[turtleTop];
    }
    else TraceLog(.LOG_WARNING, "TURTLE STACK UNDERFLOW!");

    return TurtleState.{};
}

// Create a new penrose tile structure
CreatePenroseLSystem :: (drawLength: float ) -> PenroseLSystem
{
    // TODO: Review constant values assignment on recreation?
    ls: PenroseLSystem = .{
        steps = 0,
        ruleW = "YF++ZF4-XF[-YF4-WF]++",
        ruleX = "+YF--ZF[3-WF--XF]+",
        ruleY = "-WF++XF[+++YF++ZF]-",
        ruleZ = "--YF++++WF[+ZF++++XF]--XF",
        drawLength = drawLength,
        theta = 36.0 // Degrees
    };

    ls.production = cast(*u8)alloc(size_of(u8)*STR_MAX_SIZE);
    ls.production[0] = #char "\0";
    strncpy(ls.production, "[X]++[X]++[X]++[X]++[X]", STR_MAX_SIZE);

    return ls;
}

// Build next penrose step
BuildProductionStep :: (ls: *PenroseLSystem)
{
    newProduction: *u8 = cast(*u8)alloc(size_of(u8)*STR_MAX_SIZE);
    newProduction[0] = #char "\0";

    productionLength: s32 = cast(s32)array_len(ls.production, STR_MAX_SIZE);

    for i: 0..productionLength-1
    {
        step: u8 = ls.production[i];
        remainingSpace: s32 = STR_MAX_SIZE - cast(s32)array_len(newProduction, STR_MAX_SIZE) - 1;
        if step ==
        {
            case #char "W"; strncat(newProduction, ls.ruleW, remainingSpace);
            case #char "X"; strncat(newProduction, ls.ruleX, remainingSpace);
            case #char "Y"; strncat(newProduction, ls.ruleY, remainingSpace);
            case #char "Z"; strncat(newProduction, ls.ruleZ, remainingSpace);
            case;
            {
                if (step != #char "F")
                {
                    t: s32 = cast(s32)array_len(newProduction, STR_MAX_SIZE);
                    newProduction[t] = step;
                    newProduction[t + 1] = #char "\0";
                }
            }
        }
    }

    ls.drawLength *= 0.5;
    strncpy(ls.production, newProduction, STR_MAX_SIZE);

    free(newProduction);
}

// Draw penrose tile lines
DrawPenroseLSystem :: (ls: *PenroseLSystem)
{
    screenCenter: Vector2 = .{ GetScreenWidth()/2.0, GetScreenHeight()/2.0 };

    turtle: TurtleState = .{
        origin = .{},
        angle = -90.0
    };

    repeats: s32 = 1;
    productionLength: s32 = cast(s32)array_len(ls.production, STR_MAX_SIZE);
    ls.steps += 12;

    if (ls.steps > productionLength) ls.steps = productionLength;

    for i: 0..ls.steps-1
    {
        step: u8 = ls.production[i];
        if (step == #char "F")
        {
            for j: 0..repeats-1
            {
                startPosWorld: Vector2 = turtle.origin;
                radAngle: float  = DEG2RAD*turtle.angle;
                turtle.origin.x += ls.drawLength*cos(radAngle);
                turtle.origin.y += ls.drawLength*sin(radAngle);
                startPosScreen: Vector2 = .{ startPosWorld.x + screenCenter.x, startPosWorld.y + screenCenter.y };
                endPosScreen: Vector2 = .{ turtle.origin.x + screenCenter.x, turtle.origin.y + screenCenter.y };

                DrawLineEx(startPosScreen, endPosScreen, 2, Fade(BLACK, 0.2));
            }

            repeats = 1;
        }
        else if (step == #char "+")
        {
            for j: 0..repeats-1 turtle.angle += ls.theta;

            repeats = 1;
        }
        else if (step == #char "-")
        {
            for j: 0..repeats-1 turtle.angle += -ls.theta;

            repeats = 1;
        }
        else if (step == #char "[") PushTurtleState(turtle);
        else if (step == #char "]") turtle = PopTurtleState();
        else if ((step >= 48) && (step <= 57)) repeats = cast(s32) step - 48;
    }

    turtleTop = -1;
}
