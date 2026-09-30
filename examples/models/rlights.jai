//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
MAX_LIGHTS :: 4;         // Max dynamic lights supported by shader

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Light data
Light :: struct {   
    type      : LightType;
    enabled   : bool;
    position  : Vector3;
    target    : Vector3;
    color     : Color;
    attenuation : float;
    
    // Shader locations
    enabledLoc   : s32;
    typeLoc      : s32;
    positionLoc  : s32;
    targetLoc    : s32;
    colorLoc     : s32;
    intensityLoc : s32;
};

// Light type
LightType :: enum {
    LIGHT_DIRECTIONAL :: 0;
    LIGHT_POINT;
};

/*
**********************************************************************************
*
*   RLIGHTS IMPLEMENTATION
*
***********************************************************************************
*/

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
lightsCount: s32 = 0;    // Current amount of created lights

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Create a light and get shader locations
CreateLight :: (type: LightType, position: Vector3, target: Vector3, color: Color, shader: Shader) -> Light {
    light: Light;

    if (lightsCount < MAX_LIGHTS) {
        light.enabled  = true;
        light.type     = type;
        light.position = position;
        light.target   = target;
        light.color    = color;


        // NOTE: Lighting shader naming must be the provided ones
        light.enabledLoc  = GetShaderLocation(shader, TextFormat("lights[%i].enabled" , lightsCount));
        light.typeLoc     = GetShaderLocation(shader, TextFormat("lights[%i].type"    , lightsCount));
        light.positionLoc = GetShaderLocation(shader, TextFormat("lights[%i].position", lightsCount));
        light.targetLoc   = GetShaderLocation(shader, TextFormat("lights[%i].target"  , lightsCount));
        light.colorLoc    = GetShaderLocation(shader, TextFormat("lights[%i].color"   , lightsCount));

        UpdateLightValues(shader, light);
        
        lightsCount += 1;
    }

    return light;
}

// Send light properties to shader
// NOTE: Light shader locations should be available 
UpdateLightValues :: (shader: Shader, light: Light) {
    // Send to shader light enabled state and type
    SetShaderValue(shader, light.enabledLoc, *light.enabled, .SHADER_UNIFORM_INT);
    SetShaderValue(shader, light.typeLoc   , *light.type   , .SHADER_UNIFORM_INT);

    // Send to shader light position values
    position: [3]float = .[light.position.x, light.position.y, light.position.z];
    SetShaderValue(shader, light.positionLoc, *position, .SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    target: [3]float = .[light.target.x, light.target.y, light.target.z];
    SetShaderValue(shader, light.targetLoc, *target, .SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    color: [4]float = .[
        cast(float)light.color.r/cast(float)255,
        cast(float)light.color.g/cast(float)255,
        cast(float)light.color.b/cast(float)255,
        cast(float)light.color.a/cast(float)255];
    SetShaderValue(shader, light.colorLoc, *color, .SHADER_UNIFORM_VEC4);
}
