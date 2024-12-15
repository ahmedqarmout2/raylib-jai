/*
*********************************************************************************************
*
*   raylib.lights - Some useful functions to deal with lights data
*
*   CONFIGURATION:
*
*   #define RLIGHTS_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers 
*       or source files without problems. But only ONE file should hold the implementation.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2017-2024 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
*********************************************************************************************
*/

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
    intensity : float;
    
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
    LIGHT_SPOT;
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

CreateLight :: (type: LightType, position: Vector3, target: Vector3, color: Color, intensity: float, shader: Shader) -> Light {
    light: Light;

    if (lightsCount < MAX_LIGHTS) {
        light.enabled   = true;
        light.type      = type;
        light.position  = position;
        light.target    = target;
        light.color     = color;
        light.intensity = intensity;
        
        // NOTE: Shader parameters names for lights must match the requested ones
        light.enabledLoc   = GetShaderLocation(shader, TextFormat("lights[%i].enabled"  , lightsCount));
        light.typeLoc      = GetShaderLocation(shader, TextFormat("lights[%i].type"     , lightsCount));
        light.positionLoc  = GetShaderLocation(shader, TextFormat("lights[%i].position" , lightsCount));
        light.targetLoc    = GetShaderLocation(shader, TextFormat("lights[%i].target"   , lightsCount));
        light.colorLoc     = GetShaderLocation(shader, TextFormat("lights[%i].color"    , lightsCount));
        light.intensityLoc = GetShaderLocation(shader, TextFormat("lights[%i].intensity", lightsCount));
        
        UpdateLight(shader, light);

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

// Send light properties to shader
// NOTE: Light shader locations should be available
UpdateLight :: (shader: Shader, light: Light) {
    SetShaderValue(shader, light.enabledLoc, *light.enabled, .SHADER_UNIFORM_INT);
    SetShaderValue(shader, light.typeLoc   , *light.type   , .SHADER_UNIFORM_INT);
    
    // Send to shader light position values
    position: [3]float = .[light.position.x, light.position.y, light.position.z];
    SetShaderValue(shader, light.positionLoc, *position, .SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    target: [3]float = .[light.target.x, light.target.y, light.target.z];
    SetShaderValue(shader, light.targetLoc   , *target         , .SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    color: [4]float = .[
        cast(float)light.color.r/cast(float)255,
        cast(float)light.color.g/cast(float)255,
        cast(float)light.color.b/cast(float)255,
        cast(float)light.color.a/cast(float)255];
    SetShaderValue(shader, light.colorLoc    , *color          , .SHADER_UNIFORM_VEC4);
    SetShaderValue(shader, light.intensityLoc, *light.intensity, .SHADER_UNIFORM_FLOAT);
}
