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

// Even values are the C types
// Odd values are the jai types
TYPE_MAP :: string.[
    "const char",     "u8",
    "unsigned short", "u16",
    "unsigned int",   "u32",
    "unsigned char",  "u8",
    "char",           "s8",
    "long",           "s32",
    "double",         "float64",
    "int",            "s32",
    "Matrix",         "Matrix4"
];

JAI_STRUCTS :: string.["Vector2", "Vector3", "Vector4", "Matrix", "Quaternion"];

DOUBLE_POINTER :: "**";
SINGLE_POINTER :: "*";
STRUCT_PREFIX  :: "typedef struct";
RLAPI_PREFIX   :: "RLAPI";
CONST_PREFIX   :: "const";
ENUM_PREFIX    :: "typedef enum";
DEFINE_PREFIX  :: "#define";
RAYLIB_COLOR   :: "CLITERAL(Color)";
TYPEDEF_PREFIX :: "typedef";

GENERAL_HEADER ::  #string DONE
//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//
DONE

REAYLIB_FOOTER ::  #string DONE
#import "Math";

#if OS == .WINDOWS {
    user32  :: #library,system,link_always "user32";
    gdi32   :: #library,system,link_always "gdi32";
    shell32 :: #library,system,link_always "shell32";
    winmm   :: #library,system,link_always "winmm";

    raylib_native :: #library,no_dll "lib/raylib";
}

TraceLogCallback     :: #type (logType: s32, text: *u8, args: ..*u8);

#scope_file
Basic :: #import "Basic";

TraceLogCallback     :: #type (logLevel: TraceLogLevel, text: *u8, args: .. Any) #c_call;
LoadFileDataCallback :: #type (fileName: *u8, bytesRead: *u32) -> *u8 #c_call;
SaveFileDataCallback :: #type (fileName: *u8, data: *void, bytesToWrite: u32) -> bool #c_call;
LoadFileTextCallback :: #type (fileName: *u8) -> *u8 #c_call;
SaveFileTextCallback :: #type (fileName: *u8, text: *u8) -> bool #c_call;
AudioCallback        :: #type (bufferData: *void, frames: u32) -> bool #c_call;

#scope_file
DONE

main :: () {
    populate_improved_function_definitions_table();
    defer Hash_Table.deinit(*g_improved_function_definitions);

    populate_improved_struct_elements_table();
    defer Hash_Table.deinit(*g_improved_struct_elements);

    generate_bindings("raylib",  "raylib", REAYLIB_FOOTER);
    generate_bindings("raymath", "raymath", "");
}

g_line_counter : int;
g_lines_count  : int;

