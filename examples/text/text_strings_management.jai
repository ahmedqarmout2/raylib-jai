#import "raylib";
#import "Basic";
#import "Math";

MAX_TEXT_LENGTH ::     100;
MAX_TEXT_PARTICLES ::  100;
FONT_SIZE ::            30;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
TextParticle :: struct {
    text: [MAX_TEXT_LENGTH]u8;
    rect: Rectangle;    // Boundary
    vel: Vector2;       // Velocity
    ppos: Vector2;      // Previous position
    padding: float;
    borderWidth: float;
    friction: float;
    elasticity: float;
    color: Color;
    grabbed: bool;
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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - strings management");

    textParticles: [MAX_TEXT_PARTICLES]TextParticle;
    particleCount: s32 = 0;
    grabbedTextParticle: *TextParticle = null;
    pressOffset: Vector2;

    PrepareFirstTextParticle("raylib => fun videogames programming!", textParticles.data, *particleCount);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        delta: float = GetFrameTime();
        mousePos: Vector2 = GetMousePosition();

        // Checks if a text particle was grabbed
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
        {
            i: s32 = particleCount - 1;
            while (i >= 0)
            {
                defer i -= 1;

                tp: *TextParticle = *textParticles[i];
                pressOffset.x = mousePos.x - tp.rect.x;
                pressOffset.y = mousePos.y - tp.rect.y;
                if (CheckCollisionPointRec(mousePos, tp.rect))
                {
                    tp.grabbed = true;
                    grabbedTextParticle = tp;
                    break;
                }
            }
        }

        // Releases any text particle the was grabbed
        if (IsMouseButtonReleased(.MOUSE_BUTTON_LEFT))
        {
            if (grabbedTextParticle != null)
            {
                grabbedTextParticle.grabbed = false;
                grabbedTextParticle = null;
            }
        }

        // Slice os shatter a text particle
        if (IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT))
        {
            i: s32 = particleCount - 1;
            while (i >= 0)
            {
                defer i -= 1;

                tp: *TextParticle = *textParticles[i];
                if (CheckCollisionPointRec(mousePos, tp.rect))
                {
                    if (IsKeyDown(.KEY_LEFT_SHIFT))
                    {
                        ShatterTextParticle(tp, i, textParticles.data, *particleCount);
                    }
                    else
                    {
                        SliceTextParticle(tp, i, cast(s32)TextLength(tp.text.data)/2, textParticles.data, *particleCount);
                    }
                    break;
                }
            }
        }

        // Shake text particles
        if (IsMouseButtonPressed(.MOUSE_BUTTON_MIDDLE))
        {
            for i: 0..particleCount-1
            {
                if (!textParticles[i].grabbed) textParticles[i].vel = Vector2.{ cast(float)GetRandomValue(-2000, 2000), cast(float)GetRandomValue(-2000, 2000) };
            }
        }

        // Reset using TextTo* functions
        if (IsKeyPressed(.KEY_ONE)) PrepareFirstTextParticle("raylib => fun videogames programming!", textParticles.data, *particleCount);
        if (IsKeyPressed(.KEY_TWO)) PrepareFirstTextParticle(TextToUpper("raylib => fun videogames programming!"), textParticles.data, *particleCount);
        if (IsKeyPressed(.KEY_THREE)) PrepareFirstTextParticle(TextToLower("raylib => fun videogames programming!"), textParticles.data, *particleCount);
        if (IsKeyPressed(.KEY_FOUR)) PrepareFirstTextParticle(TextToPascal("raylib_fun_videogames_programming"), textParticles.data, *particleCount);
        if (IsKeyPressed(.KEY_FIVE)) PrepareFirstTextParticle(TextToSnake("RaylibFunVideogamesProgramming"), textParticles.data, *particleCount);
        if (IsKeyPressed(.KEY_SIX)) PrepareFirstTextParticle(TextToCamel("raylib_fun_videogames_programming"), textParticles.data, *particleCount);

        // Slice by char pressed only when we have one text particle
        charPressed: u8 = GetCharPressed();
        if ((charPressed >= #char "A") && (charPressed <= #char "z") && (particleCount == 1))
        {
            SliceTextParticleByChar(*textParticles[0], charPressed, textParticles.data, *particleCount);
        }

        // Updates each text particle state
        for i: 0..particleCount-1
        {
            tp: *TextParticle = *textParticles[i];

            // The text particle is not grabbed
            if (!tp.grabbed)
            {
                // text particle repositioning using the velocity
                tp.rect.x += tp.vel.x * delta;
                tp.rect.y += tp.vel.y * delta;

                // Does the text particle hit the screen right boundary?
                if ((tp.rect.x + tp.rect.width) >= screenWidth * 1.0)
                {
                    tp.rect.x = screenWidth - tp.rect.width; // Text particle repositioning
                    tp.vel.x = -tp.vel.x*tp.elasticity;  // Elasticity makes the text particle lose 10% of its velocity on hit
                }
                // Does the text particle hit the screen left boundary?
                else if (tp.rect.x <= 0)
                {
                    tp.rect.x = 0.0;
                    tp.vel.x = -tp.vel.x*tp.elasticity;
                }

                // The same for y axis
                if ((tp.rect.y + tp.rect.height) >= screenHeight * 1.0)
                {
                    tp.rect.y = screenHeight - tp.rect.height;
                    tp.vel.y = -tp.vel.y*tp.elasticity;
                }
                else if (tp.rect.y <= 0)
                {
                    tp.rect.y = 0.0;
                    tp.vel.y = -tp.vel.y*tp.elasticity;
                }

                // Friction makes the text particle lose 1% of its velocity each frame
                tp.vel.x = tp.vel.x*tp.friction;
                tp.vel.y = tp.vel.y*tp.friction;
            }
            else
            {
                // Text particle repositioning using the mouse position
                tp.rect.x = mousePos.x - pressOffset.x;
                tp.rect.y = mousePos.y - pressOffset.y;

                // While the text particle is grabbed, recalculates its velocity
                tp.vel.x = (tp.rect.x - tp.ppos.x)/delta;
                tp.vel.y = (tp.rect.y - tp.ppos.y)/delta;
                tp.ppos.x = tp.rect.x;
                tp.ppos.y = tp.rect.y;

                // Glue text particles when dragging and pressing left ctrl
                if (IsKeyDown(.KEY_LEFT_CONTROL))
                {
                    for i: 0..particleCount-1
                    {
                        if (*textParticles[i] != grabbedTextParticle && grabbedTextParticle.grabbed)
                        {
                            if (CheckCollisionRecs(grabbedTextParticle.rect, textParticles[i].rect))
                            {
                                GlueTextParticles(grabbedTextParticle, *textParticles[i], textParticles.data, *particleCount);
                                grabbedTextParticle = *textParticles[particleCount-1];
                            }
                        }
                    }
                }
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            for i: 0..particleCount-1
            {
                tp: *TextParticle = *textParticles[i];
                DrawRectangleRec(Rectangle.{ tp.rect.x - tp.borderWidth, tp.rect.y - tp.borderWidth, tp.rect.width + tp.borderWidth * 2, tp.rect.height + tp.borderWidth * 2 }, BLACK);
                DrawRectangleRec(tp.rect, tp.color);
                DrawText(tp.text.data, cast(s32)(tp.rect.x+tp.padding), cast(s32)(tp.rect.y+tp.padding), FONT_SIZE, BLACK);
            }

            DrawText("grab a text particle by pressing with the mouse and throw it by releasing", 10, 10, 10, DARKGRAY);
            DrawText("slice a text particle by pressing it with the mouse right button", 10, 30, 10, DARKGRAY);
            DrawText("shatter a text particle keeping left shift pressed and pressing it with the mouse right button", 10, 50, 10, DARKGRAY);
            DrawText("glue text particles by grabbing than and keeping left control pressed", 10, 70, 10, DARKGRAY);
            DrawText("1 to 6 to reset", 10, 90, 10, DARKGRAY);
            DrawText("when you have only one text particle, you can slice it by pressing a char", 10, 110, 10, DARKGRAY);
            DrawText(TextFormat("TEXT PARTICLE COUNT: %d", particleCount), 10, GetScreenHeight() - 30, 20, BLACK);

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
PrepareFirstTextParticle :: (text: *u8, tps: *TextParticle, particleCount: *s32)
{
    tps[0] = CreateTextParticle(
        text,
        GetScreenWidth()/2.0,
        GetScreenHeight()/2.0,
        RAYWHITE
    );
    (.*)particleCount = 1;
}

CreateTextParticle :: (text: *u8, x: float, y: float, color: Color) -> TextParticle
{
    tp: TextParticle;
    //tp.text = "";
    tp.rect = .{ x, y, 30, 30 };
    tp.vel = .{ cast(float)GetRandomValue(-200, 200), cast(float)GetRandomValue(-200, 200) };
    tp.ppos = .{};
    tp.padding = 5.0;
    tp.borderWidth = 5.0;
    tp.friction = 0.99;
    tp.elasticity = 0.9;
    tp.color = color;
    tp.grabbed = false;

    TextCopy(tp.text.data, text);
    tp.rect.width = MeasureText(tp.text.data, FONT_SIZE)+tp.padding*2;
    tp.rect.height = FONT_SIZE+tp.padding*2;
    return tp;
}

SliceTextParticle :: (tp: *TextParticle, particlePos: s32, sliceLength: s32, tps: *TextParticle, particleCount: *s32)
{
    length: s32 = cast(s32)TextLength(tp.text.data);

    if((length > 1) && (((.*)particleCount+length) < MAX_TEXT_PARTICLES))
    {
        i: s32 = 0;
        while (i < length)
        {
            defer i += sliceLength;

            text: *u8 = ifx sliceLength == 1 then TextFormat("%c", tp.text[i]) else TextSubtext(tp.text.data, i, sliceLength);
            tps[(.*)particleCount] = CreateTextParticle(
                text,
                tp.rect.x + i * tp.rect.width/length,
                tp.rect.y,
                Color.{ cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), 255 }
            );
            ((.*)particleCount) += 1;
        }
        RealocateTextParticles(tps, particlePos, particleCount);
    }
}

SliceTextParticleByChar :: (tp: *TextParticle, charToSlice: u8, tps: *TextParticle, particleCount: *s32)
{
    tokenCount: s32 = 0;
    tokens: **u8 = TextSplit(tp.text.data, charToSlice, *tokenCount);

    if (tokenCount > 1)
    {
        textLength: s32 = cast(s32)TextLength(tp.text.data);
        for i: 0..textLength-1
        {
            if (tp.text[i] == charToSlice)
            {
                tps[(.*)particleCount] = CreateTextParticle(
                    TextFormat("%c", charToSlice),
                    tp.rect.x,
                    tp.rect.y,
                    Color.{ cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), 255 }
                );
                ((.*)particleCount) += 1;
            }
        }
        for i: 0..tokenCount-1
        {
            tokenLength: s32 = cast(s32)TextLength(tokens[i]);
            tps[(.*)particleCount] = CreateTextParticle(
                TextFormat("%s", tokens[i]),
                tp.rect.x + i * tp.rect.width/tokenLength,
                tp.rect.y,
                Color.{ cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), cast(u8)GetRandomValue(0, 255), 255 }
            );
            ((.*)particleCount) += 1;
        }
        if (tokenCount)
        {
            RealocateTextParticles(tps, 0, particleCount);
        }
    }
}

ShatterTextParticle :: (tp: *TextParticle, particlePos: s32, tps: *TextParticle, particleCount: *s32)
{
    SliceTextParticle(tp, particlePos, 1, tps, particleCount);
}

GlueTextParticles :: (grabbed: *TextParticle, target: *TextParticle, tps: *TextParticle, particleCount: *s32)
{
    p1: s32 = -1;
    p2: s32 = -1;

    for i: 0..(.*)particleCount-1
    {
        if (*tps[i] == grabbed) p1 = i;
        if (*tps[i] == target) p2 = i;
    }

    if ((p1 != -1) && (p2 != -1))
    {
        tp: TextParticle = CreateTextParticle(
            TextFormat( "%s%s", grabbed.text.data, target.text.data),
            grabbed.rect.x,
            grabbed.rect.y,
            RAYWHITE
        );
        tp.grabbed = true;
        tps[(.*)particleCount] = tp;
        ((.*)particleCount) += 1;
        grabbed.grabbed = false;
        if (p1 < p2)
        {
            RealocateTextParticles(tps, p2, particleCount);
            RealocateTextParticles(tps, p1, particleCount);
        }
        else
        {
            RealocateTextParticles(tps, p1, particleCount);
            RealocateTextParticles(tps, p2, particleCount);
        }
    }
}

RealocateTextParticles :: (tps: *TextParticle, particlePos: s32, particleCount: *s32)
{
    i: s32 = particlePos+1;
    while (i < (.*)particleCount)
    {
        defer i += 1;

        tps[i-1] = tps[i];
    }
    ((.*)particleCount) -= 1;
}