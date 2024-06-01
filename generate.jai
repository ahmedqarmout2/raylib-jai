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
    "Matrix",         "Matrix4",
    "float",          "float"
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
    definition_line       := file_lines[g_line_counter];
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

        code_part := String.trim(line_parts[0]);
        comment   := line_parts[1];

        convert_type(code_part);

        // Indentation for formating
        // print_to_builder(builder, "    ");

        // Array prefix
        /*
        if (code_part.count == 2) {
            value := code_part[1];

            // Check if this is an array value
            right_bracket_idx := String.find_index_from_right(value, "]");
            left_bracket_idx  := String.find_index_from_right(value, "[");

            if (right_bracket_idx >= 0 && left_bracket_idx >= 0) {
                array_prefix := String.slice(value, left_bracket_idx, right_bracket_idx - left_bracket_idx + 1);
                
                // Adjust the new type to inlcude array part
                new_type = String.join(array_prefix, new_type);
                
                // Adjust the value to remove array part
                value = String.slice(value, 0, left_bracket_idx);
            }
            print_to_builder(builder, "%", value);
        } else {
            // We could have a list of names with one type. For example: float m0, m4, m8, m12;
            for i: 1..code_part.count-1 {
                print_to_builder(builder, "%", code_part[i]);
            }
        }

        print_to_builder(builder, ": %; %\n", new_type, comment);*/
    }
}

convert_type :: (line: string) -> string {
    for i: 0..TYPE_MAP.count-1 {
        c_type   := TYPE_MAP[i];
        jai_type := TYPE_MAP[i+1];

        // Skip the jai type in the next iteration
        i += 1;

        if (!String.starts_with(line, c_type)) {
            continue;
        }

        variables := String.slice(line, c_type.count, line.count - c_type.count);

        clean_variables := String.trim(variables);

        // Handle single and double pointer. For example: int *meshMaterial; or Transform **framePoses;
        pointer_prefix := "";
        if (String.starts_with(clean_variables, DOUBLE_POINTER)) {
            pointer_prefix = DOUBLE_POINTER;              
        } else if (String.starts_with(clean_variables, SINGLE_POINTER)) {
            pointer_prefix = SINGLE_POINTER;
        }

        jai_type = String.join(pointer_prefix, jai_type);
        clean_variables = String.slice(clean_variables, pointer_prefix.count, clean_variables.count - pointer_prefix.count);

        print("%: %\n", clean_variables, jai_type);
    }
    return line;
}
