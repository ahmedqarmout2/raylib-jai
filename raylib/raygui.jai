//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//


/*
********************************************************************************************
*
*   raygui v4.5-dev - A simple and easy-to-use immediate-mode gui library
*
*   DESCRIPTION:
*       raygui is a tools-dev-focused immediate-mode-gui library based on raylib but also
*       available as a standalone library, as long as input and drawing functions are provided.
*
*   FEATURES:
*       - Immediate-mode gui, minimal retained data
*       - +25 controls provided (basic and advanced)
*       - Styling system for colors, font and metrics
*       - Icons supported, embedded as a 1-bit icons pack
*       - Standalone mode option (custom input/graphics backend)
*       - Multiple support tools provided for raygui development
*
*   POSSIBLE IMPROVEMENTS:
*       - Better standalone mode API for easy plug of custom backends
*       - Externalize required inputs, allow user easier customization
*
*   LIMITATIONS:
*       - No editable multi-line word-wraped text box supported
*       - No auto-layout mechanism, up to the user to define controls position and size
*       - Standalone mode requires library modification and some user work to plug another backend
*
*   NOTES:
*       - WARNING: GuiLoadStyle() and GuiLoadStyle{Custom}() functions, allocate memory for
*         font atlas recs and glyphs, freeing that memory is (usually) up to the user,
*         no unload function is explicitly provided... but note that GuiLoadStyleDefault() unloads
*         by default any previously loaded font (texture, recs, glyphs).
*       - Global UI alpha (guiAlpha) is applied inside GuiDrawRectangle() and GuiDrawText() functions
*
*   CONTROLS PROVIDED:
*     # Container/separators Controls
*       - WindowBox     --> StatusBar, Panel
*       - GroupBox      --> Line
*       - Line
*       - Panel         --> StatusBar
*       - ScrollPanel   --> StatusBar
*       - TabBar        --> Button
*
*     # Basic Controls
*       - Label
*       - LabelButton   --> Label
*       - Button
*       - Toggle
*       - ToggleGroup   --> Toggle
*       - ToggleSlider
*       - CheckBox
*       - ComboBox
*       - DropdownBox
*       - TextBox
*       - ValueBox      --> TextBox
*       - Spinner       --> Button, ValueBox
*       - Slider
*       - SliderBar     --> Slider
*       - ProgressBar
*       - StatusBar
*       - DummyRec
*       - Grid
*
*     # Advance Controls
*       - ListView
*       - ColorPicker   --> ColorPanel, ColorBarHue
*       - MessageBox    --> Window, Label, Button
*       - TextInputBox  --> Window, Label, TextBox, Button
*
*     It also provides a set of functions for styling the controls based on its properties (size, color).
*
*
*   RAYGUI STYLE (guiStyle):
*       raygui uses a global data array for all gui style properties (allocated on data segment by default),
*       when a new style is loaded, it is loaded over the global style... but a default gui style could always be
*       recovered with GuiLoadStyleDefault() function, that overwrites the current style to the default one
*
*       The global style array size is fixed and depends on the number of controls and properties:
*
*           static unsigned int guiStyle[RAYGUI_MAX_CONTROLS*(RAYGUI_MAX_PROPS_BASE + RAYGUI_MAX_PROPS_EXTENDED)];
*
*       guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
*
*       Note that the first set of BASE properties (by default guiStyle[0..15]) belong to the generic style
*       used for all controls, when any of those base values is set, it is automatically populated to all
*       controls, so, specific control values overwriting generic style should be set after base values.
*
*       After the first BASE set we have the EXTENDED properties (by default guiStyle[16..23]), those
*       properties are actually common to all controls and can not be overwritten individually (like BASE ones)
*       Some of those properties are: TEXT_SIZE, TEXT_SPACING, LINE_COLOR, BACKGROUND_COLOR
*
*       Custom control properties can be defined using the EXTENDED properties for each independent control.
*
*       TOOL: rGuiStyler is a visual tool to customize raygui style: github.com/raysan5/rguistyler
*
*
*   RAYGUI ICONS (guiIcons):
*       raygui could use a global array containing icons data (allocated on data segment by default),
*       a custom icons set could be loaded over this array using GuiLoadIcons(), but loaded icons set
*       must be same RAYGUI_ICON_SIZE and no more than RAYGUI_ICON_MAX_ICONS will be loaded
*
*       Every icon is codified in binary form, using 1 bit per pixel, so, every 16x16 icon
*       requires 8 integers (16*16/32) to be stored in memory.
*
*       When the icon is draw, actually one quad per pixel is drawn if the bit for that pixel is set.
*
*       The global icons array size is fixed and depends on the number of icons and size:
*
*           static unsigned int guiIcons[RAYGUI_ICON_MAX_ICONS*RAYGUI_ICON_DATA_ELEMENTS];
*
*       guiIcons size is by default: 256*(16*16/32) = 2048*4 = 8192 bytes = 8 KB
*
*       TOOL: rGuiIcons is a visual tool to customize/create raygui icons: github.com/raysan5/rguiicons
*
*   RAYGUI LAYOUT:
*       raygui currently does not provide an auto-layout mechanism like other libraries,
*       layouts must be defined manually on controls drawing, providing the right bounds Rectangle for it.
*
*       TOOL: rGuiLayout is a visual tool to create raygui layouts: github.com/raysan5/rguilayout
*
*   CONFIGURATION:
*       #define RAYGUI_IMPLEMENTATION
*           Generates the implementation of the library into the included file.
*           If not defined, the library is in header only mode and can be included in other headers
*           or source files without problems. But only ONE file should hold the implementation.
*
*       #define RAYGUI_STANDALONE
*           Avoid raylib.h header inclusion in this file. Data types defined on raylib are defined
*           internally in the library and input management and drawing functions must be provided by
*           the user (check library implementation for further details).
*
*       #define RAYGUI_NO_ICONS
*           Avoid including embedded ricons data (256 icons, 16x16 pixels, 1-bit per pixel, 2KB)
*
*       #define RAYGUI_CUSTOM_ICONS
*           Includes custom ricons.h header defining a set of custom icons,
*           this file can be generated using rGuiIcons tool
*
*       #define RAYGUI_DEBUG_RECS_BOUNDS
*           Draw control bounds rectangles for debug
*
*       #define RAYGUI_DEBUG_TEXT_BOUNDS
*           Draw text bounds rectangles for debug
*
*   VERSIONS HISTORY:
*       4.5-dev (Sep-2024)    Current dev version...
*                         ADDED: guiControlExclusiveMode and guiControlExclusiveRec for exclusive modes
*                         ADDED: GuiValueBoxFloat()
*                         ADDED: GuiDropdonwBox() properties: DROPDOWN_ARROW_HIDDEN, DROPDOWN_ROLL_UP
*                         ADDED: GuiListView() property: LIST_ITEMS_BORDER_WIDTH
*                         ADDED: Multiple new icons
*                         REVIEWED: GuiTabBar(), close tab with mouse middle button
*                         REVIEWED: GuiScrollPanel(), scroll speed proportional to content
*                         REVIEWED: GuiDropdownBox(), support roll up and hidden arrow
*                         REVIEWED: GuiTextBox(), cursor position initialization
*                         REVIEWED: GuiSliderPro(), control value change check
*                         REVIEWED: GuiGrid(), simplified implementation
*                         REVIEWED: GuiIconText(), increase buffer size and reviewed padding
*                         REVIEWED: GuiDrawText(), improved wrap mode drawing
*                         REVIEWED: GuiScrollBar(), minor tweaks
*                         REVIEWED: Functions descriptions, removed wrong return value reference
*                         REDESIGNED: GuiColorPanel(), improved HSV <-> RGBA convertion
*
*       4.0 (12-Sep-2023) ADDED: GuiToggleSlider()
*                         ADDED: GuiColorPickerHSV() and GuiColorPanelHSV()
*                         ADDED: Multiple new icons, mostly compiler related
*                         ADDED: New DEFAULT properties: TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE
*                         ADDED: New enum values: GuiTextAlignment, GuiTextAlignmentVertical, GuiTextWrapMode
*                         ADDED: Support loading styles with custom font charset from external file
*                         REDESIGNED: GuiTextBox(), support mouse cursor positioning
*                         REDESIGNED: GuiDrawText(), support multiline and word-wrap modes (read only)
*                         REDESIGNED: GuiProgressBar() to be more visual, progress affects border color
*                         REDESIGNED: Global alpha consideration moved to GuiDrawRectangle() and GuiDrawText()
*                         REDESIGNED: GuiScrollPanel(), get parameters by reference and return result value
*                         REDESIGNED: GuiToggleGroup(), get parameters by reference and return result value
*                         REDESIGNED: GuiComboBox(), get parameters by reference and return result value
*                         REDESIGNED: GuiCheckBox(), get parameters by reference and return result value
*                         REDESIGNED: GuiSlider(), get parameters by reference and return result value
*                         REDESIGNED: GuiSliderBar(), get parameters by reference and return result value
*                         REDESIGNED: GuiProgressBar(), get parameters by reference and return result value
*                         REDESIGNED: GuiListView(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorPicker(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorPanel(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorBarAlpha(), get parameters by reference and return result value
*                         REDESIGNED: GuiColorBarHue(), get parameters by reference and return result value
*                         REDESIGNED: GuiGrid(), get parameters by reference and return result value
*                         REDESIGNED: GuiGrid(), added extra parameter
*                         REDESIGNED: GuiListViewEx(), change parameters order
*                         REDESIGNED: All controls return result as int value
*                         REVIEWED: GuiScrollPanel() to avoid smallish scroll-bars
*                         REVIEWED: All examples and specially controls_test_suite
*                         RENAMED: gui_file_dialog module to gui_window_file_dialog
*                         UPDATED: All styles to include ISO-8859-15 charset (as much as possible)
*
*       3.6 (10-May-2023) ADDED: New icon: SAND_TIMER
*                         ADDED: GuiLoadStyleFromMemory() (binary only)
*                         REVIEWED: GuiScrollBar() horizontal movement key
*                         REVIEWED: GuiTextBox() crash on cursor movement
*                         REVIEWED: GuiTextBox(), additional inputs support
*                         REVIEWED: GuiLabelButton(), avoid text cut
*                         REVIEWED: GuiTextInputBox(), password input
*                         REVIEWED: Local GetCodepointNext(), aligned with raylib
*                         REDESIGNED: GuiSlider*()/GuiScrollBar() to support out-of-bounds
*
*       3.5 (20-Apr-2023) ADDED: GuiTabBar(), based on GuiToggle()
*                         ADDED: Helper functions to split text in separate lines
*                         ADDED: Multiple new icons, useful for code editing tools
*                         REMOVED: Unneeded icon editing functions
*                         REMOVED: GuiTextBoxMulti(), very limited and broken
*                         REMOVED: MeasureTextEx() dependency, logic directly implemented
*                         REMOVED: DrawTextEx() dependency, logic directly implemented
*                         REVIEWED: GuiScrollBar(), improve mouse-click behaviour
*                         REVIEWED: Library header info, more info, better organized
*                         REDESIGNED: GuiTextBox() to support cursor movement
*                         REDESIGNED: GuiDrawText() to divide drawing by lines
*
*       3.2 (22-May-2022) RENAMED: Some enum values, for unification, avoiding prefixes
*                         REMOVED: GuiScrollBar(), only internal
*                         REDESIGNED: GuiPanel() to support text parameter
*                         REDESIGNED: GuiScrollPanel() to support text parameter
*                         REDESIGNED: GuiColorPicker() to support text parameter
*                         REDESIGNED: GuiColorPanel() to support text parameter
*                         REDESIGNED: GuiColorBarAlpha() to support text parameter
*                         REDESIGNED: GuiColorBarHue() to support text parameter
*                         REDESIGNED: GuiTextInputBox() to support password
*
*       3.1 (12-Jan-2022) REVIEWED: Default style for consistency (aligned with rGuiLayout v2.5 tool)
*                         REVIEWED: GuiLoadStyle() to support compressed font atlas image data and unload previous textures
*                         REVIEWED: External icons usage logic
*                         REVIEWED: GuiLine() for centered alignment when including text
*                         RENAMED: Multiple controls properties definitions to prepend RAYGUI_
*                         RENAMED: RICON_ references to RAYGUI_ICON_ for library consistency
*                         Projects updated and multiple tweaks
*
*       3.0 (04-Nov-2021) Integrated ricons data to avoid external file
*                         REDESIGNED: GuiTextBoxMulti()
*                         REMOVED: GuiImageButton*()
*                         Multiple minor tweaks and bugs corrected
*
*       2.9 (17-Mar-2021) REMOVED: Tooltip API
*       2.8 (03-May-2020) Centralized rectangles drawing to GuiDrawRectangle()
*       2.7 (20-Feb-2020) ADDED: Possible tooltips API
*       2.6 (09-Sep-2019) ADDED: GuiTextInputBox()
*                         REDESIGNED: GuiListView*(), GuiDropdownBox(), GuiSlider*(), GuiProgressBar(), GuiMessageBox()
*                         REVIEWED: GuiTextBox(), GuiSpinner(), GuiValueBox(), GuiLoadStyle()
*                         Replaced property INNER_PADDING by TEXT_PADDING, renamed some properties
*                         ADDED: 8 new custom styles ready to use
*                         Multiple minor tweaks and bugs corrected
*
*       2.5 (28-May-2019) Implemented extended GuiTextBox(), GuiValueBox(), GuiSpinner()
*       2.3 (29-Apr-2019) ADDED: rIcons auxiliar library and support for it, multiple controls reviewed
*                         Refactor all controls drawing mechanism to use control state
*       2.2 (05-Feb-2019) ADDED: GuiScrollBar(), GuiScrollPanel(), reviewed GuiListView(), removed Gui*Ex() controls
*       2.1 (26-Dec-2018) REDESIGNED: GuiCheckBox(), GuiComboBox(), GuiDropdownBox(), GuiToggleGroup() > Use combined text string
*                         REDESIGNED: Style system (breaking change)
*       2.0 (08-Nov-2018) ADDED: Support controls guiLock and custom fonts
*                         REVIEWED: GuiComboBox(), GuiListView()...
*       1.9 (09-Oct-2018) REVIEWED: GuiGrid(), GuiTextBox(), GuiTextBoxMulti(), GuiValueBox()...
*       1.8 (01-May-2018) Lot of rework and redesign to align with rGuiStyler and rGuiLayout
*       1.5 (21-Jun-2017) Working in an improved styles system
*       1.4 (15-Jun-2017) Rewritten all GUI functions (removed useless ones)
*       1.3 (12-Jun-2017) Complete redesign of style system
*       1.1 (01-Jun-2017) Complete review of the library
*       1.0 (07-Jun-2016) Converted to header-only by Ramon Santamaria.
*       0.9 (07-Mar-2016) Reviewed and tested by Albert Martos, Ian Eito, Sergio Martinez and Ramon Santamaria.
*       0.8 (27-Aug-2015) Initial release. Implemented by Kevin Gato, Daniel Nicolás and Ramon Santamaria.
*
*   DEPENDENCIES:
*       raylib 5.0  - Inputs reading (keyboard/mouse), shapes drawing, font loading and text drawing
*
*   STANDALONE MODE:
*       By default raygui depends on raylib mostly for the inputs and the drawing functionality but that dependency can be disabled
*       with the config flag RAYGUI_STANDALONE. In that case is up to the user to provide another backend to cover library needs.
*
*       The following functions should be redefined for a custom backend:
*
*           - Vector2 GetMousePosition(void);
*           - float GetMouseWheelMove(void);
*           - bool IsMouseButtonDown(int button);
*           - bool IsMouseButtonPressed(int button);
*           - bool IsMouseButtonReleased(int button);
*           - bool IsKeyDown(int key);
*           - bool IsKeyPressed(int key);
*           - int GetCharPressed(void);         // -- GuiTextBox(), GuiValueBox()
*
*           - void DrawRectangle(int x, int y, int width, int height, Color color); // -- GuiDrawRectangle()
*           - void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4); // -- GuiColorPicker()
*
*           - Font GetFontDefault(void);                            // -- GuiLoadStyleDefault()
*           - Font LoadFontEx(const char *fileName, int fontSize, int *codepoints, int codepointCount); // -- GuiLoadStyle()
*           - Texture2D LoadTextureFromImage(Image image);          // -- GuiLoadStyle(), required to load texture from embedded font atlas image
*           - void SetShapesTexture(Texture2D tex, Rectangle rec);  // -- GuiLoadStyle(), required to set shapes rec to font white rec (optimization)
*           - char *LoadFileText(const char *fileName);             // -- GuiLoadStyle(), required to load charset data
*           - void UnloadFileText(char *text);                      // -- GuiLoadStyle(), required to unload charset data
*           - const char *GetDirectoryPath(const char *filePath);   // -- GuiLoadStyle(), required to find charset/font file from text .rgs
*           - int *LoadCodepoints(const char *text, int *count);    // -- GuiLoadStyle(), required to load required font codepoints list
*           - void UnloadCodepoints(int *codepoints);               // -- GuiLoadStyle(), required to unload codepoints list
*           - unsigned char *DecompressData(const unsigned char *compData, int compDataSize, int *dataSize); // -- GuiLoadStyle()
*
*   CONTRIBUTORS:
*       Ramon Santamaria:   Supervision, review, redesign, update and maintenance
*       Vlad Adrian:        Complete rewrite of GuiTextBox() to support extended features (2019)
*       Sergio Martinez:    Review, testing (2015) and redesign of multiple controls (2018)
*       Adria Arranz:       Testing and implementation of additional controls (2018)
*       Jordi Jorba:        Testing and implementation of additional controls (2018)
*       Albert Martos:      Review and testing of the library (2015)
*       Ian Eito:           Review and testing of the library (2015)
*       Kevin Gato:         Initial implementation of basic components (2014)
*       Daniel Nicolas:     Initial implementation of basic components (2014)
*
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
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


RAYGUI_VERSION_MAJOR :: 4;
RAYGUI_VERSION_MINOR :: 5;
RAYGUI_VERSION_PATCH :: 0;
RAYGUI_VERSION ::  "4.5-dev";


// Function specifiers in case library is build/used as a shared library (Windows)
// NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll

// Function specifiers definition

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
// Allow custom memory allocators

// Simple log system to avoid printf() calls if required
// NOTE: Avoiding those calls, also avoids const strings memory usage

//----------------------------------------------------------------------------------
// Types and Structures Definition
// NOTE: Some types are required for RAYGUI_STANDALONE usage
//----------------------------------------------------------------------------------

    // Vector2 type

    // Vector3 type                 // -- ConvertHSVtoRGB(), ConvertRGBtoHSV()

    // Color type, RGBA (32bit)

    // Rectangle type

    // TODO: Texture2D type is very coupled to raylib, required by Font type
    // It should be redesigned to be provided by user

    // Image, pixel data stored in CPU memory (RAM)

    // GlyphInfo, font characters glyphs info

    // TODO: Font type is very coupled to raylib, mostly required by GuiLoadStyle()
    // It should be redesigned to be provided by user

// Style property
// NOTE: Used when exporting style as code for convenience
GuiStyleProp :: struct {
    controlId: u16;    // Control identifier
    propertyId: u16;   // Property identifier
    propertyValue: s32;           // Property value
}

/*
**
// Controls text style -NOT USED-
// NOTE: Text style is defined by control
typedef struct GuiTextStyle {
unsigned int size;
int charSpacing;
int lineSpacing;
int alignmentH;
int alignmentV;
int padding;
} GuiTextStyle;
**
*/

