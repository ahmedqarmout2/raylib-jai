#import "raylib";
#import "Basic";
#import "Math";

LETTER_BOUNDRY_SIZE     : float : 0.25;
TEXT_MAX_LAYERS         : s32   : 32;
LETTER_BOUNDRY_COLOR    : Color : VIOLET;

SHOW_LETTER_BOUNDRY := false;
SHOW_TEXT_BOUNDRY   := false;

WaveTextConfig :: struct {
    waveRange : Vector3;
    waveSpeed : Vector3;
    waveOffset: Vector3;
};

main :: () {
    set_working_directory(#filepath);

    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth  : s32 : 800;
    screenHeight : s32 : 450;

    SetConfigFlags(.FLAG_MSAA_4X_HINT | .FLAG_VSYNC_HINT);

    InitWindow(screenWidth, screenHeight, "raylib [text] example - draw 2D text in 3D");
    defer CloseWindow(); // Close window and OpenGL context

    spin      : bool = true;        // Spin the camera?
    multicolor: bool = false; // Multicolor mode

    // Define the camera to look into our 3d world
    camera: Camera3D;
    camera.position   = Vector3.{-10.0, 15.0, -10.0};   // Camera position
    camera.target     = Vector3.{0.0, 0.0, 0.0};          // Camera looking at point
    camera.up         = Vector3.{0.0, 1.0, 0.0};              // Camera up vector (rotation towards target)
    camera.fovy       = 45.0;                                    // Camera field-of-view Y
    camera.projection = .CAMERA_PERSPECTIVE;                 // Camera projection type

    camera_mode: CameraMode = .CAMERA_ORBITAL;

    cubePosition: Vector3 = .{0.0, 1.0, 0.0};
    cubeSize    : Vector3 = .{2.0, 2.0, 2.0};

    // Use the default font
    font: Font = GetFontDefault();
    defer UnloadFont(font);

    fontSize   : float = 8.0;
    fontSpacing: float = 0.5;
    lineSpacing: float = -1.0;

    // Set the text (using markdown!)
    text: [64]u8;
    s := "Hello ~~World~~ in 3D!";
    for s text[it_index] = it;

    tbox: Vector3;
    layers: s32 = 1;
    quads : s32 = 0;
    layerDistance: float = 0.01;

    wcfg: WaveTextConfig;
    wcfg.waveSpeed.x  = 3.0;
    wcfg.waveSpeed.y  = 3.0;
    wcfg.waveSpeed.z  = 0.5;
    wcfg.waveOffset.x = 0.35;
    wcfg.waveOffset.y = 0.35;
    wcfg.waveOffset.z = 0.35;
    wcfg.waveRange.x  = 0.45;
    wcfg.waveRange.y  = 0.45;
    wcfg.waveRange.z  = 0.45;

    time: float = 0.0;

    // Setup a light and dark color
    light: Color = MAROON;
    dark : Color = RED;

    // Load the alpha discard shader
    alphaDiscard: Shader = LoadShader(null, "resources/shaders/glsl330/alpha_discard.fs");
    defer UnloadShader(alphaDiscard);

    // Array filled with multiple random colors (when multicolor mode is set)
    multi: [TEXT_MAX_LAYERS]Color;

    // DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    while (!WindowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(*camera, camera_mode);
        
        // Handle font files dropped
        if (IsFileDropped()) {
            droppedFiles: FilePathList = LoadDroppedFiles();
            defer UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory

            // NOTE: We only support first ttf file dropped
            if (IsFileExtension(droppedFiles.paths[0], ".ttf")) {
                UnloadFont(font);
                font = LoadFontEx(droppedFiles.paths[0], cast(s32)fontSize, null, 0);
            } else if (IsFileExtension(droppedFiles.paths[0], ".fnt")) {
                UnloadFont(font);
                font = LoadFont(droppedFiles.paths[0]);
                fontSize = cast(float)font.baseSize;
            }
        }

        // Handle Events
        if (IsKeyPressed(.KEY_F1)) SHOW_LETTER_BOUNDRY = !SHOW_LETTER_BOUNDRY;
        if (IsKeyPressed(.KEY_F2)) SHOW_TEXT_BOUNDRY   = !SHOW_TEXT_BOUNDRY;
        if (IsKeyPressed(.KEY_F3)) {
            // Handle camera change
            spin = !spin;
            // we need to reset the camera when changing modes
            camera.target     = Vector3.{0.0, 0.0, 0.0};          // Camera looking at point
            camera.up         = Vector3.{0.0, 1.0, 0.0};              // Camera up vector (rotation towards target)
            camera.fovy       = 45.0;                                    // Camera field-of-view Y
            camera.projection = .CAMERA_PERSPECTIVE;                 // Camera mode type

            if (spin) {
                camera.position = Vector3.{-10.0, 15.0, -10.0};   // Camera position
                camera_mode     = .CAMERA_ORBITAL;
            } else {
                camera.position = Vector3.{10.0, 10.0, -10.0};   // Camera position
                camera_mode     = .CAMERA_FREE;
            }
        }

        // Handle clicking the cube
        if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
            ray: Ray = GetScreenToWorldRay(GetMousePosition(), camera);

            // Check collision between ray and box
            collision: RayCollision = GetRayCollisionBox(
                ray,
                BoundingBox.{
                    Vector3.{cubePosition.x - cubeSize.x/2, cubePosition.y - cubeSize.y/2, cubePosition.z - cubeSize.z/2},
                    Vector3.{cubePosition.x + cubeSize.x/2, cubePosition.y + cubeSize.y/2, cubePosition.z + cubeSize.z/2}});
            if (collision.hit) {
                // Generate new random colors
                light = GenerateRandomColor(0.5, 0.78);
                dark  = GenerateRandomColor(0.4, 0.58);
            }
        }

        // Handle text layers changes
        if      (IsKeyPressed(.KEY_HOME)) { if (layers > 1)               layers -= 1; }
        else if (IsKeyPressed(.KEY_END))  { if (layers < TEXT_MAX_LAYERS) layers += 1; }

        // Handle text changes
        if      (IsKeyPressed(.KEY_LEFT))      fontSize      -= 0.5;
        else if (IsKeyPressed(.KEY_RIGHT))     fontSize      += 0.5;
        else if (IsKeyPressed(.KEY_UP))        fontSpacing   -= 0.1;
        else if (IsKeyPressed(.KEY_DOWN))      fontSpacing   += 0.1;
        else if (IsKeyPressed(.KEY_PAGE_UP))   lineSpacing   -= 0.1;
        else if (IsKeyPressed(.KEY_PAGE_DOWN)) lineSpacing   += 0.1;
        else if (IsKeyDown(.KEY_INSERT))       layerDistance -= 0.001;
        else if (IsKeyDown(.KEY_DELETE))       layerDistance += 0.001;
        else if (IsKeyPressed(.KEY_TAB)) {
            multicolor = !multicolor;   // Enable /disable multicolor mode

            if (multicolor) {
                // Fill color array with random colors
                for i: 0..TEXT_MAX_LAYERS-1 {
                    multi[i]   = GenerateRandomColor(0.5, 0.8);
                    multi[i].a = cast(u8) GetRandomValue(0, 255);
                }
            }
        }

        // Handle text input
        ch: u8 = GetCharPressed();
        if (IsKeyPressed(.KEY_BACKSPACE)) {
            // Remove last char
            len: s32 = cast(s32) TextLength(text.data);
            if (len > 0) text[len - 1] = #char "\0";
        } else if (IsKeyPressed(.KEY_ENTER)) {
            // handle newline
            len: s32 = cast(s32) TextLength(text.data);
            if (len < text.count - 1) {
                text[len]   = #char "\n";
                text[len+1] = #char "\0";
            }
        } else {
            // append only printable chars
            len: s32 = cast(s32) TextLength(text.data);
            if (len < text.count - 1) {
                text[len]   = ch;
                text[len+1] = #char "\0";
            }
        }

        // Measure 3D text so we can center it
        tbox = MeasureTextWave3D(font, text.data, fontSize, fontSpacing, lineSpacing);

        quads = 0;                      // Reset quad counter
        time += GetFrameTime();         // Update timer needed by `DrawTextWave3D()`
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();
        defer EndDrawing();

        ClearBackground(RAYWHITE);

        {
            BeginMode3D(camera);
            defer EndMode3D();

            DrawCubeV(cubePosition, cubeSize, dark);
            DrawCubeWires(cubePosition, 2.1, 2.1, 2.1, light);

            DrawGrid(10, 2.0);

            {
                // Use a shader to handle the depth buffer issue with transparent textures
                // NOTE: more info at https://bedroomcoders.co.uk/raylib-billboards-advanced-use/
                BeginShaderMode(alphaDiscard);
                defer EndShaderMode();

                {
                    // Draw the 3D text above the red cube
                    rlPushMatrix();
                    defer rlPopMatrix();

                    rlRotatef(90.0, 1.0, 0.0, 0.0);
                    rlRotatef(90.0, 0.0, 0.0, -1.0);

                    for i: 0..layers-1 {
                        clr: Color = light;
                        if (multicolor) clr = multi[i];
                        DrawTextWave3D(font, text.data, Vector3.{-tbox.x/2.0, layerDistance*i, -4.5}, fontSize, fontSpacing, lineSpacing, true, *wcfg, time, clr);
                    }

                    // Draw the text boundry if set
                    if (SHOW_TEXT_BOUNDRY) DrawCubeWiresV(Vector3.{0.0, 0.0, -4.5 + tbox.z/2}, tbox, dark);
                }

                // Don't draw the letter boundries for the 3D text below
                slb: bool = SHOW_LETTER_BOUNDRY;
                SHOW_LETTER_BOUNDRY = false;

                {
                    // Draw 3D options (use default font)
                    //-------------------------------------------------------------------------
                    rlPushMatrix();
                    defer rlPopMatrix();

                    rlRotatef(180.0, 0.0, 1.0, 0.0);
                    opt: *u8 = cast(*u8)TextFormat("< SIZE: %2.1 >", fontSize);
                    quads += cast(s32) TextLength(opt);
                    m  : Vector3 = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos: Vector3 = .{ -m.x/2.0, 0.01, 2.0};
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, BLUE);
                    pos.z += 0.5 + m.z;

                    opt = cast(*u8)TextFormat("< SPACING: %2.1 >", fontSpacing);
                    quads += cast(s32) TextLength(opt);
                    m = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos.x = -m.x/2.0;
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, BLUE);
                    pos.z += 0.5 + m.z;

                    opt = cast(*u8)TextFormat("< LINE: %2.1 >", lineSpacing);
                    quads += cast(s32) TextLength(opt);
                    m = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos.x = -m.x/2.0;
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, BLUE);
                    pos.z += 1.0 + m.z;

                    opt = cast(*u8)TextFormat("< LBOX: %3s >", get_c_string(ifx slb then "ON" else "OFF"));
                    quads += cast(s32) TextLength(opt);
                    m = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos.x = -m.x/2.0;
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, RED);
                    pos.z += 0.5 + m.z;

                    opt = cast(*u8)TextFormat("< TBOX: %3s >", get_c_string(ifx SHOW_TEXT_BOUNDRY then "ON" else "OFF"));
                    quads += cast(s32) TextLength(opt);
                    m = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos.x = -m.x/2.0;
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, RED);
                    pos.z += 0.5 + m.z;

                    opt = cast(*u8)TextFormat("< LAYER DISTANCE: %.3f >", layerDistance);
                    quads += cast(s32) TextLength(opt);
                    m = MeasureText3D(GetFontDefault(), opt, 8.0, 1.0, 0.0);
                    pos.x = -m.x/2.0;
                    DrawText3D(GetFontDefault(), opt, pos, 8.0, 1.0, 0.0, false, DARKPURPLE);
                    //-------------------------------------------------------------------------
                }

                // Draw 3D info text (use default font)
                //-------------------------------------------------------------------------
                opt := "All the text displayed here is in 3D";
                quads += 36;
                m := MeasureText3D(GetFontDefault(), opt.data, 10.0, 0.5, 0.0);
                pos := Vector3.{-m.x/2.0, 0, 2.0};
                DrawText3D(GetFontDefault(), opt.data, pos, 10.0, 0.5, 0.0, false, DARKBLUE);
                pos.z += 1.5 + m.z;

                opt = "press [Left]/[Right] to change the font size";
                quads += 44;
                m = MeasureText3D(GetFontDefault(), opt.data, 6.0, 0.5, 0.0);
                pos.x = -m.x/2.0;
                DrawText3D(GetFontDefault(), opt.data, pos, 6.0, 0.5, 0.0, false, DARKBLUE);
                pos.z += 0.5 + m.z;

                opt = "press [Up]/[Down] to change the font spacing";
                quads += 44;
                m = MeasureText3D(GetFontDefault(), opt.data, 6.0, 0.5, 0.0);
                pos.x = -m.x/2.0;
                DrawText3D(GetFontDefault(), opt.data, pos, 6.0, 0.5, 0.0, false, DARKBLUE);
                pos.z += 0.5 + m.z;

                opt = "press [PgUp]/[PgDown] to change the line spacing";
                quads += 48;
                m = MeasureText3D(GetFontDefault(), opt.data, 6.0, 0.5, 0.0);
                pos.x = -m.x/2.0;
                DrawText3D(GetFontDefault(), opt.data, pos, 6.0, 0.5, 0.0, false, DARKBLUE);
                pos.z += 0.5 + m.z;

                opt = "press [F1] to toggle the letter boundry";
                quads += 39;
                m = MeasureText3D(GetFontDefault(), opt.data, 6.0, 0.5, 0.0);
                pos.x = -m.x/2.0;
                DrawText3D(GetFontDefault(), opt.data, pos, 6.0, 0.5, 0.0, false, DARKBLUE);
                pos.z += 0.5 + m.z;

                opt = "press [F2] to toggle the text boundry";
                quads += 37;
                m = MeasureText3D(GetFontDefault(), opt.data, 6.0, 0.5, 0.0);
                pos.x = -m.x/2.0;
                DrawText3D(GetFontDefault(), opt.data, pos, 6.0, 0.5, 0.0, false, DARKBLUE);
                //-------------------------------------------------------------------------

                SHOW_LETTER_BOUNDRY = slb;
            }
        }

        // Draw 2D info text & stats
        //-------------------------------------------------------------------------
        DrawText("Drag & drop a font file to change the font!\nType something, see what happens!\n\nPress [F3] to toggle the camera", 10, 35, 10, BLACK);

        quads += cast(s32) TextLength(text.data)*2*layers;
        tmp: *u8 = cast(*u8)TextFormat("%2i layer(s) | %s camera | %4i quads (%4i verts)", layers, get_c_string(ifx spin then "ORBITAL" else "FREE"), quads, quads*4);
        width: s32 = MeasureText(tmp, 10);
        DrawText(tmp, screenWidth - 20 - width, 10, 10, DARKGREEN);

        tmp = "[Home]/[End] to add/remove 3D text layers";
        width = MeasureText(tmp, 10);
        DrawText(tmp, screenWidth - 20 - width, 25, 10, DARKGRAY);

        tmp = "[Insert]/[Delete] to increase/decrease distance between layers";
        width = MeasureText(tmp, 10);
        DrawText(tmp, screenWidth - 20 - width, 40, 10, DARKGRAY);

        tmp = "click the [CUBE] for a random color";
        width = MeasureText(tmp, 10);
        DrawText(tmp, screenWidth - 20 - width, 55, 10, DARKGRAY);

        tmp = "[Tab] to toggle multicolor mode";
        width = MeasureText(tmp, 10);
        DrawText(tmp, screenWidth - 20 - width, 70, 10, DARKGRAY);
        //-------------------------------------------------------------------------

        DrawFPS(10, 10);
        //----------------------------------------------------------------------------------
    }
}

