#import "raylib";
#import "Basic";
#import "Math";

// IMPORTANT: This must match gol*.glsl GOL_WIDTH constant
// This must be a multiple of 16 (check golLogic compute dispatch)
GOL_WIDTH :: 768;

// Maximum amount of queued draw commands (squares draw from mouse down events)
MAX_BUFFERED_TRANSFERTS :: 48;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Game Of Life Update Command
GolUpdateCmd :: struct {
    x: u32;         // x coordinate of the gol command
    y: u32;         // y coordinate of the gol command
    w: u32;         // width of the filled zone
    enabled: bool;   // whether to enable or disable zone
};

// Game Of Life Update Commands SSBO
GolUpdateSSBO :: struct {
    count: u32;
    commands: [MAX_BUFFERED_TRANSFERTS]GolUpdateCmd;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : GOL_WIDTH;
    screenHeight : s32 : GOL_WIDTH;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - rlgl compute");

    resolution: Vector2 = .{ cast(float)screenWidth, cast(float)screenHeight };
    brushSize: u32 = 8;

    // Game of Life logic compute shader
    golLogicCode: *u8 = LoadFileText("resources/shaders/glsl430/gol.glsl");
    golLogicShader: u32 = rlLoadShader(golLogicCode, RL_COMPUTE_SHADER);
    golLogicProgram: u32 = rlLoadShaderProgramCompute(golLogicShader);
    UnloadFileText(golLogicCode);

    // Game of Life logic render shader
    golRenderShader: Shader = LoadShader(null, "resources/shaders/glsl430/gol_render.glsl");
    resUniformLoc: s32 = GetShaderLocation(golRenderShader, "resolution");

    // Game of Life transfert shader (CPU<->GPU download and upload)
    golTransfertCode: *u8 = LoadFileText("resources/shaders/glsl430/gol_transfert.glsl");
    golTransfertShader: u32 = rlLoadShader(golTransfertCode, RL_COMPUTE_SHADER);
    golTransfertProgram: u32 = rlLoadShaderProgramCompute(golTransfertShader);
    UnloadFileText(golTransfertCode);

    // Load shader storage buffer object (SSBO), id returned
    ssboA: u32 = rlLoadShaderBuffer(GOL_WIDTH*GOL_WIDTH*size_of(u32), null, RL_DYNAMIC_COPY);
    ssboB: u32 = rlLoadShaderBuffer(GOL_WIDTH*GOL_WIDTH*size_of(u32), null, RL_DYNAMIC_COPY);
    ssboTransfert: u32 = rlLoadShaderBuffer(size_of(GolUpdateSSBO), null, RL_DYNAMIC_COPY);

    transfertBuffer: GolUpdateSSBO;

    // Create a white texture of the size of the window to update
    // each pixel of the window using the fragment shader: golRenderShader
    whiteImage: Image = GenImageColor(GOL_WIDTH, GOL_WIDTH, WHITE);
    whiteTex: Texture = LoadTextureFromImage(whiteImage);
    UnloadImage(whiteImage);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())
    {
        // Update
        //----------------------------------------------------------------------------------
        brushSize += cast(u32)GetMouseWheelMove();

        if ((IsMouseButtonDown(.MOUSE_BUTTON_LEFT) || IsMouseButtonDown(.MOUSE_BUTTON_RIGHT))
            && (transfertBuffer.count < MAX_BUFFERED_TRANSFERTS))
        {
            // Buffer a new command
            transfertBuffer.commands[transfertBuffer.count].x = cast(u32)GetMouseX() - brushSize/2;
            transfertBuffer.commands[transfertBuffer.count].y = cast(u32)GetMouseY() - brushSize/2;
            transfertBuffer.commands[transfertBuffer.count].w = brushSize;
            transfertBuffer.commands[transfertBuffer.count].enabled = IsMouseButtonDown(.MOUSE_BUTTON_LEFT);
            transfertBuffer.count += 1;
        }
        else if (transfertBuffer.count > 0)  // Process transfert buffer
        {
            // Send SSBO buffer to GPU
            rlUpdateShaderBuffer(ssboTransfert, *transfertBuffer, size_of(GolUpdateSSBO), 0);

            // Process SSBO commands on GPU
            rlEnableShader(golTransfertProgram);
            rlBindShaderBuffer(ssboA, 1);
            rlBindShaderBuffer(ssboTransfert, 3);
            rlComputeShaderDispatch(transfertBuffer.count, 1, 1); // Each GPU unit will process a command!
            rlDisableShader();

            transfertBuffer.count = 0;
        }
        else
        {
            // Process game of life logic
            rlEnableShader(golLogicProgram);
            rlBindShaderBuffer(ssboA, 1);
            rlBindShaderBuffer(ssboB, 2);
            rlComputeShaderDispatch(GOL_WIDTH/16, GOL_WIDTH/16, 1);
            rlDisableShader();

            // ssboA <-> ssboB
            temp: u32 = ssboA;
            ssboA = ssboB;
            ssboB = temp;
        }

        rlBindShaderBuffer(ssboA, 1);
        SetShaderValue(golRenderShader, resUniformLoc, *resolution, .SHADER_UNIFORM_VEC2);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(BLANK);

            BeginShaderMode(golRenderShader);
                DrawTexture(whiteTex, 0, 0, WHITE);
            EndShaderMode();

            DrawRectangleLines(GetMouseX() - cast(s32)brushSize/2, GetMouseY() - cast(s32)brushSize/2, cast(s32)brushSize, cast(s32)brushSize, RED);

            DrawText("Use Mouse wheel to increase/decrease brush size", 10, 10, 20, WHITE);
            DrawFPS(GetScreenWidth() - 100, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload shader buffers objects
    rlUnloadShaderBuffer(ssboA);
    rlUnloadShaderBuffer(ssboB);
    rlUnloadShaderBuffer(ssboTransfert);

    // Unload compute shader
    rlUnloadShader(golLogicShader);
    rlUnloadShader(golTransfertShader);
    rlUnloadShaderProgram(golTransfertProgram);
    rlUnloadShaderProgram(golLogicProgram);

    UnloadTexture(whiteTex);            // Unload white texture
    UnloadShader(golRenderShader);      // Unload rendering fragment shader

    CloseWindow();                      // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