// Gui control state
GuiState :: enum s32 {
    STATE_NORMAL :: 0;
    STATE_FOCUSED;
    STATE_PRESSED;
    STATE_DISABLED;
}

// Gui control text alignment
GuiTextAlignment :: enum s32 {
    TEXT_ALIGN_LEFT :: 0;
    TEXT_ALIGN_CENTER;
    TEXT_ALIGN_RIGHT;
}

// Gui control text alignment vertical
// NOTE: Text vertical position inside the text bounds
GuiTextAlignmentVertical :: enum s32 {
    TEXT_ALIGN_TOP :: 0;
    TEXT_ALIGN_MIDDLE;
    TEXT_ALIGN_BOTTOM;
}

// Gui control text wrap mode
// NOTE: Useful for multiline text
GuiTextWrapMode :: enum s32 {
    TEXT_WRAP_NONE :: 0;
    TEXT_WRAP_CHAR;
    TEXT_WRAP_WORD;
}

// Gui controls
GuiControl :: enum s32 {
    // Default -> populates to all controls when set
    DEFAULT :: 0;

    // Basic controls
    LABEL;          // Used also for: LABELBUTTON
    BUTTON;
    TOGGLE;         // Used also for: TOGGLEGROUP
    SLIDER;         // Used also for: SLIDERBAR, TOGGLESLIDER
    PROGRESSBAR;
    CHECKBOX;
    COMBOBOX;
    DROPDOWNBOX;
    TEXTBOX;        // Used also for: TEXTBOXMULTI
    VALUEBOX;
    SPINNER;        // Uses: BUTTON, VALUEBOX
    LISTVIEW;
    COLORPICKER;
    SCROLLBAR;
    STATUSBAR;
}

