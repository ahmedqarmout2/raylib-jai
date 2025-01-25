Basic      :: #import "Basic";
File       :: #import "File";
Hash_Table :: #import "Hash_Table";
String     :: #import "String";

String_Builder   :: Basic.String_Builder;
Table            :: Hash_Table.Table;
print            :: Basic.print;
print_to_builder :: Basic.print_to_builder;

g_improved_function_definitions : Table(string, string);
g_improved_struct_elements      : Table(string, string);
g_improved_definitions          : Table(string, string);

// Even values are the C types
// Odd values are the jai types
TYPE_MAP :: string.[
    "unsigned short", "u16",
    "unsigned int",   "u32",
    "unsigned char",  "u8",
    "char",           "u8",
    "long",           "s64",
    "double",         "float64",
    "int",            "s32",
    "Matrix",         "Matrix4"
];

JAI_STRUCTS        :: string.["Vector2", "Vector3", "Vector4", "Matrix", "Quaternion"];
REMOVED_CASTS      :: string.["(float)"];
KNOWN_FUNC_RETURNS :: string.["void", "Color"];

DOUBLE_POINTER   :: "**";
SINGLE_POINTER   :: "*";
STRUCT_PREFIX    :: "typedef struct";
RLAPI_PREFIX     :: "RLAPI";
RMAPI_PREFIX     :: "RMAPI";
RAYGUIAPI_PREFIX :: "RAYGUIAPI";
CONST_PREFIX     :: "const";
ENUM_PREFIX      :: "typedef enum";
DEFINE_PREFIX    :: "#define";
RAYLIB_COLOR     :: "CLITERAL(Color)";
TYPEDEF_PREFIX   :: "typedef";
IF_BEGIN_PREFIX  :: "#if ";
IF_END_PREFIX    :: "#endif";
SWITCH_PREFIX    :: "switch";
CASE_PREFIX      :: "case";
NUMBERS          :: "0123456789";
RLGL_END         :: "#endif // RLGL_H";
RCAMERA_END      :: "#endif // RCAMERA_H";

GENERAL_HEADER :: #string DONE
//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//
DONE

RAYLIB_HEADER :: #string DONE
#import "Basic";
#import "Math";
DONE

RAYLIB_FOOTER :: #string DONE
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

    raylib_native :: #library,no_dll "lib/raylib";
    raygui_native :: #library,no_dll "lib/raygui";
}
DONE

RAYMATH_HEADER :: #string DONE
EPSILON :: 0.000001;
DEG2RAD :: (PI/180.0);
RAD2DEG :: (180.0/PI);
DONE

main :: () {
    populate_improved_function_definitions_table();
    defer Hash_Table.deinit(*g_improved_function_definitions);

    populate_improved_struct_elements_table();
    defer Hash_Table.deinit(*g_improved_struct_elements);

    populate_improved_definitions();
    defer Hash_Table.deinit(*g_improved_definitions);

    generate_bindings("raylib" , RAYLIB_HEADER , RAYLIB_FOOTER, false);
    generate_bindings("raymath", RAYMATH_HEADER, ""           , false);
    generate_bindings("rlgl"   , ""            , ""           , false);
    generate_bindings("rcamera", ""            , ""           , false);
    generate_bindings("raygui" , ""            , ""           , false);
}

g_line_counter : int;
g_lines_count  : int;

