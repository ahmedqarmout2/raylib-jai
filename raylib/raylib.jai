//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//

#import "Basic";
#import "Math";

/*
***********************************************************************************************
*
*   raylib v5.5 - A simple and easy-to-use library to enjoy videogames programming (www.raylib.com)
*
*   FEATURES:
*       - NO external dependencies, all required libraries included with raylib
*       - Multiplatform: Windows, Linux, FreeBSD, OpenBSD, NetBSD, DragonFly,
*                        MacOS, Haiku, Android, Raspberry Pi, DRM native, HTML5.
*       - Written in plain C code (C99) in PascalCase/camelCase notation
*       - Hardware accelerated with OpenGL (1.1, 2.1, 3.3, 4.3, ES2, ES3 - choose at compile)
*       - Unique OpenGL abstraction layer (usable as standalone module): [rlgl]
*       - Multiple Fonts formats supported (TTF, OTF, FNT, BDF, Sprite fonts)
*       - Outstanding texture formats support, including compressed formats (DXT, ETC, ASTC)
*       - Full 3d support for 3d Shapes, Models, Billboards, Heightmaps and more!
*       - Flexible Materials system, supporting classic maps and PBR maps
*       - Animated 3D models supported (skeletal bones animation) (IQM, M3D, GLTF)
*       - Shaders support, including Model shaders and Postprocessing shaders
*       - Powerful math module for Vector, Matrix and Quaternion operations: [raymath]
*       - Audio loading and playing with streaming support (WAV, OGG, MP3, FLAC, QOA, XM, MOD)
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
*       [rcore][GLFW] rglfw (Camilla Löwy - github.com/glfw/glfw) for window/context management and input
*       [rcore][RGFW] rgfw (ColleagueRiley - github.com/ColleagueRiley/RGFW) for window/context management and input
*       [rlgl] glad/glad_gles2 (David Herberth - github.com/Dav1dde/glad) for OpenGL 3.3 extensions loading
*       [raudio] miniaudio (David Reid - github.com/mackron/miniaudio) for audio device/context management
*
*   OPTIONAL DEPENDENCIES (included):
*       [rcore] msf_gif (Miles Fogle) for GIF recording
*       [rcore] sinfl (Micha Mettke) for DEFLATE decompression algorithm
*       [rcore] sdefl (Micha Mettke) for DEFLATE compression algorithm
*       [rcore] rprand (Ramon Snatamaria) for pseudo-random numbers generation
*       [rtextures] qoi (Dominic Szablewski - https://phoboslab.org) for QOI image manage
*       [rtextures] stb_image (Sean Barret) for images loading (BMP, TGA, PNG, JPEG, HDR...)
*       [rtextures] stb_image_write (Sean Barret) for image writing (BMP, TGA, PNG, JPG)
*       [rtextures] stb_image_resize2 (Sean Barret) for image resizing algorithms
*       [rtextures] stb_perlin (Sean Barret) for Perlin Noise image generation
*       [rtext] stb_truetype (Sean Barret) for ttf fonts loading
*       [rtext] stb_rect_pack (Sean Barret) for rectangles packing
*       [rmodels] par_shapes (Philip Rideout) for parametric 3d shapes generation
*       [rmodels] tinyobj_loader_c (Syoyo Fujita) for models loading (OBJ, MTL)
*       [rmodels] cgltf (Johannes Kuhlmann) for models loading (glTF)
*       [rmodels] m3d (bzt) for models loading (M3D, https://bztsrc.gitlab.io/model3d)
*       [rmodels] vox_loader (Johann Nadalutti) for models loading (VOX)
*       [raudio] dr_wav (David Reid) for WAV audio file loading
*       [raudio] dr_flac (David Reid) for FLAC audio file loading
*       [raudio] dr_mp3 (David Reid) for MP3 audio file loading
*       [raudio] stb_vorbis (Sean Barret) for OGG audio loading
*       [raudio] jar_xm (Joshua Reisenauer) for XM audio module loading
*       [raudio] jar_mod (Joshua Reisenauer) for MOD audio module loading
*       [raudio] qoa (Dominic Szablewski - https://phoboslab.org) for QOA audio manage
*
*
*   LICENSE: zlib/libpng
*
*   raylib is licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software:
*
*   Copyright (c) 2013-2024 Ramon Santamaria (@raysan5)
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



RAYLIB_VERSION_MAJOR :: 5;
RAYLIB_VERSION_MINOR :: 5;
RAYLIB_VERSION_PATCH :: 0;
RAYLIB_VERSION ::  "5.5";

// Function specifiers in case library is build/used as a shared library
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
// NOTE: visibility("default") attribute makes symbols "visible" when compiled with -fvisibility=hidden


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
LIGHTGRAY  :: Color.{ 200, 200, 200, 255 };   // Light Gray
GRAY       :: Color.{ 130, 130, 130, 255 };   // Gray
DARKGRAY   :: Color.{ 80, 80, 80, 255 };      // Dark Gray
YELLOW     :: Color.{ 253, 249, 0, 255 };     // Yellow
GOLD       :: Color.{ 255, 203, 0, 255 };     // Gold
ORANGE     :: Color.{ 255, 161, 0, 255 };     // Orange
PINK       :: Color.{ 255, 109, 194, 255 };   // Pink
RED        :: Color.{ 230, 41, 55, 255 };     // Red
MAROON     :: Color.{ 190, 33, 55, 255 };     // Maroon
GREEN      :: Color.{ 0, 228, 48, 255 };      // Green
LIME       :: Color.{ 0, 158, 47, 255 };      // Lime
DARKGREEN  :: Color.{ 0, 117, 44, 255 };      // Dark Green
SKYBLUE    :: Color.{ 102, 191, 255, 255 };   // Sky Blue
BLUE       :: Color.{ 0, 121, 241, 255 };     // Blue
DARKBLUE   :: Color.{ 0, 82, 172, 255 };      // Dark Blue
PURPLE     :: Color.{ 200, 122, 255, 255 };   // Purple
VIOLET     :: Color.{ 135, 60, 190, 255 };    // Violet
DARKPURPLE :: Color.{ 112, 31, 126, 255 };    // Dark Purple
BEIGE      :: Color.{ 211, 176, 131, 255 };   // Beige
BROWN      :: Color.{ 127, 106, 79, 255 };    // Brown
DARKBROWN  :: Color.{ 76, 63, 47, 255 };      // Dark Brown

WHITE      :: Color.{ 255, 255, 255, 255 };   // White
BLACK      :: Color.{ 0, 0, 0, 255 };         // Black
BLANK      :: Color.{ 0, 0, 0, 0 };           // Blank (Transparent)
MAGENTA    :: Color.{ 255, 0, 255, 255 };     // Magenta
RAYWHITE   :: Color.{ 245, 245, 245, 255 };   // My own White (raylib logo)

//----------------------------------------------------------------------------------
// Structures Definition
//----------------------------------------------------------------------------------
// Boolean type

// Vector2, 2 components
// struct Vector2 is already defined in jai.

// Vector3, 3 components
// struct Vector3 is already defined in jai.

// Vector4, 4 components
// struct Vector4 is already defined in jai.

// Quaternion, 4 components (Vector4 alias)
// struct Quaternion is already defined in jai.

// Matrix, 4x4 components, column major, OpenGL style, right-handed
// struct Matrix is already defined in jai.

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
    format: PixelFormat;              // Data format (PixelFormat type)
}

// Texture, tex data stored in GPU memory (VRAM)
Texture :: struct {
    id: u32;         // OpenGL texture id
    width: s32;               // Texture base width
    height: s32;              // Texture base height
    mipmaps: s32;             // Mipmap levels, 1 by default
    format: PixelFormat;              // Data format (PixelFormat type)
}

// Texture2D, same as Texture
Texture2D :: Texture;

// TextureCubemap, same as Texture
TextureCubemap :: Texture;

// RenderTexture, fbo for texture rendering
RenderTexture :: struct {
    id: u32;         // OpenGL framebuffer object id
    texture: Texture;         // Color buffer attachment texture
    depth: Texture;           // Depth buffer attachment texture
}

// RenderTexture2D, same as RenderTexture
RenderTexture2D :: RenderTexture;

// NPatchInfo, n-patch layout info
NPatchInfo :: struct {
    source: Rectangle;        // Texture source rectangle
    left: s32;                // Left border offset
    top: s32;                 // Top border offset
    right: s32;               // Right border offset
    bottom: s32;              // Bottom border offset
    layout: NPatchLayout;              // Layout of the n-patch: 3x3, 1x3 or 3x1
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
    projection: CameraProjection;          // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

Camera :: Camera3D;

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
    boneIds: *u8;  // Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
    boneWeights: *float;      // Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
    boneMatrices: *Matrix4;    // Bones animated transformation matrices
    boneCount: s32;           // Number of bones

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
    name: [32]u8;           // Bone name
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
    name: [32]u8;           // Animation name
}

// Ray, ray for raycasting
Ray :: struct {
    position: Vector3;        // Ray position (origin)
    direction: Vector3;       // Ray direction (normalized)
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
rAudioBuffer :: struct { /* only used as a pointer in this header */ }
rAudioProcessor :: struct { /* only used as a pointer in this header */ }

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
    paths: **u8;                    // Filepaths entries
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
ConfigFlags :: enum s32 {
    FLAG_VSYNC_HINT         :: 0x00000040;   // Set to try enabling V-Sync on GPU
    FLAG_FULLSCREEN_MODE    :: 0x00000002;   // Set to run program in fullscreen
    FLAG_WINDOW_RESIZABLE   :: 0x00000004;   // Set to allow resizable window
    FLAG_WINDOW_UNDECORATED :: 0x00000008;   // Set to disable window decoration (frame and buttons)
    FLAG_WINDOW_HIDDEN      :: 0x00000080;   // Set to hide window
    FLAG_WINDOW_MINIMIZED   :: 0x00000200;   // Set to minimize window (iconify)
    FLAG_WINDOW_MAXIMIZED   :: 0x00000400;   // Set to maximize window (expanded to monitor)
    FLAG_WINDOW_UNFOCUSED   :: 0x00000800;   // Set to window non focused
    FLAG_WINDOW_TOPMOST     :: 0x00001000;   // Set to window always on top
    FLAG_WINDOW_ALWAYS_RUN  :: 0x00000100;   // Set to allow windows running while minimized
    FLAG_WINDOW_TRANSPARENT :: 0x00000010;   // Set to allow transparent framebuffer
    FLAG_WINDOW_HIGHDPI     :: 0x00002000;   // Set to support HighDPI
    FLAG_WINDOW_MOUSE_PASSTHROUGH :: 0x00004000; // Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    FLAG_BORDERLESS_WINDOWED_MODE :: 0x00008000; // Set to run program in borderless windowed mode
    FLAG_MSAA_4X_HINT       :: 0x00000020;   // Set to try enabling MSAA 4X
    FLAG_INTERLACED_HINT    :: 0x00010000;    // Set to try enabling interlaced video format (for V3D)
}

// Trace log level
// NOTE: Organized by priority level
TraceLogLevel :: enum s32 {
    LOG_ALL :: 0;        // Display all logs
    LOG_TRACE;          // Trace logging, intended for internal use only
    LOG_DEBUG;          // Debug logging, used for internal debugging, it should be disabled on release builds
    LOG_INFO;           // Info logging, used for program execution info
    LOG_WARNING;        // Warning logging, used on recoverable failures
    LOG_ERROR;          // Error logging, used on unrecoverable failures
    LOG_FATAL;          // Fatal logging, used to abort program: exit(EXIT_FAILURE)
    LOG_NONE;            // Disable logging
}

