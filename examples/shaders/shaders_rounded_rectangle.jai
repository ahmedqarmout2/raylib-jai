#import "raylib";
#import "Basic";
#import "Math";

GLSL_VERSION :: 330;

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Rounded rectangle data
RoundedRectangle :: struct {
    cornerRadius: Vector4; // Individual corner radius (top-left, top-right, bottom-left, bottom-right)

    // Shadow variables
    shadowRadius: float;
    shadowOffset: Vector2;
    shadowScale: float;

    // Border variables
    borderThickness: float; // Inner-border thickness

    // Shader locations
    rectangleLoc: s32;
    radiusLoc: s32;
    colorLoc: s32;
    shadowRadiusLoc: s32;
    shadowOffsetLoc: s32;
    shadowScaleLoc: s32;
    shadowColorLoc: s32;
    borderThicknessLoc: s32;
    borderColorLoc: s32;
};

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: ()
{
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - rounded rectangle");

    // Load the shader
    shader: Shader = LoadShader(TextFormat("resources/shaders/glsl%i/base.vs", GLSL_VERSION),
                               TextFormat("resources/shaders/glsl%i/rounded_rectangle.fs", GLSL_VERSION));

    // Create a rounded rectangle
    roundedRectangle: RoundedRectangle = CreateRoundedRectangle(
        Vector4.{ 5.0, 10.0, 15.0, 20.0 },     // Corner radius
        20.0,                                      // Shadow radius
        Vector2.{ 0.0, -5.0 },                   // Shadow offset
        0.95,                                      // Shadow scale
        5.0,                                       // Border thickness
        shader                                      // Shader
    );

    // Update shader uniforms
    UpdateRoundedRectangle(roundedRectangle, shader);

    rectangleColor: Color = BLUE;
    shadowColor: Color = DARKBLUE;
    borderColor: Color = SKYBLUE;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // Draw rectangle box with rounded corners using shader
            rec: Rectangle = .{ 50, 70, 110, 60 };
            DrawRectangleLines(cast(s32)rec.x - 20, cast(s32)rec.y - 20, cast(s32)rec.width + 40, cast(s32)rec.height + 40, DARKGRAY);
            DrawText("Rounded rectangle", cast(s32)rec.x - 20, cast(s32)rec.y - 35, 10, DARKGRAY);

            // Flip Y axis to match shader coordinate system
            rec.y = screenHeight - rec.y - rec.height;
            SetShaderValue(shader, roundedRectangle.rectangleLoc, *(float.[ rec.x, rec.y, rec.width, rec.height ]), .SHADER_UNIFORM_VEC4);

            // Only rectangle color
            SetShaderValue(shader, roundedRectangle.colorLoc, *(float.[ rectangleColor.r/255.0, rectangleColor.g/255.0, rectangleColor.b/255.0, rectangleColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.shadowColorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.borderColorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);

            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            // Draw rectangle shadow using shader
            rec = Rectangle.{ 50, 200, 110, 60 };
            DrawRectangleLines(cast(s32)rec.x - 20, cast(s32)rec.y - 20, cast(s32)rec.width + 40, cast(s32)rec.height + 40, DARKGRAY);
            DrawText("Rounded rectangle shadow", cast(s32)rec.x - 20, cast(s32)rec.y - 35, 10, DARKGRAY);

            rec.y = screenHeight - rec.y - rec.height;
            SetShaderValue(shader, roundedRectangle.rectangleLoc, *(float.[ rec.x, rec.y, rec.width, rec.height ]), .SHADER_UNIFORM_VEC4);

            // Only shadow color
            SetShaderValue(shader, roundedRectangle.colorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.shadowColorLoc, *(float.[ shadowColor.r/255.0, shadowColor.g/255.0, shadowColor.b/255.0, shadowColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.borderColorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);

            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            // Draw rectangle's border using shader
            rec = Rectangle.{ 50, 330, 110, 60 };
            DrawRectangleLines(cast(s32)rec.x - 20, cast(s32)rec.y - 20, cast(s32)rec.width + 40, cast(s32)rec.height + 40, DARKGRAY);
            DrawText("Rounded rectangle border", cast(s32)rec.x - 20, cast(s32)rec.y - 35, 10, DARKGRAY);

            rec.y = screenHeight - rec.y - rec.height;
            SetShaderValue(shader, roundedRectangle.rectangleLoc, *(float.[ rec.x, rec.y, rec.width, rec.height ]), .SHADER_UNIFORM_VEC4);

            // Only border color
            SetShaderValue(shader, roundedRectangle.colorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.shadowColorLoc, *(float.[ 0.0, 0.0, 0.0, 0.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.borderColorLoc, *(float.[ borderColor.r/255.0, borderColor.g/255.0, borderColor.b/255.0, borderColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);

            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            // Draw one more rectangle with all three colors
            rec = Rectangle.{ 240, 80, 500, 300 };
            DrawRectangleLines(cast(s32)rec.x - 30, cast(s32)rec.y - 30, cast(s32)rec.width + 60, cast(s32)rec.height + 60, DARKGRAY);
            DrawText("Rectangle with all three combined", cast(s32)rec.x - 30, cast(s32)rec.y - 45, 10, DARKGRAY);

            rec.y = screenHeight - rec.y - rec.height;
            SetShaderValue(shader, roundedRectangle.rectangleLoc, *(float.[ rec.x, rec.y, rec.width, rec.height ]), .SHADER_UNIFORM_VEC4);

            // All three colors
            SetShaderValue(shader, roundedRectangle.colorLoc, *(float.[ rectangleColor.r/255.0, rectangleColor.g/255.0, rectangleColor.b/255.0, rectangleColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.shadowColorLoc, *(float.[ shadowColor.r/255.0, shadowColor.g/255.0, shadowColor.b/255.0, shadowColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);
            SetShaderValue(shader, roundedRectangle.borderColorLoc, *(float.[ borderColor.r/255.0, borderColor.g/255.0, borderColor.b/255.0, borderColor.a/255.0 ]), .SHADER_UNIFORM_VEC4);

            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, WHITE);
            EndShaderMode();

            DrawText("(c) Rounded rectangle SDF by Iñigo Quilez. MIT License.", screenWidth - 300, screenHeight - 20, 10, BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader); // Unload shader

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

//------------------------------------------------------------------------------------
// Module Functions Definitions
//------------------------------------------------------------------------------------

// Create a rounded rectangle and set uniform locations
CreateRoundedRectangle :: (cornerRadius: Vector4, shadowRadius: float, shadowOffset: Vector2, shadowScale: float, borderThickness: float, shader: Shader) -> RoundedRectangle
{
    rec: RoundedRectangle;
    rec.cornerRadius = cornerRadius;
    rec.shadowRadius = shadowRadius;
    rec.shadowOffset = shadowOffset;
    rec.shadowScale = shadowScale;
    rec.borderThickness = borderThickness;

    // Get shader uniform locations
    rec.rectangleLoc = GetShaderLocation(shader, "rectangle");
    rec.radiusLoc = GetShaderLocation(shader, "radius");
    rec.colorLoc = GetShaderLocation(shader, "color");
    rec.shadowRadiusLoc = GetShaderLocation(shader, "shadowRadius");
    rec.shadowOffsetLoc = GetShaderLocation(shader, "shadowOffset");
    rec.shadowScaleLoc = GetShaderLocation(shader, "shadowScale");
    rec.shadowColorLoc = GetShaderLocation(shader, "shadowColor");
    rec.borderThicknessLoc = GetShaderLocation(shader, "borderThickness");
    rec.borderColorLoc = GetShaderLocation(shader, "borderColor");

    UpdateRoundedRectangle(rec, shader);

    return rec;
}

// Update rounded rectangle uniforms
UpdateRoundedRectangle :: (rec: RoundedRectangle, shader: Shader)
{
    SetShaderValue(shader, rec.radiusLoc, *(float.[ rec.cornerRadius.x, rec.cornerRadius.y, rec.cornerRadius.z, rec.cornerRadius.w ]), .SHADER_UNIFORM_VEC4);
    SetShaderValue(shader, rec.shadowRadiusLoc, *rec.shadowRadius, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, rec.shadowOffsetLoc, *(float.[ rec.shadowOffset.x, rec.shadowOffset.y ]), .SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, rec.shadowScaleLoc, *rec.shadowScale, .SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, rec.borderThicknessLoc, *rec.borderThickness, .SHADER_UNIFORM_FLOAT);
}