// Gui base properties for every control
// NOTE: RAYGUI_MAX_PROPS_BASE properties (by default 16 properties)
GuiControlProperty :: enum s32 {
    BORDER_COLOR_NORMAL :: 0;    // Control border color in STATE_NORMAL
    BASE_COLOR_NORMAL;          // Control base color in STATE_NORMAL
    TEXT_COLOR_NORMAL;          // Control text color in STATE_NORMAL
    BORDER_COLOR_FOCUSED;       // Control border color in STATE_FOCUSED
    BASE_COLOR_FOCUSED;         // Control base color in STATE_FOCUSED
    TEXT_COLOR_FOCUSED;         // Control text color in STATE_FOCUSED
    BORDER_COLOR_PRESSED;       // Control border color in STATE_PRESSED
    BASE_COLOR_PRESSED;         // Control base color in STATE_PRESSED
    TEXT_COLOR_PRESSED;         // Control text color in STATE_PRESSED
    BORDER_COLOR_DISABLED;      // Control border color in STATE_DISABLED
    BASE_COLOR_DISABLED;        // Control base color in STATE_DISABLED
    TEXT_COLOR_DISABLED;        // Control text color in STATE_DISABLED
    BORDER_WIDTH;               // Control border size, 0 for no border
    //TEXT_SIZE,                  // Control text size (glyphs max height) -> GLOBAL for all controls
    //TEXT_SPACING,               // Control text spacing between glyphs -> GLOBAL for all controls
    //TEXT_LINE_SPACING           // Control text spacing between lines -> GLOBAL for all controls
    TEXT_PADDING;               // Control text padding, not considering border
    TEXT_ALIGNMENT;             // Control text horizontal alignment inside control text bound (after border and padding)
    //TEXT_WRAP_MODE              // Control text wrap-mode inside text bounds -> GLOBAL for all controls
}