// Keyboard keys (US keyboard layout)
// NOTE: Use GetKeyPressed() to allow redefining
// required keys for alternative layouts
KeyboardKey :: enum s32 {
    KEY_NULL            :: 0;        // Key: NULL, used for no key pressed
    // Alphanumeric keys
    KEY_APOSTROPHE      :: 39;       // Key: '
    KEY_COMMA           :: 44;       // Key: ,
    KEY_MINUS           :: 45;       // Key: -
    KEY_PERIOD          :: 46;       // Key: .
    KEY_SLASH           :: 47;       // Key: /
    KEY_ZERO            :: 48;       // Key: 0
    KEY_ONE             :: 49;       // Key: 1
    KEY_TWO             :: 50;       // Key: 2
    KEY_THREE           :: 51;       // Key: 3
    KEY_FOUR            :: 52;       // Key: 4
    KEY_FIVE            :: 53;       // Key: 5
    KEY_SIX             :: 54;       // Key: 6
    KEY_SEVEN           :: 55;       // Key: 7
    KEY_EIGHT           :: 56;       // Key: 8
    KEY_NINE            :: 57;       // Key: 9
    KEY_SEMICOLON       :: 59;       // Key: ;
    KEY_EQUAL           :: 61;       // Key: =
    KEY_A               :: 65;       // Key: A | a
    KEY_B               :: 66;       // Key: B | b
    KEY_C               :: 67;       // Key: C | c
    KEY_D               :: 68;       // Key: D | d
    KEY_E               :: 69;       // Key: E | e
    KEY_F               :: 70;       // Key: F | f
    KEY_G               :: 71;       // Key: G | g
    KEY_H               :: 72;       // Key: H | h
    KEY_I               :: 73;       // Key: I | i
    KEY_J               :: 74;       // Key: J | j
    KEY_K               :: 75;       // Key: K | k
    KEY_L               :: 76;       // Key: L | l
    KEY_M               :: 77;       // Key: M | m
    KEY_N               :: 78;       // Key: N | n
    KEY_O               :: 79;       // Key: O | o
    KEY_P               :: 80;       // Key: P | p
    KEY_Q               :: 81;       // Key: Q | q
    KEY_R               :: 82;       // Key: R | r
    KEY_S               :: 83;       // Key: S | s
    KEY_T               :: 84;       // Key: T | t
    KEY_U               :: 85;       // Key: U | u
    KEY_V               :: 86;       // Key: V | v
    KEY_W               :: 87;       // Key: W | w
    KEY_X               :: 88;       // Key: X | x
    KEY_Y               :: 89;       // Key: Y | y
    KEY_Z               :: 90;       // Key: Z | z
    KEY_LEFT_BRACKET    :: 91;       // Key: [
    KEY_BACKSLASH       :: 92;       // Key: '\'
    KEY_RIGHT_BRACKET   :: 93;       // Key: ]
    KEY_GRAVE           :: 96;       // Key: `
    // Function keys
    KEY_SPACE           :: 32;       // Key: Space
    KEY_ESCAPE          :: 256;      // Key: Esc
    KEY_ENTER           :: 257;      // Key: Enter
    KEY_TAB             :: 258;      // Key: Tab
    KEY_BACKSPACE       :: 259;      // Key: Backspace
    KEY_INSERT          :: 260;      // Key: Ins
    KEY_DELETE          :: 261;      // Key: Del
    KEY_RIGHT           :: 262;      // Key: Cursor right
    KEY_LEFT            :: 263;      // Key: Cursor left
    KEY_DOWN            :: 264;      // Key: Cursor down
    KEY_UP              :: 265;      // Key: Cursor up
    KEY_PAGE_UP         :: 266;      // Key: Page up
    KEY_PAGE_DOWN       :: 267;      // Key: Page down
    KEY_HOME            :: 268;      // Key: Home
    KEY_END             :: 269;      // Key: End
    KEY_CAPS_LOCK       :: 280;      // Key: Caps lock
    KEY_SCROLL_LOCK     :: 281;      // Key: Scroll down
    KEY_NUM_LOCK        :: 282;      // Key: Num lock
    KEY_PRINT_SCREEN    :: 283;      // Key: Print screen
    KEY_PAUSE           :: 284;      // Key: Pause
    KEY_F1              :: 290;      // Key: F1
    KEY_F2              :: 291;      // Key: F2
    KEY_F3              :: 292;      // Key: F3
    KEY_F4              :: 293;      // Key: F4
    KEY_F5              :: 294;      // Key: F5
    KEY_F6              :: 295;      // Key: F6
    KEY_F7              :: 296;      // Key: F7
    KEY_F8              :: 297;      // Key: F8
    KEY_F9              :: 298;      // Key: F9
    KEY_F10             :: 299;      // Key: F10
    KEY_F11             :: 300;      // Key: F11
    KEY_F12             :: 301;      // Key: F12
    KEY_LEFT_SHIFT      :: 340;      // Key: Shift left
    KEY_LEFT_CONTROL    :: 341;      // Key: Control left
    KEY_LEFT_ALT        :: 342;      // Key: Alt left
    KEY_LEFT_SUPER      :: 343;      // Key: Super left
    KEY_RIGHT_SHIFT     :: 344;      // Key: Shift right
    KEY_RIGHT_CONTROL   :: 345;      // Key: Control right
    KEY_RIGHT_ALT       :: 346;      // Key: Alt right
    KEY_RIGHT_SUPER     :: 347;      // Key: Super right
    KEY_KB_MENU         :: 348;      // Key: KB menu
    // Keypad keys
    KEY_KP_0            :: 320;      // Key: Keypad 0
    KEY_KP_1            :: 321;      // Key: Keypad 1
    KEY_KP_2            :: 322;      // Key: Keypad 2
    KEY_KP_3            :: 323;      // Key: Keypad 3
    KEY_KP_4            :: 324;      // Key: Keypad 4
    KEY_KP_5            :: 325;      // Key: Keypad 5
    KEY_KP_6            :: 326;      // Key: Keypad 6
    KEY_KP_7            :: 327;      // Key: Keypad 7
    KEY_KP_8            :: 328;      // Key: Keypad 8
    KEY_KP_9            :: 329;      // Key: Keypad 9
    KEY_KP_DECIMAL      :: 330;      // Key: Keypad .
    KEY_KP_DIVIDE       :: 331;      // Key: Keypad /
    KEY_KP_MULTIPLY     :: 332;      // Key: Keypad *
    KEY_KP_SUBTRACT     :: 333;      // Key: Keypad -
    KEY_KP_ADD          :: 334;      // Key: Keypad +
    KEY_KP_ENTER        :: 335;      // Key: Keypad Enter
    KEY_KP_EQUAL        :: 336;      // Key: Keypad =
    // Android key buttons
    KEY_BACK            :: 4;        // Key: Android back button
    KEY_MENU            :: 5;        // Key: Android menu button
    KEY_VOLUME_UP       :: 24;       // Key: Android volume up button
    KEY_VOLUME_DOWN     :: 25;        // Key: Android volume down button
}

// Add backwards compatibility support for deprecated names
MOUSE_LEFT_BUTTON   :: MouseButton.MOUSE_BUTTON_LEFT;
MOUSE_RIGHT_BUTTON  :: MouseButton.MOUSE_BUTTON_RIGHT;
MOUSE_MIDDLE_BUTTON :: MouseButton.MOUSE_BUTTON_MIDDLE;

// Mouse buttons
MouseButton :: enum s32 {
    MOUSE_BUTTON_LEFT    :: 0;       // Mouse button left
    MOUSE_BUTTON_RIGHT   :: 1;       // Mouse button right
    MOUSE_BUTTON_MIDDLE  :: 2;       // Mouse button middle (pressed wheel)
    MOUSE_BUTTON_SIDE    :: 3;       // Mouse button side (advanced mouse device)
    MOUSE_BUTTON_EXTRA   :: 4;       // Mouse button extra (advanced mouse device)
    MOUSE_BUTTON_FORWARD :: 5;       // Mouse button forward (advanced mouse device)
    MOUSE_BUTTON_BACK    :: 6;       // Mouse button back (advanced mouse device)
}

// Mouse cursor
MouseCursor :: enum s32 {
    MOUSE_CURSOR_DEFAULT       :: 0;     // Default pointer shape
    MOUSE_CURSOR_ARROW         :: 1;     // Arrow shape
    MOUSE_CURSOR_IBEAM         :: 2;     // Text writing cursor shape
    MOUSE_CURSOR_CROSSHAIR     :: 3;     // Cross shape
    MOUSE_CURSOR_POINTING_HAND :: 4;     // Pointing hand cursor
    MOUSE_CURSOR_RESIZE_EW     :: 5;     // Horizontal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NS     :: 6;     // Vertical resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NWSE   :: 7;     // Top-left to bottom-right diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NESW   :: 8;     // The top-right to bottom-left diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_ALL    :: 9;     // The omnidirectional resize/move cursor shape
    MOUSE_CURSOR_NOT_ALLOWED   :: 10;     // The operation-not-allowed shape
}

// Gamepad buttons
GamepadButton :: enum s32 {
    GAMEPAD_BUTTON_UNKNOWN :: 0;         // Unknown button, just for error checking
    GAMEPAD_BUTTON_LEFT_FACE_UP;        // Gamepad left DPAD up button
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT;     // Gamepad left DPAD right button
    GAMEPAD_BUTTON_LEFT_FACE_DOWN;      // Gamepad left DPAD down button
    GAMEPAD_BUTTON_LEFT_FACE_LEFT;      // Gamepad left DPAD left button
    GAMEPAD_BUTTON_RIGHT_FACE_UP;       // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT;    // Gamepad right button right (i.e. PS3: Circle, Xbox: B)
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN;     // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT;     // Gamepad right button left (i.e. PS3: Square, Xbox: X)
    GAMEPAD_BUTTON_LEFT_TRIGGER_1;      // Gamepad top/back trigger left (first), it could be a trailing button
    GAMEPAD_BUTTON_LEFT_TRIGGER_2;      // Gamepad top/back trigger left (second), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1;     // Gamepad top/back trigger right (first), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2;     // Gamepad top/back trigger right (second), it could be a trailing button
    GAMEPAD_BUTTON_MIDDLE_LEFT;         // Gamepad center buttons, left one (i.e. PS3: Select)
    GAMEPAD_BUTTON_MIDDLE;              // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    GAMEPAD_BUTTON_MIDDLE_RIGHT;        // Gamepad center buttons, right one (i.e. PS3: Start)
    GAMEPAD_BUTTON_LEFT_THUMB;          // Gamepad joystick pressed button left
    GAMEPAD_BUTTON_RIGHT_THUMB;          // Gamepad joystick pressed button right
}

// Gamepad axis
GamepadAxis :: enum s32 {
    GAMEPAD_AXIS_LEFT_X        :: 0;     // Gamepad left stick X axis
    GAMEPAD_AXIS_LEFT_Y        :: 1;     // Gamepad left stick Y axis
    GAMEPAD_AXIS_RIGHT_X       :: 2;     // Gamepad right stick X axis
    GAMEPAD_AXIS_RIGHT_Y       :: 3;     // Gamepad right stick Y axis
    GAMEPAD_AXIS_LEFT_TRIGGER  :: 4;     // Gamepad back trigger left, pressure level: [1..-1]
    GAMEPAD_AXIS_RIGHT_TRIGGER :: 5;      // Gamepad back trigger right, pressure level: [1..-1]
}

// Material map index
MaterialMapIndex :: enum s32 {
    MATERIAL_MAP_ALBEDO :: 0;        // Albedo material (same as: MATERIAL_MAP_DIFFUSE)
    MATERIAL_MAP_METALNESS;         // Metalness material (same as: MATERIAL_MAP_SPECULAR)
    MATERIAL_MAP_NORMAL;            // Normal material
    MATERIAL_MAP_ROUGHNESS;         // Roughness material
    MATERIAL_MAP_OCCLUSION;         // Ambient occlusion material
    MATERIAL_MAP_EMISSION;          // Emission material
    MATERIAL_MAP_HEIGHT;            // Heightmap material
    MATERIAL_MAP_CUBEMAP;           // Cubemap material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_IRRADIANCE;        // Irradiance material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_PREFILTER;         // Prefilter material (NOTE: Uses GL_TEXTURE_CUBE_MAP)
    MATERIAL_MAP_BRDF;               // Brdf material
}

MATERIAL_MAP_DIFFUSE  :: MaterialMapIndex.MATERIAL_MAP_ALBEDO;
MATERIAL_MAP_SPECULAR :: MaterialMapIndex.MATERIAL_MAP_METALNESS;

