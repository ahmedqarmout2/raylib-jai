#import "raylib";
#import "Basic";
#import "Math";

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Movement constants
GRAVITY          :: 32.0;
MAX_SPEED        :: 20.0;
CROUCH_SPEED     :: 5.0;
JUMP_FORCE       :: 12.0;
MAX_ACCEL        :: 150.0;

// Grounded drag
FRICTION         :: 0.86;

// Increasing air drag, increases strafing speed
AIR_DRAG         :: 0.98;

// Responsiveness for turning movement direction to looked direction
CONTROL          :: 15.0;
CROUCH_HEIGHT    :: 0.0;
STAND_HEIGHT     :: 1.0;
BOTTOM_HEIGHT    :: 0.5;
NORMALIZE_INPUT  :: false;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Body structure
Body :: struct {
    position: Vector3;
    velocity: Vector3;
    dir: Vector3;
    isGrounded: bool;
}

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
sensitivity := Vector2.{ 0.001, 0.001 };
player: Body;
lookRotation: Vector2;
headTimer: float;
walkLerp: float;
headLerp := STAND_HEIGHT;
lean: Vector2;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth: s32 = 1920;
    screenHeight: s32 = 1080;

    InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera fps");
    defer CloseWindow();  // Close window and OpenGL context

    // Initialize camera variables
    // NOTE: UpdateCameraFPS() takes care of the rest
    camera: Camera;
    camera.fovy = 60.0;
    camera.projection = .CAMERA_PERSPECTIVE;
    camera.position = Vector3.{
        player.position.x,
        player.position.y + (BOTTOM_HEIGHT + headLerp),
        player.position.z,
    };

    UpdateCameraFPS(*camera); // Update camera parameters

    DisableCursor();        // Limit cursor to relative movement inside the window

    SetTargetFPS(60);       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while !WindowShouldClose()    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        mouseDelta: Vector2 = GetMouseDelta();
        lookRotation.x -= mouseDelta.x * sensitivity.x;
        lookRotation.y += mouseDelta.y * sensitivity.y;

        sideway: int = (ifx IsKeyDown(.KEY_D) then 1 else 0) - (ifx IsKeyDown(.KEY_A) then 1 else 0);
        forward: int = (ifx IsKeyDown(.KEY_W) then 1 else 0) - (ifx IsKeyDown(.KEY_S) then 1 else 0);
        crouching: bool = IsKeyDown(.KEY_LEFT_CONTROL);

        UpdateBody(*player, lookRotation.x, sideway, forward, IsKeyPressed(.KEY_SPACE), crouching);

        delta: float = GetFrameTime();
        headLerp = lerp(
            headLerp,
            ifx crouching then CROUCH_HEIGHT else STAND_HEIGHT,
            20.0 * delta
        );

        camera.position = Vector3.{
            player.position.x,
            player.position.y + (BOTTOM_HEIGHT + headLerp),
            player.position.z,
        };

        if player.isGrounded && ((forward != 0) || (sideway != 0)) {
            headTimer += delta * 3.0;
            walkLerp = lerp(walkLerp, 1.0, 10.0 * delta);
            camera.fovy = lerp(camera.fovy, 55.0, 5.0 * delta);
        } else {
            walkLerp = lerp(walkLerp, 0.0, 10.0 * delta);
            camera.fovy = lerp(camera.fovy, 60.0, 5.0 * delta);
        }

        lean.x = lerp(lean.x, sideway * 0.02, 10.0 * delta);
        lean.y = lerp(lean.y, forward * 0.015, 10.0 * delta);

        UpdateCameraFPS(*camera);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            BeginDrawing();
            defer EndDrawing();

                ClearBackground(RAYWHITE);

                BeginMode3D(camera);
                    DrawLevel();
                EndMode3D();

                // Draw info box
                DrawRectangle(5, 5, 330, 75, Fade(SKYBLUE, 0.5));
                DrawRectangleLines(5, 5, 330, 75, BLUE);

                DrawText("Camera controls:", 15, 15, 10, BLACK);
                DrawText("- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, BLACK);
                DrawText("- Look around: arrow keys or mouse", 15, 45, 10, BLACK);
                DrawText(
                    TextFormat(
                        "- Velocity Len: (%06.3f)",
                        Vector2Length(Vector2.{ player.velocity.x, player.velocity.z })
                    ),
                    15, 60, 10, BLACK
                );

        }
        //----------------------------------------------------------------------------------
    }
}

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
// Update body considering current world state
UpdateBody :: (
    body: *Body, rot: float, side: int, forward: int, jumpPressed: bool, crouchHold: bool
) {
    input := Vector2.{ cast(float)side, cast(float)(-forward) };

    #if NORMALIZE_INPUT {
        // Slow down diagonal movement
        if (side != 0) && (forward != 0) then input = Vector2Normalize(input);
    }

    delta: float = GetFrameTime();

    if !body.isGrounded then body.velocity.y -= GRAVITY * delta;

    if body.isGrounded && jumpPressed
    {
        body.velocity.y = JUMP_FORCE;
        body.isGrounded = false;
    }

    front := Vector3.{ sin(rot), 0.0, cos(rot) };
    right := Vector3.{ cos(-rot), 0.0, sin(-rot) };

    desiredDir := Vector3.{
        input.x * right.x + input.y * front.x,
        0.0,
        input.x * right.z + input.y * front.z
    };

    body.dir = Vector3Lerp(body.dir, desiredDir, CONTROL * delta);

    decel: float = ifx body.isGrounded then FRICTION else AIR_DRAG;
    hvel := Vector3.{ body.velocity.x * decel, 0.0, body.velocity.z * decel };

    hvelLength := Vector3Length(hvel); // Magnitude
    if hvelLength < (MAX_SPEED * 0.01) then hvel = Vector3.{};

    // This is what creates strafing
    speed: float = Vector3DotProduct(hvel, body.dir);

    // Whenever the amount of acceleration to add is clamped by the maximum acceleration constant,
    // a Player can make the speed faster by bringing the direction closer to horizontal velocity angle
    // More info here: https://youtu.be/v3zT3Z5apaM?t=165
    maxSpeed: float = ifx crouchHold then CROUCH_SPEED else MAX_SPEED;
    accel: float = clamp(maxSpeed - speed, 0.0, MAX_ACCEL * delta);
    hvel.x += body.dir.x * accel;
    hvel.z += body.dir.z * accel;

    body.velocity.x = hvel.x;
    body.velocity.z = hvel.z;

    body.position.x += body.velocity.x * delta;
    body.position.y += body.velocity.y * delta;
    body.position.z += body.velocity.z * delta;

    // Fancy collision system against the floor
    if body.position.y <= 0.0
    {
        body.position.y = 0.0;
        body.velocity.y = 0.0;
        body.isGrounded = true; // Enable jumping
    }
}

