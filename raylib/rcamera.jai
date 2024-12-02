//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//


/*
********************************************************************************************
*
*   rcamera - Basic camera system with support for multiple camera modes
*
*   CONFIGURATION:
*       #define RCAMERA_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RCAMERA_STANDALONE
*           If defined, the library can be used as standalone as a camera system but some
*           functions must be redefined to manage inputs accordingly.
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, update and maintenance
*       Christoph Wagner:   Complete redesign, using raymath (2022)
*       Marc Palau:         Initial implementation (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2022-2024 Christoph Wagner (@Crydsch) & Ramon Santamaria (@raysan5)
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
***********************************************************************************************
*/


//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Function specifiers definition

// Function specifiers in case library is build/used as a shared library (Windows)
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll



//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Below types are required for standalone usage
//----------------------------------------------------------------------------------

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------


GetCameraForward :: (camera: *Camera) -> Vector3 #foreign raylib_native;
GetCameraUp :: (camera: *Camera) -> Vector3 #foreign raylib_native;
GetCameraRight :: (camera: *Camera) -> Vector3 #foreign raylib_native;

// Camera movement
CameraMoveForward :: (camera: *Camera, distance: float, moveInWorldPlane: bool) #foreign raylib_native;
CameraMoveUp :: (camera: *Camera, distance: float) #foreign raylib_native;
CameraMoveRight :: (camera: *Camera, distance: float, moveInWorldPlane: bool) #foreign raylib_native;
CameraMoveToTarget :: (camera: *Camera, delta: float) #foreign raylib_native;

// Camera rotation
CameraYaw :: (camera: *Camera, angle: float, rotateAroundTarget: bool) #foreign raylib_native;
CameraPitch :: (camera: *Camera, angle: float, lockView: bool, rotateAroundTarget: bool, rotateUp: bool) #foreign raylib_native;
CameraRoll :: (camera: *Camera, angle: float) #foreign raylib_native;

GetCameraViewMatrix :: (camera: *Camera) -> Matrix4 #foreign raylib_native;
GetCameraProjectionMatrix :: (camera: *Camera, aspect: float) -> Matrix4 #foreign raylib_native;