// Shader location index
ShaderLocationIndex :: enum s32 {
    SHADER_LOC_VERTEX_POSITION :: 0; // Shader location: vertex attribute: position
    SHADER_LOC_VERTEX_TEXCOORD01;   // Shader location: vertex attribute: texcoord01
    SHADER_LOC_VERTEX_TEXCOORD02;   // Shader location: vertex attribute: texcoord02
    SHADER_LOC_VERTEX_NORMAL;       // Shader location: vertex attribute: normal
    SHADER_LOC_VERTEX_TANGENT;      // Shader location: vertex attribute: tangent
    SHADER_LOC_VERTEX_COLOR;        // Shader location: vertex attribute: color
    SHADER_LOC_MATRIX_MVP;          // Shader location: matrix uniform: model-view-projection
    SHADER_LOC_MATRIX_VIEW;         // Shader location: matrix uniform: view (camera transform)
    SHADER_LOC_MATRIX_PROJECTION;   // Shader location: matrix uniform: projection
    SHADER_LOC_MATRIX_MODEL;        // Shader location: matrix uniform: model (transform)
    SHADER_LOC_MATRIX_NORMAL;       // Shader location: matrix uniform: normal
    SHADER_LOC_VECTOR_VIEW;         // Shader location: vector uniform: view
    SHADER_LOC_COLOR_DIFFUSE;       // Shader location: vector uniform: diffuse color
    SHADER_LOC_COLOR_SPECULAR;      // Shader location: vector uniform: specular color
    SHADER_LOC_COLOR_AMBIENT;       // Shader location: vector uniform: ambient color
    SHADER_LOC_MAP_ALBEDO;          // Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    SHADER_LOC_MAP_METALNESS;       // Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    SHADER_LOC_MAP_NORMAL;          // Shader location: sampler2d texture: normal
    SHADER_LOC_MAP_ROUGHNESS;       // Shader location: sampler2d texture: roughness
    SHADER_LOC_MAP_OCCLUSION;       // Shader location: sampler2d texture: occlusion
    SHADER_LOC_MAP_EMISSION;        // Shader location: sampler2d texture: emission
    SHADER_LOC_MAP_HEIGHT;          // Shader location: sampler2d texture: height
    SHADER_LOC_MAP_CUBEMAP;         // Shader location: samplerCube texture: cubemap
    SHADER_LOC_MAP_IRRADIANCE;      // Shader location: samplerCube texture: irradiance
    SHADER_LOC_MAP_PREFILTER;       // Shader location: samplerCube texture: prefilter
    SHADER_LOC_MAP_BRDF;            // Shader location: sampler2d texture: brdf
    SHADER_LOC_VERTEX_BONEIDS;      // Shader location: vertex attribute: boneIds
    SHADER_LOC_VERTEX_BONEWEIGHTS;  // Shader location: vertex attribute: boneWeights
    SHADER_LOC_BONE_MATRICES;        // Shader location: array of matrices uniform: boneMatrices
}

SHADER_LOC_MAP_DIFFUSE  :: ShaderLocationIndex.SHADER_LOC_MAP_ALBEDO;
SHADER_LOC_MAP_SPECULAR :: ShaderLocationIndex.SHADER_LOC_MAP_METALNESS;

// Shader uniform data type
ShaderUniformDataType :: enum s32 {
    SHADER_UNIFORM_FLOAT :: 0;       // Shader uniform type: float
    SHADER_UNIFORM_VEC2;            // Shader uniform type: vec2 (2 float)
    SHADER_UNIFORM_VEC3;            // Shader uniform type: vec3 (3 float)
    SHADER_UNIFORM_VEC4;            // Shader uniform type: vec4 (4 float)
    SHADER_UNIFORM_INT;             // Shader uniform type: int
    SHADER_UNIFORM_IVEC2;           // Shader uniform type: ivec2 (2 int)
    SHADER_UNIFORM_IVEC3;           // Shader uniform type: ivec3 (3 int)
    SHADER_UNIFORM_IVEC4;           // Shader uniform type: ivec4 (4 int)
    SHADER_UNIFORM_SAMPLER2D;        // Shader uniform type: sampler2d
}

// Shader attribute data types
ShaderAttributeDataType :: enum s32 {
    SHADER_ATTRIB_FLOAT :: 0;        // Shader attribute type: float
    SHADER_ATTRIB_VEC2;             // Shader attribute type: vec2 (2 float)
    SHADER_ATTRIB_VEC3;             // Shader attribute type: vec3 (3 float)
    SHADER_ATTRIB_VEC4;              // Shader attribute type: vec4 (4 float)
}

// Pixel formats
// NOTE: Support depends on OpenGL version and platform
PixelFormat :: enum s32 {
    PIXELFORMAT_UNCOMPRESSED_GRAYSCALE :: 1; // 8 bit per pixel (no alpha)
    PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA;    // 8*2 bpp (2 channels)
    PIXELFORMAT_UNCOMPRESSED_R5G6B5;        // 16 bpp
    PIXELFORMAT_UNCOMPRESSED_R8G8B8;        // 24 bpp
    PIXELFORMAT_UNCOMPRESSED_R5G5B5A1;      // 16 bpp (1 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R4G4B4A4;      // 16 bpp (4 bit alpha)
    PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;      // 32 bpp
    PIXELFORMAT_UNCOMPRESSED_R32;           // 32 bpp (1 channel - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32;     // 32*3 bpp (3 channels - float)
    PIXELFORMAT_UNCOMPRESSED_R32G32B32A32;  // 32*4 bpp (4 channels - float)
    PIXELFORMAT_UNCOMPRESSED_R16;           // 16 bpp (1 channel - half float)
    PIXELFORMAT_UNCOMPRESSED_R16G16B16;     // 16*3 bpp (3 channels - half float)
    PIXELFORMAT_UNCOMPRESSED_R16G16B16A16;  // 16*4 bpp (4 channels - half float)
    PIXELFORMAT_COMPRESSED_DXT1_RGB;        // 4 bpp (no alpha)
    PIXELFORMAT_COMPRESSED_DXT1_RGBA;       // 4 bpp (1 bit alpha)
    PIXELFORMAT_COMPRESSED_DXT3_RGBA;       // 8 bpp
    PIXELFORMAT_COMPRESSED_DXT5_RGBA;       // 8 bpp
    PIXELFORMAT_COMPRESSED_ETC1_RGB;        // 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_RGB;        // 4 bpp
    PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA;   // 8 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGB;        // 4 bpp
    PIXELFORMAT_COMPRESSED_PVRT_RGBA;       // 4 bpp
    PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA;   // 8 bpp
    PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA;    // 2 bpp
}

// Texture parameters: filter mode
// NOTE 1: Filtering considers mipmaps if available in the texture
// NOTE 2: Filter is accordingly set for minification and magnification
TextureFilter :: enum s32 {
    TEXTURE_FILTER_POINT :: 0;               // No filter, just pixel approximation
    TEXTURE_FILTER_BILINEAR;                // Linear filtering
    TEXTURE_FILTER_TRILINEAR;               // Trilinear filtering (linear with mipmaps)
    TEXTURE_FILTER_ANISOTROPIC_4X;          // Anisotropic filtering 4x
    TEXTURE_FILTER_ANISOTROPIC_8X;          // Anisotropic filtering 8x
    TEXTURE_FILTER_ANISOTROPIC_16X;         // Anisotropic filtering 16x
}

// Texture parameters: wrap mode
TextureWrap :: enum s32 {
    TEXTURE_WRAP_REPEAT :: 0;                // Repeats texture in tiled mode
    TEXTURE_WRAP_CLAMP;                     // Clamps texture to edge pixel in tiled mode
    TEXTURE_WRAP_MIRROR_REPEAT;             // Mirrors and repeats the texture in tiled mode
    TEXTURE_WRAP_MIRROR_CLAMP;               // Mirrors and clamps to border the texture in tiled mode
}

// Cubemap layouts
CubemapLayout :: enum s32 {
    CUBEMAP_LAYOUT_AUTO_DETECT :: 0;         // Automatically detect layout type
    CUBEMAP_LAYOUT_LINE_VERTICAL;           // Layout is defined by a vertical line with faces
    CUBEMAP_LAYOUT_LINE_HORIZONTAL;         // Layout is defined by a horizontal line with faces
    CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR;     // Layout is defined by a 3x4 cross with cubemap faces
    CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE;     // Layout is defined by a 4x3 cross with cubemap faces
}

// Font type, defines generation method
FontType :: enum s32 {
    FONT_DEFAULT :: 0;               // Default font generation, anti-aliased
    FONT_BITMAP;                    // Bitmap font generation, no anti-aliasing
    FONT_SDF;                        // SDF font generation, requires external shader
}

// Color blending modes (pre-defined)
BlendMode :: enum s32 {
    BLEND_ALPHA :: 0;                // Blend textures considering alpha (default)
    BLEND_ADDITIVE;                 // Blend textures adding colors
    BLEND_MULTIPLIED;               // Blend textures multiplying colors
    BLEND_ADD_COLORS;               // Blend textures adding colors (alternative)
    BLEND_SUBTRACT_COLORS;          // Blend textures subtracting colors (alternative)
    BLEND_ALPHA_PREMULTIPLY;        // Blend premultiplied textures considering alpha
    BLEND_CUSTOM;                   // Blend textures using custom src/dst factors (use rlSetBlendFactors())
    BLEND_CUSTOM_SEPARATE;           // Blend textures using custom rgb/alpha separate src/dst factors (use rlSetBlendFactorsSeparate())
}

// Gesture
// NOTE: Provided as bit-wise flags to enable only desired gestures
Gesture :: enum s32 {
    GESTURE_NONE        :: 0;        // No gesture
    GESTURE_TAP         :: 1;        // Tap gesture
    GESTURE_DOUBLETAP   :: 2;        // Double tap gesture
    GESTURE_HOLD        :: 4;        // Hold gesture
    GESTURE_DRAG        :: 8;        // Drag gesture
    GESTURE_SWIPE_RIGHT :: 16;       // Swipe right gesture
    GESTURE_SWIPE_LEFT  :: 32;       // Swipe left gesture
    GESTURE_SWIPE_UP    :: 64;       // Swipe up gesture
    GESTURE_SWIPE_DOWN  :: 128;      // Swipe down gesture
    GESTURE_PINCH_IN    :: 256;      // Pinch in gesture
    GESTURE_PINCH_OUT   :: 512;       // Pinch out gesture
}

// Camera system modes
CameraMode :: enum s32 {
    CAMERA_CUSTOM :: 0;              // Camera custom, controlled by user (UpdateCamera() does nothing)
    CAMERA_FREE;                    // Camera free mode
    CAMERA_ORBITAL;                 // Camera orbital, around target, zoom supported
    CAMERA_FIRST_PERSON;            // Camera first person
    CAMERA_THIRD_PERSON;             // Camera third person
}

// Camera projection
CameraProjection :: enum s32 {
    CAMERA_PERSPECTIVE :: 0;         // Perspective projection
    CAMERA_ORTHOGRAPHIC;             // Orthographic projection
}

// N-patch layout
NPatchLayout :: enum s32 {
    NPATCH_NINE_PATCH :: 0;          // Npatch layout: 3x3 tiles
    NPATCH_THREE_PATCH_VERTICAL;    // Npatch layout: 1x3 tiles
    NPATCH_THREE_PATCH_HORIZONTAL;   // Npatch layout: 3x1 tiles
}

// Callbacks to hook some internal functions
// WARNING: These callbacks are intended for advanced users

//------------------------------------------------------------------------------------
// Global Variables Definition
//------------------------------------------------------------------------------------
// It's lonely here...

//------------------------------------------------------------------------------------
// Window and Graphics Device Functions (Module: core)
//------------------------------------------------------------------------------------