// TODO: Which text styling properties should be global or per-control?
// At this moment TEXT_PADDING and TEXT_ALIGNMENT is configured and saved per control while
// TEXT_SIZE, TEXT_SPACING, TEXT_LINE_SPACING, TEXT_ALIGNMENT_VERTICAL, TEXT_WRAP_MODE are global and
// should be configured by user as needed while defining the UI layout

// Gui extended properties depend on control
// NOTE: RAYGUI_MAX_PROPS_EXTENDED properties (by default, max 8 properties)
//----------------------------------------------------------------------------------
// DEFAULT extended properties
// NOTE: Those properties are common to all controls or global
// WARNING: We only have 8 slots for those properties by default!!! -> New global control: TEXT?
GuiDefaultProperty :: enum s32 {
    TEXT_SIZE :: 16;             // Text size (glyphs max height)
    TEXT_SPACING;               // Text spacing between glyphs
    LINE_COLOR;                 // Line control color
    BACKGROUND_COLOR;           // Background color
    TEXT_LINE_SPACING;          // Text spacing between lines
    TEXT_ALIGNMENT_VERTICAL;    // Text vertical alignment inside text bounds (after border and padding)
    TEXT_WRAP_MODE;              // Text wrap-mode inside text bounds
    //TEXT_DECORATION             // Text decoration: 0-None, 1-Underline, 2-Line-through, 3-Overline
    //TEXT_DECORATION_THICK       // Text decoration line thickness
}

// Other possible text properties:
// TEXT_WEIGHT                  // Normal, Italic, Bold -> Requires specific font change
// TEXT_INDENT                  // Text indentation -> Now using TEXT_PADDING...

// Label
//typedef enum { } GuiLabelProperty;

// Button/Spinner
//typedef enum { } GuiButtonProperty;

// Toggle/ToggleGroup
GuiToggleProperty :: enum s32 {
    GROUP_PADDING :: 16;         // ToggleGroup separation between toggles
}

// Slider/SliderBar
GuiSliderProperty :: enum s32 {
    SLIDER_WIDTH :: 16;          // Slider size of internal bar
    SLIDER_PADDING;              // Slider/SliderBar internal bar padding
}

// ProgressBar
GuiProgressBarProperty :: enum s32 {
    PROGRESS_PADDING :: 16;      // ProgressBar internal padding
}

// ScrollBar
GuiScrollBarProperty :: enum s32 {
    ARROWS_SIZE :: 16;           // ScrollBar arrows size
    ARROWS_VISIBLE;             // ScrollBar arrows visible
    SCROLL_SLIDER_PADDING;      // ScrollBar slider internal padding
    SCROLL_SLIDER_SIZE;         // ScrollBar slider size
    SCROLL_PADDING;             // ScrollBar scroll padding from arrows
    SCROLL_SPEED;               // ScrollBar scrolling speed
}

// CheckBox
GuiCheckBoxProperty :: enum s32 {
    CHECK_PADDING :: 16;          // CheckBox internal check padding
}

// ComboBox
GuiComboBoxProperty :: enum s32 {
    COMBO_BUTTON_WIDTH :: 16;    // ComboBox right button width
    COMBO_BUTTON_SPACING;        // ComboBox button separation
}

// DropdownBox
GuiDropdownBoxProperty :: enum s32 {
    ARROW_PADDING :: 16;         // DropdownBox arrow separation from border and items
    DROPDOWN_ITEMS_SPACING;     // DropdownBox items separation
    DROPDOWN_ARROW_HIDDEN;      // DropdownBox arrow hidden
    DROPDOWN_ROLL_UP;            // DropdownBox roll up flag (default rolls down)
}

// TextBox/TextBoxMulti/ValueBox/Spinner
GuiTextBoxProperty :: enum s32 {
    TEXT_READONLY :: 16;         // TextBox in read-only mode: 0-text editable, 1-text no-editable
}

// Spinner
GuiSpinnerProperty :: enum s32 {
    SPIN_BUTTON_WIDTH :: 16;     // Spinner left/right buttons width
    SPIN_BUTTON_SPACING;        // Spinner buttons separation
}

// ListView
GuiListViewProperty :: enum s32 {
    LIST_ITEMS_HEIGHT :: 16;     // ListView items height
    LIST_ITEMS_SPACING;         // ListView items separation
    SCROLLBAR_WIDTH;            // ListView scrollbar size (usually width)
    SCROLLBAR_SIDE;             // ListView scrollbar side (0-SCROLLBAR_LEFT_SIDE, 1-SCROLLBAR_RIGHT_SIDE)
    LIST_ITEMS_BORDER_WIDTH;     // ListView items border width
}

// ColorPicker
GuiColorPickerProperty :: enum s32 {
    COLOR_SELECTOR_SIZE :: 16;
    HUEBAR_WIDTH;               // ColorPicker right hue bar width
    HUEBAR_PADDING;             // ColorPicker right hue bar separation from panel
    HUEBAR_SELECTOR_HEIGHT;     // ColorPicker right hue bar selector height
    HUEBAR_SELECTOR_OVERFLOW;    // ColorPicker right hue bar selector overflow
}

SCROLLBAR_LEFT_SIDE ::     0;
SCROLLBAR_RIGHT_SIDE ::    1;

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------


// Global gui state control functions
GuiEnable :: () #foreign raygui_native;                                 // Enable gui controls (global state)
GuiDisable :: () #foreign raygui_native;                                // Disable gui controls (global state)
GuiLock :: () #foreign raygui_native;                                   // Lock gui controls (global state)
GuiUnlock :: () #foreign raygui_native;                                 // Unlock gui controls (global state)
GuiIsLocked :: () -> bool #foreign raygui_native;                               // Check if gui is locked (global state)
GuiSetAlpha :: (alpha: float) #foreign raygui_native;                        // Set gui controls alpha (global state), alpha goes from 0.0f to 1.0f
GuiSetState :: (state: s32) #foreign raygui_native;                          // Set gui state (global state)
GuiGetState :: () -> s32 #foreign raygui_native;                                // Get gui state (global state)

// Font set/get functions
GuiSetFont :: (font: Font) #foreign raygui_native;                           // Set gui custom font (global state)
GuiGetFont :: () -> Font #foreign raygui_native;                                // Get gui custom font (global state)

// Style set/get functions
GuiSetStyle :: (control: s32, property: s32, value: s32) #foreign raygui_native; // Set one style property
GuiGetStyle :: (control: s32, property: s32) -> s32 #foreign raygui_native;           // Get one style property

// Styles loading functions
GuiLoadStyle :: (fileName: *u8) #foreign raygui_native;              // Load style file over global style variable (.rgs)
GuiLoadStyleDefault :: () #foreign raygui_native;                       // Load style default over global style

// Tooltips management functions
GuiEnableTooltip :: () #foreign raygui_native;                          // Enable gui tooltips (global state)
GuiDisableTooltip :: () #foreign raygui_native;                         // Disable gui tooltips (global state)
GuiSetTooltip :: (tooltip: *u8) #foreign raygui_native;              // Set tooltip string

// Icons functionality
GuiIconText :: (iconId: s32, text: *u8) -> *u8 #foreign raygui_native; // Get text with icon id prepended (if supported)

