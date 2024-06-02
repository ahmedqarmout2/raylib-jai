/*
***********************************************************************************************
*
*   raymath v1.5 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
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
*     - Functions use always a "result" variable for return
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
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
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
// Vector2 type
Vector2 :: struct {
    x: float; 
    y: float; 
}

// Vector3 type
Vector3 :: struct {
    x: float; 
    y: float; 
    z: float; 
}

// Vector4 type
Vector4 :: struct {
    x: float; 
    y: float; 
    z: float; 
    w: float; 
}

// Quaternion type

// Matrix type (OpenGL style 4x4 - right handed, column major)
Matrix :: struct {
    m0, m4, m8, m12: float;       // Matrix first row (4 components)
    m1, m5, m9, m13: float;       // Matrix second row (4 components)
    m2, m6, m10, m14: float;      // Matrix third row (4 components)
    m3, m7, m11, m15: float;      // Matrix fourth row (4 components)
}

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



// Calculate linear interpolation between two floats


// Normalize input value within input range


// Remap input value within input range to output range


// Wrap input value from min to max


// Check whether two given floats are almost equal



//----------------------------------------------------------------------------------
// Module Functions Definition - Vector2 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f


// Vector with components value 1.0f


// Add two vectors (v1 + v2)


// Add vector and float value


// Subtract two vectors (v1 - v2)


// Subtract vector by float value


// Calculate vector length


// Calculate vector square length


// Calculate two vectors dot product


// Calculate distance between two vectors


// Calculate square distance between two vectors


// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)




// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle

    // TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior


// Scale vector (multiply by value)


// Multiply vector by vector


// Negate vector


// Divide vector by vector


// Normalize provided vector



// Transforms a Vector2 by a given Matrix




// Calculate linear interpolation between two vectors



// Calculate reflected vector to normal




// Rotate vector by angle




// Move Vector towards target






// Invert the given vector


// Clamp the components of the vector between
// min and max values specified by the given vectors



// Clamp the magnitude of the vector between two min and max values




// Check whether two given vectors are almost equal



//----------------------------------------------------------------------------------
// Module Functions Definition - Vector3 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f


// Vector with components value 1.0f


// Add two vectors


// Add vector and float value


// Subtract two vectors


// Subtract vector by float value


// Multiply vector by scalar


// Multiply vector by vector


// Calculate two vectors cross product


// Calculate one vector perpendicular vector




    // Cross product between vectors


// Calculate vector length


// Calculate vector square length


// Calculate two vectors dot product


// Calculate distance between two vectors



// Calculate square distance between two vectors



// Calculate angle between two vectors



// Negate provided vector (invert direction)


// Divide vector by vector


// Normalize provided vector




//Calculate the projection of the vector v1 on to v2





//Calculate the rejection of the vector v1 on to v2





// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation

    // Vector3Normalize(*v1);

    // Vector3CrossProduct(*v1, *v2)

    // Vector3Normalize(vn1);

    // Vector3CrossProduct(vn1, *v1)


// Transforms a Vector3 by a given Matrix




// Transform a vector by quaternion rotation



// Rotates a vector around an axis
    // Using Euler-Rodrigues Formula
    // Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula


    // Vector3Normalize(axis);


    // Vector3CrossProduct(w, v)

    // Vector3CrossProduct(w, wv)

    // Vector3Scale(wv, 2*a)

    // Vector3Scale(wwv, 2)




// Calculate linear interpolation between two vectors



// Calculate reflected vector to normal

    // I is the original vector
    // N is the normal of the incident plane
    // R = I - (2*N*(DotProduct[I, N]))




// Get min value for each pair of components



// Get max value for each pair of components



// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle





// Projects a Vector3 from screen space into object space
// NOTE: We are avoiding calling other raymath functions despite available

    // Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it

    // Calculate inverted matrix -> MatrixInvert(matViewProj);
    // Cache the matrix values (speed optimization)


    // Calculate the invert determinant (inlined to avoid double-caching)


    // Create quaternion from source point

    // Multiply quat point by unprojecte matrix

    // Normalized world points in vectors


// Get Vector3 as float array



// Invert the given vector


// Clamp the components of the vector between
// min and max values specified by the given vectors



// Clamp the magnitude of the vector between two values




// Check whether two given vectors are almost equal



// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface





//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant

    // Cache the matrix values (speed optimization)



// Get the trace of the matrix (sum of the values along the diagonal)


// Transposes provided matrix



// Invert provided matrix

    // Cache the matrix values (speed optimization)


    // Calculate the invert determinant (inlined to avoid double-caching)



// Get identity matrix


// Add two matrices



// Subtract two matrices (left - right)



// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!



// Get translation matrix


// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians










// Get x-rotation matrix
// NOTE: Angle must be provided in radians




// Get y-rotation matrix
// NOTE: Angle must be provided in radians




// Get z-rotation matrix
// NOTE: Angle must be provided in radians





// Get xyz-rotation matrix
// NOTE: Angle must be provided in radians






// Get zyx-rotation matrix
// NOTE: Angle must be provided in radians







// Get scaling matrix


// Get perspective projection matrix







// Get perspective projection matrix
// NOTE: Fovy angle must be provided in radians


    // MatrixFrustum(-right, right, -top, top, near, far);



// Get orthographic projection matrix




// Get camera look-at matrix (view matrix)


    // Vector3Subtract(eye, target)

    // Vector3Normalize(vz)

    // Vector3CrossProduct(up, vz)

    // Vector3Normalize(x)

    // Vector3CrossProduct(vz, vx)



// Get float array of matrix data



//----------------------------------------------------------------------------------
// Module Functions Definition - Quaternion math
//----------------------------------------------------------------------------------

// Add two quaternions


// Add quaternion and float value


// Subtract two quaternions


// Subtract quaternion and float value


// Get identity quaternion


// Computes the length of a quaternion


// Normalize provided quaternion




// Invert provided quaternion





// Calculate two quaternion multiplication




// Scale quaternion by float value



// Divide two quaternions


// Calculate linear interpolation between two quaternions



// Calculate slerp-optimized interpolation between two quaternions

    // QuaternionLerp(q1, q2, amount)

    // QuaternionNormalize(q);



// Calculates spherical linear interpolation between two quaternions








// Calculate quaternion based on the rotation from one vector to another



    // QuaternionNormalize(q);
    // NOTE: Normalize to essentially nlerp the original and identity to 0.5



// Get a quaternion for a given rotation matrix








// Get a matrix for a given quaternion






// Get rotation quaternion for an angle and axis
// NOTE: Angle must be provided in radians




        // Vector3Normalize(axis)



        // QuaternionNormalize(q);


// Get the rotation angle and axis for a given quaternion
        // QuaternionNormalize(q);



        // This occurs when the angle is zero.
        // Not a problem: just set an arbitrary normalized axis.


// Get the quaternion equivalent to Euler angles
// NOTE: Rotation order is ZYX




// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
// NOTE: Angles are returned in a Vector3 struct in radians

    // Roll (x-axis rotation)

    // Pitch (y-axis rotation)

    // Yaw (z-axis rotation)


// Transform a quaternion given a transformation matrix



// Check whether two given quaternions are almost equal