generate_bindings :: (input_filename: string, output_filename: string, file_footer: string) {
    g_line_counter = -1;
    g_lines_count  = 0;

    print("------------------------------------\n");
    print("Generate bindings for: %\n", input_filename);

    input_file := String.join("include/", input_filename, ".h");

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

    file_data: string;
    file_data.data  = buffer;
    file_data.count = length;
    file_lines := String.split(file_data, "\n");
    g_lines_count = file_lines.count;

    for file_lines {
        if (!increment_line_counter()) {
            break;
        }

        if (is_empty_line_or_comments(file_lines, *output_builder)) {
            continue;
        }

        line := file_lines[g_line_counter];

        if (String.starts_with(line, STRUCT_PREFIX)) {
            handle_struct(file_lines, *output_builder);
            continue;
        }

        if (String.starts_with(line, ENUM_PREFIX)) {
            handle_enum(file_lines, *output_builder);
            continue;
        }

        if (String.starts_with(line, RLAPI_PREFIX)) {
            handle_rplai(file_lines, *output_builder);
            continue;
        }

        if (String.starts_with(line, DEFINE_PREFIX)) {
            handle_define(file_lines, *output_builder);
            continue;
        }

        if (String.starts_with(line, TYPEDEF_PREFIX)) {
            handle_typedef(file_lines, *output_builder);
            continue;
        }

        // Print unrecognized lines
        print_to_builder(*unrecognized_builder, "%\n", line);
    }

    print_to_builder(*output_builder, "%\n", file_footer);

    Basic.free(buffer);
    File.file_close(*file);

    output_file := String.join("raylib/", output_filename, ".jai");
    File.write_entire_file(output_file, *output_builder);

    remainder_file := String.join("raylib/", output_filename, "_unrecognized.h");
    File.write_entire_file(remainder_file, *unrecognized_builder);
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

    Hash_Table.table_add(*g_improved_function_definitions, "IsGestureDetected", "(gesture: Gesture) -> bool");

    Hash_Table.table_add(*g_improved_function_definitions, "IsWindowState"    , "(flag: ConfigFlags) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "SetWindowState"   , "(flags: ConfigFlags)");
    Hash_Table.table_add(*g_improved_function_definitions, "ClearWindowState" , "(flags: ConfigFlags)");

    Hash_Table.table_add(*g_improved_function_definitions, "UpdateCamera", "(camera: Camera, mode: CameraMode)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetConfigFlags", "(flags: ConfigFlags)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetTraceLogLevel" , "(logType: TraceLogLevel)");
    Hash_Table.table_add(*g_improved_function_definitions, "SetTraceLogExit"  , "(logType: TraceLogLevel)");

    Hash_Table.table_add(*g_improved_function_definitions, "SetShaderValue"  , "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType)");
    Hash_Table.table_add(*g_improved_function_definitions, "SetShaderValueV" , "(shader: Shader, uniformLoc: s32, value: *void, uniformType: ShaderUniformDataType, count: s32)");

    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonPressed"  , "(gamepad: int, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonDown"     , "(gamepad: int, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonReleased" , "(gamepad: int, button: GamepadButton) -> bool");
    Hash_Table.table_add(*g_improved_function_definitions, "IsGamepadButtonUp"       , "(gamepad: int, button: GamepadButton) -> bool");

    Hash_Table.table_add(*g_improved_function_definitions, "GetGamepadAxisMovement", "(gamepad: int, axis: GamepadAxis) -> float");

    Hash_Table.table_add(*g_improved_function_definitions, "ImageKernelConvolution", "(image: *Image, kernel: *float, kernelSize: s32)");
}

populate_improved_struct_elements_table :: () {
    Hash_Table.table_add(*g_improved_struct_elements, "Camera3D_projection", "CameraProjection");
}

increment_line_counter :: () -> bool {
    g_line_counter += 1;
    return g_line_counter < g_lines_count - 1;
}

is_empty_line_or_comments :: (file_lines: []string, builder: *String_Builder) -> bool {
    line := file_lines[g_line_counter];

    trimmed_line := String.trim(line);
    if (trimmed_line.count == 0) {
        print_to_builder(builder, "\n");
        return true;
    }

    prefix := "/*";
    if (String.starts_with(trimmed_line, prefix)) {
        handle_comment_block(file_lines, builder);
        return true;
    }

    prefix = "//";
    if (String.starts_with(trimmed_line, prefix)) {
        print_to_builder(builder, "%\n", line);
        return true;
    }

    return false;
}

handle_comment_block :: (file_lines: []string, builder: *String_Builder) {
    line := String.trim(file_lines[g_line_counter]);

    print_to_builder(builder, "%\n", "/*");

    line = String.replace(line, "/*", "**");
    print_to_builder(builder, "%\n", line);

    suffix :: "*/";
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a comment block\n");
            return;
        }

        line = String.trim(file_lines[g_line_counter]);
        if (String.ends_with(line, suffix)) {
            line = String.replace(line, "*/", "**");
            print_to_builder(builder, "%\n", line);
            print_to_builder(builder, "%\n", "*/");
            return;
        }
        print_to_builder(builder, "%\n", line);
    }
}

handle_struct :: (file_lines: []string, builder: *String_Builder) {
    line := file_lines[g_line_counter];

    if (String.contains(line, ";")) {
        definition_parts := String.split(line, " ");
        struct_name      := definition_parts[2];
        print_to_builder(builder, "% :: struct { /* only used as a pointer in this header */ }\n", struct_name);
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
            print_to_builder(builder, "// struct % is already defined in jai.\n", struct_name);
            is_jai_struct = true;
            break;
        }
    }

    if (!is_jai_struct) {
        print_to_builder(builder, "% :: struct {\n", struct_name);
    }

    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of a struct: %\n", struct_name);
            return;
        }

        line := file_lines[g_line_counter];

        if (is_empty_line_or_comments(file_lines, builder)) {
            continue;
        }

        if (String.starts_with(line, struct_end)) {
            if (!is_jai_struct) {
                print_to_builder(builder, "}\n");
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

            print_to_builder(builder, "    %: %; %\n", remainder, ifx found_improvement then improved_element else jai_type, comment);
        }
    }
}

