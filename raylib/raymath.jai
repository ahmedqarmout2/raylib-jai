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
Clamp :: (value: float, min: float, max: float) -> float {
    result: float = ifx (value < min) then  min else value;

    if (result > max) result = max;

    return result;
}

// Calculate linear interpolation between two floats
Lerp :: (start: float, end: float, amount: float) -> float {
    result: float = start + amount*(end - start);

    return result;
}

// Normalize input value within input range
Normalize :: (value: float, start: float, end: float) -> float {
    result: float = (value - start)/(end - start);

    return result;
}

// Remap input value within input range to output range
Remap :: (value: float, inputStart: float, inputEnd: float, outputStart: float, outputEnd: float) -> float {
    result: float = (value - inputStart)/(inputEnd - inputStart)*(outputEnd - outputStart) + outputStart;

    return result;
}

// Wrap input value from min to max
Wrap :: (value: float, min: float, max: float) -> float {
    result: float = value - (max - min)*floorf((value - min)/(max - min));

    return result;
}

// Check whether two given floats are almost equal
FloatEquals :: (x: float, y: float) -> s32 {

    result: s32 = (fabsf(x - y)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(x), fabsf(y))));

    return result;
}

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector2 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector2Zero :: () -> Vector2 {
    result: Vector2 = Vector2.{ 0.0 , 0.0  };

    return result;
}

// Vector with components value 1.0f
Vector2One :: () -> Vector2 {
    result: Vector2 = Vector2.{ 1.0 , 1.0  };

    return result;
}

// Add two vectors (v1 + v2)
Vector2Add :: (v1: Vector2, v2: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ v1.x + v2.x, v1.y + v2.y };

    return result;
}

// Add vector and float value
Vector2AddValue :: (v: Vector2, add: float) -> Vector2 {
    result: Vector2 = Vector2.{ v.x + add, v.y + add };

    return result;
}

// Subtract two vectors (v1 - v2)
Vector2Subtract :: (v1: Vector2, v2: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ v1.x - v2.x, v1.y - v2.y };

    return result;
}

// Subtract vector by float value
Vector2SubtractValue :: (v: Vector2, sub: float) -> Vector2 {
    result: Vector2 = Vector2.{ v.x - sub, v.y - sub };

    return result;
}

// Calculate vector length
Vector2Length :: (v: Vector2) -> float {
    result: float = sqrtf((v.x*v.x) + (v.y*v.y));

    return result;
}

// Calculate vector square length
Vector2LengthSqr :: (v: Vector2) -> float {
    result: float = (v.x*v.x) + (v.y*v.y);

    return result;
}

// Calculate two vectors dot product
Vector2DotProduct :: (v1: Vector2, v2: Vector2) -> float {
    result: float = (v1.x*v2.x + v1.y*v2.y);

    return result;
}

// Calculate distance between two vectors
Vector2Distance :: (v1: Vector2, v2: Vector2) -> float {
    result: float = sqrtf((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y));

    return result;
}

// Calculate square distance between two vectors
Vector2DistanceSqr :: (v1: Vector2, v2: Vector2) -> float {
    result: float = ((v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y));

    return result;
}

// Calculate angle between two vectors
// NOTE: Angle is calculated from origin point (0, 0)
Vector2Angle :: (v1: Vector2, v2: Vector2) -> float {
    result: float = 0.0 ;

    dot: float = v1.x*v2.x + v1.y*v2.y;
    det: float = v1.x*v2.y - v1.y*v2.x;

    result  = atan2f(det, dot);

    return result;
}

// Calculate angle defined by a two vectors line
// NOTE: Parameters need to be normalized
// Current implementation should be aligned with glm::angle
Vector2LineAngle :: (start: Vector2, end: Vector2) -> float {
    result: float = 0.0 ;

    // TODO(10/9/2023): Currently angles move clockwise, determine if this is wanted behavior
    result  = -atan2f(end.y - start.y, end.x - start.x);

    return result;
}

// Scale vector (multiply by value)
Vector2Scale :: (v: Vector2, scale: float) -> Vector2 {
    result: Vector2 = Vector2.{ v.x*scale, v.y*scale };

    return result;
}

// Multiply vector by vector
Vector2Multiply :: (v1: Vector2, v2: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ v1.x*v2.x, v1.y*v2.y };

    return result;
}

// Negate vector
Vector2Negate :: (v: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ -v.x, -v.y };

    return result;
}

// Divide vector by vector
Vector2Divide :: (v1: Vector2, v2: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ v1.x/v2.x, v1.y/v2.y };

    return result;
}

// Normalize provided vector
Vector2Normalize :: (v: Vector2) -> Vector2 {
    result: Vector2;
    length: float = sqrtf((v.x*v.x) + (v.y*v.y));

    if (length > 0)
    {
        ilength: float = 1.0 /length;
        result.x  = v.x*ilength;
        result.y  = v.y*ilength;
    }

    return result;
}

// Transforms a Vector2 by a given Matrix
Vector2Transform :: (v: Vector2, mat: Matrix4) -> Vector2 {
    result: Vector2;

    x: float = v.x;
    y: float = v.y;
    z: float = 0;

    result.x  = mat.m0*x + mat.m4*y + mat.m8*z + mat.m12;
    result.y  = mat.m1*x + mat.m5*y + mat.m9*z + mat.m13;

    return result;
}

// Calculate linear interpolation between two vectors
Vector2Lerp :: (v1: Vector2, v2: Vector2, amount: float) -> Vector2 {
    result: Vector2;

    result.x  = v1.x + amount*(v2.x - v1.x);
    result.y  = v1.y + amount*(v2.y - v1.y);

    return result;
}

// Calculate reflected vector to normal
Vector2Reflect :: (v: Vector2, normal: Vector2) -> Vector2 {
    result: Vector2;

    dotProduct: float = (v.x*normal.x + v.y*normal.y); // Dot product

    result.x  = v.x - (2.0 *normal.x)*dotProduct;
    result.y  = v.y - (2.0 *normal.y)*dotProduct;

    return result;
}

// Rotate vector by angle
Vector2Rotate :: (v: Vector2, angle: float) -> Vector2 {
    result: Vector2;

    cosres: float = cosf(angle);
    sinres: float = sinf(angle);

    result.x  = v.x*cosres - v.y*sinres;
    result.y  = v.x*sinres + v.y*cosres;

    return result;
}

// Move Vector towards target
Vector2MoveTowards :: (v: Vector2, target: Vector2, maxDistance: float) -> Vector2 {
    result: Vector2;

    dx: float = target.x - v.x;
    dy: float = target.y - v.y;
    value: float = (dx*dx) + (dy*dy);

    if ((value == 0) || ((maxDistance >= 0) && (value <= maxDistance*maxDistance))) return target;

    dist: float = sqrtf(value);

    result.x  = v.x + dx/dist*maxDistance;
    result.y  = v.y + dy/dist*maxDistance;

    return result;
}

// Invert the given vector
Vector2Invert :: (v: Vector2) -> Vector2 {
    result: Vector2 = Vector2.{ 1.0 /v.x, 1.0 /v.y };

    return result;
}

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector2Clamp :: (v: Vector2, min: Vector2, max: Vector2) -> Vector2 {
    result: Vector2;

    result.x  = fminf(max.x, fmaxf(min.x, v.x));
    result.y  = fminf(max.y, fmaxf(min.y, v.y));

    return result;
}

// Clamp the magnitude of the vector between two min and max values
Vector2ClampValue :: (v: Vector2, min: float, max: float) -> Vector2 {
    result: Vector2 = v;

    length: float = (v.x*v.x) + (v.y*v.y);
    if (length > 0.0 )
    {
        length  = sqrtf(length);

        if (length < min)
        {
            scale: float = min/length;
            result.x  = v.x*scale;
            result.y  = v.y*scale;
        }
        else if (length > max)
        {
            scale: float = max/length;
            result.x  = v.x*scale;
            result.y  = v.y*scale;
        }
    }

    return result;
}

// Check whether two given vectors are almost equal
Vector2Equals :: (p: Vector2, q: Vector2) -> s32 {

    result: s32 = ((fabsf(p.x - q.x)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.x), fabsf(q.x))))) &&
    ((fabsf(p.y - q.y)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.y), fabsf(q.y)))));

    return result;
}

//----------------------------------------------------------------------------------
// Module Functions Definition - Vector3 math
//----------------------------------------------------------------------------------