// Window-related functions
InitWindow :: (width: s32, height: s32, title: *u8) #foreign raylib_native;
CloseWindow :: () #foreign raylib_native;
WindowShouldClose :: () -> bool #foreign raylib_native;
IsWindowReady :: () -> bool #foreign raylib_native;
IsWindowFullscreen :: () -> bool #foreign raylib_native;
IsWindowHidden :: () -> bool #foreign raylib_native;
IsWindowMinimized :: () -> bool #foreign raylib_native;
IsWindowMaximized :: () -> bool #foreign raylib_native;
IsWindowFocused :: () -> bool #foreign raylib_native;
IsWindowResized :: () -> bool #foreign raylib_native;
IsWindowState :: (flag: ConfigFlags) -> bool #foreign raylib_native;
SetWindowState :: (flags: ConfigFlags) #foreign raylib_native;
ClearWindowState :: (flags: ConfigFlags) #foreign raylib_native;
ToggleFullscreen :: () #foreign raylib_native;
ToggleBorderlessWindowed :: () #foreign raylib_native;
MaximizeWindow :: () #foreign raylib_native;
MinimizeWindow :: () #foreign raylib_native;
RestoreWindow :: () #foreign raylib_native;
SetWindowIcon :: (image: Image) #foreign raylib_native;
SetWindowIcons :: (images: *Image, count: s32) #foreign raylib_native;
SetWindowTitle :: (title: *u8) #foreign raylib_native;
SetWindowPosition :: (x: s32, y: s32) #foreign raylib_native;
SetWindowMonitor :: (monitor: s32) #foreign raylib_native;
SetWindowMinSize :: (width: s32, height: s32) #foreign raylib_native;
SetWindowMaxSize :: (width: s32, height: s32) #foreign raylib_native;
SetWindowSize :: (width: s32, height: s32) #foreign raylib_native;
SetWindowOpacity :: (opacity: float) #foreign raylib_native;
SetWindowFocused :: () #foreign raylib_native;
GetWindowHandle :: () -> *void #foreign raylib_native;
GetScreenWidth :: () -> s32 #foreign raylib_native;
GetScreenHeight :: () -> s32 #foreign raylib_native;
GetRenderWidth :: () -> s32 #foreign raylib_native;
GetRenderHeight :: () -> s32 #foreign raylib_native;
GetMonitorCount :: () -> s32 #foreign raylib_native;
GetCurrentMonitor :: () -> s32 #foreign raylib_native;
GetMonitorPosition :: (monitor: s32) -> Vector2 #foreign raylib_native;
GetMonitorWidth :: (monitor: s32) -> s32 #foreign raylib_native;
GetMonitorHeight :: (monitor: s32) -> s32 #foreign raylib_native;
GetMonitorPhysicalWidth :: (monitor: s32) -> s32 #foreign raylib_native;
GetMonitorPhysicalHeight :: (monitor: s32) -> s32 #foreign raylib_native;
GetMonitorRefreshRate :: (monitor: s32) -> s32 #foreign raylib_native;
GetWindowPosition :: () -> Vector2 #foreign raylib_native;
GetWindowScaleDPI :: () -> Vector2 #foreign raylib_native;
GetMonitorName :: (monitor: s32) -> *u8 #foreign raylib_native;
SetClipboardText :: (text: *u8) #foreign raylib_native;
GetClipboardText :: () -> *u8 #foreign raylib_native;
GetClipboardImage :: () -> Image #foreign raylib_native;
EnableEventWaiting :: () #foreign raylib_native;
DisableEventWaiting :: () #foreign raylib_native;

// Cursor-related functions
ShowCursor :: () #foreign raylib_native;
HideCursor :: () #foreign raylib_native;
IsCursorHidden :: () -> bool #foreign raylib_native;
EnableCursor :: () #foreign raylib_native;
DisableCursor :: () #foreign raylib_native;
IsCursorOnScreen :: () -> bool #foreign raylib_native;

// Drawing-related functions
ClearBackground :: (color: Color) #foreign raylib_native;
BeginDrawing :: () #foreign raylib_native;
EndDrawing :: () #foreign raylib_native;
BeginMode2D :: (camera: Camera2D) #foreign raylib_native;
EndMode2D :: () #foreign raylib_native;
BeginMode3D :: (camera: Camera3D) #foreign raylib_native;
EndMode3D :: () #foreign raylib_native;
BeginTextureMode :: (target: RenderTexture2D) #foreign raylib_native;
EndTextureMode :: () #foreign raylib_native;
BeginShaderMode :: (shader: Shader) #foreign raylib_native;
EndShaderMode :: () #foreign raylib_native;
BeginBlendMode :: (mode: BlendMode) #foreign raylib_native;
EndBlendMode :: () #foreign raylib_native;
BeginScissorMode :: (x: s32, y: s32, width: s32, height: s32) #foreign raylib_native;
EndScissorMode :: () #foreign raylib_native;
BeginVrStereoMode :: (config: VrStereoConfig) #foreign raylib_native;
EndVrStereoMode :: () #foreign raylib_native;

// VR stereo config functions for VR simulator
LoadVrStereoConfig :: (device: VrDeviceInfo) -> VrStereoConfig #foreign raylib_native;
UnloadVrStereoConfig :: (config: VrStereoConfig) #foreign raylib_native;

// Shader management functions
// NOTE: Shader functionality is not available on OpenGL 1.1
LoadShader :: (vsFileName: *u8, fsFileName: *u8) -> Shader #foreign raylib_native;
LoadShaderFromMemory :: (vsCode: *u8, fsCode: *u8) -> Shader #foreign raylib_native;
IsShaderValid :: (shader: Shader) -> bool #foreign raylib_native;
GetShaderLocation :: (shader: Shader, uniformName: *u8) -> s32 #foreign raylib_native;
GetShaderLocationAttrib :: (shader: Shader, attribName: *u8) -> s32 #foreign raylib_native;
SetShaderValue :: (shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType) #foreign raylib_native;
SetShaderValueV :: (shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType, count: s32) #foreign raylib_native;
SetShaderValueMatrix :: (shader: Shader, locIndex: s32, mat: Matrix4) #foreign raylib_native;
SetShaderValueTexture :: (shader: Shader, locIndex: s32, texture: Texture2D) #foreign raylib_native;
UnloadShader :: (shader: Shader) #foreign raylib_native;

// Screen-space-related functions
GetMouseRay :: GetScreenToWorldRay;    // Compatibility hack for previous raylib versions
GetScreenToWorldRay :: (position: Vector2, camera: Camera) -> Ray #foreign raylib_native;
GetScreenToWorldRayEx :: (position: Vector2, camera: Camera, width: s32, height: s32) -> Ray #foreign raylib_native;
GetWorldToScreen :: (position: Vector3, camera: Camera) -> Vector2 #foreign raylib_native;
GetWorldToScreenEx :: (position: Vector3, camera: Camera, width: s32, height: s32) -> Vector2 #foreign raylib_native;
GetWorldToScreen2D :: (position: Vector2, camera: Camera2D) -> Vector2 #foreign raylib_native;
GetScreenToWorld2D :: (position: Vector2, camera: Camera2D) -> Vector2 #foreign raylib_native;
GetCameraMatrix :: (camera: Camera) -> Matrix4 #foreign raylib_native;
GetCameraMatrix2D :: (camera: Camera2D) -> Matrix4 #foreign raylib_native;

// Timing-related functions
SetTargetFPS :: (fps: s32) #foreign raylib_native;
GetFrameTime :: () -> float #foreign raylib_native;
GetTime :: () -> float64 #foreign raylib_native;
GetFPS :: () -> s32 #foreign raylib_native;

// Custom frame control functions
// NOTE: Those functions are intended for advanced users that want full control over the frame processing
// By default EndDrawing() does this job: draws everything + SwapScreenBuffer() + manage frame timing + PollInputEvents()
// To avoid that behaviour and control frame processes manually, enable in config.h: SUPPORT_CUSTOM_FRAME_CONTROL
SwapScreenBuffer :: () #foreign raylib_native;
PollInputEvents :: () #foreign raylib_native;
WaitTime :: (seconds: float64) #foreign raylib_native;

// Random values generation functions
SetRandomSeed :: (seed: u32) #foreign raylib_native;
GetRandomValue :: (min: s32, max: s32) -> s32 #foreign raylib_native;
LoadRandomSequence :: (count: u32, min: s32, max: s32) -> *s32 #foreign raylib_native;
UnloadRandomSequence :: (sequence: *s32) #foreign raylib_native;

// Misc. functions
TakeScreenshot :: (fileName: *u8) #foreign raylib_native;
SetConfigFlags :: (flags: ConfigFlags) #foreign raylib_native;
OpenURL :: (url: *u8) #foreign raylib_native;

// NOTE: Following functions implemented in module [utils]
//------------------------------------------------------------------
TraceLog :: (logLevel: TraceLogLevel, text: *u8, args: ..*u8) #foreign raylib_native;
SetTraceLogLevel :: (logType: TraceLogLevel) #foreign raylib_native;
MemAlloc :: (size: u32) -> *void #foreign raylib_native;
MemRealloc :: (ptr: *void, size: u32) -> *void #foreign raylib_native;
MemFree :: (ptr: *void) #foreign raylib_native;

// Set custom callbacks
// WARNING: Callbacks setup is intended for advanced users
SetTraceLogCallback :: (callback: TraceLogCallback) #foreign raylib_native;
SetLoadFileDataCallback :: (callback: LoadFileDataCallback) #foreign raylib_native;
SetSaveFileDataCallback :: (callback: SaveFileDataCallback) #foreign raylib_native;
SetLoadFileTextCallback :: (callback: LoadFileTextCallback) #foreign raylib_native;
SetSaveFileTextCallback :: (callback: SaveFileTextCallback) #foreign raylib_native;

// Files management functions
LoadFileData :: (fileName: *u8, dataSize: *s32) -> *u8 #foreign raylib_native;
UnloadFileData :: (data: *u8) #foreign raylib_native;
SaveFileData :: (fileName: *u8, data: *void, dataSize: s32) -> bool #foreign raylib_native;
ExportDataAsCode :: (data: *u8, dataSize: s32, fileName: *u8) -> bool #foreign raylib_native;
LoadFileText :: (fileName: *u8) -> *u8 #foreign raylib_native;
UnloadFileText :: (text: *u8) #foreign raylib_native;
SaveFileText :: (fileName: *u8, text: *u8) -> bool #foreign raylib_native;
//------------------------------------------------------------------

// File system functions
FileExists :: (fileName: *u8) -> bool #foreign raylib_native;
DirectoryExists :: (dirPath: *u8) -> bool #foreign raylib_native;
IsFileExtension :: (fileName: *u8, ext: *u8) -> bool #foreign raylib_native;
GetFileLength :: (fileName: *u8) -> s32 #foreign raylib_native;
GetFileExtension :: (fileName: *u8) -> *u8 #foreign raylib_native;
GetFileName :: (filePath: *u8) -> *u8 #foreign raylib_native;
GetFileNameWithoutExt :: (filePath: *u8) -> *u8 #foreign raylib_native;
GetDirectoryPath :: (filePath: *u8) -> *u8 #foreign raylib_native;
GetPrevDirectoryPath :: (dirPath: *u8) -> *u8 #foreign raylib_native;
GetWorkingDirectory :: () -> *u8 #foreign raylib_native;
GetApplicationDirectory :: () -> *u8 #foreign raylib_native;
MakeDirectory :: (dirPath: *u8) -> s32 #foreign raylib_native;
ChangeDirectory :: (dir: *u8) -> bool #foreign raylib_native;
IsPathFile :: (path: *u8) -> bool #foreign raylib_native;
IsFileNameValid :: (fileName: *u8) -> bool #foreign raylib_native;
LoadDirectoryFiles :: (dirPath: *u8) -> FilePathList #foreign raylib_native;
LoadDirectoryFilesEx :: (basePath: *u8, filter: *u8, scanSubdirs: bool) -> FilePathList #foreign raylib_native;
UnloadDirectoryFiles :: (files: FilePathList) #foreign raylib_native;
IsFileDropped :: () -> bool #foreign raylib_native;
LoadDroppedFiles :: () -> FilePathList #foreign raylib_native;
UnloadDroppedFiles :: (files: FilePathList) #foreign raylib_native;
GetFileModTime :: (fileName: *u8) -> s64 #foreign raylib_native;

