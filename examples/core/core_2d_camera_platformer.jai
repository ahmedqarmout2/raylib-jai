#import "raylib";
#import "Basic";
#import "Math";

G : s32 : 400;
PLAYER_JUMP_SPD : float : 350.0;
PLAYER_HOR_SPD  : float : 200.0;

Player :: struct {
    position: Vector2;
    speed: float;
    canJump: bool;
}

EnvItem :: struct {
    rect: Rectangle;
    blocking: s32;
    color: Color;
}

main :: () {
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 2d camera platformer");
    defer CloseWindow(); // Close window and OpenGL context

    player: Player;
    player.position = Vector2.{ 400, 280 };
    player.speed = 0;
    player.canJump = false;
    envItems: [5]EnvItem = .[
        EnvItem.{ Rectangle.{ 0, 0, 1000, 400 },   0, LIGHTGRAY },
        EnvItem.{ Rectangle.{ 0, 400, 1000, 200 }, 1, GRAY },
        EnvItem.{ Rectangle.{ 300, 200, 400, 10 }, 1, GRAY },
        EnvItem.{ Rectangle.{ 250, 300, 100, 10 }, 1, GRAY },
        EnvItem.{ Rectangle.{ 650, 300, 100, 10 }, 1, GRAY }
    ];

    camera: Camera2D;
    camera.target = player.position;
    camera.offset = Vector2.{ screenWidth/2.0, screenHeight/2.0 };
    camera.rotation = 0.0;
    camera.zoom = 1.0;

    CameraFunc :: #type (camera: *Camera2D, player: *Player, items: []EnvItem, delta: float, w: s32, h: s32);

    cameraUpdaters: [5]CameraFunc = .[
        UpdateCameraCenter,
        UpdateCameraCenterInsideMap,
        UpdateCameraCenterSmoothFollow,
        UpdateCameraEvenOutOnLanding,
        UpdateCameraPlayerBoundsPush
    ];
    
    cameraOption         : s32 = 0;
    cameraUpdatersLength : s32 = 5;
    
    cameraDescriptions : [5]string = .[
        "Follow player center",
        "Follow player center, but clamp to map edges",
        "Follow player center; smoothed",
        "Follow player center horizontally; updateplayer center vertically after landing",
        "Player push camera on getting too close to screen edge"
    ];

    SetTargetFPS(60);              // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        deltaTime : float = GetFrameTime();
        
        UpdatePlayer(*player, envItems, deltaTime);

        camera.zoom += (cast(float)GetMouseWheelMove()*0.05);

        if camera.zoom > 3.0 camera.zoom = 3.0;
        else if camera.zoom < 0.25 camera.zoom = 0.25;
        
        if IsKeyPressed(.KEY_R) {
            camera.zoom = 1.0;
            player.position = Vector2.{ 400, 280 };
        }

        if IsKeyPressed(.KEY_C) cameraOption = (cameraOption + 1) % cameraUpdatersLength;

        // Call update camera function by its pointer
        cameraUpdaters[cameraOption](*camera, *player, envItems, deltaTime, screenWidth, screenHeight);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

            ClearBackground(LIGHTGRAY);

            {
                BeginMode2D(camera);
                defer EndMode2D();

                for envItems  DrawRectangleRec(it.rect, it.color);

                playerRect : Rectangle = Rectangle.{ player.position.x - 20, player.position.y - 40, 40, 40 };
                DrawRectangleRec(playerRect, RED);

                DrawCircleV(player.position, 5.0, GOLD);
            }

            DrawText("Controls:", 20, 20, 10, BLACK);
            DrawText("- Right/Left to move", 40, 40, 10, DARKGRAY);
            DrawText("- Space to jump", 40, 60, 10, DARKGRAY);
            DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, DARKGRAY);
            DrawText("- C to change camera mode", 40, 100, 10, DARKGRAY);
            DrawText("Current camera mode:", 20, 120, 10, BLACK);
            DrawText(get_c_string(cameraDescriptions[cameraOption]), 40, 140, 10, DARKGRAY);
        }
        //----------------------------------------------------------------------------------
    }
}