// Controls
//----------------------------------------------------------------------------------------------------------
// Container/separator controls, useful for controls organization
GuiWindowBox :: (bounds: Rectangle, title: *u8) -> s32 #foreign raygui_native;                                       // Window Box control, shows a window that can be closed
GuiGroupBox :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                         // Group Box control with text name
GuiLine :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                             // Line separator control, could contain text
GuiPanel :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                            // Panel control, useful to group controls
GuiTabBar :: (bounds: Rectangle, text: **u8, count: s32, active: *s32) -> s32 #foreign raygui_native;                  // Tab Bar control, returns TAB to be closed or -1
GuiScrollPanel :: (bounds: Rectangle, text: *u8, content: Rectangle, scroll: *Vector2, view: *Rectangle) -> s32 #foreign raygui_native; // Scroll Panel control

// Basic controls set
GuiLabel :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                            // Label control
GuiButton :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                           // Button control, returns true when clicked
GuiLabelButton :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                      // Label button control, returns true when clicked
GuiToggle :: (bounds: Rectangle, text: *u8, active: *bool) -> s32 #foreign raygui_native;                             // Toggle Button control
GuiToggleGroup :: (bounds: Rectangle, text: *u8, active: *s32) -> s32 #foreign raygui_native;                         // Toggle Group control
GuiToggleSlider :: (bounds: Rectangle, text: *u8, active: *s32) -> s32 #foreign raygui_native;                        // Toggle Slider control
GuiCheckBox :: (bounds: Rectangle, text: *u8, checked: *bool) -> s32 #foreign raygui_native;                          // Check Box control, returns true when active
GuiComboBox :: (bounds: Rectangle, text: *u8, active: *s32) -> s32 #foreign raygui_native;                            // Combo Box control

GuiDropdownBox :: (bounds: Rectangle, text: *u8, active: *s32, editMode: bool) -> s32 #foreign raygui_native;          // Dropdown Box control
GuiSpinner :: (bounds: Rectangle, text: *u8, value: *s32, minValue: s32, maxValue: s32, editMode: bool) -> s32 #foreign raygui_native; // Spinner control
GuiValueBox :: (bounds: Rectangle, text: *u8, value: *s32, minValue: s32, maxValue: s32, editMode: bool) -> s32 #foreign raygui_native; // Value Box control, updates input text with numbers
GuiValueBoxFloat :: (bounds: Rectangle, text: *u8, textValue: *u8, value: *float, editMode: bool) -> s32 #foreign raygui_native; // Value box control for float values
GuiTextBox :: (bounds: Rectangle, text: *u8, textSize: s32, editMode: bool) -> s32 #foreign raygui_native;                   // Text Box control, updates input text

GuiSlider :: (bounds: Rectangle, textLeft: *u8, textRight: *u8, value: *float, minValue: float, maxValue: float) -> s32 #foreign raygui_native; // Slider control
GuiSliderBar :: (bounds: Rectangle, textLeft: *u8, textRight: *u8, value: *float, minValue: float, maxValue: float) -> s32 #foreign raygui_native; // Slider Bar control
GuiProgressBar :: (bounds: Rectangle, textLeft: *u8, textRight: *u8, value: *float, minValue: float, maxValue: float) -> s32 #foreign raygui_native; // Progress Bar control
GuiStatusBar :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                        // Status Bar control, shows info text
GuiDummyRec :: (bounds: Rectangle, text: *u8) -> s32 #foreign raygui_native;                                         // Dummy control for placeholders
GuiGrid :: (bounds: Rectangle, text: *u8, spacing: float, subdivs: s32, mouseCell: *Vector2) -> s32 #foreign raygui_native; // Grid control

// Advance controls set
GuiListView :: (bounds: Rectangle, text: *u8, scrollIndex: *s32, active: *s32) -> s32 #foreign raygui_native;          // List View control
GuiListViewEx :: (bounds: Rectangle, text: **u8, count: s32, scrollIndex: *s32, active: *s32, focus: *s32) -> s32 #foreign raygui_native; // List View with extended parameters
GuiMessageBox :: (bounds: Rectangle, title: *u8, message: *u8, buttons: *u8) -> s32 #foreign raygui_native; // Message Box control, displays a message
GuiTextInputBox :: (bounds: Rectangle, title: *u8, message: *u8, buttons: *u8, text: *u8, textMaxSize: s32, secretViewActive: *bool) -> s32 #foreign raygui_native; // Text Input Box control, ask for text, supports secret
GuiColorPicker :: (bounds: Rectangle, text: *u8, color: *Color) -> s32 #foreign raygui_native;                        // Color Picker control (multiple color controls)
GuiColorPanel :: (bounds: Rectangle, text: *u8, color: *Color) -> s32 #foreign raygui_native;                         // Color Panel control
GuiColorBarAlpha :: (bounds: Rectangle, text: *u8, alpha: *float) -> s32 #foreign raygui_native;                      // Color Bar Alpha control
GuiColorBarHue :: (bounds: Rectangle, text: *u8, value: *float) -> s32 #foreign raygui_native;                        // Color Bar Hue control
GuiColorPickerHSV :: (bounds: Rectangle, text: *u8, colorHsv: *Vector3) -> s32 #foreign raygui_native;                // Color Picker control that avoids conversion to RGB on each call (multiple color controls)
GuiColorPanelHSV :: (bounds: Rectangle, text: *u8, colorHsv: *Vector3) -> s32 #foreign raygui_native;                 // Color Panel control that updates Hue-Saturation-Value color value, used by GuiColorPickerHSV()
//----------------------------------------------------------------------------------------------------------




/*
************************************************************************************
*
*   RAYGUI IMPLEMENTATION
*
*************************************************************************************
*/


// Check if two rectangles are equal, used to validate a slider bounds as an id



// WARNING: Those values define the total size of the style data array,
// if changed, previous saved styles could become incompatible
RAYGUI_MAX_CONTROLS ::             16;     // Maximum number of controls
RAYGUI_MAX_PROPS_BASE ::           16;     // Maximum number of base properties
RAYGUI_MAX_PROPS_EXTENDED ::        8;     // Maximum number of extended properties

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// Gui control property style color element
 GuiPropertyElement :: enum s32  { BORDER :: 0; BASE; TEXT; OTHER ; } 

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------





//static int blinkCursorFrameCounter = 0;       // Frame counter for cursor blinking

//----------------------------------------------------------------------------------
// Style data array for all gui style properties (allocated on data segment by default)
//
// NOTE 1: First set of BASE properties are generic to all controls but could be individually
// overwritten per control, first set of EXTENDED properties are generic to all controls and
// can not be overwritten individually but custom EXTENDED properties can be used by control
//
// NOTE 2: A new style set could be loaded over this array using GuiLoadStyle(),
// but default gui style could always be recovered with GuiLoadStyleDefault()
//
// guiStyle size is by default: 16*(16 + 8) = 384*4 = 1536 bytes = 1.5 KB
//----------------------------------------------------------------------------------


//----------------------------------------------------------------------------------
// Standalone Mode Functions Declaration
//
// NOTE: raygui depend on some raylib input and drawing functions
// To use raygui as standalone library, below functions must be defined by the user
//----------------------------------------------------------------------------------

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------






//----------------------------------------------------------------------------------
// Gui Setup Functions Definition
//----------------------------------------------------------------------------------
// Enable gui global state
// NOTE: We check for STATE_DISABLED to avoid messing custom global state setups

// Disable gui global state
// NOTE: We check for STATE_NORMAL to avoid messing custom global state setups

// Lock gui global state

// Unlock gui global state

// Check if gui is locked (global state)

// Set gui controls alpha global state


// Set gui state (global state)

// Get gui state (global state)