// Compression/Encoding functionality
CompressData :: (data: *u8, dataSize: s32, compDataSize: *s32) -> *u8 #foreign raylib_native;
DecompressData :: (compData: *u8, compDataSize: s32, dataSize: *s32) -> *u8 #foreign raylib_native;
EncodeDataBase64 :: (data: *u8, dataSize: s32, outputSize: *s32) -> *u8 #foreign raylib_native;
DecodeDataBase64 :: (data: *u8, outputSize: *s32) -> *u8 #foreign raylib_native;
ComputeCRC32 :: (data: *u8, dataSize: s32) -> u32 #foreign raylib_native;
ComputeMD5 :: (data: *u8, dataSize: s32) -> *u32 #foreign raylib_native;
ComputeSHA1 :: (data: *u8, dataSize: s32) -> *u32 #foreign raylib_native;


// Automation events functionality
LoadAutomationEventList :: (fileName: *u8) -> AutomationEventList #foreign raylib_native;
UnloadAutomationEventList :: (list: AutomationEventList) #foreign raylib_native;
ExportAutomationEventList :: (list: AutomationEventList, fileName: *u8) -> bool #foreign raylib_native;
SetAutomationEventList :: (list: *AutomationEventList) #foreign raylib_native;
SetAutomationEventBaseFrame :: (frame: s32) #foreign raylib_native;
StartAutomationEventRecording :: () #foreign raylib_native;
StopAutomationEventRecording :: () #foreign raylib_native;
PlayAutomationEvent :: (event: AutomationEvent) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Input Handling Functions (Module: core)
//------------------------------------------------------------------------------------

// Input-related functions: keyboard
IsKeyPressed :: (key: KeyboardKey) -> bool #foreign raylib_native;
IsKeyPressedRepeat :: (key: s32) -> bool #foreign raylib_native;
IsKeyDown :: (key: KeyboardKey) -> bool #foreign raylib_native;
IsKeyReleased :: (key: KeyboardKey) -> bool #foreign raylib_native;
IsKeyUp :: (key: KeyboardKey) -> bool #foreign raylib_native;
GetKeyPressed :: () -> s32 #foreign raylib_native;
GetCharPressed :: () -> u8 #foreign raylib_native;
SetExitKey :: (key: KeyboardKey) -> bool #foreign raylib_native;

// Input-related functions: gamepads
IsGamepadAvailable :: (gamepad: s32) -> bool #foreign raylib_native;
GetGamepadName :: (gamepad: s32) -> *u8 #foreign raylib_native;
IsGamepadButtonPressed :: (gamepad: s32, button: GamepadButton) -> bool #foreign raylib_native;
IsGamepadButtonDown :: (gamepad: s32, button: GamepadButton) -> bool #foreign raylib_native;
IsGamepadButtonReleased :: (gamepad: s32, button: GamepadButton) -> bool #foreign raylib_native;
IsGamepadButtonUp :: (gamepad: s32, button: GamepadButton) -> bool #foreign raylib_native;
GetGamepadButtonPressed :: () -> GamepadButton #foreign raylib_native;
GetGamepadAxisCount :: (gamepad: s32) -> s32 #foreign raylib_native;
GetGamepadAxisMovement :: (gamepad: s32, axis: GamepadAxis) -> float #foreign raylib_native;
SetGamepadMappings :: (mappings: *u8) -> s32 #foreign raylib_native;
SetGamepadVibration :: (gamepad: s32, leftMotor: float, rightMotor: float, duration: float) #foreign raylib_native;

// Input-related functions: mouse
IsMouseButtonPressed :: (button: MouseButton) -> bool #foreign raylib_native;
IsMouseButtonDown :: (button: MouseButton) -> bool #foreign raylib_native;
IsMouseButtonReleased :: (button: MouseButton) -> bool #foreign raylib_native;
IsMouseButtonUp :: (button: MouseButton) -> bool #foreign raylib_native;
GetMouseX :: () -> s32 #foreign raylib_native;
GetMouseY :: () -> s32 #foreign raylib_native;
GetMousePosition :: () -> Vector2 #foreign raylib_native;
GetMouseDelta :: () -> Vector2 #foreign raylib_native;
SetMousePosition :: (x: s32, y: s32) #foreign raylib_native;
SetMouseOffset :: (offsetX: s32, offsetY: s32) #foreign raylib_native;
SetMouseScale :: (scaleX: float, scaleY: float) #foreign raylib_native;
GetMouseWheelMove :: () -> float #foreign raylib_native;
GetMouseWheelMoveV :: () -> Vector2 #foreign raylib_native;
SetMouseCursor :: (cursor: MouseCursor) #foreign raylib_native;

// Input-related functions: touch
GetTouchX :: () -> s32 #foreign raylib_native;
GetTouchY :: () -> s32 #foreign raylib_native;
GetTouchPosition :: (index: s32) -> Vector2 #foreign raylib_native;
GetTouchPointId :: (index: s32) -> s32 #foreign raylib_native;
GetTouchPointCount :: () -> s32 #foreign raylib_native;

//------------------------------------------------------------------------------------
// Gestures and Touch Handling Functions (Module: rgestures)
//------------------------------------------------------------------------------------
SetGesturesEnabled :: (flags: u32) #foreign raylib_native;
IsGestureDetected :: (gesture: Gesture) -> bool #foreign raylib_native;
GetGestureDetected :: () -> Gesture #foreign raylib_native;
GetGestureHoldDuration :: () -> float #foreign raylib_native;
GetGestureDragVector :: () -> Vector2 #foreign raylib_native;
GetGestureDragAngle :: () -> float #foreign raylib_native;
GetGesturePinchVector :: () -> Vector2 #foreign raylib_native;
GetGesturePinchAngle :: () -> float #foreign raylib_native;

//------------------------------------------------------------------------------------
// Camera System Functions (Module: rcamera)
//------------------------------------------------------------------------------------
UpdateCamera :: (camera: *Camera, mode: CameraMode) #foreign raylib_native;
UpdateCameraPro :: (camera: *Camera, movement: Vector3, rotation: Vector3, zoom: float) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Basic Shapes Drawing Functions (Module: shapes)
//------------------------------------------------------------------------------------
// Set texture and rectangle to be used on shapes drawing
// NOTE: It can be useful when using basic shapes and one single font,
// defining a font char white rectangle would allow drawing everything in a single draw call
SetShapesTexture :: (texture: Texture2D, source: Rectangle) #foreign raylib_native;
GetShapesTexture :: () -> Texture2D #foreign raylib_native;
GetShapesTextureRectangle :: () -> Rectangle #foreign raylib_native;