generate_bindings :: (input_filename: string, file_header: string, file_footer: string, output_unrecognized_code: bool) {
    g_line_counter = -1;
    g_lines_count  = 0;

    print("------------------------------------\n");
    print("Generating bindings for: % ...\n", input_filename);

    input_file := String.join("c_headers/", input_filename, ".h");

    file, success := File.file_open(input_file);
    if !success {
        print("Could not open file: %\n", input_file);
        return;
    }

    length := File.file_length(file);
    buffer := cast(*u8) Basic.alloc(length);

    success = File.file_read(file, buffer, length);
    if !success {
        print("Could not read file: %\n", input_file);
        return;
    }

    output_builder       : String_Builder;
    unrecognized_builder : String_Builder;

    print_to_builder(*output_builder, "%\n", GENERAL_HEADER);
    print_to_builder(*output_builder, "%\n", file_header);

    file_data: string;
    file_data.data  = buffer;
    file_data.count = length;
    file_lines := String.split(file_data, "\n");
    g_lines_count = file_lines.count;

    for file_lines {
        if (!increment_line_counter()) {
            break;
        }

        if (is_empty_line_or_comments_or_ignored(file_lines, *output_builder, *unrecognized_builder)) {
            continue;
        }

        line := file_lines[g_line_counter];

        if (String.starts_with(line, STRUCT_PREFIX)) {
            handle_struct(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, ENUM_PREFIX)) {
            handle_enum(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, DEFINE_PREFIX)) {
            handle_define(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, TYPEDEF_PREFIX)) {
            handle_typedef(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, RLAPI_PREFIX)) {
            handle_rplai(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, RMAPI_PREFIX)) {
            handle_rmapi(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, RAYGUIAPI_PREFIX)) {
            handle_rayguiapi(file_lines, *output_builder, *unrecognized_builder);
            continue;
        }

        if (String.starts_with(line, RLGL_END) || String.starts_with(line, RCAMERA_END)) {
            break;
        }

        if (is_function(file_lines)) {
            // handle_full_function(file_lines);
            continue;
        }

        // Unrecognized lines
        print_to_builder(*unrecognized_builder, "%\n", line);
    }

    print_to_builder(*output_builder, "%\n", file_footer);

    Basic.free(buffer);
    File.file_close(*file);

    output_file := String.join("raylib/", input_filename, ".jai");
    File.write_entire_file(output_file, *output_builder);

    if (output_unrecognized_code) {
        remainder_file := String.join("raylib/", input_filename, "_unrecognized.h");
        File.write_entire_file(remainder_file, *unrecognized_builder);
    }

    print("Generated bindings for: %\n", input_filename);
    print("------------------------------------\n");
}