// Set custom gui font
// NOTE: Font loading/unloading is external to raygui
        // NOTE: If we try to setup a font but default style has not been
        // lazily loaded before, it will be overwritten, so we need to force
        // default style loading first


// Get custom gui font

// Set control style property value

    // Default properties are propagated to all controls

// Get control style property value

//----------------------------------------------------------------------------------
// Gui Controls Functions Definition
//----------------------------------------------------------------------------------

// Window Box control
    // Window title bar height (including borders)
    // NOTE: This define is also used by GuiMessageBox() and GuiTextInputBox()

    //GuiState state = guiState;




    // Update control
    //--------------------------------------------------------------------
    // NOTE: Logic is directly managed by button
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw window close button
    //--------------------------------------------------------------------


// Group Box control with text name


    // Draw control
    //--------------------------------------------------------------------

    //--------------------------------------------------------------------


// Line control



    // Draw control
    //--------------------------------------------------------------------

        // Draw line with embedded text label: "--- text --------------"
    //--------------------------------------------------------------------


// Panel control


    // Text will be drawn as a header bar (if provided)

        // Move panel bounds after the header bar

    // Draw control
    //--------------------------------------------------------------------

    //--------------------------------------------------------------------


// Tab Bar control
// NOTE: Using GuiToggle() for the TABS

    //GuiState state = guiState;





    // Draw control
    //--------------------------------------------------------------------

            // Draw tabs as toggle controls


            // Close tab with middle mouse button pressed


            // Draw tab close button
            // NOTE: Only draw close button for current tab: if (CheckCollisionPointRec(mousePosition, tabBounds))

    // Draw tab-bar bottom line
    //--------------------------------------------------------------------


// Scroll Panel control




    // Text will be drawn as a header bar (if provided)

        // Move panel bounds after the header bar


    // Recheck to account for the other scrollbar being visible


    // Make sure scroll bars have a minimum width/height

    // Calculate view area (area without the scrollbars)

    // Clip view area to the actual content size


    // Update control
    //--------------------------------------------------------------------

        // Check button state


            // Set scrolling speed with mouse wheel based on ratio between bounds and content

            // Horizontal and vertical scrolling with mouse wheel

    // Normalize scroll values
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


    // Save size of the scrollbar slider

    // Draw horizontal scrollbar if visible
        // Change scrollbar slider size to show the diff in size between the content width and the widget width

    // Draw vertical scrollbar if visible
        // Change scrollbar slider size to show the diff in size between the content height and the widget height

    // Draw detail corner rectangle if both scroll bars are visible

    // Draw scrollbar lines depending on current state

    // Set scrollbar slider size back to the way it was before
    //--------------------------------------------------------------------



// Label control

    // Update control
    //--------------------------------------------------------------------
    //...
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
    //--------------------------------------------------------------------


// Button control, returns true when clicked

    // Update control
    //--------------------------------------------------------------------

        // Check button state

    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    //------------------------------------------------------------------


// Label button control

    // NOTE: We force bounds.width to be all text

    // Update control
    //--------------------------------------------------------------------

        // Check checkbox state

    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
    //--------------------------------------------------------------------


// Toggle Button control


    // Update control
    //--------------------------------------------------------------------

        // Check toggle button state
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    //--------------------------------------------------------------------


// Toggle Group control




    // Get substrings items from text (items pointers)






// Toggle Slider control extended


    //bool toggle = false;    // Required for individual toggles

    // Get substrings items from text (items pointers)


    // Update control
    //--------------------------------------------------------------------



    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw internal slider

    // Draw text in slider

    //--------------------------------------------------------------------


// Check Box control, returns 1 when state changed




    // Update control
    //--------------------------------------------------------------------


        // Check checkbox state

    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------


// Combo Box control




    // Get substrings items from text (items pointers, lengths and count)


    // Update control
    //--------------------------------------------------------------------


    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
    // Draw combo box main

    // Draw selector using a custom button
    // NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values


    //--------------------------------------------------------------------


// Dropdown Box control
// NOTE: Returns mouse click




    // Get substrings items from text (items pointers, lengths and count)



    // Update control
    //--------------------------------------------------------------------


            // Check if mouse has been pressed or released outside limits

            // Check if already selected item has been pressed again

            // Check focused and selected item
                // Update item rectangle y position for next item


    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


        // Draw visible items
            // Update item rectangle y position for next item


        // Draw arrows (using icon if available)
    //--------------------------------------------------------------------


    // TODO: Use result to return more internal states: mouse-press out-of-bounds, mouse-press over selected-item...

// Text Box control
// NOTE: Returns true on ENTER pressed (useful for data validation)




    // Cursor rectangle
    // NOTE: Position X value should be updated


    // Mouse cursor rectangle
    // NOTE: Initialized outside of screen

    // Auto-cursor movement logic
    // NOTE: Cursor moves automatically when key down after some time

    // Blink-cursor frame counter
    //if (!autoCursorMode) blinkCursorFrameCounter++;
    //else blinkCursorFrameCounter = 0;

    // Update control
    //--------------------------------------------------------------------
    // WARNING: Text editing is only supported under certain conditions:



            // If text does not fit in the textbox and current cursor position is out of bounds,
            // we add an index offset to text for drawing only what requires depending on cursor




            // Encode codepoint as UTF-8

            // Add codepoint to text, at current cursor position
            // NOTE: Make sure we do not overflow buffer size
                // Move forward data from cursor position

                // Add new codepoint in current cursor position


                // Make sure text last character is EOL

            // Move cursor to start

            // Move cursor to end

            // Delete codepoint from text, after current cursor position


                    // Move backward text from cursor position


                    // Make sure text last character is EOL

            // Delete related codepoints from text, before current cursor position

                // Move cursor to the end of word if on space already

                // Move cursor to the start of the word

                // Move forward text from cursor position

                // Prevent cursor index from decrementing past 0

                // Make sure text last character is EOL


                    // Prevent cursor index from decrementing past 0

                        // Move backward text from cursor position


                    // Make sure text last character is EOL

            // Move cursor position with keys





            // Move cursor position with mouse





                // Check if mouse cursor is at the last position

                // Place cursor at required index on mouse click

            // Recalculate cursor position.y depending on textBoxCursorIndex
            //if (multiline) cursor.y = GetTextLines()

            // Finish text editing on ENTER or mouse click outside bounds

    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw text considering index offset if required
    // NOTE: Text index offset depends on cursor position

    // Draw cursor
        //if (autoCursorMode || ((blinkCursorFrameCounter/40)%2 == 0))

        // Draw mouse position cursor (if required)
    //--------------------------------------------------------------------


/*
**
// Text Box control with multiple lines and word-wrap
// NOTE: This text-box is readonly, no editing supported by default
bool GuiTextBoxMulti(Rectangle bounds, char *text, int textSize, bool editMode)
{
bool pressed = false;

GuiSetStyle(TEXTBOX, TEXT_READONLY, 1);
GuiSetStyle(DEFAULT, TEXT_WRAP_MODE, TEXT_WRAP_WORD);   // WARNING: If wrap mode enabled, text editing is not supported
GuiSetStyle(DEFAULT, TEXT_ALIGNMENT_VERTICAL, TEXT_ALIGN_TOP);

// TODO: Implement methods to calculate cursor position properly
pressed = GuiTextBox(bounds, text, textSize, editMode);

GuiSetStyle(DEFAULT, TEXT_ALIGNMENT_VERTICAL, TEXT_ALIGN_MIDDLE);
GuiSetStyle(DEFAULT, TEXT_WRAP_MODE, TEXT_WRAP_NONE);
GuiSetStyle(TEXTBOX, TEXT_READONLY, 0);

return pressed;
}
**
*/