// Vector with components value 0.0f
Vector3Zero :: () -> Vector3 {
    result: Vector3 = Vector3.{ 0.0 , 0.0 , 0.0  };

    return result;
}

// Vector with components value 1.0f
Vector3One :: () -> Vector3 {
    result: Vector3 = Vector3.{ 1.0 , 1.0 , 1.0  };

    return result;
}

// Add two vectors
Vector3Add :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ v1.x + v2.x, v1.y + v2.y, v1.z + v2.z };

    return result;
}

// Add vector and float value
Vector3AddValue :: (v: Vector3, add: float) -> Vector3 {
    result: Vector3 = Vector3.{ v.x + add, v.y + add, v.z + add };

    return result;
}

// Subtract two vectors
Vector3Subtract :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ v1.x - v2.x, v1.y - v2.y, v1.z - v2.z };

    return result;
}

// Subtract vector by float value
Vector3SubtractValue :: (v: Vector3, sub: float) -> Vector3 {
    result: Vector3 = Vector3.{ v.x - sub, v.y - sub, v.z - sub };

    return result;
}

// Multiply vector by scalar
Vector3Scale :: (v: Vector3, scalar: float) -> Vector3 {
    result: Vector3 = Vector3.{ v.x*scalar, v.y*scalar, v.z*scalar };

    return result;
}

// Multiply vector by vector
Vector3Multiply :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ v1.x*v2.x, v1.y*v2.y, v1.z*v2.z };

    return result;
}

// Calculate two vectors cross product
Vector3CrossProduct :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x };

    return result;
}

// Calculate one vector perpendicular vector
Vector3Perpendicular :: (v: Vector3) -> Vector3 {
    result: Vector3;

    min: float = fabs(v.x);
    cardinalAxis: Vector3 = Vector3.{1.0 , 0.0 , 0.0 };

    if (fabsf(v.y) < min)
    {
        min  = fabs(v.y);
        tmp: Vector3 = Vector3.{0.0 , 1.0 , 0.0 };
        cardinalAxis  = tmp;
    }

    if (fabsf(v.z) < min)
    {
        tmp: Vector3 = Vector3.{0.0 , 0.0 , 1.0 };
        cardinalAxis  = tmp;
    }

    // Cross product between vectors
    result.x  = v.y*cardinalAxis.z - v.z*cardinalAxis.y;
    result.y  = v.z*cardinalAxis.x - v.x*cardinalAxis.z;
    result.z  = v.x*cardinalAxis.y - v.y*cardinalAxis.x;

    return result;
}

// Calculate vector length
Vector3Length :: (v: Vector3) -> float {
    result: float = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);

    return result;
}

// Calculate vector square length
Vector3LengthSqr :: (v: Vector3) -> float {
    result: float = v.x*v.x + v.y*v.y + v.z*v.z;

    return result;
}

// Calculate two vectors dot product
Vector3DotProduct :: (v1: Vector3, v2: Vector3) -> float {
    result: float = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);

    return result;
}

// Calculate distance between two vectors
Vector3Distance :: (v1: Vector3, v2: Vector3) -> float {
    result: float = 0.0 ;

    dx: float = v2.x - v1.x;
    dy: float = v2.y - v1.y;
    dz: float = v2.z - v1.z;
    result  = sqrtf(dx*dx + dy*dy + dz*dz);

    return result;
}

// Calculate square distance between two vectors
Vector3DistanceSqr :: (v1: Vector3, v2: Vector3) -> float {
    result: float = 0.0 ;

    dx: float = v2.x - v1.x;
    dy: float = v2.y - v1.y;
    dz: float = v2.z - v1.z;
    result  = dx*dx + dy*dy + dz*dz;

    return result;
}

// Calculate angle between two vectors
Vector3Angle :: (v1: Vector3, v2: Vector3) -> float {
    result: float = 0.0 ;

    cross: Vector3 = Vector3.{ v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x };
    len: float = sqrtf(cross.x*cross.x + cross.y*cross.y + cross.z*cross.z);
    dot: float = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
    result  = atan2f(len, dot);

    return result;
}

// Negate provided vector (invert direction)
Vector3Negate :: (v: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ -v.x, -v.y, -v.z };

    return result;
}

// Divide vector by vector
Vector3Divide :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ v1.x/v2.x, v1.y/v2.y, v1.z/v2.z };

    return result;
}

// Normalize provided vector
Vector3Normalize :: (v: Vector3) -> Vector3 {
    result: Vector3 = v;

    length: float = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length != 0.0 )
    {
        ilength: float = 1.0 /length;

        result.x *= ilength;
        result.y *= ilength;
        result.z *= ilength;
    }

    return result;
}

//Calculate the projection of the vector v1 on to v2
Vector3Project :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3;

    v1dv2: float = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
    v2dv2: float = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z);

    mag: float = v1dv2/v2dv2;

    result.x  = v2.x*mag;
    result.y  = v2.y*mag;
    result.z  = v2.z*mag;

    return result;
}

//Calculate the rejection of the vector v1 on to v2
Vector3Reject :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3;

    v1dv2: float = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
    v2dv2: float = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z);

    mag: float = v1dv2/v2dv2;

    result.x  = v1.x - (v2.x*mag);
    result.y  = v1.y - (v2.y*mag);
    result.z  = v1.z - (v2.z*mag);

    return result;
}

// Orthonormalize provided vectors
// Makes vectors normalized and orthogonal to each other
// Gram-Schmidt function implementation
Vector3OrthoNormalize :: (v1: *Vector3, v2: *Vector3) {
    length: float = 0.0 ;
    ilength: float = 0.0 ;

    // Vector3Normalize(*v1);
    v: Vector3 = *v1;
    length  = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0 ) length = 1.0 ;
    ilength  = 1.0 /length;
    v1.x *= ilength;
    v1.y *= ilength;
    v1.z *= ilength;

    // Vector3CrossProduct(*v1, *v2)
    vn1: Vector3 = Vector3.{ v1.y*v2.z - v1.z*v2.y, v1.z*v2.x - v1.x*v2.z, v1.x*v2.y - v1.y*v2.x };

    // Vector3Normalize(vn1);
    v  = vn1;
    length  = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0 ) length = 1.0 ;
    ilength  = 1.0 /length;
    vn1.x *= ilength;
    vn1.y *= ilength;
    vn1.z *= ilength;

    // Vector3CrossProduct(vn1, *v1)
    vn2: Vector3 = Vector3.{ vn1.y*v1.z - vn1.z*v1.y, vn1.z*v1.x - vn1.x*v1.z, vn1.x*v1.y - vn1.y*v1.x };

    *v2  = vn2;
}

// Transforms a Vector3 by a given Matrix
Vector3Transform :: (v: Vector3, mat: Matrix4) -> Vector3 {
    result: Vector3;

    x: float = v.x;
    y: float = v.y;
    z: float = v.z;

    result.x  = mat.m0*x + mat.m4*y + mat.m8*z + mat.m12;
    result.y  = mat.m1*x + mat.m5*y + mat.m9*z + mat.m13;
    result.z  = mat.m2*x + mat.m6*y + mat.m10*z + mat.m14;

    return result;
}

// Transform a vector by quaternion rotation
Vector3RotateByQuaternion :: (v: Vector3, q: Quaternion) -> Vector3 {
    result: Vector3;

    result.x  = v.x*(q.x*q.x + q.w*q.w - q.y*q.y - q.z*q.z) + v.y*(2*q.x*q.y - 2*q.w*q.z) + v.z*(2*q.x*q.z + 2*q.w*q.y);
    result.y  = v.x*(2*q.w*q.z + 2*q.x*q.y) + v.y*(q.w*q.w - q.x*q.x + q.y*q.y - q.z*q.z) + v.z*(-2*q.w*q.x + 2*q.y*q.z);
    result.z  = v.x*(-2*q.w*q.y + 2*q.x*q.z) + v.y*(2*q.w*q.x + 2*q.y*q.z)+ v.z*(q.w*q.w - q.x*q.x - q.y*q.y + q.z*q.z);

    return result;
}