populate_improved_function_definitions_table :: () {
    Hash_Table.table_add(*g_improved_function_definitions, "IsKeyPressed"  , "(key: KeyboardKey) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsKeyDown"     , "(key: KeyboardKey) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsKeyReleased" , "(key: KeyboardKey) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsKeyUp"       , "(key: KeyboardKey) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "SetExitKey"    , "(key: KeyboardKey) -> bool");

    Hash_Table.table_add(*g_improved_function_definitions, "IsMouseButtonPressed"  , "(button: MouseButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsMouseButtonDown"     , "(button: MouseButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsMouseButtonReleased" , "(button: MouseButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsMouseButtonUp"       , "(button: MouseButton) -> bool");

    Hash_Table.table_add(*g_improved_function_definitions, "IsGestureDetected"  , "(gesture: Gesture) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "GetGestureDetected" , "() -> Gesture");

    Hash_Table.table_add(*g_improved_function_definitions, "IsWindowState"    , "(flag: ConfigFlags) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "SetWindowState"   , "(flags: ConfigFlags)");
    Hash_Table.table_add(*g_improved_function_definitions, "ClearWindowState" , "(flags: ConfigFlags)");

    Hash_Table.table_add(*g_improved_function_definitions, "UpdateCamera", "(camera: *Camera, mode: CameraMode)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetConfigFlags", "(flags: ConfigFlags)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetTraceLogLevel" , "(logType: TraceLogLevel)");
    Hash_Table.table_add(*g_improved_function_definitions, "SetTraceLogExit"  , "(logType: TraceLogLevel)");
    Hash_Table.table_add(*g_improved_function_definitions, "TraceLog"         , "(logLevel: TraceLogLevel, text: *u8, args: ..*u8)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetShaderValue"  , "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType)");
    Hash_Table.table_add(*g_improved_function_definitions, "SetShaderValueV" , "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType, count: s32)");

    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonPressed"  , "(gamepad: s32, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonDown"     , "(gamepad: s32, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonReleased" , "(gamepad: s32, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonUp"       , "(gamepad: s32, button: GamepadButton) -> bool");

    Hash_Table.table_add(*g_improved_function_definitions, "GetGamepadAxisMovement", "(gamepad: s32, axis: GamepadAxis) -> float");

    Hash_Table.table_add(*g_improved_function_definitions, "ImageKernelConvolution", "(image: *Image, kernel: *float, kernelSize: s32)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetTextureFilter", "(texture: Texture2D, filter: TextureFilter)");
    Hash_Table.table_add(*g_improved_function_definitions, "SetTextureWrap"  , "(texture: Texture2D, wrap: TextureWrap)");

    Hash_Table.table_add(*g_improved_function_definitions, "BeginBlendMode", "(mode: BlendMode)");

    Hash_Table.table_add(*g_improved_function_definitions, "ImageFormat", "(image: *Image, newFormat: PixelFormat)");

    Hash_Table.table_add(*g_improved_function_definitions, "LoadImageRaw", "(fileName: *u8, width: s32, height: s32, format: PixelFormat, headerSize: s32) -> Image");

    Hash_Table.table_add(*g_improved_function_definitions, "GetGamepadButtonPressed", "() -> GamepadButton");

    Hash_Table.table_add(*g_improved_function_definitions, "GetCharPressed", "() -> u8");

    Hash_Table.table_add(*g_improved_function_definitions, "LoadFontData", "(fileData: *u8, dataSize: s32, fontSize: s32, codepoints: *s32, codepointCount: s32, type: FontType) -> *GlyphInfo");

    Hash_Table.table_add(*g_improved_function_definitions, "SetMouseCursor", "(cursor: MouseCursor)");

    Hash_Table.table_add(*g_improved_function_definitions, "rlLoadTexture", "(data: *void, width: s32, height: s32, format: PixelFormat, mipmapCount: s32) -> u32");
    Hash_Table.table_add(*g_improved_function_definitions, "rlLoadTextureCubemap", "(data: *void, size: s32, format: PixelFormat, mipmapCount: s32) -> u32");
    Hash_Table.table_add(*g_improved_function_definitions, "rlFramebufferAttach", "(fboId: u32, texId: u32, attachType: rlFramebufferAttachType, texType: rlFramebufferAttachTextureType, mipLevel: s32)");
    Hash_Table.table_add(*g_improved_function_definitions, "rlSetUniform", "(locIndex: s32, value: *void, uniformType: ShaderUniformDataType, count: s32)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetMaterialTexture", "(material: *Material, mapType: MaterialMapIndex, texture: Texture2D)");

    Hash_Table.table_add(*g_improved_function_definitions, "LoadTextureCubemap", "(image: Image, layout: CubemapLayout) -> TextureCubemap");

    Hash_Table.table_add(*g_improved_function_definitions, "rlSetBlendMode", "(mode: BlendMode)");
}

populate_improved_struct_elements_table :: () {
    Hash_Table.table_add(*g_improved_struct_elements, "Camera3D_projection", "CameraProjection");

    Hash_Table.table_add(*g_improved_struct_elements, "Image_format"  , "PixelFormat");
    Hash_Table.table_add(*g_improved_struct_elements, "Texture_format", "PixelFormat");

    Hash_Table.table_add(*g_improved_struct_elements, "NPatchInfo_layout", "NPatchLayout");
}

populate_improved_definitions :: () {
    Hash_Table.table_add(*g_improved_definitions, "MOUSE_LEFT_BUTTON"   , "MOUSE_LEFT_BUTTON   :: MouseButton.MOUSE_BUTTON_LEFT");
    Hash_Table.table_add(*g_improved_definitions, "MOUSE_RIGHT_BUTTON"  , "MOUSE_RIGHT_BUTTON  :: MouseButton.MOUSE_BUTTON_RIGHT");
    Hash_Table.table_add(*g_improved_definitions, "MOUSE_MIDDLE_BUTTON" , "MOUSE_MIDDLE_BUTTON :: MouseButton.MOUSE_BUTTON_MIDDLE");

    Hash_Table.table_add(*g_improved_definitions, "MATERIAL_MAP_DIFFUSE"  , "MATERIAL_MAP_DIFFUSE  :: MaterialMapIndex.MATERIAL_MAP_ALBEDO");
    Hash_Table.table_add(*g_improved_definitions, "MATERIAL_MAP_SPECULAR" , "MATERIAL_MAP_SPECULAR :: MaterialMapIndex.MATERIAL_MAP_METALNESS");

    Hash_Table.table_add(*g_improved_definitions, "SHADER_LOC_MAP_DIFFUSE"  , "SHADER_LOC_MAP_DIFFUSE  :: ShaderLocationIndex.SHADER_LOC_MAP_ALBEDO");
    Hash_Table.table_add(*g_improved_definitions, "SHADER_LOC_MAP_SPECULAR" , "SHADER_LOC_MAP_SPECULAR :: ShaderLocationIndex.SHADER_LOC_MAP_METALNESS");

    Hash_Table.table_add(*g_improved_definitions, "RL_SHADER_LOC_MAP_DIFFUSE"  , "RL_SHADER_LOC_MAP_DIFFUSE  :: rlShaderLocationIndex.RL_SHADER_LOC_MAP_ALBEDO");
    Hash_Table.table_add(*g_improved_definitions, "RL_SHADER_LOC_MAP_SPECULAR" , "RL_SHADER_LOC_MAP_SPECULAR :: rlShaderLocationIndex.RL_SHADER_LOC_MAP_METALNESS");
}

increment_line_counter :: () -> bool {
    g_line_counter += 1;
    return g_line_counter < g_lines_count - 1;
}

is_empty_line_or_comments_or_ignored :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) -> bool {
    line := file_lines[g_line_counter];

    trimmed_line := String.trim(line);
    if (trimmed_line.count == 0) {
        print_to_builder(output_builder, "\n");
        return true;
    }

    prefix := "/*";
    if (String.starts_with(trimmed_line, prefix)) {
        handle_comment_block(file_lines, output_builder);
        return true;
    }

    prefix = "//";
    if (String.starts_with(trimmed_line, prefix)) {
        print_to_builder(output_builder, "%\n", line);
        return true;
    }

    if (String.starts_with(trimmed_line, IF_BEGIN_PREFIX)) {
        handle_ignored(file_lines, unrecognized_builder);
        return true;
    }

    return false;
}

handle_comment_block :: (file_lines: []string, output_builder: *String_Builder) {
    line := String.trim(file_lines[g_line_counter]);

    print_to_builder(output_builder, "%\n", "/*");

    line = String.replace(line, "/*", "**");
    print_to_builder(output_builder, "%\n", line);

    suffix :: "*/";
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a comment block\n");
            return;
        }

        line = String.trim(file_lines[g_line_counter]);
        if (String.ends_with(line, suffix)) {
            line = String.replace(line, "*/", "**");
            print_to_builder(output_builder, "%\n", line);
            print_to_builder(output_builder, "%\n", "*/");
            return;
        }
        print_to_builder(output_builder, "%\n", line);
    }
}

handle_ignored :: (file_lines: []string, unrecognized_builder: *String_Builder) {
    open_ifs := 0;
    while (true) {
        line := String.trim(file_lines[g_line_counter]);

        if (String.starts_with(line, IF_BEGIN_PREFIX)) {
            open_ifs += 1;
        }

        print_to_builder(unrecognized_builder, "%\n", line);

        if (String.starts_with(line, IF_END_PREFIX)) {
            open_ifs -= 1;

            if (open_ifs == 0) {
                return;
            }
        }

        if (!increment_line_counter()) {
            print("EOF while looking for the end of an ignored block\n");
            return;
        }
    }
}

handle_struct :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    if (String.contains(line, ";")) {
        definition_parts := String.split(line, " ");
        struct_name      := definition_parts[2];
        print_to_builder(output_builder, "% :: struct { /* only used as a pointer in this header */ }\n", struct_name);
        return;
    } 

    success, definition, comment := String.split_from_left(line, "{");
    if (!success) {
        print("--Unexpected struct definition--\n");
        print("%\n", definition);
        print("--Expected: typedef struct <NAME> { --\n");
        return;
    }

    definition        = String.trim(definition);
    definition_parts := String.split(definition, " ");
    if (definition_parts.count != 3) {
        print("--Unexpected struct definition--\n");
        print("%\n", definition);
        print("--Expected: typedef struct <NAME> { --\n");
        return;
    }

    struct_name := definition_parts[2];
    struct_end  := String.join("} ", struct_name, ";");

    is_jai_struct := false;
    for JAI_STRUCTS {
        if (it == struct_name) {
            print_to_builder(output_builder, "// struct % is already defined in jai.\n", struct_name);
            is_jai_struct = true;
            break;
        }
    }

    if (!is_jai_struct) {
        print_to_builder(output_builder, "% :: struct {\n", struct_name);
    }

    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a struct: %\n", struct_name);
            return;
        }

        line := file_lines[g_line_counter];

        if (is_empty_line_or_comments_or_ignored(file_lines, output_builder, unrecognized_builder)) {
            continue;
        }

        if (String.starts_with(line, struct_end)) {
            if (!is_jai_struct) {
                print_to_builder(output_builder, "}\n");
            }
            return;
        }

        success1, struct_element, comment := String.split_from_left(line, ";");
        if (!success1) {
            print("Unexpected struct element formart\n");
            print("%\n", struct_name);
            print("%\n", line);
            return;
        }

        struct_element = String.trim(struct_element);

        success2, c_type, jai_type, remainder := map_type(struct_element);
        if (!success2) {
            print("Unexpected struct element type\n");
            print("%\n", struct_name);
            print("%\n", struct_element);
            return;
        }

        if (!is_jai_struct) {
            improved_element, found_improvement := Hash_Table.table_find(*g_improved_struct_elements, String.join(struct_name, "_", remainder));

            print_to_builder(output_builder, "    %: %; %\n", remainder, ifx found_improvement then improved_element else jai_type, comment);
        }
    }
}

