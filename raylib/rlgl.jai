//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//


/*
***********************************************************************************************
*
*   rlgl v4.5 - A multi-OpenGL abstraction layer with an immediate-mode style API
*
*   DESCRIPTION:
*       An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
*       that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
*
*   ADDITIONAL NOTES:
*       When choosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
*       initialized on rlglInit() to accumulate vertex data.
*
*       When an internal state change is required all the stored vertex data is renderer in batch,
*       additionally, rlDrawRenderBatchActive() could be called to force flushing of the batch.
*
*       Some resources are also loaded for convenience, here the complete list:
*          - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
*          - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
*          - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
*
*       Internal buffer (and resources) must be manually unloaded calling rlglClose().
*
*   CONFIGURATION:
*       #define GRAPHICS_API_OPENGL_11
*       #define GRAPHICS_API_OPENGL_21
*       #define GRAPHICS_API_OPENGL_33
*       #define GRAPHICS_API_OPENGL_43
*       #define GRAPHICS_API_OPENGL_ES2
*       #define GRAPHICS_API_OPENGL_ES3
*           Use selected OpenGL graphics backend, should be supported by platform
*           Those preprocessor defines are only used on rlgl module, if OpenGL version is
*           required by any other module, use rlGetVersion() to check it
*
*       #define RLGL_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RLGL_RENDER_TEXTURES_HINT
*           Enable framebuffer objects (fbo) support (enabled by default)
*           Some GPUs could not support them despite the OpenGL version
*
*       #define RLGL_SHOW_GL_DETAILS_INFO
*           Show OpenGL extensions and capabilities detailed logs on init
*
*       #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
*           Enable debug context (only available on OpenGL 4.3)
*
*       rlgl capabilities could be customized just defining some internal
*       values before library inclusion (default values listed):
*
*       #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
*       #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
*       #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
*       #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
*
*       #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
*       #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
*       #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
*       #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
*
*       When loading a shader, the following vertex attributes and uniform
*       location names are tried to be set automatically:
*
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Bound by default to shader location: 0
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Bound by default to shader location: 1
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Bound by default to shader location: 2
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Bound by default to shader location: 3
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Bound by default to shader location: 4
*       #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Bound by default to shader location: 5
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
*       #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
*       #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
*
*   DEPENDENCIES:
*      - OpenGL libraries (depending on platform and OpenGL version selected)
*      - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
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

// Support TRACELOG macros

// Allow custom memory allocators

// Security check in case no GRAPHICS_API_OPENGL_* defined

// Security check in case multiple GRAPHICS_API_OPENGL_* defined

// OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
// WARNING: Specific parts are checked with #if defines

// OpenGL 4.3 uses OpenGL 3.3 Core functionality

// OpenGL ES 3.0 uses OpenGL ES 2.0 functionality (and more)

// Support framebuffer objects by default
// NOTE: Some driver implementation do not support it, despite they should

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------

// Default internal render batch elements limits

// Internal Matrix stack

// Shader limits

// Projection matrix culling

// Texture parameters (equivalent to OpenGL defines)



// Matrix modes (equivalent to OpenGL)

// Primitive assembly draw modes

// GL equivalent data types

// GL buffer usage hint

// GL Shader type

// GL blending factors

// GL blending functions/equations


//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------


// Dynamic vertex buffers (position + texcoords + colors + indices arrays)
rlVertexBuffer :: struct {
    elementCount: s32;            // Number of elements in the buffer (QUADS)

    vertices: *float;             // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: *float;            // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors: *u8;       // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    vaoId: u32;          // OpenGL Vertex Array Object id
    vboId: [4]u32;       // OpenGL Vertex Buffer Objects id (4 types of vertex data)
}

// Draw call type
// NOTE: Only texture changes register a new draw, other state-change-related elements are not
// used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
// of those state-change happens (this is done in core module)
rlDrawCall :: struct {
    mode: s32;                    // Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount: s32;             // Number of vertex of the draw
    vertexAlignment: s32;         // Number of vertex required for index alignment (LINES, TRIANGLES)
    //unsigned int vaoId;       // Vertex array id to be used on the draw -> Using RLGL.currentBatch->vertexBuffer.vaoId
    //unsigned int shaderId;    // Shader id to be used on the draw -> Using RLGL.currentShaderId
    textureId: u32;      // Texture id to be used on the draw -> Use to create new draw call if changes

    //Matrix projection;        // Projection matrix for this draw -> Using RLGL.projection by default
    //Matrix modelview;         // Modelview matrix for this draw -> Using RLGL.modelview by default
}

// rlRenderBatch type
rlRenderBatch :: struct {
    bufferCount: s32;             // Number of vertex buffers (multi-buffering support)
    currentBuffer: s32;           // Current buffer tracking in case of multi-buffering
    vertexBuffer: *rlVertexBuffer;  // Dynamic buffer(s) for vertex data

    draws: *rlDrawCall;           // Draw calls array, depends on textureId
    drawCounter: s32;             // Draw calls counter
    currentDepth: float;          // Current depth value for next draw
}

// OpenGL version
rlGlVersion :: enum s32 {
    RL_OPENGL_11 :: 1;           // OpenGL 1.1
    RL_OPENGL_21;               // OpenGL 2.1 (GLSL 120)
    RL_OPENGL_33;               // OpenGL 3.3 (GLSL 330)
    RL_OPENGL_43;               // OpenGL 4.3 (using GLSL 330)
    RL_OPENGL_ES_20;            // OpenGL ES 2.0 (GLSL 100)
    RL_OPENGL_ES_30;             // OpenGL ES 3.0 (GLSL 300 es)
}

// Trace log level
// NOTE: Organized by priority level
rlTraceLogLevel :: enum s32 {
    RL_LOG_ALL :: 0;             // Display all logs
    RL_LOG_TRACE;               // Trace logging, intended for internal use only
    RL_LOG_DEBUG;               // Debug logging, used for internal debugging, it should be disabled on release builds
    RL_LOG_INFO;                // Info logging, used for program execution info
    RL_LOG_WARNING;             // Warning logging, used on recoverable failures
    RL_LOG_ERROR;               // Error logging, used on unrecoverable failures
    RL_LOG_FATAL;               // Fatal logging, used to abort program: exit(EXIT_FAILURE)
    RL_LOG_NONE;                 // Disable logging
}

// Texture pixel formats
// NOTE: Support depends on OpenGL version
rlPixelFormat :: enum s32 {
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE :: 1;     // 8 bit per pixel (no alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA;        // 8*2 bpp (2 channels)
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5;            // 16 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8;            // 24 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1;          // 16 bpp (1 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4;          // 16 bpp (4 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;          // 32 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R32;               // 32 bpp (1 channel - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32;         // 32*3 bpp (3 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32;      // 32*4 bpp (4 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16;               // 16 bpp (1 channel - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16;         // 16*3 bpp (3 channels - half float)
    RL_PIXELFORMAT_UNCOMPRESSED_R16G16B16A16;      // 16*4 bpp (4 channels - half float)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB;            // 4 bpp (no alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA;           // 4 bpp (1 bit alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA;           // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA;           // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB;            // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB;            // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA;       // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB;            // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA;           // 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA;       // 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA;        // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
rlTextureFilter :: enum s32 {
    RL_TEXTURE_FILTER_POINT :: 0;        // No filter, just pixel approximation
    RL_TEXTURE_FILTER_BILINEAR;         // Linear filtering
    RL_TEXTURE_FILTER_TRILINEAR;        // Trilinear filtering (linear with mipmaps)
    RL_TEXTURE_FILTER_ANISOTROPIC_4X;   // Anisotropic filtering 4x
    RL_TEXTURE_FILTER_ANISOTROPIC_8X;   // Anisotropic filtering 8x
    RL_TEXTURE_FILTER_ANISOTROPIC_16X;  // Anisotropic filtering 16x
}

// Color blending modes (pre-defined)
rlBlendMode :: enum s32 {
    RL_BLEND_ALPHA :: 0;                 // Blend textures considering alpha (default)
    RL_BLEND_ADDITIVE;                  // Blend textures adding colors
    RL_BLEND_MULTIPLIED;                // Blend textures multiplying colors
    RL_BLEND_ADD_COLORS;                // Blend textures adding colors (alternative)
    RL_BLEND_SUBTRACT_COLORS;           // Blend textures subtracting colors (alternative)
    RL_BLEND_ALPHA_PREMULTIPLY;         // Blend premultiplied textures considering alpha
    RL_BLEND_CUSTOM;                    // Blend textures using custom src/dst factors (use rlSetBlendFactors())
    RL_BLEND_CUSTOM_SEPARATE;            // Blend textures using custom src/dst factors (use rlSetBlendFactorsSeparate())
}

// Shader location point type
rlShaderLocationIndex :: enum s32 {
    RL_SHADER_LOC_VERTEX_POSITION :: 0;  // Shader location: vertex attribute: position
    RL_SHADER_LOC_VERTEX_TEXCOORD01;    // Shader location: vertex attribute: texcoord01
    RL_SHADER_LOC_VERTEX_TEXCOORD02;    // Shader location: vertex attribute: texcoord02
    RL_SHADER_LOC_VERTEX_NORMAL;        // Shader location: vertex attribute: normal
    RL_SHADER_LOC_VERTEX_TANGENT;       // Shader location: vertex attribute: tangent
    RL_SHADER_LOC_VERTEX_COLOR;         // Shader location: vertex attribute: color
    RL_SHADER_LOC_MATRIX_MVP;           // Shader location: matrix uniform: model-view-projection
    RL_SHADER_LOC_MATRIX_VIEW;          // Shader location: matrix uniform: view (camera transform)
    RL_SHADER_LOC_MATRIX_PROJECTION;    // Shader location: matrix uniform: projection
    RL_SHADER_LOC_MATRIX_MODEL;         // Shader location: matrix uniform: model (transform)
    RL_SHADER_LOC_MATRIX_NORMAL;        // Shader location: matrix uniform: normal
    RL_SHADER_LOC_VECTOR_VIEW;          // Shader location: vector uniform: view
    RL_SHADER_LOC_COLOR_DIFFUSE;        // Shader location: vector uniform: diffuse color
    RL_SHADER_LOC_COLOR_SPECULAR;       // Shader location: vector uniform: specular color
    RL_SHADER_LOC_COLOR_AMBIENT;        // Shader location: vector uniform: ambient color
    RL_SHADER_LOC_MAP_ALBEDO;           // Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
    RL_SHADER_LOC_MAP_METALNESS;        // Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
    RL_SHADER_LOC_MAP_NORMAL;           // Shader location: sampler2d texture: normal
    RL_SHADER_LOC_MAP_ROUGHNESS;        // Shader location: sampler2d texture: roughness
    RL_SHADER_LOC_MAP_OCCLUSION;        // Shader location: sampler2d texture: occlusion
    RL_SHADER_LOC_MAP_EMISSION;         // Shader location: sampler2d texture: emission
    RL_SHADER_LOC_MAP_HEIGHT;           // Shader location: sampler2d texture: height
    RL_SHADER_LOC_MAP_CUBEMAP;          // Shader location: samplerCube texture: cubemap
    RL_SHADER_LOC_MAP_IRRADIANCE;       // Shader location: samplerCube texture: irradiance
    RL_SHADER_LOC_MAP_PREFILTER;        // Shader location: samplerCube texture: prefilter
    RL_SHADER_LOC_MAP_BRDF;              // Shader location: sampler2d texture: brdf
}


// Shader uniform data type
rlShaderUniformDataType :: enum s32 {
    RL_SHADER_UNIFORM_FLOAT :: 0;        // Shader uniform type: float
    RL_SHADER_UNIFORM_VEC2;             // Shader uniform type: vec2 (2 float)
    RL_SHADER_UNIFORM_VEC3;             // Shader uniform type: vec3 (3 float)
    RL_SHADER_UNIFORM_VEC4;             // Shader uniform type: vec4 (4 float)
    RL_SHADER_UNIFORM_INT;              // Shader uniform type: int
    RL_SHADER_UNIFORM_IVEC2;            // Shader uniform type: ivec2 (2 int)
    RL_SHADER_UNIFORM_IVEC3;            // Shader uniform type: ivec3 (3 int)
    RL_SHADER_UNIFORM_IVEC4;            // Shader uniform type: ivec4 (4 int)
    RL_SHADER_UNIFORM_SAMPLER2D;         // Shader uniform type: sampler2d
}

// Shader attribute data types
rlShaderAttributeDataType :: enum s32 {
    RL_SHADER_ATTRIB_FLOAT :: 0;         // Shader attribute type: float
    RL_SHADER_ATTRIB_VEC2;              // Shader attribute type: vec2 (2 float)
    RL_SHADER_ATTRIB_VEC3;              // Shader attribute type: vec3 (3 float)
    RL_SHADER_ATTRIB_VEC4;               // Shader attribute type: vec4 (4 float)
}

// Framebuffer attachment type
// NOTE: By default up to 8 color channels defined, but it can be more
rlFramebufferAttachType :: enum s32 {
    RL_ATTACHMENT_COLOR_CHANNEL0 :: 0;       // Framebuffer attachment type: color 0
    RL_ATTACHMENT_COLOR_CHANNEL1 :: 1;       // Framebuffer attachment type: color 1
    RL_ATTACHMENT_COLOR_CHANNEL2 :: 2;       // Framebuffer attachment type: color 2
    RL_ATTACHMENT_COLOR_CHANNEL3 :: 3;       // Framebuffer attachment type: color 3
    RL_ATTACHMENT_COLOR_CHANNEL4 :: 4;       // Framebuffer attachment type: color 4
    RL_ATTACHMENT_COLOR_CHANNEL5 :: 5;       // Framebuffer attachment type: color 5
    RL_ATTACHMENT_COLOR_CHANNEL6 :: 6;       // Framebuffer attachment type: color 6
    RL_ATTACHMENT_COLOR_CHANNEL7 :: 7;       // Framebuffer attachment type: color 7
    RL_ATTACHMENT_DEPTH :: 100;              // Framebuffer attachment type: depth
    RL_ATTACHMENT_STENCIL :: 200;            // Framebuffer attachment type: stencil
}

// Framebuffer texture attachment type
rlFramebufferAttachTextureType :: enum s32 {
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X :: 0;   // Framebuffer texture attachment type: cubemap, +X side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X :: 1;   // Framebuffer texture attachment type: cubemap, -X side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y :: 2;   // Framebuffer texture attachment type: cubemap, +Y side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y :: 3;   // Framebuffer texture attachment type: cubemap, -Y side
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z :: 4;   // Framebuffer texture attachment type: cubemap, +Z side
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z :: 5;   // Framebuffer texture attachment type: cubemap, -Z side
    RL_ATTACHMENT_TEXTURE2D :: 100;          // Framebuffer texture attachment type: texture2d
    RL_ATTACHMENT_RENDERBUFFER :: 200;       // Framebuffer texture attachment type: renderbuffer
}

// Face culling mode
rlCullMode :: enum s32 {
    RL_CULL_FACE_FRONT :: 0;
    RL_CULL_FACE_BACK;
}

//------------------------------------------------------------------------------------
// Functions Declaration - Matrix operations
//------------------------------------------------------------------------------------


rlMatrixMode :: (mode: s32) #foreign raylib_native;
rlPushMatrix :: () #foreign raylib_native;
rlPopMatrix :: () #foreign raylib_native;
rlLoadIdentity :: () #foreign raylib_native;
rlTranslatef :: (x: float, y: float, z: float) #foreign raylib_native;
rlRotatef :: (angle: float, x: float, y: float, z: float) #foreign raylib_native;
rlScalef :: (x: float, y: float, z: float) #foreign raylib_native;
rlMultMatrixf :: (matf: *float) #foreign raylib_native;
rlFrustum :: (left: float64, right: float64, bottom: float64, top: float64, znear: float64, zfar: float64) #foreign raylib_native;
rlOrtho :: (left: float64, right: float64, bottom: float64, top: float64, znear: float64, zfar: float64) #foreign raylib_native;
rlViewport :: (x: s32, y: s32, width: s32, height: s32) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Functions Declaration - Vertex level operations
//------------------------------------------------------------------------------------
rlBegin :: (mode: s32) #foreign raylib_native;
rlEnd :: () #foreign raylib_native;
rlVertex2i :: (x: s32, y: s32) #foreign raylib_native;
rlVertex2f :: (x: float, y: float) #foreign raylib_native;
rlVertex3f :: (x: float, y: float, z: float) #foreign raylib_native;
rlTexCoord2f :: (x: float, y: float) #foreign raylib_native;
rlNormal3f :: (x: float, y: float, z: float) #foreign raylib_native;
rlColor4ub :: (r: u8, g: u8, b: u8, a: u8) #foreign raylib_native;
rlColor3f :: (x: float, y: float, z: float) #foreign raylib_native;
rlColor4f :: (x: float, y: float, z: float, w: float) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
// NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
// some of them are direct wrappers over OpenGL calls, some others are custom
//------------------------------------------------------------------------------------

// Vertex buffers state
rlEnableVertexArray :: (vaoId: u32) -> bool #foreign raylib_native;
rlDisableVertexArray :: () #foreign raylib_native;
rlEnableVertexBuffer :: (id: u32) #foreign raylib_native;
rlDisableVertexBuffer :: () #foreign raylib_native;
rlEnableVertexBufferElement :: (id: u32) #foreign raylib_native;
rlDisableVertexBufferElement :: () #foreign raylib_native;
rlEnableVertexAttribute :: (index: u32) #foreign raylib_native;
rlDisableVertexAttribute :: (index: u32) #foreign raylib_native;

// Textures state
rlActiveTextureSlot :: (slot: s32) #foreign raylib_native;
rlEnableTexture :: (id: u32) #foreign raylib_native;
rlDisableTexture :: () #foreign raylib_native;
rlEnableTextureCubemap :: (id: u32) #foreign raylib_native;
rlDisableTextureCubemap :: () #foreign raylib_native;
rlTextureParameters :: (id: u32, param: s32, value: s32) #foreign raylib_native;
rlCubemapParameters :: (id: u32, param: s32, value: s32) #foreign raylib_native;

// Shader state
rlEnableShader :: (id: u32) #foreign raylib_native;
rlDisableShader :: () #foreign raylib_native;

// Framebuffer state
rlEnableFramebuffer :: (id: u32) #foreign raylib_native;
rlDisableFramebuffer :: () #foreign raylib_native;
rlActiveDrawBuffers :: (count: s32) #foreign raylib_native;
rlBlitFramebuffer :: (srcX: s32, srcY: s32, srcWidth: s32, srcHeight: s32, dstX: s32, dstY: s32, dstWidth: s32, dstHeight: s32, bufferMask: s32) #foreign raylib_native;

// General render state
rlEnableColorBlend :: () #foreign raylib_native;
rlDisableColorBlend :: () #foreign raylib_native;
rlEnableDepthTest :: () #foreign raylib_native;
rlDisableDepthTest :: () #foreign raylib_native;
rlEnableDepthMask :: () #foreign raylib_native;
rlDisableDepthMask :: () #foreign raylib_native;
rlEnableBackfaceCulling :: () #foreign raylib_native;
rlDisableBackfaceCulling :: () #foreign raylib_native;
rlSetCullFace :: (mode: s32) #foreign raylib_native;
rlEnableScissorTest :: () #foreign raylib_native;
rlDisableScissorTest :: () #foreign raylib_native;
rlScissor :: (x: s32, y: s32, width: s32, height: s32) #foreign raylib_native;
rlEnableWireMode :: () #foreign raylib_native;
rlEnablePointMode :: () #foreign raylib_native;
rlDisableWireMode :: () #foreign raylib_native;
rlSetLineWidth :: (width: float) #foreign raylib_native;
rlGetLineWidth :: () -> float #foreign raylib_native;
rlEnableSmoothLines :: () #foreign raylib_native;
rlDisableSmoothLines :: () #foreign raylib_native;
rlEnableStereoRender :: () #foreign raylib_native;
rlDisableStereoRender :: () #foreign raylib_native;
rlIsStereoRenderEnabled :: () -> bool #foreign raylib_native;

rlClearColor :: (r: u8, g: u8, b: u8, a: u8) #foreign raylib_native;
rlClearScreenBuffers :: () #foreign raylib_native;
rlCheckErrors :: () #foreign raylib_native;
rlSetBlendMode :: (mode: s32) #foreign raylib_native;
rlSetBlendFactors :: (glSrcFactor: s32, glDstFactor: s32, glEquation: s32) #foreign raylib_native;
rlSetBlendFactorsSeparate :: (glSrcRGB: s32, glDstRGB: s32, glSrcAlpha: s32, glDstAlpha: s32, glEqRGB: s32, glEqAlpha: s32) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Functions Declaration - rlgl functionality
//------------------------------------------------------------------------------------
// rlgl initialization functions
rlglInit :: (width: s32, height: s32) #foreign raylib_native;
rlglClose :: () #foreign raylib_native;
rlLoadExtensions :: (loader: *void) #foreign raylib_native;
rlGetVersion :: () -> s32 #foreign raylib_native;
rlSetFramebufferWidth :: (width: s32) #foreign raylib_native;
rlGetFramebufferWidth :: () -> s32 #foreign raylib_native;
rlSetFramebufferHeight :: (height: s32) #foreign raylib_native;
rlGetFramebufferHeight :: () -> s32 #foreign raylib_native;

rlGetTextureIdDefault :: () -> u32 #foreign raylib_native;
rlGetShaderIdDefault :: () -> u32 #foreign raylib_native;
rlGetShaderLocsDefault :: () -> *s32 #foreign raylib_native;

// Render batch management
// NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
// but this render batch API is exposed in case of custom batches are required
rlLoadRenderBatch :: (numBuffers: s32, bufferElements: s32) -> rlRenderBatch #foreign raylib_native;
rlUnloadRenderBatch :: (batch: rlRenderBatch) #foreign raylib_native;
rlDrawRenderBatch :: (batch: *rlRenderBatch) #foreign raylib_native;
rlSetRenderBatchActive :: (batch: *rlRenderBatch) #foreign raylib_native;
rlDrawRenderBatchActive :: () #foreign raylib_native;
rlCheckRenderBatchLimit :: (vCount: s32) -> bool #foreign raylib_native;

rlSetTexture :: (id: u32) #foreign raylib_native;

//------------------------------------------------------------------------------------------------------------------------

// Vertex buffers management
rlLoadVertexArray :: () -> u32 #foreign raylib_native;
rlLoadVertexBuffer :: (buffer: *void, size: s32, dynamic: bool) -> u32 #foreign raylib_native;
rlLoadVertexBufferElement :: (buffer: *void, size: s32, dynamic: bool) -> u32 #foreign raylib_native;
rlUpdateVertexBuffer :: (bufferId: u32, data: *void, dataSize: s32, offset: s32) #foreign raylib_native;
rlUpdateVertexBufferElements :: (id: u32, data: *void, dataSize: s32, offset: s32) #foreign raylib_native;
rlUnloadVertexArray :: (vaoId: u32) #foreign raylib_native;
rlUnloadVertexBuffer :: (vboId: u32) #foreign raylib_native;
rlSetVertexAttribute :: (index: u32, compSize: s32, type: s32, normalized: bool, stride: s32, pointer: *void) #foreign raylib_native;
rlSetVertexAttributeDivisor :: (index: u32, divisor: s32) #foreign raylib_native;
rlSetVertexAttributeDefault :: (locIndex: s32, value: *void, attribType: s32, count: s32) #foreign raylib_native;
rlDrawVertexArray :: (offset: s32, count: s32) #foreign raylib_native;
rlDrawVertexArrayElements :: (offset: s32, count: s32, buffer: *void) #foreign raylib_native;
rlDrawVertexArrayInstanced :: (offset: s32, count: s32, instances: s32) #foreign raylib_native;
rlDrawVertexArrayElementsInstanced :: (offset: s32, count: s32, buffer: *void, instances: s32) #foreign raylib_native;

// Textures management
rlLoadTexture :: (data: *void, width: s32, height: s32, format: s32, mipmapCount: s32) -> u32 #foreign raylib_native;
rlLoadTextureDepth :: (width: s32, height: s32, useRenderBuffer: bool) -> u32 #foreign raylib_native;
rlLoadTextureCubemap :: (data: *void, size: s32, format: s32) -> u32 #foreign raylib_native;
rlUpdateTexture :: (id: u32, offsetX: s32, offsetY: s32, width: s32, height: s32, format: s32, data: *void) #foreign raylib_native;
rlGetGlTextureFormats :: (format: s32, glInternalFormat: *u32, glFormat: *u32, glType: *u32) #foreign raylib_native;
rlGetPixelFormatName :: (format: u32) -> *u8 #foreign raylib_native;
rlUnloadTexture :: (id: u32) #foreign raylib_native;
rlGenTextureMipmaps :: (id: u32, width: s32, height: s32, format: s32, mipmaps: *s32) #foreign raylib_native;
rlReadTexturePixels :: (id: u32, width: s32, height: s32, format: s32) -> *void #foreign raylib_native;
rlReadScreenPixels :: (width: s32, height: s32) -> *u8 #foreign raylib_native;

// Framebuffer management (fbo)
rlLoadFramebuffer :: (width: s32, height: s32) -> u32 #foreign raylib_native;
rlFramebufferAttach :: (fboId: u32, texId: u32, attachType: s32, texType: s32, mipLevel: s32) #foreign raylib_native;
rlFramebufferComplete :: (id: u32) -> bool #foreign raylib_native;
rlUnloadFramebuffer :: (id: u32) #foreign raylib_native;

// Shaders management
rlLoadShaderCode :: (vsCode: *u8, fsCode: *u8) -> u32 #foreign raylib_native;
rlCompileShader :: (shaderCode: *u8, type: s32) -> u32 #foreign raylib_native;
rlLoadShaderProgram :: (vShaderId: u32, fShaderId: u32) -> u32 #foreign raylib_native;
rlUnloadShaderProgram :: (id: u32) #foreign raylib_native;
rlGetLocationUniform :: (shaderId: u32, uniformName: *u8) -> s32 #foreign raylib_native;
rlGetLocationAttrib :: (shaderId: u32, attribName: *u8) -> s32 #foreign raylib_native;
rlSetUniform :: (locIndex: s32, value: *void, uniformType: s32, count: s32) #foreign raylib_native;
rlSetUniformMatrix :: (locIndex: s32, mat: Matrix4) #foreign raylib_native;
rlSetUniformSampler :: (locIndex: s32, textureId: u32) #foreign raylib_native;
rlSetShader :: (id: u32, locs: *s32) #foreign raylib_native;

// Compute shader management
rlLoadComputeShaderProgram :: (shaderId: u32) -> u32 #foreign raylib_native;
rlComputeShaderDispatch :: (groupX: u32, groupY: u32, groupZ: u32) #foreign raylib_native;

// Shader buffer storage object management (ssbo)
rlLoadShaderBuffer :: (size: u32, data: *void, usageHint: s32) -> u32 #foreign raylib_native;
rlUnloadShaderBuffer :: (ssboId: u32) #foreign raylib_native;
rlUpdateShaderBuffer :: (id: u32, data: *void, dataSize: u32, offset: u32) #foreign raylib_native;
rlBindShaderBuffer :: (id: u32, index: u32) #foreign raylib_native;
rlReadShaderBuffer :: (id: u32, dest: *void, count: u32, offset: u32) #foreign raylib_native;
rlCopyShaderBuffer :: (destId: u32, srcId: u32, destOffset: u32, srcOffset: u32, count: u32) #foreign raylib_native;
rlGetShaderBufferSize :: (id: u32) -> u32 #foreign raylib_native;

// Buffer management
rlBindImageTexture :: (id: u32, index: u32, format: s32, readonly: bool) #foreign raylib_native;

// Matrix state management
rlGetMatrixModelview :: () -> Matrix4 #foreign raylib_native;
rlGetMatrixProjection :: () -> Matrix4 #foreign raylib_native;
rlGetMatrixTransform :: () -> Matrix4 #foreign raylib_native;
rlGetMatrixProjectionStereo :: (eye: s32) -> Matrix4 #foreign raylib_native;
rlGetMatrixViewOffsetStereo :: (eye: s32) -> Matrix4 #foreign raylib_native;
rlSetMatrixProjection :: (proj: Matrix4) #foreign raylib_native;
rlSetMatrixModelview :: (view: Matrix4) #foreign raylib_native;
rlSetMatrixProjectionStereo :: (right: Matrix4, left: Matrix4) #foreign raylib_native;
rlSetMatrixViewOffsetStereo :: (right: Matrix4, left: Matrix4) #foreign raylib_native;

// Quick and dirty cube/quad buffers load->draw->unload
rlLoadDrawCube :: () #foreign raylib_native;
rlLoadDrawQuad :: () #foreign raylib_native;