// Rotates a vector around an axis
Vector3RotateByAxisAngle :: (v: Vector3, axis: Vector3, angle: float) -> Vector3 {
    // Using Euler-Rodrigues Formula
    // Ref.: https://en.wikipedia.org/w/index.php?title=Euler%E2%80%93Rodrigues_formula

    result: Vector3 = v;

    // Vector3Normalize(axis);
    length: float = sqrtf(axis.x*axis.x + axis.y*axis.y + axis.z*axis.z);
    if (length == 0.0 ) length = 1.0 ;
    ilength: float = 1.0  / length;
    axis.x *= ilength;
    axis.y *= ilength;
    axis.z *= ilength;

    angle /= 2.0 ;
    a: float = sinf(angle);
    b: float = axis.x*a;
    c: float = axis.y*a;
    d: float = axis.z*a;
    a  = cosf(angle);
    w: Vector3 = Vector3.{ b, c, d };

    // Vector3CrossProduct(w, v)
    wv: Vector3 = Vector3.{ w.y*v.z - w.z*v.y, w.z*v.x - w.x*v.z, w.x*v.y - w.y*v.x };

    // Vector3CrossProduct(w, wv)
    wwv: Vector3 = Vector3.{ w.y*wv.z - w.z*wv.y, w.z*wv.x - w.x*wv.z, w.x*wv.y - w.y*wv.x };

    // Vector3Scale(wv, 2*a)
    a *= 2;
    wv.x *= a;
    wv.y *= a;
    wv.z *= a;

    // Vector3Scale(wwv, 2)
    wwv.x *= 2;
    wwv.y *= 2;
    wwv.z *= 2;

    result.x += wv.x;
    result.y += wv.y;
    result.z += wv.z;

    result.x += wwv.x;
    result.y += wwv.y;
    result.z += wwv.z;

    return result;
}

// Calculate linear interpolation between two vectors
Vector3Lerp :: (v1: Vector3, v2: Vector3, amount: float) -> Vector3 {
    result: Vector3;

    result.x  = v1.x + amount*(v2.x - v1.x);
    result.y  = v1.y + amount*(v2.y - v1.y);
    result.z  = v1.z + amount*(v2.z - v1.z);

    return result;
}

// Calculate reflected vector to normal
Vector3Reflect :: (v: Vector3, normal: Vector3) -> Vector3 {
    result: Vector3;

    // I is the original vector
    // N is the normal of the incident plane
    // R = I - (2*N*(DotProduct[I, N]))

    dotProduct: float = (v.x*normal.x + v.y*normal.y + v.z*normal.z);

    result.x  = v.x - (2.0 *normal.x)*dotProduct;
    result.y  = v.y - (2.0 *normal.y)*dotProduct;
    result.z  = v.z - (2.0 *normal.z)*dotProduct;

    return result;
}

// Get min value for each pair of components
Vector3Min :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3;

    result.x  = fminf(v1.x, v2.x);
    result.y  = fminf(v1.y, v2.y);
    result.z  = fminf(v1.z, v2.z);

    return result;
}

// Get max value for each pair of components
Vector3Max :: (v1: Vector3, v2: Vector3) -> Vector3 {
    result: Vector3;

    result.x  = fmaxf(v1.x, v2.x);
    result.y  = fmaxf(v1.y, v2.y);
    result.z  = fmaxf(v1.z, v2.z);

    return result;
}

// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
// NOTE: Assumes P is on the plane of the triangle
Vector3Barycenter :: (p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3 {
    result: Vector3;

    v0: Vector3 = Vector3.{ b.x - a.x, b.y - a.y, b.z - a.z };   // Vector3Subtract(b, a)
    v1: Vector3 = Vector3.{ c.x - a.x, c.y - a.y, c.z - a.z };   // Vector3Subtract(c, a)
    v2: Vector3 = Vector3.{ p.x - a.x, p.y - a.y, p.z - a.z };   // Vector3Subtract(p, a)
    d00: float = (v0.x*v0.x + v0.y*v0.y + v0.z*v0.z);    // Vector3DotProduct(v0, v0)
    d01: float = (v0.x*v1.x + v0.y*v1.y + v0.z*v1.z);    // Vector3DotProduct(v0, v1)
    d11: float = (v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);    // Vector3DotProduct(v1, v1)
    d20: float = (v2.x*v0.x + v2.y*v0.y + v2.z*v0.z);    // Vector3DotProduct(v2, v0)
    d21: float = (v2.x*v1.x + v2.y*v1.y + v2.z*v1.z);    // Vector3DotProduct(v2, v1)

    denom: float = d00*d11 - d01*d01;

    result.y  = (d11*d20 - d01*d21)/denom;
    result.z  = (d00*d21 - d01*d20)/denom;
    result.x  = 1.0  - (result.z + result.y);

    return result;
}

// Projects a Vector3 from screen space into object space
// NOTE: We are avoiding calling other raymath functions despite available
Vector3Unproject :: (source: Vector3, projection: Matrix4, view: Matrix4) -> Vector3 {
    result: Vector3;

    // Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
    matViewProj: Matrix4 = Matrix4.{      // MatrixMultiply(view, projection);
        view.m0*projection.m0 + view.m1*projection.m4 + view.m2*projection.m8 + view.m3*projection.m12,
        view.m0*projection.m1 + view.m1*projection.m5 + view.m2*projection.m9 + view.m3*projection.m13,
        view.m0*projection.m2 + view.m1*projection.m6 + view.m2*projection.m10 + view.m3*projection.m14,
        view.m0*projection.m3 + view.m1*projection.m7 + view.m2*projection.m11 + view.m3*projection.m15,
        view.m4*projection.m0 + view.m5*projection.m4 + view.m6*projection.m8 + view.m7*projection.m12,
        view.m4*projection.m1 + view.m5*projection.m5 + view.m6*projection.m9 + view.m7*projection.m13,
        view.m4*projection.m2 + view.m5*projection.m6 + view.m6*projection.m10 + view.m7*projection.m14,
        view.m4*projection.m3 + view.m5*projection.m7 + view.m6*projection.m11 + view.m7*projection.m15,
        view.m8*projection.m0 + view.m9*projection.m4 + view.m10*projection.m8 + view.m11*projection.m12,
        view.m8*projection.m1 + view.m9*projection.m5 + view.m10*projection.m9 + view.m11*projection.m13,
        view.m8*projection.m2 + view.m9*projection.m6 + view.m10*projection.m10 + view.m11*projection.m14,
        view.m8*projection.m3 + view.m9*projection.m7 + view.m10*projection.m11 + view.m11*projection.m15,
        view.m12*projection.m0 + view.m13*projection.m4 + view.m14*projection.m8 + view.m15*projection.m12,
        view.m12*projection.m1 + view.m13*projection.m5 + view.m14*projection.m9 + view.m15*projection.m13,
        view.m12*projection.m2 + view.m13*projection.m6 + view.m14*projection.m10 + view.m15*projection.m14,
    view.m12*projection.m3 + view.m13*projection.m7 + view.m14*projection.m11 + view.m15*projection.m15 };

    // Calculate inverted matrix -> MatrixInvert(matViewProj);
    // Cache the matrix values (speed optimization)
    a00: float = matViewProj.m0; a01:float = matViewProj.m1; a02:float = matViewProj.m2; a03:float = matViewProj.m3;
    a10: float = matViewProj.m4; a11:float = matViewProj.m5; a12:float = matViewProj.m6; a13:float = matViewProj.m7;
    a20: float = matViewProj.m8; a21:float = matViewProj.m9; a22:float = matViewProj.m10; a23:float = matViewProj.m11;
    a30: float = matViewProj.m12; a31:float = matViewProj.m13; a32:float = matViewProj.m14; a33:float = matViewProj.m15;

    b00: float = a00*a11 - a01*a10;
    b01: float = a00*a12 - a02*a10;
    b02: float = a00*a13 - a03*a10;
    b03: float = a01*a12 - a02*a11;
    b04: float = a01*a13 - a03*a11;
    b05: float = a02*a13 - a03*a12;
    b06: float = a20*a31 - a21*a30;
    b07: float = a20*a32 - a22*a30;
    b08: float = a20*a33 - a23*a30;
    b09: float = a21*a32 - a22*a31;
    b10: float = a21*a33 - a23*a31;
    b11: float = a22*a33 - a23*a32;

    // Calculate the invert determinant (inlined to avoid double-caching)
    invDet: float = 1.0 /(b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);

    matViewProjInv: Matrix4 = Matrix4.{
        (a11*b11 - a12*b10 + a13*b09)*invDet,
        (-a01*b11 + a02*b10 - a03*b09)*invDet,
        (a31*b05 - a32*b04 + a33*b03)*invDet,
        (-a21*b05 + a22*b04 - a23*b03)*invDet,
        (-a10*b11 + a12*b08 - a13*b07)*invDet,
        (a00*b11 - a02*b08 + a03*b07)*invDet,
        (-a30*b05 + a32*b02 - a33*b01)*invDet,
        (a20*b05 - a22*b02 + a23*b01)*invDet,
        (a10*b10 - a11*b08 + a13*b06)*invDet,
        (-a00*b10 + a01*b08 - a03*b06)*invDet,
        (a30*b04 - a31*b02 + a33*b00)*invDet,
        (-a20*b04 + a21*b02 - a23*b00)*invDet,
        (-a10*b09 + a11*b07 - a12*b06)*invDet,
        (a00*b09 - a01*b07 + a02*b06)*invDet,
        (-a30*b03 + a31*b01 - a32*b00)*invDet,
    (a20*b03 - a21*b01 + a22*b00)*invDet };

    // Create quaternion from source point
    quat: Quaternion = Quaternion.{ source.x, source.y, source.z, 1.0  };

    // Multiply quat point by unprojecte matrix
    qtransformed: Quaternion = Quaternion.{     // QuaternionTransform(quat, matViewProjInv)
        matViewProjInv.m0*quat.x + matViewProjInv.m4*quat.y + matViewProjInv.m8*quat.z + matViewProjInv.m12*quat.w,
        matViewProjInv.m1*quat.x + matViewProjInv.m5*quat.y + matViewProjInv.m9*quat.z + matViewProjInv.m13*quat.w,
        matViewProjInv.m2*quat.x + matViewProjInv.m6*quat.y + matViewProjInv.m10*quat.z + matViewProjInv.m14*quat.w,
    matViewProjInv.m3*quat.x + matViewProjInv.m7*quat.y + matViewProjInv.m11*quat.z + matViewProjInv.m15*quat.w };

    // Normalized world points in vectors
    result.x  = qtransformed.x/qtransformed.w;
    result.y  = qtransformed.y/qtransformed.w;
    result.z  = qtransformed.z/qtransformed.w;

    return result;
}

// Get Vector3 as float array
Vector3ToFloatV :: (v: Vector3) -> float3 {
    buffer: float3;

    buffer.v[0]  = v.x;
    buffer.v[1]  = v.y;
    buffer.v[2]  = v.z;

    return buffer;
}

// Invert the given vector
Vector3Invert :: (v: Vector3) -> Vector3 {
    result: Vector3 = Vector3.{ 1.0 /v.x, 1.0 /v.y, 1.0 /v.z };

    return result;
}

// Clamp the components of the vector between
// min and max values specified by the given vectors
Vector3Clamp :: (v: Vector3, min: Vector3, max: Vector3) -> Vector3 {
    result: Vector3;

    result.x  = fminf(max.x, fmaxf(min.x, v.x));
    result.y  = fminf(max.y, fmaxf(min.y, v.y));
    result.z  = fminf(max.z, fmaxf(min.z, v.z));

    return result;
}

// Clamp the magnitude of the vector between two values
Vector3ClampValue :: (v: Vector3, min: float, max: float) -> Vector3 {
    result: Vector3 = v;

    length: float = (v.x*v.x) + (v.y*v.y) + (v.z*v.z);
    if (length > 0.0 )
    {
        length  = sqrtf(length);

        if (length < min)
        {
            scale: float = min/length;
            result.x  = v.x*scale;
            result.y  = v.y*scale;
            result.z  = v.z*scale;
        }
        else if (length > max)
        {
            scale: float = max/length;
            result.x  = v.x*scale;
            result.y  = v.y*scale;
            result.z  = v.z*scale;
        }
    }

    return result;
}

// Check whether two given vectors are almost equal
Vector3Equals :: (p: Vector3, q: Vector3) -> s32 {

    result: s32 = ((fabsf(p.x - q.x)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.x), fabsf(q.x))))) &&
    ((fabsf(p.y - q.y)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.y), fabsf(q.y))))) &&
    ((fabsf(p.z - q.z)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.z), fabsf(q.z)))));

    return result;
}