handle_enum :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    // Handle one line enum
    {
        line := String.trim(file_lines[g_line_counter]);
        if (String.contains(line, "}") && String.contains(line, ";")) {
            line = String.replace(line, ENUM_PREFIX, "");

            success1, enum_string, comment := String.split_from_left(line, ";");
            if (!success1) {
                print("--Unexpected enum definition--\n");
                print("%\n", line);
                return;
            }

            success2, enum_values, enum_name := String.split_from_left(enum_string, "}");
            if (!success2) {
                print("--Unexpected enum definition--\n");
                print("%\n", enum_string);
                return;
            }

            enum_values = String.replace(enum_values, ",", ";");
            enum_values = String.replace(enum_values, "=", "::");

            print_to_builder(output_builder, "% :: enum s32 %; } %\n", enum_name, enum_values, comment);
            return;
        }
    }

    enum_name := "";

    // Look ahead for enum name
    _g_line_counter := g_line_counter;
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of an enum.\n");
            return;
        }

        line := String.trim(file_lines[g_line_counter]);

        if (!String.starts_with(line, "}") || !String.ends_with(line, ";")) {
            continue;
        }

        success, definition, comment := String.split_from_left(line, ";");
        if (!success) {
            print("--Unexpected enum definition--\n");
            print("%\n", definition);
            print("--Expected: } <NAME>; --\n");
            return;
        }

        enum_name = String.replace(definition, "} ", "");
        break;
    }

    // Reset the line counter and process all enum files
    g_line_counter = _g_line_counter;

    print_to_builder(output_builder, "% :: enum s32 {\n", enum_name);
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of an enum.\n");
            return;
        }

        if (is_empty_line_or_comments_or_ignored(file_lines, output_builder, unrecognized_builder)) {
            continue;
        }

        line := String.trim(file_lines[g_line_counter]);

        if (String.starts_with(line, "}") && String.ends_with(line, ";")) {
            print_to_builder(output_builder, "}\n");
            return;
        }

        enum_element := convert_enum_element(line);
        print_to_builder(output_builder, "    %\n", enum_element);
    }
}