//--------------------------------------------------------------------------------------
// Module Functions Definitions
//--------------------------------------------------------------------------------------
// Draw codepoint at specified position in 3D space
DrawTextCodepoint3D :: (font: Font, codepoint: s32, _position: Vector3, fontSize: float, backface: bool, tint: Color) {
    // Character index position in sprite font
    // NOTE: In case a codepoint is not available in the font, index returned points to '?'
    index: s32 = GetGlyphIndex(font, codepoint);
    scale: float = fontSize/cast(float)font.baseSize;

    position := _position;

    // Character destination rectangle on screen
    // NOTE: We consider charsPadding on drawing
    position.x += cast(float)(font.glyphs[index].offsetX - font.glyphPadding)/cast(float)font.baseSize*scale;
    position.z += cast(float)(font.glyphs[index].offsetY - font.glyphPadding)/cast(float)font.baseSize*scale;

    // Character source rectangle from font texture atlas
    // NOTE: We consider chars padding when drawing, it could be required for outline/glow shader effects
    srcRec: Rectangle = .{
        font.recs[index].x - cast(float)font.glyphPadding,
        font.recs[index].y - cast(float)font.glyphPadding,
        font.recs[index].width + 2.0*font.glyphPadding,
        font.recs[index].height + 2.0*font.glyphPadding
    };

    width : float = cast(float)(font.recs[index].width + 2.0*font.glyphPadding)/cast(float)font.baseSize*scale;
    height: float = cast(float)(font.recs[index].height + 2.0*font.glyphPadding)/cast(float)font.baseSize*scale;

    if (font.texture.id > 0) {
        x: float = 0.0;
        y: float = 0.0;
        z: float = 0.0;

        // normalized texture coordinates of the glyph inside the font texture (0.0 -> 1.0)
        tx: float = srcRec.x/font.texture.width;
        ty: float = srcRec.y/font.texture.height;
        tw: float = (srcRec.x+srcRec.width)/font.texture.width;
        th: float = (srcRec.y+srcRec.height)/font.texture.height;

        if (SHOW_LETTER_BOUNDRY) DrawCubeWiresV(Vector3.{position.x + width/2, position.y, position.z + height/2}, Vector3.{width, LETTER_BOUNDRY_SIZE, height}, LETTER_BOUNDRY_COLOR);

        rlCheckRenderBatchLimit(cast(s32)(4 + 4 * (ifx backface then 1 else 0)));
        rlSetTexture(font.texture.id);
        defer rlSetTexture(0);

        rlPushMatrix();
        defer rlPopMatrix();

        rlTranslatef(position.x, position.y, position.z);

        rlBegin(RL_QUADS);
        defer rlEnd();

        rlColor4ub(tint.r, tint.g, tint.b, tint.a);

        // Front Face
        rlNormal3f(0.0, 1.0, 0.0);                                   // Normal Pointing Up
        rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z);              // Top Left Of The Texture and Quad
        rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height);     // Bottom Left Of The Texture and Quad
        rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height);     // Bottom Right Of The Texture and Quad
        rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z);              // Top Right Of The Texture and Quad

        if (backface) {
            // Back Face
            rlNormal3f(0.0, -1.0, 0.0);                              // Normal Pointing Down
            rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z);          // Top Right Of The Texture and Quad
            rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z);          // Top Left Of The Texture and Quad
            rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height); // Bottom Left Of The Texture and Quad
            rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height); // Bottom Right Of The Texture and Quad
        }
    }
}