// Compute the direction of a refracted ray
// v: normalized direction of the incoming ray
// n: normalized normal vector of the interface of two optical media
// r: ratio of the refractive index of the medium from where the ray comes
//    to the refractive index of the medium on the other side of the surface
Vector3Refract :: (v: Vector3, n: Vector3, r: float) -> Vector3 {
    result: Vector3;

    dot: float = v.x*n.x + v.y*n.y + v.z*n.z;
    d: float = 1.0  - r*r*(1.0  - dot*dot);

    if (d >= 0.0 )
    {
        d  = sqrtf(d);
        v.x  = r*v.x - (r*dot + d)*n.x;
        v.y  = r*v.y - (r*dot + d)*n.y;
        v.z  = r*v.z - (r*dot + d)*n.z;

        result  = v;
    }

    return result;
}

//----------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//----------------------------------------------------------------------------------

// Compute matrix determinant
MatrixDeterminant :: (mat: Matrix4) -> float {
    result: float = 0.0 ;

    // Cache the matrix values (speed optimization)
    a00: float = mat.m0; a01:float = mat.m1; a02:float = mat.m2; a03:float = mat.m3;
    a10: float = mat.m4; a11:float = mat.m5; a12:float = mat.m6; a13:float = mat.m7;
    a20: float = mat.m8; a21:float = mat.m9; a22:float = mat.m10; a23:float = mat.m11;
    a30: float = mat.m12; a31:float = mat.m13; a32:float = mat.m14; a33:float = mat.m15;

    result  = a30*a21*a12*a03 - a20*a31*a12*a03 - a30*a11*a22*a03 + a10*a31*a22*a03 +
    a20*a11*a32*a03 - a10*a21*a32*a03 - a30*a21*a02*a13 + a20*a31*a02*a13 +
    a30*a01*a22*a13 - a00*a31*a22*a13 - a20*a01*a32*a13 + a00*a21*a32*a13 +
    a30*a11*a02*a23 - a10*a31*a02*a23 - a30*a01*a12*a23 + a00*a31*a12*a23 +
    a10*a01*a32*a23 - a00*a11*a32*a23 - a20*a11*a02*a33 + a10*a21*a02*a33 +
    a20*a01*a12*a33 - a00*a21*a12*a33 - a10*a01*a22*a33 + a00*a11*a22*a33;

    return result;
}

// Get the trace of the matrix (sum of the values along the diagonal)
MatrixTrace :: (mat: Matrix4) -> float {
    result: float = (mat.m0 + mat.m5 + mat.m10 + mat.m15);

    return result;
}

// Transposes provided matrix
MatrixTranspose :: (mat: Matrix4) -> Matrix4 {
    result: Matrix4;

    result.m0  = mat.m0;
    result.m1  = mat.m4;
    result.m2  = mat.m8;
    result.m3  = mat.m12;
    result.m4  = mat.m1;
    result.m5  = mat.m5;
    result.m6  = mat.m9;
    result.m7  = mat.m13;
    result.m8  = mat.m2;
    result.m9  = mat.m6;
    result.m10  = mat.m10;
    result.m11  = mat.m14;
    result.m12  = mat.m3;
    result.m13  = mat.m7;
    result.m14  = mat.m11;
    result.m15  = mat.m15;

    return result;
}