convert_enum_element :: (line: string) -> string {
    first_space_index             := 0;
    first_space_after_value_index := 0;
    equals_index                  := 0;
    comma_index                   := 0;
    for i: 0..line.count-1 {
        // Break on at the beginning of a comment
        if ((line[i] == #char "/") && (line[i+1] == #char "/")) {
            break;
        }

        t := line[i];

        if (t == #char " ") {
            if (first_space_index == 0) {
                first_space_index = i;
            }

            if (equals_index > 0 && i > (equals_index + 1) && first_space_after_value_index == 0) {
                first_space_after_value_index = i;
            }
        }

        if ((t == #char "=") && equals_index == 0) {
            equals_index = i;
        }

        if ((t == #char ",") && comma_index == 0) {
            comma_index = i;
        }
    }

    split_name_on_index      := 0;
    split_remainder_on_index := 0;
    end_value_on_index       := 0;
    if (equals_index > 0) {
        split_name_on_index      = equals_index;
        split_remainder_on_index = ifx (comma_index > 0) then comma_index + 1 else first_space_after_value_index;
        end_value_on_index       = ifx (comma_index > 0) then comma_index - 1 else first_space_after_value_index;
    } else if (comma_index > 0) {
        split_name_on_index      = comma_index;
        split_remainder_on_index = comma_index + 1;
    } else {
        split_name_on_index      = first_space_index;
        split_remainder_on_index = first_space_index;
    }

    enum_element_name  := String.slice(line, 0, split_name_on_index);
    enum_element_value := "";
    if (equals_index > 0) {
        enum_element_value = String.trim(String.slice(line, equals_index + 1, end_value_on_index - equals_index));
        enum_element_value = String.join(":: ", enum_element_value); 
    }
    enum_element_remainder := String.slice(line, split_remainder_on_index, line.count - split_remainder_on_index);
    
    // If there are no spaces, then the entire enum is the value.
    // For example: 
    // rlCullMode :: enum {
    //     RL_CULL_FACE_FRONT :: 0;
    //     RL_CULL_FACE_BACK;
    //}
    if (first_space_index == 0) {
        enum_element_value     = enum_element_remainder;
        enum_element_remainder = "";
    }
    return String.join(enum_element_name, enum_element_value, ";", enum_element_remainder);
}

handle_define :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    // Remove define prefix
    line = String.slice(line, DEFINE_PREFIX.count + 1, line.count - DEFINE_PREFIX.count);

    if (String.contains(line, RAYLIB_COLOR)) {
        jai_color := String.replace(line, RAYLIB_COLOR, ":: Color.");
        jai_color  = String.replace(jai_color, "}", "};");
        print_to_builder(output_builder, "%\n", jai_color);
        return;
    }

    if (!String.contains(line, " ")) {
        // For example: #define RL_COLOR_TYPE
        print_to_builder(unrecognized_builder, "% %\n", DEFINE_PREFIX, line);
        return;
    }

    line = String.trim(line);

    found, definition, remainder := String.split_from_left(line, " ");
    improved_definition, found_improvement := Hash_Table.table_find(*g_improved_definitions, definition);
    if (found_improvement) {
        print_to_builder(output_builder, "%;\n", improved_definition);
        return;
    }

    first_replacement      := false; // first space after some characters
    second_replacement     := false; // second space after some characters
    found_space_after_char := false;
    new_line := "";
    for i: 0..line.count-1 {
        c := String.slice(line, i, 1);
        if (c == " ") {
            if (!first_replacement) {
                new_line = String.join(new_line, " :: ");
                first_replacement = true;
                continue;
            } else if (found_space_after_char && !second_replacement) {
                new_line = String.join(new_line, ";");
                second_replacement = true;
                continue;
            }
        } else if (first_replacement) {
            found_space_after_char = true;
        }

        if (!second_replacement && line[i] == #char "/" && line[i+1] == #char "/" ) {
            new_line = String.join(new_line, ";");
            second_replacement = true;
        }
        new_line = String.join(new_line, c);
    }
    if (!second_replacement) {
        new_line = String.join(new_line, ";");
    }
    print_to_builder(output_builder, "%\n", new_line);
}

handle_typedef :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    // Remove typedef prefix
    line = String.slice(line, TYPEDEF_PREFIX.count + 1, line.count - TYPEDEF_PREFIX.count);

    found, code, remainder := String.split_from_left(line, ";");
    if (!found) {
        return;
    }

    code_parts := String.split(code, " ");

    if (code_parts.count == 2) {
        is_jai_struct := false;
        struct_name   := code_parts[1];
        for JAI_STRUCTS {
            if (it == struct_name) {
                print_to_builder(output_builder, "// struct % is already defined in jai.\n", struct_name);
                is_jai_struct = true;
                return;
            }
        }

        print_to_builder(output_builder, "% :: %;\n", struct_name, code_parts[0]);
    }
}

handle_rplai :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    // Remove RLAPI prefix
    line = String.slice(line, RLAPI_PREFIX.count + 1, line.count - RLAPI_PREFIX.count);

    success, definition, comment := String.split_from_left(line, ";");
    if (!success) {
        print("--Unexpected function definition--\n");
        print("% %\n", RLAPI_PREFIX, definition);
        print("--Expected: RLAPI <RETURN> <NAME>(<PARAMETERS ...>); --\n");
        return;
    }

    function_definition := convert_function_definition(definition);

    print_to_builder(output_builder, "% #foreign raylib_native;\n", function_definition);
}

