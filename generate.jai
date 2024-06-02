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

DOUBLE_POINTER :: "**";
SINGLE_POINTER :: "*";

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

        prefix := "typedef struct";
        if (String.starts_with(line, prefix)) {
            handle_struct(file_lines, *builder);
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
    suffix :: "*/";
    while (true) {
        line := String.trim(file_lines[g_line_counter]);
        print_to_builder(builder, "%\n", line);
        if (String.ends_with(line, suffix)) {
            return;
        }

        if (!increment_line_counter()) {
            print("EOF while looking for the end of a comment block\n");
            return;
        }
    }
}

handle_struct :: (file_lines: []string, builder: *String_Builder) {
    definition_line := file_lines[g_line_counter];

    if (String.contains(definition_line, ";")) {
        print_to_builder(builder, "// TODO: parse this line. %\n", definition_line);
        return;
    } 

    definition_line_parts := String.split(definition_line, " ");
    if (definition_line_parts.count < 4) {
        print("--Unexpected struct definition--\n");
        print("%\n", definition_line);
        print("--Expected: typedef struct <NAME> { --\n");
        return;
    }



    struct_name := definition_line_parts[2];
    struct_end  := String.join("} ", struct_name, ";");

    print_to_builder(builder, "% :: {\n", struct_name);
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

        line_parts := String.split(line, ";");
        if (line_parts.count != 2) {
            print("Unexpected struct data formart\n");
            print("%\n", struct_name);
            print("%\n", line);
            return;
        }

        struct_element := String.trim(line_parts[0]);
        comment        := line_parts[1];

        successful, jai_format := convert_struct_element_type(struct_element);
        if (!successful) {
            print("Unexpected struct element format\n");
            print("%\n", struct_name);
            print("%\n", line);
            return;
        }

        print_to_builder(builder, "    %; %\n", jai_format, comment);
    }
}

convert_struct_element_type :: (line: string) -> (successful: bool, jai_format: string) {
    c_type   := "";
    jai_type := "";

    for i: 0..TYPE_MAP.count-1 {
        _c_type   := TYPE_MAP[i];
        _jai_type := TYPE_MAP[i+1];

        // Skip the jai type in the next iteration
        i += 1;

        if (String.starts_with(line, _c_type)) {
            c_type   = _c_type;
            jai_type = _jai_type;
            break;
        }
    }

    // c_type does not need to be mapped to a jai_type
    if (c_type.count == 0 && jai_type.count == 0) {
        found, _c_type, _variables := String.split_from_left(line, " ");
        if (!found) {
            return false, "";
        }

        c_type   = _c_type;
        jai_type = _c_type;
    }

    // + 1 to account for the space after the c_type
    variables := String.slice(line, c_type.count + 1, line.count - c_type.count + 1);


    // Handle single and double pointer. For example: int *meshMaterial; or Transform **framePoses;
    pointer_prefix := "";
    if (String.starts_with(variables, DOUBLE_POINTER)) {
        pointer_prefix = DOUBLE_POINTER;              
    } else if (String.starts_with(variables, SINGLE_POINTER)) {
        pointer_prefix = SINGLE_POINTER;
    }

    jai_type  = String.join(pointer_prefix, jai_type);
    variables = String.slice(variables, pointer_prefix.count, variables.count - pointer_prefix.count);

    // Handle array types. For example: float v[3];
    right_bracket_idx := String.find_index_from_right(variables, "]");
    left_bracket_idx  := String.find_index_from_right(variables, "[");

    if (right_bracket_idx >= 0 && left_bracket_idx >= 0) {
        array_prefix := String.slice(variables, left_bracket_idx, right_bracket_idx - left_bracket_idx + 1);
        
        // Adjust the new type to inlcude array part
        jai_type = String.join(array_prefix, jai_type);
        
        // Adjust the variables to remove array part
        variables = String.slice(variables, 0, left_bracket_idx);
    }

    return true, String.join(variables, ": ", jai_type);
}