// Invert provided matrix
MatrixInvert :: (mat: Matrix4) -> Matrix4 {
    result: Matrix4;

    // Cache the matrix values (speed optimization)
    a00: float = mat.m0; a01:float = mat.m1; a02:float = mat.m2; a03:float = mat.m3;
    a10: float = mat.m4; a11:float = mat.m5; a12:float = mat.m6; a13:float = mat.m7;
    a20: float = mat.m8; a21:float = mat.m9; a22:float = mat.m10; a23:float = mat.m11;
    a30: float = mat.m12; a31:float = mat.m13; a32:float = mat.m14; a33:float = mat.m15;

    b00: float = a00*a11 - a01*a10;
    b01: float = a00*a12 - a02*a10;
    b02: float = a00*a13 - a03*a10;
    b03: float = a01*a12 - a02*a11;
    b04: float = a01*a13 - a03*a11;
    b05: float = a02*a13 - a03*a12;
    b06: float = a20*a31 - a21*a30;
    b07: float = a20*a32 - a22*a30;
    b08: float = a20*a33 - a23*a30;
    b09: float = a21*a32 - a22*a31;
    b10: float = a21*a33 - a23*a31;
    b11: float = a22*a33 - a23*a32;

    // Calculate the invert determinant (inlined to avoid double-caching)
    invDet: float = 1.0 /(b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);

    result.m0  = (a11*b11 - a12*b10 + a13*b09)*invDet;
    result.m1  = (-a01*b11 + a02*b10 - a03*b09)*invDet;
    result.m2  = (a31*b05 - a32*b04 + a33*b03)*invDet;
    result.m3  = (-a21*b05 + a22*b04 - a23*b03)*invDet;
    result.m4  = (-a10*b11 + a12*b08 - a13*b07)*invDet;
    result.m5  = (a00*b11 - a02*b08 + a03*b07)*invDet;
    result.m6  = (-a30*b05 + a32*b02 - a33*b01)*invDet;
    result.m7  = (a20*b05 - a22*b02 + a23*b01)*invDet;
    result.m8  = (a10*b10 - a11*b08 + a13*b06)*invDet;
    result.m9  = (-a00*b10 + a01*b08 - a03*b06)*invDet;
    result.m10  = (a30*b04 - a31*b02 + a33*b00)*invDet;
    result.m11  = (-a20*b04 + a21*b02 - a23*b00)*invDet;
    result.m12  = (-a10*b09 + a11*b07 - a12*b06)*invDet;
    result.m13  = (a00*b09 - a01*b07 + a02*b06)*invDet;
    result.m14  = (-a30*b03 + a31*b01 - a32*b00)*invDet;
    result.m15  = (a20*b03 - a21*b01 + a22*b00)*invDet;

    return result;
}

// Get identity matrix
MatrixIdentity :: () -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  };

    return result;
}

// Add two matrices
MatrixAdd :: (left: Matrix4, right: Matrix4) -> Matrix4 {
    result: Matrix4;

    result.m0  = left.m0 + right.m0;
    result.m1  = left.m1 + right.m1;
    result.m2  = left.m2 + right.m2;
    result.m3  = left.m3 + right.m3;
    result.m4  = left.m4 + right.m4;
    result.m5  = left.m5 + right.m5;
    result.m6  = left.m6 + right.m6;
    result.m7  = left.m7 + right.m7;
    result.m8  = left.m8 + right.m8;
    result.m9  = left.m9 + right.m9;
    result.m10  = left.m10 + right.m10;
    result.m11  = left.m11 + right.m11;
    result.m12  = left.m12 + right.m12;
    result.m13  = left.m13 + right.m13;
    result.m14  = left.m14 + right.m14;
    result.m15  = left.m15 + right.m15;

    return result;
}

// Subtract two matrices (left - right)
MatrixSubtract :: (left: Matrix4, right: Matrix4) -> Matrix4 {
    result: Matrix4;

    result.m0  = left.m0 - right.m0;
    result.m1  = left.m1 - right.m1;
    result.m2  = left.m2 - right.m2;
    result.m3  = left.m3 - right.m3;
    result.m4  = left.m4 - right.m4;
    result.m5  = left.m5 - right.m5;
    result.m6  = left.m6 - right.m6;
    result.m7  = left.m7 - right.m7;
    result.m8  = left.m8 - right.m8;
    result.m9  = left.m9 - right.m9;
    result.m10  = left.m10 - right.m10;
    result.m11  = left.m11 - right.m11;
    result.m12  = left.m12 - right.m12;
    result.m13  = left.m13 - right.m13;
    result.m14  = left.m14 - right.m14;
    result.m15  = left.m15 - right.m15;

    return result;
}

// Get two matrix multiplication
// NOTE: When multiplying matrices... the order matters!
MatrixMultiply :: (left: Matrix4, right: Matrix4) -> Matrix4 {
    result: Matrix4;

    result.m0  = left.m0*right.m0 + left.m1*right.m4 + left.m2*right.m8 + left.m3*right.m12;
    result.m1  = left.m0*right.m1 + left.m1*right.m5 + left.m2*right.m9 + left.m3*right.m13;
    result.m2  = left.m0*right.m2 + left.m1*right.m6 + left.m2*right.m10 + left.m3*right.m14;
    result.m3  = left.m0*right.m3 + left.m1*right.m7 + left.m2*right.m11 + left.m3*right.m15;
    result.m4  = left.m4*right.m0 + left.m5*right.m4 + left.m6*right.m8 + left.m7*right.m12;
    result.m5  = left.m4*right.m1 + left.m5*right.m5 + left.m6*right.m9 + left.m7*right.m13;
    result.m6  = left.m4*right.m2 + left.m5*right.m6 + left.m6*right.m10 + left.m7*right.m14;
    result.m7  = left.m4*right.m3 + left.m5*right.m7 + left.m6*right.m11 + left.m7*right.m15;
    result.m8  = left.m8*right.m0 + left.m9*right.m4 + left.m10*right.m8 + left.m11*right.m12;
    result.m9  = left.m8*right.m1 + left.m9*right.m5 + left.m10*right.m9 + left.m11*right.m13;
    result.m10  = left.m8*right.m2 + left.m9*right.m6 + left.m10*right.m10 + left.m11*right.m14;
    result.m11  = left.m8*right.m3 + left.m9*right.m7 + left.m10*right.m11 + left.m11*right.m15;
    result.m12  = left.m12*right.m0 + left.m13*right.m4 + left.m14*right.m8 + left.m15*right.m12;
    result.m13  = left.m12*right.m1 + left.m13*right.m5 + left.m14*right.m9 + left.m15*right.m13;
    result.m14  = left.m12*right.m2 + left.m13*right.m6 + left.m14*right.m10 + left.m15*right.m14;
    result.m15  = left.m12*right.m3 + left.m13*right.m7 + left.m14*right.m11 + left.m15*right.m15;

    return result;
}

// Get translation matrix
MatrixTranslate :: (x: float, y: float, z: float) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , x,
        0.0 , 1.0 , 0.0 , y,
        0.0 , 0.0 , 1.0 , z,
    0.0 , 0.0 , 0.0 , 1.0  };

    return result;
}

// Create rotation matrix from axis and angle
// NOTE: Angle should be provided in radians
MatrixRotate :: (axis: Vector3, angle: float) -> Matrix4 {
    result: Matrix4;

    x: float = axis.x; y:float = axis.y; z:float = axis.z;

    lengthSquared: float = x*x + y*y + z*z;

    if ((lengthSquared != 1.0 ) && (lengthSquared != 0.0 ))
    {
        ilength: float = 1.0 /sqrtf(lengthSquared);
        x *= ilength;
        y *= ilength;
        z *= ilength;
    }

    sinres: float = sinf(angle);
    cosres: float = cosf(angle);
    t: float = 1.0  - cosres;

    result.m0  = x*x*t + cosres;
    result.m1  = y*x*t + z*sinres;
    result.m2  = z*x*t - y*sinres;
    result.m3  = 0.0 ;

    result.m4  = x*y*t - z*sinres;
    result.m5  = y*y*t + cosres;
    result.m6  = z*y*t + x*sinres;
    result.m7  = 0.0 ;

    result.m8  = x*z*t + y*sinres;
    result.m9  = y*z*t - x*sinres;
    result.m10  = z*z*t + cosres;
    result.m11  = 0.0 ;

    result.m12  = 0.0 ;
    result.m13  = 0.0 ;
    result.m14  = 0.0 ;
    result.m15  = 1.0 ;

    return result;
}

// Get x-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateX :: (angle: float) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  }; // MatrixIdentity()

    cosres: float = cosf(angle);
    sinres: float = sinf(angle);

    result.m5  = cosres;
    result.m6  = sinres;
    result.m9  = -sinres;
    result.m10  = cosres;

    return result;
}

// Get y-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateY :: (angle: float) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  }; // MatrixIdentity()

    cosres: float = cosf(angle);
    sinres: float = sinf(angle);

    result.m0  = cosres;
    result.m2  = -sinres;
    result.m8  = sinres;
    result.m10  = cosres;

    return result;
}

// Get z-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateZ :: (angle: float) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  }; // MatrixIdentity()

    cosres: float = cosf(angle);
    sinres: float = sinf(angle);

    result.m0  = cosres;
    result.m1  = sinres;
    result.m4  = -sinres;
    result.m5  = cosres;

    return result;
}