handle_rmapi :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    // Remove RMAPI prefix
    line = String.slice(line, RMAPI_PREFIX.count + 1, line.count - RMAPI_PREFIX.count);

    function_definition := convert_function_definition(line);

    print_to_builder(output_builder, "% #foreign raylib_native;\n", function_definition);

    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a function.\n");
            return;
        }

        line := String.trim(file_lines[g_line_counter]);

        // Skip to the end of function
        if (String.starts_with(line, "}")) {
            return;
        }
    }
}

handle_rayguiapi :: (file_lines: []string, output_builder: *String_Builder, unrecognized_builder: *String_Builder) {
    line := file_lines[g_line_counter];

    // Remove RAYGUIAPI_PREFIX prefix
    line = String.slice(line, RAYGUIAPI_PREFIX.count + 1, line.count - RAYGUIAPI_PREFIX.count);

    success, definition, comment := String.split_from_left(line, ";");
    if (!success) {
        print("--Unexpected function definition--\n");
        print("% %\n", RAYGUIAPI_PREFIX, definition);
        print("--Expected: RAYGUIAPI <RETURN> <NAME>(<PARAMETERS ...>); --\n");
        return;
    }

    function_definition := convert_function_definition(definition);

    print_to_builder(output_builder, "% #foreign raygui_native;%\n", function_definition, comment);
}