// Draw a 2D text in 3D space
DrawText3D :: (font: Font, text: *u8, position: Vector3, fontSize: float, fontSpacing: float, lineSpacing: float, backface: bool, tint: Color) {
    length: s32 = cast(s32) TextLength(text);          // Total length in bytes of the text, scanned by codepoints in loop

    textOffsetY: float = 0.0;               // Offset between lines (on line break '\n')
    textOffsetX: float = 0.0;               // Offset X to next character to draw

    scale: float = fontSize/cast(float)font.baseSize;

    i: s32 = 0;
    while (i < length) {
        // Get next codepoint from byte string and glyph index in font
        codepointByteCount: s32 = 0;
        codepoint: s32 = GetCodepoint(*text[i], *codepointByteCount);
        index: s32 = GetGlyphIndex(font, codepoint);

        // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if (codepoint == 0x3f) codepointByteCount = 1;

        if (codepoint == #char "\n") {
            // NOTE: Fixed line spacing of 1.5 line-height
            // TODO: Support custom line spacing defined by user
            textOffsetY += scale + lineSpacing/cast(float)font.baseSize*scale;
            textOffsetX = 0.0;
        } else {
            if ((codepoint != #char " ") && (codepoint != #char "\t")) {
                DrawTextCodepoint3D(font, codepoint, Vector3.{position.x + textOffsetX, position.y, position.z + textOffsetY}, fontSize, backface, tint);
            }

            if (font.glyphs[index].advanceX == 0) textOffsetX += cast(float)(font.recs[index].width + fontSpacing)/cast(float)font.baseSize*scale;
            else textOffsetX += cast(float)(font.glyphs[index].advanceX + fontSpacing)/cast(float)font.baseSize*scale;
        }

        i += codepointByteCount;   // Move text bytes counter to next codepoint
    }
}

// Measure a text in 3D. For some reason `MeasureTextEx()` just doesn't seem to work so i had to use this instead.
MeasureText3D :: (font: Font, text: *u8, fontSize: float, fontSpacing: float, lineSpacing: float) -> Vector3 {
    len       : s32 = cast(s32) TextLength(text);
    tempLen   : s32 = 0;                // Used to count longer text line num chars
    lenCounter: s32 = 0;

    tempTextWidth: float = 0.0;     // Used to count longer text line width

    scale     : float = fontSize/cast(float)font.baseSize;
    textHeight: float = scale;
    textWidth : float = 0.0;

    letter: s32 = 0;                 // Current character
    index : s32 = 0;                  // Index position in sprite font

    for i: 0..len-1 {
        lenCounter += 1;

        next: s32 = 0;
        letter = GetCodepoint(*text[i], *next);
        index = GetGlyphIndex(font, letter);

        // NOTE: normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol so to not skip any we set next = 1
        if (letter == 0x3f) next = 1;
        i += next - 1;

        if (letter != #char "\n") {
            if (font.glyphs[index].advanceX != 0) textWidth += (font.glyphs[index].advanceX+fontSpacing)/cast(float)font.baseSize*scale;
            else textWidth += (font.recs[index].width + font.glyphs[index].offsetX)/cast(float)font.baseSize*scale;
        } else {
            if (tempTextWidth < textWidth) tempTextWidth = textWidth;
            lenCounter = 0;
            textWidth = 0.0;
            textHeight += scale + lineSpacing/cast(float)font.baseSize*scale;
        }

        if (tempLen < lenCounter) tempLen = lenCounter;
    }

    if (tempTextWidth < textWidth) tempTextWidth = textWidth;

    vec: Vector3;
    vec.x = tempTextWidth + cast(float)((tempLen - 1)*fontSpacing/cast(float)font.baseSize*scale); // Adds chars spacing to measure
    vec.y = 0.25;
    vec.z = textHeight;

    return vec;
}

// Draw a 2D text in 3D space and wave the parts that start with `~~` and end with `~~`.
// This is a modified version of the original code by @Nighten found here https://github.com/NightenDushi/Raylib_DrawTextStyle
DrawTextWave3D :: (font: Font, text: *u8, position: Vector3, fontSize: float, fontSpacing: float, lineSpacing: float, backface: bool, config: *WaveTextConfig, time: float, tint: Color) {
    length: s32 = cast(s32) TextLength(text);          // Total length in bytes of the text, scanned by codepoints in loop

    textOffsetY: float = 0.0;               // Offset between lines (on line break '\n')
    textOffsetX: float = 0.0;               // Offset X to next character to draw

    scale: float = fontSize/cast(float)font.baseSize;

    wave: bool = false;

    i: s32 = 0;
    k: s32 = 0;
    while (i < length) {
        k += 1;

        // Get next codepoint from byte string and glyph index in font
        codepointByteCount: s32 = 0;
        codepoint         : s32 = GetCodepoint(*text[i], *codepointByteCount);
        index             : s32 = GetGlyphIndex(font, codepoint);

        // NOTE: Normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol moving one byte
        if (codepoint == 0x3f) codepointByteCount = 1;

        if (codepoint == #char "\n") {
            // NOTE: Fixed line spacing of 1.5 line-height
            // TODO: Support custom line spacing defined by user
            textOffsetY += scale + lineSpacing/cast(float)font.baseSize*scale;
            textOffsetX = 0.0;
            k = 0;
        } else if (codepoint == #char "~") {
            if (GetCodepoint(*text[i+1], *codepointByteCount) == #char "~") {
                codepointByteCount += 1;
                wave = !wave;
            }
        } else {
            if ((codepoint != #char " ") && (codepoint != #char "\t")) {
                pos: Vector3 = position;
                if (wave) { // Apply the wave effect
                    pos.x += sin(time*config.waveSpeed.x-k*config.waveOffset.x)*config.waveRange.x;
                    pos.y += sin(time*config.waveSpeed.y-k*config.waveOffset.y)*config.waveRange.y;
                    pos.z += sin(time*config.waveSpeed.z-k*config.waveOffset.z)*config.waveRange.z;
                }

                DrawTextCodepoint3D(font, codepoint, Vector3.{pos.x + textOffsetX, pos.y, pos.z + textOffsetY}, fontSize, backface, tint);
            }

            if (font.glyphs[index].advanceX == 0) textOffsetX += cast(float)(font.recs[index].width + fontSpacing)/cast(float)font.baseSize*scale;
            else textOffsetX += cast(float)(font.glyphs[index].advanceX + fontSpacing)/cast(float)font.baseSize*scale;
        }

        i += codepointByteCount;   // Move text bytes counter to next codepoint
    }
}

// Measure a text in 3D ignoring the `~~` chars.
MeasureTextWave3D :: (font: Font, text: *u8, fontSize: float, fontSpacing: float, lineSpacing: float) -> Vector3 {
    len       : s32 = cast(s32) TextLength(text);
    tempLen   : s32 = 0;                // Used to count longer text line num chars
    lenCounter: s32 = 0;

    tempTextWidth: float = 0.0;     // Used to count longer text line width

    scale     : float = fontSize/cast(float)font.baseSize;
    textHeight: float = scale;
    textWidth : float = 0.0;

    letter: s32 = 0;                 // Current character
    index : s32 = 0;                  // Index position in sprite font

    for i: 0..len-1 {
        lenCounter += 1;

        next: s32 = 0;
        letter = GetCodepoint(*text[i], *next);
        index = GetGlyphIndex(font, letter);

        // NOTE: normally we exit the decoding sequence as soon as a bad byte is found (and return 0x3f)
        // but we need to draw all of the bad bytes using the '?' symbol so to not skip any we set next = 1
        if (letter == 0x3f) next = 1;
        i += next - 1;

        if (letter != #char "\n") {
            if (letter == #char "~" && GetCodepoint(*text[i+1], *next) == #char "~") {
                i += 1;
            } else {
                if (font.glyphs[index].advanceX != 0) textWidth += (font.glyphs[index].advanceX+fontSpacing)/cast(float)font.baseSize*scale;
                else textWidth += (font.recs[index].width + font.glyphs[index].offsetX)/cast(float)font.baseSize*scale;
            }
        } else {
            if (tempTextWidth < textWidth) tempTextWidth = textWidth;
            lenCounter = 0;
            textWidth = 0.0;
            textHeight += scale + lineSpacing/cast(float)font.baseSize*scale;
        }

        if (tempLen < lenCounter) tempLen = lenCounter;
    }

    if (tempTextWidth < textWidth) tempTextWidth = textWidth;

    vec: Vector3;
    vec.x = tempTextWidth + cast(float)((tempLen - 1)*fontSpacing/cast(float)font.baseSize*scale); // Adds chars spacing to measure
    vec.y = 0.25;
    vec.z = textHeight;

    return vec;
}

// Generates a nice color with a random hue
GenerateRandomColor :: (s: float, v: float) -> Color {
    Phi: float = cast(float) 0.618033988749895; // Golden ratio conjugate
    h: float = cast(float)GetRandomValue(0, 360);
    h = fmod_cycling((h + h*Phi), 360.0);
    return ColorFromHSV(h, s, v);
}