// Spinner control, returns selected value




    // Update control
    //--------------------------------------------------------------------

        // Check spinner state


    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw value selector custom buttons
    // NOTE: BORDER_WIDTH and TEXT_ALIGNMENT forced values


    // Draw text label if provided
    //--------------------------------------------------------------------


// Value Box control, updates input text with numbers
// NOTE: Requires static variables: frameCounter




    // Update control
    //--------------------------------------------------------------------




            // Only allow keys in range [48..57]

            // Delete text


            // NOTE: We are not clamp values until user input finishes
            //if (*value > maxValue) *value = maxValue;
            //else if (*value < minValue) *value = minValue;



    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


    // Draw cursor
        // NOTE: ValueBox internal text is always centered

    // Draw text label if provided
    //--------------------------------------------------------------------


// Floating point Value Box control, updates input val_str with numbers
// NOTE: Requires static variables: frameCounter


    //char textValue[RAYGUI_VALUEBOX_MAX_CHARS + 1] = "\0";
    //sprintf(textValue, "%2.2f", *value);


    // Update control
    //--------------------------------------------------------------------




            // Only allow keys in range [48..57]


            // Pressed backspace


    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


    // Draw cursor
        // NOTE: ValueBox internal text is always centered

    // Draw text label if provided
    //--------------------------------------------------------------------


// Slider control with pro parameters
// NOTE: Other GuiSlider*() controls use this one



    // Update control
    //--------------------------------------------------------------------

                    // Get equivalent value and slider position from mousePosition.x

                    // Get equivalent value and slider position from mousePosition.x


    // Control value change check

    // Slider bar limits check
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw slider internal bar (depends on state)

    // Draw left/right text if provided



    //--------------------------------------------------------------------


// Slider control extended, returns selected value and has text

// Slider Bar control extended, returns selected value

// Progress Bar control extended, shows current progress value


    // Progress bar

    // Update control
    //--------------------------------------------------------------------

    // WARNING: Working with floats could lead to rounding issues
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
            // Draw progress bar with colored border, more visual

            // Draw borders not yet reached by value

        // Draw slider internal progress bar (depends on state)

    // Draw left/right text if provided



    //--------------------------------------------------------------------


// Status Bar control

    // Draw control
    //--------------------------------------------------------------------
    //--------------------------------------------------------------------


// Dummy rectangle control, intended for placeholding

    // Update control
    //--------------------------------------------------------------------

        // Check button state
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
    //------------------------------------------------------------------


// List View control




// List View control with extended parameters


    // Check if we need a scroll bar

    // Define base item rectangle [0]

    // Get items on the list


    // Update control
    //--------------------------------------------------------------------

        // Check mouse inside list view

            // Check focused and selected item

                // Update item rectangle y position for next item




        // Reset item rectangle y to [0]
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw visible items


                // Draw item selected
                // Draw item focused
                // Draw item normal

        // Update item rectangle y position for next item


        // Calculate percentage of visible items and apply same percentage to scrollbar



    //--------------------------------------------------------------------



// Color Panel control - Color (RGBA) variant.



    // Check if the hsv was changed, only then change the color.
    // This is required, because the Color->HSV->Color conversion has precision errors.
    // Thus the assignment from HSV to Color should only be made, if the HSV has a new user-entered value.
    // Otherwise GuiColorPanel would often modify it's color without user input.
    // TODO: GuiColorPanelHSV could return 1 if the slider was dragged, to simplify this check.

        // NOTE: Vector3ToColor() only available on raylib 1.8.1

// Color Bar Alpha control
// NOTE: Returns alpha value normalized [0..1]


    // Update control
    //--------------------------------------------------------------------



                //selector.x = bounds.x + (int)(((alpha - 0)/(100 - 0))*(bounds.width - 2*GuiGetStyle(SLIDER, BORDER_WIDTH))) - selector.width/2;
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

    // Draw alpha bar: checked background




    // Draw alpha bar: selector
    //--------------------------------------------------------------------


// Color Bar Hue control
// Returns hue value normalized [0..1]
// NOTE: Other similar bars (for reference):
//      Color GuiColorBarSat() [WHITE->color]
//      Color GuiColorBarValue() [BLACK->color], HSV/HSL
//      float GuiColorBarLuminance() [BLACK->WHITE]

    // Update control
    //--------------------------------------------------------------------





/*
**if (IsKeyDown(KEY_UP))
{
hue -= 2.0f;
if (hue <= 0.0f) hue = 0.0f;
}
else if (IsKeyDown(KEY_DOWN))
{
hue += 2.0f;
if (hue >= 360.0f) hue = 360.0f;
}**
*/
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------
        // Draw hue bar:color bars
        // TODO: Use directly DrawRectangleGradientEx(bounds, color1, color2, color2, color1);


    // Draw hue bar: selector
    //--------------------------------------------------------------------


// Color Picker control
// NOTE: It's divided in multiple controls:
//      Color GuiColorPanel(Rectangle bounds, Color color)
//      float GuiColorBarAlpha(Rectangle bounds, float alpha)
//      float GuiColorBarHue(Rectangle bounds, float value)
// NOTE: bounds define GuiColorPanel() size
// NOTE: this picker converts RGB to HSV, which can cause the Hue control to jump. If you have this problem, consider using the HSV variant instead



    //Rectangle boundsAlpha = { bounds.x, bounds.y + bounds.height + GuiGetStyle(COLORPICKER, BARS_PADDING), bounds.width, GuiGetStyle(COLORPICKER, BARS_THICK) };

    // NOTE: this conversion can cause low hue-resolution, if the r, g and b value are very similar, which causes the hue bar to shift around when only the GuiColorPanel is used.


    //color.a = (unsigned char)(GuiColorBarAlpha(boundsAlpha, (float)color.a/255.0f)*255.0f);



// Color Picker control that avoids conversion to RGB and back to HSV on each call, thus avoiding jittering.
// The user can call ConvertHSVtoRGB() to convert *colorHsv value to RGB.
// NOTE: It's divided in multiple controls:
//      int GuiColorPanelHSV(Rectangle bounds, const char *text, Vector3 *colorHsv)
//      int GuiColorBarAlpha(Rectangle bounds, const char *text, float *alpha)
//      float GuiColorBarHue(Rectangle bounds, float value)
// NOTE: bounds define GuiColorPanelHSV() size







// Color Panel control - HSV variant




    // Update control
    //--------------------------------------------------------------------



                    // Calculate color from picker




                // Calculate color from picker


    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

        // Draw color picker: selector

    //--------------------------------------------------------------------


// Message Box control



    //int textWidth = GetTextWidth(message) + 2;


    // Draw control
    //--------------------------------------------------------------------




    //--------------------------------------------------------------------


// Text Input Box control, ask for text

    // Used to enable text edit mode
    // WARNING: No more than one GuiTextInputBox() should be open at the same time







    // Draw control
    //--------------------------------------------------------------------

    // Draw message if available






    //--------------------------------------------------------------------


// Grid control
// NOTE: Returns grid mouse-hover selected cell
// About drawing lines at subpixel spacing, simple put, not easy solution:
// https://stackoverflow.com/questions/4435450/2d-opengl-drawing-lines-that-dont-exactly-fit-pixel-raster
    // Grid lines alpha amount





    // Update control
    //--------------------------------------------------------------------
            // NOTE: Cell values must be the upper left of the cell the mouse is in
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------

        // Draw vertical grid lines

        // Draw horizontal grid lines


//----------------------------------------------------------------------------------
// Tooltip management functions
// NOTE: Tooltips requires some global variables: tooltipPtr
//----------------------------------------------------------------------------------
// Enable gui tooltips (global state)

// Disable gui tooltips (global state)