remove_f_from_floats :: (line: string) {
    found_number := false;
    found_dot    := false;
    for i: 0..line.count-1 {
        c := line[i];
        if (String.contains(NUMBERS, c)) {
            found_number = true;
            continue;
        }
        if (c == #char "." && found_number) {
            found_dot = true;
            continue;
        }
        if (c == #char "f" && found_number && found_dot) {
            line[i] = #char " ";
        }
        found_number = false;
        found_dot    = false;
    }
}

is_function :: (file_lines: []string) -> bool {
    line := file_lines[g_line_counter];
    line = String.replace(line, "static", "");
    line = String.trim(line);

    for KNOWN_FUNC_RETURNS {
        if (String.starts_with(line, it)) {
            left_bracket_idx  := String.find_index_from_right(line, "(");
            right_bracket_idx := String.find_index_from_right(line, ")");
            if (left_bracket_idx > 0 && right_bracket_idx > left_bracket_idx) {
                func_bracket_idx := String.find_index_from_right(line, "{");
                if (func_bracket_idx > right_bracket_idx) {
                    return true;
                }

                next_line := file_lines[g_line_counter+1];
                if (String.starts_with(next_line, "{")) {
                    return true;
                }
            }
            return false;
        }
    }
    return false;
}

// THIS IS NOT COMPLETE YET, but I dont have a good reason to complete it. IT IS A PAIN
handle_full_function :: (file_lines: []string) {
    line := file_lines[g_line_counter];
    line = String.replace(line, "static", "");
    line = String.trim(line);

    right_bracket_idx := String.find_index_from_right(line, ")");

    c_function_definition   := String.slice(line, 0, right_bracket_idx + 1);
    jai_function_definition := convert_function_definition(c_function_definition);

    success, old_definition, first_line_remainder := String.split_from_left(line, ")");
    if (!success) {
        print("Unexpected function definition\n");
        print("%\n", line);
        return;
    }

    line = String.join(jai_function_definition, first_line_remainder);

    // print("FOUND A FUNCTION: %\n", line);
}

convert_function_definition :: (line: string) -> string {
    success, c_type, jai_type, remainder := map_type(line);
    if (!success) {
        print("Unexpected function type\n");
        print("%\n", line);
        return "";
    }

    right_bracket_idx := String.find_index_from_right(remainder, ")");
    left_bracket_idx  := String.find_index_from_left(remainder, "(");

    function_name := String.slice(remainder, 0, left_bracket_idx);

    improved_definition, found_improvement := Hash_Table.table_find(*g_improved_function_definitions, function_name);
    if (found_improvement) {
        return String.join(function_name, " :: ", improved_definition);
    }
    
    new_definition := String.join(function_name, " :: (");

    variables_combined := String.slice(remainder, left_bracket_idx + 1, right_bracket_idx - left_bracket_idx - 1);
    if (variables_combined != "void") {
        variables := String.split(variables_combined, ",");
        for i: 0..variables.count-1 {
            variable := String.trim(variables[i]);

            if (variable == "...") {
                new_definition = String.join(new_definition, "args: ..*u8");
            } else {
                success2, variable_c_type, variable_jai_type, variable_name := map_type(variable);
                if (!success2) {
                    print("Unexpected function variable\n");
                    print("%\n", function_name);
                    print("%\n", variable);
                    return "";
                }
                new_definition = String.join(new_definition, variable_name, ": ", variable_jai_type);
            }

            if (i != variables.count-1) {
                new_definition = String.join(new_definition, ", ");
            }
        }
    }

    
    return String.join(new_definition, ")", ifx jai_type == "void" then "" else String.join(" -> ", jai_type));
}

