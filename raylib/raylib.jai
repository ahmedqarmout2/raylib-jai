/**********************************************************************************************
*
*   raylib v5.0 - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
*                        MacOS, Haiku, Android, Raspberry Pi, DRM native, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3, 4.3 or ES2 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, XNA fonts, AngelCode fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Animated 3D models supported (skeletal bones animation) (IQM)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, XM, MOD)
*       - VR stereo rendering with configurable HMD device parameters
*       - Bindings to multiple programming languages available!
*
*   NOTES:
*       - One default Font is loaded on InitWindow()->LoadFontDefault() [core, text]
*       - One default Texture2D is loaded on rlglInit(), 1x1 white pixel R8G8B8A8 [rlgl] (OpenGL 3.3 or ES2)
*       - One default Shader is loaded on rlglInit()->rlLoadShaderDefault() [rlgl] (OpenGL 3.3 or ES2)
*       - One default RenderBatch is loaded on rlglInit()->rlLoadRenderBatch() [rlgl] (OpenGL 3.3 or ES2)
*
*   DEPENDENCIES (included):
*       [rcore] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input (PLATFORM_DESKTOP)
*       [rlgl] glad (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading (PLATFORM_DESKTOP)
*       [raudio] miniaudio (David Reid - github.com/mackron/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [rcore] msf_gif (Miles Fogle) for GIF recording
*       [rcore] sinfl (Micha Mettke) for DEFLATE decompression algorithm
*       [rcore] sdefl (Micha Mettke) for DEFLATE compression algorithm
*       [rtextures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [rtextures] stb_image_write (Sean Barret) for image writing (BMP, TGA, PNG, JPG)
*       [rtextures] stb_image_resize (Sean Barret) for image resizing algorithms
*       [rtext] stb_truetype (Sean Barret) for ttf fonts loading
*       [rtext] stb_rect_pack (Sean Barret) for rectangles packing
*       [rmodels] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [rmodels] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [rmodels] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [rmodels] Model3D (bzt) for models loading (M3D, https://bztsrc.gitlab.io/model3d)
*       [raudio] dr_wav (David Reid) for WAV audio file loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2023 Ramon Santamaria (@raysan5)
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
**********************************************************************************************/




// Function specifiers in case library is build/used as a shared library (Windows)
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll


//----------------------------------------------------------------------------------
// Some basic Defines
//----------------------------------------------------------------------------------

// Allow custom memory allocators
// NOTE: Require recompiling raylib sources

// NOTE: MSVC C++ compiler does not support compound literals (C99 feature)
// Plain structures in C++ (without constructors) can be initialized with { }
// This is called aggregate initialization (C++11 feature)

// Some compilers (mostly macos clang) default to C++98,
// where aggregate initialization can't be used
// So, give a more clear error stating how to fix this

// NOTE: We set some defines with some data types declared by raylib
// Other modules (raymath, rlgl) also require some of those types, so,
// to be able to use those other modules as standalone (not depending on raylib)
// this defines are very useful for internal check and avoid type (re)definitions

// Some Basic Colors
// NOTE: Custom raylib color palette for amazing visuals on WHITE background


//----------------------------------------------------------------------------------
// Structures Definition
//----------------------------------------------------------------------------------
// Boolean type

// Vector2, 2 components
Vector2 :: {
}

// Vector3, 3 components
Vector3 :: {
}

// Vector4, 4 components
Vector4 :: {
}

// Quaternion, 4 components (Vector4 alias)

// Matrix, 4x4 components, column major, OpenGL style, right-handed
Matrix :: {
}

// Color, 4 components, R8G8B8A8 (32bit)
Color :: {
}

// Rectangle, 4 components
Rectangle :: {
}

// Image, pixel data stored in CPU memory (RAM)
Image :: {
}

// Texture, tex data stored in GPU memory (VRAM)
Texture :: {
}

// Texture2D, same as Texture

// TextureCubemap, same as Texture

// RenderTexture, fbo for texture rendering
RenderTexture :: {
}

// RenderTexture2D, same as RenderTexture

// NPatchInfo, n-patch layout info
NPatchInfo :: {
}

// GlyphInfo, font characters glyphs info
GlyphInfo :: {
}

// Font, font texture and GlyphInfo array data
Font :: {
}

// Camera, defines position/orientation in 3d space
Camera3D :: {
}


// Camera2D, defines position/orientation in 2d space
Camera2D :: {
}

// Mesh, vertex data and vao/vbo
Mesh :: {

    // Vertex attributes data

    // Animation vertex data

    // OpenGL identifiers
}

// Shader
Shader :: {
}

// MaterialMap
MaterialMap :: {
}

// Material, includes shader and maps
Material :: {
}

// Transform, vertex transformation data
Transform :: {
}

// Bone, skeletal animation bone
BoneInfo :: {
}

// Model, meshes, materials and animation data
Model :: {


    // Animation data
}

// ModelAnimation
ModelAnimation :: {
}

// Ray, ray for raycasting
Ray :: {
}

