/*
***********************************************************************************************
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
***********************************************************************************************
*/




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
Vector2 :: struct {
    x: float;                 // Vector x component
    y: float;                 // Vector y component
}

// Vector3, 3 components
Vector3 :: struct {
    x: float;                 // Vector x component
    y: float;                 // Vector y component
    z: float;                 // Vector z component
}

// Vector4, 4 components
Vector4 :: struct {
    x: float;                 // Vector x component
    y: float;                 // Vector y component
    z: float;                 // Vector z component
    w: float;                 // Vector w component
}

// Quaternion, 4 components (Vector4 alias)

// Matrix, 4x4 components, column major, OpenGL style, right-handed
Matrix :: struct {
    m0, m4, m8, m12: float;   // Matrix first row (4 components)
    m1, m5, m9, m13: float;   // Matrix second row (4 components)
    m2, m6, m10, m14: float;  // Matrix third row (4 components)
    m3, m7, m11, m15: float;  // Matrix fourth row (4 components)
}

// Color, 4 components, R8G8B8A8 (32bit)
Color :: struct {
    r: u8;         // Color red value
    g: u8;         // Color green value
    b: u8;         // Color blue value
    a: u8;         // Color alpha value
}

// Rectangle, 4 components
Rectangle :: struct {
    x: float;                 // Rectangle top-left corner position x
    y: float;                 // Rectangle top-left corner position y
    width: float;             // Rectangle width
    height: float;            // Rectangle height
}

// Image, pixel data stored in CPU memory (RAM)
Image :: struct {
    data: *void;              // Image raw data
    width: s32;               // Image base width
    height: s32;              // Image base height
    mipmaps: s32;             // Mipmap levels, 1 by default
    format: s32;              // Data format (PixelFormat type)
}

// Texture, tex data stored in GPU memory (VRAM)
Texture :: struct {
    id: u32;         // OpenGL texture id
    width: s32;               // Texture base width
    height: s32;              // Texture base height
    mipmaps: s32;             // Mipmap levels, 1 by default
    format: s32;              // Data format (PixelFormat type)
}

// Texture2D, same as Texture

// TextureCubemap, same as Texture