// Basic shapes drawing functions
DrawPixel :: (posX: s32, posY: s32, color: Color) #foreign raylib_native;
DrawPixelV :: (position: Vector2, color: Color) #foreign raylib_native;
DrawLine :: (startPosX: s32, startPosY: s32, endPosX: s32, endPosY: s32, color: Color) #foreign raylib_native;
DrawLineV :: (startPos: Vector2, endPos: Vector2, color: Color) #foreign raylib_native;
DrawLineEx :: (startPos: Vector2, endPos: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawLineStrip :: (points: *Vector2, pointCount: s32, color: Color) #foreign raylib_native;
DrawLineBezier :: (startPos: Vector2, endPos: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawCircle :: (centerX: s32, centerY: s32, radius: float, color: Color) #foreign raylib_native;
DrawCircleSector :: (center: Vector2, radius: float, startAngle: float, endAngle: float, segments: s32, color: Color) #foreign raylib_native;
DrawCircleSectorLines :: (center: Vector2, radius: float, startAngle: float, endAngle: float, segments: s32, color: Color) #foreign raylib_native;
DrawCircleGradient :: (centerX: s32, centerY: s32, radius: float, inner: Color, outer: Color) #foreign raylib_native;
DrawCircleV :: (center: Vector2, radius: float, color: Color) #foreign raylib_native;
DrawCircleLines :: (centerX: s32, centerY: s32, radius: float, color: Color) #foreign raylib_native;
DrawCircleLinesV :: (center: Vector2, radius: float, color: Color) #foreign raylib_native;
DrawEllipse :: (centerX: s32, centerY: s32, radiusH: float, radiusV: float, color: Color) #foreign raylib_native;
DrawEllipseLines :: (centerX: s32, centerY: s32, radiusH: float, radiusV: float, color: Color) #foreign raylib_native;
DrawRing :: (center: Vector2, innerRadius: float, outerRadius: float, startAngle: float, endAngle: float, segments: s32, color: Color) #foreign raylib_native;
DrawRingLines :: (center: Vector2, innerRadius: float, outerRadius: float, startAngle: float, endAngle: float, segments: s32, color: Color) #foreign raylib_native;
DrawRectangle :: (posX: s32, posY: s32, width: s32, height: s32, color: Color) #foreign raylib_native;
DrawRectangleV :: (position: Vector2, size: Vector2, color: Color) #foreign raylib_native;
DrawRectangleRec :: (rec: Rectangle, color: Color) #foreign raylib_native;
DrawRectanglePro :: (rec: Rectangle, origin: Vector2, rotation: float, color: Color) #foreign raylib_native;
DrawRectangleGradientV :: (posX: s32, posY: s32, width: s32, height: s32, top: Color, bottom: Color) #foreign raylib_native;
DrawRectangleGradientH :: (posX: s32, posY: s32, width: s32, height: s32, left: Color, right: Color) #foreign raylib_native;
DrawRectangleGradientEx :: (rec: Rectangle, topLeft: Color, bottomLeft: Color, topRight: Color, bottomRight: Color) #foreign raylib_native;
DrawRectangleLines :: (posX: s32, posY: s32, width: s32, height: s32, color: Color) #foreign raylib_native;
DrawRectangleLinesEx :: (rec: Rectangle, lineThick: float, color: Color) #foreign raylib_native;
DrawRectangleRounded :: (rec: Rectangle, roundness: float, segments: s32, color: Color) #foreign raylib_native;
DrawRectangleRoundedLines :: (rec: Rectangle, roundness: float, segments: s32, color: Color) #foreign raylib_native;
DrawRectangleRoundedLinesEx :: (rec: Rectangle, roundness: float, segments: s32, lineThick: float, color: Color) #foreign raylib_native;
DrawTriangle :: (v1: Vector2, v2: Vector2, v3: Vector2, color: Color) #foreign raylib_native;
DrawTriangleLines :: (v1: Vector2, v2: Vector2, v3: Vector2, color: Color) #foreign raylib_native;
DrawTriangleFan :: (points: *Vector2, pointCount: s32, color: Color) #foreign raylib_native;
DrawTriangleStrip :: (points: *Vector2, pointCount: s32, color: Color) #foreign raylib_native;
DrawPoly :: (center: Vector2, sides: s32, radius: float, rotation: float, color: Color) #foreign raylib_native;
DrawPolyLines :: (center: Vector2, sides: s32, radius: float, rotation: float, color: Color) #foreign raylib_native;
DrawPolyLinesEx :: (center: Vector2, sides: s32, radius: float, rotation: float, lineThick: float, color: Color) #foreign raylib_native;

// Splines drawing functions
DrawSplineLinear :: (points: *Vector2, pointCount: s32, thick: float, color: Color) #foreign raylib_native;
DrawSplineBasis :: (points: *Vector2, pointCount: s32, thick: float, color: Color) #foreign raylib_native;
DrawSplineCatmullRom :: (points: *Vector2, pointCount: s32, thick: float, color: Color) #foreign raylib_native;
DrawSplineBezierQuadratic :: (points: *Vector2, pointCount: s32, thick: float, color: Color) #foreign raylib_native;
DrawSplineBezierCubic :: (points: *Vector2, pointCount: s32, thick: float, color: Color) #foreign raylib_native;
DrawSplineSegmentLinear :: (p1: Vector2, p2: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawSplineSegmentBasis :: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawSplineSegmentCatmullRom :: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawSplineSegmentBezierQuadratic :: (p1: Vector2, c2: Vector2, p3: Vector2, thick: float, color: Color) #foreign raylib_native;
DrawSplineSegmentBezierCubic :: (p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, thick: float, color: Color) #foreign raylib_native;

// Spline segment point evaluation functions, for a given t [0.0f .. 1.0f]
GetSplinePointLinear :: (startPos: Vector2, endPos: Vector2, t: float) -> Vector2 #foreign raylib_native;
GetSplinePointBasis :: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float) -> Vector2 #foreign raylib_native;
GetSplinePointCatmullRom :: (p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2, t: float) -> Vector2 #foreign raylib_native;
GetSplinePointBezierQuad :: (p1: Vector2, c2: Vector2, p3: Vector2, t: float) -> Vector2 #foreign raylib_native;
GetSplinePointBezierCubic :: (p1: Vector2, c2: Vector2, c3: Vector2, p4: Vector2, t: float) -> Vector2 #foreign raylib_native;

// Basic shapes collision detection functions
CheckCollisionRecs :: (rec1: Rectangle, rec2: Rectangle) -> bool #foreign raylib_native;
CheckCollisionCircles :: (center1: Vector2, radius1: float, center2: Vector2, radius2: float) -> bool #foreign raylib_native;
CheckCollisionCircleRec :: (center: Vector2, radius: float, rec: Rectangle) -> bool #foreign raylib_native;
CheckCollisionCircleLine :: (center: Vector2, radius: float, p1: Vector2, p2: Vector2) -> bool #foreign raylib_native;
CheckCollisionPointRec :: (point: Vector2, rec: Rectangle) -> bool #foreign raylib_native;
CheckCollisionPointCircle :: (point: Vector2, center: Vector2, radius: float) -> bool #foreign raylib_native;
CheckCollisionPointTriangle :: (point: Vector2, p1: Vector2, p2: Vector2, p3: Vector2) -> bool #foreign raylib_native;
CheckCollisionPointLine :: (point: Vector2, p1: Vector2, p2: Vector2, threshold: s32) -> bool #foreign raylib_native;
CheckCollisionPointPoly :: (point: Vector2, points: *Vector2, pointCount: s32) -> bool #foreign raylib_native;
CheckCollisionLines :: (startPos1: Vector2, endPos1: Vector2, startPos2: Vector2, endPos2: Vector2, collisionPoint: *Vector2) -> bool #foreign raylib_native;
GetCollisionRec :: (rec1: Rectangle, rec2: Rectangle) -> Rectangle #foreign raylib_native;

//------------------------------------------------------------------------------------
// Texture Loading and Drawing Functions (Module: textures)
//------------------------------------------------------------------------------------

// Image loading functions
// NOTE: These functions do not require GPU access
LoadImage :: (fileName: *u8) -> Image #foreign raylib_native;
LoadImageRaw :: (fileName: *u8, width: s32, height: s32, format: PixelFormat, headerSize: s32) -> Image #foreign raylib_native;
LoadImageAnim :: (fileName: *u8, frames: *s32) -> Image #foreign raylib_native;
LoadImageAnimFromMemory :: (fileType: *u8, fileData: *u8, dataSize: s32, frames: *s32) -> Image #foreign raylib_native;
LoadImageFromMemory :: (fileType: *u8, fileData: *u8, dataSize: s32) -> Image #foreign raylib_native;
LoadImageFromTexture :: (texture: Texture2D) -> Image #foreign raylib_native;
LoadImageFromScreen :: () -> Image #foreign raylib_native;
IsImageValid :: (image: Image) -> bool #foreign raylib_native;
UnloadImage :: (image: Image) #foreign raylib_native;
ExportImage :: (image: Image, fileName: *u8) -> bool #foreign raylib_native;
ExportImageToMemory :: (image: Image, fileType: *u8, fileSize: *s32) -> *u8 #foreign raylib_native;
ExportImageAsCode :: (image: Image, fileName: *u8) -> bool #foreign raylib_native;

// Image generation functions
GenImageColor :: (width: s32, height: s32, color: Color) -> Image #foreign raylib_native;
GenImageGradientLinear :: (width: s32, height: s32, direction: s32, start: Color, end: Color) -> Image #foreign raylib_native;
GenImageGradientRadial :: (width: s32, height: s32, density: float, inner: Color, outer: Color) -> Image #foreign raylib_native;
GenImageGradientSquare :: (width: s32, height: s32, density: float, inner: Color, outer: Color) -> Image #foreign raylib_native;
GenImageChecked :: (width: s32, height: s32, checksX: s32, checksY: s32, col1: Color, col2: Color) -> Image #foreign raylib_native;
GenImageWhiteNoise :: (width: s32, height: s32, factor: float) -> Image #foreign raylib_native;
GenImagePerlinNoise :: (width: s32, height: s32, offsetX: s32, offsetY: s32, scale: float) -> Image #foreign raylib_native;
GenImageCellular :: (width: s32, height: s32, tileSize: s32) -> Image #foreign raylib_native;
GenImageText :: (width: s32, height: s32, text: *u8) -> Image #foreign raylib_native;

// Image manipulation functions
ImageCopy :: (image: Image) -> Image #foreign raylib_native;
ImageFromImage :: (image: Image, rec: Rectangle) -> Image #foreign raylib_native;
ImageFromChannel :: (image: Image, selectedChannel: s32) -> Image #foreign raylib_native;
ImageText :: (text: *u8, fontSize: s32, color: Color) -> Image #foreign raylib_native;
ImageTextEx :: (font: Font, text: *u8, fontSize: float, spacing: float, tint: Color) -> Image #foreign raylib_native;
ImageFormat :: (image: *Image, newFormat: PixelFormat) #foreign raylib_native;
ImageToPOT :: (image: *Image, fill: Color) #foreign raylib_native;
ImageCrop :: (image: *Image, crop: Rectangle) #foreign raylib_native;
ImageAlphaCrop :: (image: *Image, threshold: float) #foreign raylib_native;
ImageAlphaClear :: (image: *Image, color: Color, threshold: float) #foreign raylib_native;
ImageAlphaMask :: (image: *Image, alphaMask: Image) #foreign raylib_native;
ImageAlphaPremultiply :: (image: *Image) #foreign raylib_native;
ImageBlurGaussian :: (image: *Image, blurSize: s32) #foreign raylib_native;
ImageKernelConvolution :: (image: *Image, kernel: *float, kernelSize: s32) #foreign raylib_native;
ImageResize :: (image: *Image, newWidth: s32, newHeight: s32) #foreign raylib_native;
ImageResizeNN :: (image: *Image, newWidth: s32, newHeight: s32) #foreign raylib_native;
ImageResizeCanvas :: (image: *Image, newWidth: s32, newHeight: s32, offsetX: s32, offsetY: s32, fill: Color) #foreign raylib_native;
ImageMipmaps :: (image: *Image) #foreign raylib_native;
ImageDither :: (image: *Image, rBpp: s32, gBpp: s32, bBpp: s32, aBpp: s32) #foreign raylib_native;
ImageFlipVertical :: (image: *Image) #foreign raylib_native;
ImageFlipHorizontal :: (image: *Image) #foreign raylib_native;
ImageRotate :: (image: *Image, degrees: s32) #foreign raylib_native;
ImageRotateCW :: (image: *Image) #foreign raylib_native;
ImageRotateCCW :: (image: *Image) #foreign raylib_native;
ImageColorTint :: (image: *Image, color: Color) #foreign raylib_native;
ImageColorInvert :: (image: *Image) #foreign raylib_native;
ImageColorGrayscale :: (image: *Image) #foreign raylib_native;
ImageColorContrast :: (image: *Image, contrast: float) #foreign raylib_native;
ImageColorBrightness :: (image: *Image, brightness: s32) #foreign raylib_native;
ImageColorReplace :: (image: *Image, color: Color, replace: Color) #foreign raylib_native;
LoadImageColors :: (image: Image) -> *Color #foreign raylib_native;
LoadImagePalette :: (image: Image, maxPaletteSize: s32, colorCount: *s32) -> *Color #foreign raylib_native;
UnloadImageColors :: (colors: *Color) #foreign raylib_native;
UnloadImagePalette :: (colors: *Color) #foreign raylib_native;
GetImageAlphaBorder :: (image: Image, threshold: float) -> Rectangle #foreign raylib_native;
GetImageColor :: (image: Image, x: s32, y: s32) -> Color #foreign raylib_native;

// Image drawing functions
// NOTE: Image software-rendering functions (CPU)
ImageClearBackground :: (dst: *Image, color: Color) #foreign raylib_native;
ImageDrawPixel :: (dst: *Image, posX: s32, posY: s32, color: Color) #foreign raylib_native;
ImageDrawPixelV :: (dst: *Image, position: Vector2, color: Color) #foreign raylib_native;
ImageDrawLine :: (dst: *Image, startPosX: s32, startPosY: s32, endPosX: s32, endPosY: s32, color: Color) #foreign raylib_native;
ImageDrawLineV :: (dst: *Image, start: Vector2, end: Vector2, color: Color) #foreign raylib_native;
ImageDrawLineEx :: (dst: *Image, start: Vector2, end: Vector2, thick: s32, color: Color) #foreign raylib_native;
ImageDrawCircle :: (dst: *Image, centerX: s32, centerY: s32, radius: s32, color: Color) #foreign raylib_native;
ImageDrawCircleV :: (dst: *Image, center: Vector2, radius: s32, color: Color) #foreign raylib_native;
ImageDrawCircleLines :: (dst: *Image, centerX: s32, centerY: s32, radius: s32, color: Color) #foreign raylib_native;
ImageDrawCircleLinesV :: (dst: *Image, center: Vector2, radius: s32, color: Color) #foreign raylib_native;
ImageDrawRectangle :: (dst: *Image, posX: s32, posY: s32, width: s32, height: s32, color: Color) #foreign raylib_native;
ImageDrawRectangleV :: (dst: *Image, position: Vector2, size: Vector2, color: Color) #foreign raylib_native;
ImageDrawRectangleRec :: (dst: *Image, rec: Rectangle, color: Color) #foreign raylib_native;
ImageDrawRectangleLines :: (dst: *Image, rec: Rectangle, thick: s32, color: Color) #foreign raylib_native;
ImageDrawTriangle :: (dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) #foreign raylib_native;
ImageDrawTriangleEx :: (dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, c1: Color, c2: Color, c3: Color) #foreign raylib_native;
ImageDrawTriangleLines :: (dst: *Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) #foreign raylib_native;
ImageDrawTriangleFan :: (dst: *Image, points: *Vector2, pointCount: s32, color: Color) #foreign raylib_native;
ImageDrawTriangleStrip :: (dst: *Image, points: *Vector2, pointCount: s32, color: Color) #foreign raylib_native;
ImageDraw :: (dst: *Image, src: Image, srcRec: Rectangle, dstRec: Rectangle, tint: Color) #foreign raylib_native;
ImageDrawText :: (dst: *Image, text: *u8, posX: s32, posY: s32, fontSize: s32, color: Color) #foreign raylib_native;
ImageDrawTextEx :: (dst: *Image, font: Font, text: *u8, position: Vector2, fontSize: float, spacing: float, tint: Color) #foreign raylib_native;

// Texture loading functions
// NOTE: These functions require GPU access
LoadTexture :: (fileName: *u8) -> Texture2D #foreign raylib_native;
LoadTextureFromImage :: (image: Image) -> Texture2D #foreign raylib_native;
LoadTextureCubemap :: (image: Image, layout: CubemapLayout) -> TextureCubemap #foreign raylib_native;
LoadRenderTexture :: (width: s32, height: s32) -> RenderTexture2D #foreign raylib_native;
IsTextureValid :: (texture: Texture2D) -> bool #foreign raylib_native;
UnloadTexture :: (texture: Texture2D) #foreign raylib_native;
IsRenderTextureValid :: (target: RenderTexture2D) -> bool #foreign raylib_native;
UnloadRenderTexture :: (target: RenderTexture2D) #foreign raylib_native;
UpdateTexture :: (texture: Texture2D, pixels: *void) #foreign raylib_native;
UpdateTextureRec :: (texture: Texture2D, rec: Rectangle, pixels: *void) #foreign raylib_native;

// Texture configuration functions
GenTextureMipmaps :: (texture: *Texture2D) #foreign raylib_native;
SetTextureFilter :: (texture: Texture2D, filter: TextureFilter) #foreign raylib_native;
SetTextureWrap :: (texture: Texture2D, wrap: TextureWrap) #foreign raylib_native;

// Texture drawing functions
DrawTexture :: (texture: Texture2D, posX: s32, posY: s32, tint: Color) #foreign raylib_native;
DrawTextureV :: (texture: Texture2D, position: Vector2, tint: Color) #foreign raylib_native;
DrawTextureEx :: (texture: Texture2D, position: Vector2, rotation: float, scale: float, tint: Color) #foreign raylib_native;
DrawTextureRec :: (texture: Texture2D, source: Rectangle, position: Vector2, tint: Color) #foreign raylib_native;
DrawTexturePro :: (texture: Texture2D, source: Rectangle, dest: Rectangle, origin: Vector2, rotation: float, tint: Color) #foreign raylib_native;
DrawTextureNPatch :: (texture: Texture2D, nPatchInfo: NPatchInfo, dest: Rectangle, origin: Vector2, rotation: float, tint: Color) #foreign raylib_native;

// Color/pixel related functions
ColorIsEqual :: (col1: Color, col2: Color) -> bool #foreign raylib_native;
Fade :: (color: Color, alpha: float) -> Color #foreign raylib_native;
ColorToInt :: (color: Color) -> s32 #foreign raylib_native;
ColorNormalize :: (color: Color) -> Vector4 #foreign raylib_native;
ColorFromNormalized :: (normalized: Vector4) -> Color #foreign raylib_native;
ColorToHSV :: (color: Color) -> Vector3 #foreign raylib_native;
ColorFromHSV :: (hue: float, saturation: float, value: float) -> Color #foreign raylib_native;
ColorTint :: (color: Color, tint: Color) -> Color #foreign raylib_native;
ColorBrightness :: (color: Color, factor: float) -> Color #foreign raylib_native;
ColorContrast :: (color: Color, contrast: float) -> Color #foreign raylib_native;
ColorAlpha :: (color: Color, alpha: float) -> Color #foreign raylib_native;
ColorAlphaBlend :: (dst: Color, src: Color, tint: Color) -> Color #foreign raylib_native;
ColorLerp :: (color1: Color, color2: Color, factor: float) -> Color #foreign raylib_native;
GetColor :: (hexValue: u32) -> Color #foreign raylib_native;
GetPixelColor :: (srcPtr: *void, format: s32) -> Color #foreign raylib_native;
SetPixelColor :: (dstPtr: *void, color: Color, format: s32) #foreign raylib_native;
GetPixelDataSize :: (width: s32, height: s32, format: s32) -> s32 #foreign raylib_native;

//------------------------------------------------------------------------------------
// Font Loading and Text Drawing Functions (Module: text)
//------------------------------------------------------------------------------------

// Font loading/unloading functions
GetFontDefault :: () -> Font #foreign raylib_native;
LoadFont :: (fileName: *u8) -> Font #foreign raylib_native;
LoadFontEx :: (fileName: *u8, fontSize: s32, codepoints: *s32, codepointCount: s32) -> Font #foreign raylib_native;
LoadFontFromImage :: (image: Image, key: Color, firstChar: s32) -> Font #foreign raylib_native;
LoadFontFromMemory :: (fileType: *u8, fileData: *u8, dataSize: s32, fontSize: s32, codepoints: *s32, codepointCount: s32) -> Font #foreign raylib_native;
IsFontValid :: (font: Font) -> bool #foreign raylib_native;
LoadFontData :: (fileData: *u8, dataSize: s32, fontSize: s32, codepoints: *s32, codepointCount: s32, type: FontType) -> *GlyphInfo #foreign raylib_native;
GenImageFontAtlas :: (glyphs: *GlyphInfo, glyphRecs: **Rectangle, glyphCount: s32, fontSize: s32, padding: s32, packMethod: s32) -> Image #foreign raylib_native;
UnloadFontData :: (glyphs: *GlyphInfo, glyphCount: s32) #foreign raylib_native;
UnloadFont :: (font: Font) #foreign raylib_native;
ExportFontAsCode :: (font: Font, fileName: *u8) -> bool #foreign raylib_native;

// Text drawing functions
DrawFPS :: (posX: s32, posY: s32) #foreign raylib_native;
DrawText :: (text: *u8, posX: s32, posY: s32, fontSize: s32, color: Color) #foreign raylib_native;
DrawTextEx :: (font: Font, text: *u8, position: Vector2, fontSize: float, spacing: float, tint: Color) #foreign raylib_native;
DrawTextPro :: (font: Font, text: *u8, position: Vector2, origin: Vector2, rotation: float, fontSize: float, spacing: float, tint: Color) #foreign raylib_native;
DrawTextCodepoint :: (font: Font, codepoint: s32, position: Vector2, fontSize: float, tint: Color) #foreign raylib_native;
DrawTextCodepoints :: (font: Font, codepoints: *s32, codepointCount: s32, position: Vector2, fontSize: float, spacing: float, tint: Color) #foreign raylib_native;

// Text font info functions
SetTextLineSpacing :: (spacing: s32) #foreign raylib_native;
MeasureText :: (text: *u8, fontSize: s32) -> s32 #foreign raylib_native;
MeasureTextEx :: (font: Font, text: *u8, fontSize: float, spacing: float) -> Vector2 #foreign raylib_native;
GetGlyphIndex :: (font: Font, codepoint: s32) -> s32 #foreign raylib_native;
GetGlyphInfo :: (font: Font, codepoint: s32) -> GlyphInfo #foreign raylib_native;
GetGlyphAtlasRec :: (font: Font, codepoint: s32) -> Rectangle #foreign raylib_native;

// Text codepoints management functions (unicode characters)
LoadUTF8 :: (codepoints: *s32, length: s32) -> *u8 #foreign raylib_native;
UnloadUTF8 :: (text: *u8) #foreign raylib_native;
LoadCodepoints :: (text: *u8, count: *s32) -> *s32 #foreign raylib_native;
UnloadCodepoints :: (codepoints: *s32) #foreign raylib_native;
GetCodepointCount :: (text: *u8) -> s32 #foreign raylib_native;
GetCodepoint :: (text: *u8, codepointSize: *s32) -> s32 #foreign raylib_native;
GetCodepointNext :: (text: *u8, codepointSize: *s32) -> s32 #foreign raylib_native;
GetCodepointPrevious :: (text: *u8, codepointSize: *s32) -> s32 #foreign raylib_native;
CodepointToUTF8 :: (codepoint: s32, utf8Size: *s32) -> *u8 #foreign raylib_native;

// Text strings management functions (no UTF-8 strings, only byte chars)
// NOTE: Some strings allocate memory internally for returned strings, just be careful!
TextCopy :: (dst: *u8, src: *u8) -> s32 #foreign raylib_native;
TextIsEqual :: (text1: *u8, text2: *u8) -> bool #foreign raylib_native;
TextLength :: (text: *u8) -> u32 #foreign raylib_native;
TextFormat :: (text: *u8, args: ..*u8) -> *u8 #foreign raylib_native;
TextSubtext :: (text: *u8, position: s32, length: s32) -> *u8 #foreign raylib_native;
TextReplace :: (text: *u8, replace: *u8, by: *u8) -> *u8 #foreign raylib_native;
TextInsert :: (text: *u8, insert: *u8, position: s32) -> *u8 #foreign raylib_native;
TextJoin :: (textList: **u8, count: s32, delimiter: *u8) -> *u8 #foreign raylib_native;
TextSplit :: (text: *u8, delimiter: u8, count: *s32) -> **u8 #foreign raylib_native;
TextAppend :: (text: *u8, append: *u8, position: *s32) #foreign raylib_native;
TextFindIndex :: (text: *u8, find: *u8) -> s32 #foreign raylib_native;
TextToUpper :: (text: *u8) -> *u8 #foreign raylib_native;
TextToLower :: (text: *u8) -> *u8 #foreign raylib_native;
TextToPascal :: (text: *u8) -> *u8 #foreign raylib_native;
TextToSnake :: (text: *u8) -> *u8 #foreign raylib_native;
TextToCamel :: (text: *u8) -> *u8 #foreign raylib_native;

TextToInteger :: (text: *u8) -> s32 #foreign raylib_native;
TextToFloat :: (text: *u8) -> float #foreign raylib_native;

//------------------------------------------------------------------------------------
// Basic 3d Shapes Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Basic geometric 3D shapes drawing functions
DrawLine3D :: (startPos: Vector3, endPos: Vector3, color: Color) #foreign raylib_native;
DrawPoint3D :: (position: Vector3, color: Color) #foreign raylib_native;
DrawCircle3D :: (center: Vector3, radius: float, rotationAxis: Vector3, rotationAngle: float, color: Color) #foreign raylib_native;
DrawTriangle3D :: (v1: Vector3, v2: Vector3, v3: Vector3, color: Color) #foreign raylib_native;
DrawTriangleStrip3D :: (points: *Vector3, pointCount: s32, color: Color) #foreign raylib_native;
DrawCube :: (position: Vector3, width: float, height: float, length: float, color: Color) #foreign raylib_native;
DrawCubeV :: (position: Vector3, size: Vector3, color: Color) #foreign raylib_native;
DrawCubeWires :: (position: Vector3, width: float, height: float, length: float, color: Color) #foreign raylib_native;
DrawCubeWiresV :: (position: Vector3, size: Vector3, color: Color) #foreign raylib_native;
DrawSphere :: (centerPos: Vector3, radius: float, color: Color) #foreign raylib_native;
DrawSphereEx :: (centerPos: Vector3, radius: float, rings: s32, slices: s32, color: Color) #foreign raylib_native;
DrawSphereWires :: (centerPos: Vector3, radius: float, rings: s32, slices: s32, color: Color) #foreign raylib_native;
DrawCylinder :: (position: Vector3, radiusTop: float, radiusBottom: float, height: float, slices: s32, color: Color) #foreign raylib_native;
DrawCylinderEx :: (startPos: Vector3, endPos: Vector3, startRadius: float, endRadius: float, sides: s32, color: Color) #foreign raylib_native;
DrawCylinderWires :: (position: Vector3, radiusTop: float, radiusBottom: float, height: float, slices: s32, color: Color) #foreign raylib_native;
DrawCylinderWiresEx :: (startPos: Vector3, endPos: Vector3, startRadius: float, endRadius: float, sides: s32, color: Color) #foreign raylib_native;
DrawCapsule :: (startPos: Vector3, endPos: Vector3, radius: float, slices: s32, rings: s32, color: Color) #foreign raylib_native;
DrawCapsuleWires :: (startPos: Vector3, endPos: Vector3, radius: float, slices: s32, rings: s32, color: Color) #foreign raylib_native;
DrawPlane :: (centerPos: Vector3, size: Vector2, color: Color) #foreign raylib_native;
DrawRay :: (ray: Ray, color: Color) #foreign raylib_native;
DrawGrid :: (slices: s32, spacing: float) #foreign raylib_native;

//------------------------------------------------------------------------------------
// Model 3d Loading and Drawing Functions (Module: models)
//------------------------------------------------------------------------------------

// Model management functions
LoadModel :: (fileName: *u8) -> Model #foreign raylib_native;
LoadModelFromMesh :: (mesh: Mesh) -> Model #foreign raylib_native;
IsModelValid :: (model: Model) -> bool #foreign raylib_native;
UnloadModel :: (model: Model) #foreign raylib_native;
GetModelBoundingBox :: (model: Model) -> BoundingBox #foreign raylib_native;

// Model drawing functions
DrawModel :: (model: Model, position: Vector3, scale: float, tint: Color) #foreign raylib_native;
DrawModelEx :: (model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float, scale: Vector3, tint: Color) #foreign raylib_native;
DrawModelWires :: (model: Model, position: Vector3, scale: float, tint: Color) #foreign raylib_native;
DrawModelWiresEx :: (model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float, scale: Vector3, tint: Color) #foreign raylib_native;
DrawModelPoints :: (model: Model, position: Vector3, scale: float, tint: Color) #foreign raylib_native;
DrawModelPointsEx :: (model: Model, position: Vector3, rotationAxis: Vector3, rotationAngle: float, scale: Vector3, tint: Color) #foreign raylib_native;
DrawBoundingBox :: (box: BoundingBox, color: Color) #foreign raylib_native;
DrawBillboard :: (camera: Camera, texture: Texture2D, position: Vector3, scale: float, tint: Color) #foreign raylib_native;
DrawBillboardRec :: (camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, size: Vector2, tint: Color) #foreign raylib_native;
DrawBillboardPro :: (camera: Camera, texture: Texture2D, source: Rectangle, position: Vector3, up: Vector3, size: Vector2, origin: Vector2, rotation: float, tint: Color) #foreign raylib_native;

// Mesh management functions
UploadMesh :: (mesh: *Mesh, dynamic: bool) #foreign raylib_native;
UpdateMeshBuffer :: (mesh: Mesh, index: s32, data: *void, dataSize: s32, offset: s32) #foreign raylib_native;
UnloadMesh :: (mesh: Mesh) #foreign raylib_native;
DrawMesh :: (mesh: Mesh, material: Material, transform: Matrix4) #foreign raylib_native;
DrawMeshInstanced :: (mesh: Mesh, material: Material, transforms: *Matrix4, instances: s32) #foreign raylib_native;
GetMeshBoundingBox :: (mesh: Mesh) -> BoundingBox #foreign raylib_native;
GenMeshTangents :: (mesh: *Mesh) #foreign raylib_native;
ExportMesh :: (mesh: Mesh, fileName: *u8) -> bool #foreign raylib_native;
ExportMeshAsCode :: (mesh: Mesh, fileName: *u8) -> bool #foreign raylib_native;

// Mesh generation functions
GenMeshPoly :: (sides: s32, radius: float) -> Mesh #foreign raylib_native;
GenMeshPlane :: (width: float, length: float, resX: s32, resZ: s32) -> Mesh #foreign raylib_native;
GenMeshCube :: (width: float, height: float, length: float) -> Mesh #foreign raylib_native;
GenMeshSphere :: (radius: float, rings: s32, slices: s32) -> Mesh #foreign raylib_native;
GenMeshHemiSphere :: (radius: float, rings: s32, slices: s32) -> Mesh #foreign raylib_native;
GenMeshCylinder :: (radius: float, height: float, slices: s32) -> Mesh #foreign raylib_native;
GenMeshCone :: (radius: float, height: float, slices: s32) -> Mesh #foreign raylib_native;
GenMeshTorus :: (radius: float, size: float, radSeg: s32, sides: s32) -> Mesh #foreign raylib_native;
GenMeshKnot :: (radius: float, size: float, radSeg: s32, sides: s32) -> Mesh #foreign raylib_native;
GenMeshHeightmap :: (heightmap: Image, size: Vector3) -> Mesh #foreign raylib_native;
GenMeshCubicmap :: (cubicmap: Image, cubeSize: Vector3) -> Mesh #foreign raylib_native;

// Material loading/unloading functions
LoadMaterials :: (fileName: *u8, materialCount: *s32) -> *Material #foreign raylib_native;
LoadMaterialDefault :: () -> Material #foreign raylib_native;
IsMaterialValid :: (material: Material) -> bool #foreign raylib_native;
UnloadMaterial :: (material: Material) #foreign raylib_native;
SetMaterialTexture :: (material: *Material, mapType: MaterialMapIndex, texture: Texture2D) #foreign raylib_native;
SetModelMeshMaterial :: (model: *Model, meshId: s32, materialId: s32) #foreign raylib_native;

// Model animations loading/unloading functions
LoadModelAnimations :: (fileName: *u8, animCount: *s32) -> *ModelAnimation #foreign raylib_native;
UpdateModelAnimation :: (model: Model, anim: ModelAnimation, frame: s32) #foreign raylib_native;
UpdateModelAnimationBones :: (model: Model, anim: ModelAnimation, frame: s32) #foreign raylib_native;
UnloadModelAnimation :: (anim: ModelAnimation) #foreign raylib_native;
UnloadModelAnimations :: (animations: *ModelAnimation, animCount: s32) #foreign raylib_native;
IsModelAnimationValid :: (model: Model, anim: ModelAnimation) -> bool #foreign raylib_native;

// Collision detection functions
CheckCollisionSpheres :: (center1: Vector3, radius1: float, center2: Vector3, radius2: float) -> bool #foreign raylib_native;
CheckCollisionBoxes :: (box1: BoundingBox, box2: BoundingBox) -> bool #foreign raylib_native;
CheckCollisionBoxSphere :: (box: BoundingBox, center: Vector3, radius: float) -> bool #foreign raylib_native;
GetRayCollisionSphere :: (ray: Ray, center: Vector3, radius: float) -> RayCollision #foreign raylib_native;
GetRayCollisionBox :: (ray: Ray, box: BoundingBox) -> RayCollision #foreign raylib_native;
GetRayCollisionMesh :: (ray: Ray, mesh: Mesh, transform: Matrix4) -> RayCollision #foreign raylib_native;
GetRayCollisionTriangle :: (ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3) -> RayCollision #foreign raylib_native;
GetRayCollisionQuad :: (ray: Ray, p1: Vector3, p2: Vector3, p3: Vector3, p4: Vector3) -> RayCollision #foreign raylib_native;

//------------------------------------------------------------------------------------
// Audio Loading and Playing Functions (Module: audio)
//------------------------------------------------------------------------------------

// Audio device management functions
InitAudioDevice :: () #foreign raylib_native;
CloseAudioDevice :: () #foreign raylib_native;
IsAudioDeviceReady :: () -> bool #foreign raylib_native;
SetMasterVolume :: (volume: float) #foreign raylib_native;
GetMasterVolume :: () -> float #foreign raylib_native;

// Wave/Sound loading/unloading functions
LoadWave :: (fileName: *u8) -> Wave #foreign raylib_native;
LoadWaveFromMemory :: (fileType: *u8, fileData: *u8, dataSize: s32) -> Wave #foreign raylib_native;
IsWaveValid :: (wave: Wave) -> bool #foreign raylib_native;
LoadSound :: (fileName: *u8) -> Sound #foreign raylib_native;
LoadSoundFromWave :: (wave: Wave) -> Sound #foreign raylib_native;
LoadSoundAlias :: (source: Sound) -> Sound #foreign raylib_native;
IsSoundValid :: (sound: Sound) -> bool #foreign raylib_native;
UpdateSound :: (sound: Sound, data: *void, sampleCount: s32) #foreign raylib_native;
UnloadWave :: (wave: Wave) #foreign raylib_native;
UnloadSound :: (sound: Sound) #foreign raylib_native;
UnloadSoundAlias :: (alias: Sound) #foreign raylib_native;
ExportWave :: (wave: Wave, fileName: *u8) -> bool #foreign raylib_native;
ExportWaveAsCode :: (wave: Wave, fileName: *u8) -> bool #foreign raylib_native;

// Wave/Sound management functions
PlaySound :: (sound: Sound) #foreign raylib_native;
StopSound :: (sound: Sound) #foreign raylib_native;
PauseSound :: (sound: Sound) #foreign raylib_native;
ResumeSound :: (sound: Sound) #foreign raylib_native;
IsSoundPlaying :: (sound: Sound) -> bool #foreign raylib_native;
SetSoundVolume :: (sound: Sound, volume: float) #foreign raylib_native;
SetSoundPitch :: (sound: Sound, pitch: float) #foreign raylib_native;
SetSoundPan :: (sound: Sound, pan: float) #foreign raylib_native;
WaveCopy :: (wave: Wave) -> Wave #foreign raylib_native;
WaveCrop :: (wave: *Wave, initFrame: s32, finalFrame: s32) #foreign raylib_native;
WaveFormat :: (wave: *Wave, sampleRate: s32, sampleSize: s32, channels: s32) #foreign raylib_native;
LoadWaveSamples :: (wave: Wave) -> *float #foreign raylib_native;
UnloadWaveSamples :: (samples: *float) #foreign raylib_native;

// Music management functions
LoadMusicStream :: (fileName: *u8) -> Music #foreign raylib_native;
LoadMusicStreamFromMemory :: (fileType: *u8, data: *u8, dataSize: s32) -> Music #foreign raylib_native;
IsMusicValid :: (music: Music) -> bool #foreign raylib_native;
UnloadMusicStream :: (music: Music) #foreign raylib_native;
PlayMusicStream :: (music: Music) #foreign raylib_native;
IsMusicStreamPlaying :: (music: Music) -> bool #foreign raylib_native;
UpdateMusicStream :: (music: Music) #foreign raylib_native;
StopMusicStream :: (music: Music) #foreign raylib_native;
PauseMusicStream :: (music: Music) #foreign raylib_native;
ResumeMusicStream :: (music: Music) #foreign raylib_native;
SeekMusicStream :: (music: Music, position: float) #foreign raylib_native;
SetMusicVolume :: (music: Music, volume: float) #foreign raylib_native;
SetMusicPitch :: (music: Music, pitch: float) #foreign raylib_native;
SetMusicPan :: (music: Music, pan: float) #foreign raylib_native;
GetMusicTimeLength :: (music: Music) -> float #foreign raylib_native;
GetMusicTimePlayed :: (music: Music) -> float #foreign raylib_native;

// AudioStream management functions
LoadAudioStream :: (sampleRate: u32, sampleSize: u32, channels: u32) -> AudioStream #foreign raylib_native;
IsAudioStreamValid :: (stream: AudioStream) -> bool #foreign raylib_native;
UnloadAudioStream :: (stream: AudioStream) #foreign raylib_native;
UpdateAudioStream :: (stream: AudioStream, data: *void, frameCount: s32) #foreign raylib_native;
IsAudioStreamProcessed :: (stream: AudioStream) -> bool #foreign raylib_native;
PlayAudioStream :: (stream: AudioStream) #foreign raylib_native;
PauseAudioStream :: (stream: AudioStream) #foreign raylib_native;
ResumeAudioStream :: (stream: AudioStream) #foreign raylib_native;
IsAudioStreamPlaying :: (stream: AudioStream) -> bool #foreign raylib_native;
StopAudioStream :: (stream: AudioStream) #foreign raylib_native;
SetAudioStreamVolume :: (stream: AudioStream, volume: float) #foreign raylib_native;
SetAudioStreamPitch :: (stream: AudioStream, pitch: float) #foreign raylib_native;
SetAudioStreamPan :: (stream: AudioStream, pan: float) #foreign raylib_native;
SetAudioStreamBufferSizeDefault :: (size: s32) #foreign raylib_native;
SetAudioStreamCallback :: (stream: AudioStream, callback: AudioCallback) #foreign raylib_native;

AttachAudioStreamProcessor :: (stream: AudioStream, processor: AudioCallback) #foreign raylib_native;
DetachAudioStreamProcessor :: (stream: AudioStream, processor: AudioCallback) #foreign raylib_native;

AttachAudioMixedProcessor :: (processor: AudioCallback) #foreign raylib_native;
DetachAudioMixedProcessor :: (processor: AudioCallback) #foreign raylib_native;


TraceLogCallback     :: #type (logLevel: TraceLogLevel, text: *u8, args: .. Any) #c_call;
LoadFileDataCallback :: #type (fileName: *u8, bytesRead: *u32) -> *u8 #c_call;
SaveFileDataCallback :: #type (fileName: *u8, data: *void, bytesToWrite: u32) -> bool #c_call;
LoadFileTextCallback :: #type (fileName: *u8) -> *u8 #c_call;
SaveFileTextCallback :: #type (fileName: *u8, text: *u8) -> bool #c_call;
AudioCallback        :: #type (bufferData: *void, frames: u32) #c_call;

#if OS == .WINDOWS {
    user32  :: #library,system,link_always "user32";
    gdi32   :: #library,system,link_always "gdi32";
    shell32 :: #library,system,link_always "shell32";
    winmm   :: #library,system,link_always "winmm";

    raylib_native :: #library,no_dll "lib/windows/raylib";
    raygui_native :: #library,no_dll "lib/windows/raygui";
}

#if OS == .LINUX {
    libm :: #library,system,link_always "libm";

    raylib_native :: #library,no_dll "lib/linux/raylib";
    raygui_native :: #library,no_dll "lib/linux/raygui";
}

#if OS == .MACOS {
    cocoa :: #library,system,link_always "Cocoa";
    iOKit :: #library,system,link_always "IOKit";

    raylib_native :: #library,no_dll "lib/macos/raylib";
    raygui_native :: #library,no_dll "lib/macos/raygui";
}