// Get xyz-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateXYZ :: (angle: Vector3) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  }; // MatrixIdentity()

    cosz: float = cosf(-angle.z);
    sinz: float = sinf(-angle.z);
    cosy: float = cosf(-angle.y);
    siny: float = sinf(-angle.y);
    cosx: float = cosf(-angle.x);
    sinx: float = sinf(-angle.x);

    result.m0  = cosz*cosy;
    result.m1  = (cosz*siny*sinx) - (sinz*cosx);
    result.m2  = (cosz*siny*cosx) + (sinz*sinx);

    result.m4  = sinz*cosy;
    result.m5  = (sinz*siny*sinx) + (cosz*cosx);
    result.m6  = (sinz*siny*cosx) - (cosz*sinx);

    result.m8  = -siny;
    result.m9  = cosy*sinx;
    result.m10= cosy*cosx;

    return result;
}

// Get zyx-rotation matrix
// NOTE: Angle must be provided in radians
MatrixRotateZYX :: (angle: Vector3) -> Matrix4 {
    result: Matrix4;

    cz: float = cosf(angle.z);
    sz: float = sinf(angle.z);
    cy: float = cosf(angle.y);
    sy: float = sinf(angle.y);
    cx: float = cosf(angle.x);
    sx: float = sinf(angle.x);

    result.m0  = cz*cy;
    result.m4  = cz*sy*sx - cx*sz;
    result.m8  = sz*sx + cz*cx*sy;
    result.m12  = 0;

    result.m1  = cy*sz;
    result.m5  = cz*cx + sz*sy*sx;
    result.m9  = cx*sz*sy - cz*sx;
    result.m13  = 0;

    result.m2  = -sy;
    result.m6  = cy*sx;
    result.m10  = cy*cx;
    result.m14  = 0;

    result.m3  = 0;
    result.m7  = 0;
    result.m11  = 0;
    result.m15  = 1;

    return result;
}

// Get scaling matrix
MatrixScale :: (x: float, y: float, z: float) -> Matrix4 {
    result: Matrix4 = Matrix4.{ x, 0.0 , 0.0 , 0.0 ,
        0.0 , y, 0.0 , 0.0 ,
        0.0 , 0.0 , z, 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  };

    return result;
}

// Get perspective projection matrix
MatrixFrustum :: (left: float64, right: float64, bottom: float64, top: float64, near: float64, far: float64) -> Matrix4 {
    result: Matrix4;

    rl: float = (right - left);
    tb: float = (top - bottom);
    fn: float = (far - near);

    result.m0  = (near*2.0 )/rl;
    result.m1  = 0.0 ;
    result.m2  = 0.0 ;
    result.m3  = 0.0 ;

    result.m4  = 0.0 ;
    result.m5  = (near*2.0 )/tb;
    result.m6  = 0.0 ;
    result.m7  = 0.0 ;

    result.m8  = (right + left)/rl;
    result.m9  = (top + bottom)/tb;
    result.m10  = -(far + near)/fn;
    result.m11  = -1.0 ;

    result.m12  = 0.0 ;
    result.m13  = 0.0 ;
    result.m14  = -(far*near*2.0 )/fn;
    result.m15  = 0.0 ;

    return result;
}

// Get perspective projection matrix
// NOTE: Fovy angle must be provided in radians
MatrixPerspective :: (fovY: float64, aspect: float64, nearPlane: float64, farPlane: float64) -> Matrix4 {
    result: Matrix4;

    top: float64 = nearPlane*tan(fovY*0.5);
    bottom: float64 = -top;
    right: float64 = top*aspect;
    left: float64 = -right;

    // MatrixFrustum(-right, right, -top, top, near, far);
    rl: float = (right - left);
    tb: float = (top - bottom);
    fn: float = (farPlane - nearPlane);

    result.m0  = (nearPlane*2.0 )/rl;
    result.m5  = (nearPlane*2.0 )/tb;
    result.m8  = (right + left)/rl;
    result.m9  = (top + bottom)/tb;
    result.m10  = -(farPlane + nearPlane)/fn;
    result.m11  = -1.0 ;
    result.m14  = -(farPlane*nearPlane*2.0 )/fn;

    return result;
}

// Get orthographic projection matrix
MatrixOrtho :: (left: float64, right: float64, bottom: float64, top: float64, nearPlane: float64, farPlane: float64) -> Matrix4 {
    result: Matrix4;

    rl: float = (right - left);
    tb: float = (top - bottom);
    fn: float = (farPlane - nearPlane);

    result.m0  = 2.0 /rl;
    result.m1  = 0.0 ;
    result.m2  = 0.0 ;
    result.m3  = 0.0 ;
    result.m4  = 0.0 ;
    result.m5  = 2.0 /tb;
    result.m6  = 0.0 ;
    result.m7  = 0.0 ;
    result.m8  = 0.0 ;
    result.m9  = 0.0 ;
    result.m10  = -2.0 /fn;
    result.m11  = 0.0 ;
    result.m12  = -(left + right)/rl;
    result.m13  = -(top + bottom)/tb;
    result.m14  = -(farPlane + nearPlane)/fn;
    result.m15  = 1.0 ;

    return result;
}

// Get camera look-at matrix (view matrix)
MatrixLookAt :: (eye: Vector3, target: Vector3, up: Vector3) -> Matrix4 {
    result: Matrix4;

    length: float = 0.0 ;
    ilength: float = 0.0 ;

    // Vector3Subtract(eye, target)
    vz: Vector3 = Vector3.{ eye.x - target.x, eye.y - target.y, eye.z - target.z };

    // Vector3Normalize(vz)
    v: Vector3 = vz;
    length  = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0 ) length = 1.0 ;
    ilength  = 1.0 /length;
    vz.x *= ilength;
    vz.y *= ilength;
    vz.z *= ilength;

    // Vector3CrossProduct(up, vz)
    vx: Vector3 = Vector3.{ up.y*vz.z - up.z*vz.y, up.z*vz.x - up.x*vz.z, up.x*vz.y - up.y*vz.x };

    // Vector3Normalize(x)
    v  = vx;
    length  = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0 ) length = 1.0 ;
    ilength  = 1.0 /length;
    vx.x *= ilength;
    vx.y *= ilength;
    vx.z *= ilength;

    // Vector3CrossProduct(vz, vx)
    vy: Vector3 = Vector3.{ vz.y*vx.z - vz.z*vx.y, vz.z*vx.x - vz.x*vx.z, vz.x*vx.y - vz.y*vx.x };

    result.m0  = vx.x;
    result.m1  = vy.x;
    result.m2  = vz.x;
    result.m3  = 0.0 ;
    result.m4  = vx.y;
    result.m5  = vy.y;
    result.m6  = vz.y;
    result.m7  = 0.0 ;
    result.m8  = vx.z;
    result.m9  = vy.z;
    result.m10  = vz.z;
    result.m11  = 0.0 ;
    result.m12  = -(vx.x*eye.x + vx.y*eye.y + vx.z*eye.z);   // Vector3DotProduct(vx, eye)
    result.m13  = -(vy.x*eye.x + vy.y*eye.y + vy.z*eye.z);   // Vector3DotProduct(vy, eye)
    result.m14  = -(vz.x*eye.x + vz.y*eye.y + vz.z*eye.z);   // Vector3DotProduct(vz, eye)
    result.m15  = 1.0 ;

    return result;
}

// Get float array of matrix data
MatrixToFloatV :: (mat: Matrix4) -> float16 {
    result: float16;

    result.v[0]  = mat.m0;
    result.v[1]  = mat.m1;
    result.v[2]  = mat.m2;
    result.v[3]  = mat.m3;
    result.v[4]  = mat.m4;
    result.v[5]  = mat.m5;
    result.v[6]  = mat.m6;
    result.v[7]  = mat.m7;
    result.v[8]  = mat.m8;
    result.v[9]  = mat.m9;
    result.v[10]  = mat.m10;
    result.v[11]  = mat.m11;
    result.v[12]  = mat.m12;
    result.v[13]  = mat.m13;
    result.v[14]  = mat.m14;
    result.v[15]  = mat.m15;

    return result;
}

//----------------------------------------------------------------------------------
// Module Functions Definition - Quaternion math
//----------------------------------------------------------------------------------

// Add two quaternions
QuaternionAdd :: (q1: Quaternion, q2: Quaternion) -> Quaternion {
    result: Quaternion = Quaternion.{q1.x + q2.x, q1.y + q2.y, q1.z + q2.z, q1.w + q2.w};

    return result;
}

