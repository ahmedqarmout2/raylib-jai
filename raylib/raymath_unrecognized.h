#ifndef RAYMATH_H
#define RAYMATH_H

#if defined(RAYMATH_IMPLEMENTATION) && defined(RAYMATH_STATIC_INLINE)
#error "Specifying both RAYMATH_IMPLEMENTATION and RAYMATH_STATIC_INLINE is contradictory"
#endif
#if defined(RAYMATH_IMPLEMENTATION)
#if defined(_WIN32) && defined(BUILD_LIBTYPE_SHARED)
#define RMAPI __declspec(dllexport) extern inline // We are building raylib as a Win32 shared library (.dll).
#elif defined(_WIN32) && defined(USE_LIBTYPE_SHARED)
#define RMAPI __declspec(dllimport)         // We are using raylib as a Win32 shared library (.dll)
#else
#define RMAPI extern inline // Provide external definition
#endif
#elif defined(RAYMATH_STATIC_INLINE)
    #define RMAPI static inline // Functions may be inlined, no external out-of-line definition
#else
#if defined(__TINYC__)
#define RMAPI static inline // plain inline not supported by tinycc (See issue #435)
#else
#define RMAPI inline        // Functions may be inlined or external definition used
#endif
#endif
#ifndef PI
#define PI 3.14159265358979323846f
#endif
#ifndef EPSILON
#define EPSILON 0.000001f
#endif
#ifndef DEG2RAD
#define DEG2RAD (PI/180.0f)
#endif
#ifndef RAD2DEG
#define RAD2DEG (180.0f/PI)
#endif
#ifndef MatrixToFloat
#define MatrixToFloat(mat) (MatrixToFloatV(mat).v)
#endif
#ifndef Vector3ToFloat
#define Vector3ToFloat(vec) (Vector3ToFloatV(vec).v)
#endif
#if !defined(RL_VECTOR2_TYPE)
// Vector2 type
typedef struct Vector2 {
float x;
float y;
} Vector2;
#define RL_VECTOR2_TYPE
#endif
#if !defined(RL_VECTOR3_TYPE)
// Vector3 type
typedef struct Vector3 {
float x;
float y;
float z;
} Vector3;
#define RL_VECTOR3_TYPE
#endif
#if !defined(RL_VECTOR4_TYPE)
// Vector4 type
typedef struct Vector4 {
float x;
float y;
float z;
float w;
} Vector4;
#define RL_VECTOR4_TYPE
#endif
#if !defined(RL_QUATERNION_TYPE)
// Quaternion type
typedef Vector4 Quaternion;
#define RL_QUATERNION_TYPE
#endif
#if !defined(RL_MATRIX_TYPE)
// Matrix type (OpenGL style 4x4 - right handed, column major)
typedef struct Matrix {
float m0, m4, m8, m12;      // Matrix first row (4 components)
float m1, m5, m9, m13;      // Matrix second row (4 components)
float m2, m6, m10, m14;     // Matrix third row (4 components)
float m3, m7, m11, m15;     // Matrix fourth row (4 components)
} Matrix;
#define RL_MATRIX_TYPE
#endif
#include <math.h>       // Required for: sinf(), cosf(), tan(), atan2f(), sqrtf(), floor(), fminf(), fmaxf(), fabs()
#if !defined(EPSILON)
#define EPSILON 0.000001f
#endif
#if !defined(EPSILON)
#define EPSILON 0.000001f
#endif
#if !defined(EPSILON)
#define EPSILON 0.000001f
#endif
#if !defined(EPSILON)
#define EPSILON 0.000001f
#endif
#if !defined(EPSILON)
#define EPSILON 0.000001f
#endif
#endif  // RAYMATH_H