// Update camera for FPS behaviour
UpdateCameraFPS :: (camera: *Camera) {
    up := Vector3.{ 0.0, 1.0, 0.0 };
    targetOffset := Vector3.{ 0.0, 0.0, -1.0 };

    // Left and right
    yaw: Vector3 = Vector3RotateByAxisAngle(targetOffset, up, lookRotation.x);

    // Clamp view up
    maxAngleUp: float = Vector3Angle(up, yaw);
    maxAngleUp -= 0.001; // Avoid numerical errors
    if -lookRotation.y > maxAngleUp then lookRotation.y = -maxAngleUp;

    // Clamp view down
    maxAngleDown: float = Vector3Angle(Vector3Negate(up), yaw);
    maxAngleDown *= -1.0; // Downwards angle is negative
    maxAngleDown += 0.001; // Avoid numerical errors
    if -lookRotation.y < maxAngleDown then lookRotation.y = -maxAngleDown;

    // Up and down
    right: Vector3 = Vector3Normalize(Vector3CrossProduct(yaw, up));

    // Rotate view vector around right axis
    pitchAngle: float = -lookRotation.y - lean.y;

    // Clamp angle so it doesn't go past straight up or straight down
    pitchAngle = clamp(pitchAngle, -PI/2 + 0.0001, PI/2 - 0.0001);  // Note: modules/Math also has PI64 for more juice
    pitch: Vector3 = Vector3RotateByAxisAngle(yaw, right, pitchAngle);

    // Head animation
    // Rotate up direction around forward axis
    headSin := sin(headTimer * PI);
    headCos := cos(headTimer * PI);
    stepRotation := 0.01;
    camera.up = Vector3RotateByAxisAngle(up, pitch, headSin * stepRotation + lean.x);

    // Camera BOB
    bobSide := 0.1;
    bobUp := 0.15;
    bobbing: Vector3 = Vector3Scale(right, headSin * bobSide);
    bobbing.y = abs(headCos * bobUp);

    camera.position = Vector3Add(camera.position, Vector3Scale(bobbing, walkLerp));
    camera.target = Vector3Add(camera.position, pitch);
}

// Draw game level
DrawLevel :: () {
    floorExtent := 25;
    tileSize := 5.0;
    tileColor1 := Color.{ 150, 200, 200, 255 };

    // Floor tiles
    x, y := -floorExtent;

    for y: -floorExtent..floorExtent for x: -floorExtent..floorExtent {
        if (y & 1) != 0 && (x & 1) != 0 {
            DrawPlane(
                Vector3.{x * tileSize, 0.0, y * tileSize},
                Vector2.{tileSize, tileSize},
                tileColor1,
            );
        } else if (y & 1) == 0 && (x & 1) == 0 {
            DrawPlane(
                Vector3.{x * tileSize, 0.0, y * tileSize},
                Vector2.{tileSize, tileSize},
                LIGHTGRAY,
            );
        }
    }

    towerSize := Vector3.{ 16.0, 32.0, 16.0 };
    towerColor := Color.{ 150, 200, 200, 255 };

    towerPos := Vector3.{ 16.0, 16.0, 16.0 };
    DrawCubeV(towerPos, towerSize, towerColor);
    DrawCubeWiresV(towerPos, towerSize, DARKBLUE);

    towerPos.x *= -1;
    DrawCubeV(towerPos, towerSize, towerColor);
    DrawCubeWiresV(towerPos, towerSize, DARKBLUE);

    towerPos.z *= -1;
    DrawCubeV(towerPos, towerSize, towerColor);
    DrawCubeWiresV(towerPos, towerSize, DARKBLUE);

    towerPos.x *= -1;
    DrawCubeV(towerPos, towerSize, towerColor);
    DrawCubeWiresV(towerPos, towerSize, DARKBLUE);

    // Red sun
    DrawSphere(Vector3.{ 300.0, 300.0, 0.0 }, 100.0, Color.{ 255, 0, 0, 255 });
}