// RayCollision, ray hit information
RayCollision :: {
}

// BoundingBox
BoundingBox :: {
}

// Wave, audio wave data
Wave :: {
}

// Opaque structs declaration
// NOTE: Actual structs are defined internally in raudio module
rAudioBuffer :: {

// AudioStream, custom audio stream


// Sound
Sound :: {
}

// Music, audio stream, anything longer than ~10 seconds should be streamed
Music :: {

}

// VrDeviceInfo, Head-Mounted-Display device parameters
VrDeviceInfo :: {
}

// VrStereoConfig, VR stereo rendering configuration for simulator
VrStereoConfig :: {
}

// File path list
FilePathList :: {
}

// Automation event
AutomationEvent :: {
}

// Automation event list
AutomationEventList :: {
}

//----------------------------------------------------------------------------------
// Enumerators Definition
//----------------------------------------------------------------------------------
// System/Window config flags
// NOTE: Every bit registers one state (use it with bit masks)
// By default all flags are set to 0

// Trace log level
// NOTE: Organized by priority level

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining
// required keys for alternative layouts
    // Alphanumeric keys
    // Function keys
    // Keypad keys
    // Android key buttons

// Add backwards compatibility support for deprecated names

// Mouse buttons

// Mouse cursor

// Gamepad buttons

// Gamepad axis

// Material map index


// Shader location index


// Shader uniform data type

// Shader attribute data types

// Pixel formats
// NOTE: Support depends on OpenGL version and platform

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification

// Texture parameters: wrap mode

// Cubemap layouts

// Font type, defines generation method

// Color blending modes (pre-defined)

// Gesture
// NOTE: Provided as bit-wise flags to enable only desired gestures

// Camera system modes

// Camera projection

// N-patch layout

// Callbacks to hook some internal functions
// WARNING: These callbacks are intended for advance users

//------------------------------------------------------------------------------------
// Global Variables Definition
//------------------------------------------------------------------------------------
// It's lonely here...

//------------------------------------------------------------------------------------
// Window and Graphics Device Functions (Module: core)
//------------------------------------------------------------------------------------


// Window-related functions

// Cursor-related functions

// Drawing-related functions

// VR stereo config functions for VR simulator

// Shader management functions
// NOTE: Shader functionality is not available on OpenGL 1.1

// Screen-space-related functions

// Timing-related functions

// Custom frame control functions
// NOTE: Those functions are intended for advance users that want full control over the frame processing
// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL

// Random values generation functions

// Misc. functions

// NOTE: Following functions implemented in module [utils]
//------------------------------------------------------------------

// Set custom callbacks
// WARNING: Callbacks setup is intended for advance users

// Files management functions
//------------------------------------------------------------------

// File system functions

// Compression/Encoding functionality

// Automation events functionality

//------------------------------------------------------------------------------------
// Input Handling Functions (Module: core)
//------------------------------------------------------------------------------------

// Input-related functions: keyboard

// Input-related functions: gamepads

// Input-related functions: mouse

// Input-related functions: touch

//------------------------------------------------------------------------------------
// Gestures and Touch Handling Functions (Module: rgestures)
//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------
// Camera System Functions (Module: rcamera)
//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------
// Basic Shapes Drawing Functions (Module: shapes)
//------------------------------------------------------------------------------------
// Set texture and rectangle to be used on shapes drawing
// NOTE: It can be useful when using basic shapes and one single font,
// defining a font char white rectangle would allow drawing everything in a single draw call

// Basic shapes drawing functions

// Splines drawing functions

// Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]

// Basic shapes collision detection functions

//------------------------------------------------------------------------------------
// Texture Loading and Drawing Functions (Module: textures)
//------------------------------------------------------------------------------------

// Image loading functions
// NOTE: These functions do not require GPU access

// Image generation functions

// Image manipulation functions

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)

// Texture loading functions
// NOTE: These functions require GPU access

// Texture configuration functions

// Texture drawing functions

// Color/pixel related functions

//------------------------------------------------------------------------------------
// Font Loading and Text Drawing Functions (Module: text)
//------------------------------------------------------------------------------------

// Font loading/unloading functions

// Text drawing functions

// Text font info functions

// Text codepoints management functions (unicode characters)

// Text strings management functions (no UTF-8 strings, only byte chars)
// NOTE: Some strings allocate memory internally for returned strings, just be careful!

//------------------------------------------------------------------------------------
// Basic 3d Shapes Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Basic geometric 3D shapes drawing functions

//------------------------------------------------------------------------------------
// Model 3d Loading and Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Model management functions

// Model drawing functions

// Mesh management functions

// Mesh generation functions

// Material loading/unloading functions

// Model animations loading/unloading functions

// Collision detection functions

//------------------------------------------------------------------------------------
// Audio Loading and Playing Functions (Module: audio)
//------------------------------------------------------------------------------------

// Audio device management functions

// Wave/Sound loading/unloading functions

// Wave/Sound management functions

// Music management functions

// AudioStream management functions




