#import "raylib";
#import "Basic";
#import "Math";

GRAVITY         : s32 : 400;
PLAYER_JUMP_SPD : float : 350.0;
PLAYER_HOR_SPD  : float : 200.0;

MAX_ENVIRONMENT_ELEMENTS : s32 : 5;

Player :: struct {
    position : Vector2;
    speed    : float;
    canJump  : bool;
};

EnvElement :: struct {
    rect     : Rectangle;
    blocking : s32;
    color    : Color;
};

main :: () {
    set_working_directory(#filepath);

    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    // Initialization
    //--------------------------------------------------------------------------------------
    InitWindow(screenWidth, screenHeight, "raylib [core] example - automation events");
    defer CloseWindow(); // Close window and OpenGL context

    icon: Image = LoadImage("../raylib_16x16.png");
    ImageFormat(*icon, .PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
    SetWindowIcon(icon);
    defer UnloadImage(icon);
    //--------------------------------------------------------------------------------------

    // Define player
    player: Player;
    player.position = Vector2.{ 400, 280 };
    player.speed = 0;
    player.canJump = false;

    // Define environment elements (platforms)
    envElements :: EnvElement.[
        EnvElement.{ Rectangle.{ 0, 0, 1000, 400 }  , 0, LIGHTGRAY },
        EnvElement.{ Rectangle.{ 0, 400, 1000, 200 }, 1, GRAY },
        EnvElement.{ Rectangle.{ 300, 200, 400, 10 }, 1, GRAY },
        EnvElement.{ Rectangle.{ 250, 300, 100, 10 }, 1, GRAY },
        EnvElement.{ Rectangle.{ 650, 300, 100, 10 }, 1, GRAY }
    ];

    // Define camera
    camera: Camera2D;
    camera.target = player.position;
    camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    // Automation events
    aelist: AutomationEventList = LoadAutomationEventList("automation_events.txt");  // Initialize list of automation events to record new events
    SetAutomationEventList(*aelist);
    eventRecording : bool = false;
    eventPlaying   : bool = false;

    frameCounter: u32 = 0;
    playFrameCounter: u32 = 0;
    currentPlayFrame: u32 = 0;

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        deltaTime : float = 0.015; //GetFrameTime();

        // Dropped files logic
        //----------------------------------------------------------------------------------
        if (IsFileDropped()) {
            droppedFiles: FilePathList = LoadDroppedFiles();

            // Supports loading .rgs style files (text or binary) and .png style palette images
            if (IsFileExtension(droppedFiles.paths[0], ".txt;.rae")) {
                UnloadAutomationEventList(*aelist);
                aelist = LoadAutomationEventList(droppedFiles.paths[0]);

                eventRecording = false;

                // Reset scene state to play
                eventPlaying = true;
                playFrameCounter = 0;
                currentPlayFrame = 0;

                player.position = Vector2.{ 400, 280 };
                player.speed = 0;
                player.canJump = false;

                camera.target = player.position;
                camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
                camera.rotation = 0.0;
                camera.zoom = 1.0;
            }

            UnloadDroppedFiles(droppedFiles);   // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Update player
        //----------------------------------------------------------------------------------
        if (IsKeyDown(.KEY_LEFT))  player.position.x -= PLAYER_HOR_SPD*deltaTime;
        if (IsKeyDown(.KEY_RIGHT)) player.position.x += PLAYER_HOR_SPD*deltaTime;
        if (IsKeyDown(.KEY_SPACE) && player.canJump) {
            player.speed = -PLAYER_JUMP_SPD;
            player.canJump = false;
        }

        hitObstacle: s32 = 0;
        for i: 0..MAX_ENVIRONMENT_ELEMENTS-1 {
            element: EnvElement = envElements[i];
            if (element.blocking &&
                element.rect.x <= player.position.x &&
                element.rect.x + element.rect.width >= player.position.x &&
                element.rect.y >= player.position.y &&
                element.rect.y <= player.position.y + player.speed*deltaTime) {
                hitObstacle = 1;
                player.speed = 0.0;
                player.position.y = element.rect.y;
            }
        }

        if (!hitObstacle) {
            player.position.y += player.speed*deltaTime;
            player.speed += GRAVITY*deltaTime;
            player.canJump = false;
        }
        else player.canJump = true;

        camera.zoom += (cast(float)GetMouseWheelMove()*0.05);

        if (camera.zoom > 3.0) camera.zoom = 3.0;
        else if (camera.zoom < 0.25) camera.zoom = 0.25;

        if (IsKeyPressed(.KEY_R)) {
            // Reset game state
            player.position = Vector2.{ 400, 280 };
            player.speed = 0;
            player.canJump = false;

            camera.target = player.position;
            camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
            camera.rotation = 0.0;
            camera.zoom = 1.0;
        }
        //----------------------------------------------------------------------------------

        // Update camera
        //----------------------------------------------------------------------------------
        camera.target = player.position;
        camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
        minX: float = 1000;
        minY: float = 1000;
        maxX: float = -1000;
        maxY: float = -1000;

        for i: 0..MAX_ENVIRONMENT_ELEMENTS-1 {
            element: EnvElement = envElements[i];
            minX = min(element.rect.x, minX);
            maxX = max(element.rect.x + element.rect.width, maxX);
            minY = min(element.rect.y, minY);
            maxY = max(element.rect.y + element.rect.height, maxY);
        }

        _max: Vector2 = GetWorldToScreen2D(Vector2.{ maxX, maxY }, camera);
        _min: Vector2 = GetWorldToScreen2D(Vector2.{ minX, minY }, camera);

        if (_max.x < cast(float)screenWidth)  camera.offset.x = screenWidth  - (_max.x - screenWidth/2);
        if (_max.y < cast(float)screenHeight) camera.offset.y = screenHeight - (_max.y - screenHeight/2);
        if (_min.x > 0) camera.offset.x = screenWidth/2  - _min.x;
        if (_min.y > 0) camera.offset.y = screenHeight/2 - _min.y;
        //----------------------------------------------------------------------------------
        
        // Toggle events recording
        if (IsKeyPressed(.KEY_S)) {
            if (!eventPlaying) {
                if (eventRecording) {
                    StopAutomationEventRecording();
                    eventRecording = false;
                    
                    ExportAutomationEventList(aelist, "automation.rae");
                    
                    TraceLog(.LOG_INFO, "RECORDED FRAMES: %i", aelist.count);
                } else {
                    SetAutomationEventBaseFrame(180);
                    StartAutomationEventRecording();
                    eventRecording = true;
                }
            }
        } else if (IsKeyPressed(.KEY_A)) {
            if (!eventRecording && (aelist.count > 0)) {
                // Reset scene state to play
                eventPlaying = true;
                playFrameCounter = 0;
                currentPlayFrame = 0;

                player.position = Vector2.{ 400, 280 };
                player.speed = 0;
                player.canJump = false;

                camera.target = player.position;
                camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
                camera.rotation = 0.0;
                camera.zoom = 1.0;
            }
        }
        
        if (eventPlaying) {
            // NOTE: Multiple events could be executed in a single frame
            while (playFrameCounter == aelist.events[currentPlayFrame].frame) {
                TraceLog(.LOG_INFO, "PLAYING: PlayFrameCount: %i | currentPlayFrame: %i | Event Frame: %i, param: %i", 
                    playFrameCounter, currentPlayFrame, aelist.events[currentPlayFrame].frame, aelist.events[currentPlayFrame].params[0]);
                
                PlayAutomationEvent(aelist.events[currentPlayFrame]);
                currentPlayFrame += 1;

                if (currentPlayFrame == aelist.count) {
                    eventPlaying = false;
                    currentPlayFrame = 0;
                    playFrameCounter = 0;

                    TraceLog(.LOG_INFO, "FINISH PLAYING!");
                    break;
                }
            }
            
            playFrameCounter += 1;
        }
        
        if (eventRecording || eventPlaying) frameCounter += 1;
        else frameCounter = 0;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(LIGHTGRAY);

            BeginMode2D(camera);

            // Draw environment elements
            for i: 0..MAX_ENVIRONMENT_ELEMENTS-1 {
                DrawRectangleRec(envElements[i].rect, envElements[i].color);
            }

            // Draw player rectangle
            DrawRectangleRec(Rectangle.{ player.position.x - 20, player.position.y - 40, 40, 40 }, RED);

            EndMode2D();
            
            // Draw game controls
            DrawRectangle(10, 10, 290, 145, Fade(SKYBLUE, 0.5));
            DrawRectangleLines(10, 10, 290, 145, Fade(BLUE, 0.8));

            DrawText("Controls:", 20, 20, 10, BLACK);
            DrawText("- RIGHT | LEFT: Player movement", 30, 40, 10, DARKGRAY);
            DrawText("- SPACE: Player jump", 30, 60, 10, DARKGRAY);
            DrawText("- R: Reset game state", 30, 80, 10, DARKGRAY);

            DrawText("- S: START/STOP RECORDING INPUT EVENTS", 30, 110, 10, BLACK);
            DrawText("- A: REPLAY LAST RECORDED INPUT EVENTS", 30, 130, 10, BLACK);

            // Draw automation events recording indicator
            if (eventRecording) {
                DrawRectangle(10, 160, 290, 30, Fade(RED, 0.3));
                DrawRectangleLines(10, 160, 290, 30, Fade(MAROON, 0.8));
                DrawCircle(30, 175, 10, MAROON);

                if (((frameCounter/15)%2) == 1) DrawText(TextFormat("RECORDING EVENTS... [%i]", aelist.count), 50, 170, 10, MAROON);
            } else if (eventPlaying) {
                DrawRectangle(10, 160, 290, 30, Fade(LIME, 0.3));
                DrawRectangleLines(10, 160, 290, 30, Fade(DARKGREEN, 0.8));
                DrawTriangle(Vector2.{ 20, 155 + 10 }, Vector2.{ 20, 155 + 30 }, Vector2.{ 40, 155 + 20 }, DARKGREEN);

                if (((frameCounter/15)%2) == 1) DrawText(TextFormat("PLAYING RECORDED EVENTS... [%i]", currentPlayFrame), 50, 170, 10, DARKGREEN);
            }
        }
        //----------------------------------------------------------------------------------
    }
}