// RenderTexture, fbo for texture rendering
RenderTexture :: struct {
    id: u32;         // OpenGL framebuffer object id
    texture: Texture;         // Color buffer attachment texture
    depth: Texture;           // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture

// NPatchInfo, n-patch layout info
NPatchInfo :: struct {
    source: Rectangle;        // Texture source rectangle
    left: s32;                // Left border offset
    top: s32;                 // Top border offset
    right: s32;               // Right border offset
    bottom: s32;              // Bottom border offset
    layout: s32;              // Layout of the n-patch: 3x3, 1x3 or 3x1
}

// GlyphInfo, font characters glyphs info
GlyphInfo :: struct {
    value: s32;               // Character value (Unicode)
    offsetX: s32;             // Character offset X when drawing
    offsetY: s32;             // Character offset Y when drawing
    advanceX: s32;            // Character advance position X
    image: Image;             // Character image data
}

// Font, font texture and GlyphInfo array data
Font :: struct {
    baseSize: s32;            // Base size (default chars height)
    glyphCount: s32;          // Number of glyph characters
    glyphPadding: s32;        // Padding around the glyph characters
    texture: Texture2D;       // Texture atlas containing the glyphs
    recs: *Rectangle;         // Rectangles in texture for the glyphs
    glyphs: *GlyphInfo;       // Glyphs info data
}

// Camera, defines position/orientation in 3d space
Camera3D :: struct {
    position: Vector3;        // Camera position
    target: Vector3;          // Camera target it looks-at
    up: Vector3;              // Camera up vector (rotation over its axis)
    fovy: float;              // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane width in orthographic
    projection: s32;          // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}


// Camera2D, defines position/orientation in 2d space
Camera2D :: struct {
    offset: Vector2;          // Camera offset (displacement from target)
    target: Vector2;          // Camera target (rotation and zoom origin)
    rotation: float;          // Camera rotation in degrees
    zoom: float;              // Camera zoom (scaling), should be 1.0f by default
}

// Mesh, vertex data and vao/vbo
Mesh :: struct {
    vertexCount: s32;         // Number of vertices stored in arrays
    triangleCount: s32;       // Number of triangles stored (indexed or not)

    // Vertex attributes data
    vertices: *float;         // Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords: *float;        // Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    texcoords2: *float;       // Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
    normals: *float;          // Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
    tangents: *float;         // Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
    colors: *u8;       // Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices: *u16;     // Vertex indices (in case vertex data comes indexed)

    // Animation vertex data
    animVertices: *float;     // Animated vertex positions (after bones transformations)
    animNormals: *float;      // Animated normals (after bones transformations)
    boneIds: *u8;  // Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning)
    boneWeights: *float;      // Vertex bone weight, up to 4 bones influence by vertex (skinning)

    // OpenGL identifiers
    vaoId: u32;      // OpenGL Vertex Array Object id
    vboId: *u32;     // OpenGL Vertex Buffer Objects id (default vertex data)
}

// Shader
Shader :: struct {
    id: u32;         // Shader program id
    locs: *s32;               // Shader locations array (RL_MAX_SHADER_LOCATIONS)
}

// MaterialMap
MaterialMap :: struct {
    texture: Texture2D;       // Material map texture
    color: Color;             // Material map color
    value: float;             // Material map value
}

// Material, includes shader and maps
Material :: struct {
    shader: Shader;           // Material shader
    maps: *MaterialMap;       // Material maps array (MAX_MATERIAL_MAPS)
    params: [4]float;         // Material generic parameters (if required)
}

// Transform, vertex transformation data
Transform :: struct {
    translation: Vector3;     // Translation
    rotation: Quaternion;     // Rotation
    scale: Vector3;           // Scale
}

// Bone, skeletal animation bone
BoneInfo :: struct {
    name: [32]s8;           // Bone name
    parent: s32;              // Bone parent
}

// Model, meshes, materials and animation data
Model :: struct {
    transform: Matrix4;        // Local transform matrix

    meshCount: s32;           // Number of meshes
    materialCount: s32;       // Number of materials
    meshes: *Mesh;            // Meshes array
    materials: *Material;     // Materials array
    meshMaterial: *s32;       // Mesh material number

    // Animation data
    boneCount: s32;           // Number of bones
    bones: *BoneInfo;         // Bones information (skeleton)
    bindPose: *Transform;     // Bones base transformation (pose)
}

// ModelAnimation
ModelAnimation :: struct {
    boneCount: s32;           // Number of bones
    frameCount: s32;          // Number of animation frames
    bones: *BoneInfo;         // Bones information (skeleton)
    framePoses: **Transform;  // Poses array by frame
    name: [32]s8;           // Animation name
}

// Ray, ray for raycasting
Ray :: struct {
    position: Vector3;        // Ray position (origin)
    direction: Vector3;       // Ray direction
}

// RayCollision, ray hit information
RayCollision :: struct {
    hit: bool;                // Did the ray hit something?
    distance: float;          // Distance to the nearest hit
    point: Vector3;           // Point of the nearest hit
    normal: Vector3;          // Surface normal of hit
}

// BoundingBox
BoundingBox :: struct {
    min: Vector3;             // Minimum vertex box-corner
    max: Vector3;             // Maximum vertex box-corner
}

// Wave, audio wave data
Wave :: struct {
    frameCount: u32;     // Total number of frames (considering channels)
    sampleRate: u32;     // Frequency (samples per second)
    sampleSize: u32;     // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels: u32;       // Number of channels (1-mono, 2-stereo, ...)
    data: *void;                  // Buffer data pointer
}

// Opaque structs declaration
// NOTE: Actual structs are defined internally in raudio module
// TODO: parse this line. typedef struct rAudioBuffer rAudioBuffer;
// TODO: parse this line. typedef struct rAudioProcessor rAudioProcessor;

// AudioStream, custom audio stream
AudioStream :: struct {
    buffer: *rAudioBuffer;        // Pointer to internal data used by the audio system
    processor: *rAudioProcessor;  // Pointer to internal data processor, useful for audio effects

    sampleRate: u32;     // Frequency (samples per second)
    sampleSize: u32;     // Bit depth (bits per sample): 8, 16, 32 (24 not supported)
    channels: u32;       // Number of channels (1-mono, 2-stereo, ...)
}

// Sound
Sound :: struct {
    stream: AudioStream;          // Audio stream
    frameCount: u32;     // Total number of frames (considering channels)
}

// Music, audio stream, anything longer than ~10 seconds should be streamed
Music :: struct {
    stream: AudioStream;          // Audio stream
    frameCount: u32;     // Total number of frames (considering channels)
    looping: bool;                // Music looping enable

    ctxType: s32;                 // Type of music context (audio filetype)
    ctxData: *void;               // Audio context data, depends on type
}

// VrDeviceInfo, Head-Mounted-Display device parameters
VrDeviceInfo :: struct {
    hResolution: s32;                 // Horizontal resolution in pixels
    vResolution: s32;                 // Vertical resolution in pixels
    hScreenSize: float;               // Horizontal size in meters
    vScreenSize: float;               // Vertical size in meters
    vScreenCenter: float;             // Screen center in meters
    eyeToScreenDistance: float;       // Distance between eye and display in meters
    lensSeparationDistance: float;    // Lens separation distance in meters
    interpupillaryDistance: float;    // IPD (distance between pupils) in meters
    lensDistortionValues: [4]float;   // Lens distortion constant parameters
    chromaAbCorrection: [4]float;     // Chromatic aberration correction parameters
}

// VrStereoConfig, VR stereo rendering configuration for simulator
VrStereoConfig :: struct {
    projection: [2]Matrix4;            // VR projection matrices (per eye)
    viewOffset: [2]Matrix4;            // VR view offset matrices (per eye)
    leftLensCenter: [2]float;         // VR left lens center
    rightLensCenter: [2]float;        // VR right lens center
    leftScreenCenter: [2]float;       // VR left screen center
    rightScreenCenter: [2]float;      // VR right screen center
    scale: [2]float;                  // VR distortion scale
    scaleIn: [2]float;                // VR distortion scale in
}

// File path list
FilePathList :: struct {
    capacity: u32;           // Filepaths max entries
    count: u32;              // Filepaths entries count
    paths: **s8;                    // Filepaths entries
}

// Automation event
AutomationEvent :: struct {
    frame: u32;              // Event frame
    type: u32;               // Event type (AutomationEventType)
    params: [4]s32;                   // Event parameters (if required)
}

// Automation event list
AutomationEventList :: struct {
    capacity: u32;           // Events max entries (MAX_AUTOMATION_EVENTS)
    count: u32;              // Events entries count
    events: *AutomationEvent;         // Events entries
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




