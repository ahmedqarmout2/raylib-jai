#import "raylib";
#import "Basic";
#import "Math";

PadButton :: enum s32 {
    BUTTON_NONE :: -1;
    BUTTON_UP;
    BUTTON_LEFT;
    BUTTON_RIGHT;
    BUTTON_DOWN;
    BUTTON_MAX;
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

    InitWindow(screenWidth, screenHeight, "raylib [core] example - input virtual controls");

    padPosition: Vector2 = .{ 100, 350 };
    buttonRadius: float = 30;

    buttonPositions: [PadButton.BUTTON_MAX]Vector2 = .[
        .{ padPosition.x,padPosition.y - buttonRadius*1.5 },  // Up
        .{ padPosition.x - buttonRadius*1.5, padPosition.y }, // Left
        .{ padPosition.x + buttonRadius*1.5, padPosition.y }, // Right
        .{ padPosition.x, padPosition.y + buttonRadius*1.5 }  // Down
    ];

    arrowTris: [4][3]Vector2 = .[
        // Up
        .[
            .{ buttonPositions[0].x,     buttonPositions[0].y - 12 },
            .{ buttonPositions[0].x - 9, buttonPositions[0].y + 9  },
            .{ buttonPositions[0].x + 9, buttonPositions[0].y + 9  }
        ],
        // Left
        .[
            .{ buttonPositions[1].x + 9,  buttonPositions[1].y - 9 },
            .{ buttonPositions[1].x - 12, buttonPositions[1].y     },
            .{ buttonPositions[1].x + 9,  buttonPositions[1].y + 9 }
        ],
        // Right
        .[
            .{ buttonPositions[2].x + 12, buttonPositions[2].y     },
            .{ buttonPositions[2].x - 9,  buttonPositions[2].y - 9 },
            .{ buttonPositions[2].x - 9,  buttonPositions[2].y + 9 }
        ],
        // Down
        .[
            .{ buttonPositions[3].x - 9, buttonPositions[3].y - 9  },
            .{ buttonPositions[3].x,     buttonPositions[3].y + 12 },
            .{ buttonPositions[3].x + 9, buttonPositions[3].y - 9  }
        ]
    ];

    buttonLabelColors: [PadButton.BUTTON_MAX]Color = .[
        YELLOW, // Up
        BLUE,   // Left
        RED,    // Right
        GREEN   // Down
    ];

    pressedButton: PadButton = .BUTTON_NONE;
    inputPosition: Vector2 = .{ 0, 0 };

    playerPosition: Vector2 = .{ cast(float)screenWidth/2, cast(float)screenHeight/2 };
    playerSpeed: float = 75;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //--------------------------------------------------------------------------
        if ((GetTouchPointCount() > 0)) inputPosition = GetTouchPosition(0); // Use touch position
        else inputPosition = GetMousePosition(); // Use mouse position

        // Reset pressed button to none
        pressedButton = .BUTTON_NONE;

        // Make sure user is pressing left mouse button if they're from desktop
        if ((GetTouchPointCount() > 0) ||
            ((GetTouchPointCount() == 0) && IsMouseButtonDown(.MOUSE_BUTTON_LEFT)))
        {
            // Find nearest D-Pad button to the input position
            for i: 0..PadButton.BUTTON_MAX-1
            {
                distX: float = abs(buttonPositions[i].x - inputPosition.x);
                distY: float = abs(buttonPositions[i].y - inputPosition.y);

                if ((distX + distY < buttonRadius))
                {
                    pressedButton = i;
                    break;
                }
            }
        }

        // Move player according to pressed button
        if pressedButton ==
        {
            case .BUTTON_UP; playerPosition.y -= playerSpeed*GetFrameTime();
            case .BUTTON_LEFT; playerPosition.x -= playerSpeed*GetFrameTime();
            case .BUTTON_RIGHT; playerPosition.x += playerSpeed*GetFrameTime();
            case .BUTTON_DOWN; playerPosition.y += playerSpeed*GetFrameTime();
        };
        //--------------------------------------------------------------------------

        // Draw
        //--------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw world
            DrawCircleV(playerPosition, 50, MAROON);

            // Draw GUI
            for i: 0..PadButton.BUTTON_MAX-1
            {
                DrawCircleV(buttonPositions[i], buttonRadius, ifx (i == pressedButton) then DARKGRAY else BLACK);

                DrawTriangle(
                    arrowTris[i][0],
                    arrowTris[i][1],
                    arrowTris[i][2],
                    buttonLabelColors[i]
                );
            }

            DrawText("move the player with D-Pad buttons", 10, 10, 20, DARKGRAY);

        EndDrawing();
        //--------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
