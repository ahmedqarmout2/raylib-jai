#ifndef RLGL_H
#define RLGL_H

#define RLGL_VERSION  "4.5"

// Function specifiers in case library is build/used as a shared library (Windows)
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
#if defined(_WIN32)
#if defined(BUILD_LIBTYPE_SHARED)
#define RLAPI __declspec(dllexport)     // We are building the library as a Win32 shared library (.dll)
#elif defined(USE_LIBTYPE_SHARED)
#define RLAPI __declspec(dllimport)     // We are using the library as a Win32 shared library (.dll)
#endif
#endif
#ifndef RLAPI
#define RLAPI       // Functions defined as 'extern' by default (implicit specifiers)
#endif
#ifndef TRACELOG
#define TRACELOG(level, ...) (void)0
#define TRACELOGD(...) (void)0
#endif
#ifndef RL_MALLOC
#define RL_MALLOC(sz)     malloc(sz)
#endif
#ifndef RL_CALLOC
#define RL_CALLOC(n,sz)   calloc(n,sz)
#endif
#ifndef RL_REALLOC
#define RL_REALLOC(n,sz)  realloc(n,sz)
#endif
#ifndef RL_FREE
#define RL_FREE(p)        free(p)
#endif
#if !defined(GRAPHICS_API_OPENGL_11) && \
!defined(GRAPHICS_API_OPENGL_21) && \
!defined(GRAPHICS_API_OPENGL_33) && \
!defined(GRAPHICS_API_OPENGL_43) && \
!defined(GRAPHICS_API_OPENGL_ES2) && \
!defined(GRAPHICS_API_OPENGL_ES3)
#define GRAPHICS_API_OPENGL_33
#endif
#if defined(GRAPHICS_API_OPENGL_11)
#if defined(GRAPHICS_API_OPENGL_21)
#undef GRAPHICS_API_OPENGL_21
#endif
#if defined(GRAPHICS_API_OPENGL_33)
#undef GRAPHICS_API_OPENGL_33
#endif
#if defined(GRAPHICS_API_OPENGL_43)
#undef GRAPHICS_API_OPENGL_43
#endif
#if defined(GRAPHICS_API_OPENGL_ES2)
#undef GRAPHICS_API_OPENGL_ES2
#endif
#endif
#if defined(GRAPHICS_API_OPENGL_21)
#define GRAPHICS_API_OPENGL_33
#endif
#if defined(GRAPHICS_API_OPENGL_43)
#define GRAPHICS_API_OPENGL_33
#endif
#if defined(GRAPHICS_API_OPENGL_ES3)
#define GRAPHICS_API_OPENGL_ES2
#endif
#define RLGL_RENDER_TEXTURES_HINT
#ifndef RL_DEFAULT_BATCH_BUFFER_ELEMENTS
#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
// This is the maximum amount of elements (quads) per batch
// NOTE: Be careful with text, every letter maps to a quad
#define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  8192
#endif
#if defined(GRAPHICS_API_OPENGL_ES2)
// We reduce memory sizes for embedded systems (RPI and HTML5)
// NOTE: On HTML5 (emscripten) this is allocated on heap,
// by default it's only 16MB!...just take care...
#define RL_DEFAULT_BATCH_BUFFER_ELEMENTS  2048
#endif
#endif
#ifndef RL_DEFAULT_BATCH_BUFFERS
#define RL_DEFAULT_BATCH_BUFFERS                 1      // Default number of batch buffers (multi-buffering)
#endif
#ifndef RL_DEFAULT_BATCH_DRAWCALLS
#define RL_DEFAULT_BATCH_DRAWCALLS             256      // Default number of batch draw calls (by state changes: mode, texture)
#endif
#ifndef RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS
#define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS       4      // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
#endif
#ifndef RL_MAX_MATRIX_STACK_SIZE
#define RL_MAX_MATRIX_STACK_SIZE                32      // Maximum size of Matrix stack
#endif
#ifndef RL_MAX_SHADER_LOCATIONS
#define RL_MAX_SHADER_LOCATIONS                 32      // Maximum number of shader locations supported
#endif
#ifndef RL_CULL_DISTANCE_NEAR
#define RL_CULL_DISTANCE_NEAR                 0.01      // Default near cull distance
#endif
#ifndef RL_CULL_DISTANCE_FAR
#define RL_CULL_DISTANCE_FAR                1000.0      // Default far cull distance
#endif
#define RL_TEXTURE_WRAP_S                       0x2802      // GL_TEXTURE_WRAP_S
#define RL_TEXTURE_WRAP_T                       0x2803      // GL_TEXTURE_WRAP_T
#define RL_TEXTURE_MAG_FILTER                   0x2800      // GL_TEXTURE_MAG_FILTER
#define RL_TEXTURE_MIN_FILTER                   0x2801      // GL_TEXTURE_MIN_FILTER
#define RL_TEXTURE_FILTER_NEAREST               0x2600      // GL_NEAREST
#define RL_TEXTURE_FILTER_LINEAR                0x2601      // GL_LINEAR
#define RL_TEXTURE_FILTER_MIP_NEAREST           0x2700      // GL_NEAREST_MIPMAP_NEAREST
#define RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR    0x2702      // GL_NEAREST_MIPMAP_LINEAR
#define RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST    0x2701      // GL_LINEAR_MIPMAP_NEAREST
#define RL_TEXTURE_FILTER_MIP_LINEAR            0x2703      // GL_LINEAR_MIPMAP_LINEAR
#define RL_TEXTURE_FILTER_ANISOTROPIC           0x3000      // Anisotropic filter (custom identifier)
#define RL_TEXTURE_MIPMAP_BIAS_RATIO            0x4000      // Texture mipmap bias, percentage ratio (custom identifier)
#define RL_TEXTURE_WRAP_REPEAT                  0x2901      // GL_REPEAT
#define RL_TEXTURE_WRAP_CLAMP                   0x812F      // GL_CLAMP_TO_EDGE
#define RL_TEXTURE_WRAP_MIRROR_REPEAT           0x8370      // GL_MIRRORED_REPEAT
#define RL_TEXTURE_WRAP_MIRROR_CLAMP            0x8742      // GL_MIRROR_CLAMP_EXT
#define RL_MODELVIEW                            0x1700      // GL_MODELVIEW
#define RL_PROJECTION                           0x1701      // GL_PROJECTION
#define RL_TEXTURE                              0x1702      // GL_TEXTURE
#define RL_LINES                                0x0001      // GL_LINES
#define RL_TRIANGLES                            0x0004      // GL_TRIANGLES
#define RL_QUADS                                0x0007      // GL_QUADS
#define RL_UNSIGNED_BYTE                        0x1401      // GL_UNSIGNED_BYTE
#define RL_FLOAT                                0x1406      // GL_FLOAT
#define RL_STREAM_DRAW                          0x88E0      // GL_STREAM_DRAW
#define RL_STREAM_READ                          0x88E1      // GL_STREAM_READ
#define RL_STREAM_COPY                          0x88E2      // GL_STREAM_COPY
#define RL_STATIC_DRAW                          0x88E4      // GL_STATIC_DRAW
#define RL_STATIC_READ                          0x88E5      // GL_STATIC_READ
#define RL_STATIC_COPY                          0x88E6      // GL_STATIC_COPY
#define RL_DYNAMIC_DRAW                         0x88E8      // GL_DYNAMIC_DRAW
#define RL_DYNAMIC_READ                         0x88E9      // GL_DYNAMIC_READ
#define RL_DYNAMIC_COPY                         0x88EA      // GL_DYNAMIC_COPY
#define RL_FRAGMENT_SHADER                      0x8B30      // GL_FRAGMENT_SHADER
#define RL_VERTEX_SHADER                        0x8B31      // GL_VERTEX_SHADER
#define RL_COMPUTE_SHADER                       0x91B9      // GL_COMPUTE_SHADER
#define RL_ZERO                                 0           // GL_ZERO
#define RL_ONE                                  1           // GL_ONE
#define RL_SRC_COLOR                            0x0300      // GL_SRC_COLOR
#define RL_ONE_MINUS_SRC_COLOR                  0x0301      // GL_ONE_MINUS_SRC_COLOR
#define RL_SRC_ALPHA                            0x0302      // GL_SRC_ALPHA
#define RL_ONE_MINUS_SRC_ALPHA                  0x0303      // GL_ONE_MINUS_SRC_ALPHA
#define RL_DST_ALPHA                            0x0304      // GL_DST_ALPHA
#define RL_ONE_MINUS_DST_ALPHA                  0x0305      // GL_ONE_MINUS_DST_ALPHA
#define RL_DST_COLOR                            0x0306      // GL_DST_COLOR
#define RL_ONE_MINUS_DST_COLOR                  0x0307      // GL_ONE_MINUS_DST_COLOR
#define RL_SRC_ALPHA_SATURATE                   0x0308      // GL_SRC_ALPHA_SATURATE
#define RL_CONSTANT_COLOR                       0x8001      // GL_CONSTANT_COLOR
#define RL_ONE_MINUS_CONSTANT_COLOR             0x8002      // GL_ONE_MINUS_CONSTANT_COLOR
#define RL_CONSTANT_ALPHA                       0x8003      // GL_CONSTANT_ALPHA
#define RL_ONE_MINUS_CONSTANT_ALPHA             0x8004      // GL_ONE_MINUS_CONSTANT_ALPHA
#define RL_FUNC_ADD                             0x8006      // GL_FUNC_ADD
#define RL_MIN                                  0x8007      // GL_MIN
#define RL_MAX                                  0x8008      // GL_MAX
#define RL_FUNC_SUBTRACT                        0x800A      // GL_FUNC_SUBTRACT
#define RL_FUNC_REVERSE_SUBTRACT                0x800B      // GL_FUNC_REVERSE_SUBTRACT
#define RL_BLEND_EQUATION                       0x8009      // GL_BLEND_EQUATION
#define RL_BLEND_EQUATION_RGB                   0x8009      // GL_BLEND_EQUATION_RGB   // (Same as BLEND_EQUATION)
#define RL_BLEND_EQUATION_ALPHA                 0x883D      // GL_BLEND_EQUATION_ALPHA
#define RL_BLEND_DST_RGB                        0x80C8      // GL_BLEND_DST_RGB
#define RL_BLEND_SRC_RGB                        0x80C9      // GL_BLEND_SRC_RGB
#define RL_BLEND_DST_ALPHA                      0x80CA      // GL_BLEND_DST_ALPHA
#define RL_BLEND_SRC_ALPHA                      0x80CB      // GL_BLEND_SRC_ALPHA
#define RL_BLEND_COLOR                          0x8005      // GL_BLEND_COLOR
#if (defined(__STDC__) && __STDC_VERSION__ >= 199901L) || (defined(_MSC_VER) && _MSC_VER >= 1800)
#include <stdbool.h>
#elif !defined(__cplusplus) && !defined(bool) && !defined(RL_BOOL_TYPE)
// Boolean type
typedef enum bool { false = 0, true = !false } bool;
#endif
#if !defined(RL_MATRIX_TYPE)
// Matrix, 4x4 components, column major, OpenGL style, right handed
typedef struct Matrix {
float m0, m4, m8, m12;      // Matrix first row (4 components)
float m1, m5, m9, m13;      // Matrix second row (4 components)
float m2, m6, m10, m14;     // Matrix third row (4 components)
float m3, m7, m11, m15;     // Matrix fourth row (4 components)
} Matrix;
#define RL_MATRIX_TYPE
#endif
#if defined(GRAPHICS_API_OPENGL_11) || defined(GRAPHICS_API_OPENGL_33)
unsigned int *indices;      // Vertex indices (in case vertex data comes indexed) (6 indices per quad)
#endif
#if defined(GRAPHICS_API_OPENGL_ES2)
unsigned short *indices;    // Vertex indices (in case vertex data comes indexed) (6 indices per quad)
#endif
#define RL_SHADER_LOC_MAP_DIFFUSE       RL_SHADER_LOC_MAP_ALBEDO
#define RL_SHADER_LOC_MAP_SPECULAR      RL_SHADER_LOC_MAP_METALNESS
#if defined(__cplusplus)
extern "C" {            // Prevents name mangling of functions
#endif
#if defined(GRAPHICS_API_OPENGL_11)
RLAPI void rlEnableStatePointer(int vertexAttribType, void *buffer);    // Enable attribute state pointer
RLAPI void rlDisableStatePointer(int vertexAttribType);                 // Disable attribute state pointer
#endif
#if defined(__cplusplus)
}
#endif