UpdatePlayer :: (player: *Player, envItems: []EnvItem, delta: float) {
    if (IsKeyDown(.KEY_LEFT)) player.position.x -= PLAYER_HOR_SPD*delta;
    if (IsKeyDown(.KEY_RIGHT)) player.position.x += PLAYER_HOR_SPD*delta;
    if (IsKeyDown(.KEY_SPACE) && player.canJump) {
        player.speed = -PLAYER_JUMP_SPD;
        player.canJump = false;
    }

    hitObstacle: bool = false;
    for envItems {
        p : *Vector2 = *player.position;
        if (it.blocking &&
            it.rect.x <= p.x &&
            it.rect.x + it.rect.width >= p.x &&
            it.rect.y >= p.y &&
            it.rect.y <= p.y + player.speed*delta) {
            hitObstacle = true;
            player.speed = 0.0;
            p.y = it.rect.y;
            break;
        }
    }

    if (!hitObstacle) {
        player.position.y += player.speed*delta;
        player.speed += G*delta;
        player.canJump = false;
    } else player.canJump = true;
}

UpdateCameraCenter :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: s32, height: s32) {
    camera.offset = Vector2.{ width/2.0, height/2.0 };
    camera.target = player.position;
}

UpdateCameraCenterInsideMap :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: s32, height: s32) {
    camera.target = player.position;
    camera.offset = Vector2.{ width/2.0, height/2.0 };
    minX: float = 1000;
    minY: float = 1000;
    maxX: float = -1000;
    maxY: float = -1000;

    for envItems {
        minX = min(it.rect.x, minX);
        maxX = max(it.rect.x + it.rect.width, maxX);
        minY = min(it.rect.y, minY);
        maxY = max(it.rect.y + it.rect.height, maxY);
    }

    max_val : Vector2 = GetWorldToScreen2D(Vector2.{maxX, maxY}, << camera);
    min_val : Vector2 = GetWorldToScreen2D(Vector2.{minX, minY}, << camera);
    
    if max_val.x < cast(float)width camera.offset.x = width - (max_val.x - width/2);
    if max_val.y < cast(float)height camera.offset.y = height - (max_val.y - height/2);
    if min_val.x > 0 camera.offset.x = width/2 - min_val.x;
    if min_val.y > 0 camera.offset.y = height/2 - min_val.y;
}

UpdateCameraCenterSmoothFollow :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: s32, height: s32) {
    minSpeed: float = 30;
    minEffectLength: float = 10;
    fractionSpeed: float = 0.8;

    camera.offset = Vector2.{ width/2.0, height/2.0 };
    diff: Vector2 = Vector2Subtract(player.position, camera.target);
    length: float = Vector2Length(diff);

    if (length > minEffectLength) {
        speed: float = max(fractionSpeed*length, minSpeed);
        camera.target = Vector2Add(camera.target, Vector2Scale(diff, speed*delta/length));
    }
}

evenOutSpeed  : float = 700;
eveningOut    : s32 = 0;
evenOutTarget : float;

UpdateCameraEvenOutOnLanding :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: s32, height: s32) {
    camera.offset   = Vector2.{ width/2.0, height/2.0 };
    camera.target.x = player.position.x;

    if (eveningOut) {
        if (evenOutTarget > camera.target.y) {
            camera.target.y += evenOutSpeed*delta;

            if (camera.target.y > evenOutTarget) {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        } else {
            camera.target.y -= evenOutSpeed*delta;

            if (camera.target.y < evenOutTarget) {
                camera.target.y = evenOutTarget;
                eveningOut = 0;
            }
        }
    } else {
        if (player.canJump && (player.speed == 0) && (player.position.y != camera.target.y)) {
            eveningOut = 1;
            evenOutTarget = player.position.y;
        }
    }
}

bbox : Vector2 = .{ 0.2, 0.2 };

UpdateCameraPlayerBoundsPush :: (camera: *Camera2D, player: *Player, envItems: []EnvItem, delta: float, width: s32, height: s32) {
    bboxWorldMin: Vector2 = GetScreenToWorld2D(Vector2.{ (1 - bbox.x)*0.5*width, (1 - bbox.y)*0.5*height }, << camera);
    bboxWorldMax: Vector2 = GetScreenToWorld2D(Vector2.{ (1 + bbox.x)*0.5*width, (1 + bbox.y)*0.5*height }, << camera);
    camera.offset = Vector2.{ (1 - bbox.x)*0.5 * width, (1 - bbox.y)*0.5*height };

    if (player.position.x < bboxWorldMin.x) camera.target.x = player.position.x;
    if (player.position.y < bboxWorldMin.y) camera.target.y = player.position.y;
    if (player.position.x > bboxWorldMax.x) camera.target.x = bboxWorldMin.x + (player.position.x - bboxWorldMax.x);
    if (player.position.y > bboxWorldMax.y) camera.target.y = bboxWorldMin.y + (player.position.y - bboxWorldMax.y);
}