// Add quaternion and float value
QuaternionAddValue :: (q: Quaternion, add: float) -> Quaternion {
    result: Quaternion = Quaternion.{q.x + add, q.y + add, q.z + add, q.w + add};

    return result;
}

// Subtract two quaternions
QuaternionSubtract :: (q1: Quaternion, q2: Quaternion) -> Quaternion {
    result: Quaternion = Quaternion.{q1.x - q2.x, q1.y - q2.y, q1.z - q2.z, q1.w - q2.w};

    return result;
}

// Subtract quaternion and float value
QuaternionSubtractValue :: (q: Quaternion, sub: float) -> Quaternion {
    result: Quaternion = Quaternion.{q.x - sub, q.y - sub, q.z - sub, q.w - sub};

    return result;
}

// Get identity quaternion
QuaternionIdentity :: () -> Quaternion {
    result: Quaternion = Quaternion.{ 0.0 , 0.0 , 0.0 , 1.0  };

    return result;
}

// Computes the length of a quaternion
QuaternionLength :: (q: Quaternion) -> float {
    result: float = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);

    return result;
}

// Normalize provided quaternion
QuaternionNormalize :: (q: Quaternion) -> Quaternion {
    result: Quaternion;

    length: float = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
    if (length == 0.0 ) length = 1.0 ;
    ilength: float = 1.0 /length;

    result.x  = q.x*ilength;
    result.y  = q.y*ilength;
    result.z  = q.z*ilength;
    result.w  = q.w*ilength;

    return result;
}

// Invert provided quaternion
QuaternionInvert :: (q: Quaternion) -> Quaternion {
    result: Quaternion = q;

    lengthSq: float = q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w;

    if (lengthSq != 0.0 )
    {
        invLength: float = 1.0 /lengthSq;

        result.x *= -invLength;
        result.y *= -invLength;
        result.z *= -invLength;
        result.w *= invLength;
    }

    return result;
}

// Calculate two quaternion multiplication
QuaternionMultiply :: (q1: Quaternion, q2: Quaternion) -> Quaternion {
    result: Quaternion;

    qax: float = q1.x; qay:float = q1.y; qaz:float = q1.z; qaw:float = q1.w;
    qbx: float = q2.x; qby:float = q2.y; qbz:float = q2.z; qbw:float = q2.w;

    result.x  = qax*qbw + qaw*qbx + qay*qbz - qaz*qby;
    result.y  = qay*qbw + qaw*qby + qaz*qbx - qax*qbz;
    result.z  = qaz*qbw + qaw*qbz + qax*qby - qay*qbx;
    result.w  = qaw*qbw - qax*qbx - qay*qby - qaz*qbz;

    return result;
}

// Scale quaternion by float value
QuaternionScale :: (q: Quaternion, mul: float) -> Quaternion {
    result: Quaternion;

    result.x  = q.x*mul;
    result.y  = q.y*mul;
    result.z  = q.z*mul;
    result.w  = q.w*mul;

    return result;
}

// Divide two quaternions
QuaternionDivide :: (q1: Quaternion, q2: Quaternion) -> Quaternion {
    result: Quaternion = Quaternion.{ q1.x/q2.x, q1.y/q2.y, q1.z/q2.z, q1.w/q2.w };

    return result;
}

// Calculate linear interpolation between two quaternions
QuaternionLerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion {
    result: Quaternion;

    result.x  = q1.x + amount*(q2.x - q1.x);
    result.y  = q1.y + amount*(q2.y - q1.y);
    result.z  = q1.z + amount*(q2.z - q1.z);
    result.w  = q1.w + amount*(q2.w - q1.w);

    return result;
}

// Calculate slerp-optimized interpolation between two quaternions
QuaternionNlerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion {
    result: Quaternion;

    // QuaternionLerp(q1, q2, amount)
    result.x  = q1.x + amount*(q2.x - q1.x);
    result.y  = q1.y + amount*(q2.y - q1.y);
    result.z  = q1.z + amount*(q2.z - q1.z);
    result.w  = q1.w + amount*(q2.w - q1.w);

    // QuaternionNormalize(q);
    q: Quaternion = result;
    length: float = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
    if (length == 0.0 ) length = 1.0 ;
    ilength: float = 1.0 /length;

    result.x  = q.x*ilength;
    result.y  = q.y*ilength;
    result.z  = q.z*ilength;
    result.w  = q.w*ilength;

    return result;
}

// Calculates spherical linear interpolation between two quaternions
QuaternionSlerp :: (q1: Quaternion, q2: Quaternion, amount: float) -> Quaternion {
    result: Quaternion;


    cosHalfTheta: float = q1.x*q2.x + q1.y*q2.y + q1.z*q2.z + q1.w*q2.w;

    if (cosHalfTheta < 0)
    {
        q2.x  = -q2.x; q2.y = -q2.y; q2.z = -q2.z; q2.w = -q2.w;
        cosHalfTheta  = -cosHalfTheta;
    }

    if (fabsf(cosHalfTheta) >= 1.0 ) result = q1;
    else if (cosHalfTheta > 0.95 ) result = QuaternionNlerp(q1, q2, amount);
    else
    {
        halfTheta: float = acosf(cosHalfTheta);
        sinHalfTheta: float = sqrtf(1.0  - cosHalfTheta*cosHalfTheta);

        if (fabsf(sinHalfTheta) < EPSILON)
        {
            result.x  = (q1.x*0.5  + q2.x*0.5 );
            result.y  = (q1.y*0.5  + q2.y*0.5 );
            result.z  = (q1.z*0.5  + q2.z*0.5 );
            result.w  = (q1.w*0.5  + q2.w*0.5 );
        }
        else
        {
            ratioA: float = sinf((1 - amount)*halfTheta)/sinHalfTheta;
            ratioB: float = sinf(amount*halfTheta)/sinHalfTheta;

            result.x  = (q1.x*ratioA + q2.x*ratioB);
            result.y  = (q1.y*ratioA + q2.y*ratioB);
            result.z  = (q1.z*ratioA + q2.z*ratioB);
            result.w  = (q1.w*ratioA + q2.w*ratioB);
        }
    }

    return result;
}

// Calculate quaternion based on the rotation from one vector to another
QuaternionFromVector3ToVector3 :: (from: Vector3, to: Vector3) -> Quaternion {
    result: Quaternion;

    cos2Theta: float = (from.x*to.x + from.y*to.y + from.z*to.z);    // Vector3DotProduct(from, to)
    cross: Vector3 = Vector3.{ from.y*to.z - from.z*to.y, from.z*to.x - from.x*to.z, from.x*to.y - from.y*to.x }; // Vector3CrossProduct(from, to)

    result.x  = cross.x;
    result.y  = cross.y;
    result.z  = cross.z;
    result.w  = 1.0  + cos2Theta;

    // QuaternionNormalize(q);
    // NOTE: Normalize to essentially nlerp the original and identity to 0.5
    q: Quaternion = result;
    length: float = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
    if (length == 0.0 ) length = 1.0 ;
    ilength: float = 1.0 /length;

    result.x  = q.x*ilength;
    result.y  = q.y*ilength;
    result.z  = q.z*ilength;
    result.w  = q.w*ilength;

    return result;
}

