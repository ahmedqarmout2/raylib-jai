Basic  :: #import "Basic";
File   :: #import "File";
String :: #import "String";

String_Builder   :: Basic.String_Builder;
print            :: Basic.print;
print_to_builder :: Basic.print_to_builder;

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

// Even values are the raylib types
// Odd values are the jai types
STRUCT_MAP  :: string.[
    "Matrix", "Matrix4"
];

JAI_STRUCTS :: string.["Vector2", "Vector3", "Vector4", "Matrix", "Quaternion"];

DOUBLE_POINTER :: "**";
SINGLE_POINTER :: "*";
STRUCT_PREFIX  :: "typedef struct";
RLAPI_PREFIX   :: "RLAPI";
CONST_PREFIX   :: "const";
REAYLIB_HEADER ::  #string DONE
//
// This file was auto-generated using the following command:
//
// jai generate.jai && ./generate.exe
//

#import "Math";

#if OS == .WINDOWS {
    user32  :: #library,system,link_always "user32";
    gdi32   :: #library,system,link_always "gdi32";
    shell32 :: #library,system,link_always "shell32";
    winmm   :: #library,system,link_always "winmm";

    raylib_native :: #library,no_dll "lib/raylib";
}
DONE

main :: () {
    generate_bindings("raylib",  "raylib");
    generate_bindings("raymath", "raymath");
}

g_line_counter : int;
g_lines_count  : int;

generate_bindings :: (input_filename: string, output_filename: string) {
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

    builder: String_Builder;
    print_to_builder(*builder, "%\n", REAYLIB_HEADER);

    file_data: string;
    file_data.data  = buffer;
    file_data.count = length;
    file_lines := String.split(file_data, "\n");
    g_lines_count = file_lines.count;

    for file_lines {
        if (!increment_line_counter()) {
            break;
        }

        if (is_empty_line_or_comments(file_lines, *builder)) {
            continue;
        }

        line := file_lines[g_line_counter];

        if (String.starts_with(line, STRUCT_PREFIX)) {
            handle_struct(file_lines, *builder);
            continue;
        }

        if (String.starts_with(line, RLAPI_PREFIX)) {
            handle_rplai(file_lines, *builder);
            continue;
        }

        // Print unrecognized lines
        // print("%\n", line);
    }

    Basic.free(buffer);
    File.file_close(*file);

    output_file := String.join("raylib/", output_filename, ".jai");
    File.write_entire_file(output_file, *builder);
    print("------------------------------------\n");
}

increment_line_counter :: () -> bool {
    g_line_counter += 1;
    return g_line_counter < g_lines_count - 1;
}

is_empty_line_or_comments :: (file_lines: []string, builder: *String_Builder) -> bool {
    line := file_lines[g_line_counter];

    clean_line := String.trim(line);
    if (clean_line.count == 0) {
        print_to_builder(builder, "\n");
        return true;
    }

    prefix := "/*";
    if (String.starts_with(clean_line, prefix)) {
        handle_comment_block(file_lines, builder);
        return true;
    }

    prefix = "//";
    if (String.starts_with(clean_line, prefix)) {
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
        print_to_builder(builder, "// TODO: parse this line. %\n", line);
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

    for i: 0..STRUCT_MAP.count-1 {
        _raylib_name := STRUCT_MAP[i];
        _jai_name    := STRUCT_MAP[i+1];
        
        // Skip the jai type in the next iteration
        i += 1;

        if (struct_name == _raylib_name) {
            struct_name = _jai_name;
            break;
        }
    }

    for JAI_STRUCTS {
        if (it == struct_name) {
            print_to_builder(builder, "// struct % is already defined in jai.\n", struct_name);
            return;
        }
    }

    print_to_builder(builder, "% :: struct {\n", struct_name);
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
            print_to_builder(builder, "}\n");
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

        print_to_builder(builder, "    %: %; %\n", remainder, jai_type, comment);
    }
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
    print_to_builder(builder, "% :: (", function_name);

    variables_combined := String.slice(remainder, left_bracket_idx + 1, right_bracket_idx - left_bracket_idx - 1);
    if (variables_combined != "void") {
        variables := String.split(variables_combined, ", ");
        for i: 0..variables.count-1 {
            variable := variables[i];

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