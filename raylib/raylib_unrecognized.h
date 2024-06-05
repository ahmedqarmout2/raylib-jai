#ifndef RAYLIB_H
RAYLIB_H
#include <stdarg.h>     // Required for: va_list - Only used by TraceLogCallback
RAYLIB_VERSION_MAJOR 5
RAYLIB_VERSION_MINOR 0
RAYLIB_VERSION_PATCH 0
RAYLIB_VERSION  "5.0"
#if defined(_WIN32)
    #if defined(BUILD_LIBTYPE_SHARED)
        #if defined(__TINYC__)
            #define __declspec(x) __attribute__((x))
        #endif
        #define RLAPI __declspec(dllexport)     // We are building the library as a Win32 shared library (.dll)
    #elif defined(USE_LIBTYPE_SHARED)
        #define RLAPI __declspec(dllimport)     // We are using the library as a Win32 shared library (.dll)
    #endif
#endif
#ifndef RLAPI
    #define RLAPI       // Functions defined as 'extern' by default (implicit specifiers)
#endif
#ifndef PI
    #define PI 3.14159265358979323846f
#endif
#ifndef DEG2RAD
    #define DEG2RAD (PI/180.0f)
#endif
#ifndef RAD2DEG
    #define RAD2DEG (180.0f/PI)
#endif
#ifndef RL_MALLOC
    #define RL_MALLOC(sz)       malloc(sz)
#endif
#ifndef RL_CALLOC
    #define RL_CALLOC(n,sz)     calloc(n,sz)
#endif
#ifndef RL_REALLOC
    #define RL_REALLOC(ptr,sz)  realloc(ptr,sz)
#endif
#ifndef RL_FREE
    #define RL_FREE(ptr)        free(ptr)
#endif
#if defined(__cplusplus)
    #define CLITERAL(type)      type
#else
    #define CLITERAL(type)      (type)
#endif
#if !defined(_MSC_VER) && (defined(__cplusplus) && __cplusplus < 201103L)
    #error "C++11 or later is required. Add -std=c++11"
#endif
RL_COLOR_TYPE
RL_RECTANGLE_TYPE
RL_VECTOR2_TYPE
RL_VECTOR3_TYPE
RL_VECTOR4_TYPE
RL_QUATERNION_TYPE
RL_MATRIX_TYPE
#if (defined(__STDC__) && __STDC_VERSION__ >= 199901L) || (defined(_MSC_VER) && _MSC_VER >= 1800)
    #include <stdbool.h>
#elif !defined(__cplusplus) && !defined(bool)
    typedef enum bool { false = 0, true = !false } bool;
    #define RL_BOOL_TYPE
#endif
MOUSE_LEFT_BUTTON   MOUSE_BUTTON_LEFT
MOUSE_RIGHT_BUTTON  MOUSE_BUTTON_RIGHT
MOUSE_MIDDLE_BUTTON MOUSE_BUTTON_MIDDLE
MATERIAL_MAP_DIFFUSE      MATERIAL_MAP_ALBEDO
MATERIAL_MAP_SPECULAR     MATERIAL_MAP_METALNESS
SHADER_LOC_MAP_DIFFUSE      SHADER_LOC_MAP_ALBEDO
SHADER_LOC_MAP_SPECULAR     SHADER_LOC_MAP_METALNESS
#if defined(__cplusplus)
extern "C" {            // Prevents name mangling of functions
#endif
#if defined(__cplusplus)
}
#endif
#endif // RAYLIB_H
