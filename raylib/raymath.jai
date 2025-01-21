//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//

EPSILON :: 0.000001;
DEG2RAD :: (PI/180.0);
RAD2DEG :: (180.0/PI);

/*
***********************************************************************************************
*
*   raymath v2.0 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
*
*   CONVENTIONS:
*     - Matrix structure is defined as row-major (memory layout) but parameters naming AND all
*       math operations performed by the library consider the structure as it was column-major
*       It is like transposed versions of the matrices are used for all the maths
*       It benefits some functions making them cache-friendly and also avoids matrix
*       transpositions sometimes required by OpenGL
*       Example: In memory order, row0 is [m0 m4 m8 m12] but in semantic math row0 is [m0 m1 m2 m3]
*     - Functions are always self-contained, no function use another raymath function inside,
*       required code is directly re-implemented inside
*     - Functions input parameters are always received by value (2 unavoidable exceptions)
*     - Functions use always a "result" variable for return (except C++ operators)
*     - Functions are always defined inline
*     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided for convenience)
*     - No compound literals used to make sure libray is compatible with C++
*
*   CONFIGURATION:
*       #define RAYMATH_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RAYMATH_STATIC_INLINE
*           Define static inline functions code, so #include header suffices for use.
*           This may use up lots of memory.
*
*       #define RAYMATH_DISABLE_CPP_OPERATORS
*           Disables C++ operator overloads for raymath types.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2024 Ramon Santamaria (@raysan5)
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



// Function specifiers definition


//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------




// Get float vector for Matrix

// Get float vector for Vector3

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------





// NOTE: Helper types to be used instead of array return types for *ToFloat functions
float3 :: struct {
    v: [3]float; 
}

float16 :: struct {
    v: [16]float; 
}


//----------------------------------------------------------------------------------
// Module Functions Definition - Utils math
//----------------------------------------------------------------------------------

// Clamp float value
Clamp :: (value: float, min: float, max: float) -> float #foreign raylib_native;

// Calculate linear interpolation between two floats
Lerp :: (start: float, end: float, amount: float) -> float #foreign raylib_native;

// Normalize input value within input range
Normalize :: (value: float, start: float, end: float) -> float #foreign raylib_native;

// Remap input value within input range to output range
Remap :: (value: float, inputStart: float, inputEnd: float, outputStart: float, outputEnd: float) -> float #foreign raylib_native;

// Wrap input value from min to max
Wrap :: (value: float, min: float, max: float) -> float #foreign raylib_native;

// Check whether two given floats are almost equal
FloatEquals :: (x: float, y: float) -> s32 #foreign raylib_native;

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector2 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector2Zero :: () -> Vector2 #foreign raylib_native;

// Vector with components value 1.0f
Vector2One :: () -> Vector2 #foreign raylib_native;

// Add two vectors (v1 + v2)
Vector2Add :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Add vector and float value
Vector2AddValue :: (v: Vector2, add: float) -> Vector2 #foreign raylib_native;

// Subtract two vectors (v1 - v2)
Vector2Subtract :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Subtract vector by float value
Vector2SubtractValue :: (v: Vector2, sub: float) -> Vector2 #foreign raylib_native;

// Calculate vector length
Vector2Length :: (v: Vector2) -> float #foreign raylib_native;

// Calculate vector square length
Vector2LengthSqr :: (v: Vector2) -> float #foreign raylib_native;

// Calculate two vectors dot product
Vector2DotProduct :: (v1: Vector2, v2: Vector2) -> float #foreign raylib_native;

// Calculate distance between two vectors
Vector2Distance :: (v1: Vector2, v2: Vector2) -> float #foreign raylib_native;

// Calculate square distance between two vectors
Vector2DistanceSqr :: (v1: Vector2, v2: Vector2) -> float #foreign raylib_native;

// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)
Vector2Angle :: (v1: Vector2, v2: Vector2) -> float #foreign raylib_native;

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle
Vector2LineAngle :: (start: Vector2, end: Vector2) -> float #foreign raylib_native;

// Scale vector (multiply by value)
Vector2Scale :: (v: Vector2, scale: float) -> Vector2 #foreign raylib_native;

// Multiply vector by vector
Vector2Multiply :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Negate vector
Vector2Negate :: (v: Vector2) -> Vector2 #foreign raylib_native;

// Divide vector by vector
Vector2Divide :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Normalize provided vector
Vector2Normalize :: (v: Vector2) -> Vector2 #foreign raylib_native;


// Transforms a Vector2 by a given Matrix
Vector2Transform :: (v: Vector2, mat: Matrix4) -> Vector2 #foreign raylib_native;

// Calculate linear interpolation between two vectors
Vector2Lerp :: (v1: Vector2, v2: Vector2, amount: float) -> Vector2 #foreign raylib_native;

// Calculate reflected vector to normal
Vector2Reflect :: (v: Vector2, normal: Vector2) -> Vector2 #foreign raylib_native;

// Get min value for each pair of components
Vector2Min :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Get max value for each pair of components
Vector2Max :: (v1: Vector2, v2: Vector2) -> Vector2 #foreign raylib_native;

// Rotate vector by angle
Vector2Rotate :: (v: Vector2, angle: float) -> Vector2 #foreign raylib_native;

// Move Vector towards target
Vector2MoveTowards :: (v: Vector2, target: Vector2, maxDistance: float) -> Vector2 #foreign raylib_native;

// Invert the given vector
Vector2Invert :: (v: Vector2) -> Vector2 #foreign raylib_native;

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector2Clamp :: (v: Vector2, min: Vector2, max: Vector2) -> Vector2 #foreign raylib_native;

// Clamp the magnitude of the vector between two min and max values
Vector2ClampValue :: (v: Vector2, min: float, max: float) -> Vector2 #foreign raylib_native;



// Check whether two given vectors are almost equal
Vector2Equals :: (p: Vector2, q: Vector2) -> s32 #foreign raylib_native;

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
Vector2Refract :: (v: Vector2, n: Vector2, r: float) -> Vector2 #foreign raylib_native;



//----------------------------------------------------------------------------------
// Module Functions Definition - Vector3 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector3Zero :: () -> Vector3 #foreign raylib_native;

// Vector with components value 1.0f
Vector3One :: () -> Vector3 #foreign raylib_native;

// Add two vectors
Vector3Add :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Add vector and float value
Vector3AddValue :: (v: Vector3, add: float) -> Vector3 #foreign raylib_native;

// Subtract two vectors
Vector3Subtract :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Subtract vector by float value
Vector3SubtractValue :: (v: Vector3, sub: float) -> Vector3 #foreign raylib_native;

// Multiply vector by scalar
Vector3Scale :: (v: Vector3, scalar: float) -> Vector3 #foreign raylib_native;

// Multiply vector by vector
Vector3Multiply :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Calculate two vectors cross product
Vector3CrossProduct :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Calculate one vector perpendicular vector
Vector3Perpendicular :: (v: Vector3) -> Vector3 #foreign raylib_native;


    // Cross product between vectors


// Calculate vector length
Vector3Length :: (v: Vector3) -> float #foreign raylib_native;

// Calculate vector square length
Vector3LengthSqr :: (v: Vector3) -> float #foreign raylib_native;

// Calculate two vectors dot product
Vector3DotProduct :: (v1: Vector3, v2: Vector3) -> float #foreign raylib_native;

// Calculate distance between two vectors
Vector3Distance :: (v1: Vector3, v2: Vector3) -> float #foreign raylib_native;

// Calculate square distance between two vectors
Vector3DistanceSqr :: (v1: Vector3, v2: Vector3) -> float #foreign raylib_native;

// Calculate angle between two vectors
Vector3Angle :: (v1: Vector3, v2: Vector3) -> float #foreign raylib_native;

// Negate provided vector (invert direction)
Vector3Negate :: (v: Vector3) -> Vector3 #foreign raylib_native;

// Divide vector by vector
Vector3Divide :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Normalize provided vector
Vector3Normalize :: (v: Vector3) -> Vector3 #foreign raylib_native;


//Calculate the projection of the vector v1 on to v2
Vector3Project :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

//Calculate the rejection of the vector v1 on to v2
Vector3Reject :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation
Vector3OrthoNormalize :: (v1: *Vector3, v2: *Vector3) #foreign raylib_native;

// Transforms a Vector3 by a given Matrix
Vector3Transform :: (v: Vector3, mat: Matrix4) -> Vector3 #foreign raylib_native;

// Transform a vector by quaternion rotation
Vector3RotateByQuaternion :: (v: Vector3, q: Quaternion) -> Vector3 #foreign raylib_native;

// Rotates a vector around an axis
Vector3RotateByAxisAngle :: (v: Vector3, axis: Vector3, angle: float) -> Vector3 #foreign raylib_native;

// Move Vector towards target
Vector3MoveTowards :: (v: Vector3, target: Vector3, maxDistance: float) -> Vector3 #foreign raylib_native;

// Calculate linear interpolation between two vectors
Vector3Lerp :: (v1: Vector3, v2: Vector3, amount: float) -> Vector3 #foreign raylib_native;

// Calculate cubic hermite interpolation between two vectors and their tangents
// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
Vector3CubicHermite :: (v1: Vector3, tangent1: Vector3, v2: Vector3, tangent2: Vector3, amount: float) -> Vector3 #foreign raylib_native;

// Calculate reflected vector to normal
Vector3Reflect :: (v: Vector3, normal: Vector3) -> Vector3 #foreign raylib_native;

// Get min value for each pair of components
Vector3Min :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Get max value for each pair of components
Vector3Max :: (v1: Vector3, v2: Vector3) -> Vector3 #foreign raylib_native;

// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle
Vector3Barycenter :: (p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3 #foreign raylib_native;

// Projects a Vector3 from screen space into object space
// NOTE: We are avoiding calling other raymath functions despite available
Vector3Unproject :: (source: Vector3, projection: Matrix4, view: Matrix4) -> Vector3 #foreign raylib_native;

// Get Vector3 as float array
Vector3ToFloatV :: (v: Vector3) -> float3 #foreign raylib_native;

// Invert the given vector
Vector3Invert :: (v: Vector3) -> Vector3 #foreign raylib_native;

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector3Clamp :: (v: Vector3, min: Vector3, max: Vector3) -> Vector3 #foreign raylib_native;

// Clamp the magnitude of the vector between two values
Vector3ClampValue :: (v: Vector3, min: float, max: float) -> Vector3 #foreign raylib_native;



// Check whether two given vectors are almost equal
Vector3Equals :: (p: Vector3, q: Vector3) -> s32 #foreign raylib_native;

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
Vector3Refract :: (v: Vector3, n: Vector3, r: float) -> Vector3 #foreign raylib_native;



//----------------------------------------------------------------------------------
// Module Functions Definition - Vector4 math
//----------------------------------------------------------------------------------

Vector4Zero :: () -> Vector4 #foreign raylib_native;

Vector4One :: () -> Vector4 #foreign raylib_native;

Vector4Add :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

Vector4AddValue :: (v: Vector4, add: float) -> Vector4 #foreign raylib_native;

Vector4Subtract :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

Vector4SubtractValue :: (v: Vector4, add: float) -> Vector4 #foreign raylib_native;

Vector4Length :: (v: Vector4) -> float #foreign raylib_native;

Vector4LengthSqr :: (v: Vector4) -> float #foreign raylib_native;

Vector4DotProduct :: (v1: Vector4, v2: Vector4) -> float #foreign raylib_native;

// Calculate distance between two vectors
Vector4Distance :: (v1: Vector4, v2: Vector4) -> float #foreign raylib_native;

// Calculate square distance between two vectors
Vector4DistanceSqr :: (v1: Vector4, v2: Vector4) -> float #foreign raylib_native;

Vector4Scale :: (v: Vector4, scale: float) -> Vector4 #foreign raylib_native;

// Multiply vector by vector
Vector4Multiply :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

// Negate vector
Vector4Negate :: (v: Vector4) -> Vector4 #foreign raylib_native;

// Divide vector by vector
Vector4Divide :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

// Normalize provided vector
Vector4Normalize :: (v: Vector4) -> Vector4 #foreign raylib_native;


// Get min value for each pair of components
Vector4Min :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

// Get max value for each pair of components
Vector4Max :: (v1: Vector4, v2: Vector4) -> Vector4 #foreign raylib_native;

// Calculate linear interpolation between two vectors
Vector4Lerp :: (v1: Vector4, v2: Vector4, amount: float) -> Vector4 #foreign raylib_native;

// Move Vector towards target
Vector4MoveTowards :: (v: Vector4, target: Vector4, maxDistance: float) -> Vector4 #foreign raylib_native;

// Invert the given vector
Vector4Invert :: (v: Vector4) -> Vector4 #foreign raylib_native;

// Check whether two given vectors are almost equal
Vector4Equals :: (p: Vector4, q: Vector4) -> s32 #foreign raylib_native;


//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant
MatrixDeterminant :: (mat: Matrix4) -> float #foreign raylib_native;

// Get the trace of the matrix (sum of the values along the diagonal)
MatrixTrace :: (mat: Matrix4) -> float #foreign raylib_native;

// Transposes provided matrix
MatrixTranspose :: (mat: Matrix4) -> Matrix4 #foreign raylib_native;

// Invert provided matrix
MatrixInvert :: (mat: Matrix4) -> Matrix4 #foreign raylib_native;

// Get identity matrix
MatrixIdentity :: () -> Matrix4 #foreign raylib_native;

// Add two matrices
MatrixAdd :: (left: Matrix4, right: Matrix4) -> Matrix4 #foreign raylib_native;

// Subtract two matrices (left - right)
MatrixSubtract :: (left: Matrix4, right: Matrix4) -> Matrix4 #foreign raylib_native;

// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!
MatrixMultiply :: (left: Matrix4, right: Matrix4) -> Matrix4 #foreign raylib_native;

// Get translation matrix
MatrixTranslate :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;

// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians
MatrixRotate :: (axis: Vector3, angle: float) -> Matrix4 #foreign raylib_native;







// Get x-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateX :: (angle: float) -> Matrix4 #foreign raylib_native;

// Get y-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateY :: (angle: float) -> Matrix4 #foreign raylib_native;

// Get z-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateZ :: (angle: float) -> Matrix4 #foreign raylib_native;


// Get xyz-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateXYZ :: (angle: Vector3) -> Matrix4 #foreign raylib_native;

// Get zyx-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateZYX :: (angle: Vector3) -> Matrix4 #foreign raylib_native;

// Get scaling matrix
MatrixScale :: (x: float, y: float, z: float) -> Matrix4 #foreign raylib_native;

// Get perspective projection matrix
MatrixFrustum :: (left: float64, right: float64, bottom: float64, top: float64, nearPlane: float64, farPlane: float64) -> Matrix4 #foreign raylib_native;

// Get perspective projection matrix
// NOTE: Fovy angle must be provided in radians
MatrixPerspective :: (fovY: float64, aspect: float64, nearPlane: float64, farPlane: float64) -> Matrix4 #foreign raylib_native;

// Get orthographic projection matrix
MatrixOrtho :: (left: float64, right: float64, bottom: float64, top: float64, nearPlane: float64, farPlane: float64) -> Matrix4 #foreign raylib_native;

// Get camera look-at matrix (view matrix)
MatrixLookAt :: (eye: Vector3, target: Vector3, up: Vector3) -> Matrix4 #foreign raylib_native;

// Get float array of matrix data
MatrixToFloatV :: (mat: Matrix4) -> float16 #foreign raylib_native;

//----------------------------------------------------------------------------------
// Module Functions Definition - Quaternion math
//----------------------------------------------------------------------------------

// Add two quaternions
QuaternionAdd :: (q1: Quaternion, q2: Quaternion) -> Quaternion #foreign raylib_native;

// Add quaternion and float value
QuaternionAddValue :: (q: Quaternion, add: float) -> Quaternion #foreign raylib_native;

// Subtract two quaternions
QuaternionSubtract :: (q1: Quaternion, q2: Quaternion) -> Quaternion #foreign raylib_native;

// Subtract quaternion and float value
QuaternionSubtractValue :: (q: Quaternion, sub: float) -> Quaternion #foreign raylib_native;

// Get identity quaternion
QuaternionIdentity :: () -> Quaternion #foreign raylib_native;

// Computes the length of a quaternion
QuaternionLength :: (q: Quaternion) -> float #foreign raylib_native;

// Normalize provided quaternion
QuaternionNormalize :: (q: Quaternion) -> Quaternion #foreign raylib_native;

// Invert provided quaternion
QuaternionInvert :: (q: Quaternion) -> Quaternion #foreign raylib_native;


// Calculate two quaternion multiplication
QuaternionMultiply :: (q1: Quaternion, q2: Quaternion) -> Quaternion #foreign raylib_native;

// Scale quaternion by float value
QuaternionScale :: (q: Quaternion, mul: float) -> Quaternion #foreign raylib_native;

// Divide two quaternions
QuaternionDivide :: (q1: Quaternion, q2: Quaternion) -> Quaternion #foreign raylib_native;

// Calculate linear interpolation between two quaternions
QuaternionLerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion #foreign raylib_native;

// Calculate slerp-optimized interpolation between two quaternions
QuaternionNlerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion #foreign raylib_native;

// Calculates spherical linear interpolation between two quaternions
QuaternionSlerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion #foreign raylib_native;





// Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
QuaternionCubicHermiteSpline :: (q1: Quaternion, outTangent1: Quaternion, q2: Quaternion, inTangent2: Quaternion, t: float) -> Quaternion #foreign raylib_native;

// Calculate quaternion based on the rotation from one vector to another
QuaternionFromVector3ToVector3 :: (from: Vector3, to: Vector3) -> Quaternion #foreign raylib_native;

// Get a quaternion for a given rotation matrix
QuaternionFromMatrix :: (mat: Matrix4) -> Quaternion #foreign raylib_native;






// Get a matrix for a given quaternion
QuaternionToMatrix :: (q: Quaternion) -> Matrix4 #foreign raylib_native;

// Get rotation quaternion for an angle and axis
// NOTE: Angle must be provided in radians
QuaternionFromAxisAngle :: (axis: Vector3, angle: float) -> Quaternion #foreign raylib_native;


// Get the rotation angle and axis for a given quaternion
QuaternionToAxisAngle :: (q: Quaternion, outAxis: *Vector3, outAngle: *float) #foreign raylib_native;


        // This occurs when the angle is zero.
        // Not a problem: just set an arbitrary normalized axis.


// Get the quaternion equivalent to Euler angles
// NOTE: Rotation order is ZYX
QuaternionFromEuler :: (pitch: float, yaw: float, roll: float) -> Quaternion #foreign raylib_native;

// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
// NOTE: Angles are returned in a Vector3 struct in radians
QuaternionToEuler :: (q: Quaternion) -> Vector3 #foreign raylib_native;

// Transform a quaternion given a transformation matrix
QuaternionTransform :: (q: Quaternion, mat: Matrix4) -> Quaternion #foreign raylib_native;

// Check whether two given quaternions are almost equal
QuaternionEquals :: (p: Quaternion, q: Quaternion) -> s32 #foreign raylib_native;

// Decompose a transformation matrix into its rotational, translational and scaling components
MatrixDecompose :: (mat: Matrix4, translation: *Vector3, rotation: *Quaternion, scale: *Vector3) #foreign raylib_native;
        // Set to identity if close to zero