// Set tooltip string

//----------------------------------------------------------------------------------
// Styles loading functions
//----------------------------------------------------------------------------------

// Load raygui style file (.rgs)
// NOTE: By default a binary file is expected, that file could contain a custom font,
// in that case, custom font image atlas is GRAY+ALPHA and pixel data can be compressed (DEFLATE)


    // Try reading the files as text file first



                        // Style property: p <control_id> <property_id> <property_value> <property_name>


                        // Style font: f <gen_font_size> <charmap_file> <font_file>



                            // Load text data from file
                            // NOTE: Expected an UTF-8 array of codepoints, no separation

                            // In case a font is already loaded and it is not default internal font, unload it


                        // If font texture not properly loaded, revert to default font and size/spacing












// Load style default over global style
    // We set this variable first to avoid cyclic function calls
    // when calling GuiSetStyle() and GuiGetStyle()

    // Initialize default LIGHT style property values
    // WARNING: Default value are applied to all controls on set but
    // they can be overwritten later on for every custom control

    // Initialize default extended property values
    // NOTE: By default, extended property values are initialized to 0

    // Initialize control-specific property values
    // NOTE: Those properties are in default list but require specific values by control type

    // Initialize extended property values
    // NOTE: By default, extended property values are initialized to 0

        // Unload previous font texture

        // Setup default raylib font

        // NOTE: Default raylib font character 95 is a white square

        // NOTE: We set up a 1px padding on char rectangle to avoid pixel bleeding on MSAA filtering

// Get text with icon id prepended
// NOTE: Useful to add icons by name id (enum) instead of
// a number that can change between ricon versions


//----------------------------------------------------------------------------------
// Module specific Functions Definition
//----------------------------------------------------------------------------------

// Load style from memory
// WARNING: Binary files only





                // If a DEFAULT property is loaded, it is propagated to all controls
                // NOTE: All DEFAULT properties should be defined first in the file


        // Font loading is highly dependant on raylib API to load font data and image


// Gui get text width considering icon




        // Make sure guiFont is set, GuiGetStyle() initializes it lazynessly

        // Custom MeasureText() implementation
            // Get size in bytes of text, considering end of line and line break







// Get text bounds considering control bounds


    // Depending on control, TEXT_PADDING and TEXT_ALIGNMENT properties could affect the text-bounds
            // TODO: Special cases (no label): COMBOBOX, DROPDOWNBOX, LISTVIEW
            // TODO: More special cases (label on side): SLIDER, CHECKBOX, VALUEBOX, SPINNER
            // TODO: WARNING: TEXT_ALIGNMENT is already considered in GuiDrawText()


// Get text icon if provided and move text cursor
// NOTE: We support up to 999 values for iconId


// Get text divided into lines (by line-breaks '\n')



    //int lineSize = 0;   // Stores current line size, not returned

            //lineSize = len;

    //lines[*count - 1].size = len;


// Get text width to next space for provided string



// Gui draw text using default font



    // PROCEDURE:
    //   - Text is processed line per line
    //   - For every line, horizontal alignment is defined
    //   - For all text, vertical alignment is defined (multiline text only)
    //   - For every line, wordwrap mode is checked (useful for GuitextBox(), read-only)

    // Get text lines (using '\n' as delimiter) to be processed individually
    // WARNING: We can't use GuiTextSplit() function because it can be already used
    // before the GuiDrawText() call and its buffer is static, it would be overriden :(

    // Text style variables
    //int alignment = GuiGetStyle(DEFAULT, TEXT_ALIGNMENT);

    // TODO: WARNING: This totalHeight is not valid for vertical alignment in case of word-wrap


        // Get text position depending on alignment and iconId
        //---------------------------------------------------------------------------------

        // NOTE: We get text size after icon has been processed
        // WARNING: GetTextWidth() also processes text icon to get width! -> Really needed?

        // If text requires an icon, add size to measure

            // WARNING: If only icon provided, text could be pointing to EOF character: '\0'

        // Check guiTextAlign global variables


            // Only valid in case of wordWrap = 0;

        // NOTE: Make sure we get pixel-perfect coordinates,
        // In case of decimals we got weird text positioning
        //---------------------------------------------------------------------------------

        // Draw text (with icon if available)
        //---------------------------------------------------------------------------------
        // Get size in bytes of text,
        // considering end of line and line break




            // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
            // but we need to draw all of the bad bytes using the '?' symbol moving one byte

            // Get glyph width to check if it goes out of bounds

            // Wrap mode text measuring, to validate if
            // it can be drawn or a new line is required
                // Jump to next line if current character reach end of the box limits


                // Get width to next space in line


                    // Considering the case the next word is longer than bounds

                // TODO: There are multiple types of spaces in Unicode,
                // maybe it's a good idea to add support for more: http://jkorpela.fi/chars/spaces.html
                        // Draw only required text glyphs fitting the textBounds.width

                        // Draw only glyphs inside the bounds


        //---------------------------------------------------------------------------------


// Gui draw rectangle using default raygui plain style with borders
        // Draw rectangle filled with color

        // Draw rectangle border lines with color


// Draw tooltip using control bounds




// Split controls text into multiple strings
// Also check for multiple columns (required by GuiToggleGroup())
    // NOTE: Current implementation returns a copy of the provided string with '\0' (string end delimiter)
    // inserted between strings defined by "delimiter" parameter. No memory is dynamically allocated,
    // all used memory is static... it has some limitations:
    //      1. Maximum number of possible split strings is set by RAYGUI_TEXTSPLIT_MAX_ITEMS
    //      2. Maximum size of text to split is RAYGUI_TEXTSPLIT_MAX_TEXT_SIZE
    // NOTE: Those definitions could be externally provided if required

    // TODO: HACK: GuiTextSplit() - Review how textRows are returned to user
    // textRow is an externally provided array of integers that stores row number for every splitted string





    // Count how many substrings we have on text and point to every one






// Convert color data from RGB to HSV
// NOTE: Color data should be passed normalized





        // NOTE: If max is 0, this divide would cause a crash
        // NOTE: If max is 0, then r = g = b = 0, s = 0, h is undefined

    // NOTE: Comparing float values could not work properly




// Convert color data from HSV to RGB
// NOTE: Color data should be passed normalized

    // NOTE: Comparing float values could not work properly





// Scroll bar control (used by GuiScrollPanel())

    // Is the scrollbar horizontal or vertical?

    // The size (width or height depending on scrollbar type) of the spinner buttons

    // Arrow buttons [<] [>] [∧] [∨]

    // Actual area of the scrollbar excluding the arrow buttons

    // Slider bar that moves     --[///]-----

    // Normalize value



    // Calculate rectangles for all of the components


        // Make sure the slider won't get outside of the scrollbar

        // Make sure the slider won't get outside of the scrollbar

    // Update control
    //--------------------------------------------------------------------



            // Handle mouse wheel

            // Handle mouse button down

                // Check arrows click
                    // If click on scrollbar position but not on slider, place slider directly on that position


            // Keyboard control on mouse hover scrollbar
/*
**
if (isVertical)
{
if (IsKeyDown(KEY_DOWN)) value += 5;
else if (IsKeyDown(KEY_UP)) value -= 5;
}
else
{
if (IsKeyDown(KEY_RIGHT)) value += 5;
else if (IsKeyDown(KEY_LEFT)) value -= 5;
}
**
*/

        // Normalize value
    //--------------------------------------------------------------------

    // Draw control
    //--------------------------------------------------------------------


    // Draw arrows (using icon if available)
    //--------------------------------------------------------------------


// Color fade-in or fade-out, alpha goes from 0.0f to 1.0f
// WARNING: It multiplies current alpha by alpha scale factor