handle_enum :: (file_lines: []string, builder: *String_Builder) {
    enum_name := "";

    // Look ahead for enum name
    _g_line_counter := g_line_counter;
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of an enum.\n");
            return;
        }

        line := file_lines[g_line_counter];
        trimmed_line := String.trim(line);

        if (!String.starts_with(trimmed_line, "}") || !String.ends_with(trimmed_line, ";")) {
            continue;
        }

        success, definition, comment := String.split_from_left(trimmed_line, ";");
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

    print_to_builder(builder, "% :: enum {\n", enum_name);
    while (true) {
        if (!increment_line_counter()) {
            print("EOF while looking for the end of an enum.\n");
            return;
        }

        if (is_empty_line_or_comments(file_lines, builder)) {
            continue;
        }

        line := file_lines[g_line_counter];
        trimmed_line := String.trim(line);

        if (String.starts_with(trimmed_line, "}") && String.ends_with(trimmed_line, ";")) {
            print_to_builder(builder, "}\n");
            return;
        }

        enum_element := convert_enum_element(trimmed_line);
        print_to_builder(builder, "    %\n", enum_element);
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
    } else if (comma_index > 0 && comma_index < first_space_index) {
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
    return String.join(enum_element_name, enum_element_value, ";", enum_element_remainder);
}

handle_rplai :: (file_lines: []string, builder: *String_Builder) {
    line := file_lines[g_line_counter];

    success, definition, comment := String.split_from_left(line, ";");
    if (!success) {
        print("--Unexpected function definition--\n");
        print("%\n", definition);
        print("--Expected: RLAPI <RETURN> <NAME>(<PARAMETERS ...>); --\n");
        return;
    }

    // Remove RLAPI prefix
    definition = String.slice(definition, RLAPI_PREFIX.count + 1, definition.count - RLAPI_PREFIX.count);

    success1, c_type, jai_type, remainder := map_type(definition);
    if (!success1) {
        print("Unexpected function type\n");
        print("%\n", definition);
        return;
    }

    right_bracket_idx := String.find_index_from_right(remainder, ")");
    left_bracket_idx  := String.find_index_from_left(remainder, "(");

    function_name := String.slice(remainder, 0, left_bracket_idx);

    improved_definition, found_improvement := Hash_Table.table_find(*g_improved_function_definitions, function_name);
    if (found_improvement) {
        print_to_builder(builder, "% :: % #foreign raylib_native;\n", function_name, improved_definition);
        return;
    }
    
    print_to_builder(builder, "% :: (", function_name);

    variables_combined := String.slice(remainder, left_bracket_idx + 1, right_bracket_idx - left_bracket_idx - 1);
    if (variables_combined != "void") {
        variables := String.split(variables_combined, ",");
        for i: 0..variables.count-1 {
            variable := String.trim(variables[i]);

            if (variable == "...") {
                print_to_builder(builder, "args: ..*u8");
            } else {
                success2, variable_c_type, variable_jai_type, variable_name := map_type(variable);
                if (!success2) {
                    print("Unexpected function variable\n");
                    print("%\n", function_name);
                    print("%\n", variable);
                    return;
                }
                print_to_builder(builder, "%: %", variable_name, variable_jai_type);
            }

            if (i != variables.count-1) {
                print_to_builder(builder, ", ");
            }
        }
    }

    print_to_builder(builder, ")% #foreign raylib_native;\n", ifx jai_type == "void" then "" else String.join(" -> ", jai_type));
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
    } else if (String.starts_with(remainder, SINGLE_POINTER)) {
        pointer_prefix = SINGLE_POINTER;
    }

    jai_type  = String.join(pointer_prefix, jai_type);
    remainder = String.slice(remainder, pointer_prefix.count, remainder.count - pointer_prefix.count);

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

handle_define :: (file_lines: []string, builder: *String_Builder) {
    line := file_lines[g_line_counter];

    if (String.contains(line, RAYLIB_COLOR)) {
        raylib_color := String.slice(line, DEFINE_PREFIX.count + 1, line.count - DEFINE_PREFIX.count);
        jai_color    := String.replace(raylib_color, RAYLIB_COLOR, ":: Color.");
        jai_color     = String.replace(jai_color, "}", "};");
        print_to_builder(builder, "%\n", jai_color);
    }
}

handle_typedef :: (file_lines: []string, builder: *String_Builder) {
    line := file_lines[g_line_counter];

    found, code, remainder := String.split_from_left(line, ";");
    if (!found) {
        return;
    }

    code_parts := String.split(code, " ");

    if (code_parts.count == 3) {

        is_jai_struct := false;
        struct_name   := code_parts[2];
        for JAI_STRUCTS {
            if (it == struct_name) {
                print_to_builder(builder, "// struct % is already defined in jai.\n", struct_name);
                is_jai_struct = true;
                return;
            }
        }

        // code_parts[0] should be typedef
        print_to_builder(builder, "% :: %;\n", struct_name, code_parts[1]);
    }
}