map_type :: (line: string) -> (success: bool, c_type: string, jai_type: string, remainder: string) {
    c_type   := "";
    jai_type := "";

    m_line := line;

    for i: 0..TYPE_MAP.count-1 {
        _c_type   := TYPE_MAP[i];
        _jai_type := TYPE_MAP[i+1];

        // Skip the jai type in the next iteration
        i += 1;

        if (String.starts_with(m_line, _c_type)) {
            c_type   = _c_type;
            jai_type = _jai_type;
            break;
        }

        _const_c_type := String.join(CONST_PREFIX, " ", _c_type);

        if (String.starts_with(m_line, _const_c_type)) {
            c_type   = _const_c_type;
            jai_type = _jai_type;
            break;
        }
    }

    // c_type does not need to be mapped to a jai_type
    if (c_type.count == 0 && jai_type.count == 0) {
        // Remove const prefix if not part of the type mapping
        if (String.starts_with(m_line, CONST_PREFIX)) {
            m_line = String.slice(m_line, CONST_PREFIX.count + 1, m_line.count - CONST_PREFIX.count);
        }

        found, _c_type, _remainder := String.split_from_left(m_line, " ");
        if (!found) {
            return false, "", "", "";
        }

        c_type   = _c_type;
        jai_type = _c_type;
    }

    // + 1 to account for the space after the c_type
    remainder := String.slice(m_line, c_type.count + 1, m_line.count - c_type.count);

    // Handle single and double pointer. For example: int *meshMaterial; or Transform **framePoses;
    pointer_prefix := "";
    if (String.starts_with(remainder, DOUBLE_POINTER)) {
        pointer_prefix = DOUBLE_POINTER;              
        remainder = String.slice(remainder, pointer_prefix.count, remainder.count - pointer_prefix.count);
    } else if (String.starts_with(remainder, SINGLE_POINTER)) {
        pointer_prefix = SINGLE_POINTER;
        remainder = String.slice(remainder, pointer_prefix.count, remainder.count - pointer_prefix.count);
    }

    // Handle single and double pointer in the variable name. For example: Camera* camera
    if (String.ends_with(jai_type, DOUBLE_POINTER)) {
        pointer_prefix = DOUBLE_POINTER; 
        jai_type = String.slice(jai_type, 0, jai_type.count - DOUBLE_POINTER.count);
    } else if (String.ends_with(jai_type, SINGLE_POINTER)) {
        pointer_prefix = SINGLE_POINTER;
        jai_type = String.slice(jai_type, 0, jai_type.count - SINGLE_POINTER.count);
    }

    jai_type = String.join(pointer_prefix, jai_type);

    // Handle array types. For example: float v[3];
    right_bracket_idx := String.find_index_from_right(remainder, "]");
    left_bracket_idx  := String.find_index_from_right(remainder, "[");

    if (right_bracket_idx >= 0 && left_bracket_idx >= 0) {
        array_prefix := String.slice(remainder, left_bracket_idx, right_bracket_idx - left_bracket_idx + 1);
        
        // Adjust the new type to inlcude array part
        jai_type = String.join(array_prefix, jai_type);
        
        // Adjust the remainder to remove array part
        remainder = String.slice(remainder, 0, left_bracket_idx);
    }

    return true, c_type, jai_type, remainder;
}

convert_assignment :: (line: string, with_type: bool) -> string {
    split_success, declaration, remainder := String.split_from_left(line, "=");
    if (!split_success) {
        print("Expected an equal sign\n");
        print("%\n", line);
        return "";
    }

    jai_type := "";
    new_line := "";
    if (with_type) {
        map_success, c_type, _jai_type, variable := map_type(declaration);
        if (!map_success) {
            print("Failed to map c values to jai\n");
            print("%\n", declaration);
            return "";
        }

        jai_type = _jai_type;
        variable = String.trim(variable);
        new_line = String.join(variable, ": ", jai_type);
    } else {
        new_line = declaration;
    }

    // Handle a multi assign. For example:
    //   float a00 = matViewProj.m0, a01 = matViewProj.m1, a02 = matViewProj.m2, a03 = matViewProj.m3;
    multi_assign_parts := String.split(remainder, "=");
    if (multi_assign_parts.count > 2 && with_type) {
        remainder = " ";
        for i: 0..multi_assign_parts.count-1 {
            t := String.trim(multi_assign_parts[i]);
            if (i < multi_assign_parts.count - 1) {
                t = String.replace(t, ",", ";");
                remainder = String.join(remainder, t, ":", jai_type, " = ");
            } else {
                remainder = String.join(remainder, t);
            }
        }
    }

    if (String.contains(remainder, " { 0 }")) {
        return String.join(new_line, ";");
    }

    remainder = String.trim(remainder);

    if (String.starts_with(remainder, "{")) {
        return String.join(new_line, " = ", jai_type, ".", remainder);
    }

    if (String.contains(remainder, "?")) {
        question_success, left, right := String.split_from_left(remainder, "?");
        if (!question_success) {
            print("Failed to split on question mark\n");
            print("%\n", remainder);
            return "";
        }
        right = String.replace(right, ":", "else");
        remainder = String.join("ifx ", left, " then ", right);
    }

    return String.join(new_line, " = ", remainder);
}