// Get a quaternion for a given rotation matrix
QuaternionFromMatrix :: (mat: Matrix4) -> Quaternion {
    result: Quaternion;

    fourWSquaredMinus1: float = mat.m0  + mat.m5 + mat.m10;
    fourXSquaredMinus1: float = mat.m0  - mat.m5 - mat.m10;
    fourYSquaredMinus1: float = mat.m5  - mat.m0 - mat.m10;
    fourZSquaredMinus1: float = mat.m10 - mat.m0 - mat.m5;

    biggestIndex: s32 = 0;
    fourBiggestSquaredMinus1: float = fourWSquaredMinus1;
    if (fourXSquaredMinus1 > fourBiggestSquaredMinus1)
    {
        fourBiggestSquaredMinus1  = fourXSquaredMinus1;
        biggestIndex  = 1;
    }

    if (fourYSquaredMinus1 > fourBiggestSquaredMinus1)
    {
        fourBiggestSquaredMinus1  = fourYSquaredMinus1;
        biggestIndex  = 2;
    }

    if (fourZSquaredMinus1 > fourBiggestSquaredMinus1)
    {
        fourBiggestSquaredMinus1  = fourZSquaredMinus1;
        biggestIndex  = 3;
    }

    biggestVal: float = sqrtf(fourBiggestSquaredMinus1 + 1.0 )*0.5 ;
    mult: float = 0.25  / biggestVal;

    if biggestIndex ==
    {
        case 0;
        result.w  = biggestVal;
        result.x  = (mat.m6 - mat.m9)*mult;
        result.y  = (mat.m8 - mat.m2)*mult;
        result.z  = (mat.m1 - mat.m4)*mult;
        
        case 1;
        result.x  = biggestVal;
        result.w  = (mat.m6 - mat.m9)*mult;
        result.y  = (mat.m1 + mat.m4)*mult;
        result.z  = (mat.m8 + mat.m2)*mult;
        
        case 2;
        result.y  = biggestVal;
        result.w  = (mat.m8 - mat.m2)*mult;
        result.x  = (mat.m1 + mat.m4)*mult;
        result.z  = (mat.m6 + mat.m9)*mult;
        
        case 3;
        result.z  = biggestVal;
        result.w  = (mat.m1 - mat.m4)*mult;
        result.x  = (mat.m8 + mat.m2)*mult;
        result.y  = (mat.m6 + mat.m9)*mult;
        
    }

    return result;
}

// Get a matrix for a given quaternion
QuaternionToMatrix :: (q: Quaternion) -> Matrix4 {
    result: Matrix4 = Matrix4.{ 1.0 , 0.0 , 0.0 , 0.0 ,
        0.0 , 1.0 , 0.0 , 0.0 ,
        0.0 , 0.0 , 1.0 , 0.0 ,
    0.0 , 0.0 , 0.0 , 1.0  }; // MatrixIdentity()

    a2: float = q.x*q.x;
    b2: float = q.y*q.y;
    c2: float = q.z*q.z;
    ac: float = q.x*q.z;
    ab: float = q.x*q.y;
    bc: float = q.y*q.z;
    ad: float = q.w*q.x;
    bd: float = q.w*q.y;
    cd: float = q.w*q.z;

    result.m0  = 1 - 2*(b2 + c2);
    result.m1  = 2*(ab + cd);
    result.m2  = 2*(ac - bd);

    result.m4  = 2*(ab - cd);
    result.m5  = 1 - 2*(a2 + c2);
    result.m6  = 2*(bc + ad);

    result.m8  = 2*(ac + bd);
    result.m9  = 2*(bc - ad);
    result.m10  = 1 - 2*(a2 + b2);

    return result;
}

// Get rotation quaternion for an angle and axis
// NOTE: Angle must be provided in radians
QuaternionFromAxisAngle :: (axis: Vector3, angle: float) -> Quaternion {
    result: Quaternion = Quaternion.{ 0.0 , 0.0 , 0.0 , 1.0  };

    axisLength: float = sqrtf(axis.x*axis.x + axis.y*axis.y + axis.z*axis.z);

    if (axisLength != 0.0 )
    {
        angle *= 0.5 ;

        length: float = 0.0 ;
        ilength: float = 0.0 ;

        // Vector3Normalize(axis)
        v: Vector3 = axis;
        length  = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
        if (length == 0.0 ) length = 1.0 ;
        ilength  = 1.0 /length;
        axis.x *= ilength;
        axis.y *= ilength;
        axis.z *= ilength;

        sinres: float = sinf(angle);
        cosres: float = cosf(angle);

        result.x  = axis.x*sinres;
        result.y  = axis.y*sinres;
        result.z  = axis.z*sinres;
        result.w  = cosres;

        // QuaternionNormalize(q);
        q: Quaternion = result;
        length  = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
        if (length == 0.0 ) length = 1.0 ;
        ilength  = 1.0 /length;
        result.x  = q.x*ilength;
        result.y  = q.y*ilength;
        result.z  = q.z*ilength;
        result.w  = q.w*ilength;
    }

    return result;
}

// Get the rotation angle and axis for a given quaternion
QuaternionToAxisAngle :: (q: Quaternion, outAxis: *Vector3, outAngle: *float) {
    if (fabsf(q.w) > 1.0 )
    {
        // QuaternionNormalize(q);
        length: float = sqrtf(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
        if (length == 0.0 ) length = 1.0 ;
        ilength: float = 1.0 /length;

        q.x  = q.x*ilength;
        q.y  = q.y*ilength;
        q.z  = q.z*ilength;
        q.w  = q.w*ilength;
    }

    resAxis: Vector3 = Vector3.{ 0.0 , 0.0 , 0.0  };
    resAngle: float = 2.0 *acosf(q.w);
    den: float = sqrtf(1.0  - q.w*q.w);

    if (den > EPSILON)
    {
        resAxis.x  = q.x/den;
        resAxis.y  = q.y/den;
        resAxis.z  = q.z/den;
    }
    else
    {
        // This occurs when the angle is zero.
        // Not a problem: just set an arbitrary normalized axis.
        resAxis.x  = 1.0 ;
    }

    *outAxis  = resAxis;
    *outAngle  = resAngle;
}

// Get the quaternion equivalent to Euler angles
// NOTE: Rotation order is ZYX
QuaternionFromEuler :: (pitch: float, yaw: float, roll: float) -> Quaternion {
    result: Quaternion;

    x0: float = cosf(pitch*0.5 );
    x1: float = sinf(pitch*0.5 );
    y0: float = cosf(yaw*0.5 );
    y1: float = sinf(yaw*0.5 );
    z0: float = cosf(roll*0.5 );
    z1: float = sinf(roll*0.5 );

    result.x  = x1*y0*z0 - x0*y1*z1;
    result.y  = x0*y1*z0 + x1*y0*z1;
    result.z  = x0*y0*z1 - x1*y1*z0;
    result.w  = x0*y0*z0 + x1*y1*z1;

    return result;
}

// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
// NOTE: Angles are returned in a Vector3 struct in radians
QuaternionToEuler :: (q: Quaternion) -> Vector3 {
    result: Vector3;

    // Roll (x-axis rotation)
    x0: float = 2.0 *(q.w*q.x + q.y*q.z);
    x1: float = 1.0  - 2.0 *(q.x*q.x + q.y*q.y);
    result.x  = atan2f(x0, x1);

    // Pitch (y-axis rotation)
    y0: float = 2.0 *(q.w*q.y - q.z*q.x);
    y0  = ifx y0 > 1.0   then  1.0  else y0;
    y0  = ifx y0 < -1.0   then  -1.0  else y0;
    result.y  = asinf(y0);

    // Yaw (z-axis rotation)
    z0: float = 2.0 *(q.w*q.z + q.x*q.y);
    z1: float = 1.0  - 2.0 *(q.y*q.y + q.z*q.z);
    result.z  = atan2f(z0, z1);

    return result;
}

// Transform a quaternion given a transformation matrix
QuaternionTransform :: (q: Quaternion, mat: Matrix4) -> Quaternion {
    result: Quaternion;

    result.x  = mat.m0*q.x + mat.m4*q.y + mat.m8*q.z + mat.m12*q.w;
    result.y  = mat.m1*q.x + mat.m5*q.y + mat.m9*q.z + mat.m13*q.w;
    result.z  = mat.m2*q.x + mat.m6*q.y + mat.m10*q.z + mat.m14*q.w;
    result.w  = mat.m3*q.x + mat.m7*q.y + mat.m11*q.z + mat.m15*q.w;

    return result;
}

// Check whether two given quaternions are almost equal
QuaternionEquals :: (p: Quaternion, q: Quaternion) -> s32 {

    result: s32 = (((fabsf(p.x - q.x)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.x), fabsf(q.x))))) &&
    ((fabsf(p.y - q.y)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.y), fabsf(q.y))))) &&
    ((fabsf(p.z - q.z)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.z), fabsf(q.z))))) &&
    ((fabsf(p.w - q.w)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.w), fabsf(q.w)))))) ||
    (((fabsf(p.x + q.x)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.x), fabsf(q.x))))) &&
    ((fabsf(p.y + q.y)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.y), fabsf(q.y))))) &&
    ((fabsf(p.z + q.z)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.z), fabsf(q.z))))) &&
    ((fabsf(p.w + q.w)) <= (EPSILON*fmaxf(1.0 , fmaxf(fabsf(p.w), fabsf(q.w))))));

    return result;